# ARCHITECT_LOG — outcomes and reasoning, so `ARCHITECT_INBOX.md` stays input

_Opened 2026-08-21. One entry per resolved question (from the inbox) or per design decision taken
with Battlewrath in conversation. **Each entry: the question · the outcome · the reasoning · what it
cites · where it LANDED (the governing doc that now carries it) · whose word it was.** The log never
carries the ruling's body — that lives in the doc named under "landed"; the log is why, and where.
Read newest first._

    ENTRY FORM    AL-N · date · from (inbox AI-N | conversation) · QUESTION · OUTCOME · REASONING ·
                  CITES · LANDED IN · WORD (Battlewrath | architect, with the rule applied)

---

## AL-21 · 2026-08-21 · inbox AI-9 (Analyst, closing RI-49) — `Next` is a field the store owes; what `role` is
- **QUESTION** RI-49 had four readings and no measurement. Now measured: `contract.lua` DECLARES
  `nextType`/`nextArg` on the characteristic record; `routes.lua` has neither (it has `ROLES =
  {start, update, complete, set}`, `child.role`, `child.setStage`); `bucket.lua` carries neither;
  `Manager.NodeDone` reads only `lone` and `step`. Proposal: `Next(Type, arg)` is a field the store owes
  and does not have; `role` + `setStage` are not that field under another name — editor-side, and they
  stay. Yes / no?
- **OUTCOME** **YES on the substance** — `Next(Type, arg)` joins the store (the declaration exists), gets
  an authoring door (the Next picker, A2.9: Step · Stage · Set N, the offer following what exists), and
  `NodeDone` gains its one branch; §4b's recovery escapement (`Set N` on the tray) becomes authorable.
  **ONE CORRECTION to the reading:** `role` is not "a separate concern that stays." It is the OLD PANE's
  spelling of what the new model expresses through Next and the ordinal — `complete` = "my Next is
  Stage", `set` + `setStage` = "my Next is Set(N)", `start`/`update` = positions (ordinal 1 / no
  ordinal). It is editor-side and LIVE only because the old pane reads it through `AcceptanceOf`, and
  A10.2a already lists `role` among the controls A10.3 REPLACES. So: it stays until the replacement
  lands, then the store hook MIGRATES it deterministically into Next and the ordinal, told — it is
  never a second vocabulary kept beside the first. The Analyst's own check ("it is read") was right
  to stop the removal; the reason it is read is the reason it is temporary.
- **REASONING** the no-second-copy law: two fields for one fact (`role=complete` and `Next=Stage`) can
  disagree. The Analyst's reading B describes the code today; L17's reading describes where the field
  belongs; both are true, in sequence. `bucket.lua` re-implementing `AcceptanceOf`'s rule instead of
  calling it (one rule, two bodies) is the bench's, as filed.
- **CITES** AI-9 · RI-49 · `contract.lua` CHARACTERISTIC · A2.9 · A10.2a · AL-4 (the picker) · AL-18
  (the tray-0 seed needs an authored Set N).
- **LANDED IN** RI-49 (drained to this) · architecture §4d (Next on the surface; `role` named as the
  replaced spelling) · the bench: `nextType`/`nextArg` in the store, the door, the `NodeDone` branch, the
  migration mapping · the Analyst: A12 rows for Next's three types and the migration.
- **ADDENDUM (Battlewrath asked whether "how does a step-0 child complete without pushing a step"
  showed in this text — it did not; folded now):** RI-49's later half, the bench's landing at his ask
  (§479), is TAKEN as the rule — `Next` ABSENT is NO OUTCOME, the default DERIVED from position (ordinalled
  → Step; zero node → nothing follows; explicit → the instruction); no fourth word, no degenerate Set;
  the manager records the derived decision. ⟶ It CORRECTS AL-18's "tray-0 seed incomplete until Next is
  authored": a zero node's absent Next is never Stage, so an unauthored tray-0 beacon is an updater and
  a recovery beacon is one given Set N. Architecture §4b corrected in place.
- **WORD** architect, applying A2.9 / A10.2a / the no-second-copy law.

## AL-20 · 2026-08-21 · inbox AI-7 (Analyst) — six stale build-state claims in the architect's files
- **QUESTION** nothing but the edit: the sensor row's today/owed split inverted (the owed half is
  built); G18 a stale BLOCKER; G19b citing a header note that no longer exists; G6's "fourteen
  refusals, none for this" (sixteen, one of them this); the basis's "nothing in the manager is built"
  (sixteen functions landed §461); three counts wrong the day they were typed; and the `AddBeacon`
  precondition quoting a source comment that lied (S7 landed beneath it).
