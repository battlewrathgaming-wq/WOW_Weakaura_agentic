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

**Consequence (as of the founding read):** the map shipped COMPLETE on the command channel and PROOF-PENDING on the
conditional channel. That asymmetry was the honest shape, not a gap to paper over — and it held exactly as stated:
the conditional channel could ONLY be closed by asking the client, which is what happened on 2026-07-17. **Both
channels are now closed** (commands: sourced-complete · conditionals: LIVE-PROVEN, 5 contexts, with 4 honest
AMBIGUOUS). The founding split was right about the shape AND about the only way out of it.

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

## ~~The RIM — proof-pending~~ → **CLOSED by the capture. The matrix in it was DISPROVEN.**

_Superseded 2026-07-17 by the 5-context capture (see the LANDED section below). Kept only as
the record of a wrong design, because the wrongness is the lesson._

**What this section used to say**, and shipped into `probe/README` and `conditionals.json`:

| `[X]` | `[noX]` | verdict *(as designed — WRONG)* |
|---|---|---|
| false | false | **unsupported** — parser rejects both ways |

**The client says otherwise.** That row **never occurs** — 5 contexts × 63 flags, not one
both-nil. **The parser IGNORES an unknown conditional; the clause PASSES.** So an unsupported
conditional reads *exactly* like a true one, and the polarity pair — the probe's whole
designed discriminator — **cannot discriminate**.

**Why the design failed:** it assumed unknown ⇒ reject. That assumption was never sourced;
it was the one piece of the probe I reasoned out rather than derived, and it's the piece that
broke. The rest of the ask (raw capture, context stamp, five contexts) is what survived and
carried the answer.

**Why it didn't cost anything:** the ask landed **RAW**. A wrong matrix cost a re-derivation
offline, not another client session. That was the entire reason for refusing to compute
verdicts in-game — and it paid, exactly as argued, on the first pass.

**The attested-usage seed** (the other half of this section) stands as recorded: it measured
**zero**, and that zero was honest. The live probe genuinely was the sole channel.

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

## ✅ THE CAPTURE LANDED + THE MAP IS BUILT (2026-07-17) — conditionals.json is FACT

Five contexts (rest · spell-form · stealth · combat · mounted), addons-bench harness,
Battlewrath live. Labels: `addons/landing/records/20260717_contexts.md`. Map:
`macros/tools/derive_verdicts.py` → `basis/conditionals.json`. Derived **offline** from the
landed raw, so a wrong rule costs a re-derivation, never another client session — which is
exactly why the ask landed RAW.

### ★★ The designed matrix was WRONG, and the data said so

I shipped *"[X] false, [noX] false ⇒ UNSUPPORTED — parser rejects both polarities."*
**That row never occurs.** Across 5 contexts × 63 flags there is not one both-nil. **The
parser IGNORES an unknown conditional — the clause PASSES.** So `[unknown]="Y"`,
`[nounknown]=nil` — *identical* to a known-true conditional. The polarity pair, the probe's
entire designed discriminator, **cannot discriminate.**

Proven, not inferred: `[petbattle]` reads TRUE in all five (no pet battle system exists on
3.3.5a). `[resting]` reads TRUE in all five while `IsResting()` is falsey in all five.

**What saved the pass: the CONTEXT STAMP and FIVE contexts** — both added late, on
Battlewrath's *"get the data set broad"* and *"triangulate"* steers. Without them this
capture would have graduated ~10 retail-only conditionals into the basis **as fact**.
Broad-first wasn't thoroughness; it was the thing that made the answer true.

**The rule that replaces it:** reads FALSE anywhere ⇒ **evaluated** ⇒ supported (an ignored
clause can never read false). For constant-TRUE: the wiki names the API each conditional
**mirrors**, the census says whether it's **resident here** — subsystem absent + constant
true + ignore-semantics ⇒ ignored. Both ends sourced, joined mechanically. Where the API
*is* resident (`overridebar`, `possessbar`) the verdict stays **AMBIGUOUS** rather than
being talked into place.

### ★★ The forecast test — TOTAL SEPARATION, ZERO CROSSOVER

