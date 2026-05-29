---
name: production-doc
description: >
  Generate a production-ready guide document. Calibrates to the user's existing
  docs and codebase, discovers the technology's unique differentiators, then
  priority-ranks sections to produce a comprehensive reference with zero padding.
  Guides are 1,000-3,500 lines with complete code examples cited from real repos.
argument-hint: <topic — e.g. "Hono", "KMP Testing", "Zod", "Docker Sandboxing">
effort: max
---

# Production Guide Generator

Generate a production-ready guide document.

Topic: $ARGUMENTS

## 1. Calibrate to Context (do NOT skip)

Before external research:

- **Read existing production docs** in `docs/` or equivalent (PRODUCTION_*.md). These define your format, tone, and depth. Match them exactly.
- **Read the repo's source code** that uses this technology. Understand the user's current patterns, what they do well, and where there are gaps.
- **Identify overlap**: What do existing guides already cover? Your guide must not repeat it. If the JS guide covers error handling generically, your framework guide covers only framework-specific error patterns.

## 2. Web Research — this is the core of the skill (do NOT skip or fake)

The entire value of a production doc is knowledge that is NOT in your training data. You MUST use WebSearch and WebFetch to find real, current information. Do NOT write from memory. Do NOT cite repos you haven't actually read in this session.

**Run research in parallel using multiple agents to maximize coverage.**

**If WebSearch or WebFetch are unavailable** (tool error, permission denied, or consistent empty results): produce the document anyway, label every section heading with `[UNVERIFIED — web research unavailable]`, mark each pattern with `[source: training data — verify before publishing]`, and append a "Verification Required" section listing 5-8 specific URLs to fetch before treating the guide as production-ready. Do not silently omit this disclosure. A labeled draft is more useful than no output.

### 2a. Start with research-requiring questions

List 5-10 specific questions about production use of this technology. Questions must target one of three research-requiring categories: (1) version-specific changes in the last 12 months, (2) community conventions that differ from the official docs, or (3) production failure modes not covered in the changelog. Examples:
- "What changed between v3 and v4 that affects how I should use this?"
- "How do teams with 50+ files organize their [technology] code in ways the docs don't mention?"
- "What production failures are reported in GitHub issues that the changelog doesn't document?"

These questions drive your research. A question answerable entirely from the official docs or a basic tutorial is the wrong question — the guide doesn't need it.

### 2b. Find apps that USE this technology (not repos ABOUT it)

This is where most research fails. Searching for "awesome-[technology]" or "[technology] best practices" finds documentation repos, template repos, and tutorial repos — NOT production code.

Instead, search for **apps that happen to use this technology**. Use the technology's most specific importable identifier (e.g., `from 'bun:test'`, not just `bun`) to find apps using this exact API, not just the broader ecosystem:
- `"from '[technology]'" OR "import [technology]" site:github.com` — finds code that imports it
- Search GitHub code search for `filename:package.json "[technology]"` to find real projects
- Look at the technology's GitHub discussions/issues — real users link their repos when asking questions
- Check who's using it: `"[technology]" site:github.com stars:>100` then look at their `src/` not their `README`

For each promising repo, use **WebFetch** to read 2-3 ACTUAL SOURCE FILES — the files where the technology is used, not the README. Record: (1) repo URL, (2) files read, (3) patterns found.

### 2c. Read official docs and check for currency

- **WebFetch** the official docs — API reference, guides, changelog/releases page
- **WebSearch** for the latest version, recent breaking changes, and deprecated APIs
- Specifically check: what version is current? What changed in the last 6-12 months? Is any commonly-taught pattern now outdated?

### 2d. Cross-source comparison

After researching multiple sources, synthesize before writing:
- What patterns do 3+ repos agree on? (consensus — recommend confidently) If fewer than 3 repos were found in 2b, research more before synthesizing — a consensus claim with fewer than 3 sources must be labeled "limited evidence" in the guide.
- What do only the best repos do? (advanced — teach with nuance)
- Where do repos disagree? (controversial — show both sides, pick one)
- What surprised you? (these are the most valuable findings for the guide)

### 2e. What counts as research

- **YES**: WebSearch → found app repo → WebFetch'd their `src/` files → extracted a pattern they use
- **YES**: WebFetch'd official docs → found a feature → verified it in a real repo's code
- **YES**: Found a GitHub discussion where a user links their production repo → fetched it
- **NO**: "I know from training data that Repo X uses pattern Y" — NOT research
- **NO**: Listing repos in "Projects Studied" you didn't actually fetch and read
- **NO**: Reading only READMEs, blog posts, or "awesome lists" without fetching actual source code

