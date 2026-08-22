# ARCHITECT_PROPOSALS — feature enrichment, OFF the factual basis until we are stable enough to drain it

_Opened 2026-08-22 at Battlewrath's instruction: "I'd keep these off the factual basis. Proposals / feature
enrichment to drain when we are stable to do so." **This file governs nothing and is cited by nothing that
builds.** Each entry is a shape reasoned with him in conversation, held here so it is not lost and not
mistaken for a ruling. An entry LEAVES by draining into `driver_architecture.md` (and from there to the
governing docs) with a log entry, or by being struck. Status is on the entry: `AP-N DRAINED (date, AL-N)`
or `AP-N STRUCK (date, why)`; no stamp = held._

---

## AP-1 · The tracker shows the ABSOLUTE position of the stage or step; trails are the author's
When the next node is on another floor, the supertracker still points at the node's world position; a
route that wants the reader led via the stairs has a STEP at the stairs — authored, not inferred. We surface
it better (AP-4's map line), we never re-target. Battlewrath: *"the tracker shows the absolute position of
the stage / step, and it's on the author to make that a stage or a step trail. We just surface it better."*

## AP-2 · The map↔world FIT and the floors a map expects TRAVEL WITH THE ROUTE
Calibration is captured by the run and the editing suite and shipped as a third side table beside NAMES and
NOTES — per floor, a few numbers, identifiers-and-numbers like everything on the line; repeated across
routes on one map and still light. The addon ships NO calibration of its own (shipping it would make us
maintainers where the addon can be self-serving); a data gap is corrected at authoring. The floor list the
native map expects rides the same way.

## AP-3 · Route METADATA is the route's own character — declared, opt-in, never inferred
Class (any, or a class) · affix · key rank · perhaps expected item level / difficulty. Captured where the run
already knows it (the capturer's class, the key and affix at capture) and widened by the author ("any").
**Owner-owned and opt-in, never mandatory to author.** The reader's OFFER filters on what is present and never
hides a route for lacking a field. Metadata is DECLARED, never inferred by the consumer: a route that says
nothing about class is "any"; the reader's addon does not guess from its own class.

## AP-4 · FLOOR TRANSITION points — same data, derived on editor interaction
A transition is the sample pair where the floor label changed; the editor derives a marker from it (bucket-
before-prune keeps it — a transition is an event of its segment). The reader's overlay draws a LINE on the
current floor to the transition when the next node is on a different floor — somewhere to point to.

## AP-5 · Dungeon Routes rides the NATIVE MAP as an OVERLAY that matches its state and hooks nothing
Our own frame, parented to the map's detail layer, anchored to its rect, scaled by its one mode number; floor
and mode READ from the map's own state; `WORLD_MAP_UPDATE` to redraw. Never a `SetPoint` on a Blizzard frame,
never a hook on a shared function — the two-owners-for-one-widget fault the client itself has. GatherMate /
HandyNotes draw this way and coexist. Content: actionables only (the stage's nodes · the next waypoint · the
arrow's target · AP-4's line). Needs AP-2's fit to project world → map.

## AP-6 · PRE-POPULATION is the authoring principle — facts PLACED, never judgements MADE
Authoring is the half that might bite the product (consumers of a WeakAura pack vastly outnumber its
builders). So the capture suite hands the author CANDIDATES: every boss kill, boon, floor transition, death
site and combat segment already on the map as a marker the author promotes with one act, obvious defaults
filled (the boss node's kill row and recovery Next · the boon's "pick up" note · the transition as a step);
a captured run can offer a DRAFT ROUTE. The author CURATES — selects, trims, adds the note and the
coordination line. The boundary (Battlewrath): the addon's "smart" is EXPRESSION — using the data we have to
make *"beacon goes there with X"* quick to say — never ASSESSMENT (which pull is dangerous, which route is
good, what to build); there is no agent in the game to reason, and a route that reasoned would open decisions
instead of flattening them. The capture can place the health dip; the author writes "use defensives here".

## AP-7 · The editor's FUNCTIONS over the record — readings with their basis, converging as samples pool
The capture never resolves ambiguity; the EDITOR may, as a function over the record: per unit name, the %
seen and the casts seen, with a trend that isolates clear cases by TIME signature and NAME signature (one
name dying alone at one moment is a clean reading; three names in one moment stay flagged until more samples
split them). Each reading shows its basis (L18 — grep the samples it came from); pooled samples converge into
PROFILES. A measurement handed to the author ("this unit is worth about 1.2%"), never an assessment of what
to build. The layering, one floor deeper: the RUN emits facts · the EDITOR's functions derive readings with
their basis · the AUTHOR judges · the ROUTE carries the expression.

---
_Drain order when stable: AP-2 and AP-5 together (the overlay needs the fit) · AP-1/AP-4 with them · AP-3 with
the offer's filters · AP-6/AP-7 with the capture suite (G29–G31). None before the proof (§6b) is green._
