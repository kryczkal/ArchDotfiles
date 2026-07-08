---
name: invariant-map
description: Map an app's stage boundaries and rank them by where MISSING invariants cause branching / ducttape / haziness. Read-only — produces a leverage-ranked worklist to feed invariant-audit. Use to see where state-space complexity lives before simplifying, or to check which boundaries already carry enforced invariants.
argument-hint: [path-or-subsystem (optional)]
effort: medium
---

# Invariant Map (read-only)

You are building a **leverage-ranked map** of where an app's complexity lives, through one lens:
**invariants**. This run makes **no code changes**. Its output is a worklist that `invariant-audit`
consumes.

## The lens (read this first)

At any point in execution there is a **state** (the set of facts currently true). A line of code must
handle whichever states can *reach* it — so each unguarded possibility becomes a branch. **An invariant
is a fact guaranteed true at a point regardless of path.** It shrinks the set of reachable states,
which deletes the branches that existed to handle the excluded ones. Missing invariants are therefore
the root cause of:

- **ifology** — dense `if`/`else`/`switch`/`?.`/`== null` guards compensating for not knowing the state.
- **ducttape** — a special-case patch for a state that "shouldn't" arrive but does (symptom of a hole upstream).
- **haziness** — code where you cannot state what's true, so branches can't be judged dead vs load-bearing.

You are locating the boundaries where establishing one invariant would collapse the most complexity.
A **stage boundary** is where one unit hands control to the next (module→module, phase→phase, or a
function's input/output contract).

## Phase 1 — Discover

- Read project docs (`CLAUDE.md`, `README.md`, `docs/**`) and config to learn the stack, and the
  lint / typecheck / test commands (you won't run edits, but note them for `invariant-audit`).
- Map the **stages and boundaries**: entrypoints, phase/pipeline steps, module seams, the fan-in points
  where many callers converge (those accumulate the most reachable states). If `$ARGUMENTS` is a path or
  subsystem, restrict to it.
- Grep for **already-enforced invariants** so you don't re-flag covered boundaries: search for the
  marker `INVARIANT:` and the project's assert idiom (`node:assert`, `invariant(`, `assert `, etc.).

## Phase 2 — Score each boundary by symptom density

Use cheap structural signals, then judge leverage by eye. Higher = more complexity a single invariant
could remove:

- deep/defensive nesting; long boolean guards; repeated null/undefined/kind checks across a function
- `catch` blocks that swallow or **fabricate** a result (mask a failure instead of surfacing it)
- the same precondition re-checked in many callers (an invariant belongs at the boundary they share)
- states the code can reach but can't act on coherently (e.g. "flagged suspicious but nothing to check")
- comments hedging about what "should" be true — haziness made visible

For each candidate, name the **invariant that would remove the branching**, and whether its natural home
is *this* boundary or an **upstream** stage (root cause is often non-local).

## Phase 3 — Emit the worklist

Print a ranked table, worst leverage first. No edits, no files written — the annotated code is the
ledger; this map is transient.

```
# Invariant map — <project/subsystem>   (N boundaries, M already carry INVARIANT markers)

rank  boundary (file:sym)         symptom                              candidate invariant                       home
1     orchestrator/x.ts:dispatch  5-arm kind switch + 2 null guards     "node is terminal by here"                this
2     phases/triage.ts:analyze    catch fabricates a finding            "suspicious ⟹ a hypothesis exists"        this
3     evidence/judge.ts:judge     re-validates layers every call        "layers validated by judge-time"          UPSTREAM: sensors
...
covered: evidence/timeline.ts:renderTimeline  ("fd kind tracked")  — verified still holds
```

End with one line: which boundary you'd hand `invariant-audit` first, and why it's the highest leverage.
Do not declare the codebase "done" — rank what exists; there is always a next-worst.
