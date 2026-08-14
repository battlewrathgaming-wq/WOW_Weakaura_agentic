# Addons_load — the addons agent's mental-load ledger

_What I'm carrying between sessions that no other file owns: open threads, banked refinements,
small debts, and walls-with-context. STATE.md says where the machine is; this says what's on my
mind. Pruned when items resolve — an empty section is a healthy section. Est. 2026-07-15._

## ▶ ACTIVE — `COA_DungeonRun` → **brief: `addons/planning/dungeonrun_poc.md` (87 sections)**

**STATUS: v0.24.2 — CAPTURE · DISPLAY · CURATION · PROMOTION · CALIBRATION · A DRIVER THAT WALKS ·
ZOOM WITH ITS CONTROLS · AND CHECKPOINTS** (2026-08-14). Eleven files, 271 fn, **0 persistent
OnUpdate**, smoke-green, **215 mutations bite on their own message**.

✅ **§81 — the stage is EDITABLE, with a MATCH count and a GAPS line.** §80 left post-mint editing
out; this closes it, and stage had to LEAVE the "facts it cannot edit" line in the same change. ★
**Match** shows how many OTHER beacons sit on that number as you type it — duplicates stay legal
(refusing would be grading) but never silent. ★ **Gaps** shows up to three free numbers INSIDE the
span, and is **blank when there are none**: a line that is usually empty gets read, one that always
says "none" gets ignored. ⚠⚠ **A recursion I nearly shipped:** `OnTextChanged` → `refresh` →
`SetText` → `OnTextChanged` is unbounded and would FREEZE the client rather than error. Fixed by
writing only when the value differs — and **no test could have caught it**, because the offline smoke
drives `refresh` directly and never goes through the client's event loop.

✅ **§80 — the STAGE FIELD at mint, closing a hole §79 left.** §56 said stage was *"inherited as a
default and EDITABLE"*; it was not, so **`4.1` could not exist** and §79's sub-division argument was
unreachable in the UI — ⚠ the same shape as §77's ticks, **a mechanism accepting a value nothing
could produce.** Now: **ghost text, not a pre-filled value** (an empty box means *use the next
number*, so the author who does not care never touches it), and the default is **the lowest free
round number** — `1,2,3,4,9` mints 5,6,7,8 then skips 9 for 10, and a delete frees its number.
Fractions are only ever typed. ⚠ Duplicates are ALLOWED and visible rather than refused. ⚠ Editing a
stage AFTER mint is still not built — a fix currently means delete and re-mint.

★ **The time-as-order question, answered from the code:** `.t` is read in four places, all in
`map.lua`, and none touch a beacon. Route order never came from time. **`Map.FloorAt` is the one
real case** — it takes the nearest EARLIER sample, so a transition between ticks reads as the old
floor. ★ And §63's PLACE whitelist names `t` as an explicit exclusion, so time never reached a beacon
at all: *"place carries, the event does not."*

✅ **§79 — §78's FIRST SLICE, and it is one expression:** `index = max(index, outcome)`, where
`outcome` is `self + 1` by default (**stored as nil**) or a number the author typed. A checkpoint is
not a kind of beacon — *"a check point is a cheap beacon"* — it is a beacon whose outcome you typed.
★ The **ratchet is IN the expression**, so nothing can walk the index backwards and checkpoints are
safe to scatter. ★ A literal number beat a beacon reference because **insertion sub-divides rather
than renumbering** (`4.1` is an ordinary stage), so nothing goes stale — §56's *"the sequence integer
rides free"* is literally true. ⚠ `self + 1` is ARITHMETIC, not "the next in the list": *"let the
author do the mental work."* The promoter now shows the **running order, sorted by value**, which is
the anti-warning — bad form is displayed, never validated.

⚠ **And it fixed a latent bug nothing had caught:** `DeleteBeacon` matches on `b.stage` and leaves a
GAP, but the driver did `route.beacons[stage]` — indexing the table by a stage LABEL, so it read the
wrong beacon after a single delete. No test had ever deleted a beacon and then armed the route.

⚠ **§77.2 — THE LESSON THAT COST A DEPLOY.** The zoom toggle shipped as a step-SIZE selector; he
meant zoom STAGES (*"take me to pre-defined stages"*). He pressed it, the map did not move, and he
reported it unwired — correctly. **Every layer of verification passed**, including a test that
pressed the real button and asserted its label changed. ★ **A test can only check the thing you
built; it cannot tell you that you built the wrong thing.** When a control's job is to change the
world, assert THE WORLD CHANGED — not that the control acknowledged the click.

★ **§74.1 — THE DRIVER IS PROVEN AND FREE.** First live walk: stages tracked, **7079 scans at
0.0061 ms each — 0.037% of a frame, 43 ms in total.** Cost is NOT a constraint on the driver's
design; the reason to test one stage at a time is SEQUENCE semantics, not performance — a correction
to an argument §73 and §74 both leant on.

★★ **THAT DISCUSSION HAPPENED — §75, and it is CAPTURED INTENT not law.** The beacon is a **surface
anchor with CHILDREN**, addressed relative to it, and the child vocabulary is **draw · place ·
print**. Four rulings carry the weight: **the geometry IS the condition** (no invisible trigger
volumes) · **entry claims focus** — sequence is a preference, not a gate · **exit is obsolescence,
not completion**, so a route cannot get stuck · and ★★★ **THE DRIVER INFORMS, IT NEVER GRADES** —
*"the beacons are not a performance grade"*, so no completion count, no *"you missed"*, no warning
when a beacon goes stale. I proposed the opposite and it was right to refuse. **Three items are still
open** at the end of §75 (what satisfies a stage on a hub · do children inherit z · does a crossed
line care about direction) — read them before building the children.

★★ **§78 COMPLETES THE MODEL — and REVERSES one §75 ruling.** The beacon is a **THEATRE**: you claim
a scene, then annotate inside it. The anchor is demoted to an **address with a label position** (drag
it clear so it stops covering the sample you want; nothing downstream may consume that position).
**Children take their full x/y/z from ANY sample on the loaded map** — ⚠ which reverses §75's *"they
inherit the anchor's plane; a second height is a second beacon"*, because two beacons means two
detectors and the author wanted one condition with two places. **The parent never moves children** —
every child's position IS a capture intent, so a group drag repairs one and destroys the rest. **Any
child may be a satisfier, first to fire wins**, so ★ **there is no priority field anywhere**:
precedence falls out of geometry. ★★ **AND THE INDEX IS ONE OPERATION, not two.** A beacon's satisfier fires → the theatre is torn
down → the index is promoted. The only thing an author changes is **what it promotes TO**: `current
+ 1` for most, a fixed `N` for a **checkpoint** — ⚠ **ratcheted** (*"if lesser than index 10, then
set to 10"*), so a loop that re-crosses one cannot drag progress backwards. A checkpoint's success is
**cheap**: arrival is the whole condition. ★ The *"NPC must be spoken to"* case, which I flagged as a
possible law break needing a gossip sensor, **dissolves into print + place + exit** — because the
driver INFORMS and never grades, there is nothing to sense. Still deferred: **line direction** (A:B
samples + a separate close mechanism).

⚠ **I added structure he then removed, twice in one thread** — new-else-original for children, then
an entry/exit split for the index. Both times the shape was identical: **turning one thing with a
parameter into two things with a relationship.** Sits with `dont-extend-past-the-evidence`.

⚠⚠ **AND A PROCESS FAULT WORTH MORE THAN THE FEATURE.** I re-raised §75's three questions as OPEN.
**They were not** — §75 closes with *"§75 HAS NO OPEN ITEMS"*. I read its `⚠ Open` heading and not
the ✅ struck-through answers beneath it. ★ **Search our own basis before calling something
unverified** — the standing rule already covered this, and it cost several turns. The turn still paid
(it produced a real reversal, with a reason), but that was luck, not method.

★ **§76/§77 came FIRST on purpose:** §75's vocabulary is half DRAWING, and on the coarse maps a
5-yard radius is under two pixels. Zoom is the prerequisite for the tools, not a polish item.

⚠ **The object pane's behaviour space is deliberately empty and says so.** Do not fill it from
§60's sketch — that sketch is captured intent, and turning it into a spec by implementation is the
thing he is avoiding.

★ **The arc since §63**, one line each: §65 **calibration** (fraction→world fitted from our own
captures, a MAP constant not a run constant, **0.000203 yd worst across 20 cross-run cases**) ·
§66 M7's terrain shift + **arm is the consent boundary** · §67 **construct from sample, never a
shipped table** · §68 the **drag** (keep original, add new) · §69 the **four gestures** · §71/§72 the
**object's own pane** · §73 the **height band** (his cross-walk case — **3.12 yd planar, 9.71
vertical** — is the fact the height check rests on, and it retired three mechanisms) · §74 the
**driver** · §75 the **behaviour model** (anchor + children) · §76 **zoom**, centre-anchored because
the cursor is also the pen · §77 its **controls widget** — and the two gestures are **ticks that
default OFF**, because the wheel belongs to the world camera and right-drag to camera-look · §77.2
the toggle rebuilt as **zoom STAGES** (100/125/150/200), destinations rather than increments.

