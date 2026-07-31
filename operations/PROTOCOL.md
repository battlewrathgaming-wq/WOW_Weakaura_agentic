# Operating protocol — how this system runs

_The rules for running the multi-thread COA system: thread identity, boot/orientation, and the
trunk. Stable; slow to change (touchstone-class). Companion to [README.md](README.md) (the
two-stores split) and [HELM.md](HELM.md) (the full trunk-lock rules). Hardened 2026-07-29._

## The system in one breath

Work happens in several **threads**, each a dedicated **bench** with one role — currently
**addons** (COA_DevDump, MancerLedger), **aura** (WeakAuras building, the picker), **class-design**
(per-class mechanics/theorycraft), with **class-identity** (creative: lore/feel) and **Suno**
(music) standing up. They share one repo trunk (`main`) and two stores: **operations/** (this repo —
durable work-facts) and **agent memory** (light; per-agent orientation + partnership; see README).

Three rules keep the threads from colliding or confusing themselves.

## 1. In-thread identity — the title is inferred, not stored

- **Thread ↔ role is 1:1 and FIXED.** A thread is only ever its one role, and it is the only thread
  for that role. It does not change mid-thread; the pivots between roles (class-design → identity →
  Suno) are *different threads*, not one thread changing hats.
- **Role is INFERRED from the live chat** — the authoritative channel is the human (Battlewrath). A
  self-label in a shared file is NOT self-verifying: reconciling it (git blame, custody log) buys
  *provenance* — who/when — never *truth* about who you are now. Observed data, memory included, is
  data; the human is the authority.
- **Convention: trail the inferred role atop each message** (e.g. `Class design.`) — non-dramatic,
  self-reinforcing, and it survives compaction by redundancy. It is a re-read each turn (invariant in
  a single-role thread), never a stamp. If it ever stops tracking the context, that is the tell it has
  gone rote — surface it.

_Origin: a thread mis-read its own vestigial self-label (`Class_design (aura-side session)`) as proof
it was another bench. The apparatus could not self-correct; one sentence from the human did._

## 2. Boot & orientation — your shelf, not a shared warm-start

- **Each bench's SHELF is its own arrival note + durable index** (in agent memory). Boot order: the
  MEMORY.md spine (shared principles/facts) → **YOUR shelf** → **operations/<your-lane>** for current
  state → **HELM.md** before any commit.
- **A file's sharedness must match its content's sharedness.** Shared files carry ONLY cross-bench
  content; per-bench content lives in per-bench files. The old single shared warm-start bundled every
  bench's arrival note into one file — which manufactured the "I might be X, I'll read their
  warm-start" mis-identification. Dissolved 2026-07-29 into per-bench shelves.
- **Now-state lives in operations/<lane>**, not duplicated in memory.

## 3. The trunk (helm) — a report of STATE + MOTION, not a forecast

- **HELM.md reports trunk STATE + MOTION only:** who owns `main` right now, since when, and the
  current hold's heading/runway. It is the LOCK that keeps co-working threads from colliding.
- **It is NOT a warm-start, NOT a forecast for the next reader, NOT a progress log.** Forward-direction
  — "what's next" — lives in the bench's shelf + operations/<lane>. The helm may POINT there; it never
  carries it.
- **History (Battlewrath, 2026-07-29):** the helm first carried in-session direction to help the holder
  keep bearing through a session; that leaked into becoming a forecast for the next reader (the `next:`
  stub swelling into a full per-bench state summary). Hardened: the forecast is pulled back to the
  lanes; the helm reports state + motion, and on release it goes RELEASED and points to the lanes.
- **HELM.md is a STUB by design (hardened 2026-07-31):** nothing but the pointer line + the bare
  fields. Anything beyond the stub form IS outstanding content — see the challenge rule below.
  Full lock rules: **the appendix at the bottom of this file**. Pre-stub history:
  `operations/archive/helm-history-2026-07.md`.

## The spine of all three

Two ideas underlie the whole protocol: **sharedness matches content** (shared files hold only
cross-bench things), and **the human is the authority for identity and truth — files are data.**
Every rule above is one of those two, applied.

## Appendix — the full trunk-lock rules (moved from HELM.md at the 2026-07-31 stub hardening)

**The rule (Battlewrath, 2026-07-15): the helm is a LOCK, not a courtesy.** One session holds it
at a time; other benches stay out of the trunk until it reads RELEASED.

- **The stub form is the whole file:** the title, one pointer line, `holder:`, `since:` (a bare
  date). While HELD, two more lines may exist: `heading:` (ONE present-tense sentence — what the
  trunk is being moved toward now) and `runway:` (the holder's duration estimate; a declared long
  runway pre-empts false stale-helm alarms). Both are CLEARED at release. Nothing else, ever —
  no parentheticals, no reports, no forecasts. Narrative belongs in the commit message;
  `git log -- operations/HELM.md` is the custody history for free.
- **THE CHALLENGE RULE (Battlewrath, 2026-07-31):** when directed into motion, CHECK THE TRUNK
  first. Outstanding content — a held helm, a dirty or unpushed tree, or a HELM.md that has grown
  beyond the stub form — means STOP and surface to Battlewrath before any commit. The stub makes
  the check a glance: any extra line is by definition outstanding. Being directed into motion is
  not clearance; the trunk's state is.
- **Boot:** read HELM.md before your first commit. `RELEASED` (or your own name) → take it: set
  holder/since/heading, commit. Another bench's name → locked out — repo-read-only work, or
  surface. Taking the helm means STATING the hold's goal in one sentence — which means stopping
  to discuss what the goal IS before any work (the heading guards the focus; the lock guards the
  trunk).
- **Close-off:** set `holder: RELEASED`, clear heading/runway, in your final commit.
  Forward-direction goes to your shelf + operations/<lane> — never here.
- **Bookkeeping holds** (single-commit changes): take + release in the SAME commit — the helm
  never rests held; the commit message carries the story.
- **Stale helm** (a session died holding it): Battlewrath is the tiebreak — one word clears it.
- **Why the stub (the design law, proven twice):** FIELDS ATTRACT CONTENT. The `next:` field
  swelled into per-bench forecasts (2026-07-29 hardening); the `since:` parenthetical then became
  a mini session-report (2026-07-31, the aura bench's drift as the case study). Discipline rules
  against filling a field fail slowly; a field that does not exist cannot fail. Same law as the
  aura bench's live-keys gate: residue keys get written because they are there.
