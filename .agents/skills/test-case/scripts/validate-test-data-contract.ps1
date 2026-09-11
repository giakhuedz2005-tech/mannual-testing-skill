[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TestSheetPath,

    [Parameter(Mandatory = $true)]
    [string]$ContractPath,

    [string]$TestCaseIdColumn = 'Test Case ID',

    [string]$TestDataColumn = 'Test Data, Input',

    [switch]$RequireContiguousIds
)

$ErrorActionPreference = 'Stop'
$validationErrors = [System.Collections.Generic.List[string]]::new()

function Add-ValidationError {
    param([string]$Message)
    $validationErrors.Add($Message)
}

function Read-TsvRows {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "File not found: $Path"
    }
    return @(Import-Csv -LiteralPath $Path -Delimiter "`t" -Encoding UTF8)
}

function Split-ReferenceIds {
    param(
        [AllowEmptyString()][string]$Value,
        [string]$Pattern,
        [string]$Context
    )

    $result = [System.Collections.Generic.List[string]]::new()
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $result.ToArray()
    }

    foreach ($rawPart in ($Value -split '\s*;\s*')) {
        $part = $rawPart.Trim()
        if ([string]::IsNullOrWhiteSpace($part)) {
            continue
        }
        if ($part -cnotmatch $Pattern) {
            Add-ValidationError "$Context contains invalid reference '$part'."
            continue
        }
        if (-not $result.Contains($part)) {
            $result.Add($part)
        }
    }
    return $result.ToArray()
}

$contractHeader = @(
    'Data Ref ID (TD-*)',
    'Profile Name',
    'Profile Type',
    'Linked Test Case (TC-*)',
    'Field / Attribute',
    'Target Partition / Required State',
    'Constraint Source',
    'Generation Instruction',
    'Expected Behavior Class',
    'Dependencies / Setup',
    'Reuse / Isolation / Reset',
    'Open Assumptions'
)

$actualContractHeader = @((Get-Content -LiteralPath $ContractPath -Encoding UTF8 -TotalCount 1) -split "`t")
if ($actualContractHeader.Count -ne $contractHeader.Count) {
    Add-ValidationError "Contract header has $($actualContractHeader.Count) columns; expected $($contractHeader.Count)."
}
else {
    for ($index = 0; $index -lt $contractHeader.Count; $index++) {
        if ($actualContractHeader[$index] -cne $contractHeader[$index]) {
            Add-ValidationError "Contract header column $($index + 1) is '$($actualContractHeader[$index])'; expected '$($contractHeader[$index])'."
        }
    }
}

$testRows = Read-TsvRows -Path $TestSheetPath
$contractRows = Read-TsvRows -Path $ContractPath

if ($testRows.Count -eq 0) {
    Add-ValidationError 'Test sheet contains no data rows.'
}
if ($contractRows.Count -eq 0) {
    Add-ValidationError 'Test data contract contains no data rows.'
}

if ($testRows.Count -gt 0) {
    $testColumns = @($testRows[0].PSObject.Properties.Name)
    if ($TestCaseIdColumn -notin $testColumns) {
        Add-ValidationError "Test sheet is missing column '$TestCaseIdColumn'."
    }
    if ($TestDataColumn -notin $testColumns) {
        Add-ValidationError "Test sheet is missing column '$TestDataColumn'."
    }
}

$allowedProfileTypes = @('ACTOR', 'SESSION', 'RESOURCE', 'INPUT_PARTITION', 'STATE', 'FILE', 'FAILURE_MODE', 'MATRIX', 'REFERENCE', 'COMPUTED')
$tdPattern = '^TD-[A-Z0-9]+(?:-[A-Z0-9]+)+$'
$tcPattern = '^TC-[A-Z0-9]+(?:-[A-Z0-9]+)+$'
$testCaseData = @{}
$allTestCases = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$sheetProfiles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)

foreach ($row in $testRows) {
    $testCaseId = [string]$row.$TestCaseIdColumn
    if ([string]::IsNullOrWhiteSpace($testCaseId)) {
        continue
    }
    $testCaseId = $testCaseId.Trim()
    if ($testCaseId -cnotmatch $tcPattern) {
        Add-ValidationError "Test sheet contains invalid test case ID '$testCaseId'."
        continue
    }
    if (-not $allTestCases.Add($testCaseId)) {
        Add-ValidationError "Duplicate test case ID '$testCaseId' in test sheet."
        continue
    }

    $profiles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($profileId in (Split-ReferenceIds -Value ([string]$row.$TestDataColumn) -Pattern $tdPattern -Context "Test case $testCaseId")) {
        [void]$profiles.Add($profileId)
        [void]$sheetProfiles.Add($profileId)
    }
    $testCaseData[$testCaseId] = $profiles
}