**The brief is long because the DESIGN is most of the value.** Read it in three passes:
§1-§16 capture · §17-§27 + §38-§40 display · §29-§37 + §41-§56 the promotion model + curation · **§57 the LAW AUDIT + anti-statements · §58 DR-31 is boss TAGS, not bosses · **§59 the NEED: pull COMPOSITION · **§60 the ROUTE OBJECT + in-route surface and §61 the PROMOTER — both CAPTURED INTENT, NOT LAW.** ★ §61's largest implication lands on the MAP, not the promoter: promotion needs it to hold **two INDEPENDENT SLOTS** — a run and a route, each loadable and unloadable on its own (run only / route only / both / neither), where it currently holds exactly one. Promoted objects also sit **on top of the ladder**, above the pin. ✅ **§62 is that BUILT** — the map now holds a **table of LAYERS** (`key` · `timed` · `art` · `lists`), run and route loaded independently, a third slot costing one row. ★★ The load-bearing part is `timed`: the time envelope resets on the RUN slot **only**, or trimming a window and then loading a route silently throws the window away — which reads as the map forgetting rather than as a fault, and so would have lived a long time. The route slot resolves through **`NS.Routes`**, the real integration point the promoter will provide, so it ships **inert rather than broken**. ✅ **§63 is the PROMOTER's first slice** — `routes.lua` + `promoter.lua`, opened from a button at the **bottom of curation**. ★ His correction is the headline: *"the order is button presses. Nothing forced as in sequence. In reality the map doesn't care.. it just accepts load conditions."* The chain map→curation→promotion **SUGGESTS and never gates** — I had written it as a state machine. ★★ The one rule of the mint: **PLACE carries, EVENT does not** — a beacon is a statement about a SPOT, so `t`/`n`/`killedBy` would make it assert what it cannot know for the next person to stand there; written as a WHITELIST because the other direction fails silently. ★★ Personal notes turned out to be a **privacy property**, not just §60's second plane: a route is the exportable object, so a note inside one would publish your annotations unasked. ⚠ Two calls flagged as MINE not his: note-above-beacon in the ladder, and refusing to mint from an already-promoted object. ⚠ NOT built: the in-field editors (name·cue·note·stage·radii·icon), the Manage half, the second tick row, the macro hook. ⚠ **The icon word for *"stop, there's a jump, a thing"* is still HIS to pick** — one row when it lands. ✅ The tension it surfaced is **resolved**: the §25.2 **back-reference is DROPPED**. A beacon is expected to drift from its origin as methods improve, there is **nothing to authenticate**, and **a route is DATA not code — a plot table**, so a bad one is a quality problem rather than a trust one. §48's trust asymmetry keeps its observation and **loses my provenance remedy**. **§55 is the statement of purpose — *we build the instrument, not the expertise* — and it is explicitly HELD LIGHTLY, not a law.** **§48 is the curation pane's design and §50 is it BUILT.** Its load-bearing result: **all curation state is transient, with no exceptions**, so curation has nowhere to write and §43's law is structural rather than a discipline. **One thread banked there:** the satnav ledger's export/import laws (7, 7b, 8) were written *in the spirit of exporting* before we knew there were TWO export objects — they likely hold for routes and want re-reading for captures. **§29 is the
architecture in one line: CAPTURE IS THE ONLY SPAWN; promotion sorts points into lanes.**

**★ THE LAWS, IN FIVE FAMILIES** — §57 audits them and says why they are five and not eleven:
several were one law seen from different sides, and the flat list hid it well enough that the same
connection had to be found twice.

| | |
|---|---|
| **A · we hold WHAT HAPPENED** | not what the world is (§17 never learn dungeons), not what it meant (§54 type·source·state·when·where, **nothing more**; §14 never derive; DR-9 as captured). **§17 and §55 are the same sentence** — one refuses facts about the dungeon, the other refuses facts about how to play it |
| **B · capture is the only entrance; downstream INHERITS** | §29 the only spawn (**origin is gated, position is NOT** — §60) · DR-36 the player as sensor where the client is silent · DR-35 don't decide at capture what will matter · §25.2 z inherited never computed (a TEACHER under editing, not a gate) · §56 the sequence integers ride free. **Every violation looks like a feature and replaces a fact with a guess** |
| **C · the view is a LENS with nowhere to write** | §43 curation edits the view never the capture · §49 availability follows visibility (**filtering hides, never fades**) · §36 location sorts but never chooses · §48 all curation state transient. Structural, not a discipline |
| **D · the display grammar — HIS taste** | §46 colour = combat state, shape = kind · §38 enter over exit · the ladder `pin > dead > start > done > leg > combatleg`, which decides the CLICK too. ⚠ **Do not re-derive these** — they came from his eye on real draws |
| **E · build hygiene** | §34 separate frames · **zero persistent OnUpdate**, asserted in the smoke not just the census · every guard gets a `mutate.py` entry |

**⚠ READ §57's ANTI-STATEMENTS BEFORE ADDING TO THE BRIEF.** Every correction on 2026-08-13 had one
shape — something TRUE, extended a step past the evidence. It sounds like insight because that is the
shape insight has. **★ It is SCOPE, not suppression** — he wants the instinct, so offer the thought and LABEL ITS STATUS rather than withholding it. The tell: **when a framing is rejected the right next output is SHORTER, not
different.** Also `memory/dont-extend-past-the-evidence.md`.

**★ THE STANDING DESIGN RULING from those runs: CAPTURE IN A STABLE FORM, THE EDITOR CURATES.**
Drift reaches 133 yards, and the answer is **not** to derive a waypoint — *"deriving means
inventing meaning we don't know in the wild"*, and a derived point is a position **nobody ever
stood at**. The legs already show a story the eye intuits; a synthesised midpoint would replace
it with a number. Do not re-open this by re-reading the drift table.

**★ THE OPEN QUESTION IS NOW REACHABLE — and it wants an eye, not code.** §21 question 5: does
the 6-px re-pull cluster read as a cluster? `RFC_Run3_Messy-5` carries it at **5.2 yd = 7.0 px
against 16 px markers**, plus **three terminal stops** — one of which he could not see because
he fell into the lava and it landed on a floor the map would not reach. Load it from the
selector and look. **The precedence ladder (§38) changes what that cluster looks like**, so the
answer is only valid on v0.9.0 or later.

**NEXT AFTER THAT: §29's PROMOTION** — the first thing built on top of the inspector. §38 already
ranks the candidates: enters are waypoints, exits are evidence. §25.2 governs it: promotion
copies the base and **z is inherited, never computed**.

**FIVE PINNED EXEMPLARS** in `addons/landing/records/` — **`SFK_Run4_Clean_C-Legs_Pins-6` is now the one to test against** (7 floors, 27 pulls, 432 combat legs, 4 pins, 0 flickers, nothing unplaceable; §54) — they are **DESIGN INPUT, not archive**
(§18 says which proves what; do not test floors against Ragefire or marker density against SFK).
The `dungeonrun` landing source stays at **`testing`**, so routine runs land to gitignored
`staging/` and only exemplars are pinned. **`RFC_Run3_Messy-5` is the complete one** — it carries
`mapFile`, floor and the instance block the older three lack.

**☑ DEPLOY LEDGER (checked 2026-08-13).** He deploys at test time and batches, so a pending line
is EXPECTED to sit true and is **not a chore to clear**. `py addons/deploy.py status` is the truth;
this is a snapshot.

