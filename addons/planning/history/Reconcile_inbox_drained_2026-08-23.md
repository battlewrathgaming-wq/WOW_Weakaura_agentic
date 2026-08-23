# Reconcile inbox — DRAINED 2026-08-23 (the §501 gap list)

_Read for WHY, never for WHAT. The conclusions are rows in `ANALYST_LOG.md`; this is the
reasoning behind them, moved out so the inbox holds only what is still a conversation._

⚠⚠ **FOUR OF THE FOURTEEN ARE NOT HERE.** `RI-59 · 65 · 66 · 70` were re-measured on
2026-08-23 and are STILL TRUE, and the governing set had not taken them up — so they stay
OPEN in the inbox. A drain is a claim; four of these could not be made.

★ **AND ONE HERE IS A WITHDRAWAL, NOT A RESOLUTION.** `RI-68`'s premise was false when it
was filed — kept in full, because a finding that was wrong is worth more as a record than
as a deletion.

---

## RI-58 · ★★★ THE ACTION WORD CANNOT BE AUTHORED — the pane offers a RETIRED vocabulary

**RI-58 DRAINED (Addon creator, 2026-08-23)** — the governing set took it up and went further - `driver_architecture.md` marks the object pane **◐ DIVERGENT** with this exact finding (*"writes ZERO rows: it never calls `Routes.SetRow`… a node authored today arms with NO behaviour"*) and rules it **KNOWN and SEQUENCED**: Ace interface → WA-coded grammar → settled homes → the rows wire. ⚠ STILL TRUE IN CODE - `SetRow` has no pane caller today. The item is settled; the gap is scheduled.


_Filed by the **Addon creator**, 2026-08-22, at his ask: *"push all needed items to the RI … where you think from implimentation the biggest gaps will be. Break it into items per."* **Measured against the shipped code, not recalled.**_

**THE GAP:** there is no way anywhere in the client to put `note`, `say` or `boss` on a node.

**WHAT IS**

    object.lua:1069-1072   the action dropdown offers TWO entries: "nothing" and
                           "point the tracker"
    object.lua:1077        it calls `Routes.SetChildAction`
    routes.lua:1413        `Routes.ACTIONS = { "supertrack" }` — the gate that setter checks
    routes.lua:1557        `Routes.ROW_ACTIONS = { "boss", "note", "say" }` — the RULED list
    routes.lua:1772        `Routes.SetRow` — the one ruled setter. **No pane calls it.**

⚠⚠ `supertrack` is the word **A2.6 / AL-19 retired as an action** — it became the node's LED TO
tick. So the only word the pane's setter accepts is the one word that is no longer a verb.

**IMPACT:** a driven route MOVES and does nothing else. Proved against the shipped `routes.lua`:
`SetChildAction(b, c, "note")` leaves `child.action` nil and the row the manager reads at
`action = nil`. ★ This is why the first live test drive produced no notes.

**THE BENCH'S READ:** wire the pane to `SetRow` and retire `Routes.ACTIONS` + `SetChildAction`
WHOLE rather than parking them. ⚠ The retirement is the half that needs the Analyst's word: the
old setter is what `AcceptanceOf` and the migration still lean on.

---

## RI-60 · ★★★ THE ARG HAS NO DOOR AT ALL — and its two origins have different rules

**RI-60 DRAINED (Addon creator, 2026-08-23)** — `concepts/arg.md` is its home, and `ARCHITECT_LOG` + `DRIVER_BASIS` carry it.


_Filed by the **Addon creator**, 2026-08-22, at his ask: *"push all needed items to the RI … where you think from implimentation the biggest gaps will be. Break it into items per."* **Measured against the shipped code, not recalled.**_

**THE GAP:** `ROW_ARG_RULE` fully specifies what an arg must be, and no control produces one.

**WHAT IS**

    routes.lua:1718-1722   boss = {string, source="run"}   PICKED from the run's own bosses,
                                                           A3.1, and **uncapped** — bounded by
                                                           what the game named
                           note/say = {string, source="user", max=255}   TYPED and capped
    object.lua              no arg control of any kind exists

**IMPACT:** even with the action word fixed, every row would carry `arg = nil`. A `note` with no
text is a tab that completes and says nothing.

**THE BENCH'S READ:** A10.3d already rules the behaviour (*set a row's action to `boss` → the
name-picker appears; set it to `note` → a text field, picker hides*), so this is BUILD not
design — filed because it is a whole control that does not exist, not because it is open.
⚠ One real question underneath: the boss offer comes from the RUN, and a promoted route drops
its back-reference to the run so it can travel (§459). **On a route with no run loaded, what
feeds the picker?**

---

## RI-61 · ★★ THE ROW IS A LIST AND THE PANE MODELS ONE

**RI-61 DRAINED (Addon creator, 2026-08-23)** — `driver_architecture.md` and A10.3c carry it - the roster idiom, one level down.


