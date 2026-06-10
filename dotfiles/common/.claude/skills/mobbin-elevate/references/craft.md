# references/craft.md — the taste rubric (levers, frame-of-mind, motion, gates)

**The one cause behind "AI-ish".** AI emits the weighted average of its training set — generic by
construction. The cure is **commitment**: one job made loud by suppressing everything else (one accent,
one light, one hero, one voice, repeated). So beauty is the *visible residue of subtraction* — the
amateur asks "what can I add to look finished?", the designer asks "what can I remove and still do the
job?", and a neon multi-stop gradient is not a color mistake but the *signature of non-commitment*.

## Frame of mind (adopt before touching a pixel)

- **Subtract from a single job; don't add toward completeness.** Name the screen's ONE job as a verb.
  Bad design = many uncoordinated decisions; good design = fewer, coordinated, intentional ones.
- **Think in roles, not elements.** Not "this card needs a heading" but "this is a *label*, this a
  *value*, this *micro*." A closed set of 3–4 type roles + one accent, reused everywhere. Consistency
  comes from the small vocabulary, not from styling each thing well in isolation.
- **Master the boring codes first, then bend exactly ONE.** Innovation = mastery of the established
  codes (8pt grid, one type scale, one accent) + a single surprise that distorts them from within. AI
  apes the *signifiers* of premium (gradient, glow, glass, multi-accent) without mastering grid, type
  scale, or color discipline → maximum surface disruption, zero tension. Bend one thing, hard; keep the
  rest disciplined and quiet. Real design holds a contradiction in tension (dense data rendered calm;
  playful copy in an austere layout); amateur design picks one register and floors it.
- **Spend a budget.** One loud move bought with surrounding silence. For every signature gesture you add,
  remove or mute two nearby elements. Personality is a function of *contrast*, and contrast needs silence.
- **Design for someone in particular; be opinionated.** A look that offends no one excites no one — that
  is the *convergence trap*, and it is exactly what a generic "polished" default is. The spec is a floor,
  not the goal. Pick a real user and a real attitude, then commit past what the category dares.
- **Best ≠ best-fit; ship the fit.** Score options on TWO axes — absolute craft AND fit to the product's
  identity/register — and when they disagree, *fit wins for what you ship*. The most objectively beautiful
  option can be the wrong one: a serene minimalist home is gorgeous but wrong for a loud competitive game.
  Keep the best-overall as a quality benchmark; ship the best-fit.

*(What designers refuse — second accent for variety, full-sat hues, filling empty space, magic numbers,
animating everything, OS-as-illustrator, deferring the choice to the user — is enumerated with its
positive replacement in **Conditional bans** at the foot of this file; lead with the levers, not the
don'ts.)*

**iOS-native craft is the quality north star.** Apple-grade iOS is, as a class, more "designed":
deference (chrome recedes so content leads), materiality + depth (system blur/translucency, layered
surfaces over heavy shadow), SF-grade type and optical spacing, restraint, physical motion. For mobile
work query Mobbin with `platform: ios`, study Apple's own apps, and treat their decisions (grouped inset
lists, large titles, generous margins, one tinted accent, system materials) as a high prior on premium.

## Levers, ranked by leverage

Apply the ones the references actually use; recalibrate *magnitude* on the app's own scale, never import
foreign numbers. **TIER 1 removes ~70% of the "AI-y" read at zero taste cost — it is pure discipline,
not talent. Clear it first; most AI builds never do.**

### TIER 1 — structural (discipline, not taste)

1. **One job, one hero; suppress everything else.** Give the hero 40–70% of the visual mass (or 4–8× the
   next element) AND actively *down-pop* the rest — smaller, dimmer, borderless, pushed to an edge.
   Hierarchy is two-directional: pop one thing AND un-pop the others. Build it from **weight + color
   first, size last** (two items the same size can still read primary/secondary). On mobile, the ONE
   primary action sits loud and *low* in the thumb zone — if a returning user must scroll to reach what
   the app is *for*, the architecture is wrong however polished the surface. *AI does instead:* even-weight
   card stacks; "make it bigger" by 1.2× while everything stays loud (a democracy of elements).

2. **One accent on a ~95%-neutral, tinted canvas; saturation is scarce and semantic.** Spend saturation
   like money — on one characterful accent, placed only where the eye must go (the hierarchy peak / the
   live state / the one action). **Solve hierarchy in grayscale first; color only amplifies an already-
   correct structure.** The invisible tell of a *designed* palette: neutrals **tinted 2–8% toward the
   accent's hue** (never pure `#000/#fff/#808080`), and the accent **desaturated ~15–25% and hue-shifted
   off the picker default** — that off-true quality is the whole signal. Build state shifts in OKLCH so
   hue/chroma stay stable (implementation craft, not a Mobbin finding —`oklch(from var(--accent) …)`). Empirical: humans use ~5 colors, AI ~11, and humans score 2.3× on quality.
   **When the user says "too AI," suspect the palette first** — kill the gradient-as-background and surplus
   accents, offer a few restrained options, let the human choose. *AI does instead:* gradient-as-foundation
   (saturation is the field, not the signal), multi-accent with no owner, max-chroma straight off the picker.

