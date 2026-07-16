---
name: neg-tree
description: Adversarial game-tree search for negotiations and strategic exchanges. Use when the user faces a high-stakes move against a counterparty (job offer negotiation, deal terms, any one-way-door message) and wants moves evaluated chess-style — model both sides as players, simulate the opponent adversarially with firewalled context, weight branches by probability, static-eval positions, pick by expected value or maximin. Triggers: "run the tree", "neg tree", "game out this negotiation", "what will they do if I send this", "adversarial pass".
---

# neg-tree — Chess-Style Negotiation Search

Treat the negotiation as a game tree: our candidate moves (root) → opponent responses (ply 1, simulated adversarially) → our best replies (ply 2) → static evaluation → minimax/expectimax at the root → adversarial judge → send the winner with prepared cards for every predicted reply.

Battle-tested provenance: built during the 2026-07 Snowflake/Google negotiation (3 tree runs, 28+ agents, cross-model reconciliation; logs in `~/zen/ops/brain.md/docs/logs/2026-07.md`, prompt artifact `~/zen/ops/brain.md/docs/negotiation-gametree-prompt.md`).

## Step 0 — Objectives interview (do NOT skip; the #1 failure mode is guessed weights)

Extract from the user, explicitly:
1. **Objectives, ranked and weighted** (e.g., outcome-value 0.5, time/optionality 0.2, relationship 0.2, risk 0.1). Ask which are WEIGHTS (tradeable) vs **HARD CONSTRAINTS** (a leaf violating one gets its composite CAPPED — e.g., "they must never be able to force my decision before date X" caps at 6.0/10 regardless of upside). Mis-classifying a constraint as a weight flips verdicts.
2. **Hard behavioral constraints** on our own moves (honesty rules, information that must never leak, channels, phrases to never repeat).
3. **Terminal policy** — what the user does at the endgame wire (pre-committed collision rules). Encode it; leaves are scored against the policy actually played, not a vague "stay flexible".
4. **The calendar** — every real date (deadlines, external events, travel). Stale dates silently corrupt every eval: re-verify them EVERY run (a v2 judge caught an entire tree scored against superseded dates — check eval-spec freshness before trusting any prior run).

## Step 1 — Two firewalled context packs

**OUR pack** (only our-side agents see it): full private situation, objectives + weights + caps, target asks/bundle, hard constraints, known opponent mechanics, calendar, terminal policy.

**THEIR pack** (the ONLY thing opponent-sim agents see): their observables (message history verbatim, what they've been told), their incentive structure (how they're measured, what costs them politically, what they fear), their org context, and — critical — **their OBSERVED style from real behavior**, not archetype priors ("warm, fast, chasing, never put a deadline in writing" beats "recruiters are sharks"). The firewall is absolute: one line of our-side intent in their pack invalidates the sim.

Opponent prompts: **"YOU ARE <NAME>"** — first person, never "you are roleplaying" (the meta-frame weakens immersion). Demand brutal honesty including reactions they'd never say aloud, and their *internal actions* (who they brief, what they pre-clear, what they'll never put in writing), not just their reply text.

## Step 2 — Root move generation (3–5, verbatim texts)

Always include: the expected move, one more aggressive, one more passive, one structurally different (e.g., skip-the-step, info-only, paper-first). Real send-ready texts — the tree evaluates words, not intentions.

## Step 3 — The plies (run as a Workflow; template below)

- **Opponent ply:** per root move, exactly TWO responses with **forced diversity** — one cooperative, one adversarial/clock-forcing — plus honest probabilities summing to ~1, calibrated to observed style. Forced diversity exists because single-engine sims inherit the engine's prior (uniformly-nice or uniformly-hard opponents both produce wrong trees).
- **Our-reply ply:** per (move, response) pair, draft our best reply honoring every hard constraint, then **static eval** 0–10 per axis, harsh grading, one-line justification each, plus a boolean per hard-constraint cap ("can they force X in this line?").
- **Composite** = Σ(weight·axis), then apply caps. Rank roots by **expected composite** (probability-weighted) AND **worst case**. When they disagree, worst case wins for one-way doors.

## Step 4 — Adversarial judge

A final agent gets OUR pack + the ranking + the top-2 lines in full. Mandate: hunt what both plies missed — new traps, constraint violations in our drafted replies, unrealistic probabilities vs observed behavior, money left on the table, stale facts. It may refine the winning text. If it has filesystem access, point it at the live logs — judges that re-verify ground truth catch stale-constraint corruption.

## Step 5 — Converge, humanize, send, card

