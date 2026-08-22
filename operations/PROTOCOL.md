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

## ★ 1b. The TOP BAND — four lines atop every message (schema, 2026-08-22)

_The role marker above is the band's first line. This is the rest of it, written down because it
was carried only in one agent's memory — so every other seat was expected to reproduce a
convention nobody had published._

    <Model> <Role>.
    **Boot**        what you RAN to orient. Commands and files, PAST TENSE.
    **Files**       what this turn reaches for. Naming an UNOPENED file is the point.
    **Memories**    which memories fired, by [[name]].
    **Instrument**  turn-invariant constraints — and only while no guard enforces them.

### ⚠⚠ IT IS EVIDENCE OF REACHING, NEVER INTENTION (Battlewrath: *"intention isn't a pre-amble"*)

Every line answers **what did you touch**, never *what do you mean to do*. A band that states
plans is a preamble, and a preamble is read once and skipped forever. ⟶ `Boot` is past tense on
purpose; `Files` is a list, not a plan.

★ **AND NAMING A FILE YOU HAVE NOT OPENED IS THE POINT, not a lie.** The band is a reminder of
what to REACH FOR. Measured (2026-08-17): a session ran 33 days across 11 compactions while
`boot.py` decayed to nothing in days — **the docs are still read, but the CHAT chooses which
ones**, so they only ever answer the chat's own questions. After a compaction the band is the one
thing pointing at disk rather than at the thread. It survives by redundancy, like the role marker.

### ★★★ WHY `Instrument` IS A SEPARATE LINE FROM `Memories` — measured, not stylistic

`Memories` is **SUBJECT-indexed**: you select what relates to what you are reasoning about.
Instrument constraints are **TURN-INVARIANT**: they apply regardless of subject. ⟶ **A
subject-relevance rule can never select them**, and the evidence is direct — the memory
`author-in-a-file-not-in-the-shell` sat in the memory set all day while its rule was broken three
times. The line was working as designed and structurally could not carry that.

    IN THE BAND     `Python → Write, always` · `anchors from Read, never terminal output`
    NOT IN IT       anything a checker, a hook or a refusal already enforces

### ★★ THE DECAY RULE — an entry LEAVES the day a guard takes it over (his)

**`Instrument` is meant to shrink.** The moment a constraint is enforced by the environment, it
stops being something to remember and the line goes. ⟶ That is what stops the band becoming
wallpaper: it is not a checklist that grows, it is a **holding pen for constraints that do not yet
have a machine**.

⚠ **AND THE FIRST ENTRY HAS ALREADY LEFT, which is the rule demonstrated rather than promised.**
`Python → Write` was added 2026-08-22 after eight failures across three sessions; the same day,
`.claude/hooks/no-shell-python.js` began refusing it at the tool boundary — so it left the band on
arrival. **Two written rules had failed at it; the hook is what held.**

★ The general form, and it is this project's argument everywhere else too: **a guard that refuses
beats a convention someone consults.** The band is for what has no guard yet.

## 2. Boot & orientation — your shelf, not a shared warm-start

### ★ Boot is EXECUTED, not remembered (added 2026-08-12)

```
py operations/boot.py --lane <YOUR lane>
```

**Run it first, every session.** Battlewrath: *"harden the boot sequence, so it's doing the work
instead of regret of missing it."* This protocol already carries the law — *discipline rules
against filling a field fail slowly; a field that does not exist cannot fail* — and **a
remembered sequence fails the same slow way**. Proven 2026-08-12: an entire multi-commit build
arc ran without the helm ever being read, and nothing surfaced it until a manual look hours
later.

The sequence is **anchored on your ROLE**, not on status:

| | |
|---|---|
| **1** | You carry your role → `--lane`, asserted by you. **The tool never guesses it** — §1 makes the human the authority on identity, so a tool that inferred it would be claiming an authority it does not have. |
| **2** | Does **your role** hold the helm? |
| **3** | If not, **clarify the CONDITION, not the fact.** "Locked" is a wall; *why* is a diagnosis — it prints days held, commits since HELM.md last changed, and the newest commit. |
| **4** | **If the condition is a close-out or communication failure, THAT is the work** — address it rather than treating it as an obstacle. |
| **5** | **Why the trunk moved** — an area roll-up plus recent commits since your lane last wrote its file. This is the part that serves a **different bench** arriving cold. |

It also carries the **merge guard** (`origin` ahead of you → pull first) and **mechanises the
challenge rule**: the stub check is counted rather than glanced at, including the two drifts
hardened against historically — a `since:` carrying a parenthetical, and `heading`/`runway` left
set at release.

**Exit 0** clear · **1** conditions raised. Three design rules, each load-bearing:

- **It never TAKES the helm.** A lock you acquire by *looking* at it is worse than one you
  forget; taking stays a deliberate act with a stated heading.
- **It emits evidence and raises QUESTIONS — it does not classify.** Nothing on disk separates
  a live hold from a session that died holding one, so it names the question and the reader
  decides.
- **It stores nothing** (computed at invocation, so it cannot rest stale) and **carries only
  cross-bench content** — bench-specific staleness stays in that bench's own tooling, per the
  sharedness law below.

Then read your shelf and your lane file: that is where the *reading* half of boot lives, and no
tool can do it for you.

- **Each bench's SHELF is its own arrival note + durable index** (in agent memory). Boot order:
  **`boot.py` (above)** → the MEMORY.md spine (shared principles/facts) → **YOUR shelf** →
  **operations/<your-lane>** for current state → **HELM.md** before any commit.
- **A file's sharedness must match its content's sharedness.** Shared files carry ONLY cross-bench
  content; per-bench content lives in per-bench files. The old single shared warm-start bundled every
  bench's arrival note into one file — which manufactured the "I might be X, I'll read their
  warm-start" mis-identification. Dissolved 2026-07-29 into per-bench shelves.
- **Now-state lives in operations/<lane>**, not duplicated in memory.

## ★ 2b. The router — one client, one Lua (`operations/ROUTER.md`)

**Read it before deciding a client behaviour is unknown, whichever bench you are on.** Battlewrath,
2026-08-15: *"Everything we do is mostly LUA. And that's universal. Every finding and function weak
auras has had to determine has cross cutting to us."*

★★ **UNIVERSAL vs APPLICATION** is the split that makes it work: a property of the client or of Lua
lives in the router and belongs to everyone; how a bench *uses* it lives on that bench's shelf.
⚠ Anyone may add a universal fact — with its provenance, and *(measured)* only if a live run proved
it. **Nobody writes another bench's application row**; the lane rule stands.

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
  the check a glance: any extra line is by definition outstanding — and since 2026-08-12
  `boot.py` COUNTS them for you, so the check no longer depends on noticing. Being directed into motion is
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
