# Postman API Test Plan — Language Learning Hub — DOC Flashcards, AI, Sharing & Export

> **Version/Date:** v2.2 / 2026-09-03  
> **Execution Goal:** Collection Runner + smoke/regression + stateful end-to-end workflow  
> **Status:** Ready for local detailed cases/scripts and TSV matrix authoring; deterministic fault fixtures plus CSV export/hash validation remain blocked

## 1. Scope & References

### 1.1 In-Scope API Operations

| API ID | Module | Method & path | Actor/auth | Reason for inclusion | Contract reference |
|---|---|---|---|---|---|
| API-DOC-010 | DOC | POST `/decks/{deckId}/flashcards` | Active Learner / Bearer JWT | Manual create, validation, uniqueness, initial learning state | API-CONTRACT §5.2 API-DOC-010 |
| API-DOC-011 | DOC | GET `/decks/{deckId}/flashcards` | Active Learner / Bearer JWT | Empty/populated collection and post-action verification | API-CONTRACT §5.2 API-DOC-011 |
| API-DOC-012 | DOC | PATCH `/flashcards/{flashcardId}` | Active Learner / Bearer JWT | Partial/full edit, duplicate and immutable Deck relationship | API-CONTRACT §5.2 API-DOC-012 |
| API-DOC-013 | DOC | DELETE `/flashcards/{flashcardId}` | Active Learner / Bearer JWT | Permanent delete and downstream exclusion | API-CONTRACT §5.2 API-DOC-013 |
| API-DOC-014 | DOC | POST `/ai/flashcard-previews` | Active Learner / Bearer JWT | Language-aware temporary preview and Groq failure mapping | API-CONTRACT §5.2 API-DOC-014 |
| API-DOC-015 | DOC | POST `/generated-flashcards` | Active Learner / Bearer JWT | Atomic save to existing/new Deck | API-CONTRACT §5.2 API-DOC-015 |
| API-DOC-016 | DOC | POST `/decks/{deckId}/share` | Active Learner / Bearer JWT | Enable/idempotent/re-enable/concurrent sharing | API-CONTRACT §5.2 API-DOC-016 |
| API-DOC-017 | DOC | DELETE `/decks/{deckId}/share` | Active Learner / Bearer JWT | Disable/no-op disable and revocation | API-CONTRACT §5.2 API-DOC-017 |
| API-DOC-018 | DOC | GET `/shared-decks/{shareToken}` | Public / no auth | Strict public projection and invalid/inactive/deleted link behavior | API-CONTRACT §5.2 API-DOC-018 |
| API-DOC-019 | DOC | GET `/decks/{deckId}/export` | Active Learner / Bearer JWT | XLSX correctness/privacy/non-mutation/error behavior | API-CONTRACT §5.2 API-DOC-019 |

### 1.2 Out-of-Scope API Operations

| API ID/flow | Reason | Dependency impact |
|---|---|---|
| API-DOC-001..009 | Separate Folder/Deck CRUD suite | API-DOC-001/005/009 may be setup/cleanup providers only; not counted as in-scope coverage |
| AUTH APIs | Separate AUTH suite | Approved test actors/tokens must exist before execution |
| LEARN/DASH/NOTIF APIs | Separate module suites | Optional soft verification for SRS/downstream effects only |
| UI-only public restricted actions | Not an API-DOC-018 HTTP operation | Direct protected-call authorization is covered separately; UI action visibility belongs to UI testing |
| Production fault injection | Unsafe/non-deterministic | Groq/export fault cases require non-production mocks/stubs |
| Performance/load/rate limits | No selected-source threshold/status contract | Do not invent SLA, 429, 413, or payload-size expectations |

### 1.3 Key Traceability References

| Source ID | Document/version/path | Scope of use | Section/heading used | Reliability/gap |
|---|---|---|---|---|
| SRC-API-CONTRACT | `Language-learning-hub-for-quizz/docs/api/API-CONTRACT.md`, v1.0 | Canonical HTTP behavior and named payloads | §§2,3,3.1,5.1,5.2,9,11 | Owner-approved baseline; DOC details labelled Draft |
| SRC-API-CONVENTIONS | `Language-learning-hub-for-quizz/docs/api/API-CONVENTIONS.md`, v0.2 | Base path, auth, envelopes, status, dependency/security | §§3–10 | Canonical global convention |
| SRC-REQ-DOC | `Local LLH-Mannual testing project/Docs/requirements_spec_DOC_flashcard-sharing-export.md` | BR/FR/AC/fields/RBAC/downstream/risks | §§2–7 | Primary business evidence |
| SRC-FRD-DOC | `Language-learning-hub-for-quizz/docs/Requirement/FRD-DOC.md` | Detailed AC/state transitions | FR-DOC-009..019 | Supplementary detailed source |
| SRC-CR-DOC-001 | API-CONTRACT §2 + requirement field rules | Chinese field placement | CR-DOC-001 | Confirmed |
| SRC-RULES-API | `codex-testing-kit/.agents/rules/api_rules.md` | QA/security checklist | Auth, isolation, assertions | Secondary; cannot override contract |

### 1.4 Known TBDs & Limitations

| ID | Gap/assumption | Impact on test or script | Confirmation needed from | Status |
|---|---|---|---|---|
| TBD-01 | Local backend base URL and DEV Supabase execution target are approved; Vercel is frontend-only | Full suite uses `http://localhost:3000/api/v1`; Render production is outside this run scope | Environment owner | Resolved for selected scope |
| TBD-02 | Contract omits many endpoint-level codes; tester approved implementation-derived assumptions | Assert exact code using ASSUMP-DOC-ERR-01 and record mismatch as defect/contract drift | Tester/implementation | Resolved as approved assumption |
| TBD-03 | FRD casing conflicts with API text; implementation returns `Enabled`/`Disabled` | Assert exact Title Case values per ASSUMP-DOC-SHARE-01 | Tester/implementation | Resolved as approved assumption |
| TBD-04 | Contract omits `deckId` edit behavior; strict implementation schema rejects unknown fields | Assert `400 VALIDATION_ERROR`, unchanged Deck/content/SRS per ASSUMP-DOC-EDIT-01 | Tester/implementation | Resolved as approved assumption |
| TBD-05 | Contract omits exact export header syntax; implementation supplies exact values | Assert MIME and RFC 5987 disposition per ASSUMP-DOC-EXPORT-01 | Tester/implementation | Resolved as approved assumption |
| TBD-06 | Native Postman sandbox has no approved XLSX parser | Save the workbook and complete the external manual checklist; native script covers bytes/headers/filename only | Tester | Resolved by accepted manual check |
| TBD-07 | Owner-approved read-only Supabase verification is available | Compare `public.flashcards.review_level`, `next_review`, and `last_recall_rating` before/after mutation; never expose them in DOC JSON | Environment owner | Resolved |
| TBD-08 | Deterministic Groq 502/503/504/correction/ambiguous-save fixtures absent | External cases SKIPPED; never fault-inject production | Backend/QA | Open |
| TBD-09 | Deterministic export-failure fixture absent | API-DOC-019 500 recovery case SKIPPED | Backend/QA | Open |
| TBD-10 | Five UTF-8 TSV source matrices are now supplied; runner-ready CSV exports and their SHA-256 hashes are not yet produced | Authoring is complete, but each bulk profile remains blocked until its matching TSV is exported to UTF-8 CSV and the CSV hash is recorded | QA | Partially resolved |
| TBD-11 | Supabase development project is owner-controlled | Cleanup authority is confirmed; retain `docRunId` scoping as a safety guard | Environment owner | Resolved |
| TBD-12 | FRD specifies functional share URL `/share/deck/{shareToken}`, while the current backend/frontend implementation uses `/shared-decks/{shareToken}` | Token extraction and local API execution follow the current implementation; report the URL mismatch as contract drift until product owner confirms the canonical public URL | Product owner/API owner | Resolved for local execution by ASSUMP-DOC-SHARE-URL-01 |

### 1.5 Approved Tester Assumptions

