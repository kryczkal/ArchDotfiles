Explain something using a first-principles approach, reaching for **diagrams** wherever a picture carries the meaning better than prose.

Topic/target: $ARGUMENTS

If $ARGUMENTS is empty, look at the most recent topic, code, concept, or file discussed in the conversation and explain that.

If $ARGUMENTS refers to a file, function, or module in the current repo, read it first before explaining.

---

## Your explanation must follow these rules:

**Audience**: Assume zero prior domain knowledge, but assume high intelligence. Do not dumb down the logic — only the vocabulary.

**Build vocabulary bottom-up**: Explain the fundamental mechanics in plain English first. Once a concept is clearly established, introduce the correct domain-specific term for it, and then use that term going forward.

**Prioritize precision**: Simplified language must not introduce ambiguity. If a plain-English analogy fails to capture full nuance, use a detailed logical explanation instead of a convenient shortcut.

**Use these techniques**:
- **Scaffolding** — each idea builds on the last; never reference something before defining it
- **Progressive Disclosure** — start with the simplest correct version, then layer in complexity
- **Definitional Density** — pack precise meaning into terms once defined, then use them freely
- **High-Fidelity Translation** — preserve every nuance from the source; no lossy compression

## Critical constraints:

1. **NO SUMMARIZATION** — you are forbidden from omitting details, collapsing steps, or hand-waving mechanics
2. **LOSSLESS** — every fact, number, name, list item, edge case, and nuance must appear in your output
3. **EXPANSION** — your output must be longer than the source material; you are unpacking density, not reducing it
4. **NO TREE REDUCTION** — do not chunk or reduce the content hierarchically; explain it linearly and completely in one pass

---

## Reach for diagrams where they carry the load

Prose alone leaves the reader holding vocabulary they can't ground. A diagram that shows the **actual data moving through the system** grounds every term the moment it appears. Default to a diagram whenever the thing you're explaining has *structure*: a pipeline, a data flow, a transform (input → output), a state machine, an architecture, a before/after redesign, a fan-out/merge. Use prose for the parts that have no shape — a single fact, a definition, a philosophical or conceptual point. The two interleave: diagrams show the *shape*, prose supplies the *precision* and the *why*. Diagrams **supplement** the first-principles rules above; they never replace the losslessness or the bottom-up rigor.

**The house style — show DATA, not vocabulary.** This is the signature that makes these land:

- **Carry ONE concrete running example through every stage.** Pick a real instance (a specific input) and follow *it* end to end. Never say "a response object" — show the actual object with real field names and real example values.
- **Draw each stage as a labeled box with its concrete INPUT and OUTPUT.** The reader should see what goes in and what comes out at every step, in real values.
- **Define each term inline, the first time it appears, grounded in the box on screen.** "A `HypothesisDraft` = this box: `description` + `claim.kind` + `rangesInFile`." The picture *is* the definition.
- **Connect stages with arrows.** Show fan-out (one → many, e.g. per-file) and merge (many → one, e.g. dedup) visually, not in words.
- **Annotate with inline callouts.** `◀── NEW: the LLM designs this`, `⚠ this field is discarded`, `✗ deleted`, `← not in the baseline → surprising`. The callouts carry the nuance a plain box can't.
- **For a redesign, draw OLD vs NEW.** Put the before and after in the same visual frame so the delta is obvious; a `✗ deleted` / `⏸ deferred` footer names what went away and why.
- **For "who uses what," draw a contract table** — each consumer against the exact field it reads.

Minimal shape to imitate (a two-stage transform, real values):

```
┌─ INPUT: raw file ─────────────┐        ┌─ OUTPUT: analysis ───────────────────────────┐
│ setup.js  (preinstall hook)   │  ──▶   │ summary:      "harvests env + creds, POSTs"   │
│ + intent: [ENV_VARS, FS]      │        │ capabilities: [ENV_VARS, FS, NETWORK]  ← NETWORK
└───────────────────────────────┘        │                              not in intent → flag │
        LLM reads source + intent        │ hypotheses:   [ … ]                           │
                                         └───────────────────────────────────────────────┘
```

Keep boxes narrow enough to read in a terminal; prefer several small diagrams over one sprawling one; label every arrow and box. When you finish, the reader should be able to point at any box and say what it is and what flows through it — without having memorized any vocabulary first.

## Example of the quality standard (prose portions):

Original (dense): "The entity exhibits hyper-volatility due to algorithmic feedback loops."

Bad (dumbed down): "The price moves around a lot because computers go crazy." — loses precision and mechanics.

Good (first principles): "When automated systems react to data, they can sometimes trigger a reaction in other systems, creating a cycle that amplifies itself. This amplification causes the value to fluctuate rapidly and unpredictably. We call this specific type of fluctuation hyper-volatility caused by algorithmic feedback loops."
