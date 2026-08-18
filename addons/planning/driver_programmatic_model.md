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
    - **the FIRST CHILD ACTS AS THE BEACON (Battlewrath, 2026-08-18):** when a beacon gains
      children, its tabs move to child 1 — the default lure and the note offer when the stage
      matches. It ROUND-TRIPS: child 1 is the LAST DELETE (with siblings present it cannot be
      removed — told, per S4); when it goes as the last child its tabs RETURN TO THE PARENT,
      which is childless again and behaves as its own single child. Same tabs, two homes, one
      at a time — the childless beacon is not a special case, it is the state you return to.
      **The one thing SHED on gaining children is STAGE COMPLETE** (`set:` / `advance`): that is
      an ANY-CHILD choice, placed by the author in whichever child's what-I-do (one or several);
      the parent holds it only BY DEFAULT when childless, and takes the default back on return.
      **Why (Battlewrath): TASTE, not mechanism** — the PARENT is the BIGGEST node (the scene);
      when mapping elements out you want DISCRETE, SMALLER nodes to place, and those are the
      children. A big marker sitting on the entry way is in the way — so the functional
      placement (lure, note) lives on child 1, small and precisely positionable, and the big
      parent stays management. Recorded so no one re-derives it as a rule of the machine.
      (First written the wrong way round; corrected the same turn.)

