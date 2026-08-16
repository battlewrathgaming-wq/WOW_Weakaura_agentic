# Remote · it is a remote, and there are two addons

_Commits: `a7d2427` §109.2 · `2865dbf` §110 · `8fbc362` §110.1 · `a275469` §113_

## The question

> *"Widget at some point should be renamed to that it is. (Need to consider. Currently it's the
> only spawning surface for the map. That then opens curation. That then opens promotion.) And
> starts a run."*

`COA_DungeonRunFrame` says even less than "widget" does. What is it?

## The reasoning

Tracing what it actually does gave the chain, which nothing had written down:

    Remote ── starts a run
           └─ opens Map ─┬─ opens Map controls
                         └─ opens Curation ── opens Promotion ── mints into Object

★★ **It is the only front door.** Everything downstream is reachable only through it — so a change
here is a change to whether the rest of the addon can be reached at all. That is worth knowing
before anything is moved.

Then he named it:

> *"So it's DungeonRun_Recorder_Remote (Like a remote to a TV.) Then DungeonRun_Drive (The addon
> that people use just to run routes) will have _remote as its primary entry."*

★★★ **`_Remote` is a PATTERN, not a name.** An addon's remote is the one surface that turns it on
and reaches everything else — small, always to hand, and not the thing itself. A TV remote is not
the television.

★★★ **And it says there are two addons:**

    DungeonRun Recorder   us — capture, curate, author        _Recorder_Remote
    DungeonRun Drive      players who only RUN a route        _Drive_Remote

### Which explained something that had looked like an oversight

`driver.lua` existed, was created hidden, and `/dr drive` was its only door. He said:

> *"Driver doesn't exist yet from what I know."*

⚠ Right about the thing that matters. It existed in code and had **no way in** — and a surface with
no door is indistinguishable from one that was never built.

★★ **It was never an unfinished corner of the recorder. It was the seed of the second addon,
sitting inside the first.** There is no door because the door belongs to `DungeonRun_Drive`, which
does not exist yet. So its `relates` settled too: it does not join the recorder's chain, and giving
it a button would have made it look like it does.

### The wrong turn

⚠ **I declared a rename.** `Driver` → `Test Drive`, and Play would spawn it. Then the surfaces were
compared:

    driver.lua   knows beacons by proximity — the model BEFORE children existed
    walk.lua     knows children, roles, on-ramps, and reports WHY the index moved

★★★ **Renaming would have carried a superseded consumer forward under a BETTER name** — the worst
of both, where the code survives *and* now sounds deliberate. His ruling:

> *"I think we deprecate that code. Leave the testing suite as it's own bounded, detailed,
> inventory lead activity."*

And on why absolutely:

> *"I'm being absolute here so we do not incur technical debt of leaving half-formed ideas in the
> code. […] Leaving it in is temptation to keep building on it. And we already proved to be adhoc
> with it with 2 similar code functions."*

## What fell out

- **The opening chain**, written once where it can be read. → `dungeonrun_interface_inventory.md`
- **`_Remote` as a pattern**, and a second addon named. → `interface/remote.md` hopes
- 💀 **`driver.lua` and `walk.lua` removed whole** — files, verbs, Init calls, the Play button, 26
  mutations, 13 smoke regions. Backlogged first to `addons/backlog/debug_suite/`.
- **A principle**, because the cause repeats:
  `memory/half-formed-code-invites-building-on-it.md`.
- **And his own account of the cause**, which is the part worth keeping:
  > *"I think it was pressure from me to see the system move. But we exposed other areas suffered -
  > like the utility of the interface."*

  ★ The cost did not land on the consumer. It landed on the **interface**, which went untended
  while the thing that made data move got the attention.

## Still open

☐ **The rename is declared and not done.** Frame name, file name and every reference move together
or not at all.

☐ **The inset is 16 here and 18 everywhere else.** Reconcile or justify.
