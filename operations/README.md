# operations

The project's **tracking layer** — where the *work* is recorded, in the repo, tracked and visible. Offloaded here so
it survives, is versioned, and isn't trapped in an agent's private memory.

## The split (Battlewrath, 2026-07-14)

Two stores, two jobs — keep them clean:

- **operations/ (here)** — everything about the WORK: current STATE, the DECISIONS we've made and why, the BACKLOG
  of what's next, and pointers into the code/READMEs where the detail already lives. Project knowledge, architecture,
  technical facts about WA. If it's about *what we're building*, it lives here.
- **agent memory** — leaner, but with latitude (not rigidly two things): mainly **(1) how to find things** (navigation —
  where operations is, key paths, the map) and **(2) how we work well together** (the working relationship, cadence).
  That second one is not "corrections to tune a tool" — corrections are just the current, technical phase; the point is
  **enrichment toward operating at the same level, as partners.** Room remains for the occasional thing that genuinely
  belongs to me. If it's about *how we collaborate*, it lives in memory; if it's about *the work*, it lives here.

The test: a fact about the machine → operations. A fact about the partnership → memory. A pointer from one to the
other is fine (memory says "project state lives in operations/STATE.md"); duplication is not.

## Two registers here

**TOUCHSTONES — stable, locked-in, slow to move (Battlewrath).** The anchoring reads, so understanding the project —
or grounding a new direction — is NOT "read everything." They change rarely, on purpose; that stability is the point.
- **WHAT.md** — what the project IS (purpose, the product, the telos).
- **HOW.md** — how the project WORKS (the architecture, the machine, the flow).
- **TECHNICAL.md** — the technical details WHAT/HOW rest on (the WA/contract facts, the surfaces). The live source is
  the code + `engine/Fact_basis/`; this is the flattened read of it.

**TRACKING — moving, updated often.** Where we are and what we're doing.
- **STATE.md** — the current "where are we" + what's open.
- **DECISIONS.md** (growing) — the decisions log: what we chose and why, appended over time.

The rule of thumb: touchstones answer "what/how/why is this" and rarely change; tracking answers "where are we right
now" and changes every session. Don't let tracking churn leak into a touchstone.
