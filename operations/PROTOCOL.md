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

- **★★★ A DOCUMENT MUST NOT TRY TO IDENTIFY ITS READER** (Battlewrath, 2026-08-23). The form to
  refuse is the second person conditional — *"if you are X, then Y."* ⚠ **From a document a
  statement is ALWAYS TRUE; read as self, ANY role can match it.** So the reader cannot resolve
  whether the sentence is addressed to them, and the doc has quietly supplied an identity claim
  they have no way to verify — the same fault as a self-label, arriving from outside instead of in.
  ⟶ **Docs state FACTS and hand over INSTRUMENTS. Identity comes from the thread.**
  - ★ **Every thread carries its role**, trailed atop each message and re-read each turn — see the
    bullet above. That band is the ONLY isolated memory space that says who *this* thread is;
    everything else on disk is shared and therefore cannot.
  - ⚠ **If the thread does not carry it, ASK Battlewrath. Do not infer it** — not from the
    directory you are editing, not from a file you happened to open, not from a doc's "you", and
    not from a lane name that merely looks close. **An inferred bench is an inferred authority.**
  - ⟶ Written form: name the INSTRUMENT and the fact, never the reader. *"`boot.py` holds the
    seat→bench map; assert your lane"* — not *"if you are the Analyst you are addons."*

_Origin: a thread mis-read its own vestigial self-label (`Class_design (aura-side session)`) as proof
it was another bench. The apparatus could not self-correct; one sentence from the human did._

## ★ 1c. The TOOL CONFIG TRAIL — and the door that stays half-shut (2026-08-22)

★ **`py operations/toolcheck.py`** verifies the environment against a DECLARED known-good
state — the hook is present, the bounds are present, the hook still BITES — and `--restore`
rewrites `.claude/settings.json` from that declaration. ⚠ It exists for one failure in
particular: **a malformed `settings.json` disables every setting in it silently**, hook and bounds
together, and nothing else was watching. ★ The known-good is DECLARED, not snapshotted — greppable
and reviewable in a diff, which is L18 applied to the environment.

**[`TOOL_CONFIG_TRAIL.md`](TOOL_CONFIG_TRAIL.md)** — one line per change to the ENVIRONMENT:
its KIND (refusal · permission · checker · hook · lane · removal), the file, one clause of why,
and the §commit. ⚠ **Not a diff and not a rationale** — git holds the structure and the commit
holds the argument. This holds the question neither answers months later: *has anything been done
to the tooling that could cause this?*

### ★★ AND THE CONFIG SURFACE IS BOUNDED AGAINST ITSELF (Battlewrath, the same day)

> *"And a limited disallow for safety. (Once the door is open it's easy to keep entering it.)"*

Editing settings was opened so the environment could stop failing us. **The same turn bounded it**,
because an authority that is used casually stops being noticed:

    DENY   `.claude/settings.local.json`   the PERMISSION file. ⟶ An agent may not widen its own
                                           grants. This is the door.
    ASK    `.claude/settings.json` · `.claude/hooks/**`   changes stay possible and stop being
                                           casual — every one is a decision someone made.

⚠ **`ask` RATHER THAN `deny` ON THE HOOKS IS DELIBERATE.** A hook that misfires must be fixable in
the moment — the `no-shell-python` refusal narrowed TWICE on its first day, both times because it
blocked something correct. **A safety measure nobody can repair becomes a safety measure everybody
routes around.**

★ The general shape, and it is the same one the band's decay rule carries: **make the right path
frictionless and the wide path deliberate.** Neither closed, neither free.

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

## ★ 2c. What boot reaches for — three instruments, and the skills (2026-08-23)

⚠ **Nothing below identifies you.** Each line names a fact or an instrument; the thread carries the
role, and where it does not, §1 says ask.

```
py operations/boot.py --lane <yours>      assert your seat. A name it does not know prints the set.
py operations/emit_tool_index.py          every tool on every desk, from their own docstrings.
py operations/toolcheck.py                is the environment still what we declared?
```

