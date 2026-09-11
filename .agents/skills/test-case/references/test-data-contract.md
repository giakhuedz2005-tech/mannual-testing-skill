# Test Data Contract

Read this reference whenever `TD-*` profiles are created, reused, split, renamed, retired, or synchronized. The contract is the handoff from `$test-case` to `$test-data-generator`.

## Purpose and ownership

`$test-case` owns:

- deciding which logical data profiles are required by the approved test cases;
- assigning stable `TD-*` IDs;
- defining profile semantics, target partitions/states, constraints, dependencies, and reset behavior;
- maintaining exact bidirectional links between `TC-*` and `TD-*`.

`$test-data-generator` owns:

- resolving those profiles into concrete synthetic values, files, fixtures, payloads, or runtime capture instructions;
- verifying exact boundaries, uniqueness, deterministic generation, and zero real PII;
- producing the concrete test-data dictionary or automation fixture without changing test-case logic.

The contract must be complete enough that the data generator does not need to infer which actor, resource, state, field, boundary, dependency, or oracle a `TD-*` represents.

## Profile boundary rule

One `TD-*` has one stable semantic meaning.

Create separate profiles when any of these differ:

- actor identity, role, account status, or ownership context;
- browser/session context, including concurrent, anonymous, expired, or stale sessions;
- logical or physical resource identity;
- resource lifecycle state, such as empty, populated, deleted, archived, shared, or revoked;
- input field, validation rule, target partition, or behavior class;
- failure/provider/environment mode;
- prerequisite/dependency chain;
- reuse, isolation, mutation, cleanup, or reset strategy;
- security/privacy classification.

Do not create one broad profile such as an “actor matrix” or “Deck data” profile containing unrelated actors, sessions, resources, and states merely because several test cases use some of them.

Multiple fields may share one `TD-*` when they form one coherent fixture or transaction dataset. For example, one active owner account may require email, role, status, and credential alias rows under the same profile. One populated Deck may require ID, name, owner, and prepared-card rows under the same profile.

A set of input values may share one `TD-*` only when it represents one data-driven partition family and all values use the same field/rule, workflow, expected behavior class, dependencies, isolation, and reset strategy. Otherwise create separate profiles.

## Canonical contract artifact

Filename:

```text
Test data contract for <Feature>.tsv
```

Canonical header, in this exact order:

```text
Data Ref ID (TD-*)	Profile Name	Profile Type	Linked Test Case (TC-*)	Field / Attribute	Target Partition / Required State	Constraint Source	Generation Instruction	Expected Behavior Class	Dependencies / Setup	Reuse / Isolation / Reset	Open Assumptions
```

Each physical row defines one field or attribute requirement. Repeating a `TD-*` across rows is valid only when all rows belong to the same coherent profile.

### Column rules

| Column | Required content |
|---|---|
| `Data Ref ID (TD-*)` | Stable profile identifier. |
| `Profile Name` | Short semantic name that remains meaningful without concrete values, such as `Active owner Learner A` or `Owned empty Deck`. |
| `Profile Type` | One of `ACTOR`, `SESSION`, `RESOURCE`, `INPUT_PARTITION`, `STATE`, `FILE`, `FAILURE_MODE`, `MATRIX`, `REFERENCE`, or `COMPUTED`. |
| `Linked Test Case (TC-*)` | Exact semicolon-separated list of cases consuming this row, not a copied profile-wide superset. |
| `Field / Attribute` | Field or attribute the downstream generator must resolve, such as `account.email`, `deck.id`, `Term`, or `provider_mode`. |
| `Target Partition / Required State` | Semantic partition/state, such as `Active owner`, `Exactly 500 characters`, `Deleted resource`, or `Timeout at configured deadline`. |
| `Constraint Source` | Requirement/AC/field-spec/schema/UI source establishing the rule. Use `UNCONFIRMED:<question-id>` when unresolved. |
| `Generation Instruction` | Deterministic instruction for producing or capturing the value. Include required format, length, uniqueness, fixed enum, or runtime-capture behavior without inventing a concrete value. |
| `Expected Behavior Class` | High-level oracle class such as `ACCEPT`, `REJECT_REQUIRED`, `REJECT_MAX_LENGTH`, `DENY_UNAUTHORIZED`, `NOT_FOUND`, `NO_MUTATION`, or `RUNTIME_BASELINE_EQUAL`. |
| `Dependencies / Setup` | Other `TD-*`, source records, environment modes, or creation order required before generation/execution. Use `NONE` when independent. |
| `Reuse / Isolation / Reset` | Whether the fixture is reusable/read-only, unique per case/run, mutable with reset, single-use, or runtime-captured. |
| `Open Assumptions` | Unresolved generation/oracle issue. Use `NONE` when fully defined. |

