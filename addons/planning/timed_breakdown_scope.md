# The timed breakdown — SCOPED

_Staged 2026-08-16. **Not a build plan and not scheduled.** A scope, so the settled ground survives
until the dev cycle reaches it._

★★ **The reasoning lives in `satnav_ledger.md` §5.11.** This file is the distilled decided / open /
out, in the order a builder would need it.

---

## ★★★ What it is, and why it is ours to build

**The map becomes a timed breakdown of a dungeon.** Movement over time, with what happened laid on
the same clock.

★★★ **The novelty is one fact: the combat log knows WHAT and WHEN, and does not know WHERE.**
Verified against this client's own logs — a CLEU line carries event, GUIDs, names, flags, spell and
school, and **no coordinates anywhere**. No damage meter carries them either, because none of them
needs to. **We carry position over time because a route needs it**, and that incidental capture is
the whole of the novelty.

---

## Decided

### ★★★ We are not a live parser — three phases

    IN COMBAT      STORE. Do not compute. Others are already parsing CLEU; piggyback.
    OUT OF COMBAT  ATTRIBUTE. Bucket the time, attribute damage and events, when there
                   is no frame budget to protect.
    DISPLAY        PACED BY THE WALK. Presenting data already attributed — nothing is
                   computed while it plays.

★ **Proven on this bench with numbers.** `mancer_stutter_report.md`: Libellus Leti 3,111 ms CPU over
131 seconds, peaking at 108 ms in one second, 55 fps in a burst second against 97 without.
MancerLedger, 0 ms. **The difference between costing sixty frames and measuring zero is WHEN THE
WORK HAPPENS.**

### ★★★ The poll IS the mechanism; the segment pull is the CHECK

    every 10-15s     poll the other addon's CURRENT segment totals
    on segment end   pull the FULL segment
    end of run       a reload, so SavedVariables flush

★★ **A running total sampled twice gives the window between by subtraction. The delta IS the
breakdown** — no CLEU, no stream, no parser.

⚠ **And the segment total is not a fallback, it is disqualified as a source.** Three reasons, and
the third decides:

    1. they already display it            no value added
    2. it carries no time                 not our contribution
    3. placing it on a timeline INVENTS   total ÷ duration is an AVERAGE across a span
                                          nobody observed. Not true, and that is enough

★ So the end-of-segment pull is reconciliation: **Σ(our deltas) must equal it.** A self-verifying
sampler, and a property the design produced without being asked for one.

### 10–15 seconds, settled

★ **Judged against its absence, not against perfect** — nobody has either number today. And
**review is not re-enactment**: nobody watches a twelve-minute dungeon in twelve minutes, so the
resolution that matters is measured in *review* time. Condensed, four buckets a minute is a reading
every fraction of a second on screen.

⚠ **Do not smooth. A 15-second bucket is drawn as a 15-second bucket.**

### The mechanism is `C_Timer.After`

★ `operations/ROUTER.md`: *"`C_Timer` EXISTS and is a genuine Ascension global, not a shim.
`C_Timer.After(delay, fn)` works — in use since `COA_GuardianPlates` v3.5.5."* ⚠ Note its warning
too: it enumerates as an **empty table** in the global census, so *a name search proving absence
proves nothing*.

★★ **Frame-free.** A self-rescheduling `After` costs nothing between ticks, where an `OnUpdate`
accumulator runs sixty times a second to find it has nothing to do. **The census stays at zero
persistent OnUpdate**, which is what the whole architecture rests on.

### Snapshot the segment list at run start

⚠ *"Clearing it an explicit act offered on dungeon start"* — an act a user may decline, forget, or
never be offered if they joined mid-dungeon. **A design that needs the list empty is wrong whenever
it is not.**

★★ **Snapshot at run start; anything not in that snapshot is ours.** Clearing becomes tidiness
rather than a precondition. Same move as the importer: **do not trust the list — DIFF it.**

### Sample identity, not just numbers

⚠ If their segment resets between two polls, a delta goes negative or restarts, and subtraction
cannot tell that from a quiet window. **Store `{segmentId, t, gt, totals}`.**

### ⚠⚠ We supply the shape. The human grades the run.

*"Staying still in a fight for a long time could be many mobs **or** a few hard hitting mobs you
struggled to survive."* ★★★ **One signature, two stories, and the data cannot tell them apart.** We
can say *you stopped here for forty seconds and took thirty thousand damage*; what it MEANS is the
player's. The model's line stands: *"we do not derive meaning. We just help give context on it."*