Every pattern in the guide must trace to either: (1) the user's own codebase (read in Step 1), or (2) a URL you fetched in this session. If you can't cite the source, don't include the pattern.

## 3. Differentiator Discovery

Before structuring the guide, answer: **"What are the 3 things this technology does that nothing else in the user's stack does?"**

These must be unique capabilities or patterns, not generic good practices that apply to any framework/library. These 3 differentiators get 2x the depth in the guide. They are the reason the guide is worth having.

## 4. Priority Ranking

List EVERY possible section. Rank by **impact** — which would change the reader's code most? **Keep only the top 10-12.** Cut the rest.

Cutting rules:
- Official docs cover it well → cut
- Existing production guides already cover it → cut
- Generic programming practice, not technology-specific → cut
- Removing it wouldn't make the guide less useful → cut
- "What is [technology]" or "How to install" → always cut

The differentiators from Step 3 should naturally rank highest. If they don't, reconsider your differentiators.

## 5. Document Structure

Every production doc MUST include ALL of these:

1. **Title**: `# Production-Ready [Technology]: The Complete Guide`
2. **Subtitle**: One-liner — who this is for, which teams/repos set the standard
3. **Table of Contents**: Numbered, linked (only surviving sections)
4. **Section 1 — Mindset Shift**: Table (10+ rows) showing the gap between tutorial and production use of THIS SPECIFIC technology.
   - At least 5 rows must be about the differentiators
   - Every row must be concrete: code snippets, tool names, specific patterns. Not abstract "bad" vs "good"
5. **Core sections** (the 10-12 that survived ranking). Each must have:
   - Why this pattern matters in production (1-2 sentences)
   - **Complete, runnable code examples** — full files with imports, not snippets. Cite which repo uses this pattern.
   - The opinionated recommendation: state what to use. Mention alternatives in one sentence max.
6. **Performance & Benchmarks section**: Concrete numbers where available (req/s, cold start, bundle size, parse throughput). Runtime/provider differences if applicable. When performance matters vs. when it doesn't for this technology.
7. **Anti-Patterns section**: 8-12 numbered entries. Each with:
   - "Wrong" code block (the real mistake, not a strawman)
   - "Right" code block (the fix)
   - One sentence: WHY the wrong version breaks in production
   - At least 4 anti-patterns must be specific to the differentiators
8. **Projects Studied section**: Table — project name, what was learned, key source files/links

## 6. Quality Standards

- **Length**: 1,000-3,500 lines. These are comprehensive references, not blog posts.
- **Code examples**: Complete, production-grade, with imports. No `// ...` shortcuts in critical paths. Show full patterns a developer can adapt in 5 minutes.
- **Opinionated**: Pick the best tool/pattern and state it clearly. Don't list options with "it depends."
- **Current**: Latest stable versions of all tools and libraries. No deprecated APIs.
- **Cited**: Every pattern must come from a URL you fetched in this session or the user's own code. State the source with a link or file path. "I know from training data" is not a citation.
- **No padding**: Every section teaches something the reader can't get from the official docs + existing production guides combined. If you can learn it from `hono.dev` or `zod.dev`, it doesn't belong here.
- **Not from memory**: The guide's value is knowledge YOU researched, not knowledge you already had. If you catch yourself writing a section entirely from memory without having fetched any sources for it, stop and go research it first.

## 7. Write the Document

Write to `docs/PRODUCTION_[TOPIC]_GUIDE.md` where [TOPIC] is a short uppercase identifier (e.g., `HONO`, `ZOD`, `KMP_TESTING`, `DOCKER_SANDBOXING`).

If the topic naturally splits into sub-guides (e.g., "Python" → general + testing + debuggability), create separate files. Ask the user before splitting.

## 8. Verify

After writing, re-read the document and verify:
- All code examples have correct syntax and complete imports
- Mindset shift table has 10+ rows, at least 5 about the differentiators
- Anti-patterns has 8+ entries, at least 4 differentiator-specific
- Projects studied table is complete — every entry has a URL you actually fetched, not a repo you "know about"
- No section repeats content from existing production guides
- The 3 differentiators are the deepest sections in the guide
- Total line count is 1,000+

Report the final file path(s) and line counts.
