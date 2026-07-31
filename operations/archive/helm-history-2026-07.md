# Archive — HELM.md as it stood 2026-07-29 → 2026-07-31 (pre-stub)

_Moved here verbatim 2026-07-31 when HELM.md became a pure stub (the challenge-rule hardening —
see PROTOCOL.md §3 + appendix). This file is history, not rules: the living lock rules are in
PROTOCOL.md; custody history is `git log --oneline -- operations/HELM.md`._

---

# HELM — who has the trunk

_A report of TRUNK STATE + MOTION only — who owns `main` right now, since when, and the current
hold's heading. NOT a warm-start, NOT a forecast for the next reader, NOT a progress log:
forward-direction ("what's next") lives in each bench's shelf + operations/<lane>. This file may
POINT there; it never carries it. Full operating protocol: [PROTOCOL.md](PROTOCOL.md)._

holder:  RELEASED
since:   2026-07-29 (class-design: operating-protocol hardening — PROTOCOL.md written + helm trimmed to state+motion; taken+released in one commit)

---

**The rule (Battlewrath, 2026-07-15): this is a LOCK, not a courtesy.** One session holds the
helm at a time; the other agents stay out of the trunk until the topic is resolved and the helm is
RELEASED at close-off.

- **The heading is trunk MOTION, not forecast** (Battlewrath, 2026-07-15 / hardened 2026-07-29):
  taking the helm means STATING the current hold's goal in one sentence — stopping to discuss what
  the goal IS before any work. It says what the trunk is being moved toward NOW; it is not direction
  for the next reader.
- **Boot:** read this file BEFORE your first commit. `RELEASED` (or your own name) → take it: set
  holder/since/heading, commit. **Another bench's name → you are locked out** — do repo-read-only
  work or surface to Battlewrath; do not commit to the trunk.
- **Close-off:** set `holder: RELEASED` in your final commit. Put forward-direction in your shelf +
  operations/<lane> — NOT here.
- **`runway:`** (optional) — the holder's estimate of how long the hold runs; a LONG runway is what a
  dead session looks like from outside, so declaring it pre-empts false stale-helm alarms. Clear it
  at close-off.
- **Stale helm** (a session died holding it): Battlewrath is the tiebreak — one word clears it;
  advisory timestamps exist for exactly this.
- `git log --oneline -- operations/HELM.md` = the trunk's custody history, for free.

**Why hardened (Battlewrath, 2026-07-29):** the helm first carried in-session direction to help the
holder keep bearing through a session; that leaked into becoming a forecast for the next reader — the
old `next:` stub swelled into a full per-bench state summary. That forecast belongs in the lanes, not
the trunk report. The helm now reports state + motion; forecast lives in the shelves + operations/<lane>.

_Born from the 2026-07-15 wobble: two sessions interleaved on the trunk and it looked like history
loss until counted. The helm makes the exception loud instead of silent._

---

_Second hardening (2026-07-31, the aura bench's drift as the case study): even trimmed, the free-text
surfaces attracted content — a `since:` parenthetical carrying a session report, the earlier `next:`
carrying a full bench forecast. Fields attract content; discipline rules fail slowly, deleted fields
can't. Hence the stub._
