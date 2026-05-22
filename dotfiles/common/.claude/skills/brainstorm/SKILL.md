---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Gathers requirements via Q&A, then writes full spec autonomously."
---

# Brainstorming Ideas Into Specs

Turn ideas into committed spec files. Two Q&A rounds with the user, then write the full spec autonomously.

## Flow

```
1. Read context  →  2. Q&A round 1  →  3. User answers  →  4. Q&A round 2 (deeper)  →  5. User answers  →  6. Write full spec  →  7. Commit  →  8. Show user
```

**You are needed by the user for steps 3 and 5.** Everything else runs without waiting.

## Step 1 — Read context

Before asking anything:
- Check relevant files, docs, recent commits
- Check `wiki/STATUS.md` and `wiki/DECISIONS.md` if they exist — skip Q&A questions already answered there
- Assess scope: if the request spans multiple independent subsystems, decompose first (what are the pieces, what order to build?), then brainstorm the first piece

## Step 2 — Q&A round 1 (scope & direction)

Ask every question you need to understand **what** the user wants and **why**. Focus on: goals, constraints, users, non-obvious context, what's explicitly out of scope.

Rules:
- One topic per question — no compound questions
- Prefer multiple choice when the option space is enumerable
- Surface your own assumptions — ask if they're correct
- Skip anything you can answer from codebase, docs, commits, or wiki

A long Q&A message is correct. An unanswered question becomes a wrong assumption in the spec.

## Step 3 — User answers round 1

Wait. First pause.

## Step 4 — Q&A round 2 (deeper / implementation-shaping)

Ask about **how**: tradeoffs, edge cases, priorities between competing concerns, integration points, anything that emerged from round 1 answers that needs clarification.

This round is typically shorter (3-8 questions). Ask only what would change the implementation approach if answered differently.

## Step 5 — User answers round 2

Wait. Second pause.

## Step 6 — Write full spec autonomously

After the user answers, do all of this **without pausing for approval**:

1. **Explore 3 orthogonal approaches.** Design three genuinely different implementation strategies — not variations on a theme, but different architectural bets. For each: one-paragraph description, key tradeoff, what it optimizes for.

2. **Evolve each approach (1 genetic iteration).** For each of the 3 approaches, spawn a subagent that produces 2-3 mutations (targeted improvements, hybrid with strengths of another approach, or scope reduction). Evaluate all mutations against the user's stated goals and constraints. Each approach's best mutation replaces the original.

3. **Pick the winner.** From the 3 evolved approaches, select the best. Document reasoning for why it wins. Include the runners-up in a "Rejected alternatives" section so the user can redirect if they disagree.

4. **Write the complete spec** covering:
   - Goal and scope (what's in, what's explicitly out)
   - Architecture and components
   - Data flow and interfaces
   - Error handling
   - Testing approach
   - Implementation phases if the work is large

5. **Self-review before committing:**
   - Any TBD / TODO / vague requirements? Fill them in.
   - Any internal contradictions? Fix them.
   - Ambiguous requirements? Pick one interpretation, make it explicit.
   - Scope too large for one implementation? Decompose.

6. **Commit** the spec to `docs/specs/YYYY-MM-DD-<topic>.md`
   - (User preference for path overrides this default)

## Step 7 — Show user

One message:

> "Spec written → `docs/specs/YYYY-MM-DD-<topic>.md`. Review and request changes, or say 'implement' to proceed."

If changes requested: update spec, re-run self-review, re-commit, show again.
If approved: implement from spec using TaskCreate for progress tracking.

## Design principles

**YAGNI ruthlessly** — remove anything not required by the stated goal.

**Design for isolation** — if you can't explain a unit without reading its internals, the boundary is wrong.

**Follow existing patterns** — explore codebase before proposing. No unrelated refactoring.

**Spec is the session handoff** — the spec file must be complete enough that an implementation session starting cold can execute it without any context from this conversation.
