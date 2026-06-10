# Launch-video craft — hooks, structure, editing, sound, motion

The craft layer: how to make it *grab and hold*. Read alongside `agency-roster.md` (who decides what) and the `hyperframes`/`gsap` skills (how to build it).

## Evidence tiers (honesty discipline — obey this)
Tag every claim you rely on; never launder a heuristic into a fact.
- **[SPEC]** — platform-official, first-party, verified. Follow as a rule.
- **[FRAMEWORK]** — named, cross-corroborated industry framework. Use as the named tool.
- **[CRAFT]** — established practitioner convention. A strong default, not a law.
- **[UNVERIFIED]** — a common rule-of-thumb that *failed* adversarial verification. You MAY use it as a soft instinct; you must NEVER assert it as fact or quote its numbers.

> **Do NOT state these as fact (they were refuted):** any "X% retention at 3 seconds" checkpoint; "strong hooks get 4–7× impressions"; fixed segment proportions ("hook 1–3s / body 70–80% / payoff 10–20%", "optimal 20–40s"); "change a visual every 3–5s / never talk >8s"; "layer 3 hooks → ~90% retention"; "70% retention via peak-end"; "sound increases Shorts conversions >20%". Don't invent retention statistics. If you need a number, label it "(rule of thumb, unverified)".

---

## 1. The hook — the most important 1–3 seconds
- **[SPEC · TikTok ads]** Prioritize the hook in the **first 6 seconds** (drives engagement/watch-time); land the **content proposition in the first 3 seconds** (drives recall). Source: TikTok Creative best-practices (performance ads).
- **[CRAFT]** Open ON the value or the tension — never on a logo/preamble. The first frame must be playable/legible instantly (works muted, on autoplay).
- **[FRAMEWORK] Hook archetypes** — a *non-exhaustive* starter library; combine and extend, don't treat as closed:
  - **Bold Statement** — a declarative claim that challenges conventional wisdom.
  - **Question** — ask exactly what the audience desperately wants answered.
  - **Pattern Interrupt** — an unexpected visual / sound / motion that breaks the scroll.
  - **Proof-First** — lead with the result, evidence, or credential.
  - (+ curiosity-gap, POV, pain-point, loss-aversion, social-proof.)
- **[FRAMEWORK] Three escalating hook levels** — engineer *above* level 1:
  1. (weak baseline) restate the title/premise — do better than this.
  2. **match** opening visuals + audio to the promise (show, don't just say it).
  3. **reaffirm the emotion** that earned the attention (curiosity / tension / surprise). *"Viewers click on feelings, not titles."* Deliver on the packaging promise immediately.

## 2. Structure & copy
- **[SPEC · TikTok ads]** Ad spine: **hook → unique selling points → clear CTA.**
- **[FRAMEWORK] PAS** — **Problem → Agitation → Solution.** Open on a problem; intensify it so it feels worse than first perceived; then present the product as the solution. Reliable across ads, landing pages, and short-form (Dan Kennedy: "the most reliable sales formula"). Caveat: don't over-agitate into manipulation.
- **[CRAFT] The ONE emotional core.** Find a single emotional arc and build the whole piece around it — loss→comeback, tedious→effortless, before→after, fumble→flex. Spend your boldest motion + sound on the payoff (the peak), not the setup.
- **[CRAFT] CTA.** End on one unambiguous action + the destination (URL/handle). One CTA, not three.
- Other named tools (use the *structure*, don't cite unverified origins): AIDA (attention/interest/desire/action), before/after, problem→solution, listicle.

## 3. Editing — the cut vocabulary [CRAFT]
Translate to HyperFrames: a "shot" = a scene/clip; "cut cadence" = scene durations; "beat-sync" = aligning scene/animation events to the audio hit-points in your timeline.
- **Cut fast early** to grab; you can widen the cadence once the viewer is committed. Cut *on* audio transients (kick/snare/word-onset) — edits feel intentional and musical.
- **Jump cut** — compress time / inject energy (hard, same framing).
- **Punch-in / push** — instant scale-up for emphasis ("the reaction", the stat landing). The single cheapest energy move.
- **J-cut** — audio leads the picture (you hear the next scene before you see it) → smooths *into* a scene.
- **L-cut** — audio lingers past the picture → smooths *out* of a scene.
- **Match cut** — continuity of shape / motion / graphic across a scene change → feels designed.
- **Cutaway / B-roll** — cover + context; hide jumps; add texture.
- **Speed ramp** — accelerate into a hit then snap to a hold; a few frames, synced to a transient. Momentum on the cheap.

## 4. Motion design [CRAFT]
- Every element earns a verb; offset the first move 0.1–0.3s (never t=0); vary eases (≥3 per scene) and durations (slowest ≈ 3× fastest); enter from varied directions; nothing fully static (ambient drift/pulse so the frame stays alive).
- **The 12 principles** (apply to graphics): timing & spacing, slow-in/slow-out (ease), **anticipation**, **follow-through & overlapping action**, squash & stretch, arcs, **staging** (lead the eye), exaggeration, secondary action, weight/solidity, appeal, straight-ahead vs pose-to-pose. *Anticipation → ease → follow-through* are the high-leverage three for promo motion.
- Build/breathe/resolve per scene: enter (staggered) → hold (one ambient motion) → exit/handoff (faster than the entrance).

## 5. Captions / kinetic typography [CRAFT]
- Burned-in captions are the default — most viewers watch **muted**. The video must carry meaning silently.
- Big, legible, high-contrast; **one phrase at a time**; pop on the beat / word-onset; keep inside the platform safe zones. Captions are a retention device (faster comprehension) and a hype device (the "narration").

## 6. Sound design [CRAFT]
- **Layers:** music bed (energy + structure) + SFX punctuation (impacts / whooshes / pops / ticks) + optional VO.
- **Land the moment as one:** sync the cut + the SFX hit + the visual punch to the same transient.
- **Make SFX cut through:** duck/sidechain the music under VO and key hits — or mix the bed LOW and the hits HIGH. (Loudness-normalization scales everything uniformly, so it *preserves your bed:SFX ratio* — set the ratio in the mix, not after.)
- **Loudness:** master to a platform-appropriate integrated loudness (social ≈ **−14 LUFS**; quieter bed −16/−23). Verify non-silent + true-peak below clipping.
- Pipeline for this skill: generate bed (structured `composition_plan` so the drop lands on the peak beat) + SFX, mix in ffmpeg (`adelay` each hit → `amix` → `alimiter`), master/verify with `muse`. See the main SKILL Phase 6.

## 7. Transitions — choose by intent [CRAFT]
hard cut = default / energy / comedic timing · crossfade = "this continues" · blur/whip/zoom-through = velocity-matched camera move · dip-to-color / overexposure = scene or register change · glitch / chromatic = tense / digital. High-energy promos: mostly fast cuts + a *few* bold transitions on the peaks — don't transition every scene (it flattens impact).

## Sources (this layer)
TikTok Creative best-practices (ads.tiktok.com/help — [SPEC]); readstoleads / Dan Kennedy on PAS ([FRAMEWORK]); opus.pro hook formulas + 1of10 hook levels ([FRAMEWORK], vendor/practitioner); descript cut taxonomy, ramd.am beat-sync, opus.pro loudness, studio2a 12-principles ([CRAFT], practitioner blogs). Re-verify platform timing before any production launch — specs drift.
