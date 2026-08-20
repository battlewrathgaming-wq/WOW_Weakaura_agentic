# Dungeon Run — UI SCOPE (not absolute; the overhaul's starting surface)

_Analyst, 2026-08-18, from four inputs: Battlewrath's short scope (§0), his draw.io model
(`audit/ui_drawio_model.md`), the self-audit of everything already said (`audit/ui_self.md`, 98
rules · 14 conflicts · panespec 10 CAN / 14 CANNOT), the WeakAuras grammar profile
(`audit/ui_wa_grammar.md`), and the field research (`audit/ui_research.md`). **This file frames the
decisions; it makes none.** Best working model until an insufficiency shows._

---

## 0. Battlewrath's scope, verbatim in substance

    WeakAuras-like in presentation · drop-downs and tabs wherever they fit · the interface
    represents the intended DATA FLOW · like options ISOLATED together (type with type)

## 1. The surfaces (his diagram, reconciled with what exists — ui_self U1)

    MAP SURFACE          the render space for run + route data; editing happens ON it
    COMMAND STRIP        map context · open chips · close map
    MAP CONTROL          pan · zoom · map options; knock-out-able
    UNIFIED INPUT PANE   one column, THREE groups = the pipeline top-down:
                           run options   load run · filters · play/replay (time)
                           promoter      pick a run node → beacon; readout
                           node editor   beacon : child : options — the model's three items
                                         SENSE · WHAT I DO (during | when off) · IF SEEN
                         two chrome strategies: FIXED (stacked) or TABS (narrow selector, one
                         page live); each group KNOCKS OUT to a floating widget; the column
                         collapses when all are out
    REMOTES              run controls + map-open · route TEST DRIVE (RI-3) · promote-node-lite
                         (right-click a run node)
    DUNGEON ROUTES       route controls / share chips / collapse-to-strip · route manager
                         (profile a run of that route session · delete routes · options)
    reader-side          route-note slot · personal-note slot (RI-10) — the consumer's, not
                         this pane's; listed so nobody looks for them here

## 2. Rules already stated that bind this scope (the load-bearing ones; all 98 in ui_self U2)

    the factual interface file is the authority; nothing reaches the client not declared in it
    tell and trust — no lock-out box mid-edit (S4, RI-6)
    position is the NODE's (map); never on the behaviour pane (RI-5)
    the behaviour pane is EXACTLY THREE items (RI-5)
    one code:user lookup; pass-through shows the code term (§3b, A5.1); no shorthand at the author
    a slash command you have to already know is not a surface; no typed commands in v1 (S)
    compactness ≠ presentation (model §1373); the map is the primary storytelling space (§1278)
    UI PLACEMENT arguments are the overhaul's, not the inbox's (RI-11)
    check_rects computes on the RIGHT canvas or it is worse than none (A9.6)

## 3. THE FORK — how panes get built from data (the decision underneath everything)

The WA profile says WA is NOT a UI framework: plain AceConfig option tables → AceConfigDialog, plus
three patterns (generator per tab · `__meta` groups flattened for reorderable sections · enum
values bound by string to code→label tables). The field says: only three projects build panes from
a spec (AceConfig, DetailsFramework, StdUi); visibility is always `hidden = bool|function`, polled
on refresh; per-object panes are regenerated subtrees; **nobody ships an offline layout checker —
our `panespec` + `check_rects` has no equivalent** (wowless `frames2rects` is the nearest cousin,
current-client only). And ui_self says: panespec CAN do zones/rows/typed cells/static subject
visibility/offline overlap and height; CANNOT do tabs, `order`, functional `hidden`, sliders,
width-as-unit, repeated rows, labels-on-fields — and **the pane it describes is not the pane that
ships** (`object.lua` builds by hand; no `Spec.Build` caller).

    A  ADOPT AceConfig + AceGUI     ship our own Ace3 (a proven 3.3.5 fork: ElvUI-WotLK's
                                    AceConfigDialog-79 or pre-Settings revision; AceGUI core
                                    reads clean; Limited BSD). Write ONE mapper: our schema
                                    (senses · actions · if-seen · reach) → `args`. Get tabs
                                    (`childGroups="tab"`), functional `hidden`, widths, dropdowns,
                                    spinbox-class slider, per-object regenerate — for free.
                                    ~~LOSE the offline geometry check~~ **CORRECTED (Battlewrath,
                                    same day): NOT LOST — we have Lua emulation. AceGUI is pure
                                    Lua over the frame API; branch Ace3 INTO the harness and its
                                    `PerformLayout` runs under lua51; `check_rects` reads the
                                    resulting rects exactly as it reads ours (it already reads a
                                    MEASURED root rect from stub frames; the WA harness runs far
                                    more of WeakAuras than AceGUI needs). Cost is STUB-SURFACE
                                    DEPTH (whatever AceGUI touches: `GetStringWidth`, templates,
                                    scripts) — and text metrics stay a hole in EVERY option.**
                                    Call this **A′ = adopt + emulate.**
    B  KEEP panespec, GROW it       add the subset of the 14 CANNOTs the model needs (tabs level ·
                                    functional hidden · order · range/slider kind · unit widths ·
                                    repeated rows · label-on-field) and MAKE object.lua BUILD FROM
                                    IT. Keep the offline checker (unique). Cost: we write and
                                    maintain a renderer; every new kind is ours.
    C  ADOPT THE GRAMMAR, KEEP THE  panespec's SCHEMA becomes AceConfig's vocabulary (`type · args ·
       RENDERER + CHECKER           order · hidden · disabled · width · values · childGroups`) —
                                    field-standard, WA-shaped, translatable — while the RENDERER
                                    stays ours (3.3.5-native, no dependency) and check_rects keeps
                                    the geometry half. The schema half of the checker comes FREE:
                                    AceConfigRegistry-3.0 is standalone Lua and validates an
                                    option table under lua51 offline. Costs as B, minus inventing
                                    a schema; plus one adapter from `args` to our layout.

    Analyst's read, labelled — REVISED same day: **A′ (adopt Ace3 + branch it into the
    emulation).** It gives §0's WA-like presentation literally, the field's grammar, tabs /
    hidden / spinbox for free, AND keeps offline geometry because the harness runs the layout.
    C remains the FALLBACK if the stub surface proves costlier than it looks (its one remaining
    advantage: no dependency to carry — real, small against a BSD library the field runs). B
    invents a schema the field already has. My first read (C) rested on a cost that the
    emulation removes; corrected on Battlewrath's challenge.

