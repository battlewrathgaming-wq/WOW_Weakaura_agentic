# S9 — THE TELEPORT GUARD, measured

_Addons bench, 2026-08-20 (§406). A FINDINGS file: measured, directs nothing. Run at
Battlewrath's ask — **"Should we audit around that? I'll take it to the designer."** — before the
decision goes to design, so it is taken against numbers rather than against two positions._

⚠ Nothing was regolded. `walk.py` was copied to the scratchpad, mutated in place, measured, and
restored from the copy; `--regold` was never passed.

---

## 0 · THE HEADLINE, and it is neither answer

**The goldens do not move — because they are BLIND to the difference, not because the two rules
agree.** The corpus contains four samples the guard would catch, and **no golden covers the runs
they are in.**

⟶ So this is a **coverage gap**, not a rule question. Either disposition of S9 is currently
un-graded.

---

## 1 · S9 VERIFIED — the two rules differ, exactly as reported

    transits          walk.py:569-575   falls back to point_fire on THREE conditions:
                                        a hole · a mapID change · a TELEPORT
                                        (d3(p, prev) / Δgt > v_max)
    broken × 3        :1047 :1159 :1276  falls back on TWO: a mapID change · gap_bound
                                        ⚠ the teleport door is ABSENT from all three

★ And the three `broken` paths are the ones that produce the w5 goldens, while **W7.1 demands the
Lua port be byte-equal to the desk** — so the port would reproduce the narrower rule while W7.2
grades the wider one.

## 2 · MEASUREMENT ONE — adding the guard moves NO golden

`v_max` added to all three recomputations, w5 re-run:

    BASELINE              SFK_live SAME · SFK_Run4 SAME · rfc_combat SAME   exit 0
    WITH v_max IN broken  SFK_live SAME · SFK_Run4 SAME · rfc_combat SAME   exit 0

⚠ On its own this reads as *"the guard is redundant"*, and that reading is wrong. It has a second
reading — *"the sample holds nothing that would trip it"* — and the two are different findings:
one is a fact about the RULE, the other about the SAMPLE. Measurement two tells them apart.

## 3 · MEASUREMENT TWO — the corpus DOES hold samples the guard catches

Direct scan of `addons/landing/corpus/*__legs.jsonl`, same arithmetic as the guard:

    files 16 · samples 11,616 · consecutive same-map pairs 9,731 · map changes 0
    PAIRS EXCEEDING v_max (100 yd/s):  4
    fastest 326.0 · then 288.4 · 286.4 · 140.2      (next-fastest legitimate: 56.9)

★★ **326 yd/s is more than three times the threshold**, and the calibration note says why the
threshold is 100 and not 30: *"a real charge must survive, and only an instantaneous relocation
must not"* (`walk.py:796`, Scythe Rush at 51 yd/s). **These four are not fast charges.**

## 4 · ★★★ MEASUREMENT THREE — and this is the finding

    the four trips are in   RFC_Run2_Messy-2   ×2
                            RFC_Run3_Messy-5   ×2
    the goldens cover       SFK_live · SFK_Run4 · rfc_combat
    overlap                 NONE - grep for either run name in all three goldens: 0

⟶ **The goldens did not move because they contain none of the data that would move them.** The
difference between the two rules is real on real captures; the reference set simply cannot see it.

⚠ **So "adding the guard is free" is true and misleading in the same breath.** It is free
*against the current goldens*, and the current goldens do not test it.

---

## 5 · WHAT THIS CHANGES FOR THE DECISION

★ The question was *"should `v_max` be in the rule or only in `transits`"*. On this evidence it
is better asked as: **nothing grades either answer today.** Whichever the designer takes, the
same gap remains — and it is closable:

    a golden (or a W7.2 synthetic) built from a run that CONTAINS a teleport pair, in a
    `broken` path. The corpus already holds two such runs, so no capture is needed.

⚠ **Filed as a finding, not a proposal.** Whether the reference set gains a fixture is an
acceptance question and this bench does not write W7.

## 6 · THE CADENCE QUESTION — and a bench claim that measurement KILLED

⚠⚠ **This section first argued that a denser sample raises apparent speed toward the
threshold, so an adaptive throttle that speeds up during movement would make a false teleport
MORE likely. It was reasoned, not measured, and the measurement does not support it.**

    fastest LEGITIMATE movement, by run cadence (trips excluded)
      0.2 s runs   5 runs   50.6 yd/s   margin to v_max  2.0x
      1 Hz  runs   7 runs   56.9 yd/s   margin to v_max  1.8x

★ **The margin is ~2x and it is FLAT across cadence.** The 1 Hz figure is slightly HIGHER,
which is the opposite of what the argument predicted.

★★ **Why the reasoning failed, because the shape of the error is worth keeping.** It assumed a
burst SHORTER than the sampling window, so a wider window would average it down. The real
bursts in this game last about a second, so they dominate BOTH windows and the average barely
moves. The premise was a property of a hypothetical burst, not of the ones on disk.

⟶ **So a granular throttle between 0.2 s and 1 Hz is free of this concern in both
directions**, and the guard keeps a stable ~2x headroom wherever the driver samples.

★ And the 0.2 s floor stands on its own footing, unrelated to any of this: it was measured as
what is needed to CATCH a player inside R (`walk.py:790`, `transits(..., cadence=0.2)`) —
a catching requirement, not a teleport one. The two never had to trade against each other.

⚠⚠ **SUPERSEDED 2026-08-20 (RI-34): THE FLOOR IS 0.1, AND IT DOES NOT STAND ALONE.** ★ The
paragraph above is right that the floor is a CATCHING requirement — and that requirement was
measured **with segment in the rule**. Under point + band + gate (A11.2a, narrowed the same day)
there is no chord, so the floor must keep a whole DIAMETER inside one sample step: at R = 5 and
the corpus maximum 56.9 yd/s that is `< 0.176 s`, which **0.2 fails.** ⚠ And it does not stand
on its own footing after all — `MAX_CLOSING_SPEED` owns the APPROACH half and no floor value
can substitute for it — settled at **`MAX_CLOSING_SPEED = 100`**, which is `TELEPORT_VMAX`
itself. ★ The teleport reading here is unaffected; only the floor's status is.

⚠ **What the guard's threshold is NOT calibrated for, and this is the residue:** `gap_bound`
is `2 x cadence`, self-calibrating per run (`cadence_of`, and its note that *"the corpus holds
1 Hz runs and 0.2 s runs"*). `TELEPORT_VMAX` is a FLAT 100 at any cadence. That asymmetry is
harmless at the two cadences measured; it is untested outside them.

## 7 · WHAT THE FOUR TRIPS ARE

    RFC_Run2_Messy-2   gt 2233.9   nearest death  3.3 s
    RFC_Run2_Messy-2   gt 2535.1   nearest death  2.9 s
    RFC_Run3_Messy-5   gt 22428.1  nearest death  3.3 s
    RFC_Run3_Messy-5   gt 22195.8  nearest death 55.8 s   ⚠ UNATTRIBUTED

★★ **Three of four are release-to-graveyard after a wipe** (Battlewrath confirms both runs were
wipes), at ~1.0 s cadence — so `gap_bound` does NOT catch them, and a live driver sees exactly
this. **A project need, not a desk artefact**, which was the open question.

⚠ The fourth is 55.8 s from any death and is left NAMED rather than tidied into the story.

---
_Measured 2026-08-20. Nothing here rules. `walk.py` restored from a scratchpad copy; w5 exit 0._
