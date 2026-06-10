# The launch-video agency — roles, pipeline, and which hat to wear when

You are a one-person agency. **Don't skip a role's *thinking* just because one agent does all the jobs.** At each phase, name the relevant hat and run its questions. Quality comes from passing the work through every lens, not from one undifferentiated pass.

> **[FRAMEWORK] Role-as-agent is a validated decomposition.** ViMax (HKUDS) orchestrates ~12 film-crew agents (Director, Screenwriter, Producer, Video Generator, Storyboard Artist, Scene/Shot planners…) under a **central orchestrator** that owns scheduling, stage transitions, and retry/fallback. Borrow the *decomposition + orchestration*; ViMax is a cinematic story-video tool, so don't import its long-narrative assumptions into a 20-second promo.

## The pipeline (ordered, but loop/retry as the orchestrator)
`brief → strategy → script/copy → storyboard + shot list → asset/production → edit → sound → color → motion/VFX → delivery → distribution/measure`
**[FRAMEWORK]** Mirror an *ordered-but-agentic* stage sequence under a central orchestrator: input → orchestration (scheduling · stage transitions · resource mgmt · retry/fallback) → script understanding → scene & shot planning → asset planning → indexing → consistency/continuity → synthesis & assembly → output. Adopt the **order** as a template; allow orchestrator-driven loops/retries (it's not a rigid assembly line).

## Pre-production artifacts to generate (between script and build) [SPEC-adjacent, verified set]
script breakdown · storyboard · shot list · schedule (stripboard) · mood board · budget.
**For an HTML/HyperFrames build these fuse:** `.hyperframes/expanded-prompt.md` *is* the script-breakdown + storyboard + shot-list; the extracted brand design-tokens *are* the mood board; "schedule/budget" ≈ scene count, render time, and effort scope. Generate the artifact's *intent* even when the medium collapses it.

## The roster — each role: what it owns · its input · what it hands off · the hat
- **Creative Director** — owns the *big idea* and the final taste bar; guards brand voice; says "no." Hat (Phase 0 brief + Phase 8 final review): *"Is this ONE coherent idea, unmistakably on-brand, worth screenshotting?"*
- **Brand / Creative Strategist** — owns audience, the core insight, message hierarchy, the ONE thing to land, and the CTA. In: brief. Out: a one-line strategy + the core message + success metric. Hat (Phase 1).
- **Copywriter / Scriptwriter** — owns the *words*: hook, script beats, on-screen captions, CTA; applies hook→USP→CTA and PAS. Out: script + caption list. Hat (Phase 3).
- **Storyboard Artist** — owns the frame-by-frame beat plan: what's on screen each moment, entrances/exits, the hero frame. Out: storyboard. Hat (Phase 3 + "layout before animation").
- **Art Director** — owns the *look*: type system, color, composition, grid, density, the distinctive (non-default) aesthetic. Out: style spec from the real brand tokens. Hat (Phase 2 token-mining + Phase 3).
- **Producer / Project Manager** — owns scope, sequence, in/out decisions, schedule, and *cutting the weak section*. Hat (Phase 0 task list; ruthless scoping throughout). *"What earns its place? What do we cut to make it stronger?"*
- **Director** — owns performance, pacing, and emotional arc across the whole cut; the rhythm and where the peak lands. Hat (Phase 3 rhythm + Phase 5).
- **Director of Photography** — owns the "shot": framing, motion, light, depth, lensing. For motion-graphics: composition, camera moves (push/parallax), focal hierarchy. Hat (per-scene framing in Phase 5).
- **Motion Designer** — owns animation: easing, the 12 principles, kinetic type, entrance/exit choreography, transitions. Hat (Phase 5 build; defer to `gsap`).
- **Video Editor** — owns the cut: cadence, the cut vocabulary (jump/punch/J-L/match/cutaway), beat-sync, the assembled structure. Hat (Phase 5 timeline).
- **Sound Designer / Composer** — owns music bed + SFX + mix + loudness (LUFS). Hat (Phase 6 audio).
- **Colorist** — owns palette consistency, contrast, mood, and the grade. Hat (Phase 2 tokens + Phase 7 contrast gate). *"Is the palette consistent and does every text clear contrast?"*
- **VFX / Compositor** — owns effects, layering, polish (flashes, glows, shaders, overlays). Hat (Phase 5 effects).
- **VO Talent / Casting** — owns the voice, if any (register, pace, energy). Hat (Phase 1 audio decision; TTS via `hyperframes-media` or a music/VO MCP).
- **Social / Distribution Strategist** — owns format per platform: aspect ratio, length, captions, safe zones, the post copy. Hat (Phase 1 format + Phase 9 delivery).
- **Performance / Analytics** — owns "did it work": hook retention, CTR, completion; feeds the next iteration / A-B. Hat (post-delivery; propose what to test next).

## How the solo agent uses this (hat → phase map)
- **Phase 0** (goal/scope): *Producer.*
- **Phase 1** (lock direction): *Strategist + Distribution Strategist + (VO casting).*
- **Phase 2** (research, mine real tokens): *Art Director + Colorist + CD taste.*
- **Phase 3** (blueprint): *Copywriter + Storyboard Artist + Art Director + Director (rhythm).*
- **Phase 5** (build): *Director + DP + Motion Designer + Editor + VFX.*
- **Phase 6** (audio): *Sound Designer / Composer.*
- **Phase 7–8** (gates + visual review): *Colorist (contrast) + CD (final taste bar).*
- **Phase 9** (deliver + iterate): *Distribution Strategist + Performance/Analytics.*

A handoff that fails a downstream role's check goes *back* (orchestrator retry), not forward — e.g. the Colorist's contrast gate failing returns the frame to the Art Director, not into the render.

## Sources
ViMax / HKUDS (role-as-agent + orchestrator — [FRAMEWORK], primary repo); StudioBinder + Boords (pre-production artifacts — verified set); premiumbeat / vmgstudios / ziflow / krock / sublightagency / journalism.university (role definitions + pipeline — [CRAFT], practitioner blogs; per-role specifics are convention, not first-party-verified).