- **OUTCOME** all six edited at their cites, each marked "(AI-7, re-measured 2026-08-21)". And the
  Analyst's read taken as the rule for these files: **a governing doc asserts build state only as a
  pointer to the checker that derives it** (`emit_built_state.py`) — the sensor row and the manager
  entry now say so; the three counts were REMOVED, not updated (a count decays the instant it is
  typed); the dead `routes.lua:474` comment is the bench's to remove. (The `ReachOf` "one production
  call site" claim lives in the Analyst's own files, not mine — theirs, already corrected.)
- **REASONING** the audit's own number: zero ghosts on the guarded axis (39/39 `grades` cites
  resolve) against ~31 of ~55 drifted line numbers on the unguarded ones — a guard beat a convention
  on one afternoon. The architecture's §3 status column was always meant to be re-measured at
  boundaries (§7); it is now derived on demand instead.
- **CITES** AI-7 · `audit/staleness_2026-08-21.md` · `sensor.lua` · `bucket.lua` · `manager.lua:1` ·
  `routes.lua:474-491`.
- **LANDED IN** architecture §3b (sensor) · §6 (G6, G18, G19b) · basis #12 and the RI-23 block · §7's
  standing rule.
- **WORD** architect; edits only.

## AL-19 · 2026-08-21 · inbox AI-8 (Creator, from Battlewrath's reading) — `supertrack` is a characteristic
- **QUESTION** Battlewrath: *"Way point can't be a choice via the sense / act / what to act. The super
  tracker is what gets the player TO the sense site. So if it is an option, it lives in the character,
  not behaviour."* The bench measured: a `whenOn:supertrack` row can only fire after the reader has
  arrived where it would have pointed them — incoherent since A2.6 made supertrack name only itself;
  and the manager already writes the entry lure (A12.3c), so two mechanisms did one job. Proposal: a
  node characteristic, a tick, default on. Open: per node, or a route-level default with override?
- **OUTCOME** **YES — and Battlewrath made it the GENERAL RULE, now L17: a capability sits in the layer
  where it has meaning.** `supertrack` leaves the closed action list (it shrinks — the safe direction
  for the security boundary) and becomes the node's **LED TO** tick: on by default; ticking off is the
  author's choice; **tray-0 nodes are UNTICKED and do not surface the choice** (recovery never lures —
  AL-6 from the other side). Per NODE. The "When on / When off to lure them back" argument
  *dissolved* in his words: *"that's to get the player back to a location, which the user can already
  do with re-pin stage. The mechanism is in user control, not keep luring them in."* The §471
  migration branch converts a stored `supertrack` row into the tick; the node takes the arrival seed.
  The action list is boss · note · say · open.
- **REASONING** the architect's framing, which he confirmed as the rule: behaviour is what happens
  when the player is HERE; a thing with meaning before the sense (getting them here) or after it
  (where the route goes next) is character. `set`/`ratchet` fell to it for firing too early (→ Next);
  `supertrack` falls to it for firing too late (→ led to). The seed gets cleaner: "no action" is purely
  reached.
- **CITES** AI-8 · A2.6 · A12.3c · RI-42 · AL-6 · AL-18 · `routes.lua:1267`.
- **LANDED IN** architecture §5 L17 · §4b (the tick, the dissolved argument, the migration) · §4d (LED TO
  in character; action list) · the bench: ROW_ACTIONS loses `supertrack`, the characteristic gains the
  tick, the migration branch, the tray-0 rule · the Analyst: A12/A13 rows (the manager reads the tick at
  entry; tray 0 never lures — already A11.9's) · data model row for the characteristic record.
- **WORD** Battlewrath.

## AL-18 · 2026-08-21 · inbox AI-6 (Analyst) — the seed row: a fourth sense-word? and what its action is
- **QUESTION** a beacon is placed before its behaviour is decided; AL-17 says a runnable node always
  carries a materialised row and an empty node is refused — so the seed must exist and must not stall.
  Q1: add a fourth sense-word meaning *satisfied as soon as the gate opens* as the seed's sense? Q2: what
  is the seeded row's ACTION — S1 "the pair is the unit" (a terminating sense carries no action, read
  from a declaration) or S2 a no-op verb in the closed list? Facing word already Battlewrath's: "Select
  a sense type" — a prompt, not a state.
