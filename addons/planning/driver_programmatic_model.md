# Dungeon Routes — THE PROGRAMMATIC MODEL (the editor's authoring form)

_Battlewrath, 2026-08-17: "From the editor side, the author needs a flattened list. Not to write
a story. Drop-downs." Sharpened by the Analyst; every drop-down's contents come from
`driver_user_journey.md`'s two complete sets — nothing added. Names are still candidates (S3:
behaviours first); the STRUCTURE is what this file fixes._

---

## 1. The objects (two, and the first is the second when it has no children)

**BEACON**
    - self-completes AS a child when it has none — the everyday unit, whole by itself
      (lure + advance in one; scoping S2 addendum)
    - WITH children: the scene manager — child identity + presentation management
      (rename each from one surface, opacity in the editing view; S2) **+ displays and edits
      the ORDINAL of its children from that same surface** (reorder a chain, insert 3.1, take
      a satellite out of the ordinal line). Each child is still edited on its OWN pane —
      location, alias, appearance, tabs, its own ordinal; the parent's surface is for
      MANAGEMENT ACROSS the set. Two doors to one field; the ordinal has one home (the child)
    - stage (ordinal; fractions allowed) · name

**CHILD**
    - location when minted      the read it was spawned from (never invented)
    - location current           after free placement (S1) — z inherited, band tolerates
    - identity / alias           its name to the author
    - appearance                 icon / presentation
    - behaviour = the SUM of its actions; **actions as tabs, one tab per action**
    - **ordinal within the beacon's identity** (Battlewrath) — stored, filterable: which child
      is first (the lure by default), which is next in a chain, which tab-set is live.
      **C10 RESOLVED (Battlewrath): beacon and child have SEPARATE identities, joined by a colon.**
          Beacon 4.1                  a beacon on the stage line (inserted between 4 and 5 — the
                                      model's meaning stands)
          Child of beacon 4.1:1 · 4.1:2 · 4.1:3 · 4.1:3.1   children under it; fractional
                                      insertion works on both sides of the colon
      The full path (`4.1:3.1`) is the identity and resolves nowhere else in the route. Nothing
      renumbers. (The advisory's "4.1 = a child" reading is withdrawn.)

## 1b. The four kinds, and what governs each one's listening (Battlewrath, same day)

    Beacon · childless · ORDINAL       a stage on the line — the everyday unit
                                       ← position + the general stage (ratchet / maxSeen)
    Beacon · childless · NON-ORDINAL   outside the sequence — recovery / boss beacon (set:stage)
                                       ← position + general stage; never advances by order, SETS
    Child  · NON-ORDINAL               satellite / funnel sensor under a beacon — any order
                                       ← position + its beacon being current
    Child  · ORDINAL                   a stage WITHIN a stage — a chain step
                                       ← the child ordinal: previous satisfied → this one listens

The store's filter set is therefore small: `(position, stage)` for the first three kinds;
`(position, stage, child-ordinal)` for the fourth. Nothing else is needed to know who is awake.

## 2. The action tab — three drop-downs

**Refined to the WeakAuras shape (Battlewrath, same day): EACH TAB IS A TRIGGER. A beacon is
SATISFIED when its triggers — each tab — have been satisfied** (All by default; Any as WA's
other combination). Consequences, and they simplify what follows:
    - no AND inside a tab: the skip is TWO tabs — one sensing *falling*, one sensing *reach at
      the landing* — and the beacon satisfies when both have.
    - "what happens NEXT" belongs to the BEACON, not the tab: satisfaction is one event, so
      advance / set stage / activate / return-to-maxSeen happen ONCE, at the beacon.
    - a tab keeps its SENSE and its WHEN TRUE (say a note · point here · let the arrow go).
    So the form is: per tab — sense + when-true; per beacon — combination (all | any) + next.
    The three-drop-down layout below still reads correctly if "next" is read as the beacon's.
    **The combination selector sits ABOVE THE TAB LINE (Battlewrath): all (and) / any (or)
    across the beacon's tabs, offered from v1; default all.** WA's placement, WA's two options.

    ┌ SELECT A SENSE ── two kinds, and a tab may require BOTH (AND) ──────────────┐
    │  POSITION   at this place — GEOMETRY: a radius (one place, broad by           │
    │             construction) or a WIRE (multi-positional: a line of small radii, │
    │             many places tracked at once; per-location tracking measured < 1 % │
    │             on a profile — bench) — and FIRING: once (crossed / entered —      │
    │             edge, segment test) or WHILE (inside — level, point test +         │
    │             hysteresis)  · scene entered                                       │
    │             (Battlewrath: `while` lives HERE as a sense-firing kind, not as a  │
    │             modifier; wire/radius = geometry, a separate axis; G15 stands —    │
    │             `while` has no prior term)                                          │
    │  STATE      in combat / not in combat  · falling / landed  · alive / dead    │
    │             · mounted  (bounded to what the CLIENT REPORTS DIRECTLY — API    │
    │             telemetry on ask, log telemetry by event; bench confirms calls)   │
    │  EVENT      boss engaged (name from the run) · boss killed (name from the run)│
    └──────────────────────────────────────────────────────────────────────────────┘
    Combining is AND only (position AND state) — WA's "all triggers"; nothing computed across.
    Battlewrath's example, the SKIP: sense "player is falling" AND "landed within reach of the
    place we set as the landing" → next: advance, stage 3. Robust for free: excludes someone
    walking underneath, because they were not falling. (Capture must record the state per row
    to replay it — in-combat is captured; falling is not yet: a capture-spec item.)
    ┌ SELECT WHAT HAPPENS WHEN THE SENSE IS TRUE / ACTIVE ────────────────────────┐
    │  point here (come here)   · say a note (≤ ~200)   · let the arrow go (close) │
    │  (nothing — sense only)                                                      │
    └──────────────────────────────────────────────────────────────────────────────┘
    ┌ SELECT WHAT HAPPENS NEXT ───────────────────────────────────────────────────┐
    │  advance (stage complete)  · set stage N  · return to maxSeen                │
    │  activate <child> (hand the arrow on)  · nothing (stay)                       │
    └──────────────────────────────────────────────────────────────────────────────┘
    + modifier on the tab:  only at stage N (optional)
      (`once | while` is NOT a modifier — it is the FIRING kind on the position sense above;
      radius | wire is the GEOMETRY kind — two independent axes)
      **The lowest-level description of a player and a radius (Battlewrath): two facts —
      WHILE IN (inside it now, for as long as that holds — "in" alone is ambiguous, keep the
      "while") and SEEN (has been inside it; a latch that flips once).** Every firing behaviour
      is a sentence over those two: *while in* · *when first seen* · *each time while in*.
      Crossing a wire = Seen on a wire. And "seen" is a PRIOR TERM — the code's `ifUnseen`
      (`routes.lua:631-651`) reads exactly as "act only if not Seen." No "once", no "stepped"
      (advancement is a separate word). Names still the naming pass's, but these two are the
      floor it builds on.

Every entry above traces to a journey line (the STATE kind was added by Battlewrath after the
journey — line 8's skip, made detectable rather than note-only); the journey never asked for
another "when true" or another "next". If a future request cannot be phrased as one of these three
drop-downs, it is not authorable (the model's own test: "can it flatten to a step?").

## 2b. The skip, worked two ways (Battlewrath) — graph vs discipline

    BY GRAPH        child 1 at the ledge: tab = reach here · when true = point here, lets go
                    on reach · beacon next = ACTIVATE child 2.  Child 2 (deaf until then):
                    tab 1 = falling · tab 2 = reach at the landing · next = advance (+N).
    BY DISCIPLINE   no edge. Both live under the beacon from the start; child 2's two tabs
                    discriminate on their own — nobody satisfies falling AND landed-here by
                    walking past — so it never false-fires.

**Rule of thumb that falls out: the graph is for when the senses alone cannot tell the intended
arrival from an incidental one; where a STATE sense discriminates, discipline suffices.** Both
are authorable; the author picks by how much the senses already say. And `advance` takes a
parameter — by N, default 1 (his `set:stage:ratchet(+N)`) — beside `set stage N`, absolute.

## 2c. The boss beacon, as tabs (Battlewrath, 2026-08-17 — not in yet, recorded)

    tab 1  LOCATION      reach at the place the boss is fought (a read from the run)
    tab 2  PUSH TOKEN    boss engaged — the game's event + name from the run
    above  ANY           either witness ARMS the CLEU listener for that name:
                         `listen(UNIT_DIED, name)` (acceptance A3.3 — the function's
                         signature is the guard; no name, nothing arms)
    next   the KILL      UNIT_DIED on that dest name satisfies → advance / set:stage

Arming is generous (you are there, OR the game says it is on); satisfaction is strict (the named
death). Two doors in, one door out. Both arming senses come from the run's record; the listener
is one dest name — inside the bounds by construction.

**The push token arrives at the DRIVER, not at an instruction (Battlewrath).** The consumer keeps
BACKGROUND PROCESSES that serve the armed instructions: an event frame standing for the game's
pushes (engage · death / alive), the throttled position tick, and CLEU armed per boss instruction
with its name. Instructions do not listen; the driver listens and ROUTES what it hears to whichever
instructions are awake — WA's shape (events set flags, one pass drains; index by event, O(1)
miss). Every background process is TWO-WAY — registered on arm, unregistered on disarm — or it is
not non-invasive (neighbours §5: every WA/DBM hazard was a one-way edge).

## 3. Defaults — the author configures nothing to get a working route

    childless beacon   sense: reach here · when true: point here · next: advance
    first child        = the lure (point here) unless the author says otherwise
    boss child         sense: boss engaged/killed (name PICKED from the run) · when true:
                       say the boss note · next: advance or set stage N
    modifiers          once · no stage restriction

## 3b. The naming law for the drop-downs (Battlewrath, 2026-08-17)

**The author is someone just getting used to it. Every verb in a drop-down must be
SELF-DESCRIBING, not technical-leaning.** *While in · seen · come here · say a note · let the
arrow go · advance · set stage · boss killed · falling* pass. *Once · latch · edge · level ·
hysteresis · activate · trip · satellite · completor* fail — those are ours in the code, never
the author's in the pane. Two-sides principle applies (expressions §4): the pane speaks the
author's side; the code may keep its own words underneath.

**Requirement that follows (Battlewrath): an ADAPTOR SURFACE — one lookup table, `code : user`,
in the documentation.** Agents write and reason in the code word; every pane renders the user
word by lookup; a rename is a one-row edit; no one translates in their head. The table IS the
reference for both sides (same law as the WA index: one vocabulary as source, translation as a
file not a habit). Seeded from expr_self E5 (candidate words already on file) once the naming
pass runs. **And it is VERIFIABLE (Battlewrath), most usefully on the user snippets:** (1) every
user-visible string in a pane resolves through the table — no stray literals, a grep-able rule
in the same spirit as the bench's interface-file checker; (2) every code term that reaches a
pane has a row; (3) the user column is reviewed against the naming law (§3b) — one column read,
not every pane.

## 4. What this fixes, and what it leaves

    FIXED   the object model (beacon / child) · three drop-downs per action · the contents
            of each (from the journey) · defaults · the two-sides principle for naming
            (reader-word / author-word — expressions §4)
    LEAVES  the NAMES in the drop-downs (S3: vocabulary audit follows) · the surface
            (which pane, which tab order — the overhaul's first pass) · anything not in
            the journey

## 5. The four holes it must give the editor FIRST (from the journey)

**ORDER RULED (Battlewrath, 2026-08-17): BEACON AND AUTHORING first** — the holes land on the
object panes (childless reach · note field · boss child + the run's name list) — **then the TEST
DRIVER.** The ADAPTOR TABLE runs alongside as the drift-catcher: inventory current code terms
into the `code` column as each is touched, correct drift there, THEN free the `user` column for
the author's words. Both sides get done inside the sprawl — no full rewrite.
    G1  a note field (the "say a note" entry has nowhere to live)
    G2  reach on a childless beacon (the default sense has no field)
    G10 a boss child kind + the run's engaged-name list (the picker)
    C-4 the per-stage pin trace in capture (so the walk / test driver can replay "point here")

---

_This is the model the capture spec is written against next (sequence: programmatic model →
capture spec → new samples). The Analyst's earlier three-column proposition is superseded by this
form — same shape, arrived at from the author's side, with "when true" and "next" separated._
