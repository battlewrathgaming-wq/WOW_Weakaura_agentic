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

## 6 · ⚠ THE ADAPTIVE THROTTLE — which way it adapts decides the answer

Battlewrath, 2026-08-20: *"I'm pretty sure we have an adaptive throttle plan that squashes most
of the teleport concerns."* ★ It bears on this directly, because the guard's input is
`distance / Δgt` and a throttle changes `Δgt`. **But the direction matters and it is not
intuitive:**

    SPARSER sampling   averages a burst over more idle time  ->  apparent speed FALLS
                       a 10 yd charge in 0.2 s reads 51 yd/s; the same charge inside a
                       0.4 s window reads 25 yd/s
    DENSER sampling    approaches true instantaneous speed   ->  apparent speed RISES

⟶ A throttle that **slows** sampling does squash the concern. One that **speeds up during
movement** — which is the shape an adaptive throttle usually takes, because that is when detail
matters — pushes ordinary movement UP toward the threshold and makes a false teleport *more*
likely, not less.

⚠ **Not a claim about the plan**, which this bench has not seen. It is the axis the plan should
be read against.

---
_Measured 2026-08-20. Nothing here rules. `walk.py` restored from a scratchpad copy; w5 exit 0._
