---
name: brainstorming
description: >
  Turn ideas into committed spec files. Decision mapping with DESIGN/TECHNICAL triage,
  prerequisite audit, extensive Q&A with assumption correction, provocative assumptions,
  error scenarios, then autonomous spec. Optimizes for crystallizing what the user envisions —
  preferences are often latent until provoked by concrete stimulus.
---

# Brainstorming Ideas Into Specs

Turn ideas into committed spec files. Claude writes great specs and makes sound technical choices — the bottleneck is crystallizing what the user wants, which often doesn't exist as conscious thought until provoked by concrete stimulus (a stated assumption, an option with tradeoffs, a failure scenario).

The highest-value question is one where Claude's default answer would be WRONG. A question Claude would get right anyway is wasted breath. "I assume X — correct/partial/wrong?" works because seeing a wrong assumption CREATES the preference, not merely extracts it.

## Flow

```
1. Read context → 2. Map decisions (DESIGN vs TECHNICAL) → 3. Prerequisite audit
→ 4. Design Q&A (extensive) → 5. Provocative assumptions → 6. Error scenarios
→ 7. Write spec (autonomous) → 8. Commit → 9. Show user
```

**You need the user for steps 3-6.** Everything else runs without waiting.

---

## Phase 1: Read Context

Before asking anything:
- Check relevant files, docs, recent commits, wiki
- Check `wiki/STATUS.md`, `wiki/DECISIONS.md`, `CLAUDE.md` — skip questions already answered
- Assess scope: if multi-subsystem, decompose first, then brainstorm the first piece

---

## Phase 2: Map Decisions

Before asking ANY questions, map ALL decisions the feature requires. For each decision, classify:

- **DESIGN** (must ask user): UX choices, behavior, interaction patterns, data presentation, workflows, error experience, what things should look/feel like, what the user sees. If wrong answer = reimplementation, it's DESIGN.
- **TECHNICAL** (Claude decides autonomously): Architecture, libraries, data structures, algorithms, protocols, file formats. Present 3 orthogonal options in the spec and pick the best.

Show the user the decision map before starting Q&A. This gives them a preview of what you'll ask and lets them correct the DESIGN/TECHNICAL classification upfront.

The triage is the core mechanism: it stops Claude from asking about things the user doesn't care about (technical details), and ensures Claude asks about everything the user DOES care about (how it works from their perspective).

---

## Phase 3: Prerequisite Audit

BEFORE asking design questions, audit what you're assuming:

1. **Data availability:** For each DESIGN decision, what data does the feature need? Does that data exist today in the codebase/system in a structured, parseable form? If not, flag the gap.
2. **System interactions:** What existing features, skills, tools, or processes does this feature interact with? List each and note the interaction type (reads from, writes to, shares logic with, replaces).
3. **Assumptions inventory:** What are you assuming about the system that you haven't verified from the code? State each assumption explicitly.

Present the audit to the user: "Before design questions, some prerequisites to verify..." The user's corrections to wrong assumptions prevent the entire Q&A from being built on false premises.

This step catches system-level gaps that no amount of design questioning surfaces — like assuming a compile pipeline is a script when it's actually a prompt, or assuming data exists when it doesn't.

---

## Phase 4: Design Q&A (the crux — extensive, targeted)

Ask DESIGN decisions one at a time, starting with the highest reimplementation cost. For each:

- Provide **2-3 concrete options** with tradeoffs (never open-ended "what do you want?")
- **State your assumption** for CORRECT / PARTIAL / WRONG correction — this format is critical because PARTIAL corrections reveal where your mental model diverges from the user's intent
- One topic per question — no compound questions
- Skip anything answerable from codebase, docs, or wiki

**No cap on interactions.** Ask until ALL design decisions are resolved. The Q&A is extensive when every question targets a potential mind-reading gap. It's too long only if questions are about things the user doesn't care about (those should be TECHNICAL).