### 3b. A′ DEMONSTRATED (bench, `history/UI_findings_ace_XML.md`, §351) — no longer a prediction
    PerformLayout RAN under our lua51 on both Ace3 revisions (wotlk-r960 = the client's rev 33,
    fully attested; modern-r1403 reaches four retail-era names, one unattested). Templates are
    READABLE from the MPQ (patch-B; 1,209 virtual definitions) — read, never modelled — and the
    frame model now applies them (54 templated controls in object.lua were sizeless boxes
    before: A9.6's third site). This client's dropdown machinery is retail-shaped and lives in
    SharedXML. Text metrics: the boundary is MEASURABLE (perturb the string-width stub; the
    rects that move are the blind spot, by name).
    Analyst on the bench's open questions (positions, labelled): Q1 SHIP in Dungeon Run only,
    harness copy for the checker; Dungeon Routes ships none · Q2 r960 · Q3 whole libraries
    (AceGUI core + AceConfig Registry+Dialog), subset of WIDGET files · Q4 A9.6 reworded to what
    it guards (done) · Q5 the text-metrics sweep NOW, once, then per pane change.

## 4. What the three model items become, under any of A/B/C (so the choice is only HOW)

    node editor        one group per object; three sub-groups in DATA-FLOW order:
                         SENSE       select (location + behaviour whilst in R, from the sense
                                     registry — no state entries, RI-17) · number
                                     (reach) · range+tick (band up/down) — NO boss entry
                                     [rewritten 2026-08-18 — was: a boss-name select in SENSE]
                         WHAT I DO   DURING · WHEN OFF, each a STACK of rows; a row = condition
                                     (immediately | on boss ⟨name⟩ killed) + action (update note ·
                                     set supertracker · advance +N · set stage N · /say · open) +
                                     [interim wording — RI-17: one declaration `<sense>:<action>:<arg>`,
                                     no condition field]; the boss NAME picker lives on the
                                     ROW, shown only when the action word is `boss`; fields depend on the
                                     choice [⚠ SUPERSEDED (RI-15 settled, 2026-08-18) — was: two multiselect rows]
                         IF SEEN     toggle (once | every)
                       + note field labelled "Route instructions" (RI-10) under WHAT I DO
    scene manager      the parent's group: child roster as a REGENERATED per-object group (the
                       WA `__meta` idiom: title · order · up/down · delete), name + opacity per row
    tabs               fixed vs tabs is chrome over the same groups; TABS is §0's choice and the
                       WA idiom (one selector, one page live; collapse-when-empty is cheap there)
    knock-out          a CONTAINER behaviour (dock/undock), not a spec concern — Lua either way
    labels             every user-visible string through the adaptor; the pane speaks the
                       author's side (§3b); "personal note" / "route instructions"

