# Test Drive Remote — the control you can see

_`drive.lua` · **a MODE of `COA_DungeonRunFrame`**, not a frame · no size of its own_

★★★ **FOLDED 2026-08-26 (§680). It is the remote's SECOND TAB.** AL-49/AL-50 ruled the test
drive is one of *"two modes of one widget"*, and the temporary door on the run mode is gone with
the fold — its own comment named the day: *"it stays only until `drive.lua` mounts itself as the
second MODE."*

    WAS   `COA_DungeonRunDrive`, 280 × 206, content x=18 width 244, hand-placed, with a Close
    NOW   `Widget.Mount("drive", "Test drive", ...)` — the remote owns the frame, the strip
          and the page; this file owns WHICH controls and in WHAT order, and nothing else

★★ **NO SIZE, NO INSET, NO x, NO y — and their absence is the record.** `DR_Pane_4`: placement
within is the library's. What replaced 280 × 206 is the remote's 240 × 197, and the page grew from
108 to 140 because **the remote is sized to the TALLER mode and does not resize per tab**
(`DR_Pane_2`: the pane keeps its identity, its position and its SIZE across a swap).

☆ **THE CLOSE BUTTON IS RETIRED.** A mode is left by picking the other tab; a Close inside a tab
would shut the whole remote, which is not what the word said.

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
★★★ **THE MODE'S CONTROLS ARE NOT REGISTERED INDIVIDUALLY**, for the same reason the remote's
are not: they are RELEASED and rebuilt on every switch (`DR_Pane_2`), so a registry key would hold
a widget AceGUI has returned to its pool. The MODE is the registered thing — `remote.mode` — and
what it contains is read through it. `drive.pane`, `.title`, `.prev`, `.next`, `.route`, `.arm`,
`.boss`, `.log`, `.close` and `.state` are RETIRED as keys.
⟶ Every one of those controls still exists and every one is asserted in
`addons/tools/smoke/smoke_dungeonrunwidget.lua`, which is where their behaviour is pinned now.

★★ **WHAT THE DRIVE MODE HOLDS, in order, and none of them carries an x or a y:**

    prev · route · next    the cursor — 0.16 · 0.66 · 0.16, one line by DECLARED width
    arm · boss             0.49 · 0.49
    log                    full width
    state                  the readout; a long in-set wraps DOWN because the container
                           gives it the width, which the old FontString needed an explicit
                           width and a JustifyV to achieve

⚠ **THE THREE CURSOR CONTROLS SHARE A LINE BY DECLARATION, NEVER BY FIT.** `concepts/row.md`
rules PAIRED BY FIT ⚠⚠ NEVER, and AceGUI `Flow` pairs by fit as its whole mechanism — the
relative widths are what make this pairing a declaration inside that layout. ☆ Nothing checks
that today; AL-60 names the check and names when it lands (*"whoever folds the object pane onto
Flow brings the neighbour check with the fold"*).

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
