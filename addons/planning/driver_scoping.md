# Dungeon Routes — SCOPING DECISIONS (Battlewrath's yes/no surface)

_Prepared by the Analyst, 2026-08-17. One row per decision the audit surfaced. Each row: the
question in one line · the options as the record holds them · where the evidence is · a blank
DECISION for Battlewrath. Decide FOR the target (`driver_use_case_target.md`), not between model
and arc on their own terms. Write in the DECISION line; nothing else needs editing. Already-ruled
items are listed at the end so they are not re-asked._

**FILLED by Battlewrath, 2026-08-17 ("Best of my ability"). Two rows (S2, S6) were written in
agent-language and could not be answered — restated plainly in `§R` at the bottom, awaiting him.**

Options key: **M** = as the model says · **A** = as the arc built it · **C** = both, as configs ·
**X** = neither / defer. Free text is fine.

---

## S1. Free drag vs re-seat only
Model + `routes.lua Place()`: drag a beacon to any point; "where you move it afterwards is yours".
Arc (advisory §12): moving = re-seating onto another read; no free point.
    evidence  reconciliation §1#5 · audit_A A4#7 · height law R-b (z never invented either way)
    DECISION: Free placement. Inform lightly to understand the H value and map. Re-seat only works when you have enough data sets to express where the guidance actually is. The intent is not "Breath exactly where I stood", that is friction then on the runner (Data collector) to perform precisely. We could H-lock it to neighbours, but that's more friction. Trust the author to not do stupid things. Expose in the walk section of the editor (replay, synthetic) and the test drive mode to go "OH, ofc". Walk will never fire on H bounds. In-game playing it will show markers floating in the air.

## S2. Anchor position — a label, or the theater's arm-zone centre
Model: "nothing downstream may consume it". Arc: theater xyz + R = the scene / broad listen (a
CONFIG since the chain ruling; not a replacement).
    evidence  reconciliation §1#4 · advisory §3, §13 (additive-config note)
    DECISION: Unsure what this means. ____   → restated in §R

## S3. Children vocabulary — model's `detect / condition / instruct` or arc's entity table + activate
Model §598-617: `shape · reach · reach.up · reach.down · unseen` / `role · stage · ramp` /
`action · target · outcome`. Arc §13: entity row `{parent, kind, pos, R, up, down, mode}` +
instructions `A / Q`, `activate`. D-3 says the two products may carry two languages (editor =
source, consumer = compiled); this row is which words the MODEL/editor keeps.
    evidence  reconciliation §1#10, D-3 · audit_A A5 (22 renamed terms)
    DECISION: I think vocab is it's own audit / research. Define the behaviours and how we construct them. Then give them logical names.

## S4. Compile-time refusal vs tell-and-trust
Model §742: no validation on authoring — duplicate stages, out-of-order, fractions accepted;
"tell and trust". Arc §4: `requires` DAG checked at flatten (no cycles / reachable / no orphan)
and REFUSED. Note: exactly-one-lure and "last stage has no close" were framed as TELL, not refuse.
    evidence  reconciliation §4 row "Stage ordinal…" · audit_B contradicted "no authoring refusal"
    DECISION: Tell and trust, with options to make it obvious (Walk nodes and their triggers on a data set.) and in-game testing and exposure (Test driver letting you cycle nodes near you and see what their doing)

## S5. Ordering primitive — `goTo` chain (code) or `requires` (arc) — and does `while` enter
Code already has `goTo` custody chain + `Heads/BrokenLinks/Cycles`; arc specified `requires` and
activation chains. Separately: `mode: while` (level-triggered, point test + hysteresis) has no
prior term — new material.
    evidence  audit_A A2#13, A3#9 · advisory §4, §13
    DECISION: I think first define the programatic model. Like:kind weak auras. How does a author select. Then we give options.

## S6. K-forward listen and clip-through — is K a v1 config, or does maxSeen return
Model §961-1011: three registers; a clip writes maxSeen and leaves the ratchet alone. Scope: v1
ratchet only, no maxSeen. Arc: forward-listen K (default 3) jumps the ratchet — which the model
names clip-through. Chain ruling: K is a config, not the default for chains.
    evidence  reconciliation §4 row "Three registers" · audit_A A4#6 · W5.2 emits K=all vs K=3
    DECISION: This is designed in language for an agent. And means nothing to me. :P   → restated in §R

