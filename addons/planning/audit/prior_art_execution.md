# PRIOR ART — hands-off executors: instructions against functions

_Addons bench, 2026-08-19 (§384). A FINDINGS file: sourced, directs nothing. Third audit in the
sequence — `audit/peer_data_stores.md` (§377) measured our PEERS on this client,
`audit/prior_art_formats.md` (§379) read format specs, and this one reads **executors**._

_Battlewrath's brief: **"what open source, automation builder and execution packages exist. Flight
controllers. Basically anything that is hands off in operation. Where the execution is
instructions against functions, rather than shipped modules that are self containing."**_

★ **That distinction is our architecture stated from the outside**: the route file is inert and
names things; the addon holds the implementations. So the question is what everyone else who built
that shape learned. ⚠ Sourced from published docs, not measured on disk — one rung weaker than
§377, and flagged as such.

---

## 0 · THE HEADLINE

    ★★★ MAVLINK'S MISSION ITEM IS OUR LINE, field for field, in a safety-critical system
        with two decades of use. Closest prior art found in any of the three audits.
    ★★★ AND IT ANSWERS P1 A FOURTH WAY: a FIXED generic param block buys a positional
        format skippability WITHOUT tags and WITHOUT a version.
    ★★  P3 GETS A THIRD ANSWER. MAVLink neither rejects nor merely represents NaN - it
        ASSIGNS IT MEANING. `NaN` = "do not change this". A11.2e rejects what a flight
        controller made load-bearing.
    ★★  G-CODE'S MODAL STATE and polyline's delta encoding turn out to buy compactness
        with THE SAME CURRENCY - sequential dependence - which our recovery rule prices.
    ★   HOME ASSISTANT SHIPS §374's FACE/META SPLIT, and says why in its own docs.

---

## 1 · MAVLINK MISSION PROTOCOL — the closest analogue in any audit so far

A drone mission is an ordered list of items uploaded to a vehicle that then flies it unattended.
`MISSION_ITEM_INT`:

    seq · frame · command · current · autocontinue · param1..4 · x · y · z · mission_type

Set beside our working line:

    OURS      MapID : RID : Stage : Step : BID : CID : POS : R : Band : Next:N : Sense:action:trigger:arg
    THEIRS    mission_type : (implicit) : — : — : seq : frame+x,y,z : param2 : — : autocontinue : command:param1..4

    seq            an ORDINAL IN THE ITEM, not implied by file position   ~ our CID
    command        a MAV_CMD enum - an ID, never a name                   ~ our action
    param1..4      meaning depends ENTIRELY on `command`                   ~ our arg
    x, y, z        the position                                            ~ our POS
    frame          MAV_FRAME - the COORDINATE SYSTEM, declared PER ITEM    ⚠ we have no such field
    autocontinue   "autocontinue to next waypoint when the command completes"  ~ our Next
    current        which item is active - runtime state, in the item       ⚠ we have no equivalent
    mission_type   mission · geofence · rally - ONE WIRE, THREE PLAN KINDS ⚠ nor this

