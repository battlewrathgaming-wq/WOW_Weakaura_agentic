# castsequence — the one STATEFUL command (how external state mutates a macro)

_A **sourced read**, not a mechanical emission. Every claim cites `Outputs/client_interface/patch-B/Interface/FrameXML/ChatFrame.lua` (the extracted client source, patch-B). Where the source stops, the boundary is marked. Surfaced 2026-07-17 from Battlewrath's own live macros — his Scarletta rotation and Gravekeeper pet sequences are all `/castsequence`._

## Why this file exists — the framing

**Almost the entire macro surface is STATELESS.** Conditionals (`[combat]`, `[form:1]`) and `@`-targets are evaluated **fresh on every press** — they read game state at press-time and nothing persists. `/castsequence` is the **one exception found so far**: it holds a persistent state machine (`CastSequenceTable`), and **external game events mutate that state between your presses**. That is the whole reason it behaves differently depending on what you did since the last press — and the reason it is worth documenting as fact rather than re-derived each time.

Unlike the conditional vocabulary (C-side, provable only by probe), this is **fully Lua and fully readable**: `ExecuteCastSequence` (:817), `QueryCastSequence` (:892), `CastSequenceManager_OnEvent` (:741), `CastSequenceManager_OnUpdate` (:799), and the helpers (:722–739).

## The state, per sequence string (`entry` in `CastSequenceTable`)

- `entry.index` — the current step (1-based). `entry.spells` / `entry.items` — the parsed list.
- `entry.reset` — the lowercased reset string (everything after `reset=` up to the first space, `:837`).
- `entry.timeout` — an absolute idle deadline, when a number is present.
- `entry.pending` — a lock set between cast-sent and cast-resolved (see Advancement).

## Parsing (`:837`, `:842`)

- **`reset=<tokens>`** is captured whole: `strmatch(sequence, "^reset=([^%s]+)%s*(.*)")` — everything up to the **first space** is the reset string; the rest is the spell list.
- **The comma splits the spell list**: `strsplit(",", spells)` (`:842`). So the `castsequence` comma is a **SEQUENCE SEPARATOR** — a different meaning from the conditional comma, which is AND. `A, B, C` = three steps.
- **The `/` inside `reset=` is COSMETIC.** Nothing splits on it. All reset tokens are matched by substring/number against the *whole* captured string (see below). `reset=target/combat/4` and `reset=combat 4 target` behave identically.

## Advancement — on cast SUCCESS, not on press (`:752–782`, `:850`)

- Press → `ExecuteCastSequence` casts `entry.spells[entry.index]`.
- `UNIT_SPELLCAST_SENT` → `entry.pending = 1` (`:772`). While pending, a re-press **does nothing**: `if (entry.pending) then return` (`:850`). This blocks double-advance from spam.
- The index **only advances on `UNIT_SPELLCAST_SUCCEEDED`** (`:775–776`). `INTERRUPTED` / `FAILED` / `FAILED_QUIET` clear `pending` but do **NOT** advance (`:773–774`) — a fizzled cast lets you retry the **same** step.
- Only casts by **`unit == "player"` or `"pet"`** count, matched by spell name/rank (`:764–770`).
- **Auto-wrap**: at the last step, `SetNextCastSequence` calls `ResetCastSequence` back to index 1 (`:733–738`). So spamming *past* the end loops back to step 1 on its own — no reset condition needed.

## The reset triggers — this is the "external state" surface

A sequence returns to step 1 when any of these fire **and** the matching token is a substring of `entry.reset`:

| trigger | fires on | source |
|---|---|---|
| **`target`** | the **event `PLAYER_TARGET_CHANGED`** | `:787–795` |
| **`combat`** | the **event `PLAYER_REGEN_ENABLED`** = **LEAVING** combat (not entering) | `:789–795` |
| **`<number>`** | idle timeout — first number in `reset`; checked every ~1s in `OnUpdate` | `:862–864`, `:799–815` |
| **`shift`/`ctrl`/`alt`** | that modifier **held at press time** | `:855–858` |
| **(always)** `PLAYER_DEAD` | resets **every** sequence, unconditionally | `:744–748` |

## ★ The subtlety that matters: it is EVENT-driven, NOT identity comparison

`PLAYER_TARGET_CHANGED` sets a local `reset = "target"`, then `strfind(entry.reset, "target", 1, true)` decides whether to reset (`:787–795`). **There is no old-target-vs-new-target comparison anywhere.** "target reset" means *"a target-change event fired,"* not *"the target is a different unit."*

