---
name: launch-video
description: Produce a polished launch / promo / announce / sizzle / trailer video end-to-end with HyperFrames, run as a tracked goal. Use when the user asks to "make a launch video", "promo video for X", "trailer", "hype reel", "announce video", "teaser", or any short product/marketing video. Sets up a task list, locks format + vibe + audio, extracts the subject's REAL design tokens, writes a beat-by-beat blueprint, builds the HyperFrames composition, runs the quality gates, verifies frames visually, renders the MP4, and delivers it. Embeds creative-agency craft (hook/structure/editing/sound frameworks + the full role roster) under an evidence-tiered discipline. Requires the hyperframes skills, Node ≥ 22, and ffmpeg.
---

# launch-video

A goal-tracked producer pipeline that turns "make a promo for X" into a delivered MP4. HyperFrames is the engine — this skill is the **discipline around it**: lock the brief, mine the real brand, blueprint the beats, build, gate, *look at frames*, render, ship. Every hard-won gotcha below was paid for once; don't pay again.

**This skill orchestrates other skills.** Invoke `hyperframes` (authoring), `hyperframes-cli` (init/lint/render), and `gsap` (animation) at the phases that need them. Don't reimplement what they cover — defer to them.

**It also embeds an agency's craft** so the agent doesn't make one undifferentiated pass and ship. Two references carry it (read them at the phases that need them):
- **`references/craft.md`** — the hook library + structure/copy frameworks (PAS), the editing cut-vocabulary, sound design, the 12 motion principles, transitions.
- **`references/agency-roster.md`** — every creative-agency role mapped to a "hat" the solo agent wears per phase (Strategist → Copywriter → Storyboard → Director → Editor → Sound → Colorist → Distribution → Analytics), under a central orchestrator. **Don't skip a role's *thinking* just because one agent does every job.**
- **`references/research-findings.md`** — the skill's evidence base (what's verified vs refuted vs still-open) and what to re-verify with first-party sources before a production launch.

**Evidence discipline (non-negotiable):** tag what you rely on — **[SPEC]** (platform-official, verified → a rule) · **[FRAMEWORK]** (named, corroborated → the named tool) · **[CRAFT]** (practitioner convention → a strong default) · **[UNVERIFIED]** (failed verification → soft instinct only). **Never invent retention/engagement statistics.** A pile of tempting numbers — "65% at 3s", "4–7× impressions", fixed segment proportions, "change a visual every 3–5s", "3 hooks → ~90%" — were adversarially *refuted*; do not state them as fact (the refuted list lives in `references/craft.md`).

---

## Phase 0 — Set up the goal (do this FIRST)

Create the task list with `TaskCreate` so progress is visible and nothing is skipped. Mark each `in_progress` when you start it and `completed` when done.

1. Research: HyperFrames + the subject + extract exact design tokens + study a reference launch
2. Lock direction (format, vibe, length, audio)
3. Write the beat-by-beat blueprint (`.hyperframes/expanded-prompt.md`)
4. Scaffold the HyperFrames project
5. Build the composition (all scenes, one master timeline)
6. Create/wire assets (fonts, audio, inline SVG)
7. Quality gates (lint → validate → inspect)
8. Visual verification (draft render → read key frames → fix)
9. Final render + deliver

(Order Phases 1–2 however the request flows — often: lock direction *then* research, or research enough to ask good questions.)

---

## Phase 1 — Lock direction (the expensive forks)

Use `AskUserQuestion` for the choices that are costly to change after building. Give a recommended option first. Default to the audience's native habits, not yours.

- **Format / aspect** — vertical 9:16 (TikTok/Reels/Shorts, mobile-first products), landscape 16:9 (website hero, YouTube), or square 1:1. *This is the one choice that's expensive to redo — always confirm.*
- **Vibe / energy** — hype drop / cinematic-premium / explainer-demo. Sets pacing and transition energy.
- **Length & platform spec** — keep teasers tight. **[SPEC]** TikTok ads: hook in the first **6s**, content proposition in the first **3s**, **9:16 + ≥720p**, spine = **hook → USPs → CTA**. YouTube Shorts: **9:16**, keep it **<60s** (10–30s for action-oriented). *Re-verify platform specs before a real launch — they drift, and most safe-zone pixel maps online are unverified.*
- **Audio** — silent + music-ready (best for muted autoplay; leave a wired `<audio>` slot + sync points), generate a TTS VO (`hyperframes-media`), or wait for a user-provided track. If you need an asset and lack a tool, say what tool would unblock you (e.g. an ElevenLabs MCP for music/SFX) and proceed silent so nothing blocks.

