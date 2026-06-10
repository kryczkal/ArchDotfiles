---
name: mobbin-elevate
description: |
  Elevate a real frontend screen to production reference quality using the Mobbin MCP
  (a library of screens from top-tier shipping apps). Use when the user says a screen looks
  "AI-ish", "generic", "slop", "templated", or "off", or asks to "elevate / level up / make it
  premium / make it look designed / polish the UI" of an existing component, page, or flow in a
  real codebase. Also use when the user mentions Mobbin or "use real apps as reference." Not for
  greenfield "design me a new app from scratch" and not for copywriting.
---

# Mobbin Elevate

**Elevation is architectural first, cosmetic second — implement it for real, don't describe it.** A screen
reads "AI slop" because AI emits the **centroid** (the training-set average, generic by construction):
nothing leads, everything competes, the surface is sanded even. The cure is **commitment** — one job made
loud by suppressing everything else; beauty is the residue of *subtraction*, not addition. (Full theory +
levers: `references/craft.md`.)

Two layers, in order: **(1) Re-architect** — decide what the screen is FOR right now, what leads, what to
cut/consolidate; find the ONE structural change that makes it feel shipped (restyling one component is not
this). **(2) Recraft** the surface in service of it. Frame of mind: ask "what can I *remove* and still do
the job?" (default: *nothing*); master the boring codes (one grid, one type scale, one accent) before
bending exactly one.

A reference is **evidence of a decision a great team made** — read the *non-obvious structural decision
behind it* and implement it for real; don't stop at "I made the card bigger." **Different is not better:**
if a direction is guessable from the app's category alone, it's the centroid — re-anchor to what makes THIS
app distinct.

**Mobbin returns STILL FRAMES ONLY** — images + `{id, app_name, mobbin_url, platform}`; no animation, flow,
or color/font/spacing data. Extract **ratios, not absolutes** (display:body, gap-between:gap-within, weight
contrast); read the *app's* values from its token files and the *reference's* ratios off the pixels — never
confuse them. Motion is a **derivation**: author it yourself.

**You do not grade your own taste** (self-score ~0.1 with real quality). The deliverable is a rendered
baseline + variant the **human rates**; you may flag only objective failures (missing focus ring,
`transition: all`, contrast fail) — never your own "looks good" score.

**Explore before you exploit.** Refining only finds the best of the *current* basin; if it reads "off" no
matter how you tweak palette/spacing/layout, reseed — scramble the context, design fresh from a strong
reference-world (keep only the product's job), generate several genuinely *different* concepts (diversity
over polish), let the human pick the basin, then refine. Keep each basin **domain-coherent** — jump
aesthetic *worlds*, not the product's meaning (a banter game reframed as a stock brokerage is noise).

## The loop

**Step 0 — Read the room.** Identify the ONE target screen. Read the app's real tokens from its files
(Tailwind `@theme` / `:root` vars / a `tokens.ts`) — never infer values from a screenshot; read ≥2 of its
components in full; note and match the motion library (don't add a new one). **Discover, don't hardcode:**
scan the environment for the project's libraries + any installed UI/design/animation skills to route to
(`find-skills`) — this skill names none on purpose, so it stays idempotent. Mine any design doc for the
app's distinct identity and its OWN size/weight numbers (a ban it declares but still violates is in-scope).
Read back one sentence: target screen + distinct identity + what you'll reuse + what you'll NOT change.

**Step 1 — The architect question, then a COHERENT reference set.** Write: **what is this screen's JOB for
the user opening it now?** What leads; what marketing-noise to cut; what status/identity/action to
consolidate. Name 2–4 comparables **by job, not looks**, commit one tone, run the centroid test *before*
searching. Fetch (`Read references/mobbin.md`): `search_screens { query: <job in 5–9 plain words>,
platform: ios|web, limit: 6, mode: "deep" }`. Mobbin mixes incompatible universes — keep the **3–5 sharing
one register AND the job**, drop the rest. Then ask the architect question *of the references*: **what
structural decision do they share that yours doesn't?** That shared decision (not a color) is what you steal.

**Step 2 — One decision doc** (`assets/decision-doc-template.md`; `Read references/craft.md` for the tiered
levers — **fix TIER 1 first: one hero / one tinted-neutral+accent / one grid / cut the infodump — ~70% of
the AI-y read at zero taste cost**). Blocks, structure-first: (1) **Structural insight + core
re-architecture** — the headline, written first: the ONE change that has to land. (2) **Sources** — app
names + `id`s. (3) **Converge** → adopt the shared structural pattern; read each by eye (layout / type
ratios + weight contrast / color roles / states), record the *why*; **assign each reference a ROLE** (vibe /
component anatomy / signature) and adopt *by role, recombining* — not averaging; add **at most one signature
flourish**, never as a substitute for the structural change. (4) **Changes** — each bound to a file + an
intent sentence; ratios on the app's OWN scale (never paste a reference's hex/px; custom fonts don't
transfer — match treatment); layout/hierarchy/IA are fair to rebuild, not just retint; **reseed all
placeholder data irregular + voiced** (`1,247` not `1,200`, human handles, system strings in the product's
voice) — cheapest high-signal fix. (5) **Deliberately reject** — and why. Run the cheap gates before rendering.

**Step 3 — Build the mock, render, rate (this skill's deliverable)** (`Read references/render.md`). Implement
the **full re-architecture** in a faithful **self-contained mock** built from the app's real extracted
tokens — rebuild layout/hierarchy/IA, not just colors; include the one orchestrated motion moment. Always
render the current screen unchanged as **baseline (variant-0)** — the anchor. Calibrating → show a few
genuinely distinct directions (Variant rule); locked → one polished variant. **Caption each STRUCTURAL move
first**, then the surface levers. **Open and READ every PNG against the reference images before presenting**
(non-skippable); fix obvious artifacts/clipping yourself. Hand baseline + variants + captions to the
**human to rate**, plus a short "what prod does that you didn't" list. **The job ends at the approved mock**
— making it *real* (porting into prod components, wiring real data/tokens/motion) is a **different prompt**:
an implementation pass, not a design-taste one (hand off the mock + decision doc; route to a coding skill).
Mock-first keeps prod clean until the look is approved.

**Iterate — one change per round.** After each round ask plainly: *ship it, or iterate?* Loop render→rate
until they're happy, changing ONE thing per round (structure → palette/clutter → details) so each rating
stays legible. Layout locked but the feel's off → the usual culprit is palette and/or clutter: hold the
layout, offer a few restrained options.

## Cheap gates (before you render)
- **Centroid:** guessable from the category alone (or category + your anti-references)? → re-anchor to the
  app's distinct identity and commit harder.
- **Squint:** hero clearly dominant, still obvious when blurred? → else raise size/weight/color contrast.
- **Closed token budget:** every token has one named job; if the app already has a system, recalibrate
  *magnitude* — don't invent new tokens.

## Variant rule
Baseline (current screen, unchanged) is ALWAYS the anchor — "is this better?" needs something to be better
*than*. Then: **calibrating** → render **3 genuinely distinct organizing principles** (not magnitude dials
of one idea — generating options is the LLM's real advantage; let the human pick from real renders);
**refining a locked direction** → ONE polished variant (add a conservative/bold dial only if the magnitude
is genuinely in question). Cap ~4 renders. Each caption leads with the **structural move**, then the levers
it dials — legible feedback ("the status-led structure in A works"), not "I like #2."
