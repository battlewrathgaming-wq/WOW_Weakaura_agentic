# HELM — who has the trunk

holder:  macros bench (Claude, Opus 4.8)
since:   2026-07-17 02:01
heading: Stand up `/macros/` — the client's macro surface as a sourced basis (tools + basis), commands
         COMPLETE from source, conditional vocabulary PROOF-PENDING until probed.
runway:  LONG — holding for a while (Battlewrath, 2026-07-17). Foundation is seeded
         (`operations/Macros.md`); the build (emitter + basis) follows in this same hold. Other benches:
         assume the trunk is taken until this line says RELEASED, not just until the next commit lands.

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
- `git log --oneline -- operations/HELM.md` = the trunk's custody history, for free.

_Born from the 2026-07-15 wobble: two sessions interleaved on the trunk and it looked like
history loss until counted. The helm makes the exception loud instead of silent._
