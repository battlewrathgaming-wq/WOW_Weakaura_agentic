# DATA MODEL — findings from shaping the driver's input

> ⚠⚠ **HISTORY (moved 2026-08-20).** Battlewrath: *"Move them. Their more examples of the
> same text to infer seperately. Source of truth and pointers."* ★ **Read for WHY, never for
> WHAT to build** — its conclusion — cost is not the limit, ISOLATION is unproven — is `driver_sense_acceptance.md`
> A11.6a, and the basis's BENCH FINDINGS section.
> ⚠ It is here because it is FINISHED, not because it was wrong: a finished audit restating a
> conclusion is a second place an agent will read as current, and can drift from the one that
> governs.


_Addons bench, 2026-08-18 (§372). A FINDINGS file: it records what was learned and what was
measured, and it directs nothing. Filed at Battlewrath's ask after a shaping conversation that
went through five iterations of the flat line and ended somewhere other than it started._

---

## 0 · THE HEADLINE, and it is not the one we started looking for

**Cost is not our limit.** We already load the route; the sensing pass is ~tens of rows at 1 Hz;
and WeakAuras dispatches thousands of combat-log lines a second through one frame and a lookup
table. Nothing in the arithmetic is close to a budget.

**★ What is NOT proven is ISOLATION.** Battlewrath, 2026-08-18:

> *"We've not proven to have a consumer of a route that doesn't also read through the whole
> many-route store."*

**Measured, and he is right.** Every reader of route data in `COA_DungeonRun` goes through
`Routes.Get(id)` → `Store.RouteTable()` → `d.routes` — **the whole table**, keyed by id. There
is no path in the addon that consumes ONE route without the store that holds all of them.

    promoter.lua:107 · :282 · :468      Routes.Get(id)
    routes.lua        ~14 call sites     Routes.Get(id)
    Store.RouteTable()                   returns d.routes — every route

⚠ So the flat form's justification was never performance. **It is that a driver installable
without the editor has never existed, and nothing has demonstrated the capability.** The driver
would be the first consumer to prove it — which makes it a capability test, not an optimisation.

---

## 1 · THE ITERATIONS — five shapes, and why each moved

_Recorded because the reasoning is the useful part; the last shape alone would read as arbitrary._

### i · "the driver reads the route"

The starting assumption, never stated because nobody had to state it. Struck by Battlewrath's
standing ruling, already in the source at `routes.lua:509`:

> the driver must be installable **WITHOUT the editor**, reading a flattened list that is
> *"a product of the auditor, not needing to know how it is all coded in construction"*

and restated the same day: *"as a flattened list. NOT as privilege of having a full corpus of
data."*
★ **What moved:** the input. And with it, WHICH driver gets built — fed the corpus it would only
run where the corpus is, and the consumer would need a second one.

### ii · a row, ordered as an author thinks

    id · mapID · world x,y,z · r · bandUp/bandDown · ordinal

★ **Battlewrath's objection, and it is a machine-level one:** *"it has to walk all the way to the
ordinal to know if it's relevant."* The field that decides whether to look at all sat last, and
the identity — which is only needed once you have HIT — sat first.
★ **What moved:** order by SELECTIVITY, not by how a human describes a target.

### iii · ordered by selectivity, gated per row

    ordinal · mapID · x,y,z · r · band · id

⚠ **Then the question that dissolved it:** does the driver read all lines at once, or raster?
**Rastering breaks the rule**, not just the budget — `walk.py:535` keeps ONE `prev` per sample
chain and tests every target against that same segment. Per-target scheduling gives each row a
different `prev`, so W1.4 (*a transit with exactly one in-region sample fires*) is lost for every
row not evaluated on that sample, and W7.1's byte-equality against the desk becomes unavailable.
★ **What moved:** one pass per sample, always. The gate is not a schedule.

### iv · the gate as a BUCKET, presented at ingest

If the list arrives grouped, relevance is the GROUP rather than a field, and no row is ever asked
"are you mine?". Battlewrath's own sketch:

    In a Stage:  CID:1  CID:2  CID:3  CID:  CID:

★ The two blank CIDs are the ordinalless rows — the always-live ones. Which is
`Routes.ListensNow`'s first line, `if child.ordinal == nil then return true end`, expressed as
structure instead of a predicate.
⚠ **And it needs fixed positions:** `CID:` with nothing after it IS the absent ordinal. That only
reads if every field holds its slot, whether or not it has a value.

### v · the gate as SORT ORDER

    RID
    no stage      ← always read
    stage
    step

*"ordered numerically, and when on a stage, it reads from stage to stage, returns to top of
current stage, always reads through no stage."*

