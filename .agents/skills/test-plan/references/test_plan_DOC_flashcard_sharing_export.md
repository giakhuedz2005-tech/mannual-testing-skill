# TEST PLAN

## Language Learning Hub — DOC Module: Flashcard CRUD, AI Generation, Sharing & Export

> **Project:** Language Learning Hub (LLH) | **Module:** DOC — Document Management
> **Repository (testing):** [LLH-Mannual-API-testing-project](https://github.com/giakhuedz2005-tech/LLH-Mannual-API-testing-project)
> **Repository (web):** [Language-learning-hub-for-quizz](https://github.com/giakhuedz2005-tech/Language-learning-hub-for-quizz)
> **Application URL:** https://language-learning-hub-for-quizz-fro.vercel.app
> **Requirement Basis:** BRD v1.9 (BR-02), FRD-DOC v0.5 (FR-DOC-009–019), Phase 2 CRs (CR-DOC-001, CR-DOC-002, CR-CROSS-001), Production Hotfixes (DEF-AI-01–04, DEF-UI-01–02, DEF-SAVE-01)

---

## Table of Contents

- [1. Analyze the Product](#1-analyze-the-product)
- [2. Define the Test Approach](#2-define-the-test-approach)
  - [2.1 Approach Summary](#21-approach-summary)
  - [2.2 Main Test Areas](#22-main-test-areas)
  - [2.3 Test Design Techniques](#23-test-design-techniques)
  - [2.4 Test Priority](#24-test-priority)
  - [2.5 Test Data Approach](#25-test-data-approach)
- [3. Define the Test Objectives](#3-define-the-test-objectives)
- [4. Define Test Criteria](#4-define-test-criteria)
  - [4.1 Entry Criteria](#41-entry-criteria)
  - [4.2 Test Result Criteria](#42-test-result-criteria)
  - [4.3 Exit Criteria](#43-exit-criteria)
- [5. Resource Planning](#5-resource-planning)
  - [5.1 Tools](#51-tools)
  - [5.3 Required Test Assets](#53-required-test-assets)
- [6. Plan the Test Environment](#6-plan-the-test-environment)
  - [6.1 Test Environment](#61-test-environment)
  - [6.3 Environment Limitations](#63-environment-limitations)
- [7. Schedule and Estimation](#7-schedule-and-estimation)
  - [7.1 Estimation Method](#71-estimation-method)
  - [7.2 Estimated Schedule](#72-estimated-schedule)
- [8. Determine Test Deliverables](#8-determine-test-deliverables)

---

## 1. Analyze the Product

### Product and Business Purpose

Language Learning Hub (LLH) is a web application that supports learners in building and managing vocabulary study material. The DOC module implements **BR-02 — Managing Document**, enabling a Learner to organize vocabulary in the hierarchy **Folder > Deck > Flashcard**, accelerate content preparation through AI-assisted generation, safely expose a Deck for anonymous public read access via a shareable link, and export Deck contents to an offline Excel file.

### Target Actors

| Actor | Description |
|---|---|
| **Learner (owner)** | Authenticated, Active account. Has full CRUD rights over their own Flashcards, Decks, and Folders. |
| **Learner (non-owner)** | Authenticated, Active account. May not access or mutate another Learner's resources. |
| **Public User** | Unauthenticated visitor. View-only access to an active shared Deck URL; no other actions permitted. |
| **AI Service (Groq)** | External provider invoked by the system to generate temporary Flashcard preview content. |
| **System** | Enforces session validity, Active account status, ownership, public-link state, and downstream data consistency. |

### Test Basis

| Document | Version / Status |
|---|---|
| Requirement Analysis (primary) | `requirements_spec_DOC_flashcard-sharing-export.md` — finalized, all Ambiguities resolved |
| BRD | v1.9 (BR-02) |
| FRD-DOC | v0.5 (FR-DOC-009–019) |
| Phase 2 Change Requests | CR-DOC-001, CR-DOC-002, CR-CROSS-001 |
| Production Hotfixes | DEF-AI-01–04, DEF-UI-01–02, DEF-SAVE-01 |
| API Contract | `API-CONTRACT.md` — AI preview endpoint, share/export endpoints |
| Data Dictionary | `DATA-DICTIONARY.md` — physical table definitions and normalization function |

### In Scope

- View Flashcards in an owned Deck, including empty-list state.
- Manually create, edit, and permanently delete an owned Flashcard (FR-DOC-009 to FR-DOC-012).
- Validate Flashcard content (required fields, character limits, language placement, normalized duplicate term, immutable Deck association).
- Verify initial SRS state on save and SRS removal on delete.
- Submit vocabulary list to AI, validate parsed/deduped input, and verify temporary AI preview generation (FR-DOC-013 to FR-DOC-014).
- Review, edit, and save selected AI-generated Flashcards to an existing or new Deck (FR-DOC-015).
- Enable/disable public sharing link for an owned Deck; verify token creation, revocation, and reuse prevention (FR-DOC-016 to FR-DOC-018).
- View an active shared Deck as a Public User; verify data minimization and read-only enforcement (FR-DOC-017).
- Export a non-empty owned Deck to `.xlsx`; verify file content, column order, filename format (UTC+7), and non-mutation of application data (FR-DOC-019).
- Cross-module impact checks: verify that Flashcard CRUD, AI save, sharing, and export do not advance `profiles.last_learning_activity_at` or create notification rows.
- RBAC and ownership enforcement at both UI and API layers.
- API-level validation for Flashcard CRUD, AI Preview + Save, Sharing, and Export endpoints.
- Database-level data verification for SRS initialization, deletion cleanup, and sharing state.

### Out of Scope

- Folder and Deck CRUD (FR-DOC-001 to FR-DOC-008).
- Moving Flashcards between Decks.
- Editing, importing, copying, or learning from a shared public Deck.
- Non-functional testing (UI, Usability , Compatibility, Performance, Security)
- AI content accuracy guarantees; internal token algorithm and database schema design.
- Persistent AI metadata; AI-generated content exists only until saved or discarded.

### Dependencies and Known Risks\

| Dependency / Risk | Planning Impact |
|---|---|
| Groq AI service availability | AI generation tests depend on a live external service; timeouts (60 s) and partial failures must be tested; service outages may block AI test cases. |
| Production environment (shared, live data) | Requires strict test-data isolation; test items must use traceable naming to avoid polluting real learner data. |
| Chinese legacy data (CR-DOC-001) | Old-format Chinese Flashcards are not auto-migrated; duplicate 409 scenarios require specific old-format fixtures. |
| SRS cross-module dependency | Downstream impact on LEARN/DASH modules must be verified via database query; no automated LEARN module coverage is in scope. |
| Browser caching after sharing revocation (AMB-01 resolved) | Browser-back behavior after revocation is an accepted known risk; tests verify only fresh-request behavior. |

---

## 2. Define the Test Approach

### 2.1 Approach Summary

| Dimension | Applied Approach |
|---|---|
| **Test level** | System test (end-to-end via UI and API on Production) |
| **Test types** | Functional testing (primary); cross-module integration checks; API contract testing; database data verification |
| **Execution mode** | Manual |
| **Test-case perspective** | Black-box (requirements-based); supplemented by error-guessing for edge cases |
| **API testing** | Postman: verify status codes, response schema, error messages, and RBAC at API layer for all in-scope endpoints |
| **Database verification** | Direct DB query to confirm SRS initialization, deletion cleanup, sharing state, and absence of activity/notification records |
| **Cross-module checks** | Verify that DOC CRUD and AI save do not advance `profiles.last_learning_activity_at` or create notification rows |
| **Access Control / RBAC** | Verify ownership enforcement and public-data minimization at both UI and API levels for all actors |
| **Automation** | Not in scope for this test cycle |
| **Exploratory testing** | Supplementary; used for AI generation edge cases and sharing/export corner cases after scripted coverage |

### 2.2 Main Test Areas

| # | Test Area | Requirement Reference |
|---|---|---|
| TA-01 | **Flashcard View** — owned list, empty-list state, cross-owner denial, missing Deck | FR-DOC-009 |
| TA-02 | **Flashcard Create** — required fields, trim/limit, language placement, normalized duplicate, SRS init, RBAC | FR-DOC-010, BR-02.2, BR-02.3, BR-02.4, BR-02.5 |
| TA-03 | **Flashcard Edit** — content update, immutable Deck association, learning-state preservation, validation rollback, RBAC | FR-DOC-011, BR-02.4 |
| TA-04 | **Flashcard Delete** — permanent deletion without confirmation, SRS removal, downstream exclusion (LEARN/DASH/share/export) | FR-DOC-012, BR-02.5 |
| TA-05 | **AI Input Validation** — parsing (comma/newline/mixed), trim, dedup, 50-item/3,000-char limits, missing/unsupported `targetLanguage` | FR-DOC-013, BR-02.5A |
| TA-06 | **AI Preview Generation** — field validation, language mapping, Sino-Vietnamese rules, `failedItems` reporting, timeout/partial/failed outcomes | FR-DOC-014, BR-02.5A, BR-02.5B |
| TA-07 | **AI Preview Review & Save** — editable preview, duplicate pre-check on UI, save to existing/new Deck, SRS init, discard boundary, cross-module non-impact | FR-DOC-015, BR-02.5B, BR-02.5C |
| TA-08 | **Sharing Enable** — token/URL activation, idempotency (re-enable shows same URL), ownership enforcement | FR-DOC-016, BR-02.6 |
| TA-09 | **Shared Deck Public View** — active-token validation, data minimization (`deckName`, `term`, `meaning`, `exampleSentence` only), view-only, unavailable state for invalid/disabled/deleted link | FR-DOC-017, AMB-05 resolved |
| TA-10 | **Sharing Disable & Revocation** — immediate revocation, fresh-request unavailability, new token on re-enable, old-token invalidation | FR-DOC-018, BR-02.7 |
| TA-11 | **Export** — `.xlsx` content, column order, filename UTC+7, multiline preservation, empty/unauthorized denial, non-mutation of application data, export failure handling | FR-DOC-019, BR-02.8, AMB-02/AMB-04 resolved |
| TA-12 | **RBAC & Session** — ownership enforcement for all actions at UI and API layer; deactivated Learner session; Admin/non-owner/Public User denial | RBAC matrix (Section 5.1 of requirement analysis) |
| TA-13 | **Cross-module Downstream Checks** — Flashcard CRUD and AI save must not advance `last_learning_activity_at` or create notification rows | CR-CROSS-001, Section 5.2 of requirement analysis |

### 2.3 Test Design Techniques

| Technique | Applied To |
|---|---|
| **Equivalence Partitioning** | Field validation (valid/invalid/empty/over-limit values for `term`, `meaning`, `exampleSentence`); `targetLanguage` (Japanese / Chinese / missing / unsupported) |
| **Boundary Value Analysis** | `term` max 500 chars, `meaning` max 1,000 chars, `exampleSentence` max 500 chars; AI input max 50 items and 3,000 characters |
| **Decision Table Testing** | Language placement rules (Japanese Kanji → Sino-Vietnamese required; Japanese Hiragana/Katakana → Sino-Vietnamese null; Chinese Hanzi → Sino-Vietnamese required) |
| **State-Transition Testing** | Flashcard lifecycle (Draft → SavedNew → Updated → Deleted); Sharing-link lifecycle (Disabled ↔ Active → Deleted); AI generation lifecycle (InputDraft → Pending → PreviewCompleted/PreviewPartial/Failed → Saved/Discarded) |
| **Error Guessing** | Concurrent duplicate-term submissions; rapid re-enable/disable of sharing; export of an empty Deck; Groq timeout simulation; legacy Chinese term editing to a conflicting new-format term (CR-DOC-001) |
| **Exploratory Testing** | AI edge cases (mixed-language input, malformed vocabulary, Chinese legacy-format coexistence); public-page browser Back behavior after revocation (accepted per AMB-01) |
| **Pairwise Testing** | AI input format combinations (comma-separated / newline / mixed) × language selection (Japanese / Chinese) |

### 2.4 Test Priority

| Impact | Meaning for this Project |
|---|---|
| **High** | Feature is a core user journey or security/data-integrity control; failure blocks a key function or exposes a data breach / ownership violation. Execute first and require full evidence before exit. |
| **Medium** | Feature supports a significant user journey or adds important guardrails; failure causes an incomplete or degraded experience but not a data breach. Execute after all High items pass. |
| **Low** | Feature is a convenience or cosmetic quality item; failure does not block any primary flow. Execute after Medium items; acceptable to defer in a time-constrained cycle. |

**Risk-based prioritization factors:**

- **High:** RBAC/ownership enforcement (RISK-01); sharing revocation and token management (RISK-02); public data leakage (RISK-03); data integrity after deletion (RISK-04); duplicate-term bypass including Chinese legacy (RISK-05).
- **Medium:** AI generation lifecycle correctness (RISK-08, RISK-09); AI save boundary and cross-module non-impact (TA-07, TA-13); export content/privacy correctness (RISK-06); Flashcard create/edit validation.
- **Low:** Export failure handling and retry (AMB-04 resolved); empty-state messaging; idempotent sharing re-enable; export filename format.

### 2.5 Test Data Approach

**Naming convention (traceable, unique, non-PII):**

```
Flashcard term:  AUTO_TC_<tcid>_<YYYYMMDD>        (e.g. AUTO_TC010_20260829)
Deck name:       AUTO_DECK_<feature>_<YYYYMMDD>
Folder name:     AUTO_FOLDER_<feature>_<YYYYMMDD>
AI vocabulary:   AUTO_VOCAB_<tcid>_<YYYYMMDD>
```

**Data categories required:**

| Category | Description |
|---|---|
| Valid Flashcard data | Japanese and Chinese `term`/`meaning`/`exampleSentence` within limits; Kanji + Sino-Vietnamese; Hiragana-only + null Sino-Vietnamese; Chinese Hanzi + Sino-Vietnamese + optional Pinyin |
| Invalid/Boundary data | Blank fields after trim; fields at exactly max length (500, 1,000 chars); fields 1 character over max; normalized duplicates (whitespace, case, Unicode variants) |
| AI vocabulary lists | 1-item valid list; 50-item boundary list; 51-item over-limit list; mixed comma/newline/blank lines; all-blank input; items mismatched with selected language; 3,000-char boundary; 3,001-char over-limit |
| Legacy Chinese fixtures | Old-format Chinese term (pre-CR-DOC-001) to verify coexistence and 409 Conflict when editing to a conflicting new-format term |
| Cross-owner data | Two Learner accounts with distinct Decks; cross-owner access attempts using Learner B credentials on Learner A resources |
| Export target Deck | Non-empty owned Deck with known Flashcard count, multiline field content, and at least one field containing special characters |

**Privacy and safety rules:**

- Do not use real user data, real vocabulary, or real email addresses.
- All test Decks, Folders, and Flashcards must be cleaned up (deleted) after test execution.
- Cleanup order: Flashcard → Deck → Folder, respecting referential integrity.
- AI-generated previews that are not saved are automatically discarded; no cleanup action required.

---

## 3. Define the Test Objectives

1. Verify that a Learner can view, create, edit, and delete owned Flashcards, and that all field validation rules (required, trim, limits, language placement, normalized duplicate uniqueness, immutable Deck association) are enforced consistently at both UI and API layers.
2. Verify that creating or saving a Flashcard initializes the correct SRS state (`reviewLevel=0`, `nextReview=null`, `lastRecallRating=null`) and that deleting a Flashcard invalidates and removes all associated SRS state from the database.
3. Verify that a deleted Flashcard is immediately excluded from future LEARN queues, DASH calculations, the shared public view, and export output.
4. Verify that the AI generation flow correctly parses, normalizes, deduplicates, and limits vocabulary input; that `targetLanguage` is mandatory; and that invalid, rejected, or timed-out items are reported in `failedItems` without any database persistence.
5. Verify that AI-generated previews are temporary, editable, and correctly implement Sino-Vietnamese language mapping rules (required for Chinese Hanzi and Japanese Kanji; null for Hiragana/Katakana-only; Title Case capitalization), and that valid and invalid items are rendered accordingly.
6. Verify that the AI save flow enforces the same validation, ownership, duplicate check, and SRS initialization as manual Flashcard creation, and that the preview is fully discarded on cancel, page refresh, or session expiry.
7. Verify that enabling public sharing creates a unique, opaque, unguessable token and URL; that re-enabling while already active returns the existing URL without creating a new token; and that the feature enforces owner-only access.
8. Verify that the public shared-view returns only the approved data fields (`deckName`, `term`, `meaning`, `exampleSentence`) and denies all restricted actions, exposing no owner email, internal IDs, SRS data, or dashboard values.
9. Verify that disabling sharing immediately invalidates the prior token so that a subsequent fresh request to the old URL returns an unavailable state, and that re-enabling creates a new, distinct token.
10. Verify that export produces a correctly structured `.xlsx` file (exact column order, `No` starting at 1 in default DB retrieval order, UTC+7 filename, preserved multiline content), denies export for empty or non-owned Decks, and does not alter any application data on success or failure.
11. Verify that CRUD, AI save, sharing, and export operations do not advance `profiles.last_learning_activity_at` or create any notification rows, as required by CR-CROSS-001.
12. Verify that all ownership, session validity, and Active-account-status checks are enforced server-side and cannot be bypassed by UI manipulation or direct API calls.
13. Produce recorded evidence (screenshots, Postman execution results, database query outputs) for all executed test cases sufficient to support a Test Summary Report and communicate residual risk.

---

## 4. Define Test Criteria

### 4.1 Entry Criteria

- Finalized, approved requirement analysis document is available and all Ambiguities are resolved.
- Production application is reachable and stable at the target URL.
- At least two distinct Learner test accounts with Active status are available and accessible on Production.
- Postman is configured with the Production base URL and authentication tokens for each test account.
- Direct database query access (read-only) is confirmed for SRS state and notification verification.
- Test case documents (Excel/Docs) are drafted and reviewed before execution begins.
- Test data naming conventions and cleanup procedures are documented and agreed.

### 4.2 Test Result Criteria

| Status | Definition |
|---|---|
| **PASS** | All steps execute as expected; actual results match expected results; no material unexpected side effects are observed. |
| **FAIL** | Actual result deviates from the expected result in a way that is supported by the requirement; deviation is recorded with evidence. A FAIL is not automatically a confirmed defect before triage. |
| **BLOCKED** | Test case cannot be executed due to a missing dependency, environment issue, or upstream FAIL blocking the current test. Reason must be recorded. |
| **NOT RUN** | Test case was not executed within this cycle; reason must be recorded (e.g. deferred, out-of-scope for this round, AI service unavailable). |

### 4.3 Exit Criteria

- All High-priority test areas (TA-01 to TA-04, TA-08 to TA-10, TA-12) have been executed and results recorded.
- All Medium-priority test areas (TA-05 to TA-07, TA-11, TA-13) have been executed or are explicitly deferred with recorded justification.
- No open High-severity defects that block a core user journey remain unaddressed (either fixed and retested, or explicitly accepted with residual-risk sign-off).
- All FAIL and BLOCKED results have been triaged and communicated.
- A Test Summary Report has been produced, listing execution metrics, open defects, residual risks, and test coverage assessment.
- Test data cleanup has been completed on the Production database.

---

## 5. Resource Planning

### 5.1 Tools

| Tool | Purpose |
|---|---|
| **Google Chrome (latest stable)** | Primary browser for manual UI test execution on Windows 11 |
| **Postman** | API test execution — request construction, collection runner, assertion scripting, response inspection for all in-scope endpoints |
| **Excel** | Test case authoring, execution recording, defect log |
| **Google Docs / Markdown** | Test plan, test summary report, requirement analysis reference |
| **GitHub Issues** | Defect tracking and test artifact versioning (repository: LLH-Mannual-API-testing-project) |
| **Database client** | [TBD: confirm client tool] — Direct read-only query against Production DB to verify SRS state, notification rows, and sharing fields |
| **Screen capture tool** | Evidence capture (screenshots) for PASS/FAIL records |

### 5.3 Required Test Assets

| Asset | Description | Status |
|---|---|---|
| Learner Account A | Active Production account — primary test executor (owner role) | Available |
| Learner Account B | Active Production account — cross-owner / non-owner attack scenarios | Available |
| Public User session | Unauthenticated browser session (incognito mode) | Available |
| Postman Collection | Collection for Flashcard CRUD, AI Preview, Sharing, Export endpoints with pre-request auth token management | To be created |
| Postman Environment | Production base URL and auth tokens for Account A and B | To be created |
| Test Case Workbook | Excel file with scripted test cases for all 13 test areas (TA-01 to TA-13) | To be created |
| Test Data Matrix | Excel sheet documenting all test data items, purpose, classification, and cleanup status | To be created |
| Legacy Chinese Flashcard fixtures | Old-format `term` records (pre-CR-DOC-001) to cover 409 Conflict coexistence tests | To be created |
| DB read-only access | Read-only DB connection for SRS and notification verification queries | [TBD: confirm client and credentials] |
| Evidence folder | Screenshot and Postman response repository linked to test cases (GitHub or local folder) | To be created |

---

## 6. Plan the Test Environment

### 6.1 Test Environment

| Item | Configuration |
|---|---|
| **Application** | Language Learning Hub — Production build |
| **Environment URL** | https://language-learning-hub-for-quizz-fro.vercel.app |
| **Module under test** | DOC — Flashcard CRUD, AI Generation, Sharing, Export (FR-DOC-009 to FR-DOC-019) |
| **Operating System** | Windows 11 |
| **Browser** | Google Chrome (latest stable) |
| **API client** | Postman (latest desktop) |
| **Test accounts** | Learner A (owner), Learner B (non-owner/cross-owner), unauthenticated session (incognito) |
| **External integration** | Groq AI Service — live, shared free tier; 12 vocabulary items per batch; 60-second timeout |
| **Database access** | Read-only query access to Production DB for SRS/notification verification — [TBD: client tool and connection details] |
| **Network** | Standard internet connection; no VPN or proxy required |
| **Deployment** | Vercel (continuous deployment from main branch); no test-specific build or feature flag |

### 6.3 Environment Limitations

| Limitation | Impact | Mitigation |
|---|---|---|
| **Production is the only test environment** | Test data is mixed with real user data; cleanup failures leave residual records. | Use strictly traceable `AUTO_` prefix naming for all test artifacts; execute cleanup after every session; document cleanup steps in test case teardown. |
| **Groq AI Service is a shared free tier** | Rate-limit (429) or service outage can block AI test cases unpredictably. | Execute AI test cases in off-peak hours; mark AI-dependent cases as BLOCKED (not FAIL) if rate-limited; record `generationStatus` from API response as evidence. |
| **Groq AI content is non-deterministic** | Generated field values vary per call, making exact-match assertions on AI content unreliable. | Assert field structure, presence, language mapping rules, and Sino-Vietnamese format; do not assert exact AI-generated strings. |
| **No staging or rollback capability** | Defects found in Production cannot be isolated; test data pollution is permanent until cleaned up. | Minimize test data footprint; clean up immediately after each session; coordinate large batch tests to avoid peak usage. |
| **Database direct access is TBD** | Cross-module downstream checks (SRS init, notification absence) may need to rely on UI-observable evidence if DB access is not confirmed. | Document which test objectives require DB verification; fall back to toast/badge evidence and note the limitation in the Test Summary Report. |
| **Single tester** | Concurrent / race-condition test cases (RISK-05: duplicate bypass; RISK-10: save race) require simultaneous requests from two sessions. | Use Postman Collection Runner with parallel requests to simulate concurrency; note that true simultaneous browser UI concurrency may not be achievable with one tester. |

---

## 7. Schedule and Estimation

### 7.1 Estimation Method

**Method:** Activity-based work breakdown using relative sizing of test cases per test area.

**Assumptions:**

- Tester is familiar with the application and requirement analysis document before execution begins.
- The Production environment is stable and accessible throughout the test cycle.
- Groq AI Service is available for at least 80% of AI-related test execution time.
- All execution is sequential and manual; no parallel or automation testing.
- Defect fix and retest cycles are estimated at approximately 20% of initial execution effort (contingency).
- No deadline constraint; schedule is indicative and sequenced by priority.

**Factors that could change the estimate:**

- Groq service outages blocking AI test areas for extended periods.
- Discovery of a High-severity defect requiring early halt and escalation.
- Scope expansion (e.g. regression of Folder/Deck CRUD).
- Database access not being confirmed, requiring alternative verification methods.

### 7.2 Estimated Schedule

| Activity | Estimated Effort | Dependency / Timing |
|---|---|---|
| Test planning (this document) | 0.5 day | Completed first |
| Test case design — TA-01 to TA-04 (Flashcard CRUD) | 1 day | After plan approval |
| Test case design — TA-05 to TA-07 (AI Generation) | 1 day | After plan approval |
| Test case design — TA-08 to TA-11 (Sharing & Export) | 1 day | After plan approval |
| Test case design — TA-12 to TA-13 (RBAC & Cross-module) | 0.5 day | After plan approval |
| Test data preparation + Postman collection setup | 1 day | After test case design |
| Execution — High priority (TA-01 to TA-04, TA-08 to TA-10, TA-12) | 2 days | After entry criteria met |
| Execution — Medium priority (TA-05 to TA-07, TA-11, TA-13) | 2 days | After High priority execution |
| Defect triage and retest (contingency ~20%) | 1 day | After each execution round |
| Test data cleanup | 0.5 day | After each execution session |
| Test Summary Report | 0.5 day | After execution complete |
| **Total estimated effort** | **~10 days** | Sequential; no fixed deadline |

---

## 8. Determine Test Deliverables

| Deliverable | Purpose |
|---|---|
| **Test Plan** (this document) | Defines scope, approach, priorities, criteria, resources, environment, and schedule for the test cycle. |
| **Requirement Analysis** (`requirements_spec_DOC_flashcard-sharing-export.md`) | Primary traceability reference; finalized and approved. |
| **Test Case Workbook** (Excel) | Scripted test cases for TA-01 to TA-13 covering UI, API, and DB verification scenarios with expected results, priority, and traceability to FR/BR. |
| **Test Data Matrix** (Excel) | Documented test data items with naming, purpose, classification (valid/invalid/boundary), and cleanup status. |
| **Postman Collection** | Executable API test collection for Flashcard CRUD, AI Preview + Save, Sharing, and Export endpoints; includes pre-request auth and response assertions. |
| **Execution Records** (Excel) | Completed test case results including actual results, PASS/FAIL/BLOCKED/NOT RUN status, and linked evidence. |
| **Evidence Repository** (Screenshots / Postman results) | Visual and API response evidence linked to test cases; stored in GitHub repository or local folder referenced in execution records. |
| **Defect Reports** (GitHub Issues) | Structured defect reports for triaged FAIL results; includes severity, steps to reproduce, actual vs expected result, and evidence. |
| **Test Summary Report** (Docs / Markdown) | Post-execution summary: planned vs executed coverage, PASS/FAIL/BLOCKED metrics, open defect list with severity, residual risks, and go/no-go assessment. |

---

*This Test Plan covers planning scope and strategy only. It does not contain executable test cases, automation scripts, concrete test-data values, or defect reports. Those are produced in downstream workflows: test-case design (`$test-case`), test-data generation (`$test-data-generator`), and defect reporting (`$bug-report`).*
