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
