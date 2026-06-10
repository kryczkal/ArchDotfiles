# references/mobbin.md — driving Mobbin + turning pixels into decisions

Load the tool: `ToolSearch select:mcp__mobbin__search_screens`.

## What the MCP actually returns (verified by live probe)

`search_screens` returns inline **still images** (webp/jpg base64, full phone/desktop frame) plus
minimal metadata only: `{ id, image_url, mobbin_url, app_name, platform }`. That is the entire
surface. There is **no** animation, flow, transition, tag, date, color value, font name, or spacing
number. `mobbin_url` is login-walled (a human citation, not a scrapable source).

Three consequences:
1. **The image is the data.** Everything you adopt is read off pixels by eye.
2. **Motion is authored, never fetched.** Read the implied moment from the still; design the
   spring/duration/stagger yourself (see `craft.md`). Never promise to "match the reference's animation."
3. **Read ratios, not absolutes.** You cannot reliably eyeball "17px" or "#6E56CF" off a webp. You CAN
   eyeball "the display is ~2.5× the body and much heavier," "this gap is ~2× that gap," "saturation
   lands in exactly one place." Adopt ratios + roles; get the app's own absolute values from its token
   files, not the picture.

## The query recipe

- **`mode: "deep"` always.** Measured: on an identical query, `deep` returned genuine on-purpose
  screens; `fast` drifted to unrelated apps. `fast` is a precision trap.
- **Query the screen's JOB in 5–9 plain words** = screen-type + 1–2 salient elements. **Nouns, not
  adjectives.** Good: `"competitive trivia game results screen with score"`, `"1v1 duel match win
  celebration confetti"`, `"leaderboard ranked tiers with rank icons"`, `"onboarding username setup"`,
  `"daily streak puzzle home"`. Bad: `"clean modern minimal premium screen"` (adjectives return slop).
- **`limit: 6`.** Enough to find convergence without flooding context.
- **`platform`**: `ios` for phone-framed/mobile-first targets; `web` only for desktop-shaped surfaces
  (web results come back wide-format and won't port to a phone screen).
- **`exclude_screen_ids`**: pass the ids you've already seen to fetch a fresh non-overlapping wave when
  one app monopolizes results — but re-check purpose-fit, wave 2 drifts looser.

## Coherence BEFORE convergence (the step the naive prompt skips)

A single query returns aesthetically incompatible universes. A real probe of one duel-result query
returned Duolingo (cartoon-bright), Riot Mobile (dark-tactical), and Bloom (dark-financial-gradient) —
three different worlds for one job. If you average them you get lowest-common-denominator banality
("centered title, bottom button").

So: **first drop everything that doesn't share an aesthetic register with your committed direction
(Step 1) AND the job.** Keep 3–5 from ONE lineage. If two strong results disagree on everything, pick
one lineage. *Then* look at what those coherent screens do alike — that convergence is the category's
real production language, and it's worth adopting wholesale. The single thing one standout does that the
others don't is a candidate signature (adopt at most one).

## Reading a screen into decisions (fixed axes, in order)

For each kept reference, read and write down:
1. **Layout / hierarchy** — what is biggest, centered, first; where the eye lands; symmetric vs
   asymmetric; is there one dominant block?
2. **Type** — display:body **size ratio** and **weight contrast** (e.g. "display ~2.4× body, weight 800
   vs 400"). Not absolute px.
3. **Color usage** — *where* saturation lands (almost always one hero accent on an otherwise calm field).
   Express as roles ("accent on the win delta, everything else neutral"), not hexes.
4. **Spacing** — **gap-between:gap-within ratio** (grouped vs uniform).
5. **Component anatomy** — how the key unit (result card, row, hero) stacks internally.
6. **The single primary CTA** — what it is, where, how it's weighted.
7. **The one signature move** — the memorable detail this app owns.

## Translate stills → motion decisions

- A confetti/celebration still → "confetti burst on mount, ~1.2s, gravity fall, palette = the visible
  accents; the number springs in."
- A big-number still → "count-up tween + spring-in on the card; supporting rows stagger ~40ms after."
- A clean list still → "rows fade+rise 8px on mount, 30–40ms stagger; no per-row bounce."

The reference tells you the *moment*; `craft.md` tells you the *curve*.

## Always cite sources

Record real `app_name` + screen `id` for every adopted decision so the human can open Mobbin and verify
what you saw. "Adopted from Duolingo (id …) + Speak (id …)" beats "industry best practice."