★★ **Three of their fields have no counterpart in ours, and each is a question rather than a
lack:**

    FRAME          they declare the coordinate system per item because a mission can MIX
                   global and local frames. ⚠ Our POS's frame is implied by MapID. That is
                   probably right for us - but it is IMPLIED, and they found it worth stating.
    CURRENT        runtime state living in the plan. ⚠ We keep progress OUT of the route
                   (RI-4, §24: no node holds another node's identity), which is the opposite
                   choice - and ours looks better for a file that gets shared.
    MISSION_TYPE   ★ ONE TRANSPORT, SEVERAL PLAN KINDS, discriminated by a field. Worth
                   knowing if routes and anything else ever share an export path.

⚠ **And no version field in the message** — *"versioning is handled at the MAVLink protocol
level."* Same answer as protobuf's: **the layer below carries it.** Two independent systems put
the version somewhere other than the record.

★ **Their transfer protocol is explicit and ordered:** MISSION_COUNT → per-item REQUEST → ITEM →
ACK, and *"items must arrive in order; out-of-sequence messages are dropped and re-requested."*
Order is a contract they ENFORCE at transfer rather than assume — RI-21 D7 again, third precedent.

---

## 2 · ★★★ THE FIXED GENERIC PARAM BLOCK — skippability without tags

One `MAV_CMD` enum plus seven generic params covers every command in the protocol:

    MAV_CMD_NAV_WAYPOINT     p1 hold time · p2 acceptance radius · p3 pass-through · p4 yaw
    MAV_CMD_NAV_LOITER_TIME  p1 loiter time · p2 exit heading · p3 loiter radius · p4 yaw
    MAV_CMD_DO_JUMP          p1 target seq · p2 repeat count · p3-7 UNUSED/RESERVED

★★★ **And the consequence is the finding:** *"ground stations gracefully handle unfamiliar commands
by simply passing through all seven parameters to the autopilot"* and *"new commands can be added
to the enum without modifying message structures."*

> **A POSITIONAL record whose payload block is FIXED-WIDTH and GENERIC is skippable — not because
> a tag says how long a field is, but because every record is the same length regardless of what
> it means.** Unknown commands survive intact.

⚠ **This is a FOURTH answer to RI-20 P1**, beside a version token, a length prefix (D4) and
tag-length-value. `prior_art_formats.md` §1a said a positional format *must* carry a version
because it cannot skip — **that was too strong, and this is the correction.** It cannot skip a
VARIABLE-WIDTH unknown; a fixed-width generic block has nothing to skip.

★ ⚠ **The price is stated plainly in their own design and we should not gloss it:** `param3-7`
are UNUSED on DO_JUMP. **A fixed block pays for every command's worst case on every row.** For a
protocol of packed binary floats that is nothing; for a text line it is visible. ⚠ And our `arg`
is already the same idea in one slot rather than seven — **the difference is that ours is
variable-width and last, which is why it can only ever be ONE.**

★★ **MAV_CMD_DO_JUMP is also control flow AS AN INSTRUCTION** — target seq plus a repeat count,
*"eliminat[ing] the need to manually duplicate waypoints."* Our `Next:N` is the same family, and
theirs is evidence that a jump-with-count is enough structure for real missions.

---

## 3 · ★★ P3 GETS A THIRD ANSWER — NaN AS A SENTINEL

    MAV_CMD_NAV_WAYPOINT   param4: yaw orientation (degrees, or NaN for NO CHANGE)
    MAV_CMD_NAV_LOITER_TIME param2: exit heading (degrees, or NaN for NO CHANGE)

★★★ **A flight controller — hands-off, safety-critical — uses NaN as LOAD-BEARING MEANING.** Not
rejected (JSON), not merely representable (CBOR): **assigned a job.** "No value here" in a field
whose every finite value is legitimate, without spending a second field on a present/absent flag.

⚠ **This does not overturn A11.2e** — a NaN *position* is meaningless and rejecting it is right.
But it shows the question is finer than reject-or-represent:

    a  REJECT everywhere                              A11.2e today
    b  REPRESENT, meaning undefined                   CBOR
    c  REJECT in fields where it is nonsense, ASSIGN MEANING where "unset" is a real state
                                                      MAVLink

★ And (c) bears on something already live: **RI-22 measured that `tonumber("1e400")` puts Inf into
the store through the shipped radius box.** ⚠ Under (c) the interesting question is not only "is
Inf allowed" but "does any of our fields have a legitimate UNSET that we are currently encoding as
nil, or as an absent slot, or not at all" — `Band` being optional (RI-22) is exactly such a field.

---

## 4 · ★★ MODAL STATE — and the currency compactness is always bought with

G-code is the oldest hands-off instruction set in service. Its central idea:

> **Modal** commands change a mode that *"stays active until some other command changes it"*.
> **Modal groups** hold commands where only one member can be in force at once.
> **Non-modal** codes *"apply only to the block in which they appear"*.

★ So a line carries only what CHANGES. Feed rate, units and coordinate mode persist; every
subsequent line is shorter for it. ⚠ LinuxCNC even has `M70`/`M72` to SAVE AND RESTORE modal
state — and the docs note a restore-order subtlety (units first, because feed is interpreted in
them), which is the tell that modal state is powerful and fiddly in equal measure.

★★★ **And placing it beside RI-21 D2 gives a result neither has alone:**

> **Delta encoding (polyline) and modal state (G-code) are different techniques that buy
> compactness with THE SAME CURRENCY: sequential dependence. Neither lets you read row 40 without
> having read rows 1..39.**

⚠ **Which is why our recovery rule is the thing that prices both.** Battlewrath, 2026-08-18: the
driver *"will need to know to always listen to update beacons (no order, doesn't exist), otherwise
recovery can't be done."* **A row that must be readable out of order cannot be modal and cannot be
a delta.** ★ That is one sentence deciding two separate optimisations, and it decides them
against — which is worth having explicitly, because both will look attractive again later.

★ ⚠ **But note the shape of the real answer, which is not all-or-nothing:** G-code makes SOME
codes modal and others one-shot. If our rows split into "always-listen recovery beacons" and
"ordered steps", the ordered ones could in principle be modal and the recovery ones absolute.
**Named as a possibility, NOT proposed** — it buys compactness we have measured as unnecessary
(routes are 0.002 MB, `audit/data_model_findings.md` §6b) at the cost of two row kinds.

---

## 5 · INSTRUCTIONS AGAINST FUNCTIONS — the pattern, in four other fields

    BehaviorTree.CPP  robotics/game AI. Trees are XML loaded at RUNTIME: "the morphology of
      (C++)           the Trees is _not_ hard-coded". Node types in the XML resolve to C++
                      classes registered in a factory; custom nodes can be static or plugins.
                      ★ The XML is DATA; the executable holds the behaviours.

    Amazon States     "The Task State... causes the interpreter to execute the work identified
    Language          by the state's 'Resource' field", where Resource is a URI. Every state
      (JSON)          MUST have a `Type`; transitions name the next state by NAME via `Next`.

    Home Assistant    triggers / conditions / actions. An action names a service the runtime
      (YAML)          holds - `action: homeassistant.turn_on`, `target: entity_id: ...`.
                      ★ Trigger-condition-action is our sense / gate / action, renamed.

    MAVLink           `command` is an enum; the autopilot holds every implementation.

★★ **Five systems, five fields, one shape: the plan names a capability by ID and the runtime owns
it.** ⚠ Which is worth stating for what it does NOT license — none of this argues our design is
right, only that it is *the ordinary shape for this problem*, and that its known costs are the
ones we should expect to pay.

★ **The cost they all share, and it is one we have already met:** the plan can name a capability
the runtime does not have. ASL resolves an ARN that may not exist; BT.CPP's XML may name an
unregistered node; HA's action may name a missing service. **That is RI-22's index-into-a-grown-
table (§381c) in four other languages** — and none of them solves it in the format. They all fail
at load and say what was missing. ⚠ **Failing loudly at load is the field's actual answer to the
problem P1 was worrying at.**

---

## 6 · ★★ AMAZON STATES LANGUAGE — the version field's graceful form

> *"A State Machine MAY have a string field named 'Version'... if omitted, the default value of
> 'Version' is '1.0'."*

★★★ **An OPTIONAL version whose ABSENCE IS ITSELF A VERSION.** That is how a format that shipped
without one retrofits it: every existing file is valid and means v1.0, and the field only appears
once there is something to distinguish.

⚠ **Which is exactly Battlewrath's position made concrete** (§382): *"Versioning is less an issue,
we don't have V1. If it ever bites we can ship resolver buckets on export."* **The retrofit does
not need to be designed now, and ASL is the proof it costs nothing later** — an optional field with
a stated default, added the day it is needed, breaks nothing that already exists.

★ ASL also carries `Comment` (human text, ignored by the interpreter) and `TimeoutSeconds` (a
machine bound). ⚠ Note where the free text went: **a field the executor never reads**, which is our
notes table by another route.

---

## 7 · ★★★ HOME ASSISTANT SHIPS §374's FACE/META SPLIT — and says why

    alias   "Friendly name for the automation"
    id      "A unique id for your automation, will allow you to MAKE CHANGES TO THE NAME and
             entity_id in the UI, and will enable debug traces"

★★★ **The id exists SO THAT THE NAME CAN CHANGE.** That is §374's landing — *"the route selector
shows the NAME; what the user sees vs what the system uses"* — corroborated by a project with an
enormous installed base, and with the reason stated in its own documentation rather than inferred.

★ And the second half of their sentence is the part we have not built: *"will enable debug
traces"*. **The stable id is what makes a trace attributable across a rename.** ⚠ Our driver
already reports `hit · skip · false_advances` against `RID:BID:CID` — so we have the id side; what
HA notes is that this is a FEATURE of the id, not merely a consequence. Bears on
`driver_data_model_proposition.md` G8 (who resolves names for a human).

---

## 8 · WHAT THE BENCH DOES NOT TAKE FROM THIS

⚠ Stated so the file cannot be read as a shopping list:

    · NOT proposing a frame field, a `current` field, a mission_type discriminator, modal
      rows, a seven-slot param block, or a version field. Every one is presented as a thing
      the field does, with its price named.
    · The MODAL possibility in §4 is explicitly NOT proposed - it buys compactness we have
      MEASURED as unnecessary (0.002 MB) at the cost of two row kinds.
    · §5 does NOT argue our design is correct. It establishes that it is the ordinary shape,
      and that the costs we should expect are the ones those five projects pay.
    · ⚠ ONE CORRECTION TO OUR OWN EARLIER FILE. `prior_art_formats.md` §1a said a positional
      format MUST carry a version because it cannot skip. §2 above shows that is too strong:
      a FIXED-WIDTH GENERIC payload is skippable without tags or versions. The claim should
      read "cannot skip a VARIABLE-WIDTH unknown."

---

## 9 · SOURCES

    MAVLink mission protocol   mavlink.io/en/services/mission.html
    MAV_CMD enum               mavlink.io/en/messages/common.html
    BehaviorTree.CPP           github.com/BehaviorTree/BehaviorTree.CPP (README)
    Amazon States Language     states-language.net/spec.html
    Home Assistant automation  home-assistant.io/docs/automation/yaml/
    G-code modal groups        linuxcnc.org docs + CNC references (secondary)

⚠ All secondary-to-primary documentation rather than measured code, unlike §377. The G-code entry
is the weakest — general references rather than the LinuxCNC interpreter source — and the modal
claims should be re-read against that source before anything is built on them.

---
_Sourced 2026-08-19. Nothing here rules._
