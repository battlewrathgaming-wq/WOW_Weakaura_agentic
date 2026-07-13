# plane_v2 — guiding principles

The principles the machinery is designed to; each phase doc cites these by
number. They extend (never replace) the blueprint's reasoning anchors.

## P1 — One write surface for reasoning
The agent (or generator) writes `docket.json` and nothing else. Everything
downstream is a deterministic machine. If a step needs judgment, the judgment
moves UPSTREAM into the docket (a field + a `why`), not into the machine.
`[[one-reasoning-element]]` `[[intelligence-vs-gears-and-tooling-backlog]]`

## P2 — The contract is a type system, not documentation
State sheets compile into `contract.json`; the filler enforces it mechanically.
A fill either cites a contract row or is rejected with a named reason. Frame-
soundness is a PROPERTY of the pipeline, not agent discipline. Judgment is
spent once, on the boundary. `[[bounded-autonomy-whitelist-not-rubberstamp]]`

## P3 — A self-report is only as honest as its account of what it couldn't report
Every extraction fact carries a grade — literal-in-source / executed-clean /
stub-degraded / needs-live. Grades 1–2 are contract-grade; 3–4 go on a LOUD
`unresolved` list, and the filler treats them as warn-and-flag, never as
silently-true or silently-absent. `[[anchors-verifiers-over-logging]]`

## P4 — Execute the source, don't paraphrase it
Facts about WA come from RUNNING WA's own code under the harness (builders
called, inits run, probes swept) and reading what it does — never from an agent
reading Lua and transcribing. Where execution degrades (stubs), P3 records it.

## P5 — The probe defines the slice; sweep the axes
An options builder is a function of trigger state. One probe = one slice of
the surface. Modal structure (`enabled_when`) is DERIVED by sweeping probes
along known axes and diffing key-sets — mechanically, as data, not by reading
`hidden` function bodies.

## P6 — Source is authority; corpus is the hole-detector
The extraction (WA source, executed) is the authority for the surface. The
corpus's job flips to COVERAGE: every field observed in real auras must be
attributable to a contract row or known residue; anything unattributable is a
hole in OUR extraction, loudly reported. Corpus never authors the contract.

## P7 — Every machine run leaves a receipt
Inputs hash, outputs hash, verdict, unresolved count, and per-decision `why`
where decisions were consumed (fill_receipt). Look-back is an audit, not a
re-derivation. The ledger is the data layer of the independent activity feed.
`[[capability-makes-inspection-cheap]]` `[[independent-activity-feed-receipts]]`

## P8 — Autonomy extends exactly as far as the verification loop is closed
A stage runs unattended only when its output is machine-checked (roundtrip,
canon-diff, settle-equality, goldens). Where the loop genuinely needs the game
client, batch it into bounded sandbox sessions — human eyes at the boundary,
never pretending the gap closed. `[[never-pretend-to-be-the-mechanical-work]]`

## P9 — Barren parts, positively checked
An emitted part contains EXACTLY seeds + policy fields + docket fills — verified
by set-equality, not by diffing (a diff is blind to residue shared by both
sides). `[[blank-slate-parts-and-diff-blindness]]`

## P10 — Mechanical before agentic
Exercise the whole chain at scale with a MECHANICAL docket generator (phase 5)
before any agent authors dockets. The machine earns trust on deterministic
input; the agent inherits a proven machine, not the other way round.

## P11 — WA ships its own acceptor; provide the minimum, let WA complete
WA declares its minimal aura (`Private.data_stub`, Types.lua) and completes it
on every Add (`regionValidate` → `validate(data, data_stub)` → subregion
defaults → Modernize — WeakAuras.lua:2951). So the ENTIRE acceptor structure
is source-derived; the corpus supplies NO structure, ever. Its two jobs:
train the reasoning (which compositions humans converge on) and verify (P6).
Every aura is built reasoning-first: reasoning (docket) → conditional logic
(grammar over sourced provides) → assembly (drop into the sourced skeleton).
WA's own standard is the gate: reimport-diff clean.
