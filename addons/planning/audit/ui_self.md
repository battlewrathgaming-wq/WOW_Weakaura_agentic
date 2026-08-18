# THE AUTHORING UI — everything this project has SAID about it, collated

_Independent audit, files only, 2026-08-18. Read in the BASIS order: `DRIVER_BASIS.md` (B),
`dungeonrun_model.md` (M), `mvp_scope.md` (S), `ui_overhaul_scope.md` (UO — reached via M:1433 "the
overhaul, scoped"), `driver_programmatic_model.md` (PM), `driver_scoping.md` (SC),
`driver_use_case_target.md` (T), `Reconcile_inbox.md` (RI), `driver_authoring_acceptance.md` (AA),
`driver_adaptor_table.md` (AD), `dungeonrun_interface_inventory.md` (INV), `interface/*.md` (remote /
map / map_controls / curation / promotion / object → RM / MP / MC / CU / PR / OB),
`interface/devlog/*`, `reference/weakauras_idioms.md` (WI), `audit/expr_self.md` (ES),
`audit/expr_mods.md` (EM); code: `panespec.lua` (PS), `layout.lua` (LY), `ui.lua` (UI), `object.lua`
(O), `promoter.lua` (P), `editor.lua` (E), `map.lua` (MAP), `widget.lua` (W);
`tools/check_interface.py` (CI), `tools/smoke/check_rects.lua` (CR), `tools/smoke/smoke_dungeonrunpromoter.lua`
(SMK). Citations are `FILE:line` or `FILE §heading`. Reported as data; no proposals._

_Governing beats history (B:159-164): where a statement below comes from UO, MP-hopes, OB-hopes or
the model's "hopes and dreams", it is marked as such and its status is read against B's positions.
"RULED" anywhere = "best working model at that date" (B:25-27, 162-164)._

---

## U1. SURFACES

Status key: **shipped** (frame exists, controls registered) · **declared-not-built** (a surface file or
a spec exists, no frame or not built from it) · **designed** (prose only) · **ruled-deferred** (a
ruling says wait). Declared-control counts are the `zone|kind` rows in `interface/*.md` as
`check_interface.py` counts them (105 literal + 6 patterns = 111 total; CI run 2026-08-18: "105 of 105
declared controls registered").

| surface | what it is for | what it shows | what an author/reader does there | declared controls | status |
|---|---|---|---|---|---|
| **Recorder Remote** (`widget.lua` · `COA_DungeonRunFrame` · 240×124 · inset 16) | "a GATE OF ACTIVITY — I'm doing a run / I'm reviewing a run" (RM:32-38); the ONLY front door (RM:80-86); compact (M:1385) | title "Dungeon run", pin, name box, count, arm/stop, map (RM:96-119; W:35-163) | starts/stops capture, pins a point, names the run, opens the Map (RM:66-71). Refuses to edit, shows a count never a judgement (RM:73-76) | **7** (all registered, RM:133) | **shipped**; rename to `DungeonRun_Recorder_Remote` PENDING (RM:17-19) |
| **Map** (`map.lua` · `COA_DungeonRunMap` · rule 1034×722) | "the primary storytelling space… we give context, they derive meaning" (M:1278-1293; MP:31-49) | run layer (timed), route layer (beacons + children), personal-notes layer (MP:95-102); tiles; floor prev/next; the selection readout panel; hover tooltip | left-click selects; right-click a beacon/child/note opens Object; drags a move-armed object; hover for facts; Controls / Curate buttons; wheel + right-drag only if ticked ON (MP:120-131) | **12** incl. `map.tile.<n>` pattern (MP:155-181, "all eleven registered") | **shipped**; "Not declared in panespec — every number hand-typed" ☐ (MP:152) |
| **Map controls** (`map.lua:1848` · `COA_DungeonRunMapControls` · 240×168) | "GENERATES better reading through population — additive" (MC:13-28; INV:79-106) | 3×3 pad: zoom −/up/zoom +, </Re-centre/>, 100%(cycle)/down/Reset; two opt-in ticks (MC:59-66, 77-107) | moves the VIEW only; zoom anchored on view centre; `100%` cycles 100/125/150/200 (MC:30-68) | **13** (all registered, MC:112) | **shipped** |
| **Curation** (`editor.lua` · `COA_DungeonRunEditor` · 320×366) | "the instrument of DISTINCTION" — valuation across runs, readability within one; SUBTRACTIVE filter (CU:13-47; M:653-687) | run dropdown, Rename/Delete/comment, "show" caption + 6 kind ticks + all, time bar with 2 handles, width halve/double, step ‹›, Play, Peek/Latch/Reset, track, hint, Promotion, Close (CU:145-262) | loads a run, names/comments/deletes it, filters by kind, slices by time (envelope/window/step/play/peek), opens Promotion (CU:49-55). "ONLY EVER CHANGES WHAT YOU SEE" (CU:59-71) | **24** incl. 3 patterns (`kind.<key>` `handle.<a|b>` `step.<n>`); all registered (CU:264) | **shipped**; content still laid out for 280 in a 320 pane ☐ (CU:141) |
| **Promotion** (`promoter.lua` · `COA_DungeonRunPromoter` · 320×400) | "Promotion is REDUCTION" — mints, holds no edit controls (PR:14-62; M:689-709) | route dropdown (with "+ create new" in the list), name/rename/delete, stage box + ghost, Create beacon, Personal note, inherit line, count, hint, "running order" ×9 rows + gaps line, Close (PR:135-201) | selects/creates a route, mints a beacon at the map's selection at the ghosted or typed stage, mints a personal note onto the player's own plane; then HANDS OFF to Object (PR:50-62, 100-111) | **18** incl. `promoter.order.<n>` pattern | **shipped**; not in panespec ☐ (PR:131); four left edges in one pane ☐ (PR:210-226); `stageGhost` in code, no entry ☐ (PR:203) |
| **Object** (`object.lua` · `COA_DungeonRunObject` · 240×600 · column x=18 w=204) | "everything about ONE selected object — a beacon, a child, or a personal note" (OB:32-43); the everyman surface where "a program gets written without anyone writing a program" (M:613-617) | title (names the SUBJECT), fact line, name, move chip, Delete; stage + match; "behaviour" heading + "on success" outcome dropdown (+ box); child roster rows (name + ordinal ×6, "N more"); child-here / child-at-node; child block: order + match + path, "Route instructions" box + ghost, sense dropdown (+ boss picker + tell), "detect" role dropdown + match + set box, shape, reach ×3, only-if-unseen, action; answers line; test line; hint; id footnote; Close (OB:130-302; O:596-1137) | edits identity, behaviour, stage, children of the map's selection; arms move/pick on the MAP; never validates — tells (OB:45-60) | **37** incl. `kid.ordinal.<n>` pattern (2 removed A2.6: `object.target`, `object.ramp` — OB:233-236, 260-262) | **shipped as hand-placed**; the ONLY surface declared in `panespec.lua` and NOT built from it ☐ (OB:5-7, 311); heights per subject none 113 · note 169 · beacon 415 · child 575 (OB:315-323) |
| **route remote** ("a SEVENTH surface, spawned from Promotion") | route testing "five steps deep", not on the front-door remote; inherits the loaded route, needs no picker (S:72-93) | "Go, stop, and whatever it reports" (S:85) | drives the session; "No typed commands, no heavy debug modes for v1" (S:89-91) | **0** — "It comes with its own interface file and declared rows. The checker walks six surfaces today" (S:93); ES G17 "rows not declared" (ES:156) | **designed**; ⚠ see U5 #4 (bench proposition §3 says "should not be a seventh surface"; RI-3 re-homed the test drive) |
| **TEST DRIVE** (its own suite entry INSIDE Dungeon Run) | "the author IN THE WORLD hitting their waypoints"; extension of the editor's play pacer; `/dr walk` is gone, not revived (RI-3; B:44-45; T:185-189) | first proof "advance on just a boss kill" (B:136-137; AA A6.1); readout `hit · skip · false_advances`, never `stage` alone (AA A6.4) | tell-and-trust made visible: "Test driver letting you cycle nodes near you and see what they're doing" (SC S4:42); "Expose in the walk section of the editor (replay, synthetic) and the test drive mode" (SC S1:21) | **0** declared | **designed**; sequenced item 6 in the standing order (B:136) |
| **the walk / timeline** (assurance side) | "a sprite walks the route… a timeline of what fired" (M:117-133); ROUTE TEST against a run's data (M:135-153); IN-GAME, paced by `play` (M:155-179); an ADDON FEATURE readable inside the addon (M:181-197) | count = "how many of N runs each detector fired for" on the face; the walk is the inspection (M:190-204) | author watches; "space is per mode — Curation and Promotion close" in walk mode (UO:396-412) | **0** | **designed**; RI-3 split it: in-world = TEST DRIVE; offline replay/py walk/fitment = the diagnostic suite (RI:49-53) |
| **the readout box** — TWO LIVES, then TWO BOXES | authoring: "the running order, counts, matches, gaps — what you weigh before promoting"; driving: "the note on the beacon you have reached" (M:268-290). Output-only sink, many senders (M:302-308). Split: **cursor box** (`map.readout`) vs **response box** (`object.test`) (M:321-335; UO:225-227) | today: `object.test` one line at the pane foot, blank until asked (OB:81-96, 275-283); `map.readout` = title + rows from `Map.Describe` (MAP:1602-1616) | reads; a drop-down to FORCE focus + release is an AUTHORING (editorial) control on it (M:292-300, 370-373; PR:244-258) | `object.test` · `object.hint` · `map.readout` declared; the "footer readout box" itself: 0 | **designed** (footer box); `object.test` shipped with "contrast NOT YET SPECIFIED · hover half not built" ☐ (OB:313) |
| **route-note slot** (driver, reader-facing) | the author's "Route instructions" for whoever runs the route; travels; ≤ ~200 chars; a CHOICE option (T:82-97; RI-10; PM §4b) | the note when the stage/place is live — "arrival is the event" (M:412-420); ONE SENDER, no ladder (M:316-319) | reads | authoring side: `object.note` + `object.note.ghost` shipped (OB:180-197, §346); reader slot: 0 | authoring **shipped** (G1 landed §346, B:130-135); reader slot **designed** (no consumer) |
| **personal-note slot** (driver, reader-facing) | "a DESIGNATED SLOT beside the route note during runs, by position"; the reader can turn it off; may push the tracker by explicit act, the route overwrites (PM §4b:270-293; T:92-97; RI-10) | the reader's own per-place, role/class experience | reads; authors it in Dungeon Run (the map plane); label "Personal note", ghost "Your note — stays with you, never travels." (RI-13) | authoring: `promoter.note` button + Object on a note; reader slot: 0 | authoring **shipped**; label/ghost **owed** ("implementation of a drained ruling", RI-13; AD:54); reader slot **designed** |
| **the parent's management surface** (beacon = SCENE MANAGER) | "child identity + presentation management… displays and edits the ORDINAL of its children from that same surface" (PM:15-20; SC §R S2:147-150) | child roster rows: name + ordinal box ×6 + "N more not shown" (OB:169-179; O:334-352) | reorders/inserts ordinals from the parent — A2.4's second door, one setter (OB:172-176) | inside Object's 37 | ordinal half **shipped** (§322); rename-from-parent + per-child opacity **designed** (M:774-790, 888-899; ES A20) |
| **the second addon's remote** (`DungeonRun_Drive` / Dungeon Routes) | "the addon that people use just to run routes will have `_remote` as its primary entry" (RM:21-27, 154-161) | select a route · arm (SC F-ii:185-187; T §9) | selects and arms | 0 | **designed**; product sorted to Dungeon Routes (T:150-175) |

---

## U2. RULES ALREADY STATED ABOUT UI

Each row: the rule (short) · where it is stated · status note where B or a later ruling touches it.
Grouped by theme; numbering is this audit's.

### A. What the addon may occupy, and how a surface is entered
1. **The addon occupies only what the user opens** — Remote is a gate and opens only the Map; wheel-zoom and right-drag default OFF; note PULLED on hover, never announced; point facts are a tooltip, not a panel; panes open from panes, never from events; the test line is blank until asked (M:53-68). Restated MP:83-91, MC:37-46, RM:57-61.
2. **THE ENTRY IS A SURFACE, NOT A COMMAND.** "A slash command you have to already know is not a surface"; the slash surface is the power path, not a door (M:70-78; RM:44-51). v1 of the route remote: "No typed commands, no heavy debug modes" (S:89-91).
3. **Space is PER MODE** — "the panes that are not needed are not there"; walking closes Curation and Promotion; the tab stack and a rich timeline do not conflict because they are different modes (UO:396-412).
4. **The Remote is the ONLY front door; the opening chain** Remote → Map → {Map controls, Curation → Promotion → Object (right-click)} (RM:78-86; INV:122-129).
5. **Panes overlap on screen**: Curation/Promotion/Object are `DIALOG` + toplevel over the Map's `HIGH`; the Map's Controls/Curate buttons read through non-opaque backdrops; **no per-pane check can see a cross-pane collision** (INV:131-137; CU:131-137).
6. **Curation and Promotion share a width and stack on one vertical edge** (CU:129; PR:127).
7. **Every pane ends on Close** — Close was on three panes and no surface file until §133 (CU:250-252, 318-320).
8. **Everyman governs what we EXPOSE, not how we BUILD** — a gesture or computed layout locks nobody out; discoverability is the real question for a gesture nothing on screen teaches (M:490-507).
9. **We inform; we do not act** — anything performing a gameplay input is out; `/cast` off the table; the announce is the nearest edge and must DESCRIBE, not instruct others (M:241-266; UO:241; OB:384-398).

### B. Hover, click, selection, subject
10. **HOVER IDs. CLICK HOLDS, and holding opens the edit surfaces** — hover shows identity + state, commits to nothing; the moment a control appears in the hover it is the wrong surface (M:354-366; UO:228-231).
11. **Click-to-hold is NOT the drop-down** — click-to-hold picks the SUBJECT; the drop-down FILTERS the readout's CONTENT from a persistent surface; both survive (M:370-373; UO:232-237).
12. **The map owns the selection and the time state; every other pane reads it** — Object/Promotion "hold no object of their own"; the §63 rule (MP:140-141; OB:53-54, 106-109; PR:119-121; CU:122-123).
13. **One content source, two presentations** — hover (GameTooltip) and the selection readout both render `Map.Describe`; the panel sits where the tooltip would have been ("2 different reading zones is counter-intuitive") (MAP:1560-1598).
14. **The face and the tooltip are the same content at two densities** — a face that disagrees with its tooltip is a bug nobody would look for (M:379-386; UO:238-239); extended: the flattened action list belongs in the hover too (UO:385-387).
15. **Beacon always on show; children FADE per child, control on the beacon; click restores 100%** — "you can never be editing something you cannot see"; per-node never per-kind (M:774-799). Run data HIDES, the product never hides (M:750-772).
16. **Zoom anchors on the VIEW CENTRE, not the cursor** — the cursor is the pen (MP:116-118; MC:56-57).

### C. The readout box, labels, readouts, text tones
17. **The readout box has TWO LIVES** (authoring: derived; driving: authored by a stranger); one component; the driving case constrains it; it is how an author speaks to a runner — "the safe channel" (M:268-290).
18. **It is an output-only box that reads what is SENT to it** — a sink, many senders, one display; the `NS.Tests.Register` registry generalised (M:302-308).
19. **The two lives are DIFFERENT MACHINES; ONE SENDER on the driver, no ladder** — the whole presentation question is EDITOR-side (M:310-319; UO:240).
20. **TWO readout boxes on the editor**: `map.readout` = the CURSOR box, `object.test` = the RESPONSE box; sharing one box lets hover wipe the emission (M:321-335; UO:225-227). ⚠ see U5 #7 (code feeds `map.readout` from SELECTION).
21. **The focus drop-down is an AUTHORING control ("editorial"), not a driver control** (M:292-300; PR:255-258).
22. **"If it informs decision making, it belongs in the readout box we'll be making in the footer space"** — cues stay beside the field; anything weighed goes to one place. "Left at that deliberately — the UI side is going to be redone" (M:1348-1356). Promotion's running order "will become a dynamic readout in a read out box. Maybe a drop down to force a readout focus and a release button" (PR:244-258).
23. **Three open questions on the box, his, unanswered**: flagging (only UNSOLICITED info needs a flag), the ladder (WA dynamic-group `Grow·Sort·Limit·Space·Stagger` is the client's form; taste, not decided), one note or many (`Limit` is the difference) (M:388-420).
24. **Emit on the act; do not catch before; warn ahead only when irreversible** (M:404-406; OB:57-59, 90-96). Rename/Delete of records go through `StaticPopup` — the client's own dialog (CU:102; O:634-638 the dialog names what it deletes).
25. **The test line: one line at the foot, blank until asked, a REGISTRY not a line per control; X/Y deliberately not reported** (OB:81-104). "Contrast NOT YET SPECIFIED · hover half not built" (OB:313).
26. **Label vs readout — the line is STATIC**: does anything call `SetText` after build; four panes name THEMSELVES (labels), two name WHAT THEY SHOW (readouts) (M:1338-1346).
27. **Four identity displays HELD, not applied** (`map.title` `object.title` `promoter.name.current` `map.floor`) — "waits for the UI redo, where the instance can be pointed at" (M:1559-1577).
28. **A third kind of text — banked**: `editor.width` "window 18:29 of…", `editor.skip` "skip 110s" — a button describing itself; "the UI redo may remove the need entirely" (M:1541-1557).
29. **The CONSEQUENCE REGISTER**: a third text tone (grey hint · high-contrast `object.test` · mild-highlight consequence WHILE THE CONDITION HOLDS); replaces the confirm dialog; colour a LOOKUP assigned by being SEEN beside the other three (UO:194-214). S:44 lists it OUT of v1.
30. **The ID is a GRAMMAR, not a label**: a footnote in a FIXED slot (`object.id` at BOTTOMRIGHT −14,10), never moved/restyled/competing; EMPTY rather than hidden when there is nothing to say; a gap in numbering is ordinary (M:1241-1262; OB:286-297).
31. **Prominence is set by the READER, never by what it cost to build** — position leads, label follows, id last (M:1228-1239).
32. **Face / meta split** — characteristics are what you watch (face); intrinsics live behind a tab; `What am I?` carries over to the face (M:1217-1226).
33. **Overflow is TOLD, never silent** — "N more not shown" (OB:177-179; O:349-352; AA A9.4).
34. **Ghost text is a SEPARATE FontString, not placeholder text** — placeholder would be stored as the value (OB:192-197).
35. **Never overwrite what someone is typing** — `HasFocus` guards on every refresh write (O:303-308, 340-343).

### D. Vocabulary of controls (usage), compactness, presentation
36. **A control is a TRIPLE — act · response · outcome — and `usage` summarises it**: action · arm · selection · input · readout · label · icon (M:1297-1336). Navigation and FILTER-vs-GENERATE are NOT usages (M:1358-1369). Seven programmatic slots banked (`exit of effect`, `has effect` earn their place first) (M:1514-1539). Gesture (hold vs tap) banked at two instances (M:1579-1595).
37. **Compactness and presentation are different jobs** — Remote 16px inset, no dividers, no zone headings; Map/Curation/Promotion/Object 18px, title labels, dividers, **zones designated over discreet text**; the six banked labels are "waiting to be REPLACED by the zone they sit in" (M:1373-1394; UO:221-223; RM:5-9).
38. **Labels ABOVE the field, per the client's idiom; the row grows 26 → 44** (UO:224; WI:59-73, 191-198 "labels above, zones over them").
39. **The three surfaces, three questions**: map *what is this?* · curation *what am I looking at?* · promotion *what should this become?* · object *what is this one thing, exactly?*; the editor's product is comprehension (M:1398-1408).
40. **FILTER vs GENERATE decides where a control goes** — Curation subtractive, Map controls additive; "one question decides… the defence against editing becoming whack-a-mole across three surfaces" (M:668-678; INV:79-106; MC:13-28; CU:375-377).
41. **Curation ONLY EVER CHANGES WHAT YOU SEE**; rename/comment/delete are metadata ABOUT the run (CU:59-71).
42. **Promotion holds no edit controls; "all edit options of an object live within its edit mode interface"** (PR:56-67; OB:45-51).
43. **The Remote is not an editor; shows a count, never a judgement** (RM:73-76).
44. **Map controls is a widget of its own "because the map's surface is the drawing area"** (MC:34-35). `100%` is a CYCLE — "one button instead of four, the flattening rule" (MC:65-66). Pan is a quarter view per press (MC:68).

### E. Authoring form on the Object pane (what the pane asks)
45. **The pane is exactly THREE: SENSE · WHAT I DO (DURING | WHEN OFF) · IF SEEN (once | every)** — no firing field; no "what happens next"; advance/set stage are ACTIONS in what-I-do (B:52-59; PM §2:92-108; RI-5).
46. **Position is the NODE's (dragged on the map), never on the behaviour pane** (PM:93-94; RI-5; AA A2.5:66-67).
47. **Each tab is a TRIGGER; a beacon is satisfied when its tabs are; combination selector ABOVE THE TAB LINE, all/any, default all** (PM:110-122) — read through RI-5: "the all/any selector, if it survives, applies to a childless beacon's own tabs only" (PM:107-108).
48. **Two thresholds on one anchor = TWO TABS → two steps** (PM:99; RI-5:65-67; AD:68-92 the two radii are ACTIONS, not senses — `radius:listen`/`radius:sense` rows PULLED).
49. **The naming law §3b: every verb in a drop-down SELF-DESCRIBING** — pass: while in · seen · come here · say a note · let the arrow go · advance · set stage · boss killed · falling; FAIL: once · latch · edge · level · hysteresis · activate · trip · satellite · completor (PM §3b:228-235). Enforced literally by CI's `BANNED` list (CI:350-351); `ratchet`/`on-ramp` are JUDGED family, reported not failed (CI:423-447; AD:141-152).
50. **The adaptor is ONE lookup `code : user`; every pane renders the user word by lookup; a rename is one row; the table carries the QUESTION LAYER only — arming/witnesses/listeners are unlabeled functions, never in a pane** (PM §3b:237-253; AD:12-32; B:32-34).
51. **Pass-through is DEGRADE-TO-LEGIBLE, not silent failure** — a missing row renders the CODE NAME; the checker makes it loud (AA A5.1; AD:34-42; B:35-36). Code today: `SENSE_TEXT[key] or key` (O:913).
52. **The boss NAME is the sense's parameter; the picker is not a term; ONE question per intent** — "boss killed: ⟨name⟩ → advance" (B:29-31; PM §2c:198-205; AD:117-134). Picker fed only from the run; author cannot type; absent unless the sense is a boss sense (AA A3.1; OB:201-207; O:415-429).
53. **No refusal anywhere: told, never locked** — `listen(UNIT_DIED, name)`: no name, nothing arms, "no name - it will not listen" (B:28; AA A3.3); two beacons on one stage TOLD (red "match N"), "no modal, no click-me mid-edit" (B:65-67; RI-6); child 1 as last delete TOLD (AA A2.5); "we tell and trust" (M:742-746; SC S4:42; OB:55-56; PR:72-74).
54. **A determined option is not shown — ABSENT rather than disabled** (OB:74-76; UO:249-251; WI:248-258 `hidden` 596 vs `disabled` 160). Set-target box only for `set`; boss picker only for a boss sense; shape stays child-only (O:457-467, 495-499).
55. **Dropdowns, not rows of ticks** — a four-option choice collapses to one line; at 240 wide a tree of radio rows does not fit (OB:78-79).
56. **Reduce decision load — two spawners, not one with an option** ("child here" / "child at node") (O:314-321).
57. **Tick-to-change SLIDERS for band + radii, with light text ("changes the height of detection"); the SAME control shape for radius:listen (come here) and radius:sense (found); raw read nil when unset** (RI-2; PM §3:218-222; B:44).
58. **Stage is a FIELD, ghosted at the mint with the next free round number, walks gaps, 4.1 legal, NOT `SetNumeric`; match count beside it as a warning** (M:723-746; PR:41, 106-107, 188-191; OB:250-256; O:642-693).
59. **Renaming is IN-FIELD; record acts (run/route rename, delete) are popups** (O:525-527).
60. **The child's ordinal is edited from the child's pane AND the parent's — two doors, one field, one writer** (PM:15-20; AA A2.4; OB:169-176). Blank ordinal = a satellite: "no order - listens whenever this beacon does" (OB:158-168; O:441-448).
61. **The Route-note box is LABELLED "Route instructions" with ghost "Instructions for the player running the route"; "Personal note" stays with ghost "Your note — stays with you, never travels."; neither kind may carry the bare word "note"** (RI-10, RI-13; PM §4b; AA A4.2; AD:53-54; O:851-876).
62. **The FIRST CHILD ACTS AS THE BEACON — its tabs move to child 1; last delete; tabs return to the parent; completion SHED to any child; the parent is the BIGGEST node (management), children the discrete placeable ones (TASTE)** (PM §1:22-36; B:56-59; RI-5; AA A2.5).
63. **The beacon with children is the SCENE MANAGER** — rename each child from one surface, opacity in the editing view, ordinal management; "actions are PER NODE so the UI space does not inflate" (SC §R S2:147-150; PM:15-20).
64. **The beacon's TAB 1 becomes the CHILD ROSTER (name + opacity slider per row)** (M:888-899; OB ☐:343-348 "Design only; the tab stack itself waits on `ui_overhaul_scope.md`").
65. **The icon is a CHILD's; the palette is OURS (a curated word list, not a picker over 3,144); no picker yet — "part of the overhaul. Might be a tab solution. Or a face picker."** (M:824-831; MP:232-239, 407-410).
66. **STEPS replace goTo — no edge to draw, no target picker (`object.target` REMOVED), no on-ramp flag (`object.ramp` REMOVED)** (B:68-75; AA A2.6; OB:41-43, 233-236, 260-262).

### F. The Object pane's engine and its checks (panespec / layout / registry / checkers)
67. **A zone = divider + header + rows, HIDDEN TOGETHER; a header is a PROPERTY of its zone — "the orphan cannot come back"** (PS:33-35; LY:19-28, 154-160; devlog object:34-40).
68. **`hidden` is a FUNCTION of the subject, a static subject SET (`only(...)`), offline-checkable across all four subject states incl. "none"** (PS:43-55; LY:157-160; UO:98).
69. **The Y is COMPUTED; a row is a BAND (owns Y), each cell owns its X and declares it; a skipped row leaves no gap; a row is as tall as its tallest cell; the pane's height is computed** (LY:188-292; PS:60-63).
70. **Spacing is SOURCED from the client (6 header→content · 8 row→row · 12 zone→zone; 24 recorded not adopted); control heights per template (edit 20 · button 22 · check 26 · dropdown 32) with OUR overrides (check/button 20, text 14)** (LY:46-88; PS:139-160; INV:172-190).
71. **A dropdown occupies +50 of ART; three extents FIELD / TEXT / ART; the art is 64 tall on a 32 frame — a rect check UNDER-REPORTS a dropdown by design; ONE dropdown per row in a 204 column** (LY:90-131; PS:105-108; devlog promotion:32-42, 62-79).
72. **The divider is the client's own `options_horizontaldivider`, read from AtlasInfo, with a VISIBLE fallback** (LY:34-38, 135-151).
73. **Two columns DERIVED from the width (96 + 12 + 96 = 204); "ratio vs content to maintain as a constant"** (PS:65-74).
74. **The footer (`object.test`) is NOT a zone** (PS:203-207).
75. **ONE builder — `Spec.Build` — so the smoke and the pane cannot drift** (PS:162-201). ⚠ `object.lua` does not call it (grep: no `PaneSpec`/`Layout.` in O/P/E/MAP) — see U5 #1.
76. **The registry: OUR keys, not global frame names; a missed registration NAMES ITSELF; `kind` speaks the inventory's vocabulary and a bad kind names itself; the probe global is INTROSPECTION ONLY (Keys/Get/Misses)** (UI:7-21, 59-116).
77. **`Click()` fires on a hidden frame — no "open the pane first" ordering** (UI:23-29, 148-150).
78. **The factual file (`interface/<surface>.md`) IS THE AUTHORITY; a difference reads as "the spec has drifted", never "the doc is out of date"; the code complies** (OB:5; CI:224-231; INV:3-9).
79. **Nothing reaches the client that is not in the inventory first; disk → geometry check → in-game** (INV:9-12).
80. **The checker checks the MECHANICAL part only; lag is expected and reported as DRIFT, never failure; neither side assumed correct** (CI:1-33, 475-478; INV:260-272). The scoreboard is a NOTE, not a finding (CI:302-321).
81. **Positional values are declared in both registers and generated in neither; emitting the spec from the doc was rejected** (INV:274-284).
82. **`check_rects` REPORTS, does not assert; one pane at a time; a finding is news** (CR:30-47). **A9.6 RED: it computes on the wrong canvas (240×330 vs 600); hand-placed controls (`object.sense` · `object.ordinal` · `object.note`) must be brought under panespec or NAMED as unverified — never silently counted clean** (AA A9.6:231-238; RI-11).
83. **UI placement arguments are DEFERRED TO THE OVERHAUL — "out of place when we know it needs an overhaul"** (RI-11; B:96-99).
84. **`check_interface.py` does not read the header's content box (inset + width) against the children** ☐ (RM:126-128).
85. **The `<pattern>` keys escape the coverage score — expand or teach the checker to count N** ☐ (CU:286-295).
86. **A dropdown cannot sit on an 18px content line — either the selector is the one control that does not meet the line, or the line moves to 25 for dropdowns "and is stated as such"** (PR:221-226).
87. **Grow the pane, don't shrink the controls — "make the pane bigger. It already takes over the UI. No point fighting that."** (O:572-577; devlog promotion:70-72); ceiling 600 in the smoke (SMK:1774).
88. **BOTTOM-anchoring is the right anchor for a footer row** (RM:130-131; CU:247-249).
89. **A9.1 — every pane assertion written before §322 is UNVERIFIED (registration was a silent no-op); the static registration count is a criterion gap** (AA A9.1:213-220).

### G. The overhaul as an ordering rule
90. **The overhaul goes FIRST; the MVP scopes its first pass** — "present the options needed to BUILD that route" (S:53-68; SC S10:83; T:184-186).
91. **The overhaul is the DECISION PASS, not a redesign — every banked ☐ is one element to be ruled on IN CONTEXT; "the bank is not debt, it is the agenda"** (UO:11-26).
92. **The dependency: CONTENT → ARRANGEMENT → DESCRIPTION (panespec becomes the intended pane) → PORT (object.lua builds FROM it; map/promoter get one); steps 3–4 cannot move first — "the port IS a redesign"** (UO:29-47; OB:9-28).
93. **A pane sits ON the map, so a TAB STACK, not WA's scroll; no empty tabs; a tab is spawned from the end of the one before; the strip is a record of decisions; the face carries a flattened summary — "concise over verbose"** (UO:324-395).
94. **"The map editing interface will be a lighter version of WA. Tabs, drop downs, ticks, sliders. Loaded based on the decision tree followed."** (UO:243-251).
95. **The bench rules that go with it**: an item is not a discussion — "if it needs a conversation it belongs in chat first and arrives here as a question with options; a row with no options is not ready to be drained" (RI:22-23); a tie-break is INSTRUCTION LINES, not deliberation (RI:12-16); show the instance, not the category ("A bit of overwhelm… Broad topics with no clear examples and then being asked to make a ruling", M:1574-1577).

### H. Text safety on surfaces
96. **No input reaches an interpreter — text a person supplies reaches a SINK, never a PARSER; three sinks (chat = argument, execution = none, rendering = ☐ open hole: `|c` `|T` `|H` in a FontString)** (M:422-454).
97. **Sanitise at the BOUNDARY (import), not at the render** (M:337-352).
98. **The announce is consented to (a tick on the DRIVER side) and improper by construction (`/say /run`); no announce while Curation or Promotion is open** (M:456-483).

---

## U3. VOCABULARY THE UI ALREADY USES

§3b test applied as CI applies it: **FAIL** = a word on the law's fail list appears in an author-facing
string; **OWED** = judged §3b's family, in the adaptor's second table; **flagged** = the adaptor
notes it as "close to technical"; **pass** = listed in the law's pass set or plainly self-describing;
**—** = a surface/structural label not yet assessed by any record.

### Registry keys (the control names — the code's side, never rendered)
`remote.*` (7) · `map.*` (12) · `mapcontrols.*` (13) · `editor.*` (24) · `promoter.*` (18) · `object.*` (37) — the `<file>.<control>` form (UI:15-16); patterns `map.tile.<n>` `editor.kind.<key>` `editor.handle.<a|b>` `editor.step.<n>` `promoter.order.<n>` `object.kid.ordinal.<n>`. `kind` vocabulary: readout · button · check · dropdown · edit · frame · scroll · texture (UI:97-100); INV:149 lists five for children.

### panespec zone names (the Object pane's declared zones)
`identity` · `behaviour` · `stage` · `children` + `footer` (not a zone) (PS:76-133, 203-207). Subject states: `beacon` · `child` · `note` · `none` (PS:46). Earlier merged names: `detect`+`action` → behaviour, `stage`+`arrival` → stage (devlog object:66-69). Overhaul-side names (prose only): `Face` · `Stage 1` · `Stage 2` · `Children (name · opacity)` · `What they are doing` · `Action (N)` · `META DATA` (UO:118-121, 253-264) — superseded in shape by RI-5's three items (see U4).

### Object pane strings (O), with the §3b read
| string | where | read |
|---|---|---|
| "nothing to edit" · "right-click a beacon, a child or a note on the map" | O:238, 260 | pass (plain) |
| title = `Map.Describe` label: "BEACON" · "child - in a beacon" · "personal note" · "PIN" · "TERMINAL STOP" · "combat START" · "combat end" · "travel sample" · "combat travel sample" | MAP:111-118 | — (identity labels; `LABEL` table) |
| fact line: "child" / "beacon" / "personal note" · "moved" · "z N" · "no world position" | O:278-285 | pass |
| "move" (chip) · "Delete" · "Close" | O:617, 631, 1137 | pass; `move` is E5's candidate (ES:178) |
| "stage" (label) · "match N" (red) · "free" | O:648, 310-312 | pass; "match" E5 candidate |
| "behaviour" (heading, hand-placed y=−136) · "on success" (label) | O:697, 701 | — (a zone caption and a field label; M:1388-1394 says such labels are "waiting to be REPLACED by the zone") |
| "advance (+1)" · "go to stage" (outcome dropdown) | O:710-711 | pass; AD rows `outcome→advance` "advance (+1)", `outcome→stage` "go to stage" (AD:65-66) |
| "N child/children" · "no children" · "child here" · "child at node" · "N more not shown" · "child N" (roster fallback) | O:355-357, 761, 784, 351, 339 | pass |
| "detect" (kidLabel over the sense/role block) | O:812 | AD:50 — "the pane labels it **detect**" for the `sense` question; not judged either way |
| "reach here" · "boss engaged" · "boss killed" (sense) · "pick a boss" · "no boss engaged in this run" · "no name - it will not listen" | O:154-158, 421, 938, 425-426 | pass (PM §3b names boss killed; AD:51, 133-134) |
| "order" (label) · "N other" · path "4.1:3" · "no order - listens whenever this beacon does" | O:880, 437-438, 441-448 | pass; `ordinal`→"order" (AD:52); `satellite` FIXED §326 (AD:147) |
| "nothing" · "stage complete" · "set stage" · "start of stage" · "updater" (role dropdown) | O:160-163, 966-970 | pass ×4; **"updater" flagged** "close to technical" (AD:63) |
| "radius" · **"trip wire"** (shape dropdown) | O:1005-1006, 469 | **FAIL** — `trip` is on the §3b list; AD row `shape→wire` OPEN, "must name a SHAPE, never a firing" (AD:94-115; AA:263-267). ⚠ CI's `SPEAKS` regex reads `SetText(`/`UIDropDownMenu_SetText(` with a literal string; the "trip wire" literal is inside a menu-entry table (O:1006) and an `and/or` expression (O:469), so the live run reports no 3b drift while the string ships |
| "only if unseen" (chip) | O:1048 | pass by E5 (ES:191); `unseen` not on the fail list; PM's floor words are WHILE IN / SEEN (PM:157-164) |
| "point the tracker" · "nothing" (action dropdown) | O:1068-1069, 474-475 | pass; AD:64 |
| "Route instructions" · ghost "Instructions for the player running the route" | O:853, 876 | pass — RULED RI-10 (AD:53) |
| **"ratchets when found"** · "ratchets when found - but no radius" · "nothing ratchets" · 'ratchet → "name"' (answers line) | O:215-231 | **OWED** — `ratchet` "needs a word" (AD:145; CI live note "1 term(s) reach a pane with NO user word… ratchet") |
| "satisfying this promotes the index to N" · "drag it on the map - click to drop" · "click a node on the map to place the child" (hint) | O:515-521 | — (`index`/`promotes` not assessed by any record) |
| "#N" (id footnote) | O:275 | — a grammar, not a label (M:1241-1262) |
| test-line emissions `move-z` · `child-here` · "role is now X" | O:621, 1401; ES R23 | — bench-facing |
| "Delete this %s?\n\nThe run it came from is untouched." | O:537 | pass |

### Other surfaces' strings
| surface | strings | read |
|---|---|---|
| Remote (W) | "Dungeon run" · "Pin here" · "Arm" / "Stop" · "not recording" · "Map" · count | pass; `arm` "in our control vocabulary and in none of the eleven forms the client's own options UI uses" (M:527-529; WI:115) |
| Map (MAP) | "Controls" · "Curate" · "< floor" · "floor >" · title (run name) · ref | pass |
| Map controls (MAP:1915-1962) | "Map controls" · "zoom −" · "up" · "zoom +" · "<" · "Re-centre" · ">" · "100%" (cycles) · "down" · "Reset" · "enable mouse wheel zooming" · "enable right click panning" | pass |
| Curation (E) | "Curation" · "Rename" · "Delete" · "show" (caption, no divider — the orphan class still alive here, CU:163-165) · "all" · six kind ticks named from FILTERS · "Play" · "Peek" · "Reset" · "track most recent node" · "Promotion" · "Close" · "pick a run above" · "peeking - the whole run, ticks still applied" · "no runs recorded" · "Rename run:" · "Delete the run %s?…" · `editor.width` "window …" · `editor.skip` "skip Ns" | pass; width/skip = the banked third text kind (M:1541-1557) |
| Promotion (P) | "Promotion" · "Create route" · "Create beacon" · "Personal note" · "Rename" · "Delete" · "stage" · "running order" · "+ create new" · "carries over from the node" · hints ("select a point on the map" · "that is already a promoted object" · "that point has no map position" · "name it and create - beacons collect afterwards" · "load a run - a route belongs to a map" · "pick a route, or + create new" · "cue, note, radii and icon are edited after minting") · "Rename route:" · "Delete route %s and everything on it?" · "Close" | pass; "Personal note" is the RULED label (RI-10) |

### The adaptor's rows today (AD:48-66, 131-134)
`sense`→(labelled "detect") · `reachHere`→"reach here" · `ordinal`→"order" · `routeNote`→"Route instructions" · `note` (personal)→"Personal note" (OWED string) · `radius`→"radius" · `bandUp`→"up" · `bandDown`→"down" · `role→complete`→"stage complete" · `role→set`→"set stage" · `role→start`→"start of stage" · `role→update`→"updater" (flagged) · `action→supertrack`→"point the tracker" · `outcome→advance`→"advance (+1)" · `outcome→stage`→"go to stage" · `sense→bossKilled+boss`→"boss killed: ⟨name⟩" · `sense→bossEngaged+boss`→"boss engaged: ⟨name⟩" · `shape→wire`→OPEN. Pulled: `radius:listen` · `radius:sense`. Owed list: `ratchet` (open) · ~~`on-ramp`~~ (gone §340) · ~~`satellite`~~ (fixed §326).

### PM's proposed pane words (candidates; "names are still the naming pass's", PM:5-6, 164)
SENSE: reach here · boss engaged ⟨name⟩ · boss killed ⟨name⟩ · falling · in combat; WHAT I DO: update note · set supertracker · advance · set stage; IF SEEN: once | every; floor words: WHILE IN · SEEN; earlier "when true": point here · say a note · let the arrow go (PM:92-98, 124-164). E5 candidates on file (ES:163-225).

---

## U4. THE OVERHAUL AS STATED

### What it was scoped to (mvp_scope + ui_overhaul_scope, 2026-08-16)
- **Order**: overhaul FIRST, the MVP unblocks it — "present the options needed to BUILD that route", then "the driver — drive that session, from a remote" (S:53-68). Ratified SC S10:83 ("overhaul first… MVP is the test driver that is a suite option of Dungeon run") and T:184-186 (sequence step 3).
- **First-pass content**: for a childless beacon "`Face : Stage 1 : Stage 2`, and inside those only the supertracker y/n and the reach. Everything else the four-strip structure describes is out of the first pass" (S:66-68).
- **The four tab strips**, derived not configured: childless `Face : Stage 1 : Stage 2`; with children `Face : Children (name · opacity) : What they are doing`; first child `Face : Stage 1 : Action (N)`; other child `Face : Action (N)` (UO:112-129).
- **Stage tabs = the closed loop**: tab 1 ON-RAMP (supertracker y/n · update note y/n), tab 2 OFF-RAMP (reach my waypoint · update note y/n); "the OFF-RAMP CARRIES NO TRACKER ACTION — a RULE, not an omission" (UO:130-156). Off-ramp splits with children; self-completion structural (UO:157-170). `complete`/`set` become ACTIONS in `Action (N)`; `role` may not survive (UO:172-184). "The transition DESTROYS the beacon's own actions" (UO:186-192).
- **Object gets a FACE and TABS; the zones are already the tabs** (UO:216-220; OB:401-430).
- **A lighter WA: tabs, drop downs, ticks, sliders, loaded by decision tree; a tab is spawned from the end of the one before; a TAB STACK not a scroll; the face carries a flattened summary** (UO:243-395).
- **The consequence register** as a third text tone (UO:194-214).
- **The route remote** as a seventh surface with its own interface file (S:72-95).
- **Mechanism**: `panespec.lua` + `layout.lua` are the candidate; two places WA is ahead (no typed x; width as a UNIT), two places ours differs for a reason (static `hidden` set; header belongs to a zone), two things missing (a level above zones for tabs; explicit `order` numbers) (UO:50-109).
- **The 575-in-330 finding is answered by tabs** (UO:70-76, 362-365).
- **Open at scoping**: the content list (19 hopes, ~2,900 words, uncollated); what goes where; whether `behaviour` and `stage` are one tab or two; the six ☐ "not declared in panespec" (UO:432-442). **Out of scope**: rebuilding the engine; the map render and `map.readout`'s internals (UO:444-448).

### What has changed since (2026-08-17/18, best working model — B positions)
| stated in the overhaul scope | now |
|---|---|
| `Face : Stage 1 : Stage 2`; on-ramp / off-ramp tabs; "OFF-RAMP carries no tracker action" | **The pane is exactly THREE: SENSE · WHAT I DO (DURING \| WHEN OFF) · IF SEEN.** No firing field; G15 IS the during/when-off pairing; advance/set stage are ACTIONS in what-I-do (RI-5; B:52-59; PM §2:92-108). On-ramp is GONE as a mechanism (RI-8; `object.ramp` removed A2.6) |
| `Action (N)` tabs, one per action; many-of | **Each tab is a TRIGGER** carrying its sense + what-I-do; combination all/any above the tab line — "if it survives, applies to a childless beacon's own tabs only" (PM:107-122). Two thresholds = two tabs (RI-5) |
| beacon-with-children strip `Face : Children : What they are doing`; "the beacon loses its tab 1"; the special child (first by ordinal) takes it | **The FIRST CHILD ACTS AS THE BEACON** (lure + note); last delete; tabs return to the parent; completion SHED to any child; parent = biggest node, management; children the discrete placeable ones — TASTE (PM §1:22-36; RI-5; AA A2.5). Ordinal management lives on the PARENT (A2.4 second door, shipped §322) |
| activation edges / `goTo` chains (advisory) | **STEPS**: an ordinal child is a step, points at itself, order = ordinal alone; `goTo` + Heads/BrokenLinks/Cycles + `activate` + `onRamp` retire in one commit (B:68-79; AA A2.6); `object.target` removed |
| note actions OUT of v1 (S:40; SC S8) | **Notes are IN v1** — S8 REVERSED (RI-9); **TWO NOTE KINDS, TWO SHELVES**; labels "Route instructions" / "Personal note" with ghosts; the reader gets TWO SLOTS (RI-10, RI-13; T:92-97; PM §4b) |
| reach on the childless face: "supertracker y/n and the reach" | G2 shipped: the same three reach boxes serve the beacon (O:488-512; AA A1) — and **band + radii are tick-to-change SLIDERS with light text, same shape for both radii; raw nil** (RI-2; PM §3:218-222) |
| the route remote, spawned from Promotion, "Go, stop" | **TEST DRIVE = its own suite entry INSIDE Dungeon Run**, an extension of the editor's play pacer; `/dr walk` gone, not revived; assurance = the diagnostic suite (RI-3; B:44-45; T:185-189) |
| boss beacon as two tabs + ANY (PM §2c) | the tabs are the DRIVER's implementation; the author has ONE question per intent; the name is the sense's parameter (B:29-31; PM §2c:198-205) |
| "argumentation over UI placement" (RI-11 a/b/c) | **DEFERRED TO THE OVERHAUL**; the checker names hand-placed controls as unverified; the canvas red is fixed now (RI-11; B:96-99) |
| position fields on the pane | **Position is the node's, not the pane's** (RI-5) |
| `panespec` had five zones (identity · detect · action · stage · arrival) | four after two merges (identity · behaviour · stage · children); the on-ramp cell taken out of the stage row by A2.6 (PS:94-125) |

### What is explicitly OUT (of v1 / of the overhaul's first pass / of scope)
- Out of v1 (S:35-49): children (as the first walk's subject), boss death/CLEU as a second axis, `maxSeen` + escapement, the player's correction path, the consequence register, the flight list itself. ⚠ Two of these moved: notes IN (RI-9); boss senses SHIPPED on the child (A3).
- Out of the overhaul's first pass: "everything else the four-strip structure describes" (S:66-68).
- Out of the overhaul's scope: rebuilding the engine; the map render and `map.readout`'s internals (UO:444-448).
- Out of the pane: arming, witnesses, listeners — functions, "never in a pane" (PM §3b:237-242; AD:22-32).
- Out of the model at all: no dungeon knowledge, no heatmap, no judgement of a route, no capture-time filtering (M:1412-1423). Death-location pointer: later (SC S15). Radius floor: no (SC S14). Dataset export UI: none yet (SC §R S11).
- Deliberately absent on the map: hopes "EMPTY — this half is his" (MP:450-451).

---

## U5. CONFLICTS AND GAPS

### Conflicts (statements about UI that disagree between sources)
1. **panespec vs object.lua describe DIFFERENT panes** — order (spec fact→name→delete; code name→fact→move+delete), pairing, no `object.title` row in the spec, three different content x (16/18/22) in one zone (OB:9-19). `object.lua` never calls `Spec.Build`/`Layout` (grep); the orphan heading `behaviour` panespec says "cannot come back" (PS:33-35) **still exists in the shipped pane** at a fixed y (O:695-697, created once, never hidden). Both files say the pane is not built from the spec ☐ (OB:7, 311); recorded here because the spec header reads as if the fix landed.
2. **Which UI shape governs the pane**: UO's `Face : Stage 1 : Stage 2` / on-ramp–off-ramp / `Action (N)` (UO:112-192) vs B/PM/RI-5's three items SENSE · WHAT I DO · IF SEEN. B is governing; UO carries no banner saying so (UO is not in B's GOVERNING or HISTORY lists; reached only via M:1433 and OB:337/348 pointers).
3. **The child roster tab** — M:888-899 and OB ☐:343-348 say the beacon's tab 1 becomes the roster (name + opacity slider); PM §1:22-36 now says the beacon's tabs MOVE TO CHILD 1 and the parent's surface is management ACROSS the set. Compatible in intent (management on the parent) but the roster's "opacity slider per row" has no B position; ES A20 "designed only".
4. **The route remote**: S:72-95 "a SEVENTH surface… its own interface file and declared rows"; `driver_bench_proposition.md §3:169-173` "It should not be a seventh surface… a MODE of the existing walk, not a new pane" (history-grade §0-14 per B:14-16); RI-3 rules the test drive is "its own suite entry INSIDE Dungeon Run… an extension of the editor's play pacer" and `/dr walk` is not revived. T:172 still lists "G3 route remote" under Dungeon Run. No record says whether "suite entry" is a pane, a mode of Curation, or the remote S describes.
5. **`object.action` one-of vs many-of**: OB:228-232 "ONE-OF TODAY, MANY-OF IN THE OVERHAUL (§179)" against UO:312-319; RI-5 makes what-I-do a DURING | WHEN OFF pair of actions per tab. The shipped dropdown offers `nothing` / `point the tracker` (O:1068-1069).
6. **`map.readout` — hover box or selection box**: M:327-328 (and UO:225-227) name it "the CURSOR box. What you are pointing at"; the code fills it from `selected` (MAP:1534, 2027) and hover goes to `GameTooltip` (MAP:1452-1456), "the hover into GameTooltip, the selection into these font strings" (MAP:1560-1565). M:384-386 itself says whether its rows are "identity and state" is unrecorded.
7. **`map.readout` size**: MP:427, 442-443 "nine FontStrings — a title and four key/value rows"; code `READOUT_ROWS = 8` (MAP:1569) → 17 FontStrings.
8. **`shape → wire` "trip wire"** ships in the pane (O:469, 1006) while AD:94-115 pulls the row as a §3b breach and AA:263-267 calls the user word WRONG; CI's live run reports 0 drift because its `SPEAKS` regex only sees `SetText("literal")` forms (CI:360; the strings sit in a menu table and an `and/or`). AD:177-179 says "A5.3 puts a third check… every user-visible string in a pane resolves through this table" — CI's fourth check enforces the BANNED words on `SetText` lines only.
9. **A9.6's named canvas**: AA:231-233 says `check_rects` reports against 240×330; `check_rects.lua` takes its box from the MEASURED root rect (CR:40-49); the literal `PANE_W, PANE_H = 240, 330` sits in the smoke wireframe (SMK:1681, comment "read from `object.lua:397`") which then asserts against `MAX_PANE = 600` (SMK:1774). Two canvases, one named.
10. **Consequence register**: UO:194-214 designs it as replacing the confirm dialog; S:44 lists it OUT of v1; the client's `StaticPopup` remains the ruled dialog for record acts (CU:102; LY:37).
11. **"the pane is a lighter WA — tabs" (UO:243-251) vs "Dropdowns, not rows of ticks… at 240 wide a tree of radio rows does not fit" (OB:78-79) vs WA idiom "a range is `‹ value ›`, never a bare slider" (WI:214-219) vs RI-2 "a slider the author TICKS to change"** — four statements about control forms; none reconciled into one form list.
12. **Inset**: RM:5-9 and M:1378-1386 justify Remote 16 vs 18; devlog remote:94 still lists "The inset is 16 here and 18 everywhere else. Reconcile or justify" as open; PR:210-226 finds four left edges in Promotion including 16 on `note`/`create` — "16 is the COMPACT inset and this is a presenting pane".
13. **`kind` vocabulary**: UI:97-100 eight kinds; INV:149 five kinds for children ("dropdown · edit · check · button · readout"); OB rows also use `text` in panespec (PS:80, 109) vs `readout` in the doc.
14. **The heights per subject** in OB:315-323 (none 113 · note 169 · beacon 415 · child 575) are the SPEC's wireframe heights, while the shipped pane is a fixed 600 (O:577); OB:294-295 anchors `object.id` by those four heights.

### Things DESIGNED with no surface (control or frame)
- The footer readout box with a focus drop-down + release (M:1348-1356; PR:244-258) — no frame; `object.test`/`object.hint` are the placeholders.
- Per-child opacity from the beacon; rename-each-child-from-one-surface (M:774-790; SC §R S2:148-149) — no control (ES A20, G7).
- The icon picker — "part of the overhaul" (MP:232-234; ES G5).
- The tab strip / face / flattened summary (UO) — no frame; panespec has no level above zones (UO:103-105).
- Tick-to-change sliders for reach/band (RI-2) — the pane has three edit boxes (O:1017-1030 via `numBox`).
- SENSE · WHAT I DO (DURING | WHEN OFF) · IF SEEN — today the pane has `sense` (3 values), `role` (5), `shape`, `reach ×3`, `action` (2), `outcome` (2 on the beacon), `unseen` (chip, only for `set`); no DURING/WHEN OFF pair, no IF SEEN control (O:409-475).
- The all/any combination selector "above the tab line" (PM:121-122) — none.
- `falling` · `in combat` senses (PM:95, 134-143) — not offered; capture of `falling` is a capture-spec item.
- The two reader slots (route note · personal note) — no consumer, no frame (T:92-97; PM §4b).
- The route remote's controls (S:85; ES G17); the test drive's readout `hit · skip · false_advances` (AA A6.4).
- The player's manual correction of the index (M:1004-1006; ES G8) — S:43 out of v1.
- The announce message field + the runner's consent tick (M:456-483; ES G3).
- Export/import door (ES G4; SC §R S11 "no UI for it yet").
- Generated reading aids on Map controls: detector radius drawn, same-height painted zones, per-plane colour (MC:131-144).
- Curation's readability modes (pulls / travel-between-pulls / general kind selection) (CU:365-373); the peek hold-to-latch FORM (CU:325-360, "a form, not a proposal").
- The identity displays' re-tag and the third text kind — held for "the UI redo" (M:1541-1577).
- Cross-pane collision check — "no instrument" (INV:136-137; CU:136-137).
- The header content-box check in CI (RM:126-128).

### Surfaces / controls declared with a gap
- `object.stage`'s `set` does not commit ☐ (OB:307-309).
- `object.test` contrast unspecified; hover half not built ☐ (OB:313).
- Curation laid out for 280 in 320 ☐; `editor.skip` at −231 on a −226 row (CU:141, 237-238); `editor.bar` 40 short of the column (CU:215).
- Promotion: `stageGhost` no entry ☐; four left edges ☐; not in panespec ☐ (PR:203, 210-226, 131).
- Map: not in panespec ☐; `map.readout` family uncounted ☐; the pane walk's readouts "unverified until the next capture" ☐ (MP:152, 426-427, 440-443).
- Remote: rename pending ☐ (RM:17-19).
- Object: three hand-placed controls outside panespec (`object.sense` · `object.ordinal` · `object.note`) named unverified until the overhaul (AA A9.6; OB:188-190).
- Registration: A9.1 pre-§322 pane greens UNVERIFIED (AA:213-220).

---

## U6. WHAT `panespec.lua` CAN AND CANNOT EXPRESS TODAY

Read from `panespec.lua` (209 lines) and `layout.lua` (294 lines); the smoke exercises it at SMK:1596-1850.

**CAN**
- **Zones**: an ordered list; each `{ name, header, applies, rows, rowHidden }` (PS:76-133). A zone's `header` is optional (`Layout.NewZone` — "text, or nil for a zone with no heading", LY:167). Zone chrome: divider (1px, client atlas or fallback) + header (14px `GameFontNormalSmall`) with sourced gaps 12 / 6 / 8 (LY:64-68, 237-284).
- **Rows** of **cells** `{ key, x, kind, w? }` (PS:60-63, 79-132); a row's height = its tallest cell, or an explicit `opts.h`, else 20 (LY:203-221). Cells declare their own X (LY:191-198). Widths default per kind (`Spec.W`: edit 100 · check 26 · button 80 · dropdown 100), overridable per cell; `text` fills to the column edge (PS:135-137, 185). Heights per kind: OURS (`Spec.H`: edit/check/button 20, text 14) over the client's (`Layout.H`: edit 20 · button 22 · check 26 · dropdown 32) (PS:139-160; LY:88).
- **Conditional visibility — STATIC subject sets**: `applies = only("child")` per zone; `rowHidden = { [i] = only(...) }` per row; the predicate is `function(subject) -> hide` over `Spec.SUBJECTS = { beacon, child, note, none }` (PS:43-55, 86-92, 103, 119, 128; LY:157-166). A hidden zone hides rule + header + rows together; a hidden row leaves no gap (LY:237-284).
- **Computed Y and pane height** for a subject (`Layout.Apply` returns the final y; `Layout.Height` adds pad) (LY:231-292).
- **A dropdown's real footprint**: `+50` art budgeted at build (`Layout.DROPDOWN_PAD`), FIELD/TEXT/ART accessors, and the 64-tall art overhang recorded (`Layout.ART`) (LY:90-131; PS:186-194).
- **Column geometry**: `Spec.x, Spec.top, Spec.width = 18, -40, 204`; two columns derived (`HALF=96`, `COL2=108`, `DROP=154`) (PS:63-74).
- **A footer that is not a zone**: `Spec.footer = { "object.test", 0, "text" }` (PS:203-207) — declared, not laid out by `Spec.Build`.
- **One builder for pane and smoke** (`Spec.Build(Layout, parent, make)`) — the caller makes the widget; the spec sizes it (PS:173-201).
- **Offline checking**: overlaps, off-column, per-subject height, ceiling 600, our-size assertions (SMK:1757-1850); `check_interface.py` reconciles each cell's w/h against `object.md` (CI:150-255).

**CANNOT**
- **Tabs / a level above zones** — `Spec.zones` is flat; UO:103-105 names it missing ("Tabs need a container over them"). Nothing carries a `Face`.
- **Explicit `order` numbers** — order is array position; UO:106-108 names it missing (multi-contributor assembly, the readout box).
- **Anchoring** other than TOPLEFT of the parent at `(x + cell.x, y)` — no right/bottom anchors, no relative anchoring between cells (LY:268-273). The shipped BOTTOMRIGHT controls (`object.close`, `object.id`) are outside its model.
- **Horizontal layout** — a row is a BAND; X is typed per cell, not computed ("widening it to solve horizontal placement too would be a second thing to be wrong", LY:265-267); UO:91 calls the typed x "the half we did not finish".
- **Width as a UNIT** — widths are a per-kind pixel bag plus overrides, not multipliers off one unit (UO:92).
- **Dynamic / functional `hidden`** — no `hidden = function(state)` over field values (only the subject kind); e.g. "set-target box appears only for `set`", "boss picker only for a boss sense" (O:459-467, 418-429) are outside the spec's expressiveness — which is why those controls are hand-placed (OB:188-190; AA A9.6).
- **Repeated / pooled rows** — the six `object.kid.ordinal.<n>` roster rows and `object.kid.more` are not in the spec (PS:127-132 has only `kids` · `here` · `pick`).
- **Labels above fields** (UO:224) — a cell is one control; a label is a `text` cell in its own row or a zone header; no label-attached-to-field form.
- **Sliders, tab strips, sub-tabs, a scroll container** — no such `kind`; `Spec.W/H` know edit · check · button · dropdown · text.
- **Widget creation, behaviour, refresh, text** — "No frames, no behaviour, no refreshing" (PS:7-10); the caller owns creation.
- **Other panes** — Map, Map controls, Curation, Promotion, Remote are not declared in it (MP:152; PR:131; CU/RM/MC no spec; INV:297 "declared in panespec: 1").
- **Cross-pane relations** (strata, shared edges, overlap between panes) — per-pane only (INV:136-137).
- **Text metrics** — a header sized by its text has no width offline; reported as `Unmeasured` (SMK:1737-1755); `text` cells carry a width but not a measured height ("the invented-font-metric again", SMK:1783-1786).
- **The pane it describes is not the pane that ships** — `object.lua` builds by hand (OB:7; no `Spec.Build` caller in the addon); `Spec.H` documents `object.lua`'s own sizes at line citations that have moved (PS:144-146 cite `object.lua:434,719,737,449,579,602,420,471,634`; the current file places these elsewhere, e.g. `moveChip` O:613-615, `delBtn` O:628-630).

_End. Counts: U1 14 rows · U2 98 rules · U3 8 vocabulary groups (registry · zones · 22 Object-string rows · 5 other-surface rows · adaptor 18 rows · PM candidates) · U4 10 scoped items + 11 changed rows + 6 OUT groups · U5 14 conflicts + 20 designed-no-surface + 8 declared-with-gap · U6 10 CAN + 14 CANNOT._