$contractProfiles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$profileSemantics = @{}
$profileCaseCoverage = @{}
$requiredContractFields = $contractHeader

for ($rowIndex = 0; $rowIndex -lt $contractRows.Count; $rowIndex++) {
    $row = $contractRows[$rowIndex]
    $displayRow = $rowIndex + 2

    foreach ($field in $requiredContractFields) {
        if ([string]::IsNullOrWhiteSpace([string]$row.$field)) {
            Add-ValidationError "Contract row $displayRow has blank required field '$field'."
        }
    }

    $profileId = ([string]$row.'Data Ref ID (TD-*)').Trim()
    if ($profileId -cnotmatch $tdPattern) {
        Add-ValidationError "Contract row $displayRow contains invalid profile ID '$profileId'."
        continue
    }
    [void]$contractProfiles.Add($profileId)

    $profileName = ([string]$row.'Profile Name').Trim()
    $profileType = ([string]$row.'Profile Type').Trim()
    if ($profileType -cnotin $allowedProfileTypes) {
        Add-ValidationError "Contract row $displayRow uses unsupported Profile Type '$profileType'."
    }

    $semanticKey = "$profileName`n$profileType"
    if ($profileSemantics.ContainsKey($profileId) -and $profileSemantics[$profileId] -cne $semanticKey) {
        Add-ValidationError "Profile '$profileId' has inconsistent Profile Name or Profile Type across contract rows."
    }
    else {
        $profileSemantics[$profileId] = $semanticKey
    }

    if (-not $profileCaseCoverage.ContainsKey($profileId)) {
        $profileCaseCoverage[$profileId] = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    }

    $linkedCases = Split-ReferenceIds -Value ([string]$row.'Linked Test Case (TC-*)') -Pattern $tcPattern -Context "Contract row $displayRow"
    foreach ($linkedCase in $linkedCases) {
        [void]$profileCaseCoverage[$profileId].Add($linkedCase)
        if (-not $allTestCases.Contains($linkedCase)) {
            Add-ValidationError "Contract row $displayRow links unknown test case '$linkedCase'."
            continue
        }
        if (-not $testCaseData[$linkedCase].Contains($profileId)) {
            Add-ValidationError "Contract row $displayRow links '$linkedCase' to '$profileId', but the test case does not reference that profile."
        }
    }
}

foreach ($profileId in $sheetProfiles) {
    if (-not $contractProfiles.Contains($profileId)) {
        Add-ValidationError "Test sheet profile '$profileId' has no contract definition."
    }
}

foreach ($profileId in $contractProfiles) {
    if (-not $sheetProfiles.Contains($profileId)) {
        Add-ValidationError "Contract profile '$profileId' is orphaned and is not referenced by the test sheet."
    }
}

foreach ($testCaseId in $testCaseData.Keys) {
    foreach ($profileId in $testCaseData[$testCaseId]) {
        if ($contractProfiles.Contains($profileId) -and -not $profileCaseCoverage[$profileId].Contains($testCaseId)) {
            Add-ValidationError "Test case '$testCaseId' consumes '$profileId', but no applicable contract row links that case."
        }
    }
}

if ($RequireContiguousIds) {
    $namespaceNumbers = @{}
    foreach ($profileId in $contractProfiles) {
        if ($profileId -cmatch '^(TD-.+)-(\d{3})$') {
            $namespace = $Matches[1]
            $number = [int]$Matches[2]
            if (-not $namespaceNumbers.ContainsKey($namespace)) {
                $namespaceNumbers[$namespace] = [System.Collections.Generic.HashSet[int]]::new()
            }
            [void]$namespaceNumbers[$namespace].Add($number)
        }
    }
    foreach ($namespace in $namespaceNumbers.Keys) {
        $numbers = @($namespaceNumbers[$namespace] | Sort-Object)
        if ($numbers.Count -gt 0) {
            for ($expected = 1; $expected -le $numbers[-1]; $expected++) {
                if (-not $namespaceNumbers[$namespace].Contains($expected)) {
                    Add-ValidationError "Namespace '$namespace' is missing contiguous ID number $expected."
                }
            }
        }
    }
}

if ($validationErrors.Count -gt 0) {
    Write-Host "FAIL: Test data contract validation found $($validationErrors.Count) issue(s)." -ForegroundColor Red
    foreach ($issue in $validationErrors) {
        Write-Host "- $issue" -ForegroundColor Red
    }
    exit 1
}

Write-Host "PASS: $($allTestCases.Count) test case(s), $($contractProfiles.Count) TD profile(s), and $($contractRows.Count) contract row(s) are bidirectionally consistent." -ForegroundColor Green