Every question must pass this test: **"Would Claude confidently pick the wrong answer here?"** If yes, ask. If Claude would get it right, don't waste the user's time.

---

## Phase 5: Provocative Assumptions

After all design questions, state 2 DELIBERATELY PROVOCATIVE assumptions. These must be:
- **Specific enough to be wrong in an interesting way** — not "this should be scalable" but "this should use a cheaper model for retries since the first attempt already proved the task is hard"
- **Designed to surface requirements the user takes for granted** — things so obvious to the user they'd never mention them
- **Targeting aspects OUTSIDE the Q&A** — the Q&A already caught the structural stuff; provocative assumptions probe product vision, cost model, and behavioral expectations the user assumed were obvious

The user's corrections to provocative assumptions are the highest-signal data in the entire brainstorm. They reveal requirements that reasonable questions never surface.

---

## Phase 6: Error Scenarios

After provocative assumptions, walk through 2-3 failure scenarios specific to this feature. Pick the scenarios most likely to reveal a design decision the Q&A missed:

- What happens when the input data is malformed or missing?
- What happens when the operation is interrupted midway?
- What happens when two components disagree about state?

Keep this brief — 2-3 scenarios, not a full checklist. Ask the user about each. These catch edge cases that abstract design questions never surface (e.g., "should the state file be written atomically?" only emerges when you walk through "what if compile crashes mid-run?").

Do NOT re-ask about data availability already covered in the prerequisite audit. The user will push back on redundancy.

---

## Phase 7: Write Spec

After Q&A, write the complete spec **without pausing for approval**.

### Approach Selection (autonomous)

Design 3 genuinely orthogonal approaches — different architectural bets, not variations on a theme. For each: one-paragraph description, key tradeoff, what it optimizes. Pick the winner with reasoning. Include rejected alternatives so the user can redirect if they disagree.

### Spec Contents

1. **Goal** — 2 sentences: what this does and what's explicitly out of scope
2. **Architecture** — diagram showing data flow and component relationships
3. **Changes** — table of `file | change` pairs, one row per file touched
4. **User-confirmed decisions** — table of design decisions from Q&A with the user's choice
5. **Technical decisions** — for each TECHNICAL decision: 3 orthogonal options, your pick, and why
6. **Tests** — numbered list of test cases with expected behavior

### Self-review before committing

- Any TBD / TODO / vague requirements? Fill them in.
- Any internal contradictions? Fix them.
- Could a cold-start session implement from this spec alone? If not, add context.
- Does every design decision trace to a user answer, a provocative assumption correction, or an error scenario finding? If not, the decision is under-justified.
- Scope too large? Decompose into phases.

### Commit

Save to `docs/specs/YYYY-MM-DD-<topic>.md` (user preference overrides path).

---

## Phase 8: Show User

One message:

> "Spec written → `docs/specs/YYYY-MM-DD-<topic>.md`. Review and request changes, or say 'implement' to proceed."

If changes: update, re-review, re-commit, show again.
If approved: implement from spec using TaskCreate for progress tracking.

---

## Design principles

- **Bridge the mind-reading gap** — the only purpose of Q&A is to learn what Claude can't figure out from the code. Every question should target a potential divergence between Claude's default and the user's vision.
- **Triage ruthlessly** — DESIGN questions (ask the user) vs TECHNICAL decisions (Claude handles). Asking a technical question wastes the user's time. Missing a design question wastes their implementation.
- **Correction over inquiry** — "I assume X — correct/partial/wrong?" surfaces divergences faster than "what do you want?". PARTIAL corrections are the highest-signal data.
- **Provocation over assumption-stating** — provocative assumptions surface hidden requirements; reasonable assumptions get rubber-stamped
- **Audit before, probe after** — prerequisite audit catches wrong premises before Q&A; error scenarios catch edge cases after. Don't re-ask what the audit already covered.
- **The spec is the session handoff** — complete enough for a cold-start implementation session
- **YAGNI ruthlessly** — remove anything not required by the stated goal
