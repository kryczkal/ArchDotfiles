# invariant-audit — rules & conventions

The load-bearing rules. `invariant-audit` must obey these; `invariant-map` reads the marker convention
to detect coverage.

## The marker (how invariants are tracked)

Invariants live **in the code, at the boundary they constrain** — not in a separate doc (a doc drifts;
the code is the single source of truth). Two parts, together:

- **An assert** in the project's idiom (`node:assert`, an `invariant(cond, msg)` helper, Python `assert`,
  Rust `debug_assert!`, Go `if !cond { panic }`, etc.) — enforces the invariant so a violation fails loud.
- **A terse `// INVARIANT: …` comment** — the semantics the assert can't carry (why this holds, what it
  means). Super brief, load-bearing; never a paragraph.

`invariant-map` and later `invariant-audit` runs grep `INVARIANT:` (+ the assert idiom) to know which
boundaries are covered and to re-verify they still hold. That is the entire ledger.

Example (TypeScript):
```ts
// INVARIANT: node is terminal here — the dispatch loop only calls finalize() on resolved nodes.
assert(node.state !== "OPEN" && node.state !== "IN_PROGRESS", `finalize() on non-terminal ${node.id}`);
```

## delete-iff-asserted

A branch may be removed **only if** an assert now catches the deleted case loudly. A comment-only
invariant (assert redundant or infeasible) may document and inform, but must **never** authorize a
deletion. Rationale: if the ratified invariant is subtly wrong, the assert converts a would-be silent
corruption into an immediate, located failure. No assert covering it → keep the branch.

## Earn the deletion

User ratification authorizes *intent*; it does not authorize the *deletion*. Before removing a branch,
spawn an **independent** falsification pass (a separate agent — the context that proposed the invariant
is biased toward it) that tries to construct a reachable state violating the invariant. Proceed only on
"could not falsify". A found counterexample goes back to the user; never delete over it.

## Assert where it earns its keep (not everywhere)

Prefer an assert at the boundary when it's cheap and about *this* boundary's input/output contract.
Do **not** re-assert what an upstream invariant already guarantees — re-checking reintroduces the work
the invariant exists to remove. Hot paths: prefer a comment (+ a debug-only assert if the idiom allows).
When you skip the assert, still leave the terse `// INVARIANT:` comment.

## Incoherent state ⇒ make it unreachable

If a boundary can reach a state it cannot act on — nothing meaningful to do, nothing to check — that is
not a branch to handle, it is a hole in an invariant. Close it at the boundary (error / retry / guard)
so the state can't arrive. Handling it is ducttape; forbidding it is the invariant.

## Root cause is often non-local

The branching may be *here* while the guarantee that removes it belongs **upstream**. Fix at the stage
that *owns* the invariant, then delete the downstream branches once the upstream assert enforces it.
Adding a local guard to a symptom is exactly the ducttape being removed.

## Atomicity

Comment + assert + branch-deletion for one invariant land **together**, and typecheck + tests are green
before the next invariant. Never leave a half-applied unit (deleted branch without its assert, or a red
tree). Interruption then just means "fewer invariants covered", re-derivable from the markers.

## Scope discipline

Prioritize the worst ifology/ducttape/haziness first. This is not a blanket pass that annotates every
function's contract — only boundaries where a missing invariant is actively causing complexity. Value
is complexity removed, not annotation coverage.
