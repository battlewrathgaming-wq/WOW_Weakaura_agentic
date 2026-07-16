# HELM — who has the trunk

holder:  RELEASED
since:   2026-07-15 21:52 (released — addons bench session closed clean)
heading: —

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
- `git log --oneline -- operations/HELM.md` = the trunk's custody history, for free.

_Born from the 2026-07-15 wobble: two sessions interleaved on the trunk and it looked like
history loss until counted. The helm makes the exception loud instead of silent._
