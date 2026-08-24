# Test Drive Remote — the control you can see

_`drive.lua` · `COA_DungeonRunDrive` · **280 × 206** · content x=18, width 244_

★★★ **The factual register.** What exists, or what the code must comply with.

★ **Reconciled by `check_interface.py`** — the file and global named above, the declared size, and every `forms · phrase` citation. ⚠ It checks the mechanical part only; whether `does`, `how` and `refuses` are still true is curation.

---

## ★★★ The model — what it IS

**A10.5. The remote that drives a route so the author does not have to type.** His reason, and it is the whole brief:

> *"Dungeon Run has a TEST DRIVE REMOTE — mainly so I stop being asked to do things by commands / dispatcher."*

and, giving the manager tier its door on 2026-08-22:

> *"A test drive widget, which is already in scope. Then for now add the buttons there. **No command use (Testing churn.)**"*

⚠⚠ **So the absence of a slash line is the FEATURE.** A10.5a states it as acceptance — *"no slash line required to reach it"* — and a command added here later would not be a convenience, it would be the row failing.

### ★★ It is the AUTHOR'S DIAGNOSTICS, not the reader's display (AL-6)

A reader in flight sees none of this. Every readout here answers *why did the run not advance*, which is a question only the person authoring the route asks. ⚠ A10.8 is the other half: **a reader sees no counts at all.**

### Its home is elsewhere, and this pane knows it

☐ **ITS HOME IS THE REMOTE'S SECOND TAB, NOT THIS PANE.** This is a hand-built pane beside the remote until that lands, and `remote.drive` is a temporary door on a pane whose own model says a gate needs two doors.

⚠ **CORRECTED 2026-08-24 (AL-49, from his structure of the same day; RI-76).** **The home is the REMOTE's SECOND TAB** — the remote carries two (Run capture · Test drive) — **not a tab on the unified pane and not G3.** The unified pane holds THREE: Curation · Promotion · Object. AL-47's rule survives (membership is DERIVED, never counted); its APPLICATION over-reached, and AL-47 carries its own dated note. ⟶ **`remote.drive` still goes when the tab lands** — that half was never wrong, only its destination.

~~D-E: **G3 is the test drive's suite entry inside Dungeon Run** — a tab in the primary Ace frame, which is not built.~~ D-6b's rule is untouched and still governs the interim: *"hand-built panes live beside it until their turn."*

⚠ **THE TAB IS NOT BUILT AND THIS REGISTER SAYS SO.** A register describes what IS; the destination is an ☐, never a claim of a built tab.

## does

1. **Offers the routes on THIS map** and cycles them — `Manager.Offer`, which is `Routes.List` and adds nothing to it.
2. **Arms and stops** the manager tier (`Manager.Select` / `Manager.Stop`).
3. **Wires the two client seams** the manager deliberately leaves empty — the sampler (`Sensor.Sample`) and the consumer of the transitions (`Sensor.OnChange`).
4. **Binds the harness's action bodies** for `note`, `say` and `boss` — on ARM, never at load.
5. **Completes a pending boss tab** — the button that plays the part of the kill.
6. **Starts and stops a named debug-log run** and prints its report.

## refuses

- ⚠ **It is not an editor.** Nothing about a route or a node is changed here.
- ⚠⚠ **It never shows `stage` alone.** A10.5's own mutation: *"expose `stage` alone → fails"*. The readout is the **IN SET BY ADDRESS**, because a stage number says the run moved and cannot say why it did not.
- ⚠⚠ **`say` prints; it does not `SendChatMessage`.** A rehearsal that talks to the party is a rehearsal the author stops running.
- ⚠ **No CLEU listener.** A10.5b's proof is *advance on just a boss kill*; the listener is the thing being specified, and a harness that guessed at it would prove the guess.
- ⚠ **It does not own the action words.** `manager.lua`: *"nothing here invents what `note`, `say` or `boss` DO."* The bodies here are one consumer's handling and carry no authority over a shipped reader's.

## relates

    Recorder Remote ── remote.drive ──▶ Test Drive Remote ──▶ Manager ──▶ Sensor
                                                          └──▶ DebugLog