_Filed by the **Addon creator**, 2026-08-22, at his ask: *"push all needed items to the RI … where you think from implimentation the biggest gaps will be. Break it into items per."* **Measured against the shipped code, not recalled.**_

**THE GAP:** `Routes.SetRow(b, child, index, …)` takes an INDEX. The pane has a single action
dropdown and no notion of a second row.

**WHAT IS:** `routes.lua:1772` takes `index`; `bucket.lua` iterates `node.rows`; `manager.lua`
dispatches per row and latches per `(address, rowIndex)`. **Every tier below the pane is
list-shaped.** `object.lua` is not.

**IMPACT:** the ruled grammar is a STACK of rows scoped by the sense (RI-15) — *"a stack of
rows, each an action"*. One row per node is a strictly smaller language than the one the runtime
already implements and the model already rules.

**THE BENCH'S READ:** A10.3c has the shape (*the child roster as a REGENERATED per-object group;
reorder; up/down; delete guarded for child 1*) — the same idiom applied one level down. Filed
so it is sized as a ROSTER rather than added as a second dropdown.

---

## RI-62 · ★★ `trigger` (once | every) HAS NO DOOR — AL-23's latch is authored by nobody

**RI-62 DRAINED (Addon creator, 2026-08-23)** — `concepts/trigger.md` is its home; `driver_manager_acceptance` carries the rule.


_Filed by the **Addon creator**, 2026-08-22, at his ask: *"push all needed items to the RI … where you think from implimentation the biggest gaps will be. Break it into items per."* **Measured against the shipped code, not recalled.**_

**THE GAP:** the latch is in the store and resolved in the bucket; no control sets it.

**WHAT IS**

    routes.lua:1605        `Routes.SetTrigger` — no caller in any pane
    routes.lua:1618        `Routes.TriggerOf`
    bucket.lua:492         `trigger = Routes.TriggerOf(c) or "once"` — resolved at build

**IMPACT:** every tab is `once` by default. ★ That is the SAFE direction rather than the silent
one — a `say` announces once instead of spamming — but `every` is unreachable, and `every` is
what AL-23 was ruled FOR: *"a boss room isn't one chance to kill it or our system breaks."*

**THE BENCH'S READ:** a per-row tick. ⚠ It is per-TAB **and** per-NODE (AL-23 rules two latches),
so a single control would author only half of it — that split is the thing to get right before
drawing anything.

---

## RI-63 · ★★ `ledTo` HAS NO SETTER — not a missing door, a missing function

**RI-63 DRAINED (Addon creator, 2026-08-23)** — `ARCHITECT_LOG` took it up and `driver_architecture.md` carries it.


_Filed by the **Addon creator**, 2026-08-22, at his ask: *"push all needed items to the RI … where you think from implimentation the biggest gaps will be. Break it into items per."* **Measured against the shipped code, not recalled.**_

**THE GAP:** AL-19's LED TO tick is *"ON by default; ticking it off is the author's choice"*,
and there is no way to tick it off.

**WHAT IS:** `routes.lua:1685` `Routes.LedTo(stage, step, lone, node)` READS `node.ledTo`.
**Nothing writes it.** No `SetLedTo` exists; the pane has no control.

**IMPACT:** every node that IS a position takes the supertracker arrow. The author cannot mark a
node as *reach it, but do not point at it* — which is the whole content of the ruling.

