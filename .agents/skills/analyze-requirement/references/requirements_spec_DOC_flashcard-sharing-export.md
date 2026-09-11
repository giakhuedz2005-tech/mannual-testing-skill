**REQUIREMENT ANALYSIS**

**Language Learning Hub- Flashcard CRUD, AI Generation, Sharing & Export**

**Testing Portfolio Project**

**Github: [LLH\_Mannual\_API\_testing\_project](https://github.com/giakhuedz2005-tech/LLH-Mannual-API-testing-project)**

**Github Web Project: [Language-learning-hub-for-quizz](https://github.com/giakhuedz2005-tech/Language-learning-hub-for-quizz)**

**Url: [link web](https://language-learning-hub-for-quizz-fro.vercel.app)**

**Requirement Basis: BRD.md v1.9 (BR-02) and FRD-DOC.md v0.5 (Group 3: FR-DOC-009–012; Group 4: FR-DOC-013–015; Group 5: FR-DOC-016–019), incorporated with Phase 2 Changes (CR-DOC-001, CR-DOC-002, CR-CROSS-001) and Production Hotfixes (DEF-AI-01–04, DEF-UI-01–02, DEF-SAVE-01).**

[**1\. Overview & Scope	3**](#1.-overview-&-scope)

[1.1 In scope	3](#1.1-in-scope)

[1.2 Out of scope	3](#1.2-out-of-scope)

[**2\. Business Requirements	4**](#2.-business-requirements)

[**3\. Functional Requirements & Logic Flow	5**](#3.-functional-requirements-&-logic-flow)

[3.1 Functional requirements and acceptance baseline	5](#3.1-functional-requirements-and-acceptance-baseline)

[**4\. Field Specifications & Data Constraints	6**](#4.-field-specifications-&-data-constraints)

[**5\. RBAC & Downstream Impacts	10**](#5.-rbac-&-downstream-impacts)

[5.1 Permission matrix	10](#5.1-permission-matrix)

[5.2 Downstream impacts and dependencies	11](#5.2-downstream-impacts-and-dependencies)

[**6\. Traceability Matrix	12**](#6.-traceability-matrix)

[**7\. Ambiguities & Testing Risks	14**](#7.-ambiguities-&-testing-risks)

[7.1 Ambiguities requiring PO/BA clarification	14](#7.1-ambiguities-requiring-po/ba-clarification)

[7.2 Testing risks	15](#7.2-testing-risks)

## 

## **1\. Overview & Scope**

* **Business requirement:** BR-02 \- Managing Document.  
* **Business purpose:** Let a learner create and manage high-quality vocabulary material in the hierarchy Folder \> Deck \> Flashcard, accelerate preparation with reviewable AI generation, safely expose a selected Deck for read-only public viewing, and take an offline Excel copy of its current Flashcards.  
* **Actors:**  
  * **Learner:** Authenticated Active owner of the Deck and its Flashcards.  
  * **Public User:** Unauthenticated visitor who opens an active shared Deck URL; read-only.  
  * **AI Service (Groq)**: External service that generates temporary Flashcard preview content from valid vocabulary input.  
  * **System:** Enforces session, account status, ownership, public-link state, and downstream consistency.  
* **Module preconditions:** The system is operational; Learner session is valid; Learner account is Active; every Learner action is limited to resources they own. FR-DOC-017 is the sole public-access exception.

### **1.1 In scope**

* View the Flashcards of an owned Deck, including the empty-list state.  
* Manually create, edit, and permanently delete an owned Flashcard.  
* Validate Flashcard content, language placement guidance, duplicate terms, and the non-movable Deck association.  
* Initialize learning state for a newly saved manual Flashcard and remove/invalidate it when deleted.  
* Submit a vocabulary list to AI Service, validate and review a temporary generated preview, and save selected valid generated Flashcards to an existing Deck or a new Deck under an owned Folder.  
* Enable/disable a public share link for an owned Deck; view the active link as a Public User.  
* Export the current contents of a non-empty owned Deck as .xlsx.  
* RBAC, ownership checks, shared-link revocation, privacy of public data, and effects on LEARN/DASH.

### **1.2 Out of scope**

* Folder/Deck CRUD(Groups 1, 2).  
* Creating a Deck without an existing Folder; moving Flashcards between Decks.  
* Editing, exporting, importing/copying, learning from, or collaboratively editing a public shared Deck.  
* Guaranteeing content accuracy; detailed token algorithm, endpoint/database design, and implementation-specific Excel generation.

## **2\. Business Requirements**

* **BR-02.1 \- Ownership and hierarchy:** A Flashcard belongs to exactly one Deck. A Learner may only manage their own content.  
* **BR-02.2 \- Flashcard completeness:** term, meaning, and exampleSentence are mandatory, distinct content elements and must be non-empty after trimming before save.  
* **BR-02.3 \- Language content placement:** Japanese and Chinese content follow their respective placement rules; a phonetic reading that is inapplicable or unavailable does not block saving.  
* **BR-02.4 \- Flashcard uniqueness and immobility:** A normalized term is unique within one Deck; editing cannot move a Flashcard to another Deck.  
* **BR-02.5 \- Learning-data integrity:** A newly saved manual Flashcard is initialized as new/unreviewed. A deleted Flashcard must immediately cease to feed future learning, dashboard, shared-view, and export retrievals.  
* **BR-02.5A** \- AI input and preview boundary: The system parses, normalizes, deduplicates, and limits AI vocabulary input; generated output is temporary, reviewable, and never becomes learning content before explicit Learner confirmation.  
* **BR-02.5B** \- AI partial-result safety: Valid generated items may be previewed and saved when other items fail, but missing/invalid generated items cannot be selected for save.  
* **BR-02.5C** \- AI save consistency: Saved AI-generated Flashcards use the same three approved fields, ownership/duplicate validation, and initial SRS state as manually created Flashcards.  
* **BR-02.6 \- Controlled public sharing:** One owned Deck may have a unique, unguessable active URL. Public access is anonymous, read-only, and exposes only approved content.  
* **BR-02.7 \- Immediate revocation:** Disabling sharing or deleting the Deck makes its URL inactive. Re-enabling creates a new token; the old one remains invalid.  
* **BR-02.8 \- Non-mutating export:** An owned non-empty Deck can be exported in the exact .xlsx content format; sharing/export do not change Flashcards, SRS, sessions, or dashboard metrics.

## **3\. Functional Requirements & Logic Flow**

### **3.1 Functional requirements and acceptance baseline**

| FR | Description | Acceptance baseline / exception coverage |
| ----- | ----- | ----- |
| FR-DOC-009 | Learner views Flashcards in an owned Deck. | Show only current Flashcards; show “This Deck has no Flashcards yet.” for an empty Deck; deny cross-owner access; handle missing Deck as Not Found. |
| FR-DOC-010 | Learner manually creates a Flashcard. | Save valid fields in target Deck; trim and reject blank/over-limit fields; reject normalized duplicate term in the same Deck; initialize reviewLevel=0, nextReview=null, lastRecallRating=null; deny missing/cross-owner Deck. |
| FR-DOC-011 | Learner edits an owned Flashcard. | Update valid content only; preserve its Deck association and existing learning state; keep prior data if validation/duplicate check fails; reject a movement attempt, Not Found, or cross-owner request. |
| FR-DOC-012 | Learner deletes an owned Flashcard. | Permanently delete without confirmation; remove/invalidate associated SRS state; no other Flashcard changes on failure; exclude the deleted item from downstream retrieval. |
| FR-DOC-013 | Learner submits a vocabulary list for AI generation. | Learner selects mandatory targetLanguage (Japanese or Chinese) and submits vocabulary list. Parse comma/newline/mixed input; trim, ignore blanks, deduplicate, accept at most 50 items and 3,000 characters; reject request with 400 Bad Request if target language is missing or unsupported; proceed with valid items for the selected target language where possible; do not save a Flashcard. |
| FR-DOC-014 | System generates an AI Flashcard preview. | Validate required three fields, target language mapping, Sino-Vietnamese reading rules (required for Chinese Hanzi and Japanese Kanji; null for Hiragana/Katakana-only; Title Case capitalization), and contextual example sentence with Vietnamese translation. Display valid and "uncertain but safe to review" items in temporary preview; surface missing/invalid/wrong-language/timed-out generation in failedItems with specific failure reasons without persistence. |
| FR-DOC-015 | Learner reviews and saves AI-generated Flashcards. | Permit edits and selection; when an Existing Deck is selected, visually identify duplicate normalized terms on UI before save (recalculated on term edit, Deck change, or selection change); prevent save while duplicate selected items exist; save valid non-duplicate selected items to an owned existing Deck or a valid new Deck under an owned Folder; validate duplicate/ownership/required fields and initialize SRS state. |
| FR-DOC-016 | Learner enables public sharing for an owned Deck. | Set sharing to enabled and create an active URL /share/deck/{shareToken}; if already enabled, show the existing URL; deny missing/cross-owner Deck. |
| FR-DOC-017 | Public User views an active shared Deck. | Show only deckName, term, meaning, exampleSentence in view-only mode; return unavailable state for invalid, disabled, or deleted link; display empty state for an empty Deck; deny restricted actions. |
| FR-DOC-018 | Learner disables public sharing. | Set sharing disabled and immediately revoke prior link; a refresh/next request from an open public page must be unavailable; re-enable creates a new token; deny cross-owner request. |
| FR-DOC-019 | Learner exports an owned Deck. | Produce .xlsx only for a non-empty owned Deck; exact columns/order and UTC+7 filename; retain supported multiline content; deny public/cross-owner use; do not alter application data on export failure. |

## **4\. Field Specifications & Data Constraints**

| Field / output | Control or type | Required | Validation / constraint | Default / state | Dependencies / notes |
| ----- | ----- | ----- | ----- | ----- | ----- |
| term | Multiline text input / text | Yes | Non-empty after trim; max 500 chars; line breaks allowed; normalized (trim, collapse internal spaces, case-insensitive where applicable) must be unique in the Deck. Japanese: original vocabulary \+ applicable Sino-Vietnamese (required when vocabulary contains Kanji; null for Hiragana/Katakana-only). Chinese: original vocabulary only. Sino-Vietnamese syllables use Title Case capitalization. UI renders multiline term in a multiline editor control, preserving line breaks. | None | Shown in full on Flashcard front and shared view/export. |
| meaning | Multiline text input / text | Yes | Non-empty after trim; max 1,000 chars; line breaks allowed; must be conceptually separate from example. Japanese: applicable Hiragana then Vietnamese meaning. Chinese: Sino-Vietnamese, optional Pinyin, then Vietnamese meaning. Vietnamese meaning must never be placed in the Sino-Vietnamese reading line. | None | Absence of unavailable/inapplicable Hiragana or Pinyin does not block manual save. Shown on back/shared view/export. |
| exampleSentence | Multiline text input / text | Yes | Non-empty after trim; max 500 chars; line breaks allowed; target-language contextual sentence followed by Vietnamese translation. Missing target sentence, missing Vietnamese translation, or wrong target language invalidates preview item. | None | Shown separately on back/shared view/export. |
| flashcardDeckAssociation | Immutable relationship | Yes | Exactly one Deck; changing it is out of MVP scope. | Target Deck at create | Must remain unchanged on edit. |
| reviewLevel | Number | System | Initialized to 0 when manual Flashcard is saved. | 0 | Used by LEARN/DASH; no recalculation on content edit. |
| nextReview | Date/null | System | Initialized null; null means new/unreviewed. | null | Makes saved item eligible for Study Today. |
| lastRecallRating | Enum/null | System | Initialized null. | null | SRS data is removed/invalidated on deletion. |
| vocabularyList | Multiline text input / collection | Yes for AI request | One item per line, comma-separated, or mixed; trim items; ignore empty lines/extra spaces; deduplicate normalized terms; max 50 items and 3,000 characters; requires explicit targetLanguage (Japanese or Chinese). | None | Unsupported items or items inconsistent with target language are returned in failedItems; missing targetLanguage rejects request before provider call. |
| generationStatus | System enum | System | pending, completed, partial, failed, or timedOut. | pending after valid submission | timedOut/failed does not save content. |
| generatedFlashcardPreview | Temporary editable collection | Conditional | Each item requires valid term, meaning, exampleSentence and approved language mapping before it is save-eligible. UI layout: Term and Meaning match in width/height; Example sentence occupies full row below. | Not persisted | Discarded on cancel, refresh, logout, or session expiry; excluded from LEARN, DASH, sharing, and export until saved. |
| AI save target | Existing Deck selector / new Folder \+ deckName | Yes when saving | Existing target must be owned and exist; new Deck requires an owned existing Folder plus valid non-duplicate deckName. | None | Duplicate generated terms in Existing Deck are pre-checked and identified on UI before save (DEF-SAVE-01). Existing Chinese data policy: old-format Chinese Flashcards are not auto-migrated; editing an old card may return 409 if a new-format term already exists. |
| sharingStatus | Toggle / enum | System | enabled or disabled; only owner may change it. | disabled assumed for a new Deck; confirm in AMB-01 | Affects Public User access only. |
| shareToken | System-generated opaque token | Conditional | Unique, unguessable; no readable learner/deck/email/private data; not reused after revoke. | Created on enable | Technical algorithm intentionally unspecified. |
| sharedDeckUrl | Read-only URL | Conditional | /share/deck/{shareToken}; active only while sharing enabled and Deck exists. | Created on enable | Does not auto-expire. |
| exportFile | .xlsx download | Conditional | Only non-empty owned Deck. Filename deck\_\<normalizedDeckName\>\_\<YYYYMMDD\>.xlsx, UTC+7. | Generated on request | normalizedDeckName: lowercase, spaces to hyphens, unsafe characters removed/replaced. |
| Export columns | Ordered worksheet columns | Yes when export succeeds | Exact order: No, Term, Meaning, Example Sentence; preserve multiline where supported. | N/A | Excludes private/system/SRS information. |

## **5\. RBAC & Downstream Impacts**

### **5.1 Permission matrix**

| Action / resource | Learner \- owner | Learner \- non-owner | Public User | Admin |
| :---- | :---- | :---- | :---- | :---- |
| View Flashcards in a Deck | Allowed | Denied | Denied except active shared view | Denied |
| Create / edit / delete Flashcard | Allowed | Denied | Denied | Denied |
| Submit AI vocabulary / view own preview | Allowed | Denied | Denied | Denied |
| Edit/select/save own generated preview | Allowed | Denied | Denied | Denied |
| Generate preview content | System invokes Groq for owner request | N/A | Denied | Denied |
| Enable / disable sharing | Allowed | Denied | Denied | Denied |
| View active shared link | May view | May view as public content only | Allowed, view-only | May view as public content only |
| Export Deck | Allowed for non-empty Deck | Denied | Denied | Denied |
| View owner/SRS/dashboard/internal data through share page | N/A to public page | N/A | Denied / not exposed | N/A |

UI hiding is not authorization. Backend/API must enforce role, Active account status, ownership, and token state. A deactivated Learner cannot continue authenticated actions.

### **5.2 Downstream impacts and dependencies**

| Change/event | Affected area | Required impact |
| :---- | :---- | :---- |
| Manual Flashcard saved | LEARN, DASH | Initialize new learning state; item becomes eligible for Study Today. Toast UI feedback; does NOT advance profiles.last\_learning\_activity\_at and creates no notification row. |
| AI preview generated but not saved | DOC, LEARN, DASH, sharing, export | Temporary only; it must not affect learning queues, dashboard metrics, public view, or export. |
| Valid generated Flashcards saved | DOC, LEARN, DASH, sharing, export | Persist as ordinary Flashcards, initialize reviewLevel \= 0, nextReview \= null, lastRecallRating \= null, and make them available to downstream modules. Toast UI feedback; does NOT advance profiles.last\_learning\_activity\_at and creates no notification row. |
| Flashcard content edited | DOC, LEARN/DASH | Content updates; Deck association and learning state remain unchanged. Toast UI feedback; no activity/notification record. |
| Flashcard deleted | LEARN, DASH, public view, export | Immediately exclude it from future Study Today/Freedom Mode queues, active/future LEARN retrieval, dashboard source calculations, shared Deck retrieval, and export. Toast UI feedback; no activity/notification record. |
| Deck sharing enabled/disabled | Public shared-view access | Only changes public access; does not change learning eligibility, SRS, DASH, or the owner's Freedom Mode availability. Toast UI feedback; no activity/notification record. |
| Deck deleted | Shared link | Invalidate its public URL. |
| Deck exported | DOC, LEARN, DASH, sharing | Read-only operation; no state/content/metrics/sharing change. |

## **6\. Traceability Matrix**

| BR / rule | Functional requirement | Acceptance criteria covered | Verification focus |
| :---- | :---- | :---- | :---- |
| BR-02.1; BR-DOC-008 | FR-DOC-009 | AC-DOC-009-01 to 03 | Owned list, empty state, ownership. |
| BR-02.2, BR-02.3; BR-DOC-008, 009, 015, 020 | FR-DOC-010 | AC-DOC-010-01 to 05 | Required/boundary fields, normalized duplicate, language placement, initial SRS state, RBAC. |
| BR-02.2–02.4; BR-DOC-008, 009, 010, 015 | FR-DOC-011 | AC-DOC-011-01 to 06 | Update integrity, validation rollback, duplicate exclusion, immutable Deck relationship, RBAC. |
| BR-02.5; BR-DOC-011, 020 | FR-DOC-012 | AC-DOC-012-01 to 04 | Permanent deletion and downstream exclusion. |
| BR-02.5A; BR-DOC-012, 013, 015 | FR-DOC-013 | AC-DOC-013-01 to 08 | Input parsing, normalization, limits, supported-item handling, no persistence, provider timeout. |
| BR-02.3, BR-02.5A–B; BR-DOC-013, 014, 015 | FR-DOC-014 | AC-DOC-014-01 to 04 | Required fields, language mapping, partial results, invalid-item exclusion, provider failure. |
| BR-02.2–02.5C; BR-DOC-004–006, 008–009, 013–015, 020 | FR-DOC-015 | AC-DOC-015-01 to 08 | Editable preview, target ownership, new/existing Deck, duplicate/validation controls, discard boundary, initial SRS state. |
| BR-02.6–02.8; BR-DOC-016–018, 021 | FR-DOC-016 | AC-DOC-016-01 to 04 | Token/URL activation, idempotency, ownership. |
| BR-02.6; BR-DOC-016–018, 021 | FR-DOC-017 | AC-DOC-017-01 to 06 | Active-token validation, public data minimization, view-only enforcement. |
| BR-02.7; BR-DOC-016–018, 021 | FR-DOC-018 | AC-DOC-018-01 to 05 | Immediate revocation, refresh behavior, old-token non-reuse. |
| BR-02.8; BR-DOC-019, 021 | FR-DOC-019 | AC-DOC-019-01 to 07 | File type/content/order/name, empty/unauthorized/error paths, non-mutation. |

## **7\. Ambiguities & Testing Risks**

### **7.1 Ambiguities requiring PO/BA clarification**

| ID | Point | Clarification & Specification | Desicion |
| :---- | :---- | :---- | ----- |
| AMB-01 | Public page browser caching after revocation | What cache headers and expected behavior are required for browser Back, cached pages, or offline mode after sharing is disabled? | Accept browser caching risk. Data only disappears after manual page reload (F5) or when cache expires. |
| AMB-02 | Export No numbering & ordering | Should No begin at 1, and what stable sort order must export use (creation time, list order, term, or another rule)? | No stable sorting order; cards are exported in the default database retrieval order. Column No starts at 1\. |
| AMB-04 | Generic export failure logging & retry | Must failed exports remove partial files and permit retry immediately; are error codes/logging required? | System must clean up partial files on failure, return a user-friendly error allowing immediate retry, and log errors on server. |
| AMB-05 | Public link response schema | Please approve an explicit allow-list schema for the public link response, including whether deck/flashcard IDs are ever exposed. | Public API returns minimal schema: Deck { deckName } and Flashcards list { term, meaning, exampleSentence }. Exclude all database IDs/metadata. |

### **7.2 Testing risks**

| ID | Risk | Detailed description | Mitigation |
| ----- | ----- | ----- | ----- |
| RISK-01 | Broken ownership enforcement | Direct URL/API access could create, edit, delete, share, or export another Learner’s resources. | Run authorization tests for each action at UI and API layers using two Learners, invalid session, deactivated account, and Admin session. |
| RISK-02 | Stale share-link access | Revocation or Deck deletion may leave old tokens active due to cache, replicas, or token reuse. | Verify old URL on fresh request/refresh after disable/delete and re-enable; assert new token differs and response contains no Deck data. |
| RISK-03 | Public-data leakage | Shared view could expose owner email, IDs, SRS/dashboard values, hidden controls, or privileged API data. | Contract-test an allow-list of public fields and test direct restricted endpoints/actions. |
| RISK-04 | Data-integrity drift after deletion | Deleted Flashcards could remain in LEARN queues, DASH calculations, share view, or export. | Run cross-module retrieval checks after deletion, including an active session containing the item. |
| RISK-05 | Duplicate bypass | Whitespace, case, Unicode, concurrent requests, and the CR-DOC-001 old/new Chinese term formats can yield unexpected duplicate outcomes because uniqueness uses the complete normalized stored term. | Test normalized variants and concurrent create/edit submissions; verify legacy/new Chinese coexistence and 409 Conflict when editing an old-format item into an already used new-format term; keep atomic uniqueness as the authoritative boundary. |
| RISK-06 | Export privacy/correctness defects | Export could include unintended columns, wrong filename date/time zone, wrong order, damaged multiline values, or empty output. | Inspect generated workbook contents/properties under UTC+7 boundaries, special characters, line breaks, and empty/non-owner/public scenarios. |
| RISK-07 | XSS/content rendering | User-entered multilingual text may be rendered in lists or public pages without safe encoding. | Security-test HTML/script-like strings in all three fields; verify safe rendering and no script execution. |
| RISK-08 | AI provider failure, latency, or partial response | Timeout, error, malformed output, or a partial provider response may incorrectly persist content or discard valid items. | Test input rejection, 60-second timeout, failed/partial status, exact failed-item reporting, and confirm no persistence until valid selection and confirmation. |
| RISK-09 | AI language/content misclassification | Script overlap or weak semantic checks can place content in the wrong field or accept a non-contextual/wrong-language example. | Use Japanese and Chinese fixtures, missing-field/wrong-language cases, editable-preview checks, and retain the Learner review gate. |
| RISK-10 | Generated batch target and duplicate race | A target Deck/Folder may disappear, be unauthorized, or gain a duplicate term between preview and save. | Verify Not Found/Permission Denied/Duplicate responses, no persistence for invalid items, and successful save of valid partial selections where defined. |

