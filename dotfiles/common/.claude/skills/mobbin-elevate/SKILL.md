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

**Elevation is architectural first, cosmetic second — and you implement it for real, you don't
describe it.** A screen reads as "AI slop" because AI emits the **centroid** — the weighted average of
every interface in its training set, generic by construction. The cure is **commitment**: one job made
loud by suppressing everything else. The tell isn't the colors and radii; it's that nothing leads —
everything competes, marketing copy and live utility carry equal weight, and the surface is sanded even
(one face/weight, uniform spacing, timid color, absent motion). Beauty is the visible residue of
*subtraction*, not addition. Real prod apps feel premium because the screen has **a clear job for the user opening
it right now** — one thing leads, the rest is demoted or cut — and only then does the surface obey
invisible systems (type extremes, grouped spacing, confident color, short origin-aware motion).

So elevation has two layers, in order:
1. **Re-architect.** Decide what this screen is FOR right now, what should lead, what to consolidate
   or cut. This is the architect move — find the ONE structural change that makes the screen feel
   shipped — and it is where the premium feel actually comes from. Restyling one component is not this.
2. **Recraft** the surface in service of that structure.

**The frame of mind both layers run on:** the amateur asks "what can I add to make this look finished?";
the designer asks "what can I remove and still do the job?" — and the default answer is *nothing*. Master
the boring codes (one grid, one type scale, one accent) before bending exactly one.

A Mobbin screenshot does neither by itself. A reference is **evidence of a decision a great team
made** — what they chose to lead with, demote, group, cut. Your job is to read the *non-obvious
structural decision behind the reference* and **implement it for real in the codebase**, so the app
*feels like a shipped premium product*. That feel — not a tidier version of what's there — is the
whole point of having real-app references. Do not stop at "I made the card bigger."

**Different is not better.** The naive prompt restyles to a cleaner generic — shadcn-with-better-
spacing — and calls it elevated. That is just a different slop. Before committing a direction, ask:
**could someone guess this direction from the app's category alone?** If yes, re-anchor to what
makes THIS app distinct.

**Mobbin returns STILL FRAMES ONLY** — images + `{id, app_name, mobbin_url, platform}`. No animation,
no flows, no color/font/spacing data. So extract **ratios, not absolute values**: display:body size
ratio, gap-between:gap-within ratio, weight *contrast*. Ratios survive eyeballing a screenshot; exact
px/hex do not. Read the *app's own* values from its token files; read the *reference's* ratios off the
pixels — never confuse the two. Motion is a **derivation**: read the implied moment from the still and
author it yourself.

**You do not grade your own taste.** The deliverable is a rendered baseline + variant the **user
rates** (your self-score correlates ~0.1 with real quality). Produce concrete, captioned, comparable
visuals; let the human judge. You may flag only objective failures (missing focus ring, `transition:
all`, contrast fail) — never your own "looks good" score.

**Explore before you exploit (escape local optima).** Refining a screen only finds the best version of
its *current* basin; if it reads "off" no matter how you tweak palette/spacing/layout, polish will never
cross the valley to where great products live. Escape by **reseeding**: scramble the context, design
fresh from a strong reference-world (keeping only the product's job), generate several genuinely
*different* concepts (diversity over polish), let the human pick the basin, then refine. Keep each basin
**domain-coherent** — jump aesthetic *worlds*, not the product's meaning (a banter game reframed as a
stock brokerage is noise, not a basin worth showing).

## The loop

**Step 0 — Read the room.** Identify the ONE target screen. Read the app's real design tokens from its
files (Tailwind `@theme` / `:root` vars / a `tokens.ts`) — never infer values from a screenshot. Read
≥2 of the screen's existing components in full; note the motion library and match it (don't add a new
one). **Discover, don't hardcode:** also scan what capabilities the environment offers — the project's
own libraries and any installed UI/design/animation skills you can route to for craft (check the
available-skills list / `find-skills`). This skill names none on purpose, so it stays idempotent.
If the app has a design doc, mine it for the app's distinct identity and any size/weight numbers
(use the app's OWN numbers over imported ones; a ban the app declares but still violates is in-scope).
One-sentence read-back: target screen + the app's distinct identity + what you'll reuse + what you'll
deliberately NOT change.

**Step 1 — The architect question, then a COHERENT reference set.** First answer, in writing: **what
is this screen's JOB for the user who opens it right now?** What should lead? What is marketing-noise
to cut, what status/identity/next-action should be consolidated and surfaced? Name 2–4 best-in-class
comparables **by job, not looks** and commit one tone. Run the centroid test *before* searching.
Then fetch — `Read references/mobbin.md` for the recipe — `search_screens { query: <the screen's JOB
as 5–9 plain words>, platform: ios|web, limit: 6, mode: "deep" }`. Mobbin mixes incompatible aesthetic
universes per query; keep the **3–5 that share one register AND the job**, drop the rest. Now ask the
architect question again *of the references*: **what STRUCTURAL decision do these prod screens share
that yours doesn't?** (what they lead with, what they cut, how they group identity/status/action, the
information hierarchy). That shared decision — not a color or a radius — is the thing to steal.