| Resident | Pending |
|---|---|
| **ALL NINE** | at parity, checked 2026-08-13 evening |

That deploy carried `COA_DungeonRun` v0.13.0 (the envelope handles, floor tracking, reset) and
`COA_DevDump` v2.3.1 (task_cleu's **metric fix**, for any future run). `st cleu` itself was already
deployed and **both CLEU runs were taken on it** — nothing new arrived for that.

**✅ MEASURED — THE COST OBJECTION IS RETIRED.** Two runs of the SFK control: allocation **178.8 / 180.3 / 178.8 kb/s** across none / count / masked (run 2, within 0.8%), and 194 / 204 / 190 in run 1. **The masked arm sits at or below the arm with NO listener** — the client and other addons churn ~180-200 kb/s regardless. Dungeon peak is **57-82 lines/s**, two orders below the raid figure the objection assumed. His TL;DR: *"our use is nothing compared to the general runtime and we can move freely. And we just keep a test on why we need it."* ⚠ **Cost stopped being the gate; PURPOSE still is** — §55's line does not move, and **consumption need is now ANSWERED — §59: pull COMPOSITION.** *"We don't touch the assessment. That's curation. We just provide the record... pen and paper."* Which lands on the DISPLAY as well as the logic: a surface that sorts pulls by size is assessment wearing UI. ⚠ Mask yield ~1% is CONDITION-SPECIFIC. ⚠ One known-wrong guard left in `task_cleu` on purpose — the 25% duration check voided a good run; fix before the next one.

**☑ THE INSTRUMENT: `/coadump st cleu`** (COA_DevDump v2.3.0). Three arms switched in-session — `none` unregistered / `count` / `masked` — per-second line counts and `collectgarbage("count")`, and **it voids its own comparison** when the arms were not the same errand. Measures ALLOCATION not time, because the profiled cost here is GC pressure and timing a near-empty handler measures the timer. Control: *"pull from the start of SFK to the boss. Kill them all. Repeat."* **Not run yet.** Core gained a **`mark`** verb for it — the in-session command path a session needs to be TOLD anything; `satnav` had wanted it all along.

**✅ THE CLEU QUESTION IS SETTLED — `addons/planning/cleu_on_this_fork.md`.** The "no CLEU" rule was a
COST CLAIM, so it was tested rather than argued. The fork declares a full retained-buffer API (`CombatLogGetNumEntries`, `AdvanceEntry`, `AddFilter`, `Object_IsA`...) and **all six functions exist** — but the buffer reads **50 · 5 · 0 · 0** across five probes in four conditions, including in combat and with logging on. **It is not a history**, so walking it would be lossy and silently so. `CombatLogAddFilter` is a **live shared singleton** (50 total vs 18 filtered = someone already set one) — same shape as `SetMapByID`. And **logging-gated routes cost the USER disk I/O**, which inverts the comparison. **Decision: push with a lean mask**, where lean has a target from ALC's own profiling — **the cost here is ALLOCATION, not call count.** ⚠ What would overturn it is a MEASUREMENT: nobody has counted lines/sec in a real pull here. The call-witness harness is built and parked for exactly that.

**☑ DOC PASS 2026-08-13** — README head/DR-table/files, `addons/README.md`, map.lua's header, the
shelf arrival note and this file all reconciled to v0.11.0. **Pruned from here:** a superseded
`COA_DungeonRun v0.2.0` block that still read *"capture only: no beacon, editor or display"* and a
pre-build paragraph still saying *"Gate: Build!, not authorised"* — both in the section a cold agent
reads. The one thing worth keeping out of them (**capture in a stable form, the editor curates**)
was moved into ACTIVE rather than pruned with them. `§45` also struck a now-inverted row in §12's
mutation table rather than deleting it, because that table is the v0.2.0 build's own record.

**⚠ BANKED: the census OVER-REPORTS persistence.** `frame_cost.md` counts `installs - clears`, and
it **cannot see `self:Hide()` as a teardown**. Live example: `COA_PetGrid/core.lua:86` — a `pinner`
that hides itself on its first frame is reported **PERSISTENT** when it runs once. Add it as a
**LEAD, not arithmetic** (a `Show()` elsewhere could revive it), worded like the `throttle?` column
already is. It matters because that page exists for exactly one number and is currently inflating it.

**⚠ BANKED: COA_PetGrid has never been MEASURED.** Battlewrath, 2026-08-13: *"part of this work was
to optimise. As I have concerns that we didn't add enough work into that addon."* What is known by
READING: its two "persistent" handlers are a self-hiding one-shot and a **0.5s-throttled** ticker, and
its CLEU listener is transient (registered in `start`, `UnregisterAllEvents` in `stop`) with
`pcall(onCleu, ...)` per event — more than the shape the 178.8 kb/s figure was measured on. **None of
that is a measurement.** The instrument is `task_callwitness`, built and parked with **four arms
unrun**, and it exists precisely because that page had to be produced for somebody else's addon.

**⚠ BANKED: a full RECONCILE, as a bounded run.** His framing. Today was the addon lane only. A
reconcile walks EVERY doc against the code it claims to describe — the other product lines, the
planning notes, `maps/`, and the memory shelf's durable half. The lesson from today's pass is what
makes it worth scheduling: **staleness collects in the SHIPPED sections**, where nobody looks
because the work is done.

**☑ PAID (2026-08-13): `addons/tools/mutate.py`** + a spec per addon under
`addons/tools/mutations/`. `py addons/tools/mutate.py dungeonrun` — 61 mutations, `--only <text>`
to run a subset, `--list` to see specs. **It baselines before mutating** (mutating on a red suite
makes every result meaningless), **restores and then VERIFIES the restore**, and re-runs the suite
at the end. That guard is not theoretical: the scratchpad version left a mutation on disk twice,
and both times it was caught only because the next command happened to be the smoke.
**Add a spec entry whenever you add a guard** — an untested guard is the thing this tool exists to
make visible.

## ◼ SHIPPED — `COA_Landmarks` v0.1.9, at rest

Capture, widget, map pins, note readout, beacon control and the edit form all confirmed in play;
inline tag completion, the `owner` control, `/lm all` orphan recovery and bulk transfer since
v0.1.3. Four live bugs closed; `landmark_design.md` §15 has the log. **Nothing to build** — §12's
A:B questions need play, not code.

**Runtime cost, settled 2026-08-12 (§15):** zero when idle, and **AC-29 now paces the beacon
poll on DISTANCE** — `clamp((dist − tier) / 30, 0.20, 2.00)` — replacing a two-tier movement
throttle that bought nothing, because AC-26's one-second debounce discarded 19 of every 20
samples and a late arrival is invisible. `lastPos` tracking is gone. **The lesson that
generalises: a guard's test has to be re-checked when the thing around it changes pace** —
AC-26's smoke step fell below the new poll floor and went vacuous, passing because the code
never looked. Both AC-24 and AC-26 are re-mutation-tested and still bite.

**One known issue, parked on his call:** the beacon holds a stale target when re-pinned onto an
already-live slot. Two candidate causes and the one-run test that separates them are in §15 —
do not guess at it in `beacon.lua`, which is where the silent-failure criteria live.

**NEXT ACTION for COA_LANDMARKS: nothing to build. v1 exists to be USED** — `landmark_design.md`
§12's A:B questions need play, not code. Do not add features to it unprompted; §11's
two-readings rule governs how any feedback gets read. *(This governs Landmarks only —
Dungeon_run's state is the ACTIVE block at the top.)*

**Read order on arrival:** this block → **`landmark_design.md`** (the brief IS the spec) →
`satnav_ledger.md` only when a criterion's *why* is in question — it is the fact basis, and the
brief cites it by `[Ln]`/`[Fn]`. `addons/maps/atlas/README.md` if you touch art. **Do not
duplicate the project files' detail here.**

**★ Two criteria fail SILENTLY in the field and must be asserted directly in the smoke:**
**AC-24** — arrival requires `GetTargetState() ~= Invalid` **and** the tier, because a
map-boundary refusal reports `sd = 0.00`, and zero satisfies every tier (walk into any instance
and a naive build fires *arrived*). **AC-26** — debounce before acting on `Invalid`, so a
loading screen is not judged as the real state. Everything else fails loudly.

**★ STALENESS:** every fact was read from patch-B as extracted 2026-08-12 or captured live that
day; this fork ships changes in days. The probe is re-runnable in three minutes
(`satnav_probe_runsheet.md`, read with `py addons/tools/read_satnav_probe.py`). Re-check
anything with a **number** in it first — F22's 727/1500 and F31/F37's 5.46–5.59 are the
client's own constants and can move.

**★ THE ARC TURNED on 2026-08-12 — read this before assuming the old framing.** It began as a
dungeon route pointer. It is now **landmark-first**:

- **Landmark / world-map scrapbook is the FIRST build, and it is NOT gated.** Farm spots,
  favoured vendors, self-authored places. It turned out to be **law 9's landmark half, already
  specified** — not a new design.
- **Routing is SECOND and still behind the §8 community gate** — and per law 9's refinement it
  is *a load-or-share operation with an order over the same architecture*, not a parallel
  build.
- **Why this order (his reason, and it is the one that matters):** *"once we have the landmark
  feature in, the questions that routing has will be part answered."* Routing's unknowns are
  mostly shared mechanics, and landmarks exercise them with **one player, outdoors, no group,
  no plan**. §9 carries the honest map of which §7 questions that answers and which it does
  not.

**★ TWO TRAPS FOR THE ARRIVING AGENT — both are corrections he had to make to me:**
1. **"Architecture" here means the way we develop and understand the system, made repeatable —
   NOT a committed code structure.** The implementation may differ; *"we don't have to codify
   them explicitly."* A shared core is a **candidate** shape, never a decision. Do not write
   an abstraction into the brief for a thing that does not exist.
2. **Scope the brief to the landmark feature ALONE.** Where a routing question is part-answered
   *for free* by a capture landmarks already need, take it; where it is not, leave it open
   rather than design for it.

**Settled and needing no rework:** the fact basis (F1–F20), the map↔world transform (exact),
laws 1–10, and **the whole icon set** — three context-chosen markers plus two user-chosen
stickers, every one verified against `AtlasInfo.lua` rather than against a browser listing.
**Carry forward:** law 9's wipe-boundary *condition* — it applies only **if** loaded and
author-owned markers share a store, which is an open implementation choice, and it belongs in
the brief as an acceptance criterion if that choice is made.

**★ BENCH TOOL, 2026-08-12 — the SELF-witness:** `addons/tools/emit_addon_census.py` →
`addons/maps/addons/`. *"We should hold ourself to the same standard"* (Battlewrath) — we built
`task_callwitness.lua` because Libellus had no self-reporting, then had none for our own code
either. Emits a bench roll-up plus **a folder per resident** (`<Addon>/frame_cost.md` +
`routes.md`) so inspecting one addon is never a trip through all of them. Resident list comes
from `deploy.py`'s MANIFEST — the one authority. **Read `addons/maps/addons/README.md` before
trusting a cell**: `throttle? yes` does not mean throttled *well* (it cannot see WHERE the
throttle sits), and the census **goes stale on EDIT, not on deploy** — it reads REPO source, so
the stale window is edit→deploy. `--check` is the safeguard (exit 0 CURRENT / 1 STALE, writes
nothing) and `menu.bat`'s Deploy check runs it.

**★ BENCH TOOL, 2026-08-13 — the WORLD MAP fact basis:** `addons/tools/emit_worldmap_census.py`
→ `addons/maps/worldmap/`. Decoded from the client's own DBCs in `patch-M.MPQ`
(`DungeonMap` · `WorldMapArea` · `Map` · `WorldMapContinent`), scoped as a **bench asset keyed by
mapID**, not a Dungeon_run extract — his framing: *"could have things for Maps, outside of our
use. Enrich the whole."*

**★ IT RETIRED A STANDING COST.** `satnav_ledger.md` carried *"calibration cost per dungeon: two
captured points with decent map separation"*. **The transform is a LOOKUP** — correct on the
first visit to a dungeon nobody has run, **verified zero-residual against 389 captured points**,
and the emitter re-runs that proof on every emit.

**Read `addons/maps/worldmap/README.md` before touching map maths.** Four traps in it, and all
four are silent: **M4** the fields named X bound world **Y** (and both axes run backwards),
**M6** 43 of 73 dungeons are multi-floor so `mapID` alone does not place a point, **M8**
`GetCurrentMapAreaID()` is off by one from the internal id, **M9** indoors the
continent/zone pair is `(-1, 0)` for **every** dungeon — a sentinel, so a `COA_Landmarks`-style
map match would draw one dungeon's pins on another's map.

**Bench tool landed 2026-08-11:** `addons/tools/emit_atlas_census.py` → `addons/maps/atlas/`
— the client's 4,503 named atlas entries classified by claim of use (1,359 claimed / 3,144
free). Read its README before picking any icon for anything; it carries three rules that cost
real work to learn. Practical: the in-game AtlasBrowser's **search is broken** (one
forward-slash texture path nils a match) — reload and scroll the unfiltered list.

