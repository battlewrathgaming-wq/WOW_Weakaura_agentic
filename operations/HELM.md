# HELM — who has the trunk

holder:  RELEASED
since:   2026-07-17 (released — `/macros/` stood up; the slice is staged and waiting on the client)
heading: —
runway:  —

next:    `/macros/` is BLOCKED ON ONE THING — the live capture. Ask is staged at `macros/probe/ASK.md`
         (addons bench owns the harness; pointer at `addons/backlog.md` #4). Nothing in the slice moves
         until it lands. When it does, the map is this bench's build: derive verdicts from the RAW record,
         graduate the proven set into `basis/conditionals.json`. Forecast + expectations:
         `operations/Macros.md`. Anything else is free game.

---

**The rule (Battlewrath, 2026-07-15): this is a LOCK, not a courtesy.** One session holds the
helm at a time; the other agent stays out of the trunk until the topic is resolved and the helm
is RELEASED at close-off.

- **The heading line is half the point** (Battlewrath, 2026-07-15): taking the helm means STATING
  the goal in one sentence — which means stopping to discuss what the goal IS before any work.
  The lock guards the trunk; the heading guards the focus.
- **Boot:** read this file BEFORE your first commit. `RELEASED` (or your own name) → take it:
  set holder/since/heading, commit. **Another bench's name → you are locked out** — do repo-read-only
  work or stop and surface to Battlewrath; do not commit to the trunk.
- **Close-off:** set `holder: RELEASED` in your session's final commit.
- **Stale helm** (a session died holding it): Battlewrath is the tiebreak — one word from him
  clears it. Advisory timestamps exist for exactly this.
- **`runway:`** (optional, added 2026-07-17 on Battlewrath's instruction — "indicating you have the
  runway for a while") — the holder's own estimate of how long the hold runs. It serves the stale-helm
  rule directly: **a LONG runway is what a dead session looks like from outside**, so say so up front.
  A quiet trunk under a declared long runway is expected, not evidence of staleness. Clear it at
  close-off with the holder line.
- **`next:`** (optional) — a LIGHT direction stub left at close-off: what the released topic is waiting
  on, in a sentence or two, so the next pickup steers without archaeology. **Steering, not audit
  history** (Battlewrath, 2026-07-17) — the trail lives in `git log` and the lane files; this line only
  points. Drop it when the topic closes or a new holder sets a heading.
- `git log --oneline -- operations/HELM.md` = the trunk's custody history, for free.

_Born from the 2026-07-15 wobble: two sessions interleaved on the trunk and it looked like
history loss until counted. The helm makes the exception loud instead of silent._
