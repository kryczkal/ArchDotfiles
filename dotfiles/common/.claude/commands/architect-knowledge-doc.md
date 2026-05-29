Generate an architecture knowledge document for the `/architect` skill.

Topic: $ARGUMENTS

This is NOT a technology guide or a production code guide. It is a **reasoning framework** — a document that teaches an AI architect how to think about a specific aspect of system design. The quality of the `/architect` skill depends entirely on the quality of these documents.

## 1. Research (do NOT skip)

You are distilling how the best architects in the world reason about this specific design concern. The research must be rigorous.

### Sources to study, in priority order

**a) Canonical texts and seminal work**

Identify the foundational papers, books, and talks for this topic. Go to the primary sources — not summaries, not blog post retellings. Extract the actual reasoning frameworks, not just the conclusions.

Examples by topic area:

- Coupling/Cohesion → Parnas "On the Criteria To Be Used in Decomposing Systems into Modules" (1972), Constantine & Yourdon "Structured Design" (1979), Ousterhout on information leakage
- Responsibility → Wirfs-Brock "Responsibility-Driven Design", Beck & Cunningham CRC cards, "Tell Don't Ask"
- Data flow/State → Hickey on state and identity, event sourcing literature, Kleppmann "Designing Data-Intensive Applications"
- Dependencies → Martin "Clean Architecture" (dependency rule), Lakos "Large-Scale C++ Software Design" (physical dependency), Acyclic Dependencies Principle
- Simplicity → Hickey "Simple Made Easy" (2011), Ousterhout "A Philosophy of Software Design" (2018), Brooks "No Silver Bullet" (essential vs accidental complexity)
- Domain → Evans "Domain-Driven Design" (2003) strategic design chapters, Vernon "Implementing DDD", Conway's Law literature
- Evolution → Ford & Parsons "Building Evolutionary Architectures" (2017), Feathers "Working Effectively with Legacy Code" on seams

**b) Top engineering organizations' published practices**

Search for how these organizations approach the specific design concern:

- Google (design docs, architecture reviews, code health)
- Amazon (PR/FAQ, two-pizza teams, service ownership)
- Stripe (API design, system decomposition)
- Meta (system design interviews reveal their architectural thinking)
- Netflix (chaos engineering, resilience patterns, microservice architecture)
- Shopify (modular monolith reasoning, domain decomposition)
  (And similar big ones)

Look for their engineering blog posts, published guidelines, conference talks, and open-source architecture decision records.

**c) Real-world case studies**

Find published accounts of systems that got this specific concern right or wrong:

- Post-mortems where structural problems caused outages or development paralysis
- Architecture retrospectives ("what we'd do differently")
- Migration stories (monolith-to-microservices, library extractions, rewrites) — these reveal what the original architecture got wrong
- Conference talks by senior engineers reflecting on architectural decisions

**d) Major open-source projects**

Study how well-architected open-source projects handle this concern:

- Linux kernel, PostgreSQL, SQLite — for deep architectural reasoning in long-lived systems
- Kubernetes, Envoy — for distributed system architecture
- VS Code, Blender — for application architecture
- Their RFCs, mailing list discussions, and design documents often contain richer reasoning than the code itself

Run research in parallel using multiple agents to maximize coverage and depth.

## 2. Synthesis: Extract Reasoning, Not Facts

Before writing, distill your research into:

1. **The core analytical procedure** — what does an expert actually do, step by step, when evaluating this concern in a system? Not what they know — what they do.
2. **The diagnostic questions** — what specific questions, asked about a specific system, reveal problems in this area?
3. **The structural patterns** — what does "good" and "bad" look like at the system level (not code level)?
4. **The failure modes** — how does this concern typically go wrong, and what does the team feel when it does?
5. **The tradeoffs** — where does over-applying this concern cause harm? Every principle has a failure mode when taken too far.

## 3. Document Structure

### Header

```markdown
# [Topic Name]: Reasoning Framework

**Source canon:** [key sources, 3-5 most important]
**Applies when:** [what you're looking for when you reach for this framework]
```

### Section 1: What This Framework Addresses

One to two paragraphs:

- What aspect of system design this covers
- What symptoms suggest this framework is relevant (the "reach for this when you see..." trigger)
- What this framework can and cannot tell you (scope boundaries)

### Section 2: Core Reasoning Procedure

The heart of the document. A step-by-step analytical procedure. Written as actions:

- "Start by identifying all module boundaries in the system"
- "For each boundary, trace what information crosses it"
- "Classify each crossing as [categories]"
- "When you find pattern X, investigate Y because..."

This section should be specific enough that following it mechanically still produces useful insights. But each step must also explain WHY it matters, so the reader can adapt when the situation doesn't fit the template.