- **Convergence:** stop when a deeper pass surfaces no new flaws and the opponent's best replies are already carded. Never loop for its own sake.
- **Cross-model check** (stakes-justified): run the same self-contained prompt on a different engine (e.g., `codex exec -m gpt-5.5`); disagreement decomposes into weights/probabilities/missed-traps — adjudicate explicitly. Different engines inherit different priors; disagreement IS the signal.
- **Humanize pass:** the winning text goes through a separate lint (different model works well): low maneuver-density (a mail where every sentence pulls a lever reads as being worked), plain words, minimal em-dashes, no drafted-language tells ("load-bearing"), never repeat a catchphrase verbatim across messages (counterparties detect managed lines). Content frozen, wording free. Adversarial-pass the final wording once more if it changed materially.
- **Cards:** for each predicted opponent reply in the winning line, a ready verbatim response; plus standing cards for known hooks (deadline pins → blur; live conditional closes → defer to writing; ask-flushes → promise the bundle without content). Persist the card deck to a file the user can act from without you.

## Standing doctrine (encode into packs where applicable)

- **Honesty as strategy, not handicap:** build only from true facts; asks must pass the no-negotiation test ("would I want this answer if no negotiation existed?"). True asks are probe-proof and cost nothing to maintain.
- **Channel discipline:** substance only in the channel we control (writing); voice for warmth/logistics; nothing conceded live — "I'll confirm by email."
- **Tempo splits:** be fast in responsiveness, slow in commitment; delay lives in process steps, never reply latency.
- **One-counter budgets:** many counterparties tolerate exactly one formal counter-round — the tree must spend it at maximum information (after key uncertainty resolves), and info-gathering steps are not counters.
- **Information vs deadline geometry:** map whether decisive information (e.g., an interview result) arrives before every forcible deadline — if yes, the worst case is an informed choice, not a blind one; encode as terminal policy.
- **Deterministic beats discretionary:** a later clock-START (via legitimate process steps) outranks reliance on a discretionary extension.

## Workflow template (adapt names/schemas; this ran successfully 3×)

```js
export const meta = { name: 'neg-tree-run', description: '...', phases: [
  { title: 'Opponent ply' }, { title: 'Reply+Eval ply' }, { title: 'Judge' }] }
const THEIR_PACK = `YOU ARE <NAME>. ...observables, incentives, history, observed style...`
const OUR_PACK = `You advise <USER>. ...objectives+weights+caps, constraints, calendar, terminal policy...`
const MOVES = [ { id: 'M1', text: `...` }, /* 3-5 */ ]
const OPP = { type:'object', required:['responses'], properties:{ responses:{ type:'array', minItems:2, maxItems:2, items:{
  type:'object', required:['label','style','probability','message_text','internal_actions','reasoning'],
  properties:{ label:{type:'string'}, style:{type:'string',enum:['cooperative','adversarial']},
  probability:{type:'number'}, message_text:{type:'string'}, internal_actions:{type:'string'}, reasoning:{type:'string'} } } } } }
const LEAF = { type:'object', required:['our_reply_text','axis1','axis2','axis3','risk','cap_violated','eval_rationale'], properties:{
  our_reply_text:{type:'string'}, axis1:{type:'number'}, axis2:{type:'number'}, axis3:{type:'number'}, risk:{type:'number'},
  cap_violated:{type:'boolean'}, eval_rationale:{type:'string'} } }
const lines = await pipeline(MOVES,
  m => agent(`${THEIR_PACK}\n\nThis arrives:\n"""${m.text}"""\n\nTWO responses: one cooperative, one adversarial, honest probabilities...`,
    { label:`opp:${m.id}`, phase:'Opponent ply', schema: OPP }),
  (o, m) => parallel(o.responses.map(r => () =>
    agent(`${OUR_PACK}\n\nLINE: we sent """${m.text}""" — they replied (${r.style}, p=${r.probability}): """${r.message_text}""" internal: ${r.internal_actions}\n\nDraft our best reply + static eval + cap check...`,
      { label:`leaf:${m.id}:${r.style}`, phase:'Reply+Eval ply', schema: LEAF })
      .then(l => ({ move:m.id, p:r.probability, style:r.style, troyMsg:r.message_text, ...l })))))
const leaves = lines.flat().filter(Boolean)
const scored = leaves.map(l => { let c = 0.5*l.axis1 + 0.2*l.axis2 + 0.2*l.axis3 + 0.1*(10-l.risk)
  if (l.cap_violated) c = Math.min(c, 6.0); return { ...l, composite:+c.toFixed(2) } })
// rank by expected + worst per move, judge the top-2, return everything
```

## Output contract (every run)

1. Ranked root table: expected, worst-case, one-line rationale.
2. Winning move, final humanized text, send-ready.
3. Cards: verbatim replies for each predicted opponent response + standing hooks.
4. Traps register (new discoveries flagged prominently).
5. Confidence + the facts that would most change the verdict.
6. Log the run and decisions to the project's session log; persist cards to a file.
