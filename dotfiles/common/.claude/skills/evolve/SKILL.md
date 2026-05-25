---
name: evolve
description: >
  Improve a skill by decomposing it into sections, finding the ONE weakest, and fixing it
  only if the fix survives a skeptic filter. Default action: no change.
  Invoke with /evolve <skill-name>.
argument-hint: <skill-name>
effort: max
---

# Evolve

Fuses decomposition-only + restraint-first (both 66/75 co-champions).
Section decomposition with attribution. Skeptic filter. ONE-weakness focus. Default: no change.

## Step 1: Decompose

Read the target skill's SKILL.md. Detect the lowest heading level present (`##`, `###`, or `#` if no sub-headings exist). List every section at that level as a numbered unit:

```
S1: <heading> — lines N-M
S2: <heading> — lines N-M
...
```

This is the section register. All subsequent steps operate on this register.
If the register is empty (no headings found), stop — the skill cannot be decomposed.

## Step 2: Run

Pick one test input that exercises the skill's core path. Choose the input that makes the
most instruction-lines in the target skill load-bearing — prefer inputs where skipping any
section would produce a materially worse output. Run the skill by following its instructions.
Record the full output. Mark each section as active or skipped.

## Step 2b (optional): Adversarial hardening

If all active sections performed well on the representative input (no section scores above 1
in attribution), try the HARDEST realistic input instead — an edge case, boundary condition,
or degenerate input the skill must handle in production. Re-run. If still no weakness, proceed
to Step 3 (which will exit cleanly).

## Step 3: Find the ONE weakest section

Score the output on four dimensions (0-3 each):

1. **Goal achievement** — did the output accomplish what was asked?
2. **Signal density** — is content load-bearing, or padding?
3. **Actionability** — can a reader act on this directly?
4. **Precision** — are claims specific, or vague and hedged?

Total: /12. Write one sentence naming the single biggest quality gap.

For each active section, score attribution (0 = no contribution to the gap, 3 = primary cause):

```
S1: 0 — worked correctly
S2: 2 — caused the gap because [reason]
S3: 1 — minor contributor
```

**Clean exit:** If no section scores above 1 on attribution, stop. Report "No significant
weakness found — skill is performing well on this input." This is a valid outcome. Do not
manufacture findings when the skill is structurally sound.

The highest-scoring section is the **target**. Ties: pick the earlier section (upstream
failures propagate). ONE section only. A list means you haven't prioritized.

## Step 4: Apply the skeptic filter

Before writing any change, state: "Someone AGAINST this change would say: [X]."

- If you cannot articulate a reasonable objection, re-examine — the change is either
  obvious (already would have been made) or you haven't found the real weakness.
- If the objection is stronger than your case, stop. Write "No change warranted." This
  is a valid outcome. The baseline evolver scored 55/75 by always changing something.

## Step 5: Rewrite the target section

Rules:
- Fix what attribution identified. Nothing else.
- Preserve section boundaries — same content scope as before.
- Surgical changes only. Vague instruction? Make it concrete. Missing constraint? Add it.
  Do not expand scope beyond what attribution identified.
- Do not touch any other section.
- Do not add new sections. The mechanism is fixing existing sections, not adding structure.

## Step 6: Re-run and compare

Run the skill again on the same test input with the rewrite in place. Produce the FULL
output — not a summary, not a mental simulation. The re-run output must appear in your
response as a quoted block or artifact before scoring. A "mental re-run" or imagined
result is fabrication.

Score the re-run output on the same four dimensions. Compare:

- New total > old total: **keep**
- New total = old total but quality gap changed: **keep** (different failure = original fixed)
- New total < old total: **roll back**

If the re-run would exceed context limits (target skill produces very long output), run it
on a SMALLER input that still exercises the changed section, and note the scope reduction.

## Step 7: Report

Output exactly this (the Score line must match scores computed FROM the re-run output above — if no re-run output exists in this response, the evolution is invalid):

```
Target section: S[n] — <heading>
Attribution: <one sentence>
Skeptic: <the objection and why your case was stronger>
Change: <one sentence>
Re-run output: [present above | scope-reduced: <reason>]
Score: [old]/12 -> [new]/12
Decision: kept | rolled back | no change warranted | no weakness found
```

If rolled back, add one sentence on what the rewrite got wrong.

Stop. One section, one fix, one verdict.

## Anti-patterns

- Do not rewrite multiple sections. Attribution exists to prevent this.
- Do not rewrite skipped sections — no execution means no signal.
- Do not expand scope beyond what attribution identified.
- Do not manufacture weaknesses when attribution shows none above 1.
- Do not add process logs — the Step 7 report is the only process output.
