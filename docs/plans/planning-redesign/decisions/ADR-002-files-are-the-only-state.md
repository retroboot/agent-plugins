# ADR-002 — Files are the only state: memory MCP, session UUIDs and container mode are removed

**Status:** accepted (developer, 2026-11-13)

## Context
`brainstorm`, `planning` and `work-issue` pass state through `session/{uuid}/…` memory keys, with
an `.ai/session/` fallback and a polled question/answer channel for headless runs. None of it is
visible to a fresh session or another machine. It also makes up a large share of the three skills,
and the developer does not use container mode.

## Options
1. Keep it as an optional layer next to packs: two sources of truth that drift. **Rejected.**
2. Remove it entirely. The pack is the state, and README Status is the phase. **Chosen.**

## Decision
Delete every session UUID, memory read and write, `.ai/session` fallback and container-mode
section from `brainstorm`, `planning` and `work-issue`.

## Consequences
- Resume works by reading README Status.
- A headless run that needs an answer stops at the checkpoint instead of polling.
- S-07.3 guards against the code coming back.