⚠ **The door is on the recorder remote's TITLE ROW, not its footer** — see `remote.md`. The footer's numbers are his, dragged on the board in §145, and there is no fourth slot in them that anyone chose.

## holds

    window pos        persists       Store.SetUI("drivePos")
    open / closed     persists       Store.SetUI("driveShown")   ⚠ closed by default
    route cursor      NOT held       rebuilt from Manager.Offer every time the pane opens
    pending boss tabs NOT held       cleared by Unwire; a stopped drive waits on nothing

## children

```
drive.pane       kind frame   usage — (the surface itself)
                 does  the pane itself. `set("close")` hides it, `read` reports shown

drive.title      kind readout   usage label   forms drive.lua · `local title = f:CreateFontString(`, GameFontNormal, "Test drive" at (18, -10)
drive.prev       kind button   usage action   forms drive.lua · `prevBtn = CreateFrame(`   does steps the route cursor back
                 numbers w 24 · h 20 at (18, -34), text "<"
drive.next       kind button   usage action   forms drive.lua · `nextBtn = CreateFrame(`   does steps the route cursor on
                 numbers w 24 · h 20 at TOPRIGHT (-18, -34), text ">"
drive.route      kind readout   usage readout   forms drive.lua · `routeText = f:CreateFontString(`   does which route, and where in the offered list
                 numbers TOPLEFT (46, -38), w 188
drive.arm        kind button   usage arm   forms drive.lua · `armBtn = CreateFrame(`   does arms and stops the manager
                 numbers w 118 · h 22 at (18, -60)
drive.boss       kind button   usage action   forms drive.lua · `bossBtn = CreateFrame(`   does completes the OLDEST pending boss tab
                 numbers w 118 · h 22 at TOPRIGHT (-18, -60)
                 ★ DISABLED when nothing is pending — disabled says "this exists and
                   needs a run"; hidden says nothing at all.
drive.log        kind button   usage action   forms drive.lua · `logBtn = CreateFrame(`   does starts / stops a named debug-log run and prints its report
                 numbers w 118 · h 22 at (18, -86)
drive.close      kind button   usage action   forms drive.lua · `local closeBtn = CreateFrame(`   does closes the pane
                 numbers w 118 · h 22 at TOPRIGHT (-18, -86)
drive.state      kind readout   usage readout   forms drive.lua · `stateText = f:CreateFontString(`   does stage · step · THE IN SET BY ADDRESS · pending boss tabs
                 numbers TOPLEFT (18, -118), w 244, wrapping
                 ★★ THE ROW A10.5a IS ABOUT. Never `stage` alone.
```

★ **Two columns, 118 + 118 with an 8px gutter inside an 18px margin** — 18 + 118 + 8 + 118 + 18 = 280. One content box, unlike the remote's history of three.

---

## Outstanding

<!-- OUTSTANDING:BEGIN - emitted by emit_outstanding.py, do not edit by hand -->

1 item:

- ITS HOME IS THE REMOTE'S SECOND TAB, NOT THIS PANE. This is a hand-built pane beside the remote until that lands, and `remote.drive` is a temporary door on a pane whose own model says a gate needs two doors.

<!-- OUTSTANDING:END -->

---

## Hopes and dreams

_What this surface still needs so **the model** can be realized (`dungeonrun_model.md`). Not technical — the backlog to realize._

- **It becomes the REMOTE's second tab** — Run capture · Test drive — rather than a pane beside it.
  ⚠ Read *"it becomes G3, a lane in the primary frame"* until 2026-08-24; corrected at AL-49.
  ★ Per AL-50 the remote's two tabs are **MODES of one widget**: same texture, **FIXED** — no undock,
  no per-tab return band. That is a NAMED exception to AL-13's *"nothing is one-way"*, which is
  scoped to the unified pane's groups.
- **The boss button becomes a real listener.** A10.5b's proof — *advance on just a boss kill against a landed capture* — is the acceptance that retires the button.
- **The readout gains its second column.** A10.5a's other half is *per target its FIRST-HIT sample index*, which needs samples to be indexed and is V1's readout, not V2's stage-level `hit · skip · false_advances` (struck by A11.5a).
