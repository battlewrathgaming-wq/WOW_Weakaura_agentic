# Macro house style (Battlewrath) — the grammar our macros follow

_**Design, not fact** — Battlewrath's choices, resting on the proven basis. Recorded so every macro
we build follows ONE modifier language (the "engrain what I already do" goal made literal). The
facts each choice rests on are cited; the composition is his seat (taste/feel). Est. 2026-07-17,
during the Reaper macro-design session, after his keybind reorg._

## ★ THE GOVERNING RULE — chain the pre-cognition, isolate the reactive

Battlewrath's playstyle, and the criterion above every technique below (2026-07-17, after the
Reaper set was built and **live-confirmed** in play): **play proactively — anticipate the expected
use case — not reactively.**

- **Chain what you can pre-cognition.** A pattern you already know you'll press — the rotation, the
  generator cycle, the AoE/ST filler — is a decision made *in advance*, so a macro can carry it.
  Fire-and-forget *is* pre-cognition made mechanical: the choice is front-loaded, now you just press.
- **Isolate what stays reactive.** An ability on unpredictable timing, a reactive window, a read you
  make in the moment — chaining it would **pre-commit a decision that has to stay live.** It keeps
  its own key, or the shift bar.

**And chain only what is ALREADY a repeatable pattern — observe first, consolidate second.** You do
not chain speculatively; you play it isolated, and *once it reveals itself as repeatable*, you fold
it into a chain. The guard against chaining something that only looked repeatable.

The test for any ability: *is this a repeatable pattern I can anticipate, or a reactive decision I
make in the moment?* Repeatable → chain. Reactive → isolate. Everything below (flatten,
survival-filter, ctrl-reset) governs only the **chainable** half.

This is the project's own method applied to the hands: **extract the pattern observed to be true,
consolidate it into a gear — never invent the gear up front.** Pre-compute what's predictable; keep
judgment free for what isn't.

## Why a convention at all

CoA classes carry **a lot of buttons** — throughput, situational, cooldowns. The convention exists
to keep the *modifier meaning* identical across every macro, so muscle memory is universal: the
same modifier always means the same kind of thing, whatever the class or ability.

## The modifier language

| input | means | rests on |
|---|---|---|
| **base press** | the **sequence** — throughput / rotation compression | `castsequence.md` |
| **shift** | **swaps to the situational BAR** (Bartender paging) — **NOT a macro layer** | `[mod:shift]` proven in the **state-driver path** (live, 2026-07-17) |
| **ctrl** | **reset** — restart the sequence from step 1 | **native `reset=ctrl`**, source-proven |
| **alt** | **row modifier** (mouse-thumb → Alt, hardware). **OUT OF BOUNDS in macros.** | see below |

**Ctrl = reset is a real built-in, not a simulation.** castsequence's own code resets to step 1 when
a modifier named in the reset string is held: `IsControlKeyDown() and reset contains "ctrl" →
SetCastSequenceIndex(1)` (ExecuteCastSequence, ~:855). So `reset=ctrl` makes ctrl+press jump to the
top and cast it — literally "start over."

**Alt is fenced off for a mechanical reason, not just taste.** The mouse thumb sends a real Alt
keypress to reach the alt row, so on that row **alt is always held** — which makes `[mod:alt]`
permanently true (dead weight) and `reset=alt` reset constantly. Shift and ctrl read *independently*
of alt, so alt-row macros can still branch on those; only alt itself is unusable in-macro.

## Shift is a BAR SWAP, not a macro layer (the last flattening)