**CHILD**
    - location when minted      the read it was spawned from (never invented)
    - location current           after free placement (S1) — z inherited, band tolerates
    - identity / alias           its name to the author
    - appearance                 icon / presentation
    - behaviour = the SUM of its actions; **actions as tabs, one tab per action**
    - **ordinal within the beacon's CHARACTER** (Battlewrath; "identity" was the earlier word — identity is the minted id, intrinsic; the ordinal is mutable = character) — stored, filterable: which child
      is first (the lure by default), which is next in a chain, which tab-set is live.
      **C10 RESOLVED (Battlewrath): beacon and child have SEPARATE identities, joined by a colon.**
          Beacon 4.1                  a beacon on the stage line (inserted between 4 and 5 — the
                                      model's meaning stands)
          Child of beacon 4.1:1 · 4.1:2 · 4.1:3 · 4.1:3.1   children under it; fractional
                                      insertion works on both sides of the colon
      The full path (`4.1:3.1`) is the identity and resolves nowhere else in the route. Nothing
      renumbers. (The advisory's "4.1 = a child" reading is withdrawn.)
      **Two guarantees at the colon (Battlewrath, 2026-08-18):** RID uniqueness cannot be
      promised across authors — so IMPORT RE-MINTS THE RID and nothing else; WITHIN a route,
      uniqueness is the AUTHOR's — every `BID:CID` is unique or it fails, and that failure is
      part of authoring (told, never silently repaired; A2.3's shape). Each held by the party
      that can hold it.

## 1b. The four kinds, and what governs each one's listening (Battlewrath, same day)

    Beacon · childless · ORDINAL       a stage on the line — the everyday unit
                                       ← position + the general stage (ratchet / maxSeen)
    Beacon · childless · NON-ORDINAL   outside the sequence — recovery / boss beacon (set:stage)
                                       ← position + general stage; never advances by order, SETS
    Child  · NON-ORDINAL               satellite / funnel sensor under a beacon — any order
                                       ← position + its beacon being current
    Child  · ORDINAL  = a STEP         a stage WITHIN a stage. **RESTATED (Battlewrath,
                                       2026-08-18 — best working model): a step is the SAME
                                       OBJECT as a childless beacon — default lure (come here,
                                       arrow, note), sense reach-here, what-I-do advance to the
                                       next step. It POINTS AT ITSELF. Order is the ORDINAL ALONE
                                       (the sub-ratchet: step n satisfied → step n+1 listens);
                                       no edge to draw. `goTo` is RETIRED — it split pointing
                                       (at A) from sensing (at B) with no default, and
                                       contradicted only-lures; its checks (Heads / BrokenLinks /
                                       Cycles) go with it; the advisory's `activate` was goTo in
                                       a new word (history). Step 1 = the first child (acts as the
                                       beacon); the last step's advance is the beacon's
                                       completion unless the author placed completion elsewhere.**
                                       ← the child ordinal: previous satisfied → this one listens
    CHILD 1 IS THE LURE AND CAN BE STEP 1 (Battlewrath, 2026-08-18): entry and step 1 are
    ordinarily the SAME node — the lure child carries ordinal 1. Co-location is only for the
    rarer case where the lure is kept separate from step 1 and both should fire: same spot —
    reached, sensed, fired. "Find the next break" is the stage-level lure's job. Position
    expresses the intent; no edge, flag, or activate.

The store's filter set is therefore small: `(position, stage)` for the first three kinds;
`(position, stage, child-ordinal)` for the fourth. Nothing else is needed to know who is awake.

## 2. The action pane — SENSE (the player) + WHAT I DO (a stack of rows) — *was* three drop-downs
_The third drop-down ("what happens next") was WITHDRAWN (RI-5) and boss left the sense list
(RI-15, 2026-08-18). The two ★ blocks below are the current shape; older text under them is kept
for the reasoning and carries its supersession where it disagrees._

> **REFRAMED (Battlewrath, 2026-08-18, RI-5 — best working model; the layout below is read
> through this):** POSITION is the NODE's (dragged on the map), not on this pane. Per tab, three
> things: **SENSE** (when am I sensing the player: reach here + distance · ~~boss engaged ⟨name⟩ ·
> boss killed ⟨name⟩~~ [⚠ SUPERSEDED (RI-15 settled, 2026-08-18): boss is NOT a sense — the ★ block below] · ~~falling · in combat~~ [⚠ SCRUBBED (RI-17, 2026-08-18): gates, not senses] …) · **WHAT I DO** as an OPEN/CLOSE pair — **DURING**
> (whilst on) | **WHEN OFF** — actions: update note · set supertracker · advance stage · set
> stage · **IF SEEN** (once | every time), a separate control. Step-on / still-on is not a field:
> during begins when the sense becomes true and holds while true; when-off runs when it stops;
> once = if seen. G15 (`while`) is this pairing. Two thresholds on one anchor = two tabs → two
> steps in the flat form (Analyst Q1, stands). **RESOLVED (Battlewrath, same day): there is NO
> separate "what happens next" and NO beacon-level "next" over children.** (a) A beacon-level
> next exists only for a CHILDLESS beacon, which is behaviourally its own single child; with
> children the beacon is not in play — its children carry the actions. (b) "What I do next"
> cannot be a true option for both types: time exists only for the stood-on-me-or-not type
> (a during, then an off); for the stepped type the step IS the next moment. So advance / set
> stage are ACTIONS in what-I-do, and the third drop-down below is WITHDRAWN. The pane is
> exactly three: SENSE · WHAT I DO (during | when off) · IF SEEN. The all/any selector, if it
> survives, applies to a childless beacon's own tabs only.

> **★ REFRAMED AGAIN (Battlewrath, 2026-08-18, RI-15's drain — best working model; reads OVER
> the RI-5 block above where they differ):** **SENSE is the LOCATION and the BEHAVIOUR WHILST IN
> ITS R** — *am I inside this radius, and what am I doing while I am in it*: on me = DURING ·
> touched me = SEEN. [⚠ SCRUBBED (RI-17, 2026-08-18): I had written *"falling, in combat, alive, mounted — only what
> the client reports about the player"*; Battlewrath: *"Not in-combat or whilst falling. Those would
> live in the wider logic that needs something that gates on combat to be a condition."* State
> predicates are GATES, not senses — candidates for a row CONDITION if ever, no sense address.]
> **Boss is NOT a sense.** *"While (duration) is
> the arming to listen to CLEU, and boss is the CLEU."* So: **WHAT I DO = "when the player is
> here" — a STACK of rows, each an ACTION with an optional CONDITION** — *give a note · advance
> (update the internal step) · set stage · set the supertracker · use /say · and so on* (an OPEN
> list, named as they land) — ~~and the condition is *on: boss ⟨name⟩ engaged | boss ⟨name⟩ killed*
> (default: immediately)~~ [→ GRAMMAR (RI-17): a row is one declaration `<sense>:<action>:<arg>` — no condition field; the boss pair is the ACTION word `boss` + the name ARG]. The whole stack is SCOPED by the sense: **"what you do only has
> meaning when you're in the location to do it."** A boss child therefore reads: *sense: here
> (during) → what I do: advance, on boss ⟨name⟩ killed* — the listener is armed only while the
> player is in the arena; a wipe and re-entry re-arms; nothing advances on leaving, because the
> KILL is the trigger, not the off-edge. Decision load unchanged (the child is already AT the
> arena; reach at default; the author still answers the name and the action). WHEN OFF and IF
> SEEN untouched by this turn. §2c below is the DRIVER's implementation of the condition and
> stands, with arming = "while the sense holds". ~~Adaptor: `boss engaged/killed: ⟨name⟩` are the
> condition's values~~ [→ RI-17: the adaptor row is the action word `boss`; engaged not offered], still one question with the name in the answer.

> **★ THE ROW, settled (Battlewrath, 2026-08-18, same drain, three turns later):**
> **a WHAT I DO row = CONDITION + ACTION (+ an optional INLINE STAGE END)** [→ READ THROUGH THE GRAMMAR (RI-17): a row is ONE declaration `<sense>:<action>:<arg>`; "condition" and "inline stage end" were the interim wording — the action function carries its own condition and completion; a stage set is its own row (`Seen:Set:N`) or the boss function's completion]**, and every row is
> SELF-COMPLETING** — no "then" between rows, no row satisfying another (that is the graph, and
> a chain has a half-done state the moment the player moves). *"An update note is a step. A
> kill-a-boss is a step. A set is a step. So set / ratchet can be a stand-alone act, OR the end
> of the what-I-do as an inline end."* ["step" here in the plain sense; RESOLVED below: step = the ordinal child; actions are actions] The stage change is the ONLY tail a row may carry, and it
> is bounded: it completes itself through the stage machinery — the new stage's ENTRY LURE
> points the arrow at its first child whether or not the player is still where the row fired,
> and the fired tab's stage has passed so its WHEN OFF cannot fire late. The stale-arrow case
> is closed by construction. **Fields depend on the choice**: a kill condition shows the name
> picker; set stage shows N; advance shows +N (default 1).
> **The author's boss condition is KILLED only.** *"There is no interest in knowing you're in a
> fight without killing it"* — the arena sense already gives the about-to-fight moment (sense:
> here → give the note, immediately), so *engaged* is redundant on the pane; it survives, at
> most, as a driver-side arming witness in §2c, never offered.
> **A kill row DEFAULTS to a stage action — route recovery**: *set the stage to this beacon's
> NEXT, absolute, computed from the node's own stage, never from where the driver currently
> thinks it is* — so it recovers a lost reader by construction (scoping S6's recovery beacon,
> "Boss killed → set:stage(N)", is this default). *Advance +N* (the ratchet, relative) is
> offered beside it. **Naming, RESOLVED (Battlewrath, same day): "step" = the ORDINAL child —
> *"a minor stage, a small gear"*. Actions are NOT steps; the pane's word for a row is the naming
> pass's (his own: "action tab"). A child WITHOUT an ordinal is still allowed — the UPDATE type
> (satellite: live whenever its beacon is, no place in the sequence), the same as a beacon can
> be an update/presence beacon.**
> **★★ THE DECLARATION GRAMMAR (Battlewrath, 2026-08-18, RI-17's drain — the bench's structure,
> which he took: "which I like"):** a WHAT I DO row IS one declaration, three terms —
>
>     <sense: the location function> : <action: the what-I-do function> : <arg>
>
>     When on:boss:Gul'dan        on me (during) · the BOSS function · the name
>     Seen:Note:<content>    touched me (seen) · the NOTE function · the note text
>
> (The sense-words are the FLOOR words, and there are THREE — **WHEN ON** (= while in) · **SEEN** ·
> **WHEN OFF**, the third named the same day, below; §3b's list is updated to match.) The first term is the behaviour whilst in the node's R (**When on** = on me / during · **Seen** = touched
> me). The second is an ACTION FUNCTION the driver holds — the author states its
> OUTCOME, never how: *boss* = "open CLEU, read for the arg name, complete the stage / N when
> done". The third is that function's argument. **In-combat, falling, encounter are what a
> function is CONSTRUCTED OF — inside it, where they help answer the call** — never a term. So
> there is NO separate condition field: the action function carries its own condition and its own
> completion; the row is stored WHOLE as this triple (RI-17 (a), answered by the grammar); the
> export carries the triple; the driver reads it whole. Fields on the pane depend on the action
> word (boss → the name picker; note → the text; set → N). The kill's recovery default (set stage
> = this beacon's next) is the boss function's completion when no N is given.
> **PRECEDENCE (Battlewrath, same day): the node's CONSTANT (ratchet the step on completion)
> collapses INTO this grammar as the default; an AUTHORED stage action on the child — `Seen:Set:4`,
> or the boss function completing to N — WINS over the child's own step completion.** The two never
> fire together: *stage 3 → 4* is proper; *stage 3 → 4 AND stage 3: step 3 → 4 at the same time*
> is improper. A stage change supersedes the ordinal hand-off (the step ratchet is moot once the
> stage has moved). **WHERE THE CONSTANT LIVES (Battlewrath, same day): NOT as a WHAT I DO row —
> it is part of the child's CHARACTER, in the ORDINAL input.** (His three layers, restated the same
> day: **IDENTITY is intrinsic** — the minted id · **CHARACTER is mutable** — ordinal, alias,
> appearance, current place · **BEHAVIOUR is a set of actions together** — the WHAT I DO tabs.)
> A child with an ordinal is a step,
> and a step ratchets on completion by construction; the pane shows no row for it. Acceptance A2.7.
> **THE STAGE NEVER WAITS FOR ALL ITS CHILDREN (Battlewrath, same day): five children, two with no
> ordinal, three in the ordinal — the stage completes when it is TOLD (an authored stage action)
> or when the ORDINAL RUNS DRY (last step done → the beacon's completion default). Update-type
> children never gate completion. The CHILDLESS beacon is the limit case: an ordinal of zero runs
> dry at its own completion — its self-complete is the same rule with nothing to wait for.
> Acceptance A2.8.**
> **WHEN OFF IS THE THIRD SENSE-WORD (Battlewrath, same day: "for pressure off, we need to be able
> to define what that action is").** So the first term is one of **WHEN ON** (= while in, on me) ·
> **SEEN** (touched me, once) · **WHEN OFF** (pressure off — I have left the R). His four tabs on one
> child:
>
>     tab 1   When on  : Note : <text>
>     tab 2   When on  : Boss : <name>
>     tab 3   When off : Note : <different text>
>     tab 4   When off : Supertrack : <waypoint>      → the arrow moves ON as I leave
>
> *"The first waypoint was satisfied the moment they stood in the lure R"* — the lure completes on
> arrival; what points onward is a WHEN OFF row. Each row is a tab (his word); A2.7's ALL reads
> over when-off tabs too — a step with a when-off tab completes when the player has come AND gone.
> ~~⚠ OPEN, not invented: WHEN OFF (leaving) has no sense-word yet~~ ANSWERED — While and Seen are the two
> named; and where an explicit N rides (a second arg, or the default only) is unstated.

> **TWO WORDS SETTLED (Battlewrath, same day):** the IF SEEN control is labelled **TRIGGER**, a
> dropdown *One time · Every time* (so *Seen* is only the sense-word); and `ratchet` is not a
> control — it is the explanation ("can't regress") behind the labels **Next stage** (+N field)
> and **Next step**, each a label with a field beside it. Adaptor rows filed.
> **A CHILD COMPLETES WHEN ALL ITS ACTION TABS HAVE COMPLETED — a CONSTANT, not a control**
> (Battlewrath, same day: *"should that be a constant defined on the UI?"* — yes). Note tab
> fired + kill tab pending = the child is NOT complete and the ordinal does not hand off; the
> kill completes it. *"Two tabs means both need to satisfy."* The NODE's constant on
> completion is the STEP only (set / ratchet the ordinal); a stage change is never the node's
> constant — it is authored on a tab as that tab's inline end (set stage N / ratchet +N) [in the
> grammar: its own row `Seen:Set:N` / `Seen:Ratchet:+N`, or the boss function's completion]. Acceptance A2.7.

**Refined to the WeakAuras shape (Battlewrath, same day): EACH TAB IS A TRIGGER. A beacon is
SATISFIED when its triggers — each tab — have been satisfied** (All by default; Any as WA's
other combination). [⚠ SUPERSEDED (RI-15 settled, 2026-08-18): on a CHILD/STEP, ALL is a CONSTANT with no control (A2.7); any/all
survives, if at all, on a CHILDLESS beacon's own tabs only.] Consequences, and they simplify what follows:
    - no AND inside a tab: the skip is TWO tabs — one sensing *falling* [⚠ SCRUBBED (RI-17, 2026-08-18): falling is a
      GATE, not a sense — the skip's discrimination, when built, is a gate on the row], one sensing *reach at
      the landing* — and the beacon satisfies when both have.
    - ~~"what happens NEXT" belongs to the BEACON, not the tab: satisfaction is one event, so
      advance / set stage / return-to-maxSeen happen ONCE, at the beacon~~ [⚠ SUPERSEDED (RI-15 settled, 2026-08-18): the node's
      constant on completion is the STEP (ordinal) only; a stage change is AUTHORED on a tab as its
      inline end, never at the beacon] (`activate` struck
      2026-08-18, RI-7: it stored another node's identity — outward pointing, retired with goTo).
    - a tab keeps its SENSE and its WHEN TRUE (say a note · point here · let the arrow go).
    ~~So the form is: per tab — sense + when-true; per beacon — combination (all | any) + next.
    The three-drop-down layout below still reads correctly if "next" is read as the beacon's.~~
    [⚠ SUPERSEDED (RI-15 settled, 2026-08-18; sense = location + behaviour in R per RI-17): per NODE — one SENSE; per ROW — condition + action + optional inline
    stage end; no "next".] **The combination selector sits ABOVE THE TAB LINE (Battlewrath): all (and) / any (or)
    across the beacon's tabs, offered from v1; default all.** [⚠ SUPERSEDED (RI-15 settled, 2026-08-18): NOT on a child — ALL is a
    constant (A2.7); a childless beacon's own tabs only, if it ships.] WA's placement, WA's two options.

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
    │  ~~STATE      in combat / not in combat  · falling / landed  · alive / dead~~  │
    │  ~~· mounted~~ [⚠ SCRUBBED (RI-17, 2026-08-18): NOT senses — GATES in the wider logic (a row  │
    │  condition if ever); the client-reports bound still applies to any gate]      │
    │  ~~EVENT      boss engaged (name from the run) · boss killed (name from the run)~~│
    │  [⚠ SUPERSEDED (RI-15 settled, 2026-08-18): boss is the what-I-do ROW's condition (killed only), not a sense]  │
    └──────────────────────────────────────────────────────────────────────────────┘
    [⚠ SCRUBBED (RI-17, 2026-08-18): STATE is not a sense — the skip's falling discrimination is a GATE inside a
    function when built; the second box below is the RI-5-era "when true" list, absorbed into the
    WHAT I DO rows (grammar block above).]
    Combining is AND only (position AND state) — WA's "all triggers"; nothing computed across.
    Battlewrath's example, the SKIP: sense "player is falling" AND "landed within reach of the
    place we set as the landing" → next: advance, stage 3. Robust for free: excludes someone
    walking underneath, because they were not falling. (Capture must record the state per row
    to replay it — in-combat is captured; falling is not yet: a capture-spec item.)
    ┌ SELECT WHAT HAPPENS WHEN THE SENSE IS TRUE / ACTIVE ────────────────────────┐
    │  point here (come here)   · say a note (≤ ~200)   · let the arrow go (close) │
    │  (nothing — sense only)                                                      │
    └──────────────────────────────────────────────────────────────────────────────┘
    [⚠ SUPERSEDED (RI-15 settled, 2026-08-18) and RI-5: this third box is WITHDRAWN — advance / set stage are ACTIONS in the
    row stack, self-completing; kept for the reasoning only]
    ┌ SELECT WHAT HAPPENS NEXT ───────────────────────────────────────────────────┐
    │  advance (stage complete)  · set stage N  · return to maxSeen                │
    │  nothing (stay)      [`activate <child>` STRUCK — RI-7: outward pointing; the      │
    │  ordinal sub-ratchet is the hand-off; a satellite jumping the chain, if ever      │
    │  needed, is `set step N` — a NUMBER, not an identity]                             │
    └──────────────────────────────────────────────────────────────────────────────┘
    ~~+ modifier on the tab:  only at stage N (optional)~~ [→ RI-17: a row is exactly three terms; no modifier field]
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
_⚠ SCRUBBED (RI-17, 2026-08-18): *falling* below is a GATE, not a sense (a row condition if ever built). ⚠ SUPERSEDED (RI-15 settled, 2026-08-18): the GRAPH form below is gone — `activate` retired (RI-7), and no row satisfies another
(rows are self-completing). Only DISCIPLINE stands: two tabs under one sense discriminate. Kept
for the reasoning._

    BY GRAPH        child 1 at the ledge: tab = reach here · when true = point here, lets go
                    on reach · beacon next = ACTIVATE child 2.  Child 2 (deaf until then):
                    tab 1 = falling · tab 2 = reach at the landing · next = advance (+N).
    BY DISCIPLINE   no edge. Both live under the beacon from the start; child 2's two tabs
                    discriminate on their own — nobody satisfies falling AND landed-here by
                    walking past — so it never false-fires.

**Rule of thumb that falls out: the graph is for when the senses alone cannot tell the intended
arrival from an incidental one; where a STATE sense discriminates, discipline suffices.** Both
are authorable; the author picks by how much the senses already say. And `advance` takes a
parameter — by N, default 1 (his `set:stage:ratchet(+N)`) — beside `set stage N`, absolute [in the
grammar these are the action functions `ratchet` (+N) and `set` (N)].

## 2c. The boss beacon, as tabs (Battlewrath, 2026-08-17 — not in yet, recorded)

    tab 1  LOCATION      reach at the place the boss is fought (a read from the run)
    tab 2  PUSH TOKEN    boss engaged — the game's event + name from the run
    above  ANY           either witness ARMS the CLEU listener for that name:
                         `listen(UNIT_DIED, name)` (acceptance A3.3 — the function's
                         signature is the guard; no name, nothing arms)
    next   the KILL      UNIT_DIED on that dest name satisfies → advance / set:stage

Arming is generous (you are there, OR the game says it is on) [⚠ CORRECTED by A3.5 (RI-15, 2026-08-18): the
listener is armed only WHILE the child's sense holds — ONE door in; the engage token is at most
an internal witness of the boss function, never a required one]; satisfaction is strict (the named
death). ~~Two doors in~~, one door out. Both arming senses come from the run's record; the listener
is one dest name — inside the bounds by construction.

**⚠ CORRECTED (Battlewrath, 2026-08-18): the tabs above are the DRIVER's implementation, NOT the
author's surface.** The author has ONE question per intent, and the boss NAME is its parameter,
not a separate step: **"boss killed: ⟨name⟩ → advance"** · ~~**"boss engaged: ⟨name⟩ → say the boss
note"**~~ [⚠ SUPERSEDED (RI-15 settled, 2026-08-18): ENGAGED is not offered — the arena sense gives the note moment: *sense: here →
give the note, immediately*] (journey line 9). Location-or-token arming, the two witnesses, the listener — all of that
is how the machine tracks once the author has picked; none of it is authored, none of it reaches
a pane. The picker is not a term; it is how the name enters the sense. (The adaptor table's three
boss rows — `bossEngaged` / `bossKilled` / `boss` — asked the author to define one question as
three mechanical steps; ~~two senses each carrying a name is the surface~~ [⚠ SUPERSEDED (RI-15 settled, 2026-08-18): ONE condition on a
what-I-do row — *on boss ⟨name⟩ killed* — is the surface; the sense is the player's presence].)

**The push token arrives at the DRIVER, not at an instruction (Battlewrath).** The consumer keeps
BACKGROUND PROCESSES that serve the armed instructions: an event frame standing for the game's
pushes (engage · death / alive), the throttled position tick, and CLEU armed per boss instruction
with its name. Instructions do not listen; the driver listens and ROUTES what it hears to whichever
instructions are awake — WA's shape (events set flags, one pass drains; index by event, O(1)
miss). Every background process is TWO-WAY — registered on arm, unregistered on disarm — or it is
not non-invasive (neighbours §5: every WA/DBM hazard was a one-way edge).

## 3. Defaults — the author configures nothing to get a working route

    childless beacon   sense: reach here · rows: `When on:Supertrack:here` (the lure) · completion:
                       ratchet (its constant; ordinal of zero runs dry at its own completion — A2.8)
                       [was: "when true: point here · next: advance" — RI-5/RI-17 wording]
    band + radii       (RI-2, 2026-08-18) ±2.5 and the default radii apply when the author sets
                       nothing; the pane shows a SLIDER the author TICKS to change, with light
                       text ("changes the height of detection"); the same control shape for
                       radius:listen (come here) and radius:sense (found). Raw read = nil when
                       unset; the consumer resolves the default (acceptance A1.3).
    first child        = the lure (point here) unless the author says otherwise
    boss child         (RI-15 settled 2026-08-18) sense: here (during) · what I do: give the boss
                       note IMMEDIATELY (the arena is the about-to-fight moment) · set stage = this
                       beacon's NEXT (absolute, from the node's own stage — recovery) ON boss ⟨name⟩
                       killed — the name PICKED from the run; boss is the row's CONDITION, not a
                       sense; ENGAGED is not offered
    modifiers          once · no stage restriction

## 3b. The naming law for the drop-downs (Battlewrath, 2026-08-17)

**The author is someone just getting used to it. Every verb in a drop-down must be
SELF-DESCRIBING, not technical-leaning.** *When on (while in) · seen · when off · come here · say a note ·
let the arrow go · advance · set stage · boss ⟨name⟩* pass [⚠ SCRUBBED (RI-17, 2026-08-18): *boss killed* → the action word
*boss*; *falling* is not a term — a gate inside a function]. *Once · latch · edge · level ·
hysteresis · activate · trip · satellite · completor* fail — those are ours in the code, never
the author's in the pane. Two-sides principle applies (expressions §4): the pane speaks the
author's side; the code may keep its own words underneath.

**The boundary the table sits on (Battlewrath, 2026-08-18): the instruction is the author's
ANSWER; the driver calls its own functions on it to realise it.** An instruction never becomes a
per-line guide to how a boss is detected and killed — it says "boss killed: X" and the driver
knows which functions that calls. So the table carries the QUESTION LAYER only — the terms an
author meets. **Not every function needs a label. A question is the end product of how a
function would answer.** Arming, witnesses, listeners: functions, unlabeled, never in a pane.

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

## 4b. Two kinds of note — de-conflated (RI-10, 2026-08-18)

    PERSONAL note    EXISTS in code (`NotePlane` / `AddNote` / `GetNotes`, `Store.NoteTable`)
                     and in rulings §60/§61; on the promoter's surface above the divider.
                     A MAP PLANE keyed by mapID · YOURS · needs no route · NEVER travels
                     (routes.lua:1408: "NOT PART OF A ROUTE, and that is the whole point").
                     **SCOPED (Battlewrath, 2026-08-18) — what it is and why it exists:**
                       WHO    a player who uses BOTH addons: written in Dungeon Run (the map),
                              shown by Dungeon Routes during runs.
                       WHAT   persistent notes across route runs, per place, SPECIFIC TO THEIR
                              ROLE AND CLASS — "healer: the mobs here DoT hard", "DPS: kick
                              that unit", "I need to taunt from here". Experience, not route.
                       WHERE  a DESIGNATED SLOT during runs, separate from the route's note
                              slot: while the route says "do X" on this leg, the personal
                              slot says what THIS player normally faces here.
                       HOW    shown by position (the map plane keyed by mapID + place; the same
                              fixed reach mechanism, a different plane, a different slot);
                              the reader can turn the slot off (non-invasive).
                       POINT  a personal note MAY drive the supertracker by an EXPLICIT act
                              ("I need to taunt from here") — and THE ROUTE OVERWRITES IT in
                              its sequence (last write wins; the route's lure re-points).
                              A manual, transient push; always yields to the route.
                       WHY    this is how routes become LESSONS LEARNED — a personal layer
                              that accumulates across runs — while staying OFF the consumer
                              path for authoring and maintaining: not route content, not
                              shared, not exported, maintained by the player alone.
                       NEVER  travel · count as route content · be a mechanism the driver
                              depends on · reach the route note slot.
                     Its authoring lives in Dungeon Run (the map); its display lives in Dungeon
                     Routes (the slot). Two planes, two slots, one reader.
    ROUTE note       G1 — the author's, for whoever runs the route; keyed to a CHILD by its
                     address; part of the route; TRAVELS (RI-4: notes survive). Referenced in
                     the store, owned in the pane (RI-1). **DRAINED (Battlewrath, RI-10): its own
                     SHELF — the route note plane, a separate table under the personal one
                     (§60); export takes it whole and never the personal one. WORDS: "personal
                     note" / "route note" — "reader" rejected because a reader is anyone reading
                     either, author or consumer alike. The LABEL the author sees is **"Route
                     instructions"** — one row in the adaptor: term `route note` → label "Route
                     instructions" ("note" reads as an author dev-note slot on first read;
                     "instructions" says what the player running it gets told); "Personal note"
                     stays. Ghost text under it: "Instructions for the player running the route".**
    They agree on nothing but the noun; the noun is why they collided the day G1 came up.

## 5. The four holes it must give the editor FIRST (from the journey)

**ORDER RULED (Battlewrath, 2026-08-17): BEACON AND AUTHORING first** — the holes land on the
object panes (childless reach · note field · boss child + the run's name list) — **then the TEST
DRIVER.** The ADAPTOR TABLE runs alongside as the drift-catcher: inventory current code terms
into the `code` column as each is touched, correct drift there, THEN free the `user` column for
the author's words. Both sides get done inside the sprawl — no full rewrite.
    G1  a note field (the "say a note" entry has nowhere to live) — RI-9 (2026-08-18): the tie
        with scoping S8 ("note actions out of v1") was called, and Battlewrath REVERSED S8 as
        a reversal the same day: notes are IN v1. G1 stands here; RI-1's shape (referenced in
        store, owned in pane) applies; acceptance A4 as written.
    G2  reach on a childless beacon (the default sense has no field)
    G10 the boss ACTION word on a what-I-do row (`When on:boss:⟨name⟩`) + the run's name list (the picker) [RI-15/17]
    C-4 the per-stage pin trace in capture (so the walk / test driver can replay "point here")

---

_This is the model the capture spec is written against next (sequence: programmatic model →
capture spec → new samples). The Analyst's earlier three-column proposition is superseded by this
form — same shape, arrived at from the author's side, with "when true" and "next" separated._
