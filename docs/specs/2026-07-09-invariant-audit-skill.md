# Spec — Invariant-driven code simplification (a `code-quality` sibling)

_Status: implemented · 2026-07-09 · brainstormed → built_

Two skills that drive code toward **clean per-stage invariants**, so branching / ducttape / haziness
shrink because the states that caused them become unreachable — not because they were patched.

## Goal

A sibling family to `code-quality`. Where `code-quality` fixes blemishes against external standards,
this fixes the code's **state-space**: it finds where a *missing invariant* is the root cause of
ifology, establishes the invariant at the boundary that owns it (as a runtime assert + a terse
load-bearing comment), and deletes the branches the invariant makes dead. The user ratifies every
invariant after having its logic explained; the skill still has to *earn* each deletion by failing to
falsify the invariant. **Out of scope:** blanket documentation of every function contract; style/bug
fixing (that's `code-quality`); anything that doesn't reduce reachable-state complexity.

## The two skills

Per-invariant confirmation is attention-gated, so "fix the whole app in one run" is impractical.
The family splits mapping (cheap, whole-app, read-only) from fixing (one boundary per run, looped):

```
invariant-map  (read-only, whole-app)          invariant-audit  (one boundary/run, /loop-friendly)
────────────────────────────────────           ──────────────────────────────────────────────────
discover stages + boundaries                    pick highest-leverage boundary (arg, or auto-scan)
score each by ifology/ducttape/haziness   ──►   map candidate invariants at that boundary
grep existing in-code invariant markers         for each candidate, judgment-scaled:
emit a leverage-ranked worklist (printed)          explain logic (via `explain` skill) → confirm
NO edits                                           → adversarially falsify → if survives:
                                                     apply atomically: assert (where it earns it)
                                                     + terse load-bearing comment; delete a branch
                                                     ONLY if an assert now covers the deleted case
                                                   run tests+typecheck green → next candidate
                                                never declares global "done" — always next-worst
```

The annotated code is the ledger: markers live in code (`invariant(...)` / `// INVARIANT:`), so a later
run greps them to see coverage and re-verify — no separate state file to drift.

## Architecture — symptom-first (the chosen bet)

The skill starts from **symptoms** (dense/defensive branching, catch-and-fabricate, deep nesting,
repeated null/kind guards), traces each to the missing invariant, and fixes it at the owning stage.
It does **not** build a formal boundary graph or annotate every contract. Rationale below (Technical
decisions). This keeps the *skill itself* simple — a scalpel, not a framework — which is the same
principle it enforces on the target code.

Root cause can be non-local: if the ifology is *here* but the invariant belongs two stages upstream,
the fix is applied at the **owning** stage and that boundary is added to the worklist — never a local
band-aid guard.

## Changes

Skills live in `ArchDotfiles/dotfiles/common/.claude/skills/` (symlinked to `~/.claude/skills/`).

| file | change |
|---|---|
| `…/.claude/skills/invariant-map/SKILL.md` | **NEW.** Read-only whole-app mapper: discover stages/boundaries, score by symptom density, grep existing invariant markers, print a leverage-ranked worklist. `effort: medium`. |
| `…/.claude/skills/invariant-audit/SKILL.md` | **NEW.** One boundary/run fixer: map candidate invariants → per-invariant explain→confirm→falsify→apply (atomic, assert+comment, delete-iff-asserted) → tests green. Loop-friendly. `effort: max`, `argument-hint: [boundary-or-path]`. |
| `…/.claude/skills/invariant-audit/reference.md` | **NEW.** The invariant-marker convention + the "delete-iff-asserted", "earn-the-deletion", incoherent-state, non-local-root-cause and atomicity rules, shared by both skills. |

## User-confirmed decisions

| decision | choice |
|---|---|
| Per-invariant flow | **explain → confirm → apply**, one invariant at a time. The user ratifies before any edit. |
| Scope / family | Whole-app **mapper** (read-only worklist) + per-boundary **audit** loop. |
| Where invariants live | **In the code**, at the boundary — assert + terse comment. No separate registry doc. |
| Enforcement form | **Assert where it earns its keep** (precondition/postcondition that fails loud); comment otherwise (assert redundant/infeasible). **Always** add a super-brief, load-bearing comment for the semantics an assert can't convey. |
| Explain trigger | **Scales with judgment** — obvious invariants stated in one line; only genuine legal-state judgment calls get the full `explain`-the-logic treatment. |
| Tracking across runs | **Annotated code is the ledger** — grep markers; mapper worklist is transient. |
| Earning a deletion (provocative #1) | Ratification is necessary, not sufficient. Before deleting a branch, the skill **tries to falsify** the invariant (search for a reachable violating state); if it finds one, it refuses and returns to the user. |
| Prioritization (provocative #2) | **Always** work the worst ifology/ducttape/haziness first. Never declares "clean, done" — when the worst is cleared, find the next improvement. Not a blanket-annotation pass. |
| Wrong ratification (failure #3) | **Delete-iff-asserted**: a branch may be removed only if an assert now catches the deleted case loudly. Comment-only invariants inform but never authorize a deletion. |
| Non-local root cause (failure #4) | Fix at the **owning** (upstream) stage; add that boundary to the worklist. No local band-aid. |
| Interruption (failure #5) | **Atomic per invariant**: comment + assert + branch-deletion land together; tests/typecheck green before the next. Half-applied units are never left. |

## Technical decisions (Claude's call — 3 orthogonal options each)

**Overall architecture** — (a) boundary-graph-first: build a formal stage/edge graph, attach contracts to edges; (b) **symptom-first: start from ifology symptoms, trace to the missing invariant** ✅; (c) contract-first: annotate every function's pre/post. → **(b)**. It matches "always work the worst area," keeps the skill itself KISS (no graph framework — Occam applied to the tool), and every action traces to a concrete complexity reduction. (a) makes the tool complex to solve a simple targeting problem; (c) is the rejected paint-roller.

**Symptom detection** — (a) pure LLM read (judge density by eye); (b) **cheap structural signals + LLM triage** ✅ (grep for deep nesting, `catch`-that-fabricates, repeated `?.`/`== null`/kind-switches, long boolean guards; LLM ranks); (c) full cyclomatic-complexity tooling per language. → **(b)**: language-agnostic, no per-stack tooling, good-enough ranking; the LLM confirms leverage.

**Invariant marker** — (a) bare comment `// INVARIANT:`; (b) **project-idiomatic assert helper + `// INVARIANT:` comment** ✅ (`node:assert` / `invariant()` / language equivalent, discovered from the stack); (c) a custom decorator/annotation. → **(b)**: executable where it earns it, greppable, matches the "assert + terse comment" decision.

**Adversarial falsification** — (a) inline self-check; (b) **spawn an independent sub-agent** to try to construct a reachable state violating the invariant (reads callers/paths, reports a counterexample or "could not falsify") ✅; (c) property-test generation. → **(b)**: independence is the point (the same context that proposed the invariant is biased toward it); cheaper than (c) and language-agnostic.

**Model/effort** — mapper `medium`; audit `max` (the reasoning + falsification are the hard part).

## Tests (skill behaviors to validate on a real repo)

1. **Map ranks by leverage.** On a repo with one heavily-branched module and clean ones, `invariant-map` puts the branched module top and prints existing invariant markers as covered.
2. **Explain fires only on judgment calls.** A trivial precondition is stated in one line; a "which states are legal here" call triggers a full `explain` before the confirm prompt.
3. **Delete-iff-asserted holds.** When the user ratifies an invariant but the skill applies it as comment-only (assert infeasible), it does **not** delete the guarded branch. With an assert, it does.
4. **Earned deletion.** Given a ratified-but-false invariant (a real violating path exists), the falsification sub-agent finds the counterexample and the skill refuses the deletion, returning to the user.
5. **Non-local fix.** Ifology at stage B whose cause is a missing guarantee at stage A → the assert+comment land at A, and B's branches are removed only after A enforces it.
6. **Atomicity.** After each applied invariant, the project's test+typecheck suite is green; interrupting between invariants leaves a compiling, passing tree with fewer (not partial) invariants.
7. **Coherence rule.** A boundary that can reach a state it can't act on (the triage "suspicious ⟹ hypothesis" shape) is fixed by making the state unreachable (error/guard), not by adding a handler branch.
8. **Loop-friendly.** Run under `/loop`, consecutive runs pick different (next-worst) boundaries via the in-code ledger; no "done" wall.