## S7. Sequence as DISTANCE only, or an ordering primitive exists
Model §1044-1049: "we never need an execution-order rule" — nested radii ARE the pacing. Arc:
`requires` / activation chains (also S5).
    evidence  audit_A A4#11
    DECISION: Neither. Programmatic primitives that decide. So the option is both and a way to express it.

## S8. Note actions — out of v1 regardless; decide for v2
Model §91 removed `note`; scope lists note actions OUT of v1. Arc §5/§13 re-introduced
per-child note actions; target §4 rules a note is a choice option, ≤ ~200 chars.
    evidence  audit_A A4#10 · target §4
    DECISION (v2): Agreed.
    ⚠ SUPERSEDED (Battlewrath, 2026-08-18, RI-9 — said as a REVERSAL): "we can build it."
    Notes are IN v1. RI-1's shape holds (referenced in store, owned in pane); G1 stays in the
    build order before the test drive; acceptance A4 proceeds as written.

## S9. Shared note slots (many satellite writers) vs the model's ONE SENDER
Model §316-319: driver readout has one sender, no ladder. Arc §4: last-writer-wins across
satellites.
    evidence  audit_A A4#9
    DECISION: Both. Onupdate (reaching a node), do as (select child) says. Programatic options.

## S10. Build order — overhaul first (scope) or driver first (arc §K)
Scope §53-68: overhaul first, the MVP unblocks it. Asklist §K: G1 driver first. Target §9: focus
is the CONSUMER, one prerequisite = producer writes something the consumer runs.
    evidence  reconciliation §1#11 · target §9
    DECISION: I think overhaul first. Or we're building Driver on inventiveness instead of handling the data set given. So I think MVP is the test driver that is a suite option of Dungeon run. Then we can cycle until the real Dungeon Route has enough proof to be written in a basis

## S11. Datasets travel? (route economy is settled; this is datasets only)
Model §206-227: runs stay home. Target §5: dataset sharing not ruled out but OUT OF BAND
(Discord), an author's interest. Advisory §12 first paragraph still says "the dataset is part
of what travels" — a stale line.
    evidence  reconciliation §1#3 · target §5
    DECISION (mark the advisory line stale? any in-addon dataset export at all?): ____   → §R

## S12. Which walk is the reference AFTER this cycle
D-2 ruled desk golden this cycle, client proves usefulness. This row is only: when the Lua
consumer exists, does W7 keep grading against `walk.py`, or does the in-game walk (model §117-237,
`editor.lua` play pacer) become the reference and the desk retire.
    evidence  reconciliation D-2 · audit_A A3#1
    DECISION: We'll collect new samples. First define what we need to capture in a run vs don't now. Then use that data set.

## S13. Far-stage policy — beyond K
Model §995-999 / scope: OPEN, "build-to-lookable"; W5.2 emits the numbers.
    evidence  asklist §I
    DECISION (rule now, or wait for the first real route?): Decide once we have something working

## S14. Radius floor — ship one, or never
"You can tell us what R is safe; whether we stop an author going below it is taste." Leans no.
    evidence  asklist G-list · H7 safe-R
    DECISION: No. Programattic and limiting choice. A beacon could cover the whole map and still be safe based on it's actions.

## S15. Death location pointer — in v1?
Target §1: reader's option, off by default, death/alive from the log, no give-back.
    evidence  target §1
    DECISION (v1 / later): Later

---

## Already RULED — not re-asked
- Detection uses own positions; tracker = calibration + arrow (R-a)
- Height by construction; band ±2.5 as tolerance
- Only lures; a beacon points to self; two radii = two steps on one position
- Child→child = activate; deaf until told to listen; chains tight, funnels broad — configs
  ⚠ SUPERSEDED (RI-7/RI-8, 2026-08-18): `activate` and `onRamp` retired with `goTo` — outward
  pointing / a second mechanism for one fact. STEPS replace it: an ordinal child points at ITSELF
  and order is the ordinal alone; satellites listen while the beacon is current. "Deaf until
  told" survives as the ordinal sub-ratchet. See DRIVER_BASIS positions.
- Ordinals allowed as drawn chains, not as a form
- Reload = user recovery (manual seek); clear is an authored condition
- No trash offer; note is a recipe; boss names pre-populated from the run
- One author, many readers; no leader; channel carries flat only; inert until selected
- Mass adoption not the build target
- D-1 WA as the model; D-2 desk golden this cycle; D-3 two products (Run / Routes)
- Give-back / reclaim (F-ii): mechanically moot — last write wins; the product line is "we
  write while a route is armed and the reader chose it" — mark RULED if that is the line: ____

---

## §R. RESTATED PLAINLY — the rows my wording failed (Analyst; awaiting Battlewrath)

