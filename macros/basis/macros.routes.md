# macros.routes - the CoA macro surface (browse menu)

_Anchor: patch-B.MPQ sha256 `a8336170a7d97b13...` | emitted 2026-07-17 | grain: PER DOMAIN, they differ - each file states its own._

**Start here, open one domain.** Emitted by `macros/tools/emit_macro_basis.py`; nothing here is written from an agent's WoW knowledge (this client is not a pure 3.3.5a). Foundation: `operations/Macros.md`.

## commands (70) - `commands.json`  ·  _SOURCED-COMPLETE_
the typed verbs

- entry rule: **(a)** secure · **(b)** takes conditionals · **(c)** CoA-custom. Stock chat/UI commands stay out.
- 49 SecureCmdList · 21 non-secure kept · **51 take conditionals** · 17 CoA-custom (declared INLINE, invisible to GlobalStrings)
- secure commands taking NO conditionals: DUEL, DUEL_CANCEL, KBMODE
- **non-secure that DO take conditionals**: DISMOUNT, EQUIP_SET, LEAVEVEHICLE, SET_TITLE, USE_TALENT_SPEC
- **custom BEHAVIOUR** (stock command, non-stock handler): CAST, CASTRANDOM, CASTSEQUENCE, CVAR, MEASURE, TRACEFUNC, USE, USERANDOM, WATCHFUNC
- **CoA-custom commands**: /ab, /atlasbrowser, /av, /bdraft, /coatalentfooter, /coatfooter, /cvar, /devconsole, /dfunc, /kb, /logdebug, /loginfo, /luaconsole, /measure, /nper, /oldetrace, /oldeventtrace, /sldebug, /tdump, /tfunc, /ti, /tinspect, /tracefunc, /version, /wcroll

## actions (17) - `actions.json`  ·  _SOURCED-COMPLETE_
the `type` vocabulary (/click)

- types: action, actionbar, assist, attribute, cancelaura, click, focus, item, macro, mainassist, maintank, multispell, pet, spell, spellbook, stop, target

## conditionals (63) - `conditionals.json`  ·  _LIVE-PROVEN (5 contexts, triangulated) - owned by macros/tools/derive_verdicts.py_
the option vocabulary; C-side; the live probe is the SOLE channel and it has RUN

- **LIVE-PROVEN 2026-07-17** — 5 contexts, triangulated against an independent witness stamp. **Owned by `macros/tools/derive_verdicts.py`, NOT this emitter.**
- flags: 53 supported · 10 UNSUPPORTED-IGNORED · 0 AMBIGUOUS (honest — not guessed)
- **the parser IGNORES unknown conditionals (the clause PASSES)** — it does not reject them. The designed polarity matrix could not have seen this; the context stamp is what caught it.
- **era diff CONFIRMED, zero crossover:** every WotLK-era conditional supported; not one post-3.3.5a conditional is.

## api (24) - `api.json`  ·  _runtime-attested x source constants_
the macro C API + limits (limits CONFLICT - unresolved)

- **LIMITS: the SOURCE still disagrees with itself** (MAX_CHARACTER_MACROS) — but the LIVE answer is settled: **MAX_CHARACTER_MACROS = 36**, not 18 (chat probe, 2026-07-17, after `MacroFrame_LoadUI()` — the globals are LOAD-ON-DEMAND, which is why they read nil in the capture).
- ⇒ **QuickKeybindActionPicker's local `18` is a stale shadow**, so the backported picker likely cannot see character macros 19–36. A real bug in THEIR client — evidenced, not hypothesised. The ENGINE limit is still unproven (needs a write test; not asked).

## statedrivers (5) - `statedrivers.json`  ·  _runtime-attested; PROVENANCE OPEN_
the 2nd consumer of the conditional vocabulary

- PROVENANCE OPEN: live, but no SecureStateDriver.lua in the extraction and `unattributed` mixes engine-custom with user-addon
