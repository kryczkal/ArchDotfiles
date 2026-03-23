Generate a production-ready guide document.

Topic: $ARGUMENTS

Follow this process:

## 1. Research (do NOT skip)

- **Check for existing production docs** in the project's `docs/` directory (PRODUCTION_*.md). If they exist, read them to understand the format, depth, and style — use them as your template. If none exist, use the structure defined below as the canonical template.
- **Study 15-20 top open-source repos** that use this technology in production. Search GitHub, read their source code, architecture, patterns, and anti-patterns. Prioritize repos with 1k+ stars that are actively maintained.
- **Search the web** for current best practices, official documentation, and community consensus. Don't rely on stale patterns.

Run research in parallel using multiple agents to maximize coverage.

## 2. Document Structure (mandatory sections)

Every production doc MUST include ALL of these sections:

1. **Title**: `# Production-Ready [Technology]: The Complete Guide`
2. **Subtitle**: One-liner about who this is for and which teams/projects set the standard
3. **Table of Contents**: Numbered, linked sections
4. **Section 1 — Mindset Shift**: Amateur vs Production comparison table (8-10 rows). This sets the tone for the entire doc.
5. **Core sections** (10-18 sections depending on topic): Each section must have:
   - Explanation of the concept and WHY it matters
   - **Real code examples** — not pseudocode, not snippets. Full, copy-pasteable, production-ready code blocks. Show complete files when relevant.
   - References to which real repos use this pattern
6. **Anti-Patterns section**: 8-12 numbered anti-patterns, each with a "Wrong" and "Right" code example
7. **Projects Studied section**: Table of every repo studied with name, what was learned, and link

## 3. Quality Standards

- **Length**: 1,000-3,500 lines. These are comprehensive reference docs, not blog posts.
- **Code examples**: Must be complete, runnable, and production-grade. No `// ...` shortcuts in critical sections. Show the full pattern.
- **Opinionated**: Pick the best tool/pattern and recommend it clearly. Don't list 5 options with "it depends." State which one to use and why. Mention alternatives briefly.
- **Current**: Use the latest stable versions of all tools and libraries. No deprecated APIs.
- **Battle-tested**: Every recommendation must come from a real production codebase, not a tutorial. Cite the source.
- **Anti-patterns**: Show the common mistakes AND the fix. Developers learn from seeing what NOT to do.

## 4. Write the Document

Write to `docs/PRODUCTION_[TOPIC]_GUIDE.md` where [TOPIC] is a short uppercase identifier (e.g., `NEXTJS`, `KMP_TESTING`, `RUST_ASYNC`).

If the topic naturally splits into sub-guides (e.g., "Next.js" → general + testing + debuggability), create separate files for each. Ask the user before splitting.

## 5. Verify

After writing, re-read the document and verify:
- All code examples are syntactically correct
- All sections from the template are present
- The mindset shift table has 8+ rows
- Anti-patterns section has 8+ entries with code examples
- Projects studied table is complete
- Total line count is 1,000+

Report the final file path(s) and line counts.