- **OUTCOME** **Q1 NO.** The seed's sense is `When on` — ARRIVAL — because arrival IS the behaviour of a
  placed node: a stage is *"get you into the room"* (R8). "Nothing to wait for" describes no node we have
  (a lure, a recovery beacon, a skip's landing all wait for the player); a term for it would be an
  invention with no instance, and a placed node that completed the moment its stage opened would be a
  waypoint nobody has to reach. The closed set of three stands. **Q2 — S1's MECHANISM with a plainer
  meaning:** a row's ACTION is OPTIONAL — `When on` with no action means REACHED, and an action is what
  ELSE happens there; the arg guard runs only when an action is present (the same read-a-declaration
  shape as `ROW_ARG.supertrack = nil`, already shipped); no no-op enters the closed capability list. A
  row the author ADDS starts with its sense unset — the prompt — and is INCOMPLETE, told, until picked;
  the seed row is never unset, so the prompt never shows on a freshly placed node. The
  `routes.lua:1308` comment sits between two lists and names neither — the bench's, one blank line.
- **REASONING** the Analyst's argument that self-termination is about WHEN is right; the answer to
  "when" for a placed node is *when the player gets there*, which is a word we have. Adding a member
  to a closed set for a case with no instance is the extension-past-the-evidence shape; making the
  action optional adds no vocabulary and matches the model's own default ("sense: reach here · what I
  do: nothing · Next: Stage"). Everything else in AI-6 stands as filed: the facing word, the owed
  adaptor row, B4/B1/B3 independent.
- **CITES** AI-6 · AL-17 · R8 (a stage is a beacon) · A2.6's default · `bucket.lua:287` (ROW_ARG read) ·
  `routes.lua:1304-1320`.
- **LANDED IN** architecture §4b (THE SEED) · the Analyst: B0's content and B2's guard; an A-row for
  "added row unset = incomplete, told" · the bench: action optional in both doors; the comment re-seated.
- **FRAME (Battlewrath, same day, on reading this):** *"the waiting is the manager with a row that has no
  escapement when no instruction is set."* ⟶ the rule stated from the manager's side, and it is the one
  §4b now carries: every armed row carries its own escapement; the seed's is arrival; a row with no
  instruction has none and is never armed.
- **CHECKED AGAINST THE FRAME (Battlewrath: "does AL-18 solve that tension?") — PARTLY, then completed:**
  (1) added the missing sentence *a row with no action completes the instant its sense fires* — without
  it the seed had no escapement in the ledger's own terms ("a tab completes when its action finishes");
  (2) found the case it did NOT solve: a TRAY-0 seed's default Next (Stage → next present = stage 1)
  would reset a passing reader; so a tray-0 node is INCOMPLETE until its Next is authored (Set N) —
  told, refused at build. Both in §4b.
- **"Does the structure need a hidden escapement — an else, move on?" (Battlewrath) — NO:** a timeout or
  auto-skip is a false advance by construction and hides stalls; the escapements are visible and
  authored (per tab · per stage · the tray's recovery · the remote's correct-when-lost). Added the one
  sentence the question exposed: an Every-time row completes on its first fire; later fires re-run the
  action without touching the ledger. §4b.
- **WORD** architect; Battlewrath's facing word applied, not re-asked; his frame landed as the rule.

## AL-17 · 2026-08-21 · inbox AI-5 (Creator) — the posed payload, defined; the empty node; the arg's type
- **QUESTION** Battlewrath gave the behaviour ("in-bucket replace the flat form with the function-call
  handling, so when stage and step are true and the sense is met, the payload is already posed") and
  declined to let it be built from the giving: *"better is getting it defined upstream so we're not
  designing by flight."* After his own correction (three of five already answered by the data model),
  what remained: the CONVERSION (flat → rows: convert at build, or migrate once?) · the EMPTY NODE
  (refuse, naming it?) · and his SECURITY constraint — *"it could be a window for arbitrary code …
  owned by the user's own addon, not what the authoring addon states is capable"* — measured by the
  bench: the verb side holds (closed list), the arg side does not (untyped payload).
- **OUTCOME** **The posed tab is DEFINED** (architecture §4b): `{ address · gate · sense · fn · arg }`,
  one per behaviour record — the gate composed from the node (AL-10); sense from a closed set; `fn`
  the consuming addon's own callable, resolved through the closed list it publishes, the resolver
  consulted AFTER that check and never instead of it (the bypass the bench found is closed by
  definition); `arg` a typed VALUE, refused by name when not the declared type, the guard READING the
  declaration. Next and Trigger stay the node's; completion stays the ledger's. **The flat form is
  MIGRATED ONCE** by the store's hook, told — never converted at build — because `child.rows` IS the
  instruction set and the pane moves onto it at L1.4 (so L1.2/L1.4 is a migration). **The empty node
  is REFUSED at build, by name — YES, today**: it can never complete and stalls in silence, the exact
  class row 24 exists to prevent; defaults are materialised as real rows at authoring time so a
  runnable node always has one.
- **REASONING** his security line is the boundary the model already carried as an implementation
  note ("functions it already has") — written now as the rule: *travelling data NAMES a capability
  from a closed list the consumer publishes; it never supplies what it does.* The verb side was closed;
  the arg side leaked because a typed promise in prose is not a check — so the check reads the
  declaration. Converting at build would keep two authored truths alive (the flat fields and the rows)
  — the second-copy fault; migrating once leaves one. Refusing the empty node costs one line and
  turns a silent stall into a named refusal.
- **CITES** AI-5 (the bench's hostile-route measurement) · data model A1.1/A1.2/A1.4a · RI-42 · A12.2c ·
  `bucket.lua:44` seam note · `manager.lua:276` · L3 · row 24.
- **LANDED IN** architecture §4b (the definition) · the bench: `Bucket.Build` gains the empty-node
  refusal and the arg-type guard; `known()` checks the closed list before the resolver; the store hook
  migrates flat → rows · the Analyst: A12 rows for the posed tab (fields, refusals, the closed-list
  order) and RI-49's `Next` as a build question. Memory: [[travelling-data-names-never-supplies]].
- **WORD** architect on the definition and the conversion; Battlewrath's on security and "define
  upstream"; the empty-node guard is a guard, taken.

## AL-16 · 2026-08-21 · conversation — the field's Ace3 idioms, a census of every launcher addon
- **QUESTION** Battlewrath: "how do people use Ace, and how can we."
- **OUTCOME** `audit/prior_art_ace_field_2026-08-21.md` (230 addons; counts re-runnable; cited) → §4f.
  Headlines: tabs-as-data is the common tongue; TSM built our structure (strip + per-tab builder + one
  layout pass + auto-height + a selection path + a theme registry); fold = hide-and-announce or an
  accordion whose row owns its height; "add another" = `args[key]` + `NotifyChange`; dock/undock is NOT a
  convention (reparent + restore suppressed chrome + sentinel, raw frames); two-level visibility is the
  collapsed strip; position = a status table, not LibWindow. Two build facts: **AceGUI 41 will be the live
  copy** (AI_VoiceOver serves it; r960 is the floor) and **ScrollFrame is missing** from our widget set.
  One read, the architect's, for the bench to take unless Battlewrath objects: **adopt AceDB for UI state**
  (fold · selection · dock · geometry) — every other Ace3 embedder on the client does, and "reference what
  is proven" says so; adopting later costs more than now.
- **REASONING** L16 / AL-11: reference what is proven, invent no handling where it buys little. Where the
  field has a convention (tabs as data, NotifyChange, status tables, AceDB) we take it; where it has none
  (dock/undock) the client's own map-with-panel (AL-15) is the reference and we are knowingly inventing.
- **LANDED IN** §4f · the audit · RI-42 (bench: ScrollFrame; AceGUI 41 floor; AceDB read).
- **WORD** architect, measurement. **AceDB for UI state: Battlewrath, same day — "Sure. Go for it. We're
  still learning how to use Ace."** ⟶ a ruling, with its reason: take the field's convention while we learn.

## AL-15 · 2026-08-21 · conversation — the client's own map-with-panel, measured as prior art for A10.9
- **QUESTION** Battlewrath: the default game has this shape (map vs map with quests). What does it do,
  and what transfers?
- **OUTCOME** `audit/prior_art_worldmap_2026-08-21.md` — the fork's `WorldMapFrame` measured from the
  extracted FrameXML. Nine idioms transfer (ruler frame · bolt-on by one anchor, never re-anchored ·
  one number = mode = scale · presence derived from content, persist only the chosen axis · proxy
  frame for undocked position · ID-based selection · texture set per mode) and two are named as
  anti-patterns (hand-listed Show/Hide ×4; two owners of one widget). Folded into `driver_architecture.md`
  §4e; A10.9's rows cite it (Analyst).
- **REASONING** the client's convention is the one users already know; where it is derived-state it
  matches A10.9 exactly, and where it is imperative it shows precisely why A10.9 insists on derivation.
- **LANDED IN** §4e · the audit file · A10.9 (Analyst cites).
- **WORD** architect, measurement.

## AL-14 · 2026-08-21 · inbox AI-4 (Creator) — the record/surface join, and `trigger`'s control
- **QUESTION** the join of `contract.lua`'s fields against `interface/object.md`'s 37 controls: 9
  stored-and-surfaced · 4 stored-not-surfaced (`trigger`; position, deliberately map-side) · 5
  surfaced-not-stored (`role · shape · match · unseen · answers`) — 14 of 37 controls carry no record
  field. Does `trigger` get its control in the A10.3 pass?
- **OUTCOME** **YES — in the A10.3 pass, with the node's other fields, never separately.** It is a
  NODE field (`contract.lua:87-90`); its user label is already ruled (*Trigger*: One time · Every time,
  adaptor row); its CODE TERM is the bench's the day it lands (the adaptor row reserves it). And the
  join is TAKEN AS THE INVENTORY'S INPUT: the authoring surface is nine fields, one owed control, and
  position on the map — the 14 no-record controls are the "different levels of completeness" made
  countable, and A10.2a's "replaced, not folded" now has its mechanical reason (they are not in the
  record). The emitting tool stays NEGATIVE as Battlewrath ruled.
- **REASONING** his frame: *what we store as functions · what we need to surface · to get to what we
  have today* — the pane is DERIVED from the record and the authoring need. A design instinct and a
  mechanical fact arriving at one answer independently is the strongest corroboration the project
  gets. The surface this implies is written as `driver_architecture.md` §4d.
- **CITES** AI-4 · `contract.lua` CHARACTERISTIC/BEHAVIOUR · A10.2a · A10.3 · adaptor `Trigger` row.
- **LANDED IN** `driver_architecture.md` §3a (node editor row: the numbers) · §4d THE AUTHORING SURFACE
  (new) · A10.3 (Analyst adds `trigger` to the node fields).
- **WORD** architect, applying rules on record.

## AL-13 · 2026-08-21 · inbox AI-3 (Creator) — dock / undock is NOW; four blanks
- **QUESTION** A10.9 rules the behaviour (every visibility DERIVED from one piece of state per group);
  unstated: what a GROUP is · how an undocked group RETURNS · where dock state LIVES · the undocked
  TEMPLATES.
- **OUTCOME**
  **Blank 1 — a group is one interface surface, YES, with the map excluded:** the six interface files
  are the only enumeration that exists and `check_interface` already reconciles them 1:1; Battlewrath's
  structure makes *the map and its controls ONE surface* that never docks — so the dockable groups are
  the other four (remote · curation · promotion · object), and a LANE is a GROUP (A10.1a's three lanes
  were the first three of them; the remote is the fourth). `Spec` declarations for the three undeclared
  groups are owed AS EACH PANE FOLDS (one pane at a time), not all at once.
  **Blank 3 — account-wide, beside the other UI preferences, YES:** dock state is a preference about the
  tool, not about a route; RI-24's law (nothing about the author's setup travels) decides it, and a
  route-scoped state would travel on export. One field.
  **Blank 4 — a re-ARRANGEMENT of the same declaration, YES:** one declaration per group, two
  arrangements (docked column · undocked window). A10.9f's parity law then holds BY CONSTRUCTION —
  same cells, same get/set, same adaptor labels — and its parity mutation becomes structurally
  impossible rather than graded. Two declarations would be the second copy that can disagree.
  **Blank 2 — ANSWERED BY BATTLEWRATH, same day:** *"A strip that shows as 'collapsed' — a different
  pane that gives a DOCK-ALL restore path, in the same texture grammar as the bolt-on had, so same
  styling. And each undocked item gets a PER-TAB return path, occupying the same band space the tabs
  lived on, so it's one language. A drawer behaviour in illusion is how I mean the collapse strip."*
  ⟶ TWO return paths, ONE language: the strip (dock all) and the per-tab band on each undocked window
  (dock this). The container never disappears; nothing is one-way. A10.9d's "maybe" is now a ruling.
- **REASONING** blanks 1/3/4 are decided by rules already on record (the existing enumeration; RI-24;
  one-declaration-two-arrangements = the no-second-copy law) — no product behaviour invented. Blank 2
  is product taste (what the author sees when everything is undocked) and the record names it his.
- **CITES** A10.9a–f · A10.1a · RI-24 · `panespec.lua` `Spec.SUBJECTS` · `check_interface` ·
  Battlewrath's structure quote (A10.9 head).
- **LANDED IN** A10.9 (Analyst adds: group = interface surface minus the map; state account-wide; one
  declaration two arrangements) · `driver_architecture.md` §3a (Primary frame row) · blank 2 → his word.
- **WORD** architect for 1/3/4; Battlewrath for 2 (answered 2026-08-21).

## AL-12 · 2026-08-21 · RI-44 — the development order's pace, and the sequence note that governs it
- **QUESTION** both chains now, the live defect today, the engine proven on synthetic rows first —
  yes / no?
- **OUTCOME** **Yes — with one sequence note that outranks the pacing:** *"There is a tension between
  what we handle and what can be handled. Push the editor to richness before worrying about export and
  Dungeon Routes. The bench can synthetic as it needs to prove rather than A/B client testing. Dungeon
  Routes earns everything Dungeon Run proves — not that Dungeon Run cannot test drive; it is that
  deciding how we present information assumes the information is structured enough to reach them."*
  ⟶ Chain 1 (the author's side) LEADS; Chain 2 runs as far as PROVING needs, on synthetic rows; Chain 3
  (the reader's screen) waits until the information is structured enough to reach it.
- **REASONING** his: presentation decisions made before the structure exists are decisions about
  information that cannot yet arrive. Proof on synthetics is cheaper and truer than A/B in the client
  and needs no deployment; the consumer inherits what the producer has proven rather than proving it
  twice. The architect's pacing stands inside that frame: the defect today; the engine's small items
  (sample · refusals · previous in-set) as proof, not as a product.
- **LANDED IN** RI-44 (drained) · `driver_architecture.md` §7 (the build principle).
- **WORD** Battlewrath.

## AL-11 · 2026-08-21 · conversation — where care goes: the hot path, and "reference what is proven"
- **QUESTION** (implicit, after the prior-art check) how much handling to design around the
  arm / re-arm swap versus the sensor's dispatch.
- **OUTCOME** Battlewrath: *"I trust your input. I am not the expert and we're referencing what is
  proven. We don't need to invent a handling where it buys us little. The sensor and action patch is
  the hot one. The stage steps has travel time between."* → **L16**: the hot path is sensor → action;
  a stage or step change has travel time on either side, so the swap is a rebuild by eviction (the
  field's shape) and is never optimised; A6's wording and F2's sequencing stand on the architect's word.
- **REASONING** cost follows cadence: the sensor polls at 0.1 s on approach and dispatch must follow
  the transition the same tick; a stage change is separated from the next by seconds of walking, so
  rebuilding the whole manifest there is free in effect and simplest in fact (WA rebuilds its load
  index by eviction; AceDB consumers rebuild on a profile switch — prior art §5).
- **LANDED IN** `driver_architecture.md` §5 L16 (home §4b · A11.4 · the manager's acceptance).
- **WORD** Battlewrath.

## AL-10 · 2026-08-21 · F1 (from the AI-2 audit) — R2 vs RI-23: does the behaviour record carry the gate?
- **QUESTION** R2 (21st): every record opens with the gate. RI-23 (19th): node fields appear once.
  The behaviour record today carries no stage/step.
- **OUTCOME** **Battlewrath: the IDENTITY / BEHAVIOUR claim stands — the behaviour record carries the
  ADDRESS only, stage and step ride the characteristic record once per node, the bucket composes the
  gate per row at build — ON CONDITION THAT THE SEQUENCE IS PROPERLY DEMONSTRATED.** Then *"the
  instruction set becomes the MANIFEST"*: the built tick list is the list of what can be true right
  now, for ONE route on ONE map. RI-23 stands; R2 is satisfied by the manifest, not by repetition.
- **REASONING (his, with the condition's reason)** saved variables load WHOLESALE — no part can be
  loaded into memory; the instruction set exists *"to isolate in run-time what can be true, so that
  many tables with similar-looking data cannot be confused."* So isolation cannot come from loading
  less; it must come from BUILDING FROM ONE RID ONLY, keyed by address. He is "not the expert or the
  programmer" and points at prior art: WeakAuras (many characters · many auras · many load
  conditions · many triggers/events) and the "profile" addons — *"our profile is a route, and it's
  whole."*
- **THE DEMONSTRATION (what "properly" means — the Analyst writes it as A-rows):** (1) two routes on
  one map with lookalike records → the bucket built for RID A contains no record of RID B, by
  address; (2) the gate the bucket composes for each behaviour row equals the prefix its
  characteristic record carries — the same manifest a combined line would have produced, so nothing
  is lost by not repeating; (3) a record whose address resolves to no characteristic is REFUSED at
  build, named — never a silent orphan.
- **PRIOR-ART CHECK — DONE the same day:** `audit/prior_art_isolation_2026-08-21.md`, measured on
  the installed WeakAuras 5.21.2 and AceDB-3.0 with citations. Fourteen shapes transfer (eligibility
  as an index rebuilt by eviction · the active selection a pointer destroyed on switch · consumers
  rebuild · one persisted key · identity by unique key, collisions regenerate · zero footprint unarmed)
  and ONE counter-example to avoid (WA never unregisters its trigger frame — disarm must). ★ The
  answer to his wholesale-load concern: a shared wholesale store isolated by a computed subset is the
  field's normal shape; isolation is the ARM step, not a second file.
- **CITES** R2 · RI-23 · model rows 3–4 · `contract.lua` BEHAVIOUR · data model §6 (SV wholesale) ·
  AL-3 (the tick list is built).
- **LANDED IN** `driver_architecture.md` §2 (the manifest; F1 resolved) · RI-42 (the bench: contract
  unchanged; the Analyst: the three demonstration rows) · `audit/` (the prior-art check, to follow).
- **WORD** Battlewrath, conditional on the demonstration.

## AL-9 · 2026-08-21 · inbox AI-2 (Analyst) — the reconcile audit's 20 corrections to the architecture
- **QUESTION** do I take the 20 corrections (16 architecture, 4 false closures) in
  `audit/reconcile_architecture_2026-08-21.md` myself, so the Analyst proceeds on B and E in parallel?
- **OUTCOME** **YES — all 20 landed in `driver_architecture.md`, each marked "(AI-2 audit, corrected
  2026-08-21)".** The ones that needed judgement: **A6** — "Stage → +1" was a defect in the accepted
  wording: an exposed gap (stages 1,2,5) is legal under L3 and +1 arms a stage that resolves to bucket 0
  alone, stalling the run with only recovery armed; now reads *the next stage PRESENT in the route*
  (architect's correction; Battlewrath may overturn). **C1/G6** — "cannot be authored" was true by
  design and false at both ends in build; marked CLOSED BY DESIGN, OPEN IN BUILD, and **F2 decided: the
  bucket's duplicate-stage refusal (D3, one named line) is SEQUENCED BEFORE the manager (D6)** — the
  window is closed at the cost of one refusal before the part that relies on it exists. **C2/G18** —
  same mark; zero code behind the previous in-set. **C3** — G19 and G3 split into a/b, the unanswered
  halves re-listed. **C4** — the zone ruling was stranded in struck text; it is now law **L15** (the
  MapID is the highest identity of location) with A11.2a as its home for the Analyst to cite. **A8** —
  §0 retitled THE SEATS: duties a thread cites, not self-labels (PROTOCOL §1); `boot.py`'s missing
  `analyst`/`architect` lanes reported to Battlewrath. **A10** — the personal-note PLANE is built
  (store · routes · map layer); only the per-role dimension and the pane are not. **A12/A13** — sensor
  ◐, readout ✗, stated against the code as it is.
- **REASONING** §7's direction rule: where this file disagrees with a mechanics doc or the code, this
  file has drifted. Two fault SHAPES earned rules, now in §7: *closed means built* (designed-but-unbuilt
  is "closed by design, open in build") and *a multi-part gap is struck only when every part has its
  citation*. The audit's own restraint — E-0 reclassified from alarm to sequence position on
  Battlewrath's word — is the model of how a measurement should travel.
- **CITES** the audit file A1–A16, C1–C4, D3, D6, F2 · L3 · model §A1.4a (two gates) · AL-8.
- **LANDED IN** `driver_architecture.md` §0 · §2 · §3a · §3b · §3c · §4 · §4b · §5 L15 · §6 · §7.
- **WORD** architect, on §7's rule; A6's wording and F2's sequencing are the architect's and stand
  until Battlewrath overturns. **F1 is his and is carried to him** (see AL-10 when answered).

## AL-8 · 2026-08-21 · inbox AI-1 (Analyst) — may the Route Manager rely on one-beacon-per-stage before the pickers exist?
- **QUESTION** A10.3e (the pickers) is ✗; three doors (`promoter.lua:530` free-text stageBox ·
  `routes.lua:432` AddBeacon · `routes.lua:1483` SetStage) still accept a duplicate stage; AL-4 says
  duplicates "cannot be authored" and the manager gets one anchor per stage "for free". Is A10.3e a
  PRECONDITION the manager may assume, its acceptance citing A10.3e as the guard?
- **OUTCOME** **YES — and the guarantee has TWO sides, not one.** The picker is the AUTHOR-TIME side
  (tell-and-trust: a swap, never a refusal). The BUCKET is the RUNTIME side, and it exists today:
  `Bucket.Build` already refuses loudly with named reasons; a second anchor at one stage is its next
  named refusal — *"two beacons at stage N — re-slot in the editor"* — never tolerance, never a
  shared cursor. So the manager never meets a duplicate whether or not the pickers have landed; RI-41
  stays dissolved; and the Analyst's window ("unenforced until A10.3e") is enforced at load from the
  day the refusal lands — one line in the bench's existing refusal list, no interim refusal in the
  editor. Routes imported from before the slot meet the same refusal (A2.3's surviving tell at load).
- **REASONING** a direction may be relied on before its author-side enforcer exists when (a) the data
  is measured empty of the case — it is: six stores carry stages, none a duplicate; (b) the enforcer
  is on the build order — A10.3e is; (c) the runtime has its own guard so the assumption cannot be
  broken from outside the editor — the bucket's refusal, which is the law already written for it:
  *bucket may fail and should fail loudly; stage may not.* Tolerating a duplicate at run time (the NO
  branch) would make the tray an authoring convenience and re-open RI-41; refusing at build keeps it
  structural at zero cost.
- **CITES** AL-4 · A2.10 · data model row 24 (bucket refuses loudly) · RI-41 · A2.3 (superseded, tell at
  load survives) · the Analyst's measurement (6/12 stores carry stages, 0 duplicates).
- **LANDED IN** the manager's acceptance (Analyst writes it citing A10.3e as the author-side guard and
  the bucket refusal as the runtime guard) · `Bucket.Build`'s refusal list (bench; one named reason) ·
  A2.10 gains the sentence "the bucket refuses a duplicate stage at load".
- **WORD** architect, applying rules already on record; no word from Battlewrath needed.

## AL-7 · 2026-08-21 · conversation (R10 moment 4) — the reader's two panes
- **QUESTION** what select · arm looks like to the reader (G9).
- **OUTCOME** two panes: the NOTE PANE (stage / step · the note — information and direction; all that
  shows when things go well) and the REMOTE (select · Arm ↔ Stop · correct-when-lost, collapsible to a
  media-player-like corrector).
- **REASONING** Battlewrath: "that lets the flight and the steering be placed separately and not
  control so much of the user's UI. If all is going well they just need information and direction."
  Supersedes his own earlier "one surface" — a flattening of the screen, not a reversal.
- **LANDED IN** `driver_architecture.md` §4c 4 · RI-42 note for A10.5's reader-side counterpart.
- **WORD** Battlewrath.

## AL-6 · 2026-08-21 · conversation (R10) — the reader's first run, moments 1–3, 5–8
- **OUTCOME** receive = the community string into a personal route inventory (an in-game sync channel
  named for later) · see enough to want it · offer by current map · stage 1 loads and lures, recovery
  never uses the supertracker · one fixed display (stage / step · note), emitted never in chat, no
  in-flight diagnostics · own note retired for this heading · end = "Route complete", re-run = leave
  and re-enter.
- **REASONING** his, moment by moment; the test-drive readout is the author's diagnostics, not the
  reader's display; tray-0 items never write the arrow because the reader observes and corrects.
- **LANDED IN** §4c · G10/G11/G12 closed, G14 retired · RI-42 note for A10.5 / A11.5 / A11.9.
- **WORD** Battlewrath.

## AL-5 · 2026-08-21 · conversation (R8) — what Step is scoped to
- **OUTCOME** "A stage is a beacon. A beacon with children becomes a stage with steps." Step = the
  child's position in its stage's sequence, restarting each stage; `stage.step` is the whole address.
- **REASONING** answered by meaning, not mechanics: stage = one intent (into the room · the jump · the
  boss), steps = how it guides you through it. R7's one-beacon-per-slot had already merged the
  beacon-scope and stage-scope readings; this names why.
- **LANDED IN** model §1 · architecture §4 · G7 closed · RI-42 (mirror into `contract.lua`).
- **WORD** Battlewrath.

## AL-4 · 2026-08-21 · conversation (R7) — slots per stage, slots per route
- **OUTCOME** a route is a tray: stage slots hold one beacon each (0 = the open tray), step slots one
  child each; the picker shows what is current plus +1 (next whole / next decimal) or swaps with a
  chosen occupant; no shift, no renumber; duplicates cannot be authored.
- **REASONING** his direction change: conflict resolved AT AUTHOR TIME by the slot beats soft prompts
  in the wild; it dissolves RI-41 / G6 and A2.3 by construction, and the manager's bucket gets one
  anchor per stage for free. Tell-and-trust holds (a swap is told, nothing refused). The architect's
  "displace to the tray" act was dropped — the picker is the whole act.
- **LANDED IN** model §1 SLOTS · A2.10 (A2.3 superseded) · A10.3e · basis line struck · G6 closed.
- **WORD** Battlewrath.

## AL-3 · 2026-08-21 · conversation (R2) — function + arg on the instruction set?
- **OUTCOME** on the BEHAVIOUR record, once per tab; on the gate list, never. The tick list is BUILT at
  load from the records and never exported.
- **REASONING** a tab IS a function and its arg, so they can live nowhere else; every record opens
  with the gate so any record stands alone; a view that travels is a copy that can disagree. R2's
  "per-ID table with tabs laid out for the bucket" is the behaviour records; "the ordered gate list"
  is the bucket. WeakAuras says the same from the other side (authored table per aura, load-time
  index per event); the flight-controller review is kept as a check, not a decision.
- **LANDED IN** architecture §2 · RI-42.
- **WORD** architect's answer to his question; he took it.

## AL-2 · 2026-08-21 · conversation (G1/G2 → R4) — the Route Manager and the order of effects
- **OUTCOME** one stateful owner of an Active Route — the offer and the one selection, current stage
  and step, the ledger, firing Next, the bucket swap, the three tracker writes, listeners, the stage
  line, the terminal state, one saved slot (selected RID, never progress). Order of effects 0–9.
- **REASONING** nothing held `currentStage` and nothing called `Designate`; a completion had no owner;
  the sensor could not be the designator without changing its own input mid-poll (row 26). One owner
  closes G1, G2, G3, G5, G13, G18, G19, G21 at once; reload becomes one overwritten slot with no
  progress saved (zero garbage), and recovery lands the reader after a re-arm.
- **LANDED IN** architecture §3b (new part) · §4b · RI-42 (the runtime tier handed to the bench).
- **WORD** architect's proposal; Battlewrath: "Yes. That matches."

## AL-1 · 2026-08-21 · conversation (R1, R3, R11) — wording and terms
- **OUTCOME** a stage advances when its conditions are met (boss, pull, transition, skip) · a RUN is the
  Run side's capture, an ACTIVE ROUTE is the Routes side's live route · "pre-load" retired for
  ingest → bucket → arm.
- **REASONING** accuracy and self-describing names: "if a word needs a gloss, the gloss is the name."
- **LANDED IN** architecture §1 · §4 · G26 closed.
- **WORD** Battlewrath.
