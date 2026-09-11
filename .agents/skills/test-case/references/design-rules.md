# Test Suite Design Rules

Read this reference whenever cases are created, split, merged, or audited.

## Contents

1. Atomic outcome rule
2. Split versus group decision
3. Coverage audit
4. Requirement and oracle discipline
5. Risk and priority
6. Existing-suite changes

## 1. Atomic outcome rule

A test case should prove one primary business outcome. It may contain multiple tightly coupled assertions needed to prove that outcome, such as UI confirmation plus persisted state, or deletion plus required cascade cleanup.

Do not interpret “one outcome” as “one click” or “one assertion.” A complete happy path can remain one case when the actions form one transaction and there is one success/failure oracle.

## 2. Split versus group decision

Group multiple data partitions in one data-driven case only when **all** of the following are the same:

- requirement or validation rule;
- actor and authorization context;
- starting state and preconditions;
- workflow and action under test;
- expected UI meaning/message and resulting UI state;
- persistence/integrity effect;
- risk and priority;
- reset and evidence strategy.

Each grouped partition must be executable independently. Steps must reset state between iterations, and evidence must identify the result of every partition.

Split when **any** of the following differs:

- validation class, such as required/blank versus maximum length + 1;
- expected message, control state, navigation, or recoverability;
- cause of failure, such as missing resource versus unauthorized resource;
- referential path, such as target Deck deleted versus parent Folder deleted;
- mutation type or atomicity consequence;
- actor, role, session, or ownership boundary;
- provider state, such as timeout versus unavailable response;
- lifecycle transition, such as inactive token versus deleted parent resource;
- traceability source or materially different risk;
- setup, cleanup, or evidence requirements.

### Field validation nuance

Analyze every field separately. Create separate cases for field-specific rules. The same required rule may be tested as one data-driven case across fields only if the application exposes the same behavior/message and every partition can be independently evidenced. Never combine required checks with format, uniqueness, min/max, semantic, or authorization checks merely because they share a form.

### Matrix exception

A single decision-table or actor/action matrix case is useful when it proves one invariant across a controlled set of combinations. Keep it only if:

- all cells use the same oracle;
- the matrix is easier to execute and diagnose than separate cases;
- failures can be recorded per cell;
- it does not repeat feature-level cases that already prove the same boundary.

If feature cases cover create/edit/delete authorization individually, a route-wide RBAC matrix should cover only the remaining shared invariant or be removed.

## 3. Coverage audit

Build a map with one row per atomic requirement/AC/business rule/risk:

| Source | Obligation | Actor/state | Risk | Primary case | Secondary evidence | Gap/duplicate |
|---|---|---|---|---|---|---|

Audit for:

- source with no primary case;
- case with no source or justified risk;
- two cases with the same precondition, action, and oracle;
- a broad matrix hiding missing feature-specific behavior;
- cross-module invariant verified both inside every feature case and again in a dedicated case;
- combined cases with multiple independent failure causes;
- positive coverage without rejection/non-mutation coverage;
- mutation coverage without stale/concurrent integrity coverage where risk justifies it;
- security assertions that verify only hidden controls but not protected mutation/state.

Choose one strategy for cross-cutting invariants:

- embed the invariant in the relevant high-risk feature cases; or
- use one dedicated integration/matrix case.

Do not do both unless each layer has a distinct oracle and traceability purpose.

## 4. Requirement and oracle discipline

Use an enforceable requirement as the pass/fail oracle. Examples:

- A field is required or has a confirmed limit: rejection is enforceable.
- A term must be unique within a Deck: duplicate rejection is enforceable.
- A multilingual layout is guidance with no validator: arbitrary non-empty text may still be valid; test preservation/rendering, not semantic rejection.
- An exact toast is not specified: expect a clear duplicate/conflict message, not invented copy.

For unclear rules, record:

- what is confirmed;
- what is ambiguous;
- the narrow assumption used, if safe;
- what expected results must change after clarification.

Do not transform a data-generation profile description into a product validation rule.

## 5. Risk and priority

Use project priority rules first. Otherwise:

- **High:** unauthorized access/mutation, privacy leakage, data loss, uniqueness/concurrency, atomicity/orphan prevention, irreversible deletion, broken referential integrity, critical cross-module effects.
- **Medium:** core positive flows, recoverable validation failures, standard boundary behavior, file accuracy.
- **Low:** cosmetic/layout behavior, informative empty states, safe idempotent repeats with low impact.

Priority reflects failure impact and likelihood, not whether a case is positive or negative.

## 6. Existing-suite changes

When revising a suite:

- Keep the original ID if the case still proves the same primary outcome.
- When splitting, keep the original ID for the closest original outcome and assign new IDs to the extracted outcomes, unless project convention requires draft renumbering.
- When merging, retain the most stable relevant ID and report the retired IDs.
- Do not silently reuse a retired ID for a different behavior.
- Preserve actual results and execution evidence for unchanged semantics.
- Reset new or materially changed cases to `NOT RUN` unless the user supplies migrated execution evidence.
- Update every dependent column after a change; changing only Test Data while leaving stale steps or expected results is invalid.

