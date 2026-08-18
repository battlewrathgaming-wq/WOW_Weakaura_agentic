# V1 DRIVER — SENSE. The bench's proposal, for tests to be written against

_Addons bench, 2026-08-18 (§371). **A proposal, not a governing document** — it directs nothing.
Battlewrath asked for it so acceptance can be written; each numbered behaviour below is meant to
become a criterion or be struck. Governed by `DRIVER_BASIS.md`; the sensing rule's own acceptance
already exists as `driver_walk_acceptance.md` W1 and W7._

---

## 0 · WHY SENSE IS FIRST

Battlewrath, 2026-08-18: *"First I think is a sense check. That we can perform sensing. As
that's the pre-condition to killing the boss."*

A boss action is *"a full function that listens the arg when sense is match"* — so **arming is
scoped by the sense** (A3.5). Nothing about the boss can be built or graded until the thing that
says *the player is here* exists and is trusted.

★ And the rule itself is not new work. `addons/tools/walk.py` carries it as `point_fire` and
`segment_fire`, W1.1–W1.10 are PASS, and `py addons/tools/walk.py check` reproduces every
W2/W3/W4 golden today. **What does not exist is a consumer.**

---

## 1 · WHAT V1 IS

> **Given a flat list of targets and the player's position, say which targets the player is in.**

Nothing else. No stage, no step, no lock-out, no recovery, no boss, no CLEU, no arming.

### 1a · THE INPUT IS A FLAT LIST, AND THAT IS A RULING NOT A PREFERENCE

Battlewrath, recorded at `routes.lua:509` in his own words:

> the driver must be installable **WITHOUT the editor**, reading a flattened list that is
> *"a product of the auditor, not needing to know how it is all coded in construction"*

and again 2026-08-18: *"as a flattened list. NOT as privilege of having a full corpus of data."*
**A8.6** carries the other half — *the flat form IS the stored form*, with panes as views over it.

★ **This decides WHICH driver gets built.** Fed the corpus it would only run where the corpus
is, and Dungeon Routes would need a second one. Fed the flat list, the driver we build is the
driver that ships. ⚠ So V1 may not call `ChildrenOf`, `ParentOf`, `AcceptanceOf`, `StageOf` or
touch the routes table at all — the same law that forbids a child holding a reference
(`routes.lua:509`) forbids the driver reaching for one.

### 1b · THE ROW SHAPE — bench read, and the thing most in need of a ruling

Derived from what `point_fire` / `segment_fire` actually consume, plus one identity:

    id        the address `RID:BID:CID` — the only thing that travels and points at nothing
    mapID     to reject on; a target in another map is not a near miss
    x, y, z   WORLD coordinates
    r         radius
    bandUp    ┐ the asymmetric band (§85), applied on dz
    bandDown  ┘
    ordinal   ⚠ V1 IGNORES IT. Carried from the start because its ABSENCE is the recovery
              signal V2 needs (§4b), and a field added later is a format change.

⚠⚠ **WORLD xy/z, NEVER MAP xy.** `map.lua:46` records that the coordinate space (1002×668) and
the tile art (1024×768) are two different sizes and that confusing them still RENDERS — wrong by
+2.2% across and +15% down. `capture.lua` stores both pairs, so a driver taking the wrong one
would sense confidently and be wrong worst furthest from the origin.

---

## 2 · THE RULE — already specified, already proven

`walk.py` is the reference implementation and the DESK is the authority (W7.1).

    POINT     is this sample inside R in xy, with dz inside the band          `point_fire`
    SEGMENT   did the PATH from the previous sample to this one come within R `segment_fire`

★ **The band is applied at the INTERPOLATED z of the closest point, never at an endpoint.** That
is the walkway-above case: a transit passing over a target is vetoed where it would otherwise
have fired. Testing an endpoint's z vetoes the wrong sample or none at all.

Already ruled and already graded on the desk (W1.1–W1.10): the point fallback when the previous
sample is absent or invalid · a mapID-straddling segment is discarded, never bridged · no hold
(a transit with one in-region sample fires) · the band veto · `while` mode entering at R and
exiting at R + margin · the clamp branch · the gap bound on chain continuity.

⚠ **V1 inherits all of it or it is not the same rule**, which is what W7.1 exists to say.

---

## 3 · WHAT V1 MUST DO — the behaviours a test can name

    S1  fed a flat list and a position, reports every target the player is IN
    S2  reports by ADDRESS, never by index into the list (an index is a reference)
    S3  a target in another mapID never fires, however close the numbers are
    S4  the band vetoes on dz at the interpolated z, not at either endpoint
    S5  the FIRST sample after arming uses POINT (there is no previous sample to segment from)
    S6  a stationary player (degenerate segment) falls back to POINT rather than dividing by zero
    S7  it holds NO route state: given the same list and the same samples it answers the same,
        in any order, with no memory between runs beyond what the caller passes in
    S8  it reports `hit · skip · false_advances` (W7.3) and NEVER `stage`, which is not a result
    S9  it costs nothing when nothing is armed — no persistent `OnUpdate` (capture.lua's own
        discipline: *"the handler exists ONLY while recording"*)
    S10 ⚠ non-finite input is rejected, and in Lua that is TWO tests (W7.2):
        `type(v) ~= "number"` and `v ~= v`; NaN and inf are separate fixtures

---

## 4 · WHAT V1 IS NOT — so nothing is graded that was not asked

