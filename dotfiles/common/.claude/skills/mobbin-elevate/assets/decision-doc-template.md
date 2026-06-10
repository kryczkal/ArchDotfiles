# Elevate decision doc — <screen name>

> Internal scaffold. The user rates the rendered visuals, not this doc — but writing it is what stops you
> from "look at picture → write CSS." Keep it concrete: every change bound to a file + token + a reason.

## Read-the-room (Step 0)
- **Target screen:** <one screen>
- **App's distinct identity:** <from its design doc / brand — what makes THIS app not-generic>
- **Real tokens (from files):** font(s) `<…>` · accent `<…>` · neutrals `<…>` · radius scale `<…>` ·
  spacing unit `<…>` · motion lib `<…>`
- **Reuse:** <existing components / tokens / motion vocabulary I will not reinvent>
- **Will NOT change:** <explicit out-of-scope>
- **Live bans from the app's own doc:** <e.g. ships Inter but doc bans it → in-scope>

## Direction (Step 1)
- **Comparable apps (by job):** <2–4>
- **Committed tone:** <e.g. loud-celebratory vs calm-precise>
- **Category-guess test:** <pass/fail + how it's anchored to the app's identity>

## Sources (the coherent kept set)
| app_name | screen id | aesthetic register | why kept |
|---|---|---|---|
| | | | |

(Dropped for incoherence: <app + id + why>)

## Converge → adopt all  ·  Signature → adopt exactly ONE
Per fixed axis, what 3–4 of the coherent set do alike (= the category's language → adopt), then the one
signature move:
- **Layout / where the eye lands:** <convergence> — *why it works:* <…>
- **Type (display:body ratio + weight contrast):** <e.g. ~2.4×, 800 vs 400> — *why:* <…>
- **Color roles (where saturation lands):** <…> — *why:* <…>
- **Spacing (gap-between:gap-within):** <e.g. ~2×> — *why:* <…>
- **Key component anatomy:** <…> — *why:* <…>
- **States visible:** <…>
- **THE ONE SIGNATURE (adopt only this one):** <app + id + the move>

## Recommended changes (each bound to file + token + intent, on the app's OWN scale)
| change | file | token / prop | new value (ratio on app's scale) | intent (one sentence) |
|---|---|---|---|---|
| | | | | |

## The one motion moment
- **Moment:** <what reveals> · **curve/spring:** <…> · **duration:** <…> · **reduced-motion:** <fallback>

## Deliberately reject
- <what I'm NOT taking from the references, and why — brand-fit or coherence>

## Cheap gates
- [ ] Category-guess  [ ] Anti-reference  [ ] Squint  [ ] Closed token budget

## Variants to render
- baseline (current, unchanged) — always
- V2 (reference-true) — mandatory · caption: <levers dialed + before→after delta>
- V1 / V3 — only if magnitude is in question
