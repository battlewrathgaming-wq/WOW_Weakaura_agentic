# Test: Stamina → pet-scaling loop (Animation)

**Date:** 2026-07-27 · **Level:** ~53 · **Spec:** Animation
**Question:** Is Stamina a real damage stat, and does a minion's inheritance
scale multiplicatively or additively with its Life Force?

## Method

Two Raised minions out simultaneously — **Ghoul (Life Force 1)** and
**Abomination (Life Force 3)** — so both share the same player state; the only
difference between them is Life Force. Record player Stamina, player "Bonus
damage" (= Spell Power), and each pet's HP, at baseline vs. after adding
Stamina. **Pets confirmed dynamic (not snapshot)** — stats update live on buff.

**Stamina sources:** Boneward (`681528`, +10% stam) + Foul Mandate (`573297`).

## Data

| Metric | Baseline | Buffed | Δ |
|---|---|---|---|
| Player Stamina | 203 | 285 | +82 |
| Player Bonus damage (SP) | 243 | 286 | +43 |
| Ghoul HP (LF1) | 1546 | 1737 | +191 |
| Abom HP (LF3) | 4617 | 5356 | +739 |

## Findings

1. **Dynamic, not snapshot** — pet stats updated live when stam changed (no
   re-summon needed). → buff *then* fight is fine.
2. **Life-Force scaling is MULTIPLICATIVE, not additive.** ΔAbom / ΔGhoul =
   739 / 191 = **3.9** (additive would be ~1.0; ~3 = the 3:1 Life Force ratio, a
   touch steeper). Per Life Force: Ghoul +191/LF, Abom +246/LF → big minions
   convert your stam modestly better per LF point.
3. **The loop's middle is live and priced.** Player SP rose +43 off +82 stam →
   **~0.5 SP per 1 Stamina** — matches Grey's "stam ≈ int ≈ ½ SP."
4. **Caveat:** the 0.5 rate is army-dependent — Sepulchral Might reads *total*
   Raised-minion Stamina, so it scales with how many/how big your pets are, and
   drops toward zero with no pets up.

## Verdict

Stamina is a confirmed **damage + survival** stat for Animation, ≈ Intellect on
the damage axis. Boosting Boneward / Foul Mandate is a damage line. Favour
high-Life-Force minions.

## Follow-up (would sharpen)

One more run with a mid-size pet (Banshee LF2 / Gargoyle) to confirm the exact
Life-Force slope (true linear ×LF vs slightly steeper).
