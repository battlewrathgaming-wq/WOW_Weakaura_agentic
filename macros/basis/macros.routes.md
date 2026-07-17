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

## conditionals (0) - `conditionals.json`  ·  _PROOF-PENDING - RIM FULLY OPEN_
the option vocabulary; C-side; probe is the SOLE channel

- **attested: 0** - the client's own code uses NO conditional literal. Not thin: zero.
- the live differential probe is the SOLE channel; see `probe_design`.

## api (24) - `api.json`  ·  _runtime-attested x source constants_
the macro C API + limits (limits CONFLICT - unresolved)

- **LIMITS CONFLICT** (client disagrees with itself): MAX_CHARACTER_MACROS - unresolved from source, do not state a limit as fact

## statedrivers (5) - `statedrivers.json`  ·  _runtime-attested; PROVENANCE OPEN_
the 2nd consumer of the conditional vocabulary

- PROVENANCE OPEN: live, but no SecureStateDriver.lua in the extraction and `unattributed` mixes engine-custom with user-addon