Don't over-ask. One tight round of 2–3 questions, then build autonomously.

## Phase 2 — Research: read the skills, study real projects, mine the brand

**Read before you build — non-negotiable.** The HyperFrames skills and real example projects encode framework rules that generic web/animation knowledge gets *wrong* (timeline registration, `data-*` semantics, non-linear-seek determinism, shader-safe CSS). Skipping this ships broken compositions.

1. **Read the relevant skills in full** — don't just trigger them; open the files for depth:
   - `hyperframes` + its always-read references (`video-composition`, `beat-direction`, `motion-principles`, `typography`, `transitions` + the transitions `catalog`; `captions` if there's text synced to audio). These live at e.g. `~/.claude/skills/hyperframes/SKILL.md` + `references/*.md` — Read them directly.
   - `hyperframes-cli` (init/lint/inspect/preview/render) and `hyperframes-media` (TTS/transcribe) if generating audio.
   - `gsap` for *every* build (it's all GSAP). Plus the adapter skill for any special technique you'll use: `css-animations`, `animejs`, `lottie`, `three`, `typegpu`, `waapi`, `tailwind`.
2. **Read real HyperFrames projects for reference — don't invent patterns from scratch.** Clone and actually read the *source*:
   - `git clone --depth 1 https://github.com/heygen-com/hyperframes-launches` → study `*/STORYBOARD.md`, `*/SCRIPT.md`, `*/index.html` (how beats are sequenced + captions + audio wired) and 1–2 beat/composition files (entrance/exit handoffs, typewriter via `tl.call`, count-ups, blur-matched transitions). Learn the architecture choice (master + sub-comps vs single composition) and the keynote-vs-hype register.
   - Search the filesystem for existing projects (`hyperframes.json` / `meta.json`) — past builds that actually rendered are the highest-fidelity reference.
   - Skim the registry (the `registry` URL in `hyperframes.json`) for caption/transition/VFX/lower-third blocks you can install (`hyperframes-registry`) instead of hand-rolling.
3. **Extract the subject's EXACT design tokens — never invent them.** If it's a codebase, dispatch an `Explore` subagent to return, with file:line: every brand hex, the font families + weights, and the signature UI components (the thing the product is *known* for — the bar, the card, the chart). If it's a live site, use `website-to-hyperframes` or screenshots. Build the video from the product's real palette/type/components; fidelity is the whole point.

## Phase 3 — Blueprint (write it, don't wing it)

Write `.hyperframes/expanded-prompt.md` (the `hyperframes` prompt-expansion step). It must contain:
- **Hook (first 1–3s)** — designed explicitly: pick an archetype (bold statement / question / pattern-interrupt / proof-first / curiosity-gap…), make the opening visuals **and** audio *match the promise*, reaffirm the emotion. Land the proposition by ~3s.
- **Copy spine** — `hook → USP → CTA`, or **PAS** (problem → agitation → solution). One CTA at the end.
- **Style block** citing the *exact* extracted tokens (hex, fonts) — no invented colors.
- **Rhythm** named in one line (e.g. `HOOK → build → PUNCH-down → PUNCH-up(PEAK) → FLEX → MONTAGE → SLAM`).
- **Per-beat**: concept, mood, depth layers (BG decoratives + MG content + FG accents), choreography verbs per element, transition out.
- **Audio hit-points** (timestamps) so music sync is trivial later.
- **Negative prompt** from the brand's anti-patterns.

Find the ONE emotional core and build the whole piece around it (for a competitive product: a loss → comeback; for a tool: tedious-before → effortless-after). The peak is the payoff — spend the boldest motion there. (Craft details: `references/craft.md` for the hook library, PAS, cut-vocabulary, sound design & motion principles; `references/agency-roster.md` for the role-hat that owns each phase.)

## Phase 4 — Scaffold

`npx hyperframes init <name> --example blank --non-interactive`. **Place it OUTSIDE any package manager workspace** (check `pnpm-workspace.yaml` / workspaces globs) so it doesn't get swept into the host repo's tooling. Set `meta.json` + the root `data-width`/`data-height` + `body` size to the chosen resolution. The scaffold pins the CLI version in `package.json` scripts — reuse that pinned `npx hyperframes@<ver>` for every subsequent command (fast, deterministic).

## Phase 5 — Build the composition

Defer to `hyperframes` for authoring rules and `gsap` for animation. Decisions that worked:
- **Single root composition + stacked `.scene` divs + one master timeline** is the lowest-risk path for a cohesive-brand piece — transitions become opacity/transform tweens with no track-overlap rules, and one timeline seeks more predictably than many nested ones. (Use master + sub-comps only when beats are genuinely different "universes" that benefit from isolation.)
- **Layout before animation**: position every element at its hero-frame, static, then add entrances.
- Recreate the product's signature UI faithfully at video scale (treat a 1080-wide vertical frame as ~3× a phone; bump 375px-design sizes ~2.5–3×).
- **Hype / "TikTok" register** (when the vibe is fast/social): a top layer of **kinetic captions that pop on the beat** (a hook caption in the *first second*), **SFX on every event**, **punch-in zooms** on the peak beats, and **no dead air** — something always moving, cut fast early (~0.8–1.5s). Author captions full-width-centered (`left/right + text-align`, not `translateX(-50%)`) so a GSAP scale/rotation pop doesn't clobber the centering.

## Phase 6 — Assets

- **Fonts**: write *literal* family names in `font-family` (NOT CSS `var(--x)` — the embedder can't resolve through a variable). Inter / JetBrains Mono and most popular Google fonts auto-embed; for any the linter flags as "not in the auto-resolved font list", download the woff2 (`curl` the `fonts.googleapis.com/css2` CSS with a Chrome UA, grab the latin woff2) into `fonts/` and add `@font-face`.
- **Audio**: wire `<audio id="music" src="assets/music.mp3" data-start=0 data-duration=<dur> data-track-index=0>` and create a **silent placeholder** so the slot is valid now: `ffmpeg -f lavfi -i anullsrc=r=44100:cl=stereo -t <dur> -c:a libmp3lame assets/music.mp3`. Dropping a real track over it needs no code change. (`<audio data-duration>` trims the track to the clip length.)
  - **Generating audio (e.g. an ElevenLabs music/SFX MCP → the `muse` skill):** compose the bed from a **structured `composition_plan`** — sections whose `duration_ms` sum to the video length — so a section boundary (the drop) lands on your peak beat. Generate punctuation SFX (`text_to_sound_effects`) for the key hits (impact / whoosh / pop). Mix in ffmpeg — each SFX `adelay`'d to its beat, `amix` with the bed, `alimiter` on the sum — then run `muse` to fit-to-exact-duration / fade / normalize (EBU R128) / verify non-silent. **Mix the bed LOW and the SFX HIGH (bed ~0.5, hits ~1.0–1.3):** loudness-normalization scales everything uniformly, so it *preserves your bed:SFX ratio* — mix SFX quiet relative to the bed and they stay buried.
  - **Tier gotcha:** ElevenLabs' **Music API needs a paid plan** (free → HTTP 402 `paid_plan_required`); **SFX + TTS work on free.** If music is gated, do SFX-only sound design (still a real lift) and flag that music needs an upgrade.
- **Visuals**: author SVG/CSS art inline; avatars as CSS gradients; grain via tiny data-URI. Don't fetch random copyrighted media.

## Phase 7 — Quality gates

`npx hyperframes lint` → `validate` (WCAG contrast) → `inspect` (layout overflow). Fix every **error**. Triage warnings:
- **Contrast on text using a dim tertiary color** → real; brighten the token (video needs more contrast than web).
- **Contrast `1:1` on text over a gradient/icon background** → false positive; the sampler can't read a gradient. Dark-on-bright-gradient is legible — document and keep if brand-accurate.
- **`file_too_large`** → soft readability note; fine for a deliberate single composition.

## Phase 8 — Visual verification (do NOT skip)

Static tools miss font fallback, color, and overlap. **Look at actual frames.** Do a fast draft render, extract the key moments, and Read them:
```
npx hyperframes render --quality draft --output renders/draft.mp4
ffmpeg -y -i renders/draft.mp4 -vf "select='eq(n\,<f1>)+eq(n\,<f2>)+...'" -fps_mode passthrough frames/f%02d.png   # frame n = round(t*fps)
```
Read each PNG; confirm fonts render (not Times/Arial fallback), tokens match, the peak lands, and nothing overlaps. Fix and re-verify the changed frames.

## Phase 9 — Final render + deliver

- Install the optimized capture browser once: `npx @puppeteer/browsers install chrome-headless-shell@stable`, then `export HYPERFRAMES_BROWSER_PATH=<printed path>`.
- `npx hyperframes render --quality high --output renders/<name>.mp4`.
- Verify a few frames of the *final* file. Clean scratch artifacts; add a `.gitignore` (`node_modules/`, `chrome-headless-shell/`, `frames*/`, scratch renders).
- Deliver with `SendUserFile` (the MP4 is the deliverable) + a tight summary: what it is, how to preview (`npm run dev`), how to swap music (drop `assets/music.mp3` → re-render; list the hit-points), the documented false-positives, and concrete next-step offers (music bed, alt aspect ratio, captions/VO, variations).
- **Iterate as committed checkpoints.** Commit each accepted cut (the Studio can corrupt; experiments wander), and save distinct renders (`name-v2.mp4`) when comparing directions so a preferred version is never overwritten.

---

## Gotchas (paid-for lessons — heed them)

- **`tl.set()` / `tl.call()` need an explicit position arg** (e.g. `, 0`). Without one GSAP appends them at the current timeline END, not where you meant. The `fromTo` from-state already hides later-scene elements via `immediateRender`, so you rarely need an initial `set` at all.
- **Never stack two transform tweens on one element**; combine into one `fromTo`, or split across parent/child. For an intentional re-target of the same property, add `overwrite: "auto"` (the linter flags overlapping tweens).
- **Don't clobber a CSS centering transform with a GSAP `scale`** — if an element centers via `transform: translate(-50%,-50%)`, GSAP `scale` replaces it. Center via margins instead, or make the element a flex child.
- **Elements that intentionally sit outside their box** (a badge poking past a bubble edge) → make them a flex sibling, or mark the container `data-layout-allow-overflow`. Off-frame decorative glows → `data-layout-ignore`.
- **Vary eases and durations** (≥3 eases/scene, slowest 3× the fastest); offset the first tween 0.1–0.3s; finite `repeat` only; yoyo loops must resolve to their start state.
- **Software rendering is fine** for CSS/DOM compositions (no GPU needed); only WebGL/shader pieces care.
- **Verify by looking, not by trusting the timeline.** Read the frames.
- **The HyperFrames Studio (`npm run dev`) can rewrite your source while it's open** — it round-trips the DOM and corrupts the file: HTML-escapes element bodies, **lowercases camelCase SVG tags** (`<linearGradient>`→`<lineargradient>`, silently killing the gradient), injects `data-hf-text-key` attrs, normalizes `<br/>`. **Close the Studio before editing source**; if you spot those signatures, rewrite the file clean. Commit known-good checkpoints so you can always recover.
- **Re-time / trim the whole timeline without renumbering every tween:** author in the original coordinates, then `tl.shiftChildren(-N, true)` right before registering — it shifts every child (plus labels/callbacks) by N seconds. Ideal for "skip the intro / open on the action" or global compression.
- **You can't hear generated audio.** Verify it mechanically (`ffprobe` duration + `volumedetect` mean ≠ −inf, or `muse`'s probe gate), then **rely on the user to judge how it sounds.** Iterate genre by re-prompting the music gen — the synced section structure is reusable. Keep the stems so a re-balance is a cheap re-mix, not a regen.
- **Montage / feature panels: fill the frame, don't float a small card.** A small card on a same-hue background reads low-contrast and unclear at flash speed; go full-bleed with one bold hero element + a distinct accent color. Dispatch a `ui-ux-pro-max` subagent to redesign any screen that reads weak.
- **Cutting a weak section beats polishing it.** If a beat isn't landing, propose dropping it and ending on the peak — shorter and stronger. Keep the cut content in git history (or hidden in the HTML) for easy revival.

## Output checklist
- [ ] Goal/task list created and walked
- [ ] Direction locked with the user (format/vibe/audio)
- [ ] Blueprint written citing exact tokens
- [ ] `lint`/`validate`/`inspect`: 0 errors; warnings triaged & documented
- [ ] Final frames eyeballed (fonts, tokens, peak, no overlap)
- [ ] MP4 delivered + iteration instructions
