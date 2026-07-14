# Production

The engine's **"can we work it?"** side — the machine that turns an authored docket into an export string. It authors
**nothing**: all content is authored upstream in the class inventory; here we gate, stage, and wrap.

```
inventory (agent authors docket)  →  GATE  →  [clean]  →  Docket_stage/<pid>/   (the content vehicle)
                                                              →  pipeline WRAPS (minimal footprint)
                                                              →  headless WA finishes  →  Docket_complete/  (export string)
```

## The line

The class inventory (agent-owned) authors a **docket** per slot — the mechanical proof the slot can function, WA-literal,
with every class decision already baked in (the watched spellId is *in* the docket, because design put it there). The
**gate** (`../gate.py`) validates that authored docket. Past the gate, nothing authors content — the pipeline only
**wraps** the staged content in the minimal footprint headless WA needs; WA fills the rest of the table data we don't define.

## What's here

- **`stage.py`** — the thing that turns an authored docket into a **file** in `Docket_stage/`. Reads authored docket(s),
  runs the gate, and on a clean read writes the docket verbatim into `Docket_stage/<pid>/` (the content vehicle) with a
  gate stub beside it. Incorrect input (malform / invalid) is **blocked** and sent back to the inventory; unchecked soft
  flags ride along. Read locations are **constants** (the class inventory is due an overhaul — repoint, don't rewrite).
    - `py stage.py`            — stage every authored docket in `_authored/`
    - `py stage.py <file...>`  — stage the given docket(s)
- **`_authored/`** — where the inventory hands authored dockets to the stager (a constant; a stand-in until the inventory
  overhaul). Currently holds the live-proven **Tome of Ahn'kahet** docket as the first slice's sample.
- **`Docket_stage/`**, **`Docket_complete/`** — transient exhaust, gitignored; `stage.py` / the pipeline recreate them.
  Staged dockets are the content vehicles (consumed → export string lands → cleared); grouped by `pid`.

## Not yet here (migrate in later)

The pipeline gears (`expand` / `fill` / `bounce` / `bundle` / `codec`) still live in `../../plane/` and move in during the
tooling pass. They are the **wrap** step — deterministic, no authoring.
