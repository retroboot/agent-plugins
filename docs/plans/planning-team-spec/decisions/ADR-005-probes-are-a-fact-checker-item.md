# ADR-005: Assumption probes are a Fact-checker checklist item

**Status:** accepted (developer, 2026-11-24)

**Proposed by:** author (spec); accepted by the developer at the spec ADR checkpoint

## Context

Every prd assumption must be probed before the design (prd S-04). A probe is a read-only check: reading a file, running a command that changes nothing. Something has to choose the check, run it, and report the evidence.

## Options

1. **A new Prober role.** Rejected: its job, proving a claim with read-only commands and quoting what they show, is the Fact-checker's job (`skills/planning/references/roles/fact-checker.md`, **Job**), and a second card would repeat it.
2. **The Facilitator runs the probes itself.** Rejected: it wrote the assumptions, so it would be checking its own work, which this pack exists to stop.
3. **The Fact-checker gains `F7`: probe every Assumptions row and report `held`, `false` or `not run: {reason}`, with evidence.** Chosen.

## Decision

`fact-checker.md` gains checklist item **F7**. A check that would write, install or use the network is not run and reports `not run: changes state`. The acceptance gate's Fact-checker runs it; the panel's Fact-checker runs it too, which re-checks the results before the cold read.

## Consequences

No new role. The panel gains a probe pass on every pack for free. The Fact-checker's checklist grows to seven items.