| Assumption ID | Approved expected behavior | Evidence basis | Failure interpretation |
|---|---|---|---|
| ASSUMP-DOC-ERR-01 | `400 VALIDATION_ERROR`; `401 AUTHENTICATION_REQUIRED` or `INVALID_AUTH_TOKEN`; `403 PERMISSION_DENIED` or `ACCOUNT_RESTRICTED`; `404 RESOURCE_NOT_FOUND`; `409 DUPLICATE_RESOURCE`; AI `502 AI_DEPENDENCY_FAILED`, `503 AI_RATE_LIMITED`/`AMBIGUOUS_SAVE_RESULT`, `504 AI_TIMEOUT`; unexpected `500 INTERNAL_ERROR` | Current backend error catalog/middleware/DOC services; tester approval for vibe-code gaps | Report exact mismatch as implementation/contract drift; do not silently loosen assertion |
| ASSUMP-DOC-SHARE-01 | Enabled share returns `sharingStatus = Enabled`; disabled/no-op disable returns `sharingStatus = Disabled` | Current sharing service plus API-DOC-017 text | Report casing/value mismatch |
| ASSUMP-DOC-EDIT-01 | Extra `deckId` in PATCH body is rejected with `400 VALIDATION_ERROR`; resource and SRS remain unchanged | Strict Zod update schema and FR-DOC immutable Deck rule | Any 2xx, movement, or mutation is a defect |
| ASSUMP-DOC-EXPORT-01 | `Content-Type = application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`; `Content-Disposition = attachment; filename*=UTF-8''<encoded deck filename>` | Current export controller; API-DOC-019 filename rule | Header mismatch is a defect; workbook contents remain manual evidence |
| ASSUMP-DOC-SHARE-URL-01 | For this local execution baseline, `sharedDeckUrl` ends in `/shared-decks/{64-lowercase-hex-token}`; API-DOC-018 is called at the same API path | Current `sharing.service.ts`, frontend router and API-DOC-018 path; FRD still says `/share/deck/` | Any other path fails local execution; retain TBD-12 as explicit contract-drift evidence rather than silently accepting both formats |

## 2. API Conventions & Exclusions

| Dimension | Confirmed convention | Affected assertion/design | Source reference |
|---|---|---|---|
| Base/API style | HTTPS REST; base path `/api/v1`; camelCase; UTF-8 JSON | `baseUrl` ends `/api/v1`; paths relative | Conventions §3 |
| Media type | JSON uses application/json; export is binary exception | Never JSON-parse successful export | Conventions §§3,5; API-DOC-019 |
| Auth | Protected endpoints use Bearer JWT; API-DOC-018 is public | Isolate owner/foreign/Admin/deactivated/missing-invalid auth | Conventions §4 |
| Authorization | Authenticated wrong role/status/resource maps 403 | Cross-owner/Admin exact `PERMISSION_DENIED`; deactivated exact `ACCOUNT_RESTRICTED` | Conventions §§4,8; ASSUMP-DOC-ERR-01 |
| Success envelope | `{data,meta?}`; collections use array in data | Assert request-specific named payload | Conventions §6 |
| Error envelope | `{error:{code,message,details?,requestId}}`; message unstable | Assert status/shape/requestId and exact approved error code; never exact-match message | Conventions §7; ASSUMP-DOC-ERR-01 |
| IDs/secrets | IDs opaque; tokens/secrets never in URLs/logs except share token required by public path | Never infer ID semantics or log auth/share token | Conventions §§3,10 |
| Flashcard | id,deckId,term,meaning,exampleSentence,isMastered,createdAt,updatedAt; no raw SRS | Reject reviewLevel/nextReview/lastRecallRating leakage; verify preserved state with DEP-10 Supabase snapshot | Contract §3.1 |
| AI | AiPreviewResult; completed/partial; 60-second total deadline | 502/503/504 mapping, bounded backend behavior, no preview persistence | API-DOC-014; Conventions §9 |
| Generated save | GeneratedSaveResult; all-or-nothing transaction | Reload/reconcile ambiguous failure; never blind write retry | API-DOC-015 |
| PublicDeck | folderName,deckName,flashcardCount,FlashcardContent[] only | Exact allow-list; no IDs/PII/SRS/internal share/action fields | Contract §3.1; API-DOC-018 |
| Share | Token accepted by API-DOC-018 is 64 lowercase hex; re-enable never reuses old token; local implementation URL ends `/shared-decks/{token}` | Exact `Enabled`/`Disabled`, shape/idempotency/revocation/rotation and one exact local URL format | API-DOC-016..018; ASSUMP-DOC-SHARE-01; ASSUMP-DOC-SHARE-URL-01 |
| Export | Non-empty owned Deck, XLSX, UTC+7 filename, exact XLSX MIME and RFC 5987 disposition, columns No/Term/Meaning/Example Sentence | Header/filename/binary/privacy; manual workbook checklist verifies No starts 1, order and multiline cells | API-DOC-019; AMB-02; ASSUMP-DOC-EXPORT-01 |
| Excluded assumptions | No uncontracted pagination, sorting, 204, 415, 413, 429, SLA or retries | Record gaps rather than expected results | Conventions §§5,8,11 |

## 3. Environment & Collections Topology

### 3.1 Environment & Setup

| Variable | Scope | Secret? | Initial/current value policy | Source/producer | Consumers | Clear/expiry rule | Reference |
|---|---|---:|---|---|---|---|---|
| `baseUrl` | Environment | No | Selected suite value: `http://localhost:3000/api/v1`; never the Vercel frontend URL | Environment owner | All | Per environment | Conventions §3; TBD-01 resolved |
| `environmentName` | Environment | No | local/test/staging; fault/mutation profiles reject production | Runner | Guards/evidence | Per run | Safety |
| `learnerAAccessToken` | Environment | Yes | Active owner placeholder only | Approved auth setup | Protected owner requests | Expire/revoke; never export/commit/log | Conventions §4 |
| `learnerBAccessToken` | Environment | Yes | Active foreign Learner placeholder | Approved auth setup | RBAC | Same | RBAC |
| `adminAccessToken` | Environment | Yes | Admin placeholder | Approved auth setup | Role denial | Same | Permission matrix |
| `deactivatedLearnerToken` | Environment | Yes | Current deactivated Learner placeholder | Approved setup | Status denial | Same | Requirement §5.1 |
| `docRunId` | Collection | No | `AUTO_DOC_<UTC timestamp>_<random>` | SCR-COM-PRE-01 | Unique data/evidence | Unset teardown | Test-data rule |
| `docFolderId` | Collection | No | Created for run | Setup API-DOC-001 | AI new Deck/cleanup | Delete owned run fixture only | DEP-02 |
| `docDeckId` | Collection | No | Owned populated Deck | Setup API-DOC-005 | CRUD/share/export | Same | DEP-02 |
| `docEmptyDeckId` | Collection | No | Owned empty Deck | Setup API-DOC-005 | Empty cases | Same | DEP-02 |
| `docDisposableDeckId` | Collection | No | Owned namespaced Deck dedicated to delete/link invalidation | Setup API-DOC-005 | DEP-11 and guarded cleanup fallback | Delete through DEP-11; unset after confirmed DeleteResult | DEP-11 |
| `docForeignFolderId` | Collection | No | Learner B namespaced Folder | Isolated setup | Foreign Deck creation/cleanup | Cleanup as B only | DEP-04 |
| `docForeignDeckId` | Collection | No | Learner B Deck | Isolated setup | RBAC | Cleanup as B only | DEP-04 |
| `docFlashcardId` | Collection | No | API-DOC-010 data.id | Create | Edit/delete/verify | Unset after delete | DEP-03 |
| `docForeignFlashcardId` | Collection | No | Learner B card | Isolated setup | RBAC | Cleanup as B | DEP-04 |
| `docDeletedFlashcardId` | Collection | No | Copied before delete | Delete workflow | Omission/not-found | Unset teardown | DEP-03 |
| `docShareToken` | Collection | Yes | Extracted from ShareResult URL; never print/export current values | API-DOC-016 | API-DOC-018/017 | Unset after cleanup | DEP-12 |
| `docOldShareToken` | Collection | Yes | Retained only for revoke/rotation comparison | Share workflow | Revocation/re-enable | Unset teardown | DEP-12 |
| `docExpectedDeckSnapshot` | Collection | No | Sanitized hash/count/content baseline | Setup/read | Non-mutation | Unset teardown | BR-02.8 |
| `matrixRowId` | Run/local | No | Read-only iteration value | CSV | Matrix scripts/evidence | Iteration-only | §3.3 |