## 5. What must be TRUE before any pane is re-laid (from ui_self U5, the ones that block)

    the spec IS the pane      object.lua built from the spec — or the checker checks a fiction
    one canvas                 A9.6 (240×330 vs 600) — the checker's box read from ONE place
    one control-form list      four statements about control forms (tabs · dropdowns-not-radio ·
                               ‹value› ranges · tick-to-change slider) reconciled into ONE list
    the readout box            hover box or selection box — say which (U5 #6); its row count
    the route remote           ✓ ANSWERED (RI-3 + D-E, 2026-08-18): the TEST DRIVE REMOTE inside
                               Dungeon Run (target §9 G3; A10.5) — was: "one word" owed
    the shipped "trip wire"    the pane still shows the banned word; the checker's regex sees
                               only SetText literals — widen or move the strings (U5 #8)

## 6. DECISIONS — Battlewrath's answers, 2026-08-18 (best working model, dated)

    D-A  THE FORK → **A′: adopt Ace3 AND emulate it in the harness.** His reason, verbatim in
         substance: "we've proven across a few projects that we struggle to build interfaces —
         too many decisions, and taste gets lost in the argumentation/resolution." Buy the
         field's answer; spend the taste on what the panes SAY, not how they are drawn.
    D-B  CHROME → **TABS.** "They buy us organisation — LANES — and let one surface do many jobs."
    D-C  KNOCK-OUT → **later.** Chrome, not data flow.
    D-D  "THE SPEC IS THE PANE" → **yes, the first acceptance row** — the spec as in THIS scoping;
         "we will learn what works / doesn't on the go" (best working model, not law).
    D-E  THE ROUTE REMOTE → clarified: the scope meant the TEST DRIVE's remote (mvp_scope's
         seventh surface, go/stop/report for route TESTING). Reconciliation offered: G3 IS the
         test drive's suite entry inside Dungeon Run (RI-3); Dungeon Routes' own remote (the
         reader's SELECT + ARM) is a separate thing in Dungeon Routes. **YES (Battlewrath): Dungeon
         Run has a TEST DRIVE REMOTE — "mainly so I stop being asked to do things by commands /
         dispatcher." A control you can see, not a slash line you must already know.**
    D-F  "GRADE" → **defined: SELF-ASSESSMENT.** Users on Dungeon Routes, having completed a run
         of a route, self-grade and have space to leave comments. Not the route being graded by
         us — the reader's own reading of their own run. If combat logging is ever read
         (Recount-style segment tables), this is where it would be saved. The never-grade bound
         (target §6) is untouched: nothing here scores THE ROUTE.

## 6b. THE APPROACH — both, not or (Battlewrath, 2026-08-18)

    "We can have both. Primary frame. Then panes as we need them. This is being approached like
    it's OR — i.e. lower risk."
    → the overhaul is a SEQUENCE, not a switch: stand up the PRIMARY FRAME first (the Ace
      container with its tab LANES), then bring panes into it ONE AT A TIME as each is needed;
      the hand-built panes keep working beside it until their turn. Nothing is torn down to
      start; each step is small enough to be wrong cheaply. "The spec is the pane" (D-D) is
      then true PER PANE as it lands, not all-at-once.

### 6c. FIRST TWO STEPS (Battlewrath, same day): "First the render and fold in the tab design.
Moving our hand-placed items into readable by Ace."
    1  RENDER THE PRIMARY FRAME with the TAB design — command strip · map surface · the unified
       input pane as a tabbed column (Ace TabGroup) with three LANES: run · promoter · node
       editor. Empty lanes are fine; the frame is the deliverable; the harness renders it before
       the client does (A′ demonstrated).
    2  FOLD THE HAND-PLACED ITEMS IN — `object.sense` · `object.ordinal` · `object.note` first
       (the three the checker cannot see today), ~~then the rest of object.lua~~ [A10.2a CORRECTED
       2026-08-18: the rest is REPLACED by A10.3, not folded] — each becoming an
       option-table entry Ace READS and check_rects MEASURES at its template's true size. The
       hand-placed count goes to zero pane by pane; each move is one row, one mutation.
    Acceptance rows A10.x follow this order: A10.1 the frame renders under the harness with
    three lanes and zero overlaps · A10.2 each folded control resolves through the adaptor and
    appears in the checker at template size · A10.2c: literal SetPoints in the folded pane's
    FILE = 0 (per-file zero, grep) — was cited as A10.3.

## 7. Deliberately NOT in this scope
    visual style (textures, colours, fonts) · the map's rendering internals · the personal-note
    pane (model §4b, later) · export/import doors (S11 off the books) · anything the vocabulary
    pass (S3) will name · the consumer's slots (Dungeon Routes owns them)

## 8. Acceptance shape for the overhaul (to be written as A10.x once D-A/D-D are said)
    the spec IS the pane (one builder, no hand-placed controls; grep = zero literal SetPoints on
    declared controls) · schema validated OFFLINE (AceConfigRegistry under lua51 if C; our own if
    B) · geometry validated OFFLINE (check_rects, right canvas, names what it cannot see) · every
    user string resolves through the adaptor (A5.3) · the three items appear in data-flow order ·
    conditional visibility exercised by the smoke (boss picker appears only on a ROW whose
    action word is `boss` — A10.3d, RI-17) ·
    per-object regenerate leaves no orphan widgets (a mutation: delete a child, count frames)

---
_Not absolute. The audits are the evidence; this is the frame; the words in §6 are his._
