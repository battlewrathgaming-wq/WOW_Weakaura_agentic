# landing — the client→repo channel

Where COA_DevDump v2's mailbox lands. `pull.py once|watch` reads the flushed
SavedVariables file, clones it **verbatim** into `raw/` (the local audit
receipt — gitignored, multi-MB), then parses it via the codec-proven
`Weak Auras/lua_table.py` into `records/<runId>__<task>.json` (**tracked** —
a capture is not reproducible from the repo). Dedupe key = the envelope
header's `runId`, so ordinary /reloads with an unchanged mailbox land nothing.

⚠ **Because `raw/` is gitignored, a `sha256` in any provenance block is NOT re-hashable on a
fresh clone** — there is nothing on disk to hash it against. It is a chain-of-custody LINK
(*these rows came from that file, on the bench that made them*), never a checksum of the
artifact carrying it. Everything downstream of the reduction is still checkable; the reduction
itself is not. Weighed and kept that way: the corpus exists so nobody has to open the raw.

Records are the landing form, not the product: consumers (the census maps,
the spec capture, the WA-env harvest) derive their artifacts FROM records and
land those where the consumer's bench expects them (`addons/maps/`,
`Outputs/`, …), provenance-stamped per `corpus/README.md`'s envelope shape.

The watcher normally runs inside the bench terminal (`addons/menu.bat` → [1]).

---

## ★ SOURCES — the manifest of who lands, and at what stage

`pull.py` was hardcoded to one file (`COA_DevDump.lua`) until 2026-08-13. `COA_DungeonRun`
then wrote its own SavedVariables, nothing landed it, and a whole dungeon run sat on disk
unnoticed. **A lane that covers one addon is not a lane.**

```bash
py addons/landing/pull.py sources     # who lands, and where
py addons/landing/pull.py once        # sweep - tracked sources, plus any `sweep: True`
py addons/landing/pull.py watch       # watch them all - one /reload flushes them all
py addons/landing/pull.py --source dungeonroutes once  # an EXCLUDED source, named
```

**`deploy.py`'s MANIFEST is the one authority on who EXISTS. `SOURCES` is the one authority on
who LANDS.** An addon joins by adding a row.

★ **A row carries two independent facts (§265), and it is worth reading them as two:**

    stage: tracked   lands in records/, committed forever
    stage: testing   lands in gitignored staging/
    sweep: True      in the default sweep, so `watch` picks it up unasked

⚠ **A new row defaults to unswept unless it is `tracked`** — that is the surprise guard, and
it guards against *an unreviewed row landing by default*, not against this row. Opting one in
is a deliberate, greppable commit. It does **not** make the source tracked; the two levers do
not move together, which is the whole point of splitting them.

`py addons/landing/pull.py sources` prints both columns. Check there before concluding a
capture failed — **a source that never landed and a source that landed nothing look the same
from the client side.**

### `kind` — the shapes genuinely differ

| kind | shape | dedupe |
|---|---|---|
| `envelope` | ONE `{header, payload}`, replaced every run | by `header.runId` |
| `collection` | a KEYED table that **accumulates**; the file only grows | **per key** — *"already"* is the normal answer for most keys on every flush |

A collection record gets a synthetic header (`tool` · `kind` · `collection` · `key` · `status`
from `closedAt`, so an **open** run says so) and the same provenance block as any other.

### ★ `stage` — the control, and why it exists

> *"The non-COA_DevDump needs to be more controlled and limited… a manifest of what's tracked.
> Then release when we get out of the testing stage."* — Battlewrath, 2026-08-13

| stage | Lands into | Default sweep? |
|---|---|---|
| `tracked` | `records/` — **git-tracked** | yes |
| `testing` | `staging/` — **gitignored** | **no**, must be named with `--source` |

**Two guards, two different hazards.** `staging/` stops **repo churn** — a collection source
lands a full run per play session, and run 1 alone is 50 KB while the record shape is still
moving. Exclusion from the sweep stops **surprise**: a watcher left running must not quietly
begin tracking a new addon because someone added a row.

**Promotion is one word in the table** — a deliberate, reviewable commit rather than a drift.

**Already-landed is checked in BOTH destinations**, so demoting a source cannot re-land its
existing tracked records into staging as duplicates. That is not hypothetical:
`20260813_020119__RFC_run1_clean-1__dungeonrun.json` is a **pinned exemplar** — it stays tracked
because `ARCHIVE__dungeonrun_poc.md` §13 cites it as the evidence for the drift finding, and **a design
note whose evidence can vanish is a note that rots.**