**THE BENCH'S READ:** cheapest item on this list: one setter, one tick, and §79's rule already
says the default stores NOTHING (only an author's OFF is written), so the storage shape is
settled before the control is drawn.

---

## RI-64 · ★★ THE R LADDER HAS NO STEPPER — the rungs exist and nothing climbs them

**RI-64 DRAINED (Addon creator, 2026-08-23)** — `concepts/r-and-band.md` is its home; `driver_authoring_acceptance` carries the ladder.


_Filed by the **Addon creator**, 2026-08-22, at his ask: *"push all needed items to the RI … where you think from implimentation the biggest gaps will be. Break it into items per."* **Measured against the shipped code, not recalled.**_

**THE GAP:** §495 built `R_STEPS = {5, 15, 25, 50, 100, 150, 300}` and `Routes.StepR`; the
pane still offers a bare text box.

**WHAT IS:** `object.lua:1038` `radBox` — a 38px `InputBoxTemplate`, free text. The floor and
ceiling now clamp underneath it (`routes.lua`, `setReach`), so nothing invalid can be STORED —
but the ladder he specified is unreachable by any control.

**IMPACT:** small and real: *"a way to increase it above the floor to a limit"* is the half of
his ruling that is not built. An author types 300 or does not discover it.

**THE BENCH'S READ:** two arrows beside the box, `Routes.StepR` behind them, box still typeable.
⚠ `< >` is the same idiom the drive remote's route cursor already uses.

---

## RI-67 · ★ `SetChildIcon` HAS NO DOOR

**RI-67 DRAINED (Addon creator, 2026-08-23)** — `driver_authoring_acceptance.md` carries it.


_Filed by the **Addon creator**, 2026-08-22, at his ask: *"push all needed items to the RI … where you think from implimentation the biggest gaps will be. Break it into items per."* **Measured against the shipped code, not recalled.**_

**THE GAP:** a writer with no caller in any pane.

**IMPACT:** cosmetic today. Filed only so it is not rediscovered as a defect during the wiring
pass, and so the pass can decide DELIBERATELY whether the icon is authored or derived.

**THE BENCH'S READ:** lowest priority on this list. If the icon should follow the ACTION rather
than be picked, the setter should go rather than gain a control.

---

## RI-68 · ★ `Place` / `Unplace` HAVE NO CALLER AT ALL — the map drag is unwired

**RI-68 DRAINED (Addon creator, 2026-08-23)** — ❌ **WITHDRAWN - THE FINDING WAS WRONG WHEN I FILED IT.** `Routes.Place` IS called: `map.lua:1845`, `R.Place(point, dragX, dragY, Map.AuthoringMapID(), shownFloor)` — through `local R = NS.Routes`. It has been wired since **§68.1, 2026-08-14**, eight days before I filed this.

⚠⚠ **AND THE FAULT IS THE ONE I HAD FIXED THAT WEEK.** RI-68 came from a hand-written scan using a LITERAL `Routes\.<name>\(` search - alias-blind - written days after I made `emit_built_state.py` alias-aware for exactly this (§497, where 20 of 43 STRANDED rows were false). ★ The memory `a-name-is-not-a-use` was written the same day and did not stop it: **I fixed the tool and then made the error by hand.** ⟶ Re-checking it today I did it a THIRD time - a tightened literal grep missed the alias again and I briefly concluded the opposite.


_Filed by the **Addon creator**, 2026-08-22, at his ask: *"push all needed items to the RI … where you think from implimentation the biggest gaps will be. Break it into items per."* **Measured against the shipped code, not recalled.**_

**THE GAP:** `routes.lua:658` `Routes.Place(p, atX, atY, mapID, floor)` and `:670` `Unplace`
are called by nothing, in any file, including smokes.

**WHAT IS:** the functions carry a long ruling about dragging (*"the drag would resolve, so a
system that projects listen range is from the new position"*, §65's calibration, z deliberately
untouched) — fully argued, fully written, never connected.

**IMPACT:** none today. ⚠ But it is the exact shape `half-formed code invites building on it`
names: a complete-looking API that nothing exercises, so nobody knows whether it works.

**THE BENCH'S READ:** either the map gains the drag or these go. **Not a third option.**

---

## RI-69 · ★ `SetNext` HAS NO DOOR — and AL-21 says LEAVE IT

**RI-69 DRAINED (Addon creator, 2026-08-23)** — `concepts/next.md` is its home. ⚠ AL-21's deferral is UNCHANGED - this item existed to be READ, not resolved, and it has been.


_Filed by the **Addon creator**, 2026-08-22, at his ask: *"push all needed items to the RI … where you think from implimentation the biggest gaps will be. Break it into items per."* **Measured against the shipped code, not recalled.**_

**THE GAP:** `routes.lua:1625` `Routes.SetNext(child, nextType, nextArg)` has no caller; the
pane still authors `SetChildRole` + `SetOutcome`, the OLD vocabulary.

⚠⚠ **FILED SO IT IS NOT WIRED BY MISTAKE.** AL-21 defers the `role` → `Next` migration until
A10.3 replaces the pane. During a wiring pass whose brief is *every authored input gets a door*,
this is the one input that must NOT get one — and that is invisible unless it is written down.

**THE BENCH'S READ:** no action. This item exists to be read, not resolved.

---

## RI-71 · ★ `SuperTrackerUtil` IS ASSUMED, NEVER VERIFIED ON THIS FORK

**RI-71 DRAINED (Addon creator, 2026-08-23)** — `driver_walk_acceptance.md` carries it.


_Filed by the **Addon creator**, 2026-08-22, at his ask: *"push all needed items to the RI … where you think from implimentation the biggest gaps will be. Break it into items per."* **Measured against the shipped code, not recalled.**_

**THE GAP:** the tracker seam is guarded by `_G.SuperTrackerUtil` and a `pcall`, so if the
global is absent **nothing happens and nothing says so**.

**WHAT IS:** `core.lua:55-65` `NS.Tracker`. The shape is `capture.lua`'s, in use since §249 for
the pin. The scraped census lists our own CALLS to it, which is not evidence the client defines
it — a name search answering a question about existence.

**IMPACT:** if the fork lacks it, the arrow silently never appears and every reader experiences a
route that leads nowhere, with a clean log. ★ The failure is indistinguishable from *the author
did not tick LED TO*.

**THE BENCH'S READ:** one line in a live session settles it. ☐ Filed rather than assumed, because
`a stored field isn't live` is the standing rule and this is its API form.

---