**S2, in plain words.** When a beacon has children, the PARENT still has a position of its own
(it was spawned from a read like everything else). The question: **does anything happen at the
parent's own position, or is it just a name/label for its children?** Two options:
    (a) it's a label only — the parent's dot on the map is where the group is drawn; nothing
        listens there; only the children (lure, satellites) do anything.
    (b) it's ALSO a broad "wake up" circle — when the reader comes within some big radius of
        the parent's dot, the parent's children start listening (the funnel case: "somewhere
        around this courtyard, start paying attention"). Since your chain answer, (b) is a
        CONFIG an author can turn on, not the default.
    DECISION (Battlewrath): (a). **The beacon is the SCENE MANAGER — not instruction-wise, but
    managing its ACTORS.** Editor concerns: opacity for the editing view; renaming each child
    from one surface. Actions are PER NODE so the UI space does not inflate. Nothing listens at
    the parent's own position. (Resolves reconciliation §1#4 to the model's "label" + a job.)
    **Addendum — the CHILDLESS beacon is the common case and is SELF-CONTAINED:** its tabs
    reflect what a child would do, but it IS the lure + the advance in one place, designed for
    ease of use. Not every route needs extrapolating into children for "come here, then
    stage N". Children are reached for when a place has more going on. (Code already falls
    back this way: on-ramp/acceptance → the beacon itself when childless, `routes.lua:862-902`;
    advisory §3 "beacon (childless): self-completing" — model and arc agree here.)

**S6, in plain words.** A route is stages 1, 2, 3, 4… The reader is on stage 2. They wander
and reach stage 4's spot before ever touching stage 3. **What should happen?** Two options:
    (a) jump the reader to stage 4 (the arrow now points at 5). Stage 3 is skipped and stays
        skipped. Simple; the risk is jumping ahead by accident when stage 4's spot happens to
        sit near stage 2's corridor.
    (b) don't jump — remember quietly "they've been at 4" but keep pointing at 3, so the order
        still guides them from where they are. Later a boss kill snaps everything into place.
        (This is what the model wrote as the "three registers"; the arc built (a).)
    Since your chain answer, "how far ahead it may listen" is a per-route setting; this asks
    for the DEFAULT behaviour when a later spot is reached out of order.
    DECISION (Battlewrath): **RATCHET + maxSeen TRACKED; skip is EXPECTED.** Normal use is
    1,2,3,4,5 as a ratchet with maxSeen recorded — so reaching 4 from 2 advances, and 3 is
    a skip. (The model's registers return; the arc's K-only jump does not stand alone.)
    **RECOVERY = a beacon OUT of the sequence:** it sits on a boss and tracks the kill; its
    instruction is `Boss killed → set:stage(N)` — a presence/update beacon that snaps the
    ratchet to where the route should be up to. At a node the author's options: skip · "while
    here, stage 3, complete, set:" · `return:maxSeen` [⚠ SUPERSEDED (RI-15 settled, 2026-08-18): the author's options are the ROW
    actions — give note · advance +N · set stage N · set supertracker · /say · open list; the
    recovery beacon IS the kill row's DEFAULT (set stage = this beacon's next, absolute);
    `return:maxSeen` is not on the pane unless it lands as a row action]. **Some dungeons are not end-to-end —
    Blockades: three bosses in a T-shaped hall, no right order** — which is exactly why maxSeen
    + boss-set exist rather than a single line. (Resolves reconciliation §4 "three registers"
    row to the model, with the recovery beacon as the authored escapement — model §984-993.)

**S11, in plain words.** Datasets (the recorded runs) — should the addon itself have ANY
export/import for them in v1, or is that entirely out of band (Discord) for now?
    DECISION (Battlewrath): **Export / import is OFF THE BOOKS for now — there is no one to share
    with. But we BUILD SO WE CAN, hygienically:** data-only, serialisable, versioned format from
    day one, no UI for it yet. (Advisory §12 "dataset is part of what travels" marked stale.)

**F-ii line** — is "we write the tracker only while a route is armed AND the reader chose it" the
product line? DECISION (Battlewrath): **YES. SELECT a route and ARM are required steps.**
    Anything automated beyond that would have to be proven useful once it is in the wild.

---

_**SCOPING COMPLETE — all fifteen rows + §R decided, 2026-08-17.** Next by the ruled sequence
(target §9): capture spec → new samples → the programmatic model (behaviours → construction →
names) → overhaul → test driver inside Dungeon Run → Dungeon Routes proper._