## ◼ AT REST — the call-witness test series (parked 2026-08-08; COLD PICKUP)

**Status: instrument BUILT, DEPLOYED, smoke-green. Four capture arms never run.** Battlewrath
parked this to explore a different addon; this is not a paused session but a **cold pickup** —
assume no carried context, assume time has passed, and verify the staleness list below before
trusting anything in this block.

**Cold-pickup read order:** this block → `addons/planning/callwitness_design.md` (why it
exists, the 5 questions, the 13 acceptance criteria) → `addons/planning/callwitness_runsheet.md`
(how to execute) → `addons/planning/mancer_findings.md` (Findings 1-5 + **Thread state**, which
carries the tone and the beats of the Discord conversation).

**STALENESS CHECKS before acting — this arc's subject matter churns fast:**
1. **Their build may have moved.** The driver shipped 0.9.553 → 0.9.563 within days, and its
   version surfaces disagree (a git tag holding 0.9.434 code, an asset labelled 0.9.554 whose
   toc reads 0.9.563). Re-pull and re-diff against `refs_libellus/LibellusLeti-0.9.554-release/`
   before quoting any source claim. **Identify builds by CONTENT hash, never by label.**
   If `MinionHpHud.lua` has changed, Findings 2/4/5 need re-walking.
2. **The Discord thread has probably moved on.** Everything in "Thread state" is a snapshot;
   re-read the channel before relaying. He may have already fixed some of this.
3. **His addon config may differ** from the arms' requirements — the run sheet's per-arm
   settings are the authority, not whatever is currently set.
4. **Client-side leftovers:** `task_callwitness.lua` is deployed and inert until invoked
   (harmless). Verify `scriptProfile` — if it was left at 1 it is quietly taxing frames;
   `/console scriptProfile 0` + reload if so. It must be back at 1 before any arm.
5. Re-run `addons/tools/smoke/smoke_callwitness.lua` under lua51 — it asserts all 13 ACs and
   proves the instrument still satisfies its spec without reading a word of history.

**Resuming is optional and cheap to abandon.** Nothing downstream depends on it: MancerLedger
is unaffected, the Discord findings are already delivered, and the deliverables that exist
(`mancer_stutter_report.md`, `mancer_stutter_summary_paste.txt`, `mancer_stutter_data.csv`)
stand on their own. If the thread has resolved, close this block rather than running the arms
out of momentum.

- **What it is:** `COA_DevDump/task_callwitness.lua` — wraps Libellus Leti's functions in
  place (and OUR OWN, same footing, AC13) to produce per-function call counts and timings.
  Built because the driver has no self-reporting: *"a witness we do not have."*
- **Spec + 13 acceptance criteria (the build satisfied all, smoke-asserted):**
  `addons/planning/callwitness_design.md`.
- **Execution card:** `addons/planning/callwitness_runsheet.md` — pre-flight (FULL RESTART
  for the new file; `/console scriptProfile 1` + reload, else the cross-check columns are
  meaningless zeros), the four arms, per-arm summary-line checks.
- **The arms:** A worst (packed capital, plates on, names-only ticked, mute OFF) · B best
  (quiet area, same settings) · C mute ON — **the one that converts Finding 4 from source
  read to measurement** · D calibration (runs `task_perf` UNWRAPPED, not callwitness).