Use approved project vocabulary when it exists. Do not turn a suggested generation format into a product validation rule.

## Concrete-value boundary

The contract describes requirements, not generated data. Therefore:

- Do not place actual synthetic emails, UUIDs, names, tokens, boundary strings, passwords, or file binaries in the contract.
- Boundary expressions such as `exactly 500 Unicode code points`, formats such as `64 lowercase hexadecimal characters`, and confirmed fixed environment enums are allowed.
- Runtime values that cannot be known during design must be expressed as capture instructions, such as `Capture current notification count immediately before the action`.
- Secret values must be represented by credential aliases or secure runtime references, never embedded credentials.

Concrete values belong only in the downstream test-data dictionary or execution fixture.

## Identifier rules

Default format:

```text
TD-<AREA>-<PROFILE>-<NNN>
```

- Use a discriminating profile namespace such as `ACTOR`, `SESSION`, `DECK`, `FC`, `SHARE`, `EXPORT`, or `FAILURE`.
- For a new draft, number IDs contiguously within each namespace starting at `001`.
- During an audit, stable historical IDs take precedence. Do not renumber an unchanged profile solely to close a gap; document intentional gaps in the change report.
- Never reuse a retired ID for a different semantic profile.
- A rename is safe only when semantics remain unchanged and all consumers are updated together.

## Linking and reuse rules

The relationship is many-to-many, but every edge must be intentional:

- A test case may compose multiple profiles, separated in `Test Data, Input` by `; `.
- A profile may support multiple cases when the same fixture semantics are reused unchanged.
- A contract row lists only cases that consume that specific field/attribute requirement.
- A case linked from a contract row must contain that `TD-*` in its `Test Data, Input` cell.
- A case containing a `TD-*` must be represented by at least one applicable contract row for that profile.
- Do not repeat the full case list on every row when some rows apply only to a subset.

## Examples of correct profile splitting

```text
TD-DOC-ACTOR-001 = Active owner Learner A
TD-DOC-ACTOR-002 = Active non-owner Learner B
TD-DOC-ACTOR-003 = Deactivated Learner
TD-DOC-ACTOR-004 = Admin
TD-DOC-ACTOR-005 = Anonymous public user
TD-DOC-SESSION-001 = Two independent concurrent owner sessions
TD-DOC-SESSION-002 = Expired owner session
```

```text
TD-DOC-DECK-001 = Owned populated Deck
TD-DOC-DECK-002 = Owned empty Deck
TD-DOC-DECK-003 = Deleted Deck reference
TD-DOC-DECK-004 = Foreign-owned Deck
TD-DOC-DECK-005 = Clean mutable create target Deck
TD-DOC-DECK-006 = Alternate Deck for duplicate recalculation
```

These are profile examples, not mandatory product fixtures. Generate only profiles justified by the active suite.

## Mandatory bidirectional quality gate

Before delivery, verify:

1. Every `TD-*` in the test sheet exists in the contract.
2. Every contract `TD-*` is referenced by at least one test case.
3. Every contract-linked `TC-*` exists in the test sheet.
4. Every linked `TC-*` actually contains that `TD-*` in `Test Data, Input`.
5. Every test case consuming a `TD-*` appears in at least one applicable row for that profile.
6. No profile mixes incompatible actors, resources, states, partitions, dependencies, or reset strategies.
7. No concrete PII, secret, or generated value appears in the contract.
8. No contract row invents a constraint or expected behavior not supported by its source.
9. New-draft IDs are unique and contiguous within namespace; preserved historical gaps are reported.
10. The test sheet, contract, steps, preconditions, and expected results describe the same data semantics.

If any check fails, the test sheet and contract are not ready for `$test-data-generator` handoff.