| era signal (predicted **before** the capture) | SUPPORTED | UNSUPPORTED | AMBIGUOUS |
|---|---|---|---|
| archive-documented (WotLK-era) | **53** | **0** | **0** |
| post-3.3.5a (patch-dated + retail-only) | **0** | 6 | 4 |

The era signal — from `{{Patch}}` annotations, before anyone touched the client — predicted
the live verdict **exactly**. Stating the expectation is what made it a test instead of a
story. It also retires the reverse error for good: inferring era from a wiki's *absence*
predicted the same rows **for the wrong reason**.

### ★ The layer finding — hypothesis raised this session, now strongly supported

**Ascension extends at the LUA/HANDLER layer, not the C parser.** Zero post-3.3.5a
conditionals work ⇒ the parser is untouched stock 3.3.5a. Yet `@cursor` — Legion 7.1.0 — **is**
present, because it's hand-rolled in `ChatFrame.lua` via `Custom_HandleTerrainClick`. That
explains the perfect era separation *and* predicts where future CoA macro capability can come
from (a handler) and where it cannot (the vocabulary).

### Targets — the control row settled it

`[@banana]` returned `target='banana'` in **all five** contexts ⇒ **`@` is a pass-through
string**; the parser never validates units. The matrix never applied to targets.
`@nameplate` **RESOLVES** (real unit) — independently confirming the guardian-tracker's
plate-token finding from a different instrument. `@cursor` = **NOT-A-UNIT**, as both
unit-token wikis said.

### Landmine found and defused

`emit_macro_basis.py` — **the documented regenerate command** — clobbered the derived
verdicts back to "rim FULLY OPEN", silently, while printing success. The next agent
following the README would have destroyed the capture's result. `conditionals.json` now
belongs to the **map**; the emitter reads it and refuses to write it.

## ★ THE REAL GAP: I PROVED THE WORDS, NOT THE SENTENCE

_Surfaced 2026-07-17 by Battlewrath asking the only question that matters: **"Does the
information gathered serve you in macro forming?"** Answered by WALKING a macro, not by
opinion — walks prove the JOINS where harnesses prove parts._

**The walk.** The commonest macro shape there is:
`/cast [@mouseover,help,nodead] X; [@target,help,nodead] X; [@player] X`

Against the basis: `/cast` takes conditionals ✓ · `[help]` SUPPORTED ✓ · `[nodead]` SUPPORTED ✓
· `@target`/`@player` RESOLVE ✓ — **and then `,` `;` `#showtooltip` are all `???`.**

**Every term proven. Not one connective.** A macro is mostly *sentence*, and the sentence is
where the logic lives.

**The audit: 14 grammar claims, ALL `reference/UNPROVEN`. Not one asked of the client.** The
basis proves exactly three grammar facts — `no` negates · unknown passes · `@` is pass-through
— and all three fell out *incidentally* from probes aimed at the vocabulary. **No grammar
question was ever asked on purpose.**

**Why it is the correctness blocker, not a nicety:** the parser fails SILENTLY by design. If
`,` is not AND, the macro misbehaves and says nothing — the identical trap, one layer up. The
vocabulary work does not protect against it.

**⇒ the basis makes the role SAFE, not yet CAPABLE.** It can say which conditionals lie. It
cannot yet compose them.

### The sequence — same pattern as the vocabulary, one layer up