Requires two fictitious Active Learners, one deactivated Learner and one Admin. Credentials/tokens are never written. Fault cases require an approved non-production backend/mock. The owner-controlled Supabase development project permits cleanup, but cleanup still deletes only resources namespaced with current `docRunId`.

### 3.2 Data Profiles

| Data profile ID | Objective | Case type | Input shape/boundary | Isolation/uniqueness | Consuming cases |
|---|---|---|---|---|---|
| TD-DOC-JP-VALID-01 | Valid Japanese content | Positive | Kanji + applicable Sino; Hiragana/Vietnamese meaning; bilingual example | docRunId suffix | 010-01,014-01,015-01 |
| TD-DOC-CN-VALID-01 | Valid CR-DOC-001 Chinese content | Positive | Original-only term; Sino/Pinyin/Vietnamese meaning | docRunId suffix | 010-02,014-02,015-02 |
| TD-DOC-BOUNDARY-01 | Exact max lengths | Edge | 500/1000/500 Unicode code points | Unique term | 010-04 |
| TD-DOC-DUP-01 | Normalized duplicate | Negative | Trim/collapse/case-equivalent term | Dedicated two-card Deck | 010-05,012-04,015-06 |
| TD-DOC-AI-MIXED-01 | Parse/deduplicate | Edge | Comma/newline/blanks/normalized duplicates | Preview only | 014-03 |
| TD-DOC-AI-50-01 | Max AI item count | Edge | 50 unique items, <=3000 chars | External-cost profile | 014-04 |
| TD-DOC-PUBLIC-01 | Public projection | Positive/Security | Known Folder/Deck/cards | Dedicated share Deck | 018-01,018-06 |
| TD-DOC-EXPORT-01 | Workbook correctness/privacy | Positive | >=2 multilingual/multiline cards; unsafe Deck-name chars | Dedicated export Deck | 019-01 |
| TD-DOC-RBAC-01 | Cross-owner isolation | Negative | A request targets B resource | Dedicated foreign fixtures | RBAC cases |

### 3.3 Bulk Validation Matrices (TSV source → CSV runner asset)

The repository source format is UTF-8 TSV so JSON values remain reviewable. Before a Postman Collection Runner execution, export only the selected matrix to UTF-8 CSV and record that CSV's SHA-256. All five matrices use the same logical schema: `matrixId,rowId,basicTcId,apiId,requestKey,fieldPath,inputMode,inputValue,valueType,generatorCount,baselineBody,expectedStatus,expectedErrorCode,expectedOutcome,fixtureId,cleanupRule,sourceRef`. Validate exact headers, row count, unique row IDs, matrix/request identity, allowed modes/types, generator count, JSON baseline, no secrets/PII and SHA-256 before transmission.

Supported `inputMode` values are `literal`, `omit`, `jsonNull`, `emptyString`, `whitespace`, `repeatString`, and `sequenceString`. `repeatString` repeats `inputValue` exactly `generatorCount` times. `sequenceString` creates a comma-separated string of `inputValue1..N`; it is used for the 51-item AI boundary without storing a giant literal. `baselineBody` may contain Postman variables and is resolved before mutation. `body.$root` replaces the complete JSON body, which is required for empty-body and mutually-exclusive target-selector cases.

| Matrix ID | Source type | Endpoint/request scope | Row schema & mapping | Expected columns | Row count/group | Run folder/profile | Version/source | Traceability |
|---|---|---|---|---|---|---|---|---|
| MATRIX-DOC-010-VAL | Supplied TSV; CSV pending | API-DOC-010 create only | Mutate valid body by fieldPath/inputMode/valueType | Common schema | 15: C010-001..015; empty/whitespace/null/omit for 3 fields + 501/1001/501 | Bulk Create / RP-BULK-010 | `postman-matrix-doc-010-val.tsv` → `.csv` | BTC-DOC-010-03 |
| MATRIX-DOC-012-VAL | Supplied TSV; CSV pending | API-DOC-012 edit only | Mutate partial body; verify baseline after every rejected row | Common schema | 13: E012-001..013; empty/whitespace/null/over-limit + empty body | Bulk Edit / RP-BULK-012 | `postman-matrix-doc-012-val.tsv` → `.csv` | BTC-DOC-012-03 |
| MATRIX-DOC-014-VAL | Supplied TSV; CSV pending | API-DOC-014 validation only | Mutate targetLanguage/vocabularyList | Common schema | 11: A014-001..011; omitted/null/empty/whitespace/unsupported language/list, 51 items, 3001 chars | Bulk AI / RP-BULK-014 | `postman-matrix-doc-014-val.tsv` → `.csv` | BTC-DOC-014-05 |
| MATRIX-DOC-015-VAL | Supplied TSV; CSV pending | API-DOC-015 validation only | Mutate or replace body for target-selector/FlashcardContent validation | Common schema | 8: S015-001..008; empty selection, invalid content, both/no target modes, invalid newDeckName/content | Bulk AI Save / RP-BULK-015 | `postman-matrix-doc-015-val.tsv` → `.csv` | BTC-DOC-015-05 |
| MATRIX-DOC-018-TOKEN | Supplied TSV; CSV pending | API-DOC-018 token only | Substitute generated/static path token; never log it | Common schema | 5: P018-001..005; 63,65,uppercase,non-hex,unknown valid-shape. Empty path excluded. | Bulk Public Token / RP-BULK-018 | `postman-matrix-doc-018-token.tsv` → `.csv` | BTC-DOC-018-03 |

`expectedErrorCode` follows ASSUMP-DOC-ERR-01 for every matrix row. Blank cells never mean omit/null/empty; only `inputMode` defines those semantics.

## 4. One Physical Postman Collection and Top-Level Folders

Create one physical collection named `COL-LLH-DOC-API — DOC Flashcards, AI, Sharing & Export`. The `COL-DOC-*` identifiers below are top-level folders inside it, not separate Postman collections. This is required because `docRunId`, resource IDs and share-token handoffs use collection-variable scope and must remain available across setup, share, public, export and cleanup folders.

| Top-level folder ID/name | Actor/auth | API IDs | Child folders/order | Standalone prerequisites | Downstream folders | Cleanup/limitation |
|---|---|---|---|---|---|---|
| COL-DOC-00 Setup & Teardown | Learner A/B | Setup providers 001/005/007/009 plus 010 when needed | 00 Environment Gate → 01 Owner Fixtures → 02 Foreign Fixtures → 90 Verify Fixtures → 99 Cleanup | DEP-01 | All functional folders | Providers are out-of-scope support requests; delete only namespaced fixtures owned by the current actor |
| COL-DOC-01 Manual Flashcard Lifecycle | Learner A | 010–013 | Setup → Positive CRUD → narrow matrices → Edge/Conflict → Delete/Verify → Cleanup | DEP-01/02; bulk also DEP-06 | May expose explicit IDs to E2E only | Happy and bulk runs separated |
| COL-DOC-02 AI Preview & Atomic Save | Learner A + Groq | 014–015 | Setup → Positive → Parsing/Partial → External → Save → Validation/Conflict → Cleanup | DEP-01/02/07; external DEP-08; bulk DEP-06 | May create sharing/export fixtures | No blind write retry; external costs isolated |
| COL-DOC-03 Sharing Owner Workflow | Learner A | 016–017 | Setup → Enable/Idempotent → Concurrent → Disable/No-op → Re-enable → Cleanup | DEP-01/02/12; concurrency only also needs DEP-08 | Produces tokens for COL-DOC-04 | Tokens secret; disable owned share only |
| COL-DOC-04 Public Shared Deck | Public | 018 | Active Token → Populated/Empty → Revoked/Deleted → Token Matrix → Owner Cleanup | DEP-12; deleted case DEP-11 | Uses owner setup | Public requests have no Authorization |
| COL-DOC-05 Export | Learner A | 019 | Setup/Snapshot → Success → Empty/Missing → Fault → Post-state → Cleanup | DEP-01/02; approved manual workbook checklist; fault DEP-09 | None | Postman does not claim cell inspection |
| COL-DOC-06 Authorization & RBAC | A/B/Admin/deactivated | 010–017,019 | Isolated Fixtures → Cross-owner → Missing/Invalid Auth → Role/Status → Role-owned Cleanup | DEP-01/04/05 | None | Does not reuse happy mutable state |
| COL-DOC-07 E2E Regression | Learner A + Public + optional Groq | 010–019 | Setup → CRUD → preview/save → share/public/revoke/re-enable → export → delete/verify → cleanup | DEP-01/02/03/07/12 | Orchestrates request copies | Finite; excludes bulk/fault/concurrency/RBAC |

