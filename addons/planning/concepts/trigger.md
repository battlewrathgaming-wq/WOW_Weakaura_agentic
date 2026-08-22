# CONCEPT HOME · `Trigger` — how many times a thing may happen

_A HOME is an INDEX, never a second copy (AL-26, Battlewrath 2026-08-22: "a home is better than a
run-time cost — it's greppable and inspectable"). It says what the concept IS in a few lines, its closed
list, and POINTS at every place that rules or grades it. The pointed-at documents stay authoritative;
if this page and one of them disagree, the document is right and this page has drifted. Checkable: a
home must name every governing document the vocabulary appears in (`emit_divergence` computes that set)._

## WHAT IT IS
A LATCH — and there are **TWO**, not one (AL-23). Both are AUTHORED (AL-35); neither is derived.

    PER TAB          on the BEHAVIOUR record. Once = fires and is spent until the node RE-ARMS.
                     Every time = released when the sense drops, so it can fire again on re-entry.
    PER STEP/STAGE   on the node. Once = the node leaves the offered list on completion.

⚠ It is NOT one field asked twice. **They answer different repeat questions**, and his case is why:
*"A boss room isn't one chance to kill it or our system breaks. At the same time we don't want to
spam LoS every time you run over it."* ⟶ boss wants Every time; `say` wants Once; same node.

★ The default is RESOLVED, never read raw — `Routes.TriggerOf` answers what the runtime should DO,
so an absent field and an authored `once` are the same answer and **cannot disagree** (§79: the
default stores nothing). Same shape as `SENSE_DEFAULT`.

## THE CLOSED LIST
    once     the default, both latches. Stores NOTHING.
    every    the opt-in.
    ⟶ `Routes.TRIGGERS = { "once", "every" }`; the facing words are **One time · Every time**.
    ⚠ NOT a derived value, NOT a tick-plus-mode pair, NOT a third state. An EXCEPTION is CHOSEN
      (A10.3k) — which is the line drawn against `Next`, whose absence IS derived.

### THE OFFERED DEFAULT PER ACTION (AL-35 — an offer, never a lock)
    boss → Every time (you can safely wipe and retry) · say → Once (the last instruction carried to
    the group, fresh in memory) · note → the bench proposes. **The author flips it in one click.**
    ★ His reason: *"that hides the setters, which is not programmatic"* — an offered default is the
    same convenience with the control still in view.

## WHERE IT IS RULED (read these; this page only points)
    driver_architecture.md      §4b (the posed tab; Trigger on the tab AND the node — drill 3) · §4d
    ARCHITECT_LOG.md            AL-23 (the two latches; released by the sense, re-armed by Trigger) ·
                                AL-35 (both AUTHORED; per-action offered defaults; the derived read STRUCK)
    driver_manager_acceptance.md A12.4b (the runtime half; default Once) · A12.4e (Every time counts
                                complete on its FIRST fire; later fires never touch the ledger)
    driver_ui_acceptance.md     A10.3k (ONE picker per latch, a closed two-value list)
    Reconcile_inbox.md          RI-27 (drained — the TWO AXES held apart: retry-while-incomplete is the
                                default BEHAVIOUR, not a control) · RI-62 (no door yet)
    contract.lua                `trigger` on the BEHAVIOUR record (*"the ROW's latch; absent is once"*)
                                and on the CHARACTERISTIC record
    routes.lua                  `TRIGGERS` · `SetTrigger` (once stores nil) · `TriggerOf` (resolved)
    adaptor                     `once | every` → One time · Every time

## WHAT IS OWED — derive it; never read it here (`emit_built_state.py`)
As of 2026-08-22 by hand: the vocabulary, both setters and the resolver are BUILT. The DOOR is not
(RI-62), the per-action offered defaults are not, and **A10.3's rows for the shown default and the
node-level control are the Analyst's** (AL-35). ⚠ A hand line; it rots — the tool is the truth.