- **▶ FIRST TASK ON RESUMING (Battlewrath, 2026-08-08 — do this BEFORE the records land, and
  BEFORE writing anything new): INSPECT WHETHER WE ALREADY HAVE THE UTILITY.** The analysis
  this needs is defined-I/O over a known payload — it must be a GEAR, not hand-derivation in
  conversation (that is how this session computed the autocorrelation and trough alignment,
  ad-hoc, surviving only in a transcript). But check the shelf first: the record-reading
  tooling used on the MancerLedger/driver work, `addons/landing/pull.py`, the emitters in
  `addons/tools/` (`read_spell_dbc.py`, `reduce_census.py`, `emit_census.py`), and
  `Class_design/Necromancer/tests/parse_combatlog.py` — his read is that the log-inspection
  parser already exists in some form and should be EXTENDED, not duplicated. Only if nothing
  fits: build `read_callwitness.py` answering design §1's Q1-Q5 plus an AC health check
  (unwrap complete, truncation flag, observer cost, wrapper-vs-engine divergence) and an
  arm-diff mode. **Gate: `Build!` — not authorised yet.**
- **On the records landing:** analyse per `callwitness_design.md` §1 — Q1 which function,
  Q2 does the scan run with plates off, Q3 is the ~7.8s pulse in CALLS or COST (calls flat +
  cost pulsing ⇒ garbage collection), Q4 one-slow-call vs many-fast, Q5 population scaling.
- **Watch for:** observer cost printing `0ms` ⇒ `debugprofilestop` not advancing, distrust
  timing columns (call counts stay valid). `unwrap N/N` unequal ⇒ client left instrumented.
- **The Discord thread** is live and the author is engaged and receptive — he asked for the
  numbers, got them, and accepted the always-on-scan finding as "something I can look at."
  Shareables already delivered: `mancer_stutter_report.md` ·
  `mancer_stutter_summary_paste.txt` (Discord-sized) · `mancer_stutter_data.csv`.
  Findings 1-5 + relay ordering: `addons/planning/mancer_findings.md`.
- **Deferred, banked:** the witness-satellite split (separate addons, own SV files, one
  command via a shared registry) — build when two witness scopes need to run concurrently.

## Investigation (2026-08-01): the PvE/PvP Power login bug - client-side readout IMPOSSIBLE

Community bug (~30% damage loss on login for many specs; fix = a mode-switch/naked/die/quit
ritual). Traced the full client surface w/ Battlewrath:
- Server applies power as AURA MACHINERY: 'PvE Power (+0..+99)' ids 101600-101699, PvP
  101700-101799 (+993xxxx variants), 'PvE Mode' 9931032 / 'War Mode (PvP)' 84420 as mode
  auras. Mode aura VISIBLE in UnitAura; power auras FULLY SUPPRESSED - not in UnitAura, not
  in CLEU even on a forced mid-session equip re-apply (tested live, silent).
- The character sheet FABRICATES its display: PaperDollFrame_SetPvEPower shows
  UnitPvEPower = client gear-sum; tooltip %s derived from the same sum x local constants.
  Nothing queries applied state -> the desync is invisible BY CONSTRUCTION.
- Detection BOUNDARY: behavioral class only (output vs known-healthy baseline). Any
  tooling there = UNGATED and rests on an unverified premise (multiplier CLEU-visibility -
  one bugged-vs-fixed A/B settles it). Expanding the Mancer/Ledger line to player damage =
  a product-scope decision NOT yet worked (Battlewrath flagged the inventive creep of
  proposing it inside findings).
- DEV REPORT PACKAGE (sharp): fix the apply path; EXPOSE applied power (unhide aura or API)
  = the structural fix players can verify; + found in passing: UnitPvEPower caps PvE by
  PVP_POWER_CAP (UnitUtil.lua copy-paste bug).

## Client-surface finding (2026-08-01, CORRECTED same day - Battlewrath's catch):
## Bartender form paging works natively; the trap is TARGET PAGE NUMBERS

Custom CoA forms work END-TO-END in the paging stack: SpellShapeshiftForm.dbc carries the
OWN-BAR flag (0x1) on most CoA forms (Rotweaver/Vizier/Lich CoA/Cursed/Draconic/Mechsuit/
Elude/Formations...), GetShapeshiftForm()/GetBonusBarOffset() report correctly, entering a
form fires UPDATE_SHAPESHIFT_FORM + UPDATE_BONUS_ACTIONBAR, secure state drivers WAKE, and
[form:N]/[bonusbar:N] conditionals evaluate. **THE TRAP: the right-hand values in a paging
string are ACTION PAGES, valid 1-11 only (11 = the vehicle/possess page, pairing with
[bonusbar:5]). Page 12+ = a SILENT no-op that perfectly imitates driver deafness** - I
banked a false 'forms don't wake drivers' finding off it; the two stacked unknowns
(wake? target?) resolved when Battlewrath questioned the target number. Lesson instance of
[[pipeline-emits-class-knowledge-curates]] + one-variable-at-a-time.
His working pattern: forms share page 8 (populated per spec); probe kit for future form
oddities: /dump GetShapeshiftForm(),GetBonusBarOffset() · SecureCmdOptionParse(specifics
FIRST - first match wins) · the 5-event listener one-liner.
FINAL STRING (validated): `[bonusbar:5]11;[mod:shift]10;[stealth]7;[form:1/2/3/4]8;1` -
priority stack modal > modifier > stealth > OWN forms (whitelist) > home floor. Two late
lessons: (a) the trailing unconditional value IS the else-branch - without it, no-match
emits nothing and the bar goes stale; (b) EXTERNAL morphs set real form-state (Stratholme
fear -> Ghoul form id 7, DBC-flagged OWN-BAR) - bare [form] greedily captures them, the
1-4 whitelist + floor ignores them. Possession rides bonusbar:5 (same page as vehicles).

## Bench capability (2026-08-01): MPQ + DBC reading (client data manifests)

mpyq (already in the toolchain via extract_interface.py) reads ANY client MPQ + its DBC
files directly - proven by the Undead-Venomancer diagnosis: CharBaseInfo.dbc (the client's
LOCAL race x class manifest, single copy in patch-M) decoded in-place -> Venomancer(29,
'PROPHET') granted to races 4/8 only, Undead row MISSING -> create UI blocks client-side
(IsRaceClassValid) before the server allow can surface. Dev-side miss, relayed precisely.
Pattern: the client gates on SHIPPED manifests (DBC in the patch chain), not runtime checks
against the server - "is there a local manifest?" is now a mechanical yes-and-here-it-is.
Glue chain for create-gating: CharacterCreateUtil.IsRaceClassEnabledAndValid =
IsRaceClassValid(DBC) AND C_CharacterCreate.CanCreateClass (realm/account side).

## Bench capability (2026-07-31): the /combatlog disk witness