## 5. Basic Test Cases (BTC)

`Type` chỉ dùng Positive, Negative hoặc Edge; Group chứa tag RBAC/Security/Workflow/External/Concurrency. Plan v2.2 giữ 69 BTC; thay đổi phiên bản này sửa topology/dependency/matrix execution mà không thay đổi phạm vi coverage cơ bản.

### COL-DOC-01 — Manual Flashcard Lifecycle

| Basic TC ID | API ID / request | Group | Type | Objective/test condition | Precondition & data profile/matrix rows | Expected status/outcome | Required assertions | Variables in/out | Dependency/flow | Priority | Trace references |
|---|---|---|---|---|---|---|---|---|---|---|---|
| BTC-DOC-010-01 | API-DOC-010 create | Positive CRUD | Positive | Create valid Japanese card | Owned Deck; TD-DOC-JP-VALID-01 | 201; one card | Success envelope; exact Flashcard projection/content; no raw SRS; initial SRS snapshot via DEP-10 | docDeckId → docFlashcardId | DEP-01/02/10 | P0 | FR-DOC-010 |
| BTC-DOC-010-02 | API-DOC-010 create | Positive CRUD | Positive | Create valid CR-DOC-001 Chinese card | TD-DOC-CN-VALID-01 | 201; one card | Original-only term; ordered meaning; bilingual example; privacy | created ID | DEP-01/02 | P0 | FR-DOC-010; CR-DOC-001 |
| BTC-DOC-010-03 | API-DOC-010 create | Validation/Matrix | Negative | Reject invalid required/over-limit fields | C010-001..015 | 400 each; no card | Row status/error shape; exact `VALIDATION_ERROR`; rowId; count unchanged | iteration only | DEP-01/02/06 | P0 | FR-DOC-010; field specs; ASSUMP-DOC-ERR-01 |
| BTC-DOC-010-04 | API-DOC-010 create | Boundary | Edge | Accept exact 500/1000/500 limits | TD-DOC-BOUNDARY-01 | 201 | Unicode code-point lengths; returned content; no raw SRS | boundary ID | DEP-01/02 | P1 | FR-DOC-010 |
| BTC-DOC-010-05 | API-DOC-010 create | Conflict | Negative | Reject normalized duplicate in same Deck | TD-DOC-DUP-01 | 409 `DUPLICATE_RESOURCE`; no extra card | Error envelope; exact `DUPLICATE_RESOURCE`; no change | duplicate seed | DEP-03 | P0 | BR-02.4; RISK-05; ASSUMP-DOC-ERR-01 |
| BTC-DOC-010-06 | API-DOC-010 create | Not Found | Negative | Reject create against missing Deck | missingDeckId | 404; no card | Error envelope; no owner/resource leak | none | DEP-01 | P1 | API-DOC-010 |
| BTC-DOC-011-01 | API-DOC-011 list | Empty | Edge | List owned empty Deck | docEmptyDeckId | 200 data=[] | Success envelope; exactly empty array | input ID | DEP-02 | P1 | FR-DOC-009 |
| BTC-DOC-011-02 | API-DOC-011 list | Positive | Positive | List current populated Deck | Known cards | 200 | Exact Flashcard[] projection; known cards; no deleted/raw SRS | snapshot | DEP-03 | P0 | FR-DOC-009 |
| BTC-DOC-011-03 | API-DOC-011 list | Not Found | Negative | Missing Deck is not empty result | missingDeckId | 404 | Error envelope; no data | none | DEP-01 | P1 | API-DOC-011 |
| BTC-DOC-012-01 | API-DOC-012 edit | Partial | Positive | Update meaning only | Owned card baseline + Supabase SRS snapshot | 200; only meaning changes | Projection; term/example/deckId unchanged; before/after SRS snapshot equal via DEP-10 | docFlashcardId | DEP-03/10 | P0 | FR-DOC-011 |
| BTC-DOC-012-02 | API-DOC-012 edit | Full | Positive | Update all three fields | Unique valid content | 200 | Exact fields; same id/deckId; no raw SRS | docFlashcardId | DEP-03 | P0 | FR-DOC-011 |
| BTC-DOC-012-03 | API-DOC-012 edit | Validation/Matrix | Negative | Reject invalid edit bodies | E012-001..013 | 400 each; baseline retained | Row assertions; baseline equality | iteration | DEP-03/06 | P0 | FR-DOC-011 |
| BTC-DOC-012-04 | API-DOC-012 edit | Conflict | Negative | Reject duplicate term edit | TD-DOC-DUP-01 | 409; no change | Error envelope; content/association unchanged | two card IDs | DEP-03 | P0 | BR-02.4; RISK-05 |
| BTC-DOC-012-05 | API-DOC-012 edit | Mass Assignment | Negative | Attempt movement with extra deckId | Original/foreign IDs | 400 `VALIDATION_ERROR`; no movement/mutation | Exact error; owner reread and Supabase SRS snapshot unchanged | IDs | DEP-03/04/10 | P0 | FR-DOC-011; BR-02.4; ASSUMP-DOC-EDIT-01 |
| BTC-DOC-012-06 | API-DOC-012 edit | Not Found | Negative | Edit missing card | missingFlashcardId | 404; siblings unchanged | Error envelope; no state change | none | DEP-01 | P1 | API-DOC-012 |
| BTC-DOC-013-01 | API-DOC-013 delete | Delete | Positive | Permanently delete owned card | docFlashcardId | 200 | DeleteResult deleted/resourceId/counts | docDeletedFlashcardId | DEP-03 | P0 | FR-DOC-012; DeleteResult |
| BTC-DOC-013-02 | API-DOC-011 verify | Workflow | Positive | Deleted card omitted from DOC and approved downstream | Delete success | 200 list omits ID | List omits ID; DEP-10 query returns no row for deleted ID | deleted ID | DEP-03/10 | P0 | BR-02.5; RISK-04 |
| BTC-DOC-013-03 | API-DOC-013 delete | Not Found | Negative | Repeat delete/missing ID | deleted ID | 404; siblings unchanged | Error envelope; no mutation | deleted ID | DEP-03 | P1 | API-DOC-013 |

### COL-DOC-02 — AI Preview & Atomic Save

