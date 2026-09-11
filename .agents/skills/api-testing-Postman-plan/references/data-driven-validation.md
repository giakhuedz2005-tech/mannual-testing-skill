# Data-driven validation for Postman

Read this reference only when the user wants to use CSV/Excel/JSON to run multiple test inputs, or when the selected API accepts an actual CSV/XLSX file.

## 1. Choosing the right file type

| Need | Usage | Planning considerations |
|---|---|---|
| Multiple inputs for the same request | CSV or JSON as iteration data for Collection Runner/Postman CLI | One row is one iteration; data variables are local and do not persist after the run. |
| Tester authors the matrix using Excel | XLSX is the authoring source, convert the approved tab to UTF-8 CSV or JSON before running | Source version and converted file must be traceable; preserve string/leading zero/blank semantics. |
| Workspace has Postman Datasets | Only use spreadsheet source directly when permissions/plan and beta support are confirmed by the user | Document dataset, data source, and view; prepare CSV/JSON fallback. |
| API accepts file upload | CSV/XLSX file is a fixture in multipart/binary request, not iteration input | Test upload contract: file type, MIME, schema, encoding, size, corrupt/missing file, content validation. |

Postman Collection Runner and Postman CLI accept CSV/JSON iteration data. Postman Datasets currently supports spreadsheet data sources but is in beta and depends on plan/permissions; do not use it as a default assumption.

## 2. When to use a matrix

Use a matrix for multiple independent variations sharing the same method/path/payload shape, such as valid/invalid/boundary for `age`, length/format of a field, enum, date format, or input combinations defined by requirements.

Do not use a matrix to replace tests requiring a dedicated request sequence or state: login/logout, create-read-update-delete, ownership/RBAC with different roles, concurrency, recovery/retry, idempotency, external dependency, or destructive cases. These belong to dedicated workflows/run profiles.

When a field has multiple invalid values with the same expected status/error/behavior, they can be grouped into one Basic TC with multiple rows. If the outcomes differ, have different side effects, or originate from different source requirements, split into corresponding BTCs/conditions.

## 3. Recommended matrix schema

Use consistent ASCII, camelCase or snake_case column names without changing capitalization. Minimum columns:

| Column | Meaning |
|---|---|
| `rowId` | Unique, stable key displayed in test output and evidence. |
| `basicTcId` | BTC/condition that the row executes; ensures backward traceability. |
| `apiId` | API ID defined by the contract. |
| `requestKey` | Permitted data-driven request/folder to run; used when explicit routing is needed. |
| `fieldPath` | Field path in the request (e.g., `body.age`), do not replace contract terms with inferred names. |
| `inputMode` | `literal`, `omit`, `jsonNull`, `emptyString`, `whitespace`, or a project-defined mode. |
| `inputValue` | Raw value meaningful only with `inputMode` and `valueType`. Do not use blank cells to implicitly mean null/omit. |
| `valueType` | E.g., `number`, `string`, `boolean`, `object`, `array`; used for safe downstream serialization. |
| `expectedStatus` | HTTP status confirmed by contract/requirements. |
| `expectedErrorCode` | Confirmed error code; leave intentionally blank when not contract-defined. |
| `expectedOutcome` | Controlled tag such as `success`, `validationError`, `noStateChange`; defined/traced in the plan. |
| `sourceRef` | API Contract/Convention/FRD section or requirement ID. |

Optional columns: `expectedFieldPath`, `expectedValueRule`, `expectedHeader`, `dataProfileId`, `priority`, `notes`, `fixtureId`, `cleanupRule`. Do not contain passwords, JWTs, API keys, or PII.

Example **schema**, not approved test data:

```csv
rowId,basicTcId,apiId,requestKey,fieldPath,inputMode,inputValue,valueType,expectedStatus,expectedErrorCode,expectedOutcome,sourceRef
AGE-NEG-001,BTC-API-USER-001-02,API-USER-001,update-user-age,body.age,literal,[value-defined-in-approved-data],number,[status-from-contract],[code-from-contract],validationError,API Contract §[endpoint]
```

## 4. CSV/Excel and conversion rules

- CSV must have headers exactly matching variable/column names; all rows must have the same number of columns; verify delimiter, quoting/escaping, and UTF-8 encoding before running.
- Keep identifier data or strings with leading zeros as text when exporting. Do not let Excel automatically convert to long numbers, dates, scientific notation, booleans, or trim whitespace.
- Do not use Excel formulas as runtime expected results. Materialize reviewed values before conversion; the matrix must not be a place to compute hidden/unauditable business rules.
- Each workbook must clearly indicate the used sheet/view, source version, owner, and export timestamp. A generated CSV/JSON must be reconciled against the source for row count + headers + unique rowIds.
- JSON is suitable if request input contains nested objects/arrays or needs to preserve numbers/booleans/null that CSV cannot easily represent. The structure is an array of objects with the same logical schema.
- Validate matrix before running: required headers, unique `rowId`, in-scope `apiId/requestKey`, valid `expectedStatus` per contract, supported `inputMode`/`valueType`, no secrets/PII.

## 5. Collection/run design

1. Create a narrow folder or collection `Data-driven validation — [API ID] — [payload]` containing one main request and only necessary helpers/assertions.
2. Run that folder with a matrix matching the endpoint/payload. Do not run the entire CRUD collection for each row unless that is the intended behavior with isolated cleanup.
3. Downstream pre-request specifications must map row → payload according to `fieldPath`, `inputMode`, `valueType`; preserve distinct omitted/null/empty/whitespace and fail-fast when a row is invalid.
4. Test specifications must assert response against `expectedStatus`, `expectedErrorCode`, `expectedOutcome` of the row; log/report `rowId`, `basicTcId`, `apiId`, request, and sourceRef upon failure.
5. Choose continue to collect full failure matrix validation; choose fail-fast only when setup/auth/matrix schema errors make subsequent rows untrustworthy. This decision must reside in the run profile.
6. For mutation endpoints, verify that each row does not corrupt data for subsequent rows. Prioritize invalid validation before persistence; if a success row creates state, add namespace/unique data and approved dedicated verification/cleanup.

## 6. Evidence and traceability

The artifact plan must record `Matrix ID`, source workbook/file, sheet/view, exported file/version, row count, row ID range, collection/folder, run profile, and execution evidence location. When a row fails, evidence must state at least `rowId`, `basicTcId`, API/request, actual status/error envelope, and response correlation/request ID if available.

Do not turn the entire spreadsheet into test case text within the plan. The plan traces condition/BTC groups to each `rowId` or range; the matrix file is a separately versioned test asset. When editing a row, assess the impact on BTC, assertion script, expected outcome, and coverage traceability.
