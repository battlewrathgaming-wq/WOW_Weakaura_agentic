# Dungeon Routes — EXPRESSIONS (three audits, collated)

_Analyst, 2026-08-17. Before inventing a programmatic model: what have WE been trying to express,
what do the installed MODS already let a person express, and what does the FIELD (route tools and
guides) already say — collated so the model is chosen from what exists. Raw reports, unedited:_

    audit/expr_self.md         ourselves — 48 author expressions · 25 reader receptions ·
                               20 conflicts · 18 gaps · a candidate vocabulary from words on file
    audit/expr_mods.md         WeakAuras · DBM · TomTom · pfQuest — the choices as the user meets
                               them, strings quoted, cross-addon table
    audit/research_routing.md  MDT · keystone.guru · written guides · speedrun · TourGuide/
                               WoW-Pro/Zygor — the step grammar, what relies on shipped data,
                               vocabulary shortlist

_Scoping S3 rules: behaviours first, then how they are constructed, THEN names. So this file
collates BEHAVIOURS and the words each source uses for them; it decides no name._

---

## 1. ONE TABLE — concept · ourselves (model / code / advisory) · mods · field

| concept | ourselves | mods (as the user meets it) | field (tools + guides) |
|---|---|---|---|
| the whole thing | route (all) | WA "aura"/"group" · DBM "mod" · TomTom "waypoints (this zone)" · pfQuest "quests" | **route** (all), MDT code "preset", "guide" |
| the driven unit | beacon (all) · theater/scene (advisory) | WA aura · TomTom waypoint · pfQuest node · DBM (none) | **pull** (MDT/keystone/guides) · **step** (TourGuide/WoW-Pro/Zygor) |
| a place | position from a read; anchor (model) | WA "Location" = zone/subzone (no x/y) · TomTom `/way x y` · DBM `/dbm arrow x y` (raid) · pfQuest node/spawn | map x/y on a shipped map (MDT) · `\|M\|x,y\|`/`goto x,y` (step-drivers) · **landmark noun** in prose ("after the bridge", "to your right") |
| a stage / phase | stage (all), ordinal, fractions | DBM "Phase %d" (mod-authored) · WA "DBM Stage" (no installed source) · TomTom/pfQuest absent | pull index (MDT) · numbered steps · boss 1..N |
| order / next | ratchet + maxSeen (model, scoping S6) · activation edges / chain (advisory) | WA Any/All/Custom (no order) · TomTom "next closest" · pfQuest nearest-neighbour route · DBM "Next %s / %s soon" | pull index, "Move up/down" (MDT) · drawn path direction (keystone) · "then" (prose) · line order + `next` (step-drivers) |
| arrival / done | reach + band; advance (model/code) · segment/point test (arc) | TomTom "Arrival Distance", "arriving at a waypoint" · WA "Range Check ≤ n" to a UNIT · DBM arrow auto-hide ≤ 3 yd (no word) | `\|CC\|` coordinate reach, zone change (step-drivers) · forces-% (MDT companions) · "crosses certain lines" (speedrun) · none in planners |
| the arrow | supertracker / tracker (model/code) · pointer, heading (advisory) | TomTom "Crazy Arrow" · DBM "run to / run away" arrow (raid) · pfQuest arrow (icon/title/sentence/distance) | **waypoint / arrow / goto** (Zygor, WoW-Pro "follow the arrows") |
| a note | note (all; NO FIELD in code — gap G1) | WA "Chat Message"/text · DBM "Announce"/"special warning" · pfQuest objective sentence | **note** (MDT "Insert Note", `\|N\|`) · comment (keystone) · inline sentence (prose) |
| a boss | boss child kind (advisory); `unit:death` (model hopes) | DBM "engaged / down / wiped" · WA "Entering Encounter" (no source here) | boss section prose; MDT enemy info (shipped) |
| a skip | skip (scoping S6); clip-through (model) | absent everywhere | **skip / ignore** (universal) · `\|O\|` optional step · absence from a pull |
| a repeat guard | ifUnseen (code) · once/while (advisory) | WA "Aura Found/Missing/Always" states · TomTom "Save between sessions" | (none) |
| the group of things | theatre + children (model/code) · scene + satellites (advisory) | WA "Group / Dynamic Group" · pfQuest "cluster" · TomTom "all waypoints" | pull = set of enemies (MDT) · pack/group (guides) |
| a condition | role · stage match · ramp (model) | WA "Trigger" + "If … Then …" + "Load" · TomTom distance/death · pfQuest quest state | (prose: "once you reach …") |
| an action | supertrack (code) · point/note/complete/set/clear/activate (advisory) | WA "On Show/On Hide": chat/sound/glow · DBM announce/timer/yell/icons · TomTom set/clear/send waypoint · pfQuest verbs Kill/Talk/Use | verbs kill/clear/engage; Zygor from/get/talk/use/click; letters A/C/T/K/R/N |
| sharing | share/export (model); package (advisory); OFF THE BOOKS for now (S11) | WA import/export string · TomTom send one waypoint · pfQuest none · DBM sync | **import/export string** (MDT/keystone) · share with party · short link |
| floor | floor (code, capture) | (none) | **sublevel / floor / dungeon level** (MDT/keystone) |
| a count | (no offer — S: the note is a recipe) | (none) | forces % · "x15 [mob]" · "3 packs" |