| Basic TC ID | API ID / request | Group | Type | Objective/test condition | Precondition & data profile/matrix rows | Expected status/outcome | Required assertions | Variables in/out | Dependency/flow | Priority | Trace references |
|---|---|---|---|---|---|---|---|---|---|---|---|
| BTC-DOC-014-01 | API-DOC-014 | AI/Japanese | Positive | Generate Japanese preview | TD-DOC-JP-VALID-01 | 200 completed/partial | AiPreviewResult; complete items; language/Sino rules; no persistence | local preview | DEP-01/07 | P0 | FR-DOC-013/014 |
| BTC-DOC-014-02 | API-DOC-014 | AI/Chinese | Positive | Generate Chinese preview | TD-DOC-CN-VALID-01 | 200 completed/partial | CR-DOC-001 field placement; no persistence | local preview | DEP-01/07 | P0 | CR-DOC-001 |
| BTC-DOC-014-03 | API-DOC-014 | Parsing/Dedup | Edge | Parse mixed delimiters, trim/ignore blanks/deduplicate | TD-DOC-AI-MIXED-01 | 200 | Each normalized unique input represented once | none | DEP-07 | P0 | FR-DOC-013 |
| BTC-DOC-014-04 | API-DOC-014 | Maximum | Edge | Accept 50 unique items within 3000 chars | TD-DOC-AI-50-01 | 200 | 50 inputs accounted once; no persistence | none | DEP-07 | P1 | FR-DOC-013 |
| BTC-DOC-014-05 | API-DOC-014 | Validation/Matrix | Negative | Reject invalid language/list inputs | A014-001..011 | 400 each; provider not called | Row/error/no persistence | iteration | DEP-01/06 | P0 | FR-DOC-013 |
| BTC-DOC-014-06 | API-DOC-014 | Partial/Language | Edge | Continue matching items and report mismatches | Mixed-language fixture | 200 partial | failedItems exact input + safe reason; valid items complete | none | DEP-07 | P0 | FR-DOC-013/014 |
| BTC-DOC-014-07 | API-DOC-014 | Corrective Pass | Edge | All parsed items invalid after one correction | Deterministic fixture | 200 partial; generated=[] | All inputs failed; exactly one correction; no persistence | none | DEP-08 | P1 | API-DOC-014 details |
| BTC-DOC-014-08 | API-DOC-014 | External/502 | Negative | Unusable/malformed provider output | Deterministic fixture | 502; no persistence | Safe error/requestId/redaction | none | DEP-08 | P1 | Conventions §9 |
| BTC-DOC-014-09 | API-DOC-014 | External/503 | Negative | Provider unavailable | Deterministic fixture | 503; no persistence | Safe error; no client retry assertion | none | DEP-08 | P1 | Conventions §9 |
| BTC-DOC-014-10 | API-DOC-014 | External/504 | Negative | 60-second total deadline | Deterministic fixture | 504; no persistence | Safe error; no provider/prompt leak | none | DEP-08 | P0 | RISK-08 |
| BTC-DOC-014-11 | API-DOC-014 + 011 | Workflow | Positive | Successful/partial preview never auto-saves | Pre/post DOC/Supabase snapshot | 200 preview; list unchanged | Count/content equality; SRS snapshot unchanged via DEP-10 | snapshot | DEP-02/07/10 | P0 | BR-02.5A |
| BTC-DOC-015-01 | API-DOC-015 | Existing Deck | Positive | Atomic save to existing owned Deck | Valid selected preview | 201 | GeneratedSaveResult; exact selected set; list all; no raw SRS | saved IDs | DEP-02/07 | P0 | FR-DOC-015 |
| BTC-DOC-015-02 | API-DOC-015 | New Deck | Positive | Atomic new Deck + cards | Unique newDeckName | 201 | One Deck; all cards; no orphan | new Deck/card IDs | DEP-02 | P0 | FR-DOC-015 |
| BTC-DOC-015-03 | API-DOC-015 | Partial Selection | Positive | Save valid selection from partial preview | Valid + failed preview | 201 | Only selected valid items saved | saved IDs | DEP-07 | P0 | AC-DOC-015-07 |
| BTC-DOC-015-04 | API-DOC-015 | Supplementary Reading | Edge | Save valid content without inapplicable Hiragana/Pinyin | Valid mapping | 201 | Absence does not block; no invented field | IDs | DEP-02 | P1 | AC-DOC-015-08 |
| BTC-DOC-015-05 | API-DOC-015 | Validation/Matrix | Negative | Reject invalid content/target selector | S015-001..008 | 400 each; zero write | Row/error; no card/orphan Deck | iteration | DEP-02/06 | P0 | FR-DOC-015 |
| BTC-DOC-015-06 | API-DOC-015 | Conflict/Atomicity | Negative | One duplicate rolls back batch | TD-DOC-DUP-01 | 409 DUPLICATE_RESOURCE | Exact code; no partial/orphan | snapshot | DEP-03 | P0 | API-DOC-015; RISK-10 |
| BTC-DOC-015-07 | API-DOC-015 | Not Found | Negative | Target Deck/Folder disappears | missing target | 404; zero write | Error; no orphan/card | none | DEP-02 | P0 | API-DOC-015 |
| BTC-DOC-015-08 | API-DOC-015 | RBAC | Negative | Target belongs to Learner B | TD-DOC-RBAC-01 | 403; zero write | Safe error; target unchanged | foreign ID | DEP-04 | P0 | AC-DOC-015-06 |
| BTC-DOC-015-09 | API-DOC-015 | Reconciliation | Edge | Reconcile ambiguous failure without automatic retry | Deterministic fixture | 503 `AMBIGUOUS_SAVE_RESULT`; reload resolves commit | Exact error; no blind retry; reload Deck/Folder | reconciliation flag | DEP-08 | P0 | API-DOC-015 details; ASSUMP-DOC-ERR-01 |

### COL-DOC-03 — Sharing Owner Workflow

| Basic TC ID | API ID / request | Group | Type | Objective/test condition | Precondition & data profile/matrix rows | Expected status/outcome | Required assertions | Variables in/out | Dependency/flow | Priority | Trace references |
|---|---|---|---|---|---|---|---|---|---|---|---|
| BTC-DOC-016-01 | API-DOC-016 | Share/Create | Positive | First enable | Owned disabled Deck | 201 created=true | ShareResult; `sharingStatus=Enabled`; exact local URL/token format; no content/SRS change | docShareToken | DEP-02 | P0 | FR-DOC-016; ASSUMP-DOC-SHARE-01; ASSUMP-DOC-SHARE-URL-01 |
| BTC-DOC-016-02 | API-DOC-016 | Idempotency | Edge | Enable already-enabled Deck | Active share | 200 created=false; same URL | Exact URL/token equality; no new write | same token | DEP-12 | P0 | API-DOC-016 |
| BTC-DOC-016-03 | API-DOC-016 | Not Found | Negative | Enable missing Deck | missing ID | 404; no token | Error; no URL/token | none | DEP-01 | P1 | AC-DOC-016-03 |
| BTC-DOC-016-04 | API-DOC-016 | Concurrency | Edge | Concurrent enable loser rereads link | Approved concurrent harness | one 201 + one 200; same link | At most one active; no 409 | one token | DEP-02/08 | P0 | API-DOC-016 |
| BTC-DOC-017-01 | API-DOC-017 | Revoke | Positive | Disable active share | Active token | 200; `sharingStatus=Disabled` | Response; content/SRS unchanged | old token | DEP-12 | P0 | FR-DOC-018; ASSUMP-DOC-SHARE-01 |
| BTC-DOC-017-02 | API-DOC-017 | No-op | Edge | Disable already-disabled Deck | No active share | 200 no-op | No token/write; remains disabled | none | DEP-02 | P1 | AC-DOC-018-02 |
| BTC-DOC-017-03 | API-DOC-017 | Not Found | Negative | Disable missing Deck | missing ID | 404 | Error; no state | none | DEP-01 | P1 | API-DOC-017 |
| BTC-DOC-016-05 | API-DOC-016 | Token Rotation | Edge | Re-enable creates new token | Old token revoked | 201; new != old | New active; old remains inactive | new token | DEP-12 | P0 | FR-DOC-018; RISK-02 |

### COL-DOC-04 — Public Shared Deck

| Basic TC ID | API ID / request | Group | Type | Objective/test condition | Precondition & data profile/matrix rows | Expected status/outcome | Required assertions | Variables in/out | Dependency/flow | Priority | Trace references |
|---|---|---|---|---|---|---|---|---|---|---|---|
| BTC-DOC-018-01 | API-DOC-018 | Public/Security | Positive | View active populated share anonymously | TD-DOC-PUBLIC-01 | 200 | Exact PublicDeck allow-list; no IDs/PII/SRS/actions | token in | DEP-12 | P0 | FR-DOC-017; RISK-03 |
| BTC-DOC-018-02 | API-DOC-018 | Public/Empty | Edge | View empty shared Deck | Empty active share | 200 count=0/cards=[] | Exact projection; no error | token | DEP-12 | P1 | AC-DOC-017-05 |
| BTC-DOC-018-03 | API-DOC-018 | Token/Matrix | Negative | Reject malformed/unknown tokens | P018-001..005 | 404 each; no data | Row/error; never log token | local token | DEP-06 | P0 | API-DOC-018 |
| BTC-DOC-018-04 | API-DOC-018 | Revocation | Negative | Disabled old token | Successful disable | 404; no content | Error; fresh request/no cache assumption | old token | DEP-12 | P0 | FR-DOC-018 |
| BTC-DOC-018-05 | API-DOC-018 | Deleted Deck | Negative | Link after owner deletes Deck | API-DOC-009 setup delete | 404; no content | Error; remains invalid | deleted token | DEP-11 | P0 | AC-DOC-017-04 |
| BTC-DOC-018-06 | API-DOC-018 | Read-only | Positive | Public reads do not mutate state | Before/after snapshot | 200; snapshots equal | Repeated read; owner/share/SRS observable state equal | snapshot hash | DEP-12/10 | P1 | BR-02.6/8 |

