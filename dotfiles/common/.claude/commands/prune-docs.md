Audit project documentation and prune everything stale, wrong, or derivable from code.

Docs dir: $ARGUMENTS (default: docs/)

---

## The Standard

A doc earns its place only if it contains knowledge **not obtainable by reading the code**:

- **Why** a decision was made (not what the code does)
- **Hardware or platform constraints** that forced a design choice
- **Empirical data** (benchmarks, measurements, failure rates)
- **Non-obvious gotchas** that will bite the next developer
- **Rationale for accepting a tradeoff** (why the worse-seeming option was chosen)

Everything else is noise. Remove it.

## What to cut

| Content type | Verdict |
|---|---|
| Diagrams that mirror the code structure | Cut — the code is the diagram |
| Component tables listing what's already in imports/config | Cut — read the code |
| "Future: X" sections where X is already implemented | Cut — it's history |
| Step-by-step flows that mirror what the code executes | Cut — read the code |
| Product vision / user journey mixed into technical docs | Move to product spec |
| Accurate constraints and gotchas | **Keep** |
| Rationale for non-obvious design choices | **Keep** |
| Measured data (latency, battery, error rates) | **Keep** |
| Platform/hardware limits that can't be inferred from code | **Keep** |

## Phase 1: Inventory

1. List all docs in the target dir (and root-level `.md` files)
2. Skip production/reference guides — they're meant to be comprehensive
3. Read every remaining doc fully

## Phase 2: Audit each doc

For every doc, ask three questions:

**Is it accurate?** Read the relevant source files. Does the doc describe what the code actually does? If it describes a replaced design, it's stale.

**Is it redundant with the code?** Could a developer answer the same question by reading the code for 2 minutes? If yes, cut that section.

**Does it contain irreplaceable knowledge?** Hardware constraints, OS limits, third-party API quirks, empirical measurements — things not obvious from the code? Keep exactly that, nothing more.

## Phase 3: Execute

For each doc that needs changes:
- **Rewrite** it to contain only the irreplaceable knowledge. Shorter is better.
- If nothing irreplaceable remains: **delete** (or move to `docs/legacy/` if it's useful historical record).
- If content belongs elsewhere: move it, don't duplicate.

Do not soften cuts. If a section is redundant, remove it entirely — do not "summarize" it into a shorter redundant version.

## Phase 4: Report

- Each doc reviewed
- What was cut and why (one line per cut)
- What was kept and why (one line per kept section)
- Any docs deleted or archived
