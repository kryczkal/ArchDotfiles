---
name: refactor
description: Comprehensive code audit and refactoring. Discovers project docs (production guides, testing guides, debuggability guides, etc.), internalizes their standards, then systematically reviews every module against those standards. Top priority task — spot all blemishes and correct them, even if requiring heavy changes.
argument-hint: [file-or-module (optional)]
effort: max
---

# Comprehensive Code Audit & Refactoring

You are performing a **top-priority, thorough code audit and refactoring**. This is not a light review — you must spot **all blemishes** and correct them, even if it requires heavy changes. Be opinionated and uncompromising about quality.

## Phase 1: Discover & Internalize Project Knowledge

Before touching any code, build full context. Every project is different — discover what THIS project uses.

### 1a. Read all project documentation

Search for and read ALL docs in the project:
- `docs/**/*.md` — production guides, testing guides, debuggability guides, frontend guides, etc.
- `CLAUDE.md`, `README.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`
- Memory files in `.claude/projects/*/memory/`
- Any other `.md` files at the project root

**These docs are your source of truth.** They contain the project's specific standards for production quality, testing, debugging, observability, error handling, and more. You must internalize them fully and apply their guidance as hard requirements during the audit.

### 1b. Read project config to understand the stack & tooling

- `pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, or equivalent
- `Dockerfile`, `docker-compose.yml`
- `.env.example` or env documentation
- Linter/formatter configs (`.eslintrc`, `ruff.toml`, `biome.json`, `rustfmt.toml`, etc.)
- CI config (`.github/workflows/`, etc.)
- `tsconfig.json`, `next.config.*`, `vite.config.*`, etc.

From these, determine:
- **Language & framework** (Python, TypeScript/Next.js, Rust, Go, etc.)
- **Lint command** (e.g., `uv run ruff check .`, `npm run lint`, `cargo clippy`)
- **Type check command** (e.g., `uv run mypy . --exclude .venv`, `npx tsc --noEmit`)
- **Test command** (e.g., `uv run pytest -v`, `npm test`, `cargo test`)
- **Format command** if any

### 1c. Read every source file

- All source files in `src/`, `app/`, root, and subdirectories
- All test files
- Understand the dependency graph between modules
- Identify the project's established conventions (naming, imports, error handling, async patterns, types)

## Phase 2: Audit Against Project Standards

Systematically review every file. The project's own docs define the bar — apply them strictly. Additionally, check all of the following universally:

### Correctness & Bugs
- Logic errors, off-by-one, race conditions
- Unhandled edge cases (None/null/undefined, empty, zero, negative)
- Variable shadowing or undefined references
- Incorrect exception handling (too broad, swallowed, wrong type)
- Resource leaks (unclosed files, connections, sessions)
- Async pitfalls (blocking in async context, missing await)

### Type Safety
- Missing or incorrect type annotations
- `Any`/`any` types that should be narrowed
- Inconsistent null/None/undefined handling
- Type checker would flag it? Fix it preemptively

### Code Quality & Style
- Dead code, unused imports, unused variables
- Duplicated logic (even partial — extract it)
- Functions doing too many things (single responsibility)
- Poor naming (vague, misleading, inconsistent)
- Magic numbers/strings (should be named constants)
- Overly complex expressions (simplify or decompose)
- Inconsistent patterns across similar modules

### Error Handling & Resilience
- Missing error handling on I/O, network, parsing
- Generic catch-all that should be specific
- Error messages missing useful context
- Silent failures that should log or propagate

### Standards from Project Docs
- **Apply every recommendation from the production guides** — logging, observability, error tracking, structured errors, etc.
- **Apply testing guide standards** — coverage, assertion quality, edge cases, test organization
- **Apply debuggability guide standards** — log levels, correlation IDs, debug endpoints, etc.
- **Apply frontend guide standards** (if applicable) — component patterns, accessibility, performance
- If a doc says "do X", verify the code does X. If it doesn't, fix it.

### Security
- Injection risks, secrets in code/logs, unsafe deserialization
- Missing input validation at boundaries

### Performance
- Unnecessary repeated work, N+1 patterns
- Blocking calls in async contexts
- Inefficient data structures

### Testing
- Untested code paths, weak assertions
- Missing edge case tests
- Test code quality

## Phase 3: Execute Changes

1. **Create a task list** of all findings, grouped by severity (bugs > standards violations > type safety > quality > style)
2. **Fix everything** — do not just report, actually make the changes
3. **Run the project's full validation suite:**
   - Lint command (discovered in Phase 1)
   - Type check command (discovered in Phase 1)
   - Test command (discovered in Phase 1)
4. **Fix any failures** from the validation suite
5. **Re-run validation** until everything passes clean

## Phase 4: Summary

After all changes, provide:
- Total files modified
- Key changes by category
- Which doc standards were newly applied
- Any remaining concerns or trade-offs
- Suggestions for future improvements that were out of scope

## Scope

- If `$ARGUMENTS` specifies a file or module, focus the audit there but still read docs and surrounding context
- If no arguments, audit the **entire codebase**
- Do not hold back — all blemishes must be found and fixed
- The project's own docs are the ultimate standard — if the code doesn't meet them, it's a defect
- Prefer correctness over backwards compatibility
- When in doubt, make the stricter/cleaner choice