1. **Research run** (Battlewrath's proposal: *"macro guides and common gramma"*) — hits BOTH
   gaps at different tiers. **common grammar** → the ask-list for a grammar probe (reference,
   feeding a live question). **macro guides** → **curated intent**: which *shapes* solve which
   problems — the corpus-equivalent for macros, and what makes the role *useful* rather than
   merely not-wrong.
2. **The grammar probe** — cheap, same chat channel, mostly settled by three rows:
   `[nocombat,nocombat]` vs `[combat,nocombat]` (is `,` AND?) ·
   `SecureCmdOptionParse("[combat]A;[nocombat]B")` (does `;` + first-true hold?) ·
   `[mod:shift/ctrl]` (is `/` OR inside an arg?). **State the required context this time** —
   probe A's control row died because it silently assumed rest.
3. **Graduate** the proven grammar into `basis/`. Reference never becomes basis by itself.

**Already covered — do not re-fetch:** the CoA wiki's mouseover section carries three worked
forms + the priority explanation. Curated intent, ingested and stamped. *(I called it a gap
while the answer sat in `reference/`. Cite internal data first — that is twice today.)*

**Channel limit found:** `@mouseover` may be structurally UNPROBEABLE from chat — typing means
the mouse left the unit, and a `nil` would be ambiguous. Needs a keybound macro. See
`probe/README`.

## Open — small, and each one precisely askable now

- **The AMBIGUOUS 4** (`known`, `overridebar`, `possessbar`, `pvpcombat`) — constant-TRUE
  with no witness and no false sibling. `overridebar`/`possessbar` mirror APIs that ARE
  resident, so they may be real. **A flag control row settles the whole class:** the ask has
  `[@banana]` for targets but **no flag control** — add `[zzznotaconditional]` and the
  ignore-signature becomes a direct read instead of an inference.
- **Macro limits: STILL UNRESOLVED, and now precisely askable.** The stamp read
  `MAX_ACCOUNT_MACROS`/`MAX_CHARACTER_MACROS` as **nil** — `Blizzard_MacroUI` is
  **load-on-demand**, so those globals don't exist until the macro window opens. That also
  re-reads `Asc_MacroBank`'s `MAX_CHARACTER_MACROS or 18` as a **load-order guard, not a
  version guard** — which is how I first read it. Fix: `MacroFrame_LoadUI()` (or open the
  window) *then* read. `GetNumMacros()` works regardless (C API): 4 account / 0 character.
- **`[bonusbar:1]` was never asked** — the stamp shows `bonusBarOffset=1` in stealth, so it
  should be true, but the ask only carries `[bonusbar:5]` (the only value the wiki
  documented). **The arg list is only as wide as the source's examples.**
- **`statedrivers` provenance** — still free from the banked clean-profile census re-run.

### 4. The guide — **a ROLE, not an artifact. Not queued; already live.**

Corrected 2026-07-17 — Battlewrath: *"Guide in this primary case is role. You're my guide, in the formation of macro
creation."*

This step used to read "prose over the map, last, downstream, not before the rim closes." **That mis-frames the
whole slice.** The guide is the AGENT, guiding macro creation with Battlewrath. It is **not blocked on anything** —
it is running now. A guide *document* may follow, or may never; it is a possible output of the role, not the point
of it.

**So what is the basis FOR?** Not a doc to generate from. **It is what makes the guidance TRUE** — the substrate
that lets the role say *"sourced, cite it freely"* vs *"unproven, and here is exactly how unproven"*. Without it the
role degrades into a confident voice reciting retail defaults at a client that backports Legion into WotLK. That is
the failure the whole slice exists to prevent, and it was never a documentation failure.

**The discipline carries over unchanged, only the medium differs:** the role **may not assert what the map doesn't
carry**. The conversation is the contained space where taste lives (the ADR line holds); `basis/` still can't lie,
and `reference/` is still never authority.

**What the role must not get wrong today** (all sourced, all usable NOW — the rim does not gate them):
- the three-way **`cursor` collision** — `@cursor` = a ground location (7.1.0, hand-rolled here) / `@mouseover` = a
  unit / `[cursor]` = a flag for what the cursor HOLDS. Wrong three ways at once if conflated.
- **`@unit` ≠ `[flag]`** — different mechanisms, different proof. `@` is pass-through (pending the control row).
- **`/use` takes conditionals** (via the `USE`=`CAST` alias), and **5 non-secure commands do too**.
- **`[@cursor]` works on `/cast`, `/castsequence` AND `/castrandom`** — Ascension's own hack.
- **Never state a macro limit as fact** — the client contradicts itself (MacroUI 36 vs QuickKeybind local 18).
- **Never state a conditional as supported** — `conditionals.json` is empty, and that emptiness is honest. Say
  "unproven", not a retail default.

**Curated intent feeds the role directly** (`reference/`): the worked examples are what players actually want a
macro to DO. That is the role's design input, available now, independent of the probe.

## `reference/` — standing, settled

**Reference material, not authority — the same standing as `corpus/`** (Battlewrath, 2026-07-17: *"Track them.
Their reference material, not authority. Just as much as the corpus is reference. They help fill curated intent."*).
`corpus/` harvests how people build auras; `macros/reference/` harvests how people write macros. Neither is a fact
about the client.

**Two uses — the second is easy to miss.** (1) The **ask-list**: the only non-invented source for the probe's
questions. (2) **Curated intent**: the worked examples are what players actually *want* a macro to do — design input
for the eventual guide, the same role a `corpus/patterns/` entry plays for auras.

**The raws are TRACKED on purpose** — don't prune them as third-party bloat. The client study copy is *gitignored*
because its extractor regenerates it exactly; a wiki fetch **cannot** be regenerated (the page moves, the revid with
it), so the saved raw **is** the reproducibility. Attribution + revid + sha256 travel in `*.provenance.json`.

## Banked — real, non-blocking, no new work

- **`statedrivers` provenance** — resolved *for free* by the clean-profile census re-run already banked in
  `Addons_load.md` (splits `unattributed` = engine-custom ∪ user-addon). Just consume it when it lands.
- **The engine macro limit** — needs a write test (create macro 19+). Changes state; out of scope for a pure-read
  pass. Only worth it if the limit ever matters to a product.
- **`Custom_HandleTerrainClick_TargetPos`** — resident but nothing calls it. Built-and-unwired, same shape as the
  native-aggroHighlight case. Noted, not chased.
- **Ascension's dev tooling** (`/luaconsole` `/tinspect` `/tracefunc` `/dfunc` `/cvar`) — **addons lane**, handed
  across. Declared in shipped UI code ≠ working; the console is confirmed, the rest isn't.

## Standing — so they don't get re-learned

- **Agent WoW recall is INADMISSIBLE as fact here, admissible as a QUESTION.** The probe adjudicates; a wrong
  candidate costs one row, a wrong fact poisons the basis.
- **Absence is never evidence.** It bit twice: the era classifier inferred "post-wotlk" from a wiki's silence, and a
  wiki *typo* silently ate `@nameplate`. Patch annotations are evidence; silence is not.
- **Cite internal data first — as leverage, not a substitute.** The WA sheets are a local sourced witness on this
  client and beat any retail doc where they overlap. But they carry **zero conditionals**, omit `mouseover`, and
  hold no patch dating: WA **listing** a token corroborates it, WA **omitting** one proves nothing. Complementary,
  not redundant.
- **Counts belong in the artifacts, not in prose.** Every hand-written number in this slice went stale within hours.
  `candidates.json`→`counts`, `probe_rows.json`→`counts`, `basis/_meta.json`→`counts`, and
  `completeness_check.incomplete` **must be empty**.
- **A `continue` that skips downstream derivation is this codebase's recurring trap** — it silently stripped
  `@cursor`'s witness, then silently nulled `probe_method` on 15 candidates, both while the run printed success.
  Fix the trap, not the instance.

## Related

- `addons/maps/census/` — the sibling map + every convention this slice copies. **`addons/backlog.md` #4** = the
  staged ask. `Addons_load.md` — the lane, the standing cautions, the extraction debts.
- `Weak Auras/engine/Fact_basis/sheets/domains.json` — the LOCAL unit-token witness (`baseUnitId`/`multiUnitId`).
  `corpus/patterns/guardian-health-tracker.md` — `@nameplate` **live-proven**, with the plate-population boundary.
- `addons/Materials/Ascencion behaviour/AGENT_HANDOFF_FACT_SHEET.md` — **the MPQ claim was CHALLENGED + CORRECTED
  in place (`c7d1cbe`)**, framed as true-in-its-env (Cowork sandbox, pre-code-agents) with the original kept as
  history. It also now carries a lead for the addons bench's open #266: the now-readable `CompactUnitFrame.lua`
  gates on `optionTable.displayAggroHighlight` before touching the texture.