**Reads from the table (data, not decisions):**
- Where the field and we already agree: **route · step/beacon as the unit · note · skip · arrive/reach · floor · arrow/waypoint · import string**. These cost nothing to keep.
- Where only we have a word because only we have the thing: **stage as a ratchet · maxSeen · a place recorded in-run · a boss child · once/while**. Nobody else drives a dungeon by position, so nobody else needed them.
- Where our words collide with something the field means differently: **pull** (the field's driven unit is a KILL-SET; ours is a PLACE) — do not borrow it; **path** (a drawn line in the field; we have no drawn line, we have a recorded walk).

---

## 2. THE BEHAVIOURS WE HAVE BEEN TRYING TO EXPRESS — grouped (E1/E2 in families)

_This is the programmatic model's raw material: not names, the things an author says and a
reader receives. From expr_self E1 (48) and E2 (25), collapsed by behaviour._

**A. Where** — a place from a read; its reach (radius) and its band (up/down); which floor; a
name; move it (free placement, S1); the parent's own place as a label + scene manager (S2).
    status: place/floor/name IN CODE; reach on a CHILD in code; **reach on a CHILDLESS beacon —
    NO FIELD (gap G2)**; band written, never evaluated (asklist B1).

**B. Come here** — the arrow points at this place; when it lets go (close: at reach / early
"lead-in"); one lure per theatre by default; the pointer is a heading, not a chain (§10);
child-to-child = activate (hand the arrow to the named child) — advisory; code = `goTo` +
`supertrack` resolved to a position at export.
    status: supertrack IN CODE (per child); lure-by-default DESIGNED; close DESIGNED; the arrow
    itself proven (W6).

**C. Done when found** — a place accepts the reader within reach (+band) → the stage advances;
segment test for pass-through, point test for standing (arc); no hold; the childless beacon is
self-completing (lure + advance in one, S2 addendum).
    status: the RULE proven (W1 ten); no consumer; childless-beacon reach missing (G2).

**D. Order** — stage as ordinal (fractions allowed); ratchet + maxSeen; skip expected (S6);
recovery = an out-of-sequence boss beacon `set:stage(N)`; K / listen-ahead as a config;
sequence by distance (model) AND by drawn chain (advisory) — "both, programmatic" (S7).
    status: ratchet + `set` role IN CODE; maxSeen DESIGNED (model); chains DESIGNED; recovery
    beacon DESIGNED (model §984-993 escapement + S6).

**E. Repeat / duration** — `ifUnseen` (once) IN CODE; `while inside` (level, hysteresis) —
advisory only, no prior term (G15).

**F. Say** — a note the reader receives (≤ ~200 chars, S: choice option); "many satellites may
write, on reaching a node do as the selected child says" (S9); announce (model, no field, G3);
personal note / comment (code) for the author's own eyes.
    status: **reader-facing note — NO FIELD (G1)**; comment IN CODE.

**G. Boss** — sense the engage (event + names from the run), validate the kill (CLEU dest name),
then `set:stage` (recovery) or complete; the name PICKED from the run's engaged list (target §3).
    status: capture holds names + timestamps; no child kind, no authoring list (G10).

**H. Death** — death location pointer (later, S15): on death point at own position, on alive
re-write the lure; reader's option, off by default.

**I. Reader-side surfaces** — arrow · note · stage readout · off-route number (advisory) ·
select + arm (F-ii) · manual seek to correct the stage (G8) · test drive (S1/S4).
    status: all DESIGNED; nothing driver-side in code (E2: 17 of 25 designed only).

**J. Author-side surfaces** — walk (nodes and their triggers on a dataset), test driver (cycle
nodes near you and see what they do), opacity/rename from the scene manager (S2), tell-and-trust
exposure (S4), share/export hygienic but off (S11).

---

## 3. THE HOLES — intents everyone assumes and nobody built (from E4, the load-bearing ones)

    G1   the reader-facing NOTE           no field, no setter, no surface (per-child form removed
                                          routes.lua:802; shared form never built)
    G2   REACH on a CHILDLESS beacon      no beacon-level radius/band in code — yet the childless
                                          beacon is the ruled everyday unit (S2 addendum)
    G10  BOSS name from the run           capture holds names; no authoring list, no child kind
    G8   correcting the stage by hand     required (model), no surface (manual seek, ruled)
    G15  `while`                          no model section, no code
    G3   announce + consent               no field, no send path (v2 at earliest)
    G4   share/export                     no serialiser, no schema_version — off the books but
                                          "build so we can" (S11) means the FORMAT exists first

## 4. THE COLLISIONS — words that mean two things in our own record (from E3; the ones that bite)

**Principle first (Battlewrath, 2026-08-17): the verbage has TWO SIDES — what the PLAYER is doing,
and how WE get them there.** *Goto* is the reader moving toward; *lure* is the thing being moved
at — same concept, different vantage, both correct on their side. Likewise arrive / reach ·
skip / maxSeen · the arrow / the supertracker · come here / on-ramp. **Rule: name a concept
twice when it has two sides (reader-word · author-word); it is a COLLISION only when two words
fight on the SAME side.** Several E3 rows are two sides, not collisions (C2 on-ramp/lure, C3
goto/activate in part, C11 detector/position); the ones below still bite because they fight
on one side.

    start · update · complete   a detect ROLE and a `fireOn` value, same file (C13)
    close                       chain-end (code) vs arrow-release (advisory) (C16)
    arm                         a run (capture) · a zone/stage/CLEU (advisory) · select+arm (F-ii)
    4.1                         a beacon between 4 and 5 (model) vs a child (advisory) (C10)
    on-ramp / lure              same intent, different word AND different defaulting (C2)
    goTo+supertrack / activate  same intent, different mechanism (C3)
    detector                    the model's word; the advisory's "there are no detectors" (C11)
    theatre / scene / arm zone  one thing, three words; S2 resolves the THING (label + manager),
                                not the word

## 5. WHAT THE FIELD'S STEP GRAMMAR SAYS ABOUT OUR SHAPE (data + a labelled read)

The recurring unit across every guide (R3): **[go to a place, by landmark or coordinate] + [do a
verb on a counted target] + [optional skip/avoid clause] + [optional note]**, completed either
by hand (prose) or by an event (coordinate reach / zone change / quest event in step-drivers;
forces-% in MDT companions). Position is a landmark noun in prose and a typed coordinate in
step-drivers — never a recorded place. Order is list order.

Analyst's read, labelled: our beacon IS that unit with two substitutions — the place is a RECORDED
read (not a landmark or typed x/y), and completion is POSITION reach in-dungeon (which no
step-driver ever did). The verb-on-counted-target part is the author's NOTE (a recipe, S), which
is exactly where the field puts it too. So the field's grammar and ours are the same sentence;
ours just has a machine under two of the words.

---

_This file decides no name (S3). It is the basis the programmatic-model discussion resumes from._