- **`boot.py` holds the SEAT→BENCH map and is its authority.** A bench may seat several roles with
  ONE trunk between them, so the helm is the bench's, not the seat's. ⚠ **The map is not restated
  here** — a copy in a doc was measured stale by one day on 2026-08-22, which is how the memory
  spine's lane list came to be wrong. If the lane you assert is not accepted, the tool prints what
  it knows; if you do not know which to assert, §1 applies.
- **A lockout costs the PUSH, not the work.** Commit freely on your own lane. ⚠ Until 2026-08-23
  boot printed *"repo-read-only. Do not commit."* — a rule **this document never carried**; §3 calls
  the helm the lock that keeps co-working threads from colliding, and the only mention of committing
  is the boot-order item above. ★ A tool had hardened a prohibition one level below its own
  governing doc and printed it as law.
- **The skills arrive on their own.** A skill's description is PUSHED into every session; a doc is
  PULLED and therefore only ever answers a question already being asked, which is how the boot
  sequence decayed while the docs sat correct. ⚠ They appear only after a session restart.
  ⟶ **They are not listed here, for the same reason the seat map is not.** This line read *"two
  skills — `boot` and `tools`"* and was **stale from the day `layout` landed (2026-08-25)**,
  measured 2026-08-26 when `push` made it four. A count in prose is a second copy of something the
  session already hands you in full. **Look at what the session offers; do not read it off a doc.**
- **Ask the desk before naming a new tool:** `py operations/emit_tool_index.py --find <word>`.
  **A new file's name is a claim about what already exists.** A Write onto an existing TRACKED file
  now asks first and shows that file's own first line and commit count
  (`.claude/hooks/no-write-over.js`) — after a new harness was written over a 342-mutation one that
  had been on the desk for months, and no checker, test or commit noticed.
- ⚠ **Two mutation harnesses, and they are not interchangeable.** `addons/tools/mutate.py` breaks
  the **Lua smokes**; `addons/tools/mutate_checkers.py` breaks the **Python checkers**. Each names
  the other in its header.

★ The through-line: **the tool is the authority and the doc points at it.** Everything above can be
re-derived by running something; nothing above is a second copy that can rot on its own.

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
- **★★★ AND THE THREADS IT PROTECTS AGAINST ARE ALL HIS** (Battlewrath, 2026-08-23):
  *"I don't do automation, every agent active is because I'm on the other end of the wire."*
  ⟶ **There is no unattended agent in this system.** A session exists because he opened it. ⚠ A
  hold can still outlive its session; the cost of that is a stale HEADING, not a lost lock. ★ It
  is the premise under §3a's push rule and under `boot.py`'s refusal to treat an aged hold as a
  symptom, so it is written where both can cite it rather than assumed by each.

- **★★★ WHAT IT CAME ABOUT FOR — THE LAG, NOT THE COLLISION** (Battlewrath, 2026-08-23):

  > *"The helm came about mainly when I swap agents for a unrelated task. And then agents
  > concerned on the lag between their last state and the new git state."*

  ⟶ **The driver was a RETURNING agent, not two concurrent ones.** He swaps a seat out for
  something unrelated; the trunk moves without it; it comes back to a tree it cannot account for
  and burns the session reconstructing — or, worse, distrusts it.

  ★★ **SO THE LOCK IS THE FORM AND THE LAG-ANSWER IS THE PRODUCT.** Collision protection is
  real and is what `holder`/`since` mechanically do; it is simply not what the instrument was
  built to buy. ⟶ `boot.py`'s WHY block is the part that answers the actual question, and it
  keys on exactly the gap he named: **what landed since YOUR OWN LANE last wrote its lane file.**

  ⚠⚠ **AND THIS CORRECTS A LINE ADDED ABOVE IT THE SAME DAY (§535, mine).** I wrote that the
  helm *"guards against COLLISION between threads he is holding at once"* — extending the
  founding line's *lock … colliding* framing (`b7b8b88`) into a statement of PURPOSE it never
  made. ★ The founding line describes the mechanism accurately; I turned a mechanism into a
  motive without checking, and one sentence from him has the origin the doc had never carried.

  ★ It also settles why a STALE HEADING is the failure mode worth naming: **the heading is what
  the returning agent reads.** §535's ruling and this origin are the same fact from two ends.
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

