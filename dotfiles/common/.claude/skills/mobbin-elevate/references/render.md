# references/render.md — render → rate → then prod

The human rates **visuals**, not docs. So produce a rendered PNG the user can judge in seconds, and get
that judgment **before** editing production code. The decision doc is your private scaffold; the visual is
the deliverable.

## Default: mock-first rating loop

1. **Build a faithful self-contained mock** of the target screen — a single standalone HTML file (or a
   tiny isolated component) that uses the app's **real extracted tokens** (the exact colors, fonts,
   radii, spacing you read from its files in Step 0) and the **real screen content/copy**. It must look
   like the actual screen, not a generic placeholder — otherwise the rating is on a fantasy. When you swap
   reference copy for the app's real copy, **keep similar character counts** so line-breaks/widths/grid
   match the proven layout. **Stage hard assets upstream:** for a scroll/hero/3D moment, build the asset
   out-of-band (image stills → frames → sequence; hero raster ≥2K, tight-crop PNGs flush to bounds) and
   have the mock only *wire* it — don't ask the build to invent it inline.
2. Make **two** mocks rendered the SAME way, so the comparison is honest:
   - **baseline** — the current screen reproduced faithfully (this is the anchor).
   - **V2** — the reference-true elevation (the one mandatory variant).
   (Add V1/V3 only when the right magnitude is genuinely in question.)
3. **Render each to PNG** at the screen's real frame (e.g. 390×844 for a mobile app), fonts loaded.
4. **Open and READ every PNG** against the Mobbin reference images (non-skippable). Fix obvious objective
   failures yourself before presenting.
5. **Make the mocks VIEWABLE, then present baseline + variant(s) side by side, each captioned** with
   the 1–3 levers it dials + the before→after delta. The user rates.
   **Non-skippable before you ask for any rating:** the human must be able to open the *live* mocks,
   not just a PNG strip. Serve the mockups dir (`python3 -m http.server <port>`) and open each mock in
   the browser (or, at minimum, output the full `file://` paths / `localhost` URLs for every mock).
   A static contact-sheet PNG is a *supplement*, not a substitute — live HTML shows motion, the
   `:active` press states, and any WebGL/shader animation a still can't. **Never file a rating question
   on visuals the human cannot open** — they can't (and shouldn't) decide blind. Open first, ask second.
6. **Only after a direction is approved**, apply it at the token + interaction layer to the **real
   components**, authoring the one motion moment in the app's existing motion library. Then optionally
   render the real component (below) as a final fidelity check.

Why mock-first: it makes iteration cheap and keeps prod clean until the look is approved. The one risk —
a mock that drifts from the real tokens — is controlled by extracting tokens from files (Step 0) and
reproducing the baseline from the same tokens.

## Rendering a PNG (either a mock file or a real route)

Prefer a headless browser you can drive deterministically:
- **Playwright** (if the project has it): a ~15-line node script — `chromium.launch()`, `page.setViewportSize({width, height})`, `page.goto('file://…' or 'http://localhost:…')`, `await page.evaluate(() => document.fonts.ready)`, `page.screenshot({ path, clip })`. Screenshot the screen element, not full-page.
- **Chrome DevTools MCP**: `ToolSearch select:mcp__chrome-devtools-mcp__navigate_page,mcp__chrome-devtools-mcp__take_screenshot,mcp__chrome-devtools-mcp__resize_page` → resize to the frame → navigate → wait for fonts → screenshot.

Always wait for `document.fonts.ready` before the shot, or web fonts render as fallback and the type
hierarchy you're being rated on is wrong.

## Rendering the REAL component (final check, or when no mock is wanted)

Look for an existing gallery / Storybook / preview harness first and reuse it — it renders the real
component with real tokens/fonts/motion, strictly better than re-implementing.

**rizz worked example (illustrative, not hardcoded):** `pnpm --filter frontend mock` serves a dev gallery
on port **5174**; it auto-discovers `src/pages/**/*.screen.tsx` files exporting a `stories` array and
renders each inside a 390×844 `GalleryPhoneShell` with real tokens/fonts/motion. Navigate to
`http://localhost:5174/#/screens/<story-id>`, wait for fonts, screenshot the `GalleryPhoneShell` div. If
the target lacks a `.screen.tsx`, add a ~15-line store-driven fixture story to stage it, plus a `*-v2`
story wired to the elevated component for the before/after. (This is one example of "find and reuse the
existing harness" — every app differs.)

## The non-skippable gate

You must actually open and READ each rendered PNG and the reference images together before presenting.
A screenshot you generated but didn't look at doesn't count — that's the exact naive-prompt failure
(write CSS, never check it against anything). **Walk the full path, not just the one populated shot:**
check the screen at its real mobile frame (re-composition, not a squeezed desktop), and walk the
empty / loading / error / success states — not only the happy path. Autonomous mode may skip *preference*
questions; it may never skip render+read.
