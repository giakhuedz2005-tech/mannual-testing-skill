[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [string]$ExpectedHeaderPath,

    [switch]$RequireTestData,

    [string[]]$AllowEmptyTestDataCaseId = @(),

    [switch]$RequireDbExpectation,

    [string[]]$UiOnlyScenarioId = @()
)

$ErrorActionPreference = 'Stop'
$resolvedPath = (Resolve-Path -LiteralPath $Path).Path
$errors = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

$bytes = [System.IO.File]::ReadAllBytes($resolvedPath)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $errors.Add('File contains a UTF-8 BOM; UTF-8 without BOM is required.')
}

$lines = [System.IO.File]::ReadAllLines($resolvedPath, [System.Text.UTF8Encoding]::new($false, $true))
if ($lines.Count -eq 0) {
    throw 'The TSV file is empty.'
}

$canonicalHeader = "Screen`tTest Scenario ID`tTest Scenario Name`tTest scenarios' Precondition overall`tTest Condition ID`tTest Condition Name`tTest Case ID`tTest Case Summary`tPriority`tTest Preconditions`tTest Data, Input`tSteps`tExpected Result`tActual Result 1`tExecution Notes`tActual Result 2"
$expectedHeader = $canonicalHeader
if ($ExpectedHeaderPath) {
    $resolvedHeaderPath = (Resolve-Path -LiteralPath $ExpectedHeaderPath).Path
    $expectedHeader = [System.IO.File]::ReadLines($resolvedHeaderPath, [System.Text.UTF8Encoding]::new($false, $true)) | Select-Object -First 1
}

if ($lines[0] -cne $expectedHeader) {
    $errors.Add('Header does not match the expected template exactly.')
}

$headers = $lines[0].Split("`t")
$columnCount = $headers.Count
for ($index = 1; $index -lt $lines.Count; $index++) {
    if ([string]::IsNullOrWhiteSpace($lines[$index])) {
        $errors.Add("Line $($index + 1) is blank.")
        continue
    }

    $actualCount = $lines[$index].Split("`t").Count
    if ($actualCount -ne $columnCount) {
        $errors.Add("Line $($index + 1) has $actualCount columns; expected $columnCount.")
    }
}

$requiredColumns = @(
    'Test Scenario ID',
    'Test Scenario Name',
    "Test scenarios' Precondition overall",
    'Test Condition ID',
    'Test Condition Name',
    'Test Case ID',
    'Test Case Summary',
    'Priority',
    'Test Data, Input',
    'Steps',
    'Expected Result',
    'Actual Result 1',
    'Execution Notes',
    'Actual Result 2'
)
foreach ($column in $requiredColumns) {
    if ($headers -notcontains $column) {
        $errors.Add("Required column '$column' is missing; semantic checks are incomplete.")
    }
}

$dbExpectationCount = 0
$uiOnlyExpectationCount = 0
$emptyTestDataCount = 0
$traceabilityCount = 0

