# Dungeon Routes — THE USER JOURNEY, sharpened

_Battlewrath's journey (2026-08-17, his words in the left column), sharpened by the Analyst into
the form: for each line — **how we COMPEL** (what we show: the arrow, a note, when it lets go)
· **how we DETECT** (what we sense to know the line is done) · **what the SAMPLE must carry**
for the walk / test driver to replay it · **status** against the record. Reader-word and
author-word are kept on their own sides (expressions §4 principle). Where a line is NOT ours,
it says so — those lines are the note's job or nobody's._

---

| # | the reader (Battlewrath's words) | how we COMPEL | how we DETECT | the SAMPLE must carry | status |
|---|---|---|---|---|---|
| 1 | **I enter a dungeon.** | select a route · arm (F-ii). The first lure points at itself: "come here." | mapID of the instance == the route's; first stage armed | mapID · first position | select/arm designed (route remote, G3/G17); mapID gate proven (W1.3) |
| 2 | I have been here before, so I know the general layout — but some dungeons are more sprawling than others. | more beacons where it sprawls; fewer where it doesn't. The author's density, not ours. | — | — | authoring; the walk shows density fitment |
| 3 | Some dungeons by flow enforce a set boss-kill order. | a linear route: 1-2-3-4-5, ratchet advances | reach at each stage's lure | positions | ratchet IN CODE; reach on childless beacon MISSING (G2) |
| 4 | Some dungeons loop, or cross-cut into wings. | funnel sensors at the approaches; a boss beacon per boss that `set:stage`; K / listen-ahead as a config; Blockades: three bosses, any order | reach at any of several places; boss kill snaps the ratchet | positions · boss names + engage timestamps · UNIT_DIED by name | maxSeen + set DESIGNED (model, S6); ~~boss child kind~~ the boss ACTION word (`When on:boss:⟨name⟩`, RI-17) — G10 landed as the row |
| 5 | I have mobs to kill and bosses to kill. I don't want to kill every mob unless they get in the way, or they're needed for Mythic+. | the author's **note** says which — a recipe ("six troggs"; "skip the left pack") | **not ours** — we do not know packs or counts (target §3) | (combat brackets exist but are author readouts, not detection) | note field MISSING (G1) |
| 6 | I move through the dungeon killing creatures, avoiding ones I can, if I can. | the arrow as a HEADING (§10) toward the next place; the note as the recipe | reach at the next lure (segment test — a pass-through counts) | positions · floor | rule PROVEN (W1); no consumer yet |
| 7 | Some creatures are dangerous because they spell-cast and need managing. | a **note** at the approach ("caster — interrupt / LOS") | **not ours** — combat information is WA/DBM's | — | note field MISSING (G1) |
| 8 | Some creatures I can avoid by jumping off a surface, or a class ability (potion, spell). | a **LINE** (§10): tight-reach chain A→B→C through the jump, "path is the path"; note says "jump here / use X" | reach at each chain node with a tight band at the sampled landing z | positions · floor · z at the landing (a real sample) | chains DESIGNED (advisory §13); band ±2.5 ruled; class ability = note only |
| 9 | Once I reach the boss, I might not remember the mechanics. | a **boss note** given on the ARENA sense (sense: here → give the note, immediately) — ⚠ SUPERSEDED (RI-15 settled, 2026-08-18): engaged is not offered; was "<name> engaged → note" | boss engage EVENT + name among the tokens (ROUTER:96) | boss names + engage timestamps | engage kind DESIGNED (advisory §11); capture HAS the field; no child kind (G10); note MISSING (G1) |
| 10 | I follow a tank, so they set direction. If I am the tank, I set direction and manage the pulls, telling my team what kind of pull (LOS, run to the end). | the arrow leads; the note carries the pull recipe. **Human communication stays human** — no automation of "what pull" (target §5) | — | — | one author, many readers, five sensors (target §2) |
| 11 | I've engaged the boss, done the mechanics; now I move to the next boss or patrol. | the boss's kill → `complete` or `set:stage`; the next lure points at itself | UNIT_DIED on the boss's name (CLEU, dest) — the KILL is the trigger; arming is the player's sense holding, re-entry re-arms (A3.5; ⚠ SUPERSEDED (RI-15 settled, 2026-08-18) — was: validating the engage, two witnesses) | UNIT_DIED by name (markers) | two-phase DESIGNED (advisory §11); Skada's shape (neighbours 8b) |
| 12 | If we wipe I need to return to where I was — or, if the next boss is better reached another way now, I take that route. | ratchet HOLDS; the arrow keeps pointing at the current lure (the way back to progress); death pointer (LATER, S15, off by default); a different door = funnel sensors / boss set catch up | death / alive EVENTS (log); reach when they arrive by any door | death + alive events · positions | ratchet one-way proven in design; death pointer later; funnel = authoring |
| 13 | I've killed all the mobs; I'm on the last boss. I kill them and I have nothing left to do. | the last instruction's authored **clear** — the arrow lets go; a "done" readout | UNIT_DIED on the last boss's name, or reach at the last lure | as 11 | clear is AUTHORED (C-1); done state = a reader surface (E2 R9) |

