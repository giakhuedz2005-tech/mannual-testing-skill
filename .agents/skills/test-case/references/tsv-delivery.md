# TSV Delivery Rules

Read this reference whenever a TSV test sheet is created or edited.

## Template precedence

If the user supplies a template or existing sheet, preserve its header text, spelling, order, duplicate columns, and column count exactly. Existing TSV files in this skill's `references/` folder are format examples only; they do not override the active project's template.

When no custom schema exists, use this canonical 16-column header:

```text
Screen	Test Scenario ID	Test Scenario Name	Test scenarios' Precondition overall	Test Condition ID	Test Condition Name	Test Case ID	Test Case Summary	Priority	Test Preconditions	Test Data, Input	Steps	Expected Result	Actual Result 1	Execution Notes	Actual Result 2
```

## Column rules

### Test Data, Input

The cell contains IDs only:

```text
TD-DOC-FC-004; TD-DOC-DECK-001
```

Do not include:

- descriptions after an em dash or hyphen;
- literal names, emails, boundary strings, payloads, or file paths;
- phrases such as `details generated separately`;
- a new data ID merely to mirror each test case ID.

Reuse an existing actor, resource, lifecycle, partition, or failure-state ID when its meaning is compatible. Compose multiple IDs with `; `. Each ID must have one stable definition in the separate test-data catalog.

Before concrete data is generated, each ID must also have a normalized definition in `Test data contract for <Feature>.tsv` according to [test-data-contract.md](test-data-contract.md). The test sheet contains IDs only; the contract contains semantic generation requirements; the downstream dictionary contains concrete values.

### Steps

- Number actions in execution order inside one physical TSV cell.
- Reference the exact `TD-*` IDs used by the case.
- For grouped partitions, state the loop, independent reset, and evidence capture.
- Use browser/user actions; no API calls, HTTP contracts, or Postman instructions.
- Do not place literal tabs or unescaped physical newlines inside cells.

### Expected Result

Use a single physical line containing:

```text
1. [UI] <observable result>. 2. [DB] <persistence or integrity result>.
```

Use `[UI/File]` for downloads. State exact copy only when confirmed. State confirmed table/column names only when schema evidence exists.

### Actual results

- New case: `Actual Result 1 = NOT RUN` and `Actual Result 2 = NOT RUN`.
- Unchanged existing case: preserve actual results and evidence.
- Materially rewritten or newly split case: reset to `NOT RUN` unless execution evidence was explicitly migrated.

### Execution Notes

Use concise metadata, for example:

```text
Perspective: Negative | Technique: BVA | Traceability: FR-DOC-010; AC-DOC-010-02
```

Record schema confirmation needs or approved assumptions here when no dedicated column exists.

## Hierarchy flattening

Each test case occupies exactly one physical row.

1. On the first case row of a scenario, populate `Screen` and all scenario fields.
2. Leave scenario fields empty on subsequent rows in the same scenario.
3. On the first case row of a condition, populate both condition fields.
4. Leave condition fields empty on subsequent rows in the same condition.
5. Keep all cases belonging to a scenario/condition contiguous.

Do not repeat parent metadata on every row and do not use spreadsheet merged cells.

## Identifier behavior

Follow project conventions. Otherwise use:

- `SCN-<AREA>-<NNN>`
- `COND-<AREA>-<NNN>`
- `TC-<AREA>-<NNN>`
- `TD-<AREA>-<PROFILE>-<NNN>`

IDs must be unique. Sequential numbering is desirable for a new draft, but preserving stable historical IDs takes precedence during an update unless the user requests renumbering.

## Physical file requirements

- Literal tab delimiter.
- UTF-8 without BOM.
- One header row.
- No extra blank rows.
- No literal tabs or physical newlines inside cells.
- Filename: `Test sheet for <Feature>.tsv`, unless the project specifies another name.

## TSV checklist

- Header and column count match the target template.
- Every physical data row has the same number of columns as the header.
- Hierarchy can be reconstructed without orphaned conditions or cases.
- Test case IDs are unique.
- Test data cells contain only `TD-*` IDs separated by semicolons.
- Every case has UI and DB expected-result markers.
- Every `TD-*` has an exact, non-orphaned definition in the companion test-data contract.
- No API execution semantics appear in steps.
- Actual results are preserved or reset according to change semantics.
- File is UTF-8 without BOM.