Consequences (for a dot-first / multi-dot rotation like Scarletta's `reset=target/combat/4 Dot, Blast×5`):
- Swap enemy A → B → event → reset → dot on B. **The intended multi-dot.**
- Target **dies** mid-blast → the event fires → reset to the dot. Next press re-dots rather than continuing the blast.
- Click off and back onto the **same** unit → two events → two resets, though "nothing changed" by identity.

## Ground-target (`[@cursor]` / `[@player]`) inside a sequence — one target for all steps, and the asymmetry

**[SOURCE]** A castsequence carries **one target for the whole sequence**, not per-step:
`ExecuteCastSequence(sequence, target)` (`:817`) passes the same `target` to every step's
`CastSpellByName(spell, target)` (`:885`). A `[@X]` conditional therefore applies to *every* spell
in the list — you cannot give step 1 one target and step 2 another.

**The ground-target hack in the CASTSEQUENCE handler (`:1153`) treats `@cursor` and `@player`
differently, and the difference decides whether you can MIX a ground spell with targeted steps:**

- **`[@cursor]` NILS the target** — `if castAtCursor then target = nil` (`:1159–1160`), *before*
  `ExecuteCastSequence`. So the non-ground steps fall back to your **current target** and work.
  `[@cursor] Ground, Attack, Attack` drops the ground spell at the cursor and lands the attacks on
  your target. **Mixes cleanly.**
- **`[@player]` KEEPS `target = "player"`** — no nil (`:1164`, `:1166`). So *every* non-ground step
  gets `target = "player"`: a harm attack told to target yourself self-casts / fails / misfires and
  will **not** hit your enemy. `[@player] Ground, Attack, Attack` **breaks the attack steps.**

**Consequence:** you cannot mix `[@player]` ground-at-feet with enemy-targeted steps in one
castsequence. `[@cursor]` mixes fine but places at the cursor, not the feet. **The fix: isolate the
ground-target on its own key** (`/cast [@player] Ground`) and chain the targeted steps separately —
which is also what the governing rule (isolate distinct-targeting) says (`../CONVENTION.md`).

**[CORROBORATION]** External research (retail-WoW community knowledge of the same behaviour)
validates the asymmetry — Battlewrath, 2026-07-17. The **source read is the primary evidence** (it
is this client's own handler); the external match is corroboration, not the basis.

## ★ Cooldowns AS the logic gates — reset-home for cooldown-tiered abilities (Battlewrath's technique, live-proven)

**The macro carries ZERO conditional logic — the cooldowns do the branching.** A step on cooldown
fails, and advance-on-success means the sequence doesn't move past it (the "fail-stick"). So a
cooldown *is* an `if-ready` check, enforced by the game, not written in the macro. There is no
cooldown conditional in the macro grammar and you don't need one — the fail-stick supplies it.

**Structure:** put the **shortest-cooldown ability first (step 1 = "home")** and use `reset=N` to
return there. The fail-stick then catches the longer-cooldown steps opportunistically when they come
up.

**Battlewrath's Necro summon manager (live-proven 2026-07-17):**
```
#showtooltip
/castsequence reset=10 Animate: Skeletal Archer, Animate: Tomb King, Animate: Plaguefather
```
Cooldowns 30s / 60s / 120s. Behaviour, all from the cooldowns + `reset=10` + fail-stick:
- **Archer is home** — recast every 30s; `reset=10` pulls the sequence back to step 1 between windows.
- **Tomb King / Plaguefather are *caught*** when they come off cooldown — you press *through* Archer
  to the ready step, it fires, and the reset returns you home.
- **All three deploy** when all are off cooldown — three presses inside the 10s window before the reset.
- `reset=N` must exceed the deploy-burst (~a few GCDs) so a full deploy isn't interrupted; its size
  sets how eagerly the chain falls back to home. `10` fits this kit.

**The edge — a TRACKING issue, not a macro-logic one** (Battlewrath): you can lock the chain out by
mismanaging the home summon (getting the Archer cadence wrong). The macro is still correct — the
failure is *knowing where you are*, which is show-state: a WeakAura's job, not the macro's. Track =
WA, apply = macro, once more.

**Correcting an earlier claim in this file's history:** a prior turn I asserted castsequence "can't
handle long independent cooldowns / gates behind the longest." **Wrong** — reset-home + fail-stick is
exactly how it handles them, and the cooldowns become the gate for free. The *concern* underneath
(long cooldowns carry a lock-out risk) was real and survives as the tracking edge above; the
*conclusion* (can't be done) did not. Kept as a note because the correction is the lesson.

## The boundary — where source stops (marked, not guessed)

The source confirms **the reset fires when `PLAYER_TARGET_CHANGED` fires.** **Which** target changes actually fire that event — swap, clear, tab-target, target-death — is **event semantics this file does not define.** That part is recall, **not sourced here**. If a design depends on the target-death edge, confirm the event's firing conditions separately (a live observation or an event-behaviour source), do not trust the summary.

## Provenance

Read 2026-07-17 from `Outputs/client_interface/patch-B/Interface/FrameXML/ChatFrame.lua` (the mpyq-extracted study copy; anchor in `basis/_meta.json`). Hand-authored **sourced read** — not emitted by `emit_macro_basis.py`, because a state-machine's semantics are not mechanically extractable the way a command list is. Verify against the cited lines if the fork moves.