`/combatlog` toggles the client's own CLEU-to-disk stream -> `Logs\<datetime> WoWCombatLog.txt`
(addon-free, zero cost, ms timestamps, standard 3.3.5 CSV after a two-space split).
`Class_design/Necromancer/tests/parse_combatlog.py` parses it as-is (`parse_line` is the
reusable piece - proven by importing it against the bench's own questions). For any future
"does this fork emit X" question this is the CHEAPEST instrument on the bench: no capture
task, no deploy, no reload. First bench use: hunting the pet-UNIT_DIED answer (Battlewrath
deliberately exposing the capability - all prior testing was dummies).

## First scaling observation (2026-07-31, MancerLedger naked/geared A/B, Rates page)

Pet MISS% responds to owner gear - consistent across types with sample: Greater Skeletal
Warrior 10%->4% (-6pp), Decaying Colossus 9%->4% (-5pp), Lesser Zombie 0%->2% (noise-level).
Anchors: naked stam 102/int 108/shadowSP 68 vs geared 222/192/362. Evidence toward pet
hit-inheritance; Class_design's lane to pursue (lab pairs would pin WHICH stat). Lesser
Zombie cadence 33.3->64.9 EXPLAINED (Battlewrath, class knowledge): zombie per-unit rate
SCALES WITH PACK SIZE - the runs had 3 vs 18 summons; the cadence measured population, not
gear. Comparability caveat class discovered: POPULATION-DEPENDENT rates (zombie cadence
comparable only at matched counts) - a third axis beside fight-length and target-defense.
Data: his MancerLedger SV (naked/geaed profiles) + screenshots this session.

## Reference (2026-08-01): the training dummy testing surface

Capital dummy read live: entry 666938, LEVEL 63 ELITE (= the +3 boss defense table: ~8%
base melee miss, spell miss + crit suppression apply), creature type "Not specified"
(TYPELESS - no type-conditional talent fires; a flat surface, corrects the
'dummies are Mechanical' assumption). Consequence for ALL baseline work: boss-table
numbers; never mix baselines across targets (petlog's captives = a different table).
If other dummy tiers exist, read them the same way before use:
/dump UnitLevel/Classification/CreatureType/GUID("target").

## Observed gap (2026-08-01, Battlewrath - observation not judgment; UNGATED)

No protocol/checklist exists for EMISSION-ARTIFACT discipline - the five catches of the
PvE-power arc (sample bias, premise promotion, inventive creep, etc.) were all his live
review, none systematic. Candidate shape if ever worked: a small handoff checklist for
findings/records/contracts (claims walked or labeled testimony · premises named · zero
solutions in findings · scope changes gated, never footnoted). Home + ceremony-vs-review
cost = its own gated working. Related ADR case: adr-inventiveness memory, 2026-08-01.

## Open threads (each has a designed next step)

- **OPPORTUNITY (Battlewrath, 2026-07-30): the PET COMBAT PARSER — inspect Libellus-Leti FIRST.**
  Target addon: https://github.com/ltgenzombie/Libellus-Leti/releases (full big-pane combat
  parser; silo-ingest per the SignalFire pattern — describe-don't-anchor; STARRED read = their
  CLEU pet/guardian ATTRIBUTION logic (the solved hard problem) + their accumulator data model +
  a perf read against our render-economics knowledge). OURS DIFFERS: micro pane (row per living
  pet, budgeted-worker discipline from birth) + THE HISTORY EXPORTER — 'what have ALL your aboms
  ever looked like': longitudinal per-entry-id database, repo-side via the landing lane (records,
  offline aggregation - no SV bloat; no addon on this client can match it because none has a
  landing zone).
  THE METRIC INVENTORY (designed, 4 capture classes): (A) registry = the guardian-tracker
  ownership primitive (SPELL_SUMMON GUID + entry-id + lifetime); (B) CLEU streams, GUID-keyed,
  plate-independent = damage done per-ability w/ crit flags, miss table, damage taken, healing
  received, casts, time-in-combat -> DPS/crit%/shares; (C) ★ PLATE-WINDOW STAT SNAPSHOTS -
  UnitAttackPower/UnitDamage/UnitAttackSpeed WORK on plate-bound pets: snapshot on
  NAME_PLATE_UNIT_ADDED for registered GUIDs PAIRED WITH OWNER STATS same-instant -> (owner
  stamina, pet AP) correlation rows = THE PET-SCALING LAB (feeds Class_design's Life-Force-slope
  question; scaling derived from data, not known); (D) boundary class - HP plate-window only,
  last-known + staleness off-plate. BOUNDARY (Battlewrath, 2026-07-30): the parser does NOT
  manage nameplate CVars (Libellus does; we explicitly do not adopt it - method 3 cross-check
  closed as REJECTED for us). Plate visibility belongs to the client + the user's nameplate
  addon (TurboPlates is now his baseline - feature-rich; State Plates coexists on the same
  driver). Plate-window snapshots are OPPORTUNISTIC: read plates as they come, never engineer
  the gate. 'Let lanes that work well carry load.' 
  DISPLAY SPEC (Battlewrath, 2026-07-30): Recount-like in-game micro grid where THE ROWS ARE
  PETS, each anchored on the ACTIVE GUID (individuals, not Libellus-style type buckets; row born
  at SPELL_SUMMON, closed at UNIT_DIED -> closed rows = the history exporter's archive feed).
  ROW SORT = a DYNAMIC WEIGHT function (Battlewrath: keep the row weight pluggable so different
  weight types feed in later - v1 weight = LIFE FORCE COST; future providers: souls economy,
  damage share, taste-defined). V1 semantics: investment order - expensive minions top, stable,
  no dancing rows;
  generalizes as summon-resource cost, but SCOPE (Battlewrath): V1 = NECROMANCER ONLY — the LF
  row-weight is Necro-specific; Reaper guardians = a later generalization with its own economy
  anchor; LF table from OUR basis, not Libellus's).
  COLUMNS: [Name (numbered twins)][HP bar (plate-window, dims stale)][Dmg][crit% (sample floor
  ~20 else '-')][miss% (the live hit-cap evidence)][Age (doubles as temp-minion TTL)][Taken].
  DPS = exporter-side analysis, not glance.
  BUILD PATH (house two-step): capture BEFORE display - a petlog session task on the v2 spine
  proves the metric set via landed envelopes + offline parse; the grid addon then displays a
  PROVEN column set (satellite model if it joins the State Plates family).
  ★ MANCER FINDINGS BANK -> addons/planning/mancer_findings.md (Battlewrath, 2026-07-31:
  'bank all the findings and the suggested fixes so we have them loaded'). Three findings
  HELD w/ evidence + fix shapes: (1) CVar three-lane corruption class [design]; (2) guardian
  suppression polling race [mechanical, the icebreaker; fix = OnShow hook]; (3) the hitching
  ATTRIBUTED [profiler-proven: Mancer 24ms/s steady + 48-108ms spikes, 8-for-8 trough
  alignment; MancerLedger 0.0ms = his 1.5s hunch acquitted]. ACTIVE HEADING: prove the
  LEDGER'S UTILITY first through ordinary play (profiles accumulating, a real regear compare)
  - engage carrying working software that embodies the principles (opt-in - the consumer/game
  source drives updates - dedupe). We advocate nothing we don't ship.
  SEQUENCE AGREED (2026-07-31): (1) Battlewrath captures the A/B - profile 'naked' 5min dummy
  (2-3 pulls, combat drops between) -> gear up -> profile 'geared' same fight same army ->
  compare = the show-piece + the scaling lab's first controlled observation (does pet miss%
  respond to owner gear?). (2) THEN I build the WINDOW against his real SV data (design
  settled: profiles list w/ name-box+New/Use/Delete, stats table, compare view w/ per-type
  ROW TRIPLETS A / signed-delta-middle / B, capture lines as frame; rates delta in
  percentage POINTS, dmg deltas keep the raw label; native Interface Options page; slash
  demoted to alias). Build gated on his data landing.
  ★★ DIRECTION PIVOT UNDER DISCUSSION (Battlewrath, 2026-07-31, leaning, not yet Build!-gated):
  COMPLETE REBUILD around Mancer (LtGenZombie's addon, the evolved Libellus) as the PRIMARY
  DRIVER, us as CONSUMER. Verified mechanism: fights auto-commit on PLAYER_REGEN_ENABLED into
  MancerDB.minionDps.fights, a 10-fight ring with dedup fingerprints (startedAt:endedAt:dmg) =
  a ready-made fold cursor; lazy lossless harvest. Architecture becomes: (1) Mancer = capture +
  per-fight review (theirs); (2) CONSUMER plugin (ours) = lifetime normals + STAT-EPOCH BUCKETS
  (buckets emerge from stat-stability periods, ±tolerance on stam/int/SP anchor, fold-time
  paper-doll read; 'how do pets look anchored stam vs int' = inspectable surface).
  ★ OFFER SPLIT (Battlewrath, 2026-07-31): the LONG-TERM AVERAGING is THE offer - it lands on
  LtGenZombie's own stated boundary ('just a per fight thing, not a life time') = easy sell,
  no treading. The compact COMBAT READOUT is NOT offered: TTL/HP is already solved (their
  MinionHpHud + WeakAuras) - offering it treads finished work, an offensive sell they'd be
  precious about. v0.2's grid stays PERSONAL tooling only. Our capture lane retires after a
  two-witness window (run both, diff counters). Consumer fails LOUD on 0.9.x shape drift.
  ★ PASS 1 LANDED + VERDICTS IN (2026-07-31, record 20260731_104452): checklist facts settled -
  see pet_parser_scope.md for the full verdict block. Headlines: canonical CLEU API is FURNITURE
  (all 4000 rows varargs; classic 3.3.5 layout verified positionally); minions are TYPE_PET not
  GUARDIAN (0x1111); lab pairs real; DODGE/MISS + crit flags confirmed at era positions;
  witness = per-TYPE presence buffs (no count buff exists); ★ UNIT_DIED NEVER FIRED for any of
  71 pets (overwrite despawn is CLEU-silent) -> row-collapse must composite activity-TTL + plate
  presence + type-buff witness. Two summon lanes: Raise (persistent army) vs Animate (zombie
  swarm, 36 in 148s, mostly never plate-bound). REMAINING BEFORE THE GRID: (a) his call on
  SWARM ROWS (36 zombie GUIDs would flood a micro grid; candidate = one collapsed family row);
  (b) LF-cost table offline; (c) the UI chassis stub.


- **OPPORTUNITY (Battlewrath, 2026-07-20, pick up as a FRESH run): the Necro/Reaper custom UI.**
  His mains, they feel the same - one UI serves both. TASTE: gothic ironwork; little gothic-styled
  headers; RE-USE the Necromancer class widget elements (the client's own art). THE BASIS EXISTS
  (see 'interfaces basis' - patch-B code extraction + census + live-proven panel patterns + render
  economics). FIRST BOUNDED STEP (designed, not started): the ASSET SURVEY -
  (1) extract patch-A.MPQ art trees via extract_interface.py --all-types (CoAResource 33 files =
  the class-resource widget art, HUD, SpellShadow, TALENTFRAME, borders/flourishes; gitignored
  study copy like patch-B); (2) locate the CoAResource/class-widget CODE in patch-B FrameXML and
  map which art each class widget uses (the Necro elements named file-by-file); (3) emit the
  reusable-elements SHELF (browsable inventory: frames/borders/headers/fills/glows, keyed by what
  they are + where the client uses them; BLP eyeballing in-game or via converter). Then design
  over a real shelf: taste picks, facts assemble. Related standing work: the pressure-queue demo,
  guardian scaffold, class-systems-as-skill-lines - all Necro/Reaper-centered display candidates.


- **🐞 BUG HUNT ITEM (2026-07-17, live error, recorded per Battlewrath):** the NATIVE tank-border
  branch we lit up has a LATENT FORK BUG — `CompactUnitFrame.lua:816` (inside UpdateHealthBorder,
  the branch that only runs when BOTH tank border colors are armed + grouped) throws
  `Usage: UnitDetailedThreatSituation("unit"[,"mob"])` with locals ("player","nameplate11").
  We are the FIRST users of this dormant path — Ascension never play-tested it. Hypotheses:
  (a) stale/mid-recycle nameplate token rejected by the C export, (b) the backported C fn doesn't
  accept nameplate units. NEXT SESSION: check whether it's transient (rare error) or systematic
  (every grouped pull); if systematic → keep the Aggro borders branch DISARMED (arm only ONE color
  slot so line 815's AND-gate stays false) and route borders through the parked hand-rolled glow
  instead; the highlight-hide steering is unaffected (different function).

- **🐞 OPEN BUG (2026-07-17, post-v3.7.0 live): ENEMY plates being suppressed.** Suppression is
  Friendly-module machinery (ns.SetSuppressed, friendly PLAYERS only) — an enemy plate showing it
  means either (a) pooled-plate reuse: a previously-suppressed friendly plate handed to an enemy
  without restore (the SANITATION FIX lane — check whether v3.7.0's gates broke a restore path),
  (b) the dual-announce alias (target token) confusing classification, or (c) the v3.7.0 python
  block-replacement in FriendlyPlates.lua having clipped a non-panel line (diff v3.6.1→v3.7.0
  FriendlyPlates carefully).
  **PRIME SUSPECT (Battlewrath's live evidence: recycle-correlated + one enemy showing the NATIVE
  friendly-player BLUE 0.667/0.667/1.0):** the delta-guard CACHE DESYNC — our direct
  SetStatusBarColor paints never update the native cache fields (healthBar.r/g/b,
  UpdateHealthColor:576), so on pool recycle the guard believes its color is already painted and
  SKIPS the repaint, stranding the previous occupant's visuals on the new unit. FIX SHAPE: stop
  direct-painting entirely in SetHealthBarColor/ClearHealthBarColor — the override + RefreshPlateColor
  paints THROUGH native (cache stays honest); keep direct only for no-UnitFrame fallback and sync
  healthBar.r/g/b there. Suppression symptom likely same family (alpha state on recycled frame). Diagnostics on board: /coasp log on + filter suppress ·
  /coagp status (suppressed count) · /coagp diag (restore log). NEXT SESSION: read the v3.7.0
  FriendlyPlates diff BEFORE theorizing.

- **★ THE NEXT TWO SLICES (Battlewrath, 2026-07-17, post-v3.7.0 live drive — "more stable"):**
  Guardian and friendly-player are still COUPLED in the Friendly module; decouple into:
  1. **Guardian slice** — ownership-resolved: CLEU SPELL_SUMMON registry (sourceGUID=player) →
     match summon GUIDs to plate GUIDs → show /OUR/ pets only ("always the intent"). This is
     `corpus/patterns/guardian-health-tracker.md`'s registry primitive coming home to the addon
     side. Satellite: COA_StatePlates_Guardian.
  2. **Friendly-NPC lane** — satellite COA_StatePlates_NPC: show health bars · bar/name color
     edits · show-bar-when-carrying-Ascension-plate-TAGS (quest giver or not — the native driver's
     own questIcon machinery = the per-plate tag read; CompactUnitFrame setup carries frame.questIcon)
     → "health bar filters attention."
  Model: same two-file satellites on the inert core; Friendly module sheds both concerns.

- **Guardian-tracker POC LIVE-PROVEN + shipped to Discord (2026-07-15 evening)** — the custom TSU
  scaffold (GUID registry from `CLEU:SPELL_SUMMON` sourceGUID=player → resolve to plate tokens →
  static-progress states, clones): four 527-hp Greater Skeletal Warrior bars live, import string
  handed to Snackz. Battlewrath hand-built from the design card; source anchors GenericTrigger.lua
  :1807 (CLEU: filter) / :1331 (nameplate group expand) / BuffTrigger2.lua:3606 (3.3.5 CLEU layout).
  **STATUS: HANDED OFF — closed on our side.** Battlewrath's call (2026-07-15): this is Snackz's
  project; we gave them the key, we don't take it over. The "more abstraction" layer (login
  backfill, off-plate policy) is THEIRS to build — do not re-open it as bench work unless asked.
  What stays OURS: DONE — captured (`export_20260715_202335_01`) + catalogued
  (`corpus/patterns/guardian-health-tracker.md`: code verbatim, repeatable steps, source anchors,
  the plate-population boundary, limits, generalization — the registry = the reusable OWNERSHIP
  primitive for every summoning class). Evidence pair: records 20260715_195725/195846.

- **Clean-profile census re-run** — the runtime record was captured with user addons loaded, so
  `runtime/globals.json`'s 1526 "unattributed" functions = engine-custom ∪ user-addon mixture.
  One re-run with addons disabled at character select (same `/coadump r census`) splits it; the
  reducer already handles a second record (newest wins, runId-anchored). Cheap, high-value.
- **`C_CoA` / `C_ChallengeMode` / `C_RealmMerge`** — attested in shipped code, absent from the
  logged-in runtime. Hypothesis: glue-context (character select / login) or realm-gated. Probe:
  run census (or a tiny probe) while at the glue screen is NOT possible (addon code doesn't run
  there) → next best: grep their call sites in the extraction for context, or accept as
  glue-side. Not blocking anything.
- **The events census has no runtime witness** — events aren't `_G` entries; the declared pass
  (registered + compared + custom-prefix strings) is the only current source. A future
  `st`-mode event-sniffer task (RegisterAllEvents collector on the v2 spine) would add the
  fired-in-practice witness. Design exists in the collector library; build when a consumer asks.
- **Content-JSON reconciliation** (`Data\Content\CharacterAdvancementData.json` +
  `SpellRankData.json` vs `coa_spells.json`) — a candidate third witness for the ability
  inventory + the dev's own rank-family table. DISCUSS-FIRST (grain questions: Realms bitmask
  semantics, CA-entry ≠ castable-ability). Flagged in STATE 2026-07-15.

## For the aura bench (relay when their custom lane develops)

- **Custom-code performance discipline** (Battlewrath, 2026-07-15, from the guardian-tracker
  profiling: naive ~14× vs targeted in plate-dense areas): TSU handlers should dispatch off the
  event's own args (unit events name their unit), set `changed` only on real deltas, early-exit
  on empty state, and full-rescan only on STATUS. The as-captured pattern snippet = demonstrator,
  not adoptable form. A palette/ingredients note when custom.md grows.
  Rider (Battlewrath, Discord close): the gap policy for plate-bound trackers = **TTL +
  update-on-refind** (state survives a plate drop with a decay clock, refreshes when the GUID
  resolves again) — steadier UI than hide-on-gap, cheaper than a CLEU estimator.

## Small debts (cheap, non-blocking)

- **task_perf instrument notes (from the 4-arm SignalFire run, 2026-07-19/20):** mem column reads
  0 (GetAddOnMemoryUsage name resolves for CPU but not mem - investigate); the envelope should
  STAMP the watched addon's own option states (arms must self-describe - arm D's parser state had
  to be asked); watch MULTIPLE addons (st perf SignalFire,Chatter) so interaction arms show who
  pays. Arm D pending: Battlewrath to confirm parser was off (decides the Chatter-doubles-residual
  read). The furniture probe (live filter roster / OnUpdate / AddMessage audit) is banked at
  refs_signalfire/inspection/furniture_probe.lua - console paste, not yet run.


- **The tooltip merge gear** (post-capture, 2026-07-17): fold the rendered lines from
  `20260717_042514_616__tooltip.json` into the inventory text for the 119 hole ids
  (`maps/tooltip_holes.json` = the join). Small offline tool; the render is the arbiter,
  accept-empty on the game's verdict. Coordinate the landing spot with the aura bench
  (inventory out/ is their data).

- ~~`frames` task wants a field list~~ — BUILT + deployed v2.1.0 (2026-07-15): `frames
  [fields]` reads the walker's field list off every hit (`displayedUnit` added to defaults);
  anonymous hits keep a `table:` addr. Smoke-green; LIVE CONFIRM = the guardian-plate
  mouseover re-run (unit token expected in the record).

- ~~GuardianPlates client copy one deploy behind~~ — RESOLVED 2026-07-15: Battlewrath deployed
  to parity; check-mode confirms both residents zero-delta.
- **5 files failed extraction from patch-B** (named in `Outputs/client_interface/patch-B/
  manifest.json`: GlueXML RaceSelect/SoundOptionsFrame + SharedXML AnimationTemplates —
  read_file returned None, likely a compression variant). Glue screens, census-marginal.
  Revisit only if a question lands exactly there.
- **8 tiny MPQ archives are unlistable** (no internal listfile: patch-4/5/C/CZZ/P/W/WB/WC).
  Almost certainly art overrides. Ladik's MPQ Editor on Battlewrath's machine is the named
  fallback if one ever matters.
- **The census smoke harness lives in the session scratchpad** (smoke_devdump.lua /
  smoke_census.lua) — regenerable but not in the repo. If regression-testing the spine becomes
  routine, promote them to `addons/tools/tests/`.

## Standing cautions (so they don't get re-learned)

- **Two agent sessions share ONE trunk** (addons + aura benches, same repo, same main). Diagnosed
  2026-07-15 after a scare: the picker session's close replayed its chain on top of mine mid-evening —
  benign (nothing lost; rev-list proved 0 missing), but the interleave was luck. Discipline: `git log
  --oneline -3` BEFORE each commit (see whose tip you're on), and diagnose-before-repair on any odd
  push range — the trunk moving under you looks exactly like history loss until you count.
  Calibration (Battlewrath): parallel sessions are the EXCEPTION, not his practice (one focus,
  chase it out, settle) — this is a rare-condition check, not a per-commit ritual.
  MECHANISM (2026-07-15): **`operations/HELM.md`** — the trunk LOCK. Read before first commit;
  another bench's name = locked out; RELEASE at close-off. Supersedes tip-glancing as the guard.

- **One envelope at a time is load-bearing:** the census task's Begin→(cycle)→Commit spans
  ~seconds; another `r`/`st` during the cycle would clobber the open envelope. The dispatcher
  guards sessions but NOT an in-flight cycler. Acceptable at current scale; a `D.busy` flag is
  the fix if it ever bites.
- **Lua errors do not reach disk** (`Logs\LUA.txt` = load milestones only; live-tested).
  In-game error dialogs must be reported by hand. An error-catcher hook (seterrorhandler →
  mailbox) is a possible future task — weigh against the anti-cheat restart cost.
- **`.gitignore` patterns want anchors** — the unanchored `runtime/` rule silently swallowed
  `addons/maps/census/runtime/` (fixed `b66d1da`). When adding ignore rules, anchor to root
  (`/x/`) unless multi-level matching is the actual intent.
- **★★ SEARCH OUR OWN BASIS BEFORE CALLING SOMETHING UNVERIFIED.** 2026-08-14, twice in one
  session: I flagged the terrain-map decrement as an open unknown when `maps/worldmap` **M7**
  had recorded it (we had written the fact and never consumed it), and flagged "can we SET a
  super-track target on this fork" as the first thing to test when `COA_Landmarks/beacon.lua`
  has done it since **AC-17** — including the trap that the direct `C_SuperTrack` call is
  silently overwritten and only the `SuperTrackerUtil` wrapper survives. **Both times the
  answer was ours already, carried an ID, and cost nothing to find.** The order is: grep the
  addons, grep `maps/`, grep the planning docs — THEN call it unknown.

- **★ NEVER hand-mutate a source file and restore it with `git checkout`.** 2026-08-14: I reproduced one
  mutation by editing `map.lua` directly, then `git checkout`-ed it — which reverted it to HEAD and took
  a session's worth of UNCOMMITTED layer work with it. Rebuilt in full (the smoke and the mutation spec
  had survived, so it was re-verifiable), but the cost was real. `mutate.py` restores files ITSELF and
  verifies the restore; to reproduce one mutation by hand, **copy to the scratchpad and restore from the
  copy**. The general law: a destructive git command is not a way to undo an edit you just made.

- **★ A TEXTURE PATH WITH ONE BACKSLASH IS A BROKEN PATH, AND LUA SAYS NOTHING.** 2026-08-14:
  `"Interface\DialogFrame\X"` is not a syntax error on 5.1 — the lexer drops the backslash and keeps
  the letter, so the string becomes `InterfaceDialogFrameX`, `SetBackdrop` accepts it, and the frame
  has no background and no border. It parses, it loads, and the failure looks like a design choice.
  **It shipped in `COA_DungeonRun`'s readout panel from §69 through a commit and a deploy.** Guard:
  `py addons/tools/check_escapes.py` (MANIFEST-scoped, exits 1, `--selftest` proves it bites).
  ⚠ I first called this cosmetic on a mis-read of my own test — **check string behaviour against
  `.tools/lua51/lua5.1.exe`, never from memory.**

- **★ THE SMOKE'S FRAME STUB RETURNS A FUNCTION FOR ANY KEY IT DOES NOT KNOW** — so
  `type(frame.OnMouseWheel) == "function"` is an assertion that CANNOT FAIL, and `frame.point` is
  never nil. Use `rawget` whenever you are testing whether something was actually SET. Cost twice
  now: the object pane's `o.point` (§72) and §77's handler checks, where the mutation for a deleted
  drag-start script came back **SILENT**. The stub's convenience is the test's blind spot.

- **The Cowork-era "mpyq can't read these MPQs" claim is false locally** — only the 8
  listfile-less archives fail. Don't re-inherit that wall from old notes.

## The lane (Battlewrath, 2026-07-15)

**Addons = the mechanical game relation** (client surface, capture tooling, evidence, source facts).
**Auras = the WA bridge** (patterns, corpus, dockets, adoption). Either can step into the other, but
it's a lane: hand off ACROSS it, don't do the other bench's documentation. Caught live: the
guardian-tracker pattern write-up was aura-lane work done from this bench — kept this once
(`corpus/patterns/guardian-health-tracker.md`, flagged as addons-authored draft for the aura bench
to tighten/own); future = hand off the snippet + facts, let auras document.

## The seat (how this bench runs — one line each)

Repo = truth; deploy.py byte-copies (game closed; new code = full restart). SV = one-envelope
mailbox; watcher lands records runId-deduped. Tasks are bounded units on the v2 spine, steered
by args, self-cycling, by-exception chat. Census tables answer "what does the client offer" —
contracts drag their areas out by citation, never by re-derivation.