3. **One grid, honored everywhere (the invisible load-bearer).** One spacing scale (4/8 base), one radius,
   one alignment spine, zero off-scale values. **Group by space + faint ground, not boxes and borders:**
   gap-*between* groups ≥ 2× gap-*within*. Drop borders on secondary cards; avoid double-bounding (card +
   border + shadow + gap at once). The "expensive" feel is *largely the absence of tiny inconsistencies* —
   nobody says "nice 8px grid," they just say "this feels solid." **This single fix removes the largest
   share of the "everything's a bit off" feeling at zero taste cost.** *AI does instead:* magic-number
   drift (radius 11/14/18/26 coexisting), border-everything, machine-uniform `gap-4` (which itself reads
   generated).

4. **Restraint over density — cut the infodump.** Premium screens show *less*: fewer competing blocks,
   fewer labels/badges/pills, more calm. Cut anything not essential to the job; collapse repeated stats
   into one quiet line; leaving a screen 40–70% empty *is* the premium signal. Calm is the visible
   signature of decisions made *for* the user (what to cut) instead of deferred *to* them (here's
   everything, you sort it). *AI does instead:* over-includes — can't tell which 20% matters, so ships
   100% and lets density substitute for judgment.

### TIER 2 — materiality & depth (a little craft)

5. **Depth from ONE light, not a shadow preset on every box.** Decide where the light is (top, slightly
   front); every shadow falls the same way (soft, downward, low-opacity ~0.06–0.08, tinted toward the
   element's hue — not pure black). Elevation is a strict order. In **dark UI**, separate surfaces by
   tone/value steps + a 1px top hairline, NOT heavy shadows; in light UI, the card is *whiter* than the
   ground. Physically-coherent light is processed pre-cognitively as "real"; mixing a hard drop shadow
   with a colored glow = two light sources = reads uncanny/cheap before the viewer can name why.

6. **Gradients vary BRIGHTNESS within ONE hue.** A good gradient keeps hue near-constant and varies
   lightness — it reads as a surface catching light. Beautiful gradients vary brightness within one hue;
   lunatic gradients vary hue across the wheel at full saturation. Add **grain/noise** over large gradient
   fields to kill banding and read as material, not CSS fill. Buy depth with a blur glow / radial vignette
   *inside the same hue family*, never an extra accent. *AI does instead:* full-bleed max-sat far-apart-hue
   ramp (cyan→magenta) with a muddy crossover band and visible banding.

7. **Type is lumpy on purpose: 3–4 styles, a violent 2–4× display:body ratio, weights at the extremes.**
   Count distinct type styles: great screens ~3–4, AI screens 8–12. The display:body jump is *violent*
   (2–4×) with nothing in the gap — **use the jump the reference (or the app's doc) implies; never impose
   a clean 1.25× modular scale** (even ratios are themselves a slop tell). Weights are regular (400) +
   black (700–900), with *color/opacity* doing the third tier — not a middle weight that smears. Labels
   recede (tiny, ALL-CAPS, tracked, dim); values advance (large, tight, full-strength). `tabular-nums` on
   any number. Tracking down as size goes up; leading tightens toward 1.0 at display. Keep ≤2 weights and
   ≤2 text colors per screen.

### TIER 3 — the soul layer (turns "clean" into "ownable" — needs a point of view)

8. **Content is real, specific, and voiced — the irregularities are the fingerprints.** *Cheapest-to-fix,
   highest-signal axis.* Reseed every number non-round and lopsided (`1,247` not `1,200`; a *tie* on the
   leaderboard); make handles degenerate-human (`sarahdactyl27`); rewrite every generic system string
   ("Submit"/"Play") into the product's voice ("Run it back"); coin one brand-owned verb; quantify a value
   prop with one specific number + a footnote. **Voice lives in the irregularities; AI lives in the
   regularities** — it defaults to the *regular* choice at every fork. Never `47.2%` faked as `50.0%`,
   never `John Doe`.

9. **A repeated signature on ≥3 surfaces (ONE axis pushed to an extreme).** A signature is one decision
   pushed past what the category dares, while everything else stays disciplined and quiet. Used once it's
   a costume; *repeated* across screens it's an identity. Pick ONE axis — voice, OR a letterform, OR a
   mascot/world, OR an accent behavior, OR a shape grammar — and go all in. **A signature shape/world is
   more ownable than a signature color** (colors are exactly what AI reaches for). Add *at most one*
   flourish on top of the structure; never let a flourish substitute for the structural change.

10. **Assets are a cast from one hand; the OS is not your illustrator.** One icon family, one stroke, one
    optical size; never mix sources (Lucide + Material + emoji is the #1 tell). Custom illustration earns
    its place by carrying voice and *recurring as a consistent cast*; imagery sets tone and the chrome
    defers to it; the brand mark is one confident shape that survives monochrome at 24px. Optical (not
    mathematical) centering; concentric radius (inner = outer − padding).

11. **Off-happy-path states are first-class; spend the motion budget on one of them.** Design empty /
    loading / error / success with the same care as the populated view: shape-faithful skeletons that
    prevent reflow (not spinners); empty = a message + one teaching CTA; error = human language + retry +
    keep the brand backdrop; success = one big restrained moment, then get out of the way. Communicate any
    state through ≥2 redundant channels (fill + border + icon), never color alone. Full interaction matrix:
    hover, `:focus-visible` ring, `active:scale-[0.97]`, real disabled, hit area ≥44×44px. The one moment
    that earns motion is usually this success/reveal transition — author its timing/curve per **Motion
    craft** below. *AI does instead:* builds only the one screenshot it was asked for;
    `if(!data) return <p>No results</p>`.

## Motion craft (you author this — Mobbin has none of it)

One subject per transition; sequence beats (stagger is the cheapest premium upgrade); give layers physics.
- Custom **ease-out** (`cubic-bezier(0.22, 1, 0.36, 1)`), never `ease-in-out`/`linear`.
- Micro-interactions 150–300ms; the one big reveal ≤~1.2s. Exit ~20% faster than enter; stagger ~30–50ms.
- **Origin-aware**, **transform/opacity only** (never `width`/`height`/`top`). Start `scale(0.94)` +
  `translateY(8px)`, never `scale(0)`. Sheets slide from an edge over a receded parent.
- Spring for snappy/interruptible reveals (`stiffness 400–500, damping ~30`); fixed tweens only for
  one-shot non-interruptible moments. Prefer one spatial morph (a number counting up, a card settling)
  over many independent twitches. Always honor `prefers-reduced-motion: reduce`.
- **Discover capabilities — don't hardcode them.** The motion moment and component/state polish are
  usually better served by something already in the environment than hand-rolled. Route to the project's
  own animation library and design system first, then any installed skill that fits (scan available-skills
  / `find-skills`). This skill names no sibling on purpose, so it stays idempotent. Match what the project
  already uses before adding anything.

## Cheap gates (model-checkable, run before you render)

- **Centroid test:** could someone guess the theme + palette from the app's *category alone* (or from
  category + your stated anti-references)? If yes you've landed on the centroid — re-anchor to the app's
  distinct identity and commit harder.
- **Squint test:** blur it — is the hero still obviously dominant and the one CTA findable? Else raise
  weight/color/size contrast (in that order).
- **One-light test:** is there exactly one light source? Two (drop shadow + colored glow) reads uncanny.
- **Grayscale test:** does hierarchy survive with color removed? If color is load-bearing for hierarchy,
  the structure is wrong.
- **Closed token budget:** every token has exactly one named job; nothing enters undeclared. If the app
  has a system, recalibrate *magnitude* — don't spawn parallel tokens. (Tokens only — layout, hierarchy,
  and IA are always fair game to rebuild.)

## Conditional bans (apply ONLY when the app commits them — lead with the levers, not these)

Each ban with its positive replacement:
- rainbow / multi-stop / full-bleed gradient → one committed accent; if a gradient survives, one hue,
  varied brightness, grain on top (lever 6)
- indigo/purple-by-default, multi-accent → one committed brand accent, desaturated + hue-shifted (lever 2)
- pure `#000`/`#fff`, gray-on-color de-emphasis → off-black/off-white tinted toward the brand hue
- generic `Inter` body / 8–12 type styles → 3–4 roles, a characterful display face (lever 7)
- a single flat gray drop shadow → one-light elevation scale (lever 5)
- centered hero + three equal cards → asymmetry, one dominant block (lever 1)
- `ease-in-out`/`linear`/`scale(0)` entrances → custom ease-out from `scale(0.94)`
- emoji as structural meaning → a real icon in the app's icon family (lever 10)
- round/tidy placeholder data (`1,000 XP`, `John Doe`) → reseeded irregular, voiced content (lever 8)

**Override:** if the target app's OWN design doc declares one of these a live violation (e.g. it bans a
brand font it still ships), that ban is in-scope — the app's doc beats this generic list.
