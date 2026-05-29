---
name: code-quality-partial
description: One slice of the code-quality audit. Picks a single source file at random, audits and fixes it thoroughly, then stops. Designed to be run repeatedly in a loop (e.g. via /loop) so refactors land incrementally over many iterations instead of as one massive change.
argument-hint: [scope-path (optional)]
effort: medium
---

# Partial Code Audit & Refactoring (Loop-Friendly)

You are performing **one slice** of the comprehensive code audit. Pick a single source file at random within the project, audit it thoroughly against the project's standards, and fix everything wrong with it. Then stop.

This is the loop-friendly counterpart to `/code-quality`. Run it on a schedule (e.g. `/loop 30m /code-quality-partial`) so coverage emerges from many small iterations rather than landing as a single massive refactor.

## Phase 1: Pick a target

### 1a. Determine candidate scope
- If `$ARGUMENTS` is a path, restrict candidates to files under that path.
- Otherwise, candidates are all source files under the project root.
- **Exclude** vendored / generated / build dirs: `node_modules/`, `.venv/`, `venv/`, `dist/`, `build/`, `target/`, `.next/`, `.git/`, `coverage/`, `__pycache__/`, `vendor/`, `.cache/`.
- **Exclude** lockfiles, minified files (`*.min.*`), and generated code (`*.pb.go`, `*_pb2.py`, `*.generated.*`, `*.g.dart`).
- **Keep only** source extensions appropriate to the project (discover the stack from project config — `pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, etc. — then filter `find` accordingly).
- **Skip files modified in the last 24h** — likely WIP, don't stomp on active work. Use `find ... -mtime +1` or equivalent.

### 1b. Pick one — semi-randomly
- Use `find <root> <filters> | shuf -n 1` (or `gshuf` on macOS) for the random pick.
- If the file is under ~20 lines, re-pick once. Tiny files rarely benefit from refactoring.
- If a file was already fixed by this skill in a recent iteration, prefer a different one — keep a tiny ledger at `.claude/code-quality-partial.log` (one path per line, append on each fix). Skip the most recent ~10 entries when picking. If the candidate set is exhausted by that filter, ignore the ledger.
- Print the chosen path early so the loop log shows what's being worked on.

### 1c. Build minimal context
- Read project standards docs once: `CLAUDE.md`, `README.md`, top-level `docs/**/*.md`. These define the bar.
- From config, identify the project's **lint**, **typecheck**, and **test** commands.
- Read the chosen file fully, plus its direct imports and one or two callers — just enough to make safe changes. Do **not** read the whole codebase.
- Before flagging any exported symbol or function as dead code, run a codebase-wide reference search (e.g. `grep -r <name> .`) to confirm zero callers — do not rely solely on the callers read above.

## Phase 2: Audit the chosen file

Apply the same standards as `/code-quality`, scoped to this one file:

- **Correctness & bugs** — logic errors, edge cases (null/empty/zero/negative), async pitfalls, resource leaks, race conditions.
- **Type safety** — missing or loose types, `Any`/`any` that should be narrowed, would-fail-typecheck issues.
- **Code quality** — dead code, unused imports, intra-file duplication, poor naming, magic values, single-responsibility violations, overly complex expressions.
- **Error handling** — missing handling on I/O / network / parsing, swallowed exceptions, errors missing context.
- **Standards from project docs** — if a doc says "do X", verify the file does X. Logging, observability, structured errors, accessibility, etc.
- **Security** — injection risks, hardcoded secrets, missing validation at trust boundaries.
- **Performance** — obvious N+1, blocking calls in async contexts, repeated work.
- **Testing** — if the file has a sibling test file, sanity-check that the changed paths are exercised.

**If the file is already clean: say so plainly and stop.** Do not manufacture issues to justify a change. A no-op iteration is the convergence signal — the loop will pick a different file next time.

## Phase 3: Fix

1. List findings briefly, grouped by severity (bugs > standards > types > quality > style).
2. Fix everything found — actually edit the file.
3. Run scoped validation:
   - **Lint** the file (most linters support file-scoped runs).
   - **Typecheck** project-wide if cheap; otherwise just the module.
   - **Tests** that directly touch the changed code (sibling test file, or grep callers).
   - Report validation as "clean" or list failures — do not narrate successful command invocations individually.
4. If validation fails, fix until clean. If validation fails due to an error in a different file not caused by this fix, stop: note it in the Phase 4 summary and do not expand scope to fix it.
5. Append the fixed path to `.claude/code-quality-partial.log`.

## Phase 4: One-paragraph summary

Designed to be readable in a loop log:
- File touched (or "skipped — already clean").
- What was fixed (categories + counts, not every line).
- Validation status.
- Anything intentionally deferred to a later iteration. A deferred item is one you found and chose not to fix due to scope; items you decided are non-issues need not appear.

## Loop discipline

- **Per-iteration scope is one file.** Do not expand to neighboring files unless absolutely required by the fix (e.g. a renamed export with a single caller).
- **Do not commit.** Leave changes staged or unstaged for the user to review across iterations.
- **No-op iterations are fine and expected** as the project converges.
- **Do not try to track global progress** beyond the small ledger above. Randomness over many iterations gives the coverage.
- **Honor the path argument** as a hard scope constraint when present.
