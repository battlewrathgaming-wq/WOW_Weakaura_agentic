# Macro house style (Battlewrath) — the grammar our macros follow

_**Design, not fact** — Battlewrath's choices, resting on the proven basis. Recorded so every macro
we build follows ONE modifier language (the "engrain what I already do" goal made literal). The
facts each choice rests on are cited; the composition is his seat (taste/feel). Est. 2026-07-17,
during the Reaper macro-design session, after his keybind reorg._

## Why a convention at all

CoA classes carry **a lot of buttons** — throughput, situational, cooldowns. The convention exists
to keep the *modifier meaning* identical across every macro, so muscle memory is universal: the
same modifier always means the same kind of thing, whatever the class or ability.

## The modifier language

| input | means | rests on |
|---|---|---|
| **base press** | the **sequence** — throughput / rotation compression | `castsequence.md` |
| **shift** | the **situational** alternate — `[mod:shift]` branch | `[mod:shift]` proven (`conditionals.json`) |
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

## The template

```
#showtooltip
/cast [mod:shift] <situational>
/castsequence reset=ctrl/target <throughput spells>
```

Base press → the throughput sequence · shift → the situational override · ctrl → restart the
sequence · (alt → hardware row, never referenced in the macro).

## Why MANUAL layering, not automatic branching

The proven **out-of-range no-fallthrough** (`execution-model.md`) means an automatic *"cast A, or B
if A is out of range"* macro **cannot be built** on this client. Manual layering sidesteps it
entirely: the out-of-range whiff only ever hits the **deliberate shift-branch you chose to press**
— the default (no modifier) always reaches the sequence. So the manual convention isn't a
consolation for the missing range-fallthrough; it's the shape that makes that limit irrelevant.

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

## Standing

The composition is **Battlewrath's seat** — design, feel, subtlety. What it rests on is fact:
`macros/basis/execution-model.md`, `macros/basis/castsequence.md`, and the proven conditionals
(`[mod:shift]`, `[mod:ctrl]`). This file says *how he chooses to compose* those facts; it never
asserts a new one. If the composition changes, edit here — the basis underneath doesn't move.
