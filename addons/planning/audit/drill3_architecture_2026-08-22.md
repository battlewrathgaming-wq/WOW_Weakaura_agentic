# DRILL 3 — `driver_architecture.md` (#0) against the governing set and the code, 2026-08-22

_Design architect, at Battlewrath's ask ("we have our own doc to test against the governing docs to see
what needs updating or still stands"). A read-only `Explore` agent read the log (AL-1..33), the architecture,
the basis, the eleven governing docs, the open bench items (RI-54..72), `concepts/next.md`, and spot-checked
thirteen code files. Direction per §7: on a mechanic, the lower doc or the code wins and #0 has drifted; a
governing doc that contradicts a LOGGED ruling is behind. **Findings applied to #0 the same day (each marked
"drill 3, 2026-08-22"); the rest are handed down below. This file records what was found; it rules nothing.**_

**Checker note first:** `py addons/tools/emit_built_state.py` REFUSES TO EMIT — `driver_manager_acceptance.md:355`
cites `Routes.TRIGGERS`, which exists (`routes.lua:1601`) as a TABLE; the collector harvests only `function Mod.Name`.
The one instrument §7 delegates all build state to is red on a false positive. Every status below was hand-measured,
which is itself the finding.

## A · ARCHITECTURE DRIFT — fixed in #0
A1 the posed tab claimed `{address·gate·sense·fn·arg}` with `fn` "resolved at build"; the code emits `{sense·action·arg·trigger}`
on a node entry carrying address + composed gate; the WORD is validated at build, bound-ness checked at ARM
(`manager.lua:207-222`), the callable looked up at DISPATCH (`:437`); `Bucket.Resolve` was never the binding step.
A2 Trigger IS on the tab (`contract.lua:103`, the row's latch, AL-23) — #0 said "NOT on the tab". A3 the cursor is
the MANAGER's (`manager.lua:319-329`), not the sensor's — DR_Runtime_9 and §4b 9 said otherwise. A4 `Set(N)` = max(current, N)
(`manager.lua:663`) — step 5 still said "→ N". A5 G16 (bucket shape) was resolved: the model is committed one-level,
`bucket.lua` builds one level with its own headstone; only `driver_sensor_brief.md` (reference-grade) lags. A6 §4c 5's
"not expressed in code" — the LED TO tick is expressed and read (`Routes.LedTo`, `IsPosition`, `manager.lua:258-266`);
only its setter is owed (RI-63). A7 §4d/§4b stated "supertrack left the list" as fact; it left ROW_ACTIONS and the old
pane still OFFERS `Routes.ACTIONS = {supertrack}` (RI-58 = DR_Content_20's first instance) — restated as prescription. A8 Trigger's
code term IS chosen (`Routes.TRIGGERS = {once, every}`, `SetTrigger`, adaptor rows); only the control is owed. A9 §2's
characteristic record lacked LED TO (AL-19) and the FLOOR SET (AL-32) — added; the contract and data model are behind too.

## C · INTERNAL CONTRADICTIONS in #0 — fixed
Set(N) twice (C1) · Trigger on/off the tab (C2) · cursor owner (C3) · three descriptions of one row (C4) · `mark` on and
off the action list (C5) · `say` as /say vs constructed (C6 — AL-31 supersedes AL-30, now said) · supertrack in the
escapement list (C7) · the node latch authored vs derived (C8 — marked: the code took AUTHORED; the architect's derived
read still awaits Battlewrath) · §4c 5 vs the LED TO block (C9) · the emit seam exists, its A10.8c comment does not (C10 — bench).

## D · STALE BUILD STATE in #0 — the status column RETIRED
The manager, the completion ledger, the tracker escapement (thin, AL-25's shape in `core.lua:55-64`), the test-drive
remote (`drive.lua`, printing bindings) and the debug log (`debuglog.lua`) had all SHIPPED while §3 said ✗. Per §7 the
column is struck; build state is the checker's. Six hand-kept counts removed; three dead line cites dropped in favour
of names. One code-side staleness handed back: `manager.lua:536-538` describes as absent the Next branch built at `:560-575`.

## B · GOVERNING DOCS BEHIND THE LOG — handed to the Analyst (rows) and the bench (declarations)
B1 `driver_manager_acceptance.md:534-535` tests `Set(1)` at stage 3 → "the run is at 1": WRONG under AL-23 (max); the
code would fail that test correctly. B2 A12.4b + `driver_ui_acceptance.md:208` A10.3k say Trigger is a NODE field only;
AL-23 and `contract.lua:103` say per tab AND per node. B3 `driver_data_model.md:27-37` behind AL-19/23/32 (no trigger
on the row, "no code term chosen", no ledTo, no floor set) — and it is #3, the entry point for the stored shape. B4
`supertrack` still offered as a behaviour word in the model (`:122, :146, :208`), `driver_ui_acceptance.md:140, :736`,
`driver_manager_acceptance.md:365`, `driver_sense_acceptance.md:515-517, :649`, `driver_adaptor_table.md:65, :87`,
`driver_ui_scope.md:121` — the class DR_Content_20 rules; none carries a retirement stamp. B5 NO governing doc carries LED TO,
THE ACTOR, `mark`, the constructed `say`, the DEBUG LOG (shipped, ungraded) or the FLOOR SET — five rulings live only in
#0, which by its own §7 carries no mechanics. B8 `concepts/next.md`'s owed list was behind the code (fixed by hand;
the tool is the truth). B9 `driver_ui_acceptance.md:135` still offers "band up / down" (bandDown retired RI-22).

## E · STILL STANDS — verified against the code
§4b's order of effects 0→9 (`manager.lua` Offer → Build after Stop → arm lowest positive + bucket 0 → dispatch by
sense-word → complete after the loop → Rearm disarms then re-arms → bucket 0 by construction → park, stay selected →
one slot on select) · the no-outcome derivation, with the derived decision emitted · a row with no action completes
on its sense · the latch semantics (latch on completion; boss never latches on a wipe; `every` released by another
transition; node complete = every row latched) · "the next stage PRESENT" with the +1 headstone · the sensor's four sets
and changed-set return · the rule's purity and gate order · identifiers-only contract (no `text` type) · F1's
composed gate and the orphan refusal · the node editor writing ZERO rows · the empty-node refusal behind the seed ·
LED TO's tray-0 rule · R_FLOOR with its derivation beside it (the test-time assertion UNVERIFIED) · the debug log's
"a watched run must not run differently".

## F · THE BENCH'S OPEN ITEMS against #0
Answered (cite and drain): RI-58 (DR_Content_20) · RI-62 per-tab half (node half awaits Battlewrath) · RI-63 (the tick) · RI-69
(the Next picker) · RI-57 (the floor set — DRAINED now) · RI-71 (§7's client-seam rule + AL-30's probe) · RI-66 (the
listener's shape) · RI-72 (in principle — DR_Process_18 one layer up). Not answered: RI-59 (two sense vocabularies; the migration
discards an authored sense — #3's) · RI-60 (what feeds the picker with no run loaded — NEW G27, Battlewrath's) · RI-61
(the row roster: reorder/delete — partly) · RI-64 (the R ladder — not absorbed) · RI-67/68 (icon; Place/Unplace — NEW
G28) · RI-65/70 (tooling, out of scope by design) · RI-54/55/56 (heading; stale banners — the Analyst's; band ceiling = DR_Process_19).

_Four to fix first (the reader's order, taken): the status column · the Trigger split · Set(N) · homes for AL-19/25/30/31/32._
