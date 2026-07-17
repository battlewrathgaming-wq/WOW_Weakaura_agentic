# Macros — the foundation for the `/macros/` slice

_"It's another slice of understanding CoA" (Battlewrath, 2026-07-17). The client's MACRO surface, mapped the way
the census maps the client's API surface. Est. 2026-07-17 — the slice's founding read; `/macros/` (tools + basis)
is built against this. Grain is stated PER CHANNEL below, because the two channels do not have the same grain._

## What the slice IS

The macro surface = what a player can TYPE into a macro on this client, and what that does. Mechanically this is
the **addons lane** (client surface / source facts, per `Addons_load.md`'s lane note) — given its own ROOT slice by
Battlewrath's call (2026-07-17), tools + basis, matching the other root folders, rather than folded into
`addons/maps/`.

**Audience settled (Battlewrath, 2026-07-17): a slice of UNDERSTANDING.** The project reads it, same family as the
census. Not (yet) a player-facing product. That resolves the open question the session opened with.

**Two artifacts, kept apart on the ADR line** (`adr-inventiveness-confined-to-contained-spaces`):

- **`/macros/basis/`** — the emitted map. Zero invention, sourced, regenerable, sha256-anchored. The thing that
  can't lie.
- **the guide** — LATER, and strictly downstream: prose written OVER the map (teaching, ordering, worked examples).
  Taste's home. It may not assert what the map doesn't carry. Writing the guide first = writing plausible sentences;
  the map first = reflected-from-source by construction.

## THE founding finding: the surface splits into two channels

Everything else follows from this.

- **SOURCED — readable now, complete.** The command surface: which commands exist, what you type, which take
  conditionals, what each handler actually does on THIS client. All of it is in the client's own Lua, already
  extracted: `Outputs/client_interface/patch-B/Interface/FrameXML/ChatFrame.lua` + the enUS locale archives'
  `GlobalStrings.lua`. Derived by join. Never recalled.
- **C-SIDE — unreadable, the rim.** The conditional VOCABULARY (`[combat]`, `[mod:shift]`, `[@focus]`).
  `SecureCmdOptionParse` is called **49× in ChatFrame.lua and defined NOWHERE in the Lua**; the runtime census
  buckets it `stock-capi`. The vocabulary lives in the binary. No source read reaches it.

**Consequence:** the map ships COMPLETE on the command channel and PROOF-PENDING on the conditional channel. That
asymmetry is the honest shape, not a gap to paper over.

## Why an agent's own WoW knowledge is INADMISSIBLE here

**This client is not a pure 3.3.5a**, so recall is unreliable in BOTH directions — a conditional can't be ruled out
for being post-WotLK, nor ruled in for being WotLK-stock. Evidence on record:

- `CompactUnitFrame` = a Legion/BfA nameplate system backported into 3.3.5a (fact sheet, live `debugstack`).
- `SLASH_KBMODE1 = "/kb"` → `ToggleQuickKeybindMode()` — **Quick Keybind Mode is a Dragonflight (10.0) feature**,
  present here (`ChatFrame.lua`; `IsQuickKeybinding`/`ToggleQuickKeybindMode` both live in the runtime census).
- `/cast` carries Ascension's own hand-rolled `[@cursor]`/`[@player]` ground-targeting (see FINDS).

The standing rule (`invariants`, and the fact sheet's own hard-won version): **any external code lead — CurseForge,
AI recall, forum posts, wowpedia — is an UNVERIFIED NAME until confirmed against this client.** That applies to macro
conditionals with full force. Nothing enters the basis from memory.

## Established FACT (this session, 2026-07-17 — sourced, reproducible)

Anchors: `patch-B.MPQ` (client UI code) + `enUS/patch-enUS-3.MPQ` ∪ `-2` ∪ `patch-enUS` ∪ `locale-enUS` (tokens).

- **49 `SecureCmdList` commands** — 47 defined handlers + 2 ALIASES (`USE` = `CAST`, `USERANDOM` = `CASTRANDOM`,
  by direct assignment: `ChatFrame.lua:1103`, `:1151`).
- **51 conditional-taking commands total**, and the set is COMPUTED (does the handler call `SecureCmdOptionParse`),
  never hand-listed:
  - 46 of the 49 `SecureCmdList` (44 direct + 2 inherited through the aliases);
  - **3 `SecureCmdList` commands take NO conditionals:** `DUEL`, `DUEL_CANCEL`, `KBMODE`;
  - **5 NON-secure `SlashCmdList` commands DO take them:** `/dismount`, `/equipset`, `/leavevehicle`, `/settitle`,
    `/usetalentspec`. ← the detail a from-memory guide gets wrong.
  - Self-check that validates the count: 44 direct + 5 non-secure = **49 call sites = the grep total**.
- **27 custom commands are declared INLINE in the UI code, not in `GlobalStrings.lua`** — invisible to a
  locale-only enumeration (see rule 2).

## The FIVE emitter rules — each one bought by a real mistake this session

Recorded because each was a wrong answer first, and a naive emitter re-earns every one of them.

1. **Precedence MERGE, not top-archive.** `patch-enUS-3` looks like the winner and is NOT a superset: `/lfg` and
   `/lfm` exist only in lower archives. Merge the locale archives in priority order. Today the archives are purely
   ADDITIVE (`changed: 0` — no token is ever redefined), so precedence affects COMPLETENESS only, not correctness —
   but the emitter must **flag any value conflict loudly** if a future patch starts overriding.
2. **TWO token sources.** `GlobalStrings.lua` **plus** inline `SLASH_*` declarations in the UI code. GlobalStrings
   alone loses all 27 custom commands. Caught by `KBMODE` returning unbound — the loud hole worked.
3. **Conditional support is COMPUTED**, per-handler, never hand-listed. This is what caught the 5 non-secure commands.
4. **Resolve ALIASES.** `USE` = `CAST` by assignment; a line-scan attributes the call to `CAST` only and reports
   `/use` as taking no conditionals — flatly false. Alias resolution is mandatory, not a nicety.
5. **Custom BEHAVIOUR falls out mechanically.** Record which non-stock functions each handler calls, checked against
   the census buckets. `[@cursor]` then surfaces as `/cast → Custom_HandleTerrainClick` on its own, instead of being
   hand-annotated and hoped-complete. (Custom COMMAND and custom BEHAVIOUR are two different axes: `/cast` is a stock
   command with custom behaviour.)

**Method note (bit twice, 2026-07-17):** the scan bug that produced a wrong count both times was owner-tracking that
never reset at the `SecureCmdList` → `SlashCmdList` boundary, misattributing the 5 non-secure calls to whichever
secure key came last (`KBMODE`), which then falsely read as conditional-supporting. The call-sites-vs-grep-total
reconciliation (49 = 49) is the check that catches it. **Any count the emitter reports wants an independent
cross-total like that**, or it's a plausible number, not a measured one.

## The RIM — `conditionals.json`, proof-pending

The vocabulary is C-side, so it must be PROVEN, not recalled. Two channels, both open:

- **Attested-usage seed (sourced, free).** Conditionals the client's OWN Lua/XML uses are proven to exist. Same grain
  as the census's declared pass. **If that grep comes back thin the file ships nearly empty and SAYS so** — an empty
  proof-pending rim is a true statement; a fabricated vocabulary is not.
- **Live differential probe (the completeness check).** `SecureCmdOptionParse` is resident and callable from a plain
  `/run` — which slips UNDER the anti-cheat restart constraint (resident Blizzard API only; same shape as the
  spec-index one-liner). **The design problem:** `[combat]` out of combat and `[fakeconditional]` both return falsey —
  unsupported and currently-false are INDISTINGUISHABLE, so a naive probe silently reports half the vocabulary as
  missing. Test BOTH polarities and read the pair:

  | `[X]` | `[noX]` | verdict |
  |---|---|---|
  | false | true | known, currently false |
  | true | false | known, currently true |
  | false | false | **unsupported** — parser rejects both ways |
  | true | true | ignored / no-op |

  Which row an unknown lands in is itself unknown — the design doesn't need to know in advance, it needs to
  DISTINGUISH. (`anchors-verifiers-over-logging`: make the hole loud.)
- **Standing limit, state it in the basis:** a probe only proves conditionals someone thought to ASK about. The output
  is a proven set with an honest unknown rim — **never an enumeration.** That line is the difference between fact basis
  and a nicer-looking guess.
- **`/luaconsole` may make this near-free** — interactive, no macro, no restart. Unverified: see FINDS.

## FINDS (2026-07-17) — real, and cross-lane

- **`[@cursor]` / `[@player]` ground-targeting WORKS here, hand-rolled by Ascension.** `ChatFrame.lua`'s `/cast`
  handler, their own comment: `-- hack to handle [@cursor] or [target=cursor] macros` → `Custom_HandleTerrainClick()`
  (and `_PlayerPos`), then restores the prior target. Runtime census confirms `Custom_HandleTerrainClick`,
  `_PlayerPos`, `_TargetPos` all resident (`unattributed` bucket). **Stock-WotLK-impossible, unguessable, invisible to
  every macro guide on the internet.** This is the single best proof the slice must be sourced.
- **`Custom_HandleTerrainClick_TargetPos` is resident but NOTHING in `/cast` calls it** — a built-but-unwired
  capability, same shape as the native-aggroHighlight situation. Unscoped; noted, not chased.
- **The client ships dev tooling we may have hand-built around → ADDONS LANE, hand off.** Declared inline in shipped
  UI code: `/luaconsole` `/devconsole` · `/tinspect` `/ti` `/tdump` (table inspector) · `/tracefunc` `/tfunc` ·
  `/dfunc` (watchfunc) · `/cvar` · `/measure` · `/coatalentfooter` · `/bdraft`. The aggroHighlight saga hand-built
  `/coasp scanglobals`/`scantables`/`upvalues` to hunt real function names. **DECLARED ≠ working** — these may be
  dev-gated; that is a live check worth ten minutes, not a claim. Cross-lane: raise with the addons bench, don't
  do their documentation.

## ✅ BUILT + EMITTED (`1b059d1`, 2026-07-17) — the slice stands

`macros/` at root: `tools/emit_macro_basis.py` (deterministic, one command) → `basis/` (routes menu · domains
catalog · 5 domain files · `_meta.json` anchored to patch-B + 4 locale archives). Basis data files byte-idempotent
across re-runs. Census conventions mirrored throughout.

**Five domains, DISCOVERED from source not declared** — `commands` 70 (SOURCED-COMPLETE) · `actions` 17
(SOURCED-COMPLETE) · `conditionals` 0 (PROOF-PENDING, rim fully open) · `api` 24 (limits CONFLICT) ·
`statedrivers` 5 (provenance OPEN). **Grain differs per domain and each file states its own** — commands/actions
cite freely, conditionals cite not at all.

**What the domain approach found that the trace would have missed** (the reason Battlewrath's reframe mattered):

- **`actions/` — the whole `/click` half of macros.** 17 `SECURE_ACTIONS` types, each self-reporting the attributes
  it reads (`spell`→`"spell"`, `macro`→`"macro"`/`"macrotext"`, `click`→`"clickbutton"`). The sheets' paired
  (lever, handling) rule, extracted rather than annotated. Chasing commands alone never reaches it.
- **`[@cursor]` extends to `/castsequence` AND `/castrandom`**, not just `/cast` — rule 5 found what the hand-read
  missed.
- **The client CONTRADICTS ITSELF on macro limits.** `Blizzard_MacroUI` declares GLOBAL `MAX_CHARACTER_MACROS=36`;
  `QuickKeybindActionPicker` declares a LOCAL `18` (the stock WotLK value) shadowing it in that file. **Hypothesis
  only, not fact:** the Dragonflight-backported picker kept the stock local and cannot see character macros 19–36.
  Live check = `GetNumMacros()`. Flagged in `api.json`; **do not state a macro limit as fact until probed.**
- **The attested-conditional grep measured ZERO** — as pre-committed, the file ships empty and says so.

**The emitter was wrong three times and was FIXED each time, never hand-worked around** (the tooling contract):
scoped to one file → discovered 27 custom commands and dropped 26 (widened to the whole extraction; `SecureCmdList`
is ChatFrame-only *verified*, `SlashCmdList` has 104 defs across `Ascension_*` + DebugTools) · knew one handler FORM
→ now knows three (inline / alias / **named-ref**) and terminates bodies at the **definition's own indent** because
`BDRAFT` nests in a block · a counts label lied (`non_secure_taking_conditionals: 21` when only 5 do) → split.

**Two verifiers, because miscounting is this slice's failure mode:** the **cross-total** (handlers calling
`SecureCmdOptionParse` == raw call sites; 49=49) which catches the owner-tracking misattribution that produced a
wrong count twice by hand — *if it ever fails the conditional counts are wrong, don't trust them*; and the **holes
report** (declared-without-handler / body-unresolved), where an unresolved body means `calls` is **blind** and
absence of `custom_behaviour` proves nothing. An empty holes list is a healthy one.

## Open / next

- **★ THE LIVE PROBE — STAGED as a bounded ask (`macros/probe/ASK.md`), pointer in `addons/backlog.md` #4.**
  The dev console is **CONFIRMED real** (Battlewrath, 2026-07-17), so the channel is live and interactive. The ask
  is one bounded pass: ~90 reads, pure, resident-API-only (every call verified against the runtime census),
  compiles under Lua 5.1, exercised headlessly. **The addons bench owns the harness** — they configure coadump.
  **Lands RAW** (`schema=macros.probe.raw/1`): the parser's own returns + a context stamp, NO verdicts computed
  in-game — emission over interpretation, so a wrong matrix costs a re-derivation not another client session.
  Read the `[@banana]` control row first; it decides how all 13 target rows are read.
- **THE MAP (this bench's next build, once data exists)** — derive verdicts from the raw record, triangulating each
  flag against its independent context witness (`[combat]` false WITH `inCombat=true` = a real anomaly, not just
  "false"), write `proof_mark` back to `reference/candidates.json`, graduate the proven set into
  `basis/conditionals.json`. **Broad capture first, maps consolidate after** (Battlewrath, 2026-07-17).
- **The macro-limit conflict** — one `GetNumMacros()` call settles it. Cheap, and it's a candidate real bug in the
  backported picker (would silently hide character macros 19–36).
- **`statedrivers` provenance** — resolved for free by the **clean-profile census re-run already banked** in
  `Addons_load.md` (splits `unattributed` = engine-custom ∪ user-addon). No new work; just consume it when it lands.
- **The guide** — prose over the map, downstream, once the rim is closed enough to teach from. Not before.
- **`GlobalStrings.lua` is NOT in patch-B** — it lives in the enUS locale archives (4 of them carry it). Any future
  census work wanting locale strings inherits the precedence-merge rule above, where it DOES bite (`/lfg`, `/lfm`).

## Related

- `addons/maps/census/` — the sibling map + every convention this slice copies. `Addons_load.md` — the lane, the
  standing cautions (incl. "the Cowork mpyq wall doesn't hold locally"), the extraction debts.
- `addons/Materials/Ascencion behaviour/AGENT_HANDOFF_FACT_SHEET.md` — **STALE on MPQ extraction** ("not extractable…
  concluded not worth pursuing"). False locally: `extract_interface.py` uses mpyq successfully and `patch-B` is
  extracted on disk. Likely cause: the Cowork session tested the SMALLEST archives first — exactly the ~8
  listfile-less art archives that genuinely can't be listed — and generalized. Operations already carries the
  correction (`Addons_load.md`, `STATE.md`); the fact sheet itself still misleads. A fresh agent this session read it
  and nearly ruled out the client's own FrameXML — i.e. this whole slice's source channel. Correction is queued.