---

## ⚠⚠ It may supersede a recorded decision — flagged, not overturned

> *"We already suggested some logging for kills in a run (what was included in the pull). But
> ideally I'd off-load it to combat loggers and just piggy back cheaper on run-time."*

`cleu_on_this_fork.md` (2026-08-13) reads **"Decision: PUSH with a lean mask"** — register
`COMBAT_LOG_EVENT_UNFILTERED`, unpack, compare, return, allocate nothing in the hot path. It was
taken for one wanted thing: **what died in a pull**, which needs `UNIT_DIED`.

★★ **If the poll can read deaths out of another addon's segment, that listener may not be needed at
all** — and the cheapest CLEU listener is still one we did not register.

⚠ **Not overturned here.** That decision is evidence-backed with a three-arm measurement, and this
is a hypothesis about a different source. ☐ **Confirm what a segment actually exposes** — deaths,
per-death detail, and whether it carries its own start/end times — before deciding.

★ Both readings are honest: a lean masked listener measured *at or below* the no-listener arm, so
the CLEU cost is not the argument. **The argument is that a thing we never registered cannot cost
anything, and cannot break when the client changes.**

---

## ★★★ THE SOURCES — decided

> *"Which damage meters? The ones the client launcher offers to players. Same version we have access
> to from a stable source."* · *"Recount / Skada / Details"* · *"And deadly boss mods is interesting
> too. As that's heavily filtered and programmed 'what's happening to you'."*

    METERS   Recount · Skada · Details        running totals per segment
    DBM      a DIFFERENT KIND of source       announced, filtered, already reduced

**All four are installed on this client**, and DBM ships `DBM-Party-BC` and `DBM-Party-Vanilla` —
so **dungeon coverage exists**, not only raids.

### ★★ The version is the launcher's, and that is the whole point

**The supported set is what the launcher offers, at the version it ships** — not whatever a player
fetched from anywhere. ★★★ **So the API we call is READABLE, on disk, at the exact version we
support.** No remembered function names, no version sniffing across a long tail of builds — the
same discipline as reading WeakAuras rather than assuming it.

⚠ **And enumerate the set from the LAUNCHER when this is built, not from one machine's AddOns
folder.** What is installed here is evidence that these four exist, not proof of what is offered.

### ★ No meter installed → the capability is absent, and says so

> *"Get one if you want the capability."*

★★ **Not degraded, not bundled, not reimplemented.** A stated optional dependency, which is an
ordinary thing to ask of a WoW player and the honest alternative to shipping a meter we would then
own. ⚠ It must SAY so — a feature that is quietly missing is a bug report.

### ★★★ DBM is a different KIND, and it changes the mechanism

**A meter holds counters; DBM makes announcements.**

    meters   POLL a running total, take the delta.   The delta is the window.
    DBM      RECEIVE what it announces as it fires.  Rare - a handful per fight, not
             hundreds - so capturing them in the hot path costs nothing

★★ **And the value is that it is already FILTERED.** A combat log is everything; DBM is the
twenty things per fight that its authors decided mattered, aimed at *what is happening to you*. For
a timeline that is exactly the right density — **a pull annotated with four announcements is
legible; the same pull with four hundred CLEU lines is not.**

⚠⚠ **AND IT SITS ON THE LINE WE JUST DREW, so name it rather than discover it.** DBM DOES derive
meaning — that is what it is for. ★ **We still do not: we carry someone else's interpretation, and
we attribute it.** *"DBM announced this, here, at this second"* is an emission. *"This pull went
badly"* would not be. The distinction is authorship, and it holds as long as the attribution is
visible.

---

## Open

- ☐ **What a segment exposes**, per meter, via its live API: totals, deaths, healing received,
  per-source breakdown, its own start/end times. **All of this decides the shape of a poll** —
  and it is answerable by reading, since the source is on disk at the supported version.
- ☐ **DBM's receive path** — its callback surface, and what an announcement actually carries.
- ☐ Whether deaths come from the poll or still need `UNIT_DIED`.
- ☐ The poll's own storage shape, and what a reload has to flush.

## Out of scope

- **Totals, DPS, uptime.** They belong to the addons that own them. *"If they want an average,
  there's tools for that."*
- **Live parsing of the combat log in the hot path**, in any form.
- **Reading log FILES from the addon** — impossible; that is a bench capability, not a feature.
- **Deriving meaning.** We supply the shape.