### ★★ 3a. ONE BENCH, THREE SEATS, ONE PUSH (Battlewrath, 2026-08-23)

> *"Three days expected from now on the Addons bench. (Addon creator, Analyst and Design
> architect. Push authority is addon creator.)"*

    THE ADDONS BENCH   Addon creator · Analyst · Design architect · UI specialist (added 2026-08-23,
                       Battlewrath: "shall we stand a new agent up as a UI specialist?" - "Yes. Proceed.";
                       seat guide `addons/planning/UI_SEAT.md`; it emits the registry and renders, the
                       Addon creator still builds the panes)
    THE TRUNK          ONE, held by the BENCH - §2c already rules the helm is the bench's,
                       not the seat's
    PUSH               the **Addon creator** alone. ⚠ The other two seats COMMIT freely on
                       the lane and do not push.

★ **THIS COMPLETES §2c'S "a lockout costs the PUSH, not the work" RATHER THAN QUALIFYING IT.**
That line said what a lockout costs; this says who pays it. ⟶ Work is never gated on a seat;
only the moment it leaves for `origin` is, and that moment now has one owner.

⚠⚠ **WHY ONE OWNER AND NOT A CONVENTION:** a push is the only act in this system that is
irreversible for everyone else. Three seats pushing one trunk is three chances to publish a tree
none of them verified whole - and the verification (smokes, checkers, walk, both mutation
harnesses) is the Addon creator's instrument set.

☐ **STILL NOT ENFORCED BY ANYTHING.** No hook, no checker and no boot condition reads this. It is a
`Instrument`-line constraint until a guard takes it over - and by this document's own decay rule
(§1b) the day one does, this paragraph should shrink to name the guard.

⚠ **AND A PRE-PUSH HOOK NOW EXISTS THAT DOES NOT ENFORCE IT — do not read its presence as the
guard.** `.githooks/pre-push` (2026-08-26) records a receipt of the checker desk and **exits 0
unconditionally, including on its own failure.** It was built to record, not to gate: a stop on the
Addon creator's push is not the Analyst seat's to install. ⟶ So the ☐ above is unchanged, and the
distinction is the point — **a hook at the moment of a rule is not a hook that reads it.**

- ⚠ **A MULTI-DAY HOLD IS THE STEADY STATE HERE, AND ONE HALF OF `boot.py` DOES NOT KNOW IT
  YET.** `boot.py` already prints a BENCH-MATE's aged hold as a fact - *"expected: the trunk sits
  with the bench rather than bouncing between seats"* - on his own reasoning that *"the current
  pace of dev means helm would be impractical to keep bouncing."* ★ **The same-seat branch still
  RAISES it as a condition at `days >= 1`.** With three days declared expected, that fires on
  every boot from tomorrow for a state he has just called normal - which is precisely what the
  tool's own comment warns *"teaches the seat to scroll past the block that also carries the real
  ones."* ⟶ Recorded here, in the governing doc, rather than hardened into the tool: §531 is the
  case of a tool carrying a rule its protocol never had.

### ★★ 3b. THE COMMIT §-NUMBER IS DERIVED FROM THE TRUNK, NEVER FROM THE THREAD (Battlewrath, 2026-08-28)

> *"Just so we're checking before commit rather than trusting the thread."*

Before EVERY commit, derive the next § from the trunk's maximum — one command, run, not recalled:

```
git log --format=%s | grep -oE "^§[0-9]+" | sort -V | tail -1
```

Your number is that plus one. ⚠⚠ **WHY, measured 2026-08-28: 41 duplicated § numbers in 300 commits**,
mostly the Design architect's — that seat derived "next" from its OWN last commit across long threads and
compactions while the other seats carried the trunk hundreds higher (its §542–§559 landed on the
Analyst's genuine §542–§559). ★ The same law the boot section states — *a remembered sequence fails the
same slow way* — biting on a one-token field. The thread's view of the sequence is a memory; the trunk
is the instrument.

⟶ **Past duplicates STAND** (history says what it said; nothing is rewritten): a citation into an
overlap band carries the HASH or the seat beside the § — qualification, not renumbering, the same cut as
the law rename (AL-62).

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
