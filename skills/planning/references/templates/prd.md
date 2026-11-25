# PRD — <Title>

_Guidance: every heading below says when it is included. Delete a section whose trigger does not
apply to this route; never leave one empty. Criterion IDs are referenced by `plan.md` and by
progress files: never renumber them, and add new ones at the end of a story._

## Problem

_Always. Guidance: what is wrong or missing today, and the evidence. Number the causes if there are
several._

## Users and jobs

_Always with a prd. Guidance: who is affected, then one job per user in the form below._

- **<User>:** <who they are>

**Jobs.**

- <User>: "When <situation>, I want <motivation>, so I can <outcome>."

## Goals

_Always. Guidance: numbered `G1`, `G2`, … Each is an outcome, not a task._

- G1. <outcome>

## Non-goals

_Always. Guidance: what this work deliberately does not do, so an executor does not drift into it._

## Success measures

_Always. Guidance: numbered `M1`, `M2`, … Each is observable after release._

- M1. <measure>

## Non-functional requirements

_Always with a prd. Guidance: one row per quality, every quality listed, each a measurable target or
`none` with a short reason. Never omit a row._

| Quality | Target |
|---|---|
| Performance | <target or none> |
| Reliability | <target or none> |
| Security | <target or none> |
| Privacy | <target or none> |
| Accessibility | <target or none> |
| Observability | <target or none> |
| Compatibility / portability | <target or none> |
| Maintainability | <target or none> |

## Assumptions

_Always with a prd. The Analyst writes `not probed yet` in Probe; after the acceptance gate the
Facilitator writes the Fact-checker's F7 result there: `held: {evidence}`, `false: {evidence}` or
`not run: {reason}`._

| Assumption | How to validate | If false | Probe |
|---|---|---|---|
| <assumption> | <check> | <what changes> | <not probed yet> |

## Story map

_Feature, Greenfield or Rewrite at size M and larger. Guidance: journey steps left to right, the
stories that serve each step underneath. Slices in `plan.md` name the steps they touch._

| <Step 1> | <Step 2> | <Step 3> |
|---|---|---|
| S-01 | S-02 | S-03 |

## Stories and acceptance criteria

_Feature, Greenfield, Rewrite and Migration. Guidance: one story per heading, then its criteria as
Given/When/Then with IDs `S-NN.k`._

### S-01 <Story title>

As <user>, I want <capability>, so that <benefit>.

- **S-01.1** Given <state>, when <action>, then <result>.

## Behaviour-preservation contract

_Refactor only, in place of Stories. Guidance: the behaviour that must not change, as criteria
`S-NN.k` grouped by area. Prove each with characterization cases under Rules and examples._

## Regression criteria

_Bug at size M and larger. Guidance: criteria `S-NN.k` stating the fixed behaviour and what must not
regress around it._

## Rules and examples

_Whenever there are stories, a preservation contract or Bug regression criteria. Guidance: per story,
one or more rules. Each rule gets an examples table of at least 2 rows, with at least one edge or
failure case. Columns make given, when and then explicit; a When shared by every row may sit in the
column header. Row IDs extend the criterion ID: `S-01.1.e1` is the first example under S-01.1._

### S-01 <Story title>

Rule: <the rule in one sentence>.

| ID | Given | When | Then |
|---|---|---|---|
| S-01.1.e1 | <state> | <action> | <result> |
| S-01.1.e2 | <edge or failure state> | <action> | <result> |

## Failure modes

_Whenever there are stories, and for every Bug. Guidance: one row per way this can go wrong in use._

| Failure | Trigger | Expected behaviour | What the user sees | Criterion |
|---|---|---|---|---|
| <failure> | <trigger> | <behaviour> | <message or state> | S-01.1 |