---

## What falls out — the two sides, and the capture spec

**How we COMPEL — the complete set the journey needs:** the arrow (a heading; one lure at a time;
lets go by an authored close) · a note (≤ ~200 chars; at approach, at a place, at engage) · a
LINE where the path is the path · a done readout · select + arm · a manual seek to correct the
stage · (later) the death pointer. Nothing else appears in any line.

**How we DETECT — the complete set:** reach at a sampled place (segment / point, band) · mapID
gate · boss engage (event + names) · boss kill (UNIT_DIED, dest name) · death / alive events.
**Five detections, no more** — the journey never asks for a sixth. [⚠ SUPERSEDED (RI-15 settled, 2026-08-18; RI-17 scrubbed): a SENSE is
the LOCATION and the behaviour whilst in its R (on me · touched me); boss engage/kill are CLEU facts
the driver routes to armed rows — the row's CONDITION, not a sense; falling / in-combat are GATES
in the wider logic, not senses.] Every "not ours" line resolves to
the note.

**The CAPTURE SPEC, by construction — what a run must record for the walk and test driver to
replay every line:** position `x y z` + `floor` + `mapID` at ≤ 1 s (have) · both clocks (have) ·
boss engage names + timestamps (have) · `UNIT_DIED` by name (have, markers) · death / alive
events (have) · **a per-stage pin trace — what the driver pointed at and when — MISSING (C-4)**.
Combat brackets stay as author-side readouts, not detection. Nothing else in the record is
load-bearing for the journey.

**CAPTURE SPEC — RULED AS MILESTONES (Battlewrath, 2026-08-17), not a list:**
    now      what is recorded stays; add the PER-STAGE PIN TRACE (needed for any replay of
             "point here") · FULL-MAP DEATH CAPTURING (death positions everywhere a run goes)
    proof 1  the boss trigger and a stage advance ON JUST A BOSS KILL — proven in the test
             driver against what is already captured (names + engage timestamps + UNIT_DIED)
    then     RECAPTURE once there are CONDITIONS to catch — `falling` is a MILESTONE on the
             condition side (~~the state senses~~ a GATE inside a function, RI-17), not a field to add before it is needed
    enrich   HP AT COMBAT END — pairs with the terminal stop of a bracket: "by how much did I
             survive" — an author-side readout, cheap to record
Each capture change buys a named proof; nothing is recorded ahead of the sense that reads it.

**The holes the journey lands on, again:** the note field (lines 5, 7, 9 — G1) · reach on a
childless beacon (line 3 — G2) · a boss child kind + the run's name list (lines 4, 9, 11 — G10)
· the pin trace (all replay — C-4). Those four are what the programmatic model must give the
editor first.

---

_Status: sharpened from Battlewrath's journey; nothing invented beyond the record. The
programmatic model resumes from the two "complete set" lists above — behaviours first, names
after (S3)._