### COL-DOC-05 — Export

| Basic TC ID | API ID / request | Group | Type | Objective/test condition | Precondition & data profile/matrix rows | Expected status/outcome | Required assertions | Variables in/out | Dependency/flow | Priority | Trace references |
|---|---|---|---|---|---|---|---|---|---|---|---|
| BTC-DOC-019-01 | API-DOC-019 | Binary/Privacy | Positive | Correct read-only export | TD-DOC-EXPORT-01; snapshot | 200 XLSX | Non-empty binary; exact MIME/disposition; UTC+7 filename; manual columns/order/No/multiline/privacy; no mutation | evidence metadata | DEP-02/10 | P0 | FR-DOC-019; AMB-02; ASSUMP-DOC-EXPORT-01 |
| BTC-DOC-019-02 | API-DOC-019 | Empty | Negative | Reject empty Deck | docEmptyDeckId | 400 JSON error | No binary/partial file/state | none | DEP-02 | P0 | API-DOC-019 |
| BTC-DOC-019-03 | API-DOC-019 | Not Found | Negative | Reject missing Deck | missing ID | 404 JSON error | No file/state | none | DEP-01 | P1 | API-DOC-019 |
| BTC-DOC-019-04 | API-DOC-019 | Fault/Recovery | Negative | 500 cleans partial file and retry works | Deterministic fixture | 500 JSON; no mutation | Safe error/requestId; no path/stack/partial; retry after reset | fault flag | DEP-09 | P0 | AMB-04; RISK-06 |

### COL-DOC-06 — Authorization & RBAC

| Basic TC ID | API ID / request | Group | Type | Objective/test condition | Precondition & data profile/matrix rows | Expected status/outcome | Required assertions | Variables in/out | Dependency/flow | Priority | Trace references |
|---|---|---|---|---|---|---|---|---|---|---|---|
| BTC-RBAC-010-01 | API-DOC-010 | RBAC/BOLA | Negative | B cannot create in A Deck | TD-DOC-RBAC-01 | 403; no card | Error; owner count unchanged | B token/A ID | DEP-04 | P0 | RISK-01 |
| BTC-RBAC-011-01 | API-DOC-011 | RBAC/BOLA | Negative | B cannot list A Deck | Foreign actor/resource | 403; no content | No owner/resource leak | same | DEP-04 | P0 | RISK-01 |
| BTC-RBAC-012-01 | API-DOC-012 | RBAC/BOLA | Negative | B cannot edit A card | Foreign card | 403; unchanged | Owner reread equal | same | DEP-04 | P0 | RISK-01 |
| BTC-RBAC-013-01 | API-DOC-013 | RBAC/BOLA | Negative | B cannot delete A card | Foreign card | 403; remains | Owner reread exists | same | DEP-04 | P0 | RISK-01 |
| BTC-RBAC-015-01 | API-DOC-015 | RBAC/BOLA | Negative | A cannot save to B target | Foreign Deck/Folder | 403; zero write | Atomic no-change; no details leak | same | DEP-04 | P0 | AC-DOC-015-06 |
| BTC-RBAC-016-01 | API-DOC-016 | RBAC/BOLA | Negative | B cannot enable A share | Disabled A Deck | 403; stays disabled | No URL/token | same | DEP-04 | P0 | AC-DOC-016-04 |
| BTC-RBAC-017-01 | API-DOC-017 | RBAC/BOLA | Negative | B cannot disable A share | Active A share | 403; stays active | A token remains usable | same | DEP-04/08 | P0 | AC-DOC-018-04 |
| BTC-RBAC-019-01 | API-DOC-019 | RBAC/BOLA | Negative | B cannot export A Deck | Foreign non-empty Deck | 403 JSON; no XLSX | No content/binary leak | same | DEP-04 | P0 | RISK-01/06 |
| BTC-AUTH-DOC-01 | APIs 010–017,019 request set | Auth/Missing | Negative | Every protected endpoint rejects no Authorization | Isolated/resettable copies | 401 each; no state/data | Per-request status/error; export JSON error | no token | DEP-01 | P0 | Conventions §4 |
| BTC-AUTH-DOC-02 | APIs 010–017,019 request set | Auth/Invalid | Negative | Every protected endpoint rejects fictitious invalid/expired token | Same set | 401 each; no state/data | Redacted safe errors | invalid local token | DEP-01 | P0 | Conventions §4 |
| BTC-ROLE-DOC-01 | APIs 010–017,019 request set | RBAC/Admin | Negative | Admin cannot interact with Learner DOC | Admin token + A fixtures | 403 each; no state/data | No Learner content | admin token | DEP-05 | P0 | Permission matrix |
| BTC-STATUS-DOC-01 | APIs 010–017,019 request set | RBAC/Deactivated | Negative | Deactivated Learner cannot continue DOC actions | Current deactivated token | 403 each; no state/data | Safe errors/no mutation | status token | DEP-05 | P0 | Requirement §5.1 |

### COL-DOC-07 — E2E Regression

| Basic TC ID | API ID / request | Group | Type | Objective/test condition | Precondition & data profile/matrix rows | Expected status/outcome | Required assertions | Variables in/out | Dependency/flow | Priority | Trace references |
|---|---|---|---|---|---|---|---|---|---|---|---|
| BTC-E2E-DOC-01 | APIs 010–019 | Workflow/E2E | Positive | Setup → CRUD → preview/save → share/public/revoke/re-enable → export → delete/verify → cleanup | Non-production; all hard gates; unique docRunId | Component statuses; finite completion | Component projection/atomicity/privacy/non-mutation + final cleanup | scoped workflow vars | DEP-01/02/03/07/12 | P0 | FR-DOC-009..019 |

## 6. Script Specification Groups

