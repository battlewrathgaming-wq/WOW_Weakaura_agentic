# The MVP — SCOPED

_Staged 2026-08-16. **Not a build plan and not scheduled.** A cut, so the smallest thing that works
end to end is written down before anyone starts adding to it._

⚠ **Read `dungeonrun_model.md` first.** Everything below is a subset of what the model already says;
this file only decides what is IN the first pass and what waits.

---

## ★★★ The gap is singular: everything AUTHORS, nothing PLAYS

`Routes.BeaconAt(id, index)` — *"the beacon under test at a given index"* — has **no caller anywhere
in the addon**. That is the whole of what is missing. Capture works, the map draws, promotion mints,
the object pane edits, curation filters, routes store. A route can be built and cannot be walked.

★★ **Which is also why nothing has pushed back on the model.** Every ruling since §78 has been
argued against a consumer that does not exist, so nothing has been able to disagree with it. **The
MVP's real product is the disagreement**, not the feature.

---

## ★★★ THE CUT

    arm a route      pick one, start
    ratchet ONLY     one register. No maxSeen, no escapement
    on-ramp          set the supertracker to the current beacon
    off-ramp         within reach -> advance
    finish           last stage satisfied -> done

**Arm a route of childless beacons, get pointed at each in turn, arrive, advance, finish.** That
exercises the ratchet, the reach, the tracker and the closed loop — which is every load-bearing
claim the model makes about running a route.

### Deliberately OUT of v1

| | why it waits |
|---|---|
| **children** | a route of childless beacons walks fine, and children are the complexity answer — the thing you reach for when the simple form is proven |
| **note actions** | §91 left `note` out on purpose: with ids a note is a CONSUMER several children reference, not a string each owns |
| **boss death / CLEU** | a second trigger axis. The distance axis has to be shown working first |
| **`maxSeen` and the escapement** | both exist to handle a ratchet that went wrong. Nothing can go wrong until something runs |
| **the player's correction path** | same — a requirement raised by a hazard that has not been observed yet |
| **the consequence register** | a text tone for destructive acts. v1 has none |
| **the flight list itself** | ⚠ the flatten is the DESTINATION, not the starting point. A first driver reads the route structure directly; the transformation earns its place at export, not at first walk |

★ **The list above is not a backlog of missing pieces.** Each one is a thing the model already
decided; they wait because **the first walk is what tells us whether the decisions were right**, and
adding them first would mean testing six claims at once.

---

## ★★★ THE ORDER — the overhaul goes FIRST, and the MVP is what unblocks it

> *"That gives the overhaul a test first, if we can present the options to build that route. Then
> the test driver, to drive that session through a remote."*

★★★ **This resolves the overhaul's chicken-and-egg.** It has been waiting on *"not enough content to
reason what-goes-where within that pane"* — which was a correct call, not a stall. The MVP supplies
exactly the content it lacked: **a bounded, concrete requirement — present the controls needed to
author one route of childless beacons, and nothing else.**

    1. the overhaul   present the options needed to BUILD that route
    2. the driver     drive that session, from a remote

⚠ **So the overhaul's first pass is scoped by the MVP, not by the full model.** For a childless
beacon that is `Face : Stage 1 : Stage 2`, and inside those only the supertracker y/n and the reach.
Everything else the four-strip structure describes is out of the first pass with it.

---

## ★★★ THE ROUTE REMOTE — a SEVENTH surface, spawned from Promotion

> *"A seperate remote. Spawned from promote. We don't want to condense route testing which is five
> steps deep against the front door remote."*

★★★ **The depth of a surface should match the depth of what it does.** A front-door control implies
front-door frequency and front-door simplicity, and route testing is neither. The front Remote stays
what it is: capture, plus a door.

⚠ **Today the Remote has no route side at all** — `pin`, `name`, `count`, `arm` are all capture, and
`map` is the door. Adding to it would not be extending a category; it would be introducing one.

★ **And it spawns where the route is already chosen**, so it inherits the loaded route and needs no
picker of its own. Go, stop, and whatever it reports.

    Remote  ->  Map  ->  Promotion  ->  route remote

**v1 constraints, his:** *"No typed comands, no heavy dug modes for v1."* Which is the model's own
rule already recorded — *a slash command you have to already know is not a surface* — arriving where
it would have been most tempting to break it.

⚠ It comes with its own interface file and declared rows. The checker walks six surfaces today.

---

## ⚠ Before the first run

**Wipe saved variables.** Beacons in already-saved routes carry no `id` (§227), so their
delete will quietly do nothing. His call was **wipe over retrofit**, so there is deliberately
no guard and no migration — a per-object complaint would make every stale beacon cry about a
state he is about to delete.

## Open

- The far-stage policy (what a satisfaction from a stage you are not on should DO). ★ Bounded rather
  than urgent — bosses as `set:stage` resync points mean a drifted ratchet can only be wrong
  *between* bosses. And it is a build-to-lookable, not an ask: the sprite walking a real run against
  a route reports how often it would have fired.
