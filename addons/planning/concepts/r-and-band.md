# CONCEPT HOME · `R` and `band` — how big a node is, and how much height it forgives

_A HOME is an INDEX, never a second copy (AL-26, Battlewrath 2026-08-22: "a home is better than a
run-time cost — it's greppable and inspectable"). It says what the concept IS in a few lines, its closed
list, and POINTS at every place that rules or grades it. The pointed-at documents stay authoritative;
if this page and one of them disagree, the document is right and this page has drifted. Checkable: a
home must name every governing document the vocabulary appears in (`emit_divergence` computes that set)._

## WHAT IT IS
Two numbers on a node's characteristic record, and **they are not the same kind of number** — which is
the distinction most worth carrying out of this page:

    R      HOW BIG THE THING IS.        A judgement. Horizontal radius, in yards.
    band   HOW MUCH HEIGHT IT FORGIVES. A TOLERANCE. Upward only.

⟶ Their defaults differ for that reason: **a nil `band` means *the author did not pick* and resolves
to 2.5, because a tolerance has a safe default. A nil `R` REFUSES at build**, because *how big a thing
is* does not (A10.3e-R). ★ Same shape, opposite answer, and the reason is the kind of number.

## THE CLOSED LISTS AND THE NUMBERS
    Routes.R_FLOOR    5    ⚠⚠ **DERIVED, NOT CHOSEN:** `R_min = v_ceiling × POLL_MIN / 2 = 100 × 0.1 / 2`.
                           R, the poll floor and the travel ceiling are ONE RELATIONSHIP — move any and
                           the others move. ★ DR_Process_18's SETTLED PAIRING: the literal stays (greppable, no
                           load-order cost) and the pairing is **ASSERTED at test time**.
    Routes.R_CEILING  300  CHOSEN. A judgement about how big a node may be, with no derivation available.
    Routes.R_STEPS    { 5, 15, 25, 50, 100, 150, 300 }   the ladder the picker climbs; `StepR` moves it.
    Bucket.BAND_DEFAULT 2.5  CHOSEN, with its reason: the measured jump apex is ~1.64 (four flat jumps
                           read between `IsFalling`'s edges) and 2.5 covers it. **NOT a derivation** —
                           correctly a literal carrying its reason, and explicitly not DR_Process_18's case.

    ⚠ `band` IS UPWARD ONLY (RI-22). Not a pair, not symmetric, not named pairs — a captured sample IS
      the floor (ROUTER 280: a unit's z is the base point), so downward tolerance measures nothing.
      `bandDown` is RETIRED; up-only is `band_down = 0`, not a signature change.
    ★ BOTH ARE SELECTIONS, not free text (RI-35): the menu is CLOSED, the author PICKS, **the store
      holds the NUMBER** — the choice is a lookup, and the index is not a live lookup the driver does.

## WHERE IT IS RULED (read these; this page only points)
    driver_architecture.md        §4b (the characteristic record) · §5 DR_Process_18 (load-bearing ⟹ sourceable)
    driver_sense_acceptance.md    A11.2 (the rule: point + band + gate) · A11.2h (the band conversion —
                                  the ONLY place it may happen) · A11.4b (arrive as numbers, snapshot at arm)
    driver_ui_acceptance.md       A10.3e (the numeric doors are SELECTIONS) · A10.3e-R (R = 5 at the mint,
                                  enforced at the picker)
    driver_walk_acceptance.md     W1.7 · W3.2 (the band sweep; the goldens are produced with bands OPEN)
    driver_data_model.md          the characteristic record · §A3b 12a (the choice is a LOOKUP)
    Reconcile_inbox.md            RI-22 (upward only) · RI-35 (indexes / the closed menu) · RI-56 (the R
                                  bounds; **the band's ceiling is still UNDEFINED**) · RI-64 (no stepper yet)
    ARCHITECT_LOG.md              AL-28 (DR_Process_19: a hedged answer with a physical reason is a SPEC FOR A
                                  MEASUREMENT — the band ceiling is one) · AL-26 (DR_Process_18, the settled pairing)
    routes.lua / bucket.lua       `R_FLOOR` · `R_CEILING` · `R_STEPS` · `StepR` · `ReachOf` · `BAND_DEFAULT`

## WHAT IS OWED — derive it; never read it here (`emit_built_state.py`)
As of 2026-08-22 by hand: the floor, ceiling, ladder and stepper function are BUILT; **the picker that
climbs the ladder is not** (RI-64). ⬜ The DR_Process_18 ASSERTION pairing `R_FLOOR` to `MAX_CLOSING_SPEED ×
POLL_MIN / 2` is the bench's one line and is not yet written. ⬜ The BAND'S UPPER LIMIT is undefined and
is a MEASUREMENT, not a preference (DR_Process_19 — *floor above clipping* is a distance between two standable
surfaces). ⚠ A hand line; it rots — the tool is the truth.