**Step 2 — One decision doc** (your internal scaffold — `assets/decision-doc-template.md`; `Read
references/craft.md` for the tiered levers — **fix TIER 1 (one hero / one tinted-neutral+accent / one
grid / cut the infodump) first; it removes ~70% of the AI-y read at zero taste cost**). Blocks, structure-first: (1) **Structural insight + core
re-architecture** (the headline, written first) — the non-obvious thing the prod refs do that this
screen doesn't, and the ONE core change you'll make to the screen's job/lead/hierarchy/what-gets-cut.
This is the change that has to land; everything else serves it. (2) **Sources** — app names + `id`s.
(3) **Converge → adopt the shared structural pattern as the foundation** (it's the category's language);
read each screen by eye along fixed axes (layout / where the eye lands, type as ratios + weight
contrast, color *roles* / where saturation lands, visible states); record the *why* (the why transfers,
the pixels don't). **Assign each kept reference a ROLE** — one for vibe, one for component anatomy, one
for the signature — and adopt *by role, recombining*, not by averaging (averaging coherent references
yields banality). Add **at most one signature flourish** on top of the structure — never let a flourish
substitute for the structural change. (4) **Changes** — each bound to a file + an intent sentence;
surface values as ratios on the app's OWN scale (never paste a reference's hex/px; custom fonts don't
transfer — match treatment, not letterforms), but **layout/hierarchy/IA are fair game to rebuild**, not
just retint; **reseed all placeholder data to be irregular and voiced** (`1,247` not `1,200`,
degenerate-human handles, system strings rewritten into the product's voice) — the cheapest, highest-
signal fix. (5) **Deliberately reject** — and why. Run the cheap gates before rendering.

**Step 3 — Build the mock, render, rate (this skill's deliverable)** (`Read
references/render.md`). Implement the **full re-architecture** in a faithful **self-contained mock**
built from the app's *real extracted tokens* — rebuild the layout/hierarchy/IA, not just the colors;
the mock must look and feel like a shipped screen, with the one orchestrated motion moment. Render the
current screen unchanged as **baseline (variant-0)** as the honest anchor. When the user is calibrating
direction (early rounds, or a rejected prior round), show **a few genuinely distinct structural
directions** (see Variant rule) so the rating teaches which organizing principle they want; once a
direction is locked, show one polished variant. **Caption each with the STRUCTURAL move
first**, then the surface levers ("Direction A: leads with player status, cuts the marketing hero; +3×
type, accent on the live CTA"). **Open and READ every PNG against the reference images before
presenting** (non-skippable) and fix obvious artifacts/clipping yourself. **Then make the mocks
viewable for the human BEFORE you ask them to rate** — serve the mockups dir and open each in the
browser, or at minimum output every mock's full `file://`/`localhost` URL (live HTML, not just a PNG
strip; see `references/render.md`). Never file a rating question on visuals the user can't open. Hand
baseline + variant(s) + captions to the **user to rate**, alongside a short **"what prod does that you
didn't"** insight list.
**This skill's job ends at the approved mock — stop there.** Making it *real* (porting the approved mock
into the actual prod components/framework, wiring real data/tokens/motion) is a **different job and a
different prompt** — an implementation pass, not a design-taste one. Hand off the approved mock + the
decision doc to that pass (route to a coding/implementation skill if one is installed); don't fold heavy
productionization into this loop. Mock-first keeps prod clean until the look is genuinely approved.

**Iterate to taste — one change per round.** After each round, ask the user plainly: *ship it, or
iterate?* Loop render→rate until they're happy, changing ONE thing per round (structure first, then
palette/clutter, then details) so each rating stays legible — never restyle everything at once. When the
user locks the layout but dislikes the feel, the usual culprit is palette and/or clutter:
hold the layout fixed and offer a few restrained palette/de-clutter options.

## Cheap gates (run before you render)
- **Centroid:** guessable from the category alone (or category + your anti-references)? → you've hit the
  mean; re-anchor to the app's distinct identity and commit harder.
- **Squint:** hero clearly dominant, still obvious when blurred? → else raise size/weight/color contrast.
- **Closed token budget:** every token has one named job. If the app already has a system, recalibrate
  *magnitude* — don't invent new tokens.

## Variant rule
Baseline (current screen, unchanged) is ALWAYS rendered as the anchor — "is this better?" needs
something to be better *than*. Then two modes:
- **Calibrating direction** (early rounds, or after a rejected round): render **3 genuinely distinct
  structural directions** — different organizing principles, not magnitude dials of one idea. Generating
  options is cheap and is the LLM's real advantage here; let the human pick the direction from real
  rendered visuals rather than guessing one. Make them honestly different bets, not three flavors of the
  same layout.
- **Refining a locked direction:** render ONE polished variant (add a conservative/bold magnitude dial
  only if the magnitude is genuinely in question).

Cap at ~4 renders (baseline + up to 3 directions). Each caption leads with the **structural move**, then
the surface levers it dials, so the rating is legible feedback ("the status-led structure in A is what
works") — not "I like #2." That mapping is the signal the skill-evolution loop needs.