| Script ID | Scope | Trigger | Objective/logic | Inputs | Outputs/side effects | Guards/failure behavior | Applicable requests/cases | Source trace |
|---|---|---|---|---|---|---|---|---|
| SCR-COM-PRE-01 | Collection pre-request | Protected collection requests | Validate baseUrl/environmentName/docRunId; never fabricate tokens | baseUrl, environmentName | docRunId if absent | Stop on missing baseUrl; block production fault/mutation profiles | All protected collections | Conventions §§3,10 |
| SCR-AUTH-PRE-01 | Folder/request pre-request | Owner/foreign/Admin/status folders | Select declared token without overwriting deliberate missing/invalid auth; remove auth for public | role selector | Request Authorization | Fail missing required secret; never log token | COL-01/02/03/05/06/07 | Conventions §4 |
| SCR-SETUP-TEST-01 | Setup provider request tests | Successful create/get provider request | Validate namespaced fixture projection and store only an allow-listed ID/name pair | `docRunId`, request `storeAs`/`namespaceField` | Collection fixture ID plus companion name | Fail before handoff when response is not namespaced or store target is not allow-listed | COL-DOC-00 setup | DEP-02/03/04 |
| SCR-CLEANUP-GUARD-01 | Cleanup request pre-request/tests | Before and after provider DELETE | Permit deletion only for an allow-listed ID whose stored companion name contains current `docRunId`; unset that fixture state only after confirmed 2xx DeleteResult | `docRunId`, request `cleanupIdVariable` | Guarded DELETE; variables unset on success | Stop before send on missing/mismatched namespace, target, actor, or ID | COL-DOC-00 cleanup | TBD-11; DEP-02/04/12 |
| SCR-UNIQUE-PRE-01 | Request pre-request | Create/write cases | Generate traceable term/name from docRunId/request key | docRunId | Local unique data | Fail non-namespaced mutation data | 010/012/015 | Test-data rule |
| SCR-MATRIX-PRE-01 | Request pre-request | Matrix iteration | Validate common TSV/CSV schema and matrix/request identity; resolve baseline JSON; safely map root/nested fieldPath plus literal/omit/null/empty/whitespace/generated boundary modes | iteration row | Mutated current request body or local path token only | Stop on schema/identity/JSON/generator error; never mutate iteration data or concatenate unsafe JSON | Matrix BTCs | Data-driven reference |
| SCR-MATRIX-TEST-01 | Request tests | Matrix response | Assert exact row status and mandatory exact error code for negative rows; report rowId/basicTcId/sourceRef/requestId | row expectations | Evidence only | Missing code/parsing/missing-field failures fail; continue valid rows | Matrix BTCs | §§3.3,5; ASSUMP-DOC-ERR-01 |
| SCR-JSON-ENV-TEST-01 | Collection tests | JSON responses | Validate success/error envelope, requestId, camelCase/redaction without fixed status | Response type | None | Explicitly skip binary success only; JSON parse errors fail | JSON requests | Conventions §§6,7,10 |
| SCR-FLASHCARD-TEST-01 | Request tests | 010/012 success | Exact Flashcard projection/content/types, raw-SRS omission, extract documented IDs | Submitted content | docFlashcardId/saved IDs | Never assert raw SRS JSON; require DEP-10 read-only Supabase before/after evidence where state preservation is in scope | Create/edit BTCs | Contract §3.1 |
| SCR-LIST-TEST-01 | Request tests | 011 success | Assert array/exact item projection/empty/populated/deleted conditions | Expected IDs | Sanitized snapshot/hash | Duplicate/unexpected/leaked fields fail | List/verify BTCs | API-DOC-011 |
| SCR-DELETE-TEST-01 | Request tests | 013 success | Assert DeleteResult and retain deleted ID | docFlashcardId | docDeletedFlashcardId | Skip dependent verify if delete fails | 013-01/02 | Contract §3.1 |
| SCR-AI-PREVIEW-TEST-01 | Request tests | 014 200 | Assert AiPreviewResult, status rules, unique input accounting, complete items, safe failed items | Input profile | Local preview only | Malformed provider output fails; no collection persistence except selected handoff | 014-01..07,11 | API-DOC-014 |
| SCR-AI-SAVE-TEST-01 | Request tests | 015 | Assert GeneratedSaveResult, selected set, atomicity/raw-SRS omission; extract saved IDs | Selection/target | Deck/card IDs | Reconcile ambiguity; never auto-retry write | 015-* | API-DOC-015 |
| SCR-SHARE-TEST-01 | Request tests | 016/017 | Assert exact `Enabled`/`Disabled`, `created`, implementation URL behavior and token rotation/idempotency; extract/compare 64-lower-hex token safely | Deck/token state | Secret token variables | Never log token; block dependent public flow if extraction fails | 016/017-* | API-DOC-016/017; ASSUMP-DOC-SHARE-01; ASSUMP-DOC-SHARE-URL-01 |
| SCR-PUBLIC-TEST-01 | Request tests | 018 200 | Exact PublicDeck allow-list and zero private/internal fields | Expected public fixture | None | No Authorization; schema mismatch fails | 018-01/02/06 | Contract §3.1 |
| SCR-ERROR-TEST-01 | Request tests | Non-matrix errors | Exact approved status/code, global error, requestId, redaction and no-state-change | Expected status/code | requestId evidence | Missing expected code fails; no message exact match | Negative BTCs | Conventions §§7,8,10; ASSUMP-DOC-ERR-01 |
| SCR-EXPORT-TEST-01 | Request tests | 019 | Branch binary success vs JSON error; exact status/MIME/disposition/filename; external workbook checklist | Deck/date/outcome | Safe metadata | Never JSON-parse success or claim native cell validation | 019-* | API-DOC-019; ASSUMP-DOC-EXPORT-01 |
| SCR-WORKFLOW-CTRL-01 | Runner | Stateful profiles | Finite setup→action→verify→cleanup; fail-fast hard gates | DEP flags/request names | Next/stop decision | No loops/blind retry; evidence before cleanup | Happy/share/E2E | API-DOC-015; §7 |

## 7. Dependency Map & Run Profiles

### 7.1 Key Setup Gates

> **Report view:** This concise table keeps the prerequisite, affected scope, verification, and handling required for execution. Detailed variable-level implementation belongs to Sections 3.1, 4, and 6.

| DEP ID | Type | Required condition / verification | Affected scope | Handling if unmet / safety |
|---|---|---|---|---|
| DEP-01 | Hard | Approved `baseUrl` and required tokens are present; never print secrets. | Protected BTCs | Stop; manually provide approved secrets. |
| DEP-02 | Hard | Owned Folder plus populated and empty Decks are created through setup API-DOC-001/005; verify with owner GET/list. | CRUD, AI save, sharing, export | Use pre-provisioned namespaced fixtures if needed; delete only `docRunId` fixtures. |
| DEP-03 | Hard/Soft | An owned Flashcard ID and baseline are created/recorded by API-DOC-010. | Edit, delete, list verification | Use a dedicated card; delete it and unset the ID afterward. |
| DEP-04 | Isolation | Learner B owns the foreign Folder/Deck/Flashcard fixture. | Cross-owner/RBAC cases | Verify ownership as B; cleanup only as B. |
| DEP-05 | Isolation | Approved Admin and deactivated Learner actors are available. | Role and account-status denial | Verify actor status out of band; never change roles in the suite. |
| DEP-06 | Hard bulk | Matching TSV has been exported to UTF-8 CSV; CSV SHA-256, exact header, row count, unique row IDs, matrixId/requestKey and JSON/generator fields are validated. | Matrix BTCs | Stop only the affected bulk profile; never send a partially parsed row. |
| DEP-07 | External | Groq normal availability is confirmed without exposing a key. | AI positive/partial cases | Use an approved stub or mark AI cases `SKIP` if unavailable. |
| DEP-08 | External/Isolation | Approved non-production AI/concurrency fixtures provide deterministic faults, correction, ambiguity, or concurrent requests. | AI fault and sharing special cases | Reset fixture after evidence; never run these cases on Production. |
| DEP-09 | External/Isolation | Approved deterministic export-failure fixture is available. | BTC-DOC-019-04 | Reset after evidence; mark the fault case `SKIP` when absent. |
| DEP-10 | Soft verification | Read-only Supabase snapshot compares the same Flashcard's SRS fields before/after mutation. | SRS and non-mutation cases | Record sanitized equality evidence; never write through verification. |
| DEP-11 | Hard workflow | Share a disposable Deck, then delete it through API-DOC-009 and retain the old token. | BTC-DOC-018-05 | Verify `DeleteResult` first; do not repeat delete. |
| DEP-12 | Hard workflow | A normal owner share step produced a verified active 64-lowercase-hex token; idempotent/revoke/rotation/public steps consume the same handoff without printing it. | Sharing/public/E2E cases | Stop dependent requests when enable/token extraction fails; disable the owned share and unset both token variables during cleanup. |

### 7.2 Run Profiles

> **Report view:** Evidence requirements are defined by the applicable scripts in Section 6 and the execution records; this table focuses on how each profile is run safely.

