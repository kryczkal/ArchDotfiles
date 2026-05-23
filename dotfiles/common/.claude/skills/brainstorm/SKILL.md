---
name: brainstorming
description: >
  Turn ideas into committed spec files. Three phases: (1) constraint-anchored Q&A with
  devil's-advocate assumptions and cost visibility check, (2) 1-2 approaches shaped by
  constraints, (3) compressed spec written autonomously. Optimizes for asking FEWER,
  SHARPER questions — wrong questions produce wrong specs regardless of spec quality.
---

# Brainstorming Ideas Into Specs

Turn ideas into committed spec files. The Q&A phase determines everything — wrong questions produce wrong specs regardless of how well the spec is written. Fewer, sharper questions beat many generic ones.

## Flow

```
1. Read context → 2. Constraints + questions → 3. Devil's advocate → 4. Cost visibility
→ 5. Approach design (1-2, shaped by constraints) → 6. Write compressed spec → 7. Commit → 8. Show user
```

**You need the user for steps 2-4.** Everything else runs without waiting.

---

## Phase 1: Read Context

Before asking anything:
- Check relevant files, docs, recent commits, wiki
- Check `wiki/STATUS.md`, `wiki/DECISIONS.md`, `CLAUDE.md` — skip questions already answered
- Assess scope: if multi-subsystem, decompose first, then brainstorm the first piece
- Map costs: identify which operations are expensive (LLM calls, external APIs), cheap (local I/O, DB writes), or free (serialization, validation)

---

## Phase 2: Q&A (the crux — fewer, sharper questions)

### Step 1 — Constraint identification

Identify 2-3 things that CANNOT change about the system for this feature. For each, state in one sentence:
- What the constraint is
- Why it's immovable
- The ONE design decision it forces

Then ask ONE binary question per constraint — the decision the constraint forces but doesn't resolve. Prefer multiple choice when the option space is enumerable.

Constraints naturally surface the concerns that generic checklists try to catch (dependencies, operational impact, security boundaries) but with specificity. A constraint that says "the parser calls `claude -p` which costs real tokens" is more useful than "what are the cost implications?"

### Step 2 — Devil's advocate assumptions

After constraints, state 2 DELIBERATELY PROVOCATIVE assumptions. These must be:
- **Specific enough to be wrong in an interesting way** — not "this should be scalable" but "this should use a cheaper model for retries since the first attempt already proved the task is hard"
- **Designed to surface requirements the user takes for granted** — things so obvious to the user they'd never mention them
- **Targeting aspects OUTSIDE the constraints** — the constraints already caught the structural stuff; provocative assumptions probe product/UX, cost model, and behavioral expectations

The user's corrections to provocative assumptions are the highest-signal data in the entire brainstorm. They reveal requirements that reasonable questions never surface.

### Step 3 — Cost visibility check

Ask ONE question: **"How does the user know what this feature cost them to use? What should be visible?"**

This catches a systematic blind spot — every brainstorm naturally focuses on what a feature DOES, not on what it COSTS. The answer shapes whether the spec includes observability, metering, or cost feedback.

Skip this step only if the feature has no resource cost (pure refactoring, documentation, etc.).

### Rules for all Q&A

- One topic per question — no compound questions
- Skip anything answerable from codebase, docs, or wiki
- Every question must change a design decision — if the answer wouldn't change the spec, don't ask
- Total Q&A should be ~5-8 interactions. More than 10 means questions are too granular.

---

## Phase 3: Approach Design

After Q&A, autonomously design the solution. The constraints already narrowed the space.

### If constraints converge to one approach:

Design 1 approach that respects all constraints and incorporates corrections from the devil's advocate round. No alternatives needed — the constraint analysis IS the approach exploration. Document why this is the only viable approach.

### If constraints leave genuine design space:

Design exactly 2 approaches:
1. **Within constraints** — optimizes within all stated constraints
2. **Relaxes one** — relaxes the least important constraint for a meaningfully better design

For each:
- **Name:** 2-3 word label
- **Core idea:** One paragraph
- **Tradeoff:** What it optimizes vs. what it sacrifices
- **Effort:** T-shirt size (S/M/L)

Pick the winner. Document which constraint was relaxed (if any) and why that's acceptable.

### Never 3 approaches

The third approach is always padding. Constraint analysis eliminates it before you design it. If you're reaching for a third, one of your constraints is wrong.

---

## Phase 4: Write Compressed Spec

After approach selection, write the complete spec **without pausing for approval**.

### Contents

1. **Goal** — 2 sentences: what this does and what's explicitly out of scope
2. **Architecture** — diagram showing data flow and component relationships
3. **Changes** — table of `file | change` pairs, one row per file touched
4. **Key decisions** — only non-obvious choices: what, why, what else was considered. Skip decisions that trace directly to a constraint (those are already documented).
5. **Tests** — numbered list of test cases with expected behavior

### Self-review before committing

- Any TBD / TODO / vague requirements? Fill them in.
- Any internal contradictions? Fix them.
- Could a cold-start session implement from this spec alone? If not, add context.
- Does every design decision trace to a constraint, a user correction, or a cost visibility answer? If not, the decision is under-justified.
- Scope too large? Decompose into phases.

### Commit

Save to `docs/specs/YYYY-MM-DD-<topic>.md` (user preference overrides path).

---

## Phase 5: Show User

One message:

> "Spec written → `docs/specs/YYYY-MM-DD-<topic>.md`. Review and request changes, or say 'implement' to proceed."

If changes: update, re-review, re-commit, show again.
If approved: implement from spec using TaskCreate for progress tracking.

---

## Design principles

- **Constraints over checklists** — a constraint with a forced decision beats a generic "did you think about X?" every time
- **Provocation over assumption-stating** — provocative assumptions surface hidden requirements; reasonable assumptions get rubber-stamped
- **The spec is the session handoff** — complete enough for a cold-start implementation session
- **Cost visibility is not optional** — every feature has a cost model; the spec must address it
- **YAGNI ruthlessly** — remove anything not required by the stated goal
- **Compression is quality** — every section, question, and sentence must change a decision; if removing it wouldn't change the spec, remove it
