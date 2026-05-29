---
name: evolve-pipeline
description: >
  3-pass skill evolution pipeline: representative (fix quality gaps) → adversarial
  (fix edge cases) → differential (fix ambiguity). Each pass catches what the others miss.
  3x compute, 3x non-overlapping improvements. Use on production skills that matter.
  Invoke with /evolve-pipeline <skill-name>.
argument-hint: <skill-name>
effort: max
---

# Evolve Pipeline — Three-Pass Skill Evolution

Three complementary evolvers in sequence. Each targets a different failure class:
1. **Representative** — find the weakest section on typical inputs, fix it
2. **Adversarial** — find the worst-case input that breaks the skill, fix it
3. **Differential** — run twice, diff, fix ambiguous wording that causes inconsistent output

Confirmed: zero overlap between passes on 2 production skills (security-audit, brainstorm).

---

## Pass 1: Representative (ultimate-final)

Read the target skill. Decompose into sections. Run on a typical test input. Score the output. Find the ONE weakest section via attribution. Apply skeptic filter ("someone against this change would say..."). Rewrite only if the skeptic loses. Re-run and keep if improved, rollback if not.

## Pass 2: Adversarial

Take Pass 1's evolved skill. Find the realistic worst-case input — the kind of input a real user would provide that would cause the skill to fail. Realistic means: inputs a practitioner would encounter in normal use, not synthetic inputs constructed specifically to defeat the skill. Categories: ambiguity/overload, false-positive bait, missing category, boundary case. Run the skill on the adversarial input. Attribute the failure to a specific section. Fix with a one-sentence clarification. Dual-verify: adversarial input improved AND typical input still works.

## Pass 3: Differential

Take Pass 2's evolved skill. Run it twice on the same input, independently. Diff the outputs. For each material divergence, trace to the exact ambiguous phrase in the skill. Fix with a one-sentence clarification that collapses the ambiguity. Verify on both typical and adversarial inputs that the skill now produces consistent output.

## Output Cap

After all 3 passes, if the evolved skill produces more than 3 findings/changes on a test input, rank by severity/impact and drop the rest. The pipeline discovers broadly; the cap enforces discipline. Without it, 3 passes produce 6 marginal findings instead of 3 strong ones.

## Report

After all 3 passes, report:
```
Pass 1: [section] — [what was fixed] — [kept/rolled back]
Pass 2: [section] — [what was fixed] — [kept/rolled back]
Pass 3: [N divergences] — [N fixed] — [kept/rolled back]
Net change: [N lines added/removed]
```