★ **This is the shape that costs nothing at runtime.** The recovery rows are read on every pass
BECAUSE OF WHERE THEY SIT — no flag, no predicate, no call. "Always listen" stops being a rule
the driver has to remember.

⚠ **The caution, raised and accepted:** row order becomes a LOAD-BEARING CONTRACT living in the
exporter, not the driver. A tidier, a merge, or an export that stabilises keys changes behaviour
silently. So either the order is part of the format and asserted on ingest, or the driver may not
depend on it.

---

## 2 · THREE CONSUMERS, THREE DIFFERENT GUARANTEES

Battlewrath: *"It's the export when we pull from many tables… import back to the editor is
translating to many tables."*

    EXPORT    many tables → flat lines     writes it, and DECIDES the order
    DRIVER    flat lines, never rebuilt    reads it; MAY depend on the order
    IMPORT    flat lines → many tables     reads it; must NOT depend on the order

★ These are compatible, and only because they are different guarantees. **Import reconstructs
from `RID:BID:CID`** — the address is the key, so any order rebuilds the same tree. The driver's
gating leans on order. **Export owes the order to the driver and owes nothing to import**, and
that sentence has to be written down or the two readings of "the format" drift apart.

★★ It also yields two tests that do not overlap: **shuffle the lines, import, get the same
tables** (RI-4's mint contract — identity · place · properties) beside a driver test that depends
on the order it was given.

⚠ And "many tables" then exists ONLY in the editor. The driver has no import path — that would be
a second implementation of the same reconstruction, and the one that has to run in a dungeon.

---

## 3 · THE `Next` FIELD — one, and the bench got it wrong

The bench proposed splitting `Next` into a choice and an N slot. **`DRIVER_BASIS.md:181` already
ruled otherwise:** *"the PRECEDENCE bullet is DISSOLVED (**Next is one field** — nothing races)."*

★ `ratchet` is the MECHANISM — can't-regress — and it is why Step and Stage are ratcheting moves
at all. The N is part of the declaration, inline: `Set(4)`. The adaptor row says the same thing
from the author's side: *a dropdown with a FIELD beside it*.

⚠ **Why one field is load-bearing, not tidy:** two slots can hold a choice of `Step` beside a
stranded `4` — a state with two readings. One field cannot express it. Same argument as the row
being stored whole (RI-17).

★ And the driver's two progression modes fall out of the word rather than a flag: **ratchet+N is
general progression (relative, cannot regress); Set is absolute.** A3.2 already carries both —
*"advance +N beside it"* and *"set stage… absolute from the node's own stage"*.

---

## 4 · WHAT WEAKAURAS ACTUALLY DOES — measured, not recalled

Read from the INSTALLED fork (`WeakAuras/GenericTrigger.lua`), which is the fact authority here.

**One frame, not many processes.** `:1276` is the frame; a scanner frame and one per watched unit
beside it. Nothing per-aura.

**The gate is an INDEX, built once at load:**

    loaded_events[event][id][triggernum] = data          -- :1390

**and dispatch is a lookup, not a scan:**

    local event_list = loaded_events[event]
    if (not event_list) then return end                  -- :888

★ **An event nobody subscribed to costs one hash miss.** WA never walks its auras asking who
cares — the question was answered when the aura LOADED, and the answer is the shape of the table.

★★ **And the hottest event gets one more index level:** `event_list = event_list[arg2]` (:893) —
CLEU keyed on its SUBEVENT, because one level was not selective enough. That is "how early can we
present the gate" answered by the field's own most-tested code: **add a level at load, never a
test at runtime.**

⚠ **Scale, for proportion:** WA runs that structure against thousands of combat-log lines a
second. We are at 1 Hz over tens of rows. ★ So the sort-order shape is worth having because it
makes "always listen" free and legible — **not** because we need the cycles, and it should not be
defended on performance grounds it does not need.

---

## 5 · WHAT THIS LEAVES OPEN

    O1  THE REPRESENTATION. Named-key table, positional array, or serialised line? A8.6 says the
        flat form is the stored form and does not say which. ⚠ It decides whether field order
        costs anything at all (a hash lookup does not care) and whether "empty means absent"
        is expressible.
    O2  IS THE ORDER PART OF THE FORMAT? §1v's caution. Asserted on ingest, or not depended on.
    O3  ONE LINE PER ROW, OR PER NODE? A node has several WHAT I DO rows (A2.7: ALL must
        complete). Either lines repeat the address, or a line carries a repeating group — and
        only the first keeps a line fixed-width.
    O4  THE ISOLATION TEST ITSELF. What proves a consumer read one route and not the store?
        ★ Bench read: it is provable rather than assertable — a driver handed a flat list, with
        the routes table absent from its environment entirely, and a smoke that fails if it
        reaches for one.

---
_Nothing here is built and nothing here rules. §4's numbers are from the installed client;
§0's from the addon's own call sites._

---

## 6 · MEASURED — how the data actually loads, and why the split exists

_Added §373. Battlewrath: *"I know in the editor I can load a route to the map. But my suspicion
is every route is shared in the same space."* Correct, and the mechanism is blunter than it
looks._

### 6a · THERE IS NO "LOAD" IN THE I/O SENSE AT ALL

`## SavedVariables: COA_DungeonRunDB` (`.toc:6`) means the client deserialises the **entire file
into one global Lua table before the addon's own code runs**. `core.lua:234` waits on
`ADDON_LOADED`, and by then it is all resident. `Store.Load()` reads nothing from disk — it
checks a global that is already there.

★ So `Map.Load("route", id)` does not load a route. **It SELECTS which one the map draws.** The
data was in memory either way, and there is no partial-load option to choose instead: WoW gives
the addon no say.

### 6b · THE LIVE FILE, MEASURED — ⚠ AND IT PREDATES THIS ARC

**Battlewrath, on seeing this section: *"I've not deployed the addon in this arc of dev."***
The file is dated **2026-08-17 17:14**; the arc's work landed 08-18. So it was written by an
EARLIER BUILD, and the reader has to know which questions it can and cannot answer.

    ✓ it CAN answer     the SHAPE - routes are tiny, runs are heavy, and the ratio is not
                        close. That is a property of what the two tables HOLD, and no
                        version of this addon changes it.
    ✗ it CANNOT answer  anything about code from this arc. Nothing built since 08-17 has
                        ever run in the client - the frame, the adaptor, the row grammar,
                        G1's note plane. All of it is verified OFFLINE only.

⚠ **And that is the normal condition here, not a gap:** Battlewrath deploys at test time and the
bench never does. What matters is that a number is labelled with which side of that line it came
from — an undeployed arc measured against a pre-arc file would otherwise read as agreement.

    routes    0.002 MB      1 route   ("Test-15")
    runs      3.997 MB      8 runs
    notes     ~0
    TOTAL     4.000 MB

★★ **The routes are 0.05% of the file.** Twenty routes would not reach 40 KB. What is heavy is
the RUNS — the captured samples — at 4 MB for eight.

### 6c · SO ISOLATION IS 100% COUPLING AND 0% COST, AND IT COULD NOT BE OTHERWISE

⚠ A driver calling `Routes.Get(id)` is not paying to load anything. Everything is resident
whatever it does. **It is DEPENDING ON THE STORE EXISTING**, and that dependency is the entire
reason it could not be installed without the editor.

★ Which restates the flat form's benefit precisely, and the restatement matters because reasons
are the part that rot: **not "less data" — a driver whose environment does not contain
`COA_DungeonRunDB` at all.**

### 6d · ★★★ AND THAT IS WHY THEY ARE TWO ADDONS

Battlewrath, 2026-08-18, on seeing the numbers:

> *"it is this reasoning why Dungeon Routes and Dungeon Run are two separate addons. Routes will
> only ever be minimal data, settings and some user notes."*

    DUNGEON RUN      the producer. Carries the capture corpus - 4 MB for eight runs, and it
                     grows with every run recorded. The editor, the map, the promoter.
    DUNGEON ROUTES   the consumer. Routes, settings, and the reader's own notes. Kilobytes,
                     and it never grows with someone else's captures.

★ **The split is not a packaging preference; it is the measurement.** A consumer that shipped
inside Dungeon Run would carry 4 MB of somebody else's samples to read 2 KB of route — and would
have `COA_DungeonRunDB` in scope whether it wanted it or not.

★★ **So O4's isolation test is not a contrivance, it is the shipping reality.** Dungeon Routes
has its own SavedVariables; `COA_DungeonRunDB` genuinely does not exist in its world. A smoke
that removes the routes table from the driver's environment is reproducing the real condition,
not simulating a strict one.

### 6e · ⚠ `routeNotes` IS ABSENT, AND THE FILE CANNOT TELL US WHY

The live SV carries `routes · notes · ui · runs · schemaVersion · nextId` — no `routeNotes`.

★ Battlewrath's reason is the true one: *"we've never had a way to author them. So they don't
exist."* ⚠ But the FILE is not evidence for it — it predates G1 (§346) either way, so its silence
is over-determined. Two explanations fit it and the file cannot separate them. **Recorded because
the correction is the useful part:** a measurement that agrees with a belief for the wrong reason
is the shape that gets cited later as proof.

⚠ **What follows for export, and this part stands:** A8.4's schema hook has never seen a real file
carrying a `routeNotes` table, and RI-10's two-table separation has never met live data — only
fixtures. Not a fault; a gap in what has been OBSERVED, and export is where it stops being
theoretical.