The procedure should build up to a conclusion: after completing these steps, you should be able to articulate [what the structural situation is] and [where the problems lie].

### Section 3: Diagnostic Questions

15-25 questions that an architect should ask when applying this framework. Each question must:

- Be **answerable about a real system** (not theoretical — you should be able to point at modules and answer it)
- Have a **clear healthy vs unhealthy answer** (describe what each looks like)
- **Reveal structural problems** when the answer is unhealthy
- Be ordered from most fundamental to most subtle

Format:

```
**Q: [The question]**
Healthy: [what a good answer looks like]
Unhealthy: [what a problematic answer looks like — and what it implies]
```

### Section 4: What Good Looks Like vs What Bad Looks Like

10-15 pairs of structural descriptions. NOT code examples — describe the shapes, relationships, flows, and responsibilities at the system/module level.

For each pair:

- **Bad:** Describe the problematic structure. Be specific about what makes it bad — not just that it's "tightly coupled" but what the coupling looks like and what problems it causes in practice.
- **Good:** Describe the healthy structure. Explain what it enables — not just that it's "loosely coupled" but what that looseness lets the team do.
- **Gravity:** Why teams end up at the bad structure. What force pulls them there? (This is critical — if you don't understand why the bad pattern exists, your recommendation to avoid it is naive.)

### Section 5: Common Failure Modes

8-12 specific ways this design concern goes wrong in real systems. For each:

- **Pattern:** What the system looks like (structural description)
- **Symptom:** What pain the team experiences (observable consequences)
- **Root cause:** Why this pattern formed (the force that created it)
- **Direction:** What structural change addresses it (architectural, not implementation)
- **Over-correction risk:** How fixing this problem too aggressively creates a new one

The over-correction risk is important. "Reduce coupling" taken too far produces a system of isolated modules that can't coordinate. "Increase cohesion" taken too far produces god modules. Every correction has a failure mode.

### Section 6: Interactions With Other Frameworks

How this concern connects to the other architecture knowledge areas. Real architectural problems don't respect neat categories — a coupling problem is often also a responsibility problem is often also a testability problem.

For each interaction:

- How problems in this area manifest in the other area
- How fixing this area's problems can accidentally create problems in the other
- How to analyze the intersection

### Section 7: Sources and Further Reading

The most valuable sources that informed this doc. NOT a bibliography — annotated references:

- What the source is
- Which specific section/chapter/segment is most valuable
- What unique insight it provides that the other sources don't

Prioritize depth over breadth. 5 deeply annotated sources are better than 20 listed titles.

## 4. Quality Standards

- **Length:** 300-700 lines. Dense and actionable. Every line should earn its place.
- **No code examples.** This is about system structure, not implementation. Use structural descriptions, text-based diagrams if helpful, and module-level examples. If you catch yourself writing code, zoom out.
- **First-principles throughout.** Every "do this" must come with "because of this." The reasoning is more important than the rule — rules can be wrong in context, but correct reasoning adapts.
- **Grounded in reality.** Prefer case studies, post-mortems, and observations from real systems over theoretical frameworks. If a principle sounds good in theory but has no backing from practice, note that explicitly.
- **Honest about limits.** Every design principle fails when over-applied. State where the principle breaks down and what the opposite failure mode looks like.
- **Opinionated with receipts.** When schools of thought diverge, pick the one with the strongest practical support and explain why. Mention the alternative and what it gets right.
- **Readable under pressure.** An architect consulting this doc during a live review should be able to find what they need in 30 seconds. Use clear headings, scannable formatting, and front-load the most important content in each section.

## 5. Write the Document

Write to `.claude/skills/architect/$ARGUMENTS.md` — using a lowercase-hyphenated slug derived from the topic name (e.g., `coupling-cohesion.md`, `data-flow-state.md`, `simplicity-complexity.md`).

The file is placed in the architect skill directory so it's automatically loaded when `/architect` is invoked.

## 6. Verify

After writing, re-read the document and verify:

- [ ] Core reasoning procedure is specific enough to follow mechanically, yet explains enough to adapt
- [ ] Diagnostic questions total 15-25, each answerable about a real system
- [ ] Good vs bad section has 10+ pairs with gravity explanations
- [ ] Failure modes section has 8+ entries, each with over-correction risk
- [ ] No code examples anywhere (structural descriptions only)
- [ ] Every recommendation has a "because" — no unjustified rules
- [ ] Interactions section connects to at least 3 other framework areas
- [ ] Sources section is annotated, not just listed
- [ ] Total line count is 300-700
- [ ] Dense — no filler paragraphs, no restating what was just said

Report the final file path and line count.
