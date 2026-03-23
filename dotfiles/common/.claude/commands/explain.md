Explain something using a first-principles approach.

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

## Example of the quality standard:

Original (dense): "The entity exhibits hyper-volatility due to algorithmic feedback loops."

Bad (dumbed down): "The price moves around a lot because computers go crazy." — loses precision and mechanics.

Good (first principles): "When automated systems react to data, they can sometimes trigger a reaction in other systems, creating a cycle that amplifies itself. This amplification causes the value to fluctuate rapidly and unpredictably. We call this specific type of fluctuation hyper-volatility caused by algorithmic feedback loops."
