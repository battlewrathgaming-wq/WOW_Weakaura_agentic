# landing — the client→repo channel

Where COA_DevDump v2's mailbox lands. `pull.py once|watch` reads the flushed
SavedVariables file, clones it **verbatim** into `raw/` (the local audit
receipt — gitignored, multi-MB), then parses it via the codec-proven
`Weak Auras/lua_table.py` into `records/<runId>__<task>.json` (**tracked** —
a capture is not reproducible from the repo). Dedupe key = the envelope
header's `runId`, so ordinary /reloads with an unchanged mailbox land nothing.

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
py addons/landing/pull.py once        # sweep the TRACKED sources
py addons/landing/pull.py watch       # watch them all - one /reload flushes them all
py addons/landing/pull.py --source dungeonrun once     # a testing-stage source
```

**`deploy.py`'s MANIFEST is the one authority on who EXISTS. `SOURCES` is the one authority on
who LANDS.** An addon joins by adding a row.

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
because `dungeonrun_poc.md` §13 cites it as the evidence for the drift finding, and **a design
note whose evidence can vanish is a note that rots.**