### 4a · Out of V1

    stages · steps · the ordinal lock-out · recovery · the boss function · CLEU · arming ·
    completion · Next · the test-drive remote's chrome (A10.5's readout is the OUTPUT SHAPE
    V1 reports in, not a surface V1 builds)

### 4b · What V2 will need, named now because V1 must not foreclose it

Battlewrath, 2026-08-18: *"At some point it'll need to understand stages and steps. As they are
a lock out mechanic. And it will need to know to always listen to update beacons (no order,
doesn't exist), otherwise recovery can't be done."*

★ **Both halves already exist on the editor side**, in `Routes.ListensNow`, and it is stateless:

    if child.ordinal == nil then return true end     -- a satellite is always live

That one line IS the recovery mechanic; the rest of the function is the lock-out. So V2 does not
invent either — it gives the driver the rule the editor already holds, which is the argument for
the flat row carrying the ordinal from the start (§1b): **the absence is the signal.**

⚠ **AND ONE GAP BLOCKS THE BEACON HALF OF RECOVERY.** An ordinalless CHILD is expressible today;
a STAGELESS BEACON is not — every beacon is minted with a stage (`routes.lua:345`) and
`SetStage` keeps the old value on anything unparseable, so `nil` never lands. Marked at both
sites §366 on Battlewrath's instruction ("to be fixed later, no impact"). It has no impact on
V1 and becomes real the moment V2 does.

---

## 5 · THE REFERENCE AND THE GOLDEN — they exist before the code

    W7.1  the Lua rule, fed the same fixture rows at the same cadence, produces the same stage
          timeline and the same per-beacon first-hit indices as the desk. BYTE-EQUAL. The desk
          is the reference.
    W7.2  the branches UNREACHABLE from the corpus (mapID straddle · non-finite · the clamp
          W1.9 · the gap bound W1.10) are graded with the SAME synthetic fixtures as the desk.
          ★ A port test that only replays the corpus ships those branches unproven.
    W7.3  readouts carry `hit`, `skips`, `false_advances`; `stage` is not a result.

★ **So this port is graded before it is built, with its reference data already written.** That is
rare and it is worth not wasting: V1's first green should be W7.1's byte-equality, not a
hand-written assertion about a number someone chose.

⚠ **A9.5, and it lands here:** the three `w5_*.golden.txt` files are UNWATCHED — `walk.py check`
covers W2/W3/W4 only, and nothing runs the w5 goldens on a landing. **A golden nobody runs is the
reference the port would be graded against.** Bench read: watch them BEFORE the port, not after.

---

## 6 · INGEST, AND WHERE THE TARGET IS SET

**Ingest.** `GetCurrentPlayerPosition()` → `x, y, z, mapID`, fork-native and ROUTER-recorded.
`capture.lua` already runs the shape a driver needs — an `OnUpdate` accumulator at 1 Hz, and
W4.1's constant: *capture at 1 Hz; do not go coarser.*

⚠ The cadence is a DECISION, not a default. `capture.lua:299` records the other direction —
*"COA_Landmarks calling GetCurrentPlayerPosition() 59 times a second"*. **Open (§7 Q2).**

**Where it is set.** Already authorable: `AddBeacon(id, node, stage)` / `AddChildHere(id, b)`
place the position; `SetBeaconReach` / `SetChildReach` set radius and band; `ReachOf(AcceptanceOf(b))`
is the composed read A1.1 landed. ★ Nothing new is needed on the editor side for V1 — only the
flattener, and V1 does not wait on it (§7 Q1).

---

## 7 · OPEN — the bench cannot settle these

    Q1  DOES V1 WAIT FOR THE FLATTENER? It is unbuilt (target §K, Dungeon Run's list). The
        driver needs the SHAPE, not the producer, and can be graded against a hand-written
        fixture list. ★ Bench read: build to the shape, let the flattener arrive with a
        consumer to satisfy rather than a format to invent.
    Q2  THE CADENCE. 1 Hz matches capture and W4.1's constant, and the desk's fixtures are at
        that cadence — which W7.1's byte-equality may actually REQUIRE. Bench read: 1 Hz,
        because the golden is at 1 Hz; a faster driver is a different experiment.
    Q3  POINT, SEGMENT, OR BOTH IN V1? W1.5 says the segment test never detects less than the
        point test. Bench read: BOTH, because the desk does both and W7.1 is byte-equality
        against the desk — a V1 that only points cannot be compared.
    Q4  WHERE THE DRIVER LIVES. Its own file in `COA_DungeonRun`, or a separate addon (it must
        be installable WITHOUT the editor). Bench read: its own file now, structured so that
        moving it later costs a `.toc` line — but the SPLIT is a shipping decision, not mine.
    Q5  WHAT ARMS IT IN V1. A10.5's remote is out of scope here, but something has to start it.
        Bench read: a function call, exercised by the smoke; the remote wires to it later.

---

## 8 · WHAT THE BENCH PROPOSES TO BUILD, in order

    P1  WATCH THE w5 GOLDENS (A9.5) — before the port, because they are its reference
    P2  the flat row SHAPE, as a declared contract with a fixture list against it
    P3  the RULE in Lua: point + segment + band, ported from walk.py
    P4  W7.1 byte-equality against the desk, and W7.2's synthetic branches
    P5  ingest at the ruled cadence, armed and disarmed with no persistent OnUpdate
    P6  the readout: hit · skip · false_advances, by address

---
_Nothing here is built. The proposal leaves once its behaviours are criteria or struck._