if (($requiredColumns | Where-Object { $headers -notcontains $_ }).Count -eq 0) {
    $rows = @($lines | ConvertFrom-Csv -Delimiter "`t")
    $seenCases = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $seenScenarios = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $seenConditions = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $currentScenario = $null
    $currentCondition = $null
    $dataIdPattern = '^TD-[A-Z0-9]+(?:-[A-Z0-9]+)+(?:;\s*TD-[A-Z0-9]+(?:-[A-Z0-9]+)+)*$'

    for ($rowIndex = 0; $rowIndex -lt $rows.Count; $rowIndex++) {
        $row = $rows[$rowIndex]
        $lineNumber = $rowIndex + 2

        if ($row.'Test Scenario ID') {
            $currentScenario = $row.'Test Scenario ID'
            $currentCondition = $null
            if (-not $seenScenarios.Add($currentScenario)) {
                $errors.Add("Line $lineNumber starts Test Scenario '$currentScenario' more than once.")
            }
            if ([string]::IsNullOrWhiteSpace($row.'Test Scenario Name')) {
                $errors.Add("Line $lineNumber starts a Test Scenario without a name.")
            }
            if ([string]::IsNullOrWhiteSpace($row."Test scenarios' Precondition overall")) {
                $errors.Add("Line $lineNumber starts a Test Scenario without an overall precondition.")
            }
        } elseif ($row.'Test Scenario Name' -or $row."Test scenarios' Precondition overall") {
            $errors.Add("Line $lineNumber has Scenario details without a Test Scenario ID.")
        }
        if (-not $currentScenario) {
            $errors.Add("Line $lineNumber has no active Test Scenario.")
        }

        if ($row.'Test Condition ID') {
            $currentCondition = $row.'Test Condition ID'
            if (-not $seenConditions.Add($currentCondition)) {
                $errors.Add("Line $lineNumber starts Test Condition '$currentCondition' more than once.")
            }
            if ([string]::IsNullOrWhiteSpace($row.'Test Condition Name')) {
                $errors.Add("Line $lineNumber starts a Test Condition without a name.")
            }
        } elseif ($row.'Test Condition Name') {
            $errors.Add("Line $lineNumber has a Condition name without a Test Condition ID.")
        }
        if (-not $currentCondition) {
            $errors.Add("Line $lineNumber has no active Test Condition.")
        }

        $caseId = $row.'Test Case ID'
        if ([string]::IsNullOrWhiteSpace($caseId)) {
            $errors.Add("Line $lineNumber has no Test Case ID.")
        } elseif (-not $seenCases.Add($caseId)) {
            $errors.Add("Line $lineNumber repeats Test Case ID '$caseId'.")
        }

        foreach ($field in @('Test Case Summary', 'Priority', 'Steps', 'Expected Result', 'Execution Notes')) {
            if ([string]::IsNullOrWhiteSpace($row.$field)) {
                $errors.Add("Line $lineNumber has no value in '$field'.")
            }
        }
        if ($row.Priority -and $row.Priority -notin @('Critical', 'High', 'Medium', 'Low')) {
            $errors.Add("Line $lineNumber has unsupported Priority '$($row.Priority)'.")
        }

        $testData = $row.'Test Data, Input'.Trim()
        if ([string]::IsNullOrWhiteSpace($testData)) {
            $emptyTestDataCount++
            if ($RequireTestData -and $caseId -notin $AllowEmptyTestDataCaseId) {
                $errors.Add("Line $lineNumber Test Data is required for '$caseId'.")
            }
        } elseif ($testData -notmatch $dataIdPattern) {
            $errors.Add("Line $lineNumber Test Data must contain TD-* IDs only, separated by semicolons.")
        }

        $expected = $row.'Expected Result'
        if ($expected -notmatch '\[UI(?:/File)?\]') {
            $errors.Add("Line $lineNumber Expected Result is missing [UI] or [UI/File].")
        }

        $hasDbExpectation = $expected -match '\[DB\]'
        $isUiOnlyScenario = $currentScenario -in $UiOnlyScenarioId
        if ($hasDbExpectation) {
            $dbExpectationCount++
            if ($isUiOnlyScenario) {
                $errors.Add("Line $lineNumber belongs to UI-only Scenario '$currentScenario' but contains [DB].")
            }
            if ($expected -match '\[DB\]\s*$') {
                $errors.Add("Line $lineNumber has [DB] without a database result.")
            }
        } else {
            $uiOnlyExpectationCount++
            if ($RequireDbExpectation -and -not $isUiOnlyScenario) {
                $errors.Add("Line $lineNumber Expected Result is missing [DB] for non-UI-only Scenario '$currentScenario'.")
            }
        }

        if ($row.'Execution Notes' -match '(?i)\bTraceability\s*:') {
            $traceabilityCount++
        }

        $steps = $row.Steps
        if ($steps -match '(?i)\bcurl\b|\bvia\s+(?:the\s+)?api\b|\bsend\s+(?:an?\s+)?(?:POST|PUT|PATCH|DELETE|GET)\s+request\b') {
            $errors.Add("Line $lineNumber contains API execution semantics in Steps.")
        }

        foreach ($actualColumn in @('Actual Result 1', 'Actual Result 2')) {
            if ([string]::IsNullOrWhiteSpace($row.$actualColumn)) {
                $warnings.Add("Line $lineNumber '$actualColumn' is blank.")
            }
        }
    }
}

Write-Output "Validated: $resolvedPath"
Write-Output "Rows: $([Math]::Max(0, $lines.Count - 1)); Columns: $columnCount"
Write-Output "Expected Results: $dbExpectationCount with [DB]; $uiOnlyExpectationCount without [DB]"
Write-Output "Test Data: $emptyTestDataCount row(s) intentionally or conditionally empty"
Write-Output "Traceability: $traceabilityCount row(s)"

if ($traceabilityCount -gt 0) {
    $warnings.Add("$traceabilityCount row(s) contain Traceability. This is allowed; confirm with the user before removing or changing it.")
}

foreach ($warning in $warnings) {
    Write-Warning $warning
}

if ($errors.Count -gt 0) {
    foreach ($validationError in $errors) {
        Write-Error $validationError -ErrorAction Continue
    }
    Write-Output "Validation failed with $($errors.Count) error(s) and $($warnings.Count) warning(s)."
    exit 1
}

Write-Output "Validation passed with 0 errors and $($warnings.Count) warning(s)."
exit 0
