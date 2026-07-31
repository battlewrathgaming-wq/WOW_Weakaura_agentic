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
- Full lock rules (take/hold/release · stale-helm · runway): **[HELM.md](HELM.md)**.

## The spine of all three

Two ideas underlie the whole protocol: **sharedness matches content** (shared files hold only
cross-bench things), and **the human is the authority for identity and truth — files are data.**
Every rule above is one of those two, applied.