**Confirmed live 2026-07-17.** The situational layer is offloaded to **Bartender paging** — a
`RegisterStateDriver` (the `statedrivers` domain — "the 2nd consumer of the conditional
vocabulary"), driven by the *same* `[condition]state;…;default` grammar as macros. Holding shift
pages the whole bar to a **situational bar** (Battlewrath's page 10), so the button under your
finger becomes a different button. Consequence: **base-page macros are only ever pressed *without*
shift** → `[mod:shift]` inside them can never fire → **macros collapse to sequence-only.**

The paging string (stealth wins; possess also overrides the voluntary shift; first-match is
left-to-right):
```
[stealth]7;[bonusbar:5]11;[mod:shift]10;[bar:2]2;[bar:3]3;[bar:4]4;[bar:5]5;[bar:6]6;0
```
Every conditional in it is in the proven-supported set (`stealth` proven; `bonusbar`/`bar`/`mod`
supported) **and** proven-by-use. Layout changes are now **native bar edits** (drop an ability
onto page 10), not macro rewrites — the real win Battlewrath was after.

## The template — sequence-only

```
#showtooltip
/castsequence reset=ctrl/target <throughput spells>
```

Base press → the throughput sequence · ctrl → restart it · shift → *the bar swaps* (handled by
paging, not this macro) · alt → hardware row, never referenced. The situational abilities live as
their own buttons on the shift-page bar.

## ★ Bar-swap SHOWS the situational state — a macro cannot (the strongest reason)

Confirmed in-game 2026-07-17. Beyond cleaner macros, the bar swap gives something a macro
modifier **fundamentally cannot**: **persistent state visibility of the situational layer.**

- `#showtooltip [mod:shift] A; B` only ever reflects the **active** branch. Not holding shift, it
  shows A — and B's **cooldown, procs, usability are invisible** until you hold the modifier. A
  macro is **stateless** (the slice's through-line: a macro *reads* state, it never *holds or
  shows* it), so an in-macro shift ability is blind.
- The **situational bar (page 10) is a persistent, state-carrying UI object.** It shows the
  situational abilities' readiness **continuously** — held shift or not. **Input and display are
  decoupled:** bar 1 (paged) is what you *press*; bar 10 is what you *watch*. You can see a
  cooldown coming up and hold shift *because* you saw it. No macro can surface that.

This is the project's bigger split in miniature: macros do the **acting**; when **state must be
shown**, that's a visible object's job (a bar here, a WeakAura elsewhere). The "show the shift
ability's state" problem is solved by not asking the macro to do it at all.

## Auto-fire drives the sequence — and it's SAFE by the pending flag

**Hold-to-repeat** (bar-1 auto-fire) is how a castsequence *wants* to be driven. From source
(`castsequence.md`): the sequence sets `pending` on cast-sent and **refuses to re-fire while
pending** (`if entry.pending then return`), and it **advances only on cast SUCCESS**. So holding
the key walks the sequence **one successful cast at a time** — the repeated presses during a cast
are harmlessly swallowed by `pending` (no double-advance, no wasted casts). Hold to walk; release
+ pause past `reset=N` to return to the opener. (The auto-fire mechanism itself is the Bartender /
key-repeat setup — not asserted here; the *castsequence side* is what makes holding it safe.)

## Why we never auto-branch WITHIN a macro

The proven **out-of-range no-fallthrough** (`execution-model.md`) means an automatic *"cast A, or B
if A is out of range"* line **cannot be built** — the out-of-range attempt eats the press. This is
*why* the situational layer is a **bar swap** and not an in-macro `/cast A; B`: the swap sidesteps
the limit entirely (different button, no fallthrough needed), where an in-macro auto-branch would
have whiffed.

## Tuning `reset=N` to the rotation's rhythm

`reset=N` is a **rolling idle timer** — reset on every press, fires ~N seconds after your **last**
press (`castsequence.md`). Tune **`N ≈ cast-time + grace`** so a natural pause after the last cast
returns you to the opener, but continuous pressing never resets.

- **Scarletta (`reset=…4`)**: the final Bloodmoon Blast cast (~3s) burns most of the 4s window while
  it casts; ~1s of grace remains after it lands, then reset to step 1 (Taldaram's Torment, the dot).
  So the **4 = ~3 cast + ~1 grace**. Set it to 3 and the reset can fire **mid-cast** — the extra
  second is deliberate.

## `reset=target` rider

`target` fires the reset on **any** target-change event, including target **death** (not an
identity compare — `execution-model.md` / `castsequence.md`). On swap-heavy fights that
restart-to-opener is a feature (re-dot / re-engage the new target); if a given macro should **not**
restart on swap, **drop `target`** from its reset string and lean on the timeout instead.

## ★ When to flatten into "keep pressing" — the economic-equivalence precondition

The general pattern this whole convention serves (Battlewrath, 2026-07-17): **"pure tracking and
applying, flattened into keep pressing."**

- **Track = WeakAura** (the show-state side): "does the target lack the debuff?" — passive, watches.
- **Apply = macro** (the acting side): "keep pressing" → more uptime than not. Deliberately dumb.

**The precondition that makes the flatten SAFE: the sequence's elements are economically
equivalent** — same cost, same resource output, differing *only in effect*. Then over-casting any
element is the **same transaction** (e.g. Murder and Dreadwake: both 30 RP, both 1 soul, one
debuffs / one AoE-shreds). Over-refreshing costs nothing extra, so the **dumb sequence is
optimal, not a compromise** — high uptime falls out of "keep pressing" with no smart gating.

**When it does NOT hold:** if the elements differ in cost or output (a costly debuff + a free
filler), mashing wastes the expensive one → a failstate → you'd want precise gating the macro
can't do. There, don't flatten; keep them separate or let the WA-tracked state drive the choice.

**The intelligence is in the SPLIT, not in either half.** The macro stays dumb (keep pressing),
the WA stays passive (just watches); the design decision — *what to track vs what to apply, and
whether the elements are equivalent enough to flatten* — is where all the thought goes. Same
shape as the rest of the project: smarts in the design, parts stay simple.

## ★ Sequence position as a survival filter — targeting-behaviour as an implicit AoE/ST switch

The strongest pattern the session produced (Battlewrath, 2026-07-17). Put the **AoE/equivalent
fillers first** and the **ST/situational payoff last**, with `reset=target`:

```
#showtooltip
/castsequence reset=target Requiem, Requiem, Soulrend
```

**Your targeting is the mode switch, no modifier needed.** `reset=target` fires on the
target-change *event* (`castsequence.md`): tab-cycling resets to the fillers (you stay AoE, never
spend the payoff on someone you're not committed to); settling on one target lets the sequence
advance to the payoff.

**The filler count before the payoff is a SURVIVAL FILTER — it does trash-vs-tanky triage with no
conditional.** To reach the payoff (step 3), a target must *survive the two fillers AND stay your
target*. Trash dies to the AoE → its death fires `PLAYER_TARGET_CHANGED` → reset → it never gets
the payoff. A tanky survivor you've committed to outlives the fillers → reaches the payoff → gets
the ST effect it merits. The sequence position *is* the "does this target deserve the ST spend?"
threshold. Airtight from the proven mechanics (reset-on-event · advance-on-success · wrap), and
**LIVE-CONFIRMED in play 2026-07-17** ("it performs well") — the fire-and-forget converges on the
right behaviour exactly as the mechanics predicted.

**The count also kills the ritual.** *One* filler would force constant tab-targeting to dodge the
payoff — you'd be *performing* the macro. *Two* give slack: **fire-and-forget converges on the
right behaviour anyway.** So tune the filler count to two things at once: the survival threshold
(how tough before it merits the payoff) and the fire-and-forget slack (how little you want to
micromanage).

**Generalises:** payoff-last behind N equivalent fillers → N is a survival threshold that
auto-selects which targets earn the payoff, and buys ergonomic slack. The intelligence is the
*number* — a count, not a conditional. Same thesis as the rest: the macro stays dumb, the design
choice carries everything.

## Standing

The composition is **Battlewrath's seat** — design, feel, subtlety. What it rests on is fact:
`macros/basis/execution-model.md`, `macros/basis/castsequence.md`, and the proven conditionals
(`[mod:shift]`, `[mod:ctrl]`). This file says *how he chooses to compose* those facts; it never
asserts a new one. If the composition changes, edit here — the basis underneath doesn't move.
