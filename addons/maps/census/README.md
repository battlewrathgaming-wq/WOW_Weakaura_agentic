# The client-surface census — the declared surface, broad

_The sheets model (`Weak Auras/engine/Fact_basis/sheets`) applied to the whole
custom client: pay the source-trace ONCE, emit generously, contracts then drag
out their own area of interest by reading tables instead of re-deriving._

## The layout (two-tier menu)

```
census.routes.md        THE browse menu — all namespaces by size + domain summaries
_meta.json              provenance anchor (patch-B sha256) + counts + the grain statement
namespaces/<ns>.json    per C_* namespace: every attested member, count, file:line sightings
namespaces/<ns>.routes.md   the light browse file (one line per member)
events.json             every event seen: kinds (registered / event-compare / custom-prefix
                        string), standing (stock per baseline / custom), sightings
globals.json            top-level `function Name(` declarations in the shipped UI code
baseline.json           the stock 3.3.5 declared surface, run out of the client's own
                        APIDocumentation addon (101 systems, functions + events + tables)
```

## The grain (read before citing)

- **Attested usage, not the engine export.** Everything here was seen in the shipped UI code
  (`patch-B.MPQ`, extracted study copy). Evidence of USE, never of the full surface — a C-side
  member no UI file calls is invisible here. **Pass 3 (the runtime `census` task on COA_DevDump
  v2) is the completeness check.**
- **Standing labels lean on the in-client baseline** (`APIDocumentation`, Author: Blizzard).
  For events that's solid (592 stock literals). For globals it's weaker: `not-in-baseline`
  means "not a stock C-API name", NOT proven custom — stock FrameXML's own Lua functions
  aren't in the baseline either.
- **Version anchor:** every emission stamps the source archive's sha256 in `_meta.json`
  (invariant 2). Current fork ≠ cited sha → re-emit before trusting.

## Regenerate (deterministic, one command each)

```
py addons\tools\extract_interface.py     # patch-B.MPQ -> Outputs/client_interface/patch-B/
py addons\tools\emit_census.py           # extraction + APIDocumentation -> this folder
```

## Standing consumers

The spec-name capture (mission 1) · the WA-env harvest (mission 3) · future aura triggers
(the 213 custom REGISTERED events are the candidate trigger vocabulary) · COA_GuardianPlates
(`C_NamePlateManager`) · any contract that needs "what does the client offer here?"