| Run profile | Collection/request order | Preconditions / handling | Isolation/cleanup |
|---|---|---|---|
| RP-HAPPY-CRUD | COL-01 Setup → CRUD → delete → verify → cleanup | DEP-01/02/03; fail fast when a dependency is unmet. | No bulk/RBAC; cleanup owned data only. |
| RP-BULK-010 | Only Bulk Create + C010-001..015 | DEP-01/02/06; continue valid rows, stop on auth/schema failure. | Invalid rows must be non-mutating. |
| RP-BULK-012 | Only Bulk Edit + E012-001..013 | DEP-01/03/06; continue rows and verify/reset the baseline after each row. | Use a dedicated card. |
| RP-AI-HAPPY | COL-02 positive/parsing/partial/save/verify/cleanup | DEP-01/02/07; fail fast at setup and mark AI cases `SKIP` if unavailable. | Excludes fault and bulk profiles. |
| RP-BULK-014 | Only AI validation + A014-001..011 | DEP-01/06; continue rows; the provider must not run. | No mutation. |
| RP-BULK-015 | Only AI-save validation + S015-001..008 | DEP-01/02/06; continue rows, verify zero writes, and stop on corruption. | Dedicated target and reset. |
| RP-AI-FAULTS | Only correction/502/503/504/reconciliation | DEP-01/08; run independently and `SKIP` without a fixture; never Production. | Reset the fault fixture after evidence. |
| RP-SHARE | COL-03 enable→idempotent→disable→revoked→re-enable→cleanup; concurrent subfolder is separate | DEP-01/02/12; only the concurrent subfolder also requires DEP-08; fail fast if first enable or token extraction fails. | Redact and unset tokens. |
| RP-PUBLIC | COL-04 populated/empty/revoked/deleted | DEP-12/11; fail fast at owner setup; public reads are independent. | No Authorization header. |
| RP-BULK-018 | Only token matrix P018-001..005 | DEP-06; continue rows and stop on schema failure. | Never log tokens. |
| RP-EXPORT | COL-05 success→empty/missing→post-state→cleanup | DEP-01/02 plus manual workbook checklist; independent negatives continue. | Retain export evidence. |
| RP-EXPORT-FAULT | Deterministic 500→reset→retry | DEP-09; `SKIP` without a fixture; never Production. | Preserve evidence before reset. |
| RP-SECURITY-RBAC | COL-06 isolated cross-owner→auth→role/status→cleanup | DEP-01/04/05; continue independent cases and stop on invalid actor ownership. | Do not reuse happy-path mutable data. |
| RP-E2E-DOC | COL-07 finite lifecycle | DEP-01/02/03/07/12; fail fast; excludes bulk, fault, concurrency, and RBAC. | One `docRunId`; cleanup at completion. |

## 8. Traceability Handoff

### 8.1 Coverage Traceability

| Basic TC ID(s) | API ID | Requirement/AC/CR | API Contract section | Convention section | Script IDs | DEP IDs | Downstream case/script ID |
|---|---|---|---|---|---|---|---|
| BTC-DOC-010-01..06 | 010 | FR-DOC-010; BR-02.2..5; CR-DOC-001 | §3.1 Flashcard; §5.2 010 | §§4–8,10 | COM/AUTH/UNIQUE/MATRIX/FLASHCARD/ERROR | 01/02/03/06/10 | Assign downstream |
| BTC-DOC-011-01..03 | 011 | FR-DOC-009 | §5.2 011 | §§4,6–8,10 | LIST/ERROR | 01/02/03 | Assign downstream |
| BTC-DOC-012-01..06 | 012 | FR-DOC-011; BR-02.4 | §3.1 Flashcard; §5.2 012 | §§4–8,10 | MATRIX/FLASHCARD/ERROR | 01/03/04/06/10 | Assign downstream |
| BTC-DOC-013-01..03 | 013/011 | FR-DOC-012; BR-02.5 | §3.1 DeleteResult; §5.2 013 | §§4,6–8 | DELETE/LIST/ERROR | 03/10 | Assign downstream |
| BTC-DOC-014-01..11 | 014 | FR-DOC-013/014; BR-02.5A/B; CR-DOC-001 | §3.1 AiPreviewResult; §5.2 014 | §§5–10 | MATRIX/AI-PREVIEW/ERROR | 01/06/07/08/10 | Assign downstream |
| BTC-DOC-015-01..09 | 015 | FR-DOC-015; BR-02.5C; AC-015-06..08 | §3.1 GeneratedSaveResult; §5.2 015 | §§4–10 | MATRIX/AI-SAVE/ERROR | 01/02/03/04/06/08/10 | Assign downstream |
| BTC-DOC-016-01..05 | 016 | FR-DOC-016/018; BR-02.6/7 | §3.1 ShareResult; §5.2 016 | §§4,6–8,10 | SHARE/ERROR | 01/02/08/12 | Assign downstream |
| BTC-DOC-017-01..03 | 017 | FR-DOC-018 | §5.2 017 | §§4,6–8 | SHARE/ERROR | 01/02/12 | Assign downstream |
| BTC-DOC-018-01..06 | 018 | FR-DOC-017/018; AMB-05; RISK-02/03 | §3.1 PublicDeck; §5.2 018 | §§6–8,10 | MATRIX/PUBLIC/ERROR | 06/10/11/12 | Assign downstream |
| BTC-DOC-019-01..04 | 019 | FR-DOC-019; BR-02.8; AMB-02/04 | §5.2 019 | §§4,7,8,10 | EXPORT/ERROR | 01/02/09/10 | Assign downstream |
| BTC-RBAC-* | 010–017,019 | Permission matrix; RISK-01/06 | Endpoint headings | §§4,7,8,10 | AUTH/ERROR | 04/08 | Assign downstream |
| BTC-AUTH-DOC-01/02; BTC-ROLE-DOC-01; BTC-STATUS-DOC-01 | 010–017,019 | Permission matrix | Endpoint headings | §§4,7,8,10 | AUTH/ERROR | 01/05 | Expand one detailed TC per endpoint |
| BTC-E2E-DOC-01 | 010–019 | FR-DOC-009..019 | DOC §5.2 | §§3–10 | Component scripts + WORKFLOW | 01/02/03/07/12 | Assign downstream |

### 8.2 Handoff Manifest for Postman implementation

| Handoff item | Plan section | Downstream completion requirement |
|---|---|---|
| Collection topology | §4 | One physical collection with concrete top-level folders/request keys; preserve public/auth/fault/bulk isolation and shared state handoffs |
| Basic TC | §5 | Expand every BTC; auth/role/status sets become one detailed TC per protected endpoint; apply approved assumptions and retain only unresolved TBDs |
| Script specification | §6 | Complete evidence-based Postman JS with placement/input/output/failure behavior |
| Dependency/run profile | §7 | Preserve hard/soft/isolation/external gates and finite workflow; no blind write retry |
| Bulk matrices | §§3.3,5–7 | Exact schemas/ranges; missing CSV must fail clearly and profiles remain blocked |
| Export workbook | ASSUMP-DOC-EXPORT-01 / TBD-06 resolved | Assert exact native headers/filename; retain external workbook inspection evidence |
| SRS/downstream | DEP-10 / TBD-07 resolved | Never assert raw SRS in DOC response; attach read-only Supabase before/after equality evidence where applicable |
| Traceability/TBD | §§1,8 | Preserve source/BTC/Matrix/DEP/SCR IDs and unresolved questions |

## 9. Readiness Checklist

- [x] All 10 selected APIs have evidence-based positive/negative/edge coverage or an explicit blocked gap.
- [x] All 69 BTCs have type, condition, expected outcome, assertions, priority, dependencies and trace.
- [x] Owner, Public, RBAC, external-fault, bulk, export and E2E lifecycles are isolated.
- [x] Variables define secrecy, scope, producer, consumer and cleanup; no secret/PII value is recorded.
- [x] Global assertions do not impose one status/envelope on JSON success, JSON error and binary export.
- [x] Workflows are finite and prohibit ambiguous write retry.
- [x] TBD-01 local backend and Supabase DEV execution target selected; production is outside this run scope.
- [x] TBD-02 exact error-code assumptions approved from implementation.
- [x] TBD-03 exact `Enabled`/`Disabled` values approved.
- [x] TBD-04 extra `deckId` rejection approved as `400 VALIDATION_ERROR`.
- [x] TBD-05/06 exact headers and manual workbook inspection approved.
- [x] TBD-07 SRS verification approved through read-only Supabase snapshots.
- [ ] TBD-08/09 deterministic AI/export fixtures available.
- [x] TBD-10 five UTF-8 TSV source matrices with exact row IDs created; CSV export/hash remains an execution gate under DEP-06.
- [x] TBD-11 cleanup authorization confirmed for the owner-controlled Supabase development project.

Plan v2.2 sẵn sàng cho local happy/negative/RBAC/export-manual runs and bulk-data authoring. Fault profiles TBD-08/09 remain blocked by fixtures; bulk execution remains blocked only until the supplied TSV files are exported to UTF-8 CSV and their hashes are recorded.
