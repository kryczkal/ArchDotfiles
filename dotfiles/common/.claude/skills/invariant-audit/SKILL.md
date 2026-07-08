---
name: invariant-audit
description: Drive ONE code boundary toward a clean invariant. Find where a missing invariant causes branching/ducttape/haziness, explain the logic, confirm the invariant with the user, adversarially verify it, then enforce it as an assert + a terse load-bearing comment and delete the branches it makes dead. One boundary per run, /loop-friendly. Sibling to code-quality — it simplifies by establishing invariants (shrinking the reachable state-space), not by patching symptoms.
argument-hint: [boundary-or-path (optional)]
effort: max
---

# Invariant Audit (one boundary, explain → confirm → earn → apply)

You simplify code by establishing **invariants at a stage boundary** so the states that caused its
branching/ducttape/haziness become **unreachable** — the branches then delete themselves. You work
**one boundary per run** and are safe to `/loop`. Read `reference.md` in this directory first — it holds
the non-negotiable rules (marker, delete-iff-asserted, earn-the-deletion, coherence). The philosophy:
an invariant shrinks the reachable-state set, and complexity scales with reachable states, so each real
invariant collapses complexity combinatorially. A simple solution to a complex problem is the goal;
ducttape is the symptom of a missing invariant.

## Phase 1 — Pick the boundary

- If `$ARGUMENTS` names a boundary/path, use it. Otherwise scan for the **highest-leverage** boundary
  (the densest ifology/ducttape/haziness whose cause is a missing invariant) — or run `invariant-map`
  first and take its top row.
- Build minimal context: read the boundary's file, its direct callers (the states that actually reach
  it), and the stage that *feeds* it. Learn the project's lint/typecheck/test commands.
- Print the chosen boundary early so a loop log shows it.
- **Never declare the codebase done.** Always work the current worst; when the worst is genuinely
  clean, the next-worst is the target. There is always a next improvement.

## Phase 2 — Name candidate invariants

For the boundary, list the invariants that, if guaranteed, would remove its branches. For each, note:
what states it excludes, which branches become dead, and whether its home is **here** or **upstream**
(if upstream, the fix lands at the owning stage and you add that boundary to your worklist — never a
local band-aid guard).

## Phase 3 — Per invariant: explain → confirm → earn → apply

Do these **one invariant at a time**, atomically. Never batch.

1. **Explain — scaled by judgment.** If the invariant is obvious/mechanical, state it in one line. If
   the *set of legal states* is a genuine design decision (only the user can say which states are
   allowed), invoke the **`explain` skill** on the boundary's logic first — explain it as if the user
   didn't know the code — so they understand what they're ratifying, not just approve a claim.
2. **Confirm.** Ask the user to ratify the invariant (`correct / partial / wrong`). A `partial` reveals
   where the legal-state set differs from your model — take it seriously.
3. **Earn the deletion.** Ratification is necessary, not sufficient. Before removing any branch,
   **try to falsify** the invariant: spawn an independent check (an Explore/general agent) that hunts
   for a reachable state violating it — a caller, a path, an input. If it finds a counterexample, do
   **not** delete; bring it back to the user. Deleting a branch is the one dangerous op; "the human was
   sure" is exactly how load-bearing branches get removed.
4. **Apply atomically.** If it survives:
   - Enforce with an **assert where it earns its keep** (a precondition/postcondition that fails loud),
     using the project's idiom. Add a **super-brief, load-bearing comment** for the semantics an assert
     can't carry — never long, always the "why/what it means". Both together (see `reference.md`).
   - **Delete a branch only if an assert now catches the deleted case loudly** (delete-iff-asserted).
     A comment-only invariant may document and inform but must **not** authorize a deletion.
   - If the state is *incoherent* (the boundary can reach something it can't act on), the fix is to make
     it **unreachable** (error/guard at the boundary), not to add a handler branch.
   - Run the project's **typecheck + tests**; they must be green before the next invariant. A half-applied
     unit (branch deleted, assert missing; or tests red) is never left behind.

## Phase 4 — Report

State, per invariant: the invariant, its enforcement (assert / comment / both), branches removed, net
lines removed, and any counterexample that blocked a deletion. Note the boundary's remaining leverage
and what you'd target next run. The annotated code is the ledger — the next run greps `INVARIANT:` to
see coverage; you write no state file.
