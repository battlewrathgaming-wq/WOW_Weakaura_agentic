# Aggro Highlight / Threat Indicator - Flattened Findings

*(Copied here from `COA_GuardianPlates/AGGRO_HIGHLIGHT_FINDINGS.md` as of v3.5.42 for a self-contained archive. The original stays in place at the addon root; this copy won't auto-update if that file changes later - check the original for anything newer than v3.5.40.)*

## SUPERSEDED (v3.5.39/40) - the v3.5.38 verdict below was wrong on the mechanism

A follow-up research pass argued this client is actually a Legion/BfA-era CompactUnitFrame nameplate backport, not the plain WotLK path v3.5.38 concluded was unreachable. A live `/coasp watchaggro` capture confirmed it directly: the aggroHighlight texture's color is driven by `CompactUnitFrame.lua:773 UpdateAggroHighlight`, called via `UpdateAll <- SetUnit <- Ascension_NamePlates\NamePlateDriver.lua:227` - a real callstack, not an inferred name. `CompactUnitFrame.lua` itself is packed inside this client's MPQ archives (not a loose readable file), so this could only be confirmed by catching it live, which is exactly what the watchaggro probe was built to do.

The `watchaggro` hook that caught this was installed on the aggroHighlight **texture instance's own `SetVertexColor` method** (`hooksecurefunc(texture, "SetVertexColor", ...)`), not a guessed global function name - the same mechanism, upgraded from logging to recoloring, now backs `ns.SetNativeAggroHighlightColor` as a persistent per-texture post-hook (v3.5.40) that re-applies our desired color immediately after any native call, with a re-entrancy guard. This should actually hold now, unlike v3.5.33's hook which targeted `UnitFrame_UpdateThreatIndicator` - a function nameplates never passed through at all.

Status (as originally written): built, not yet re-wired into production or confirmed holding on screen. See `CHANGELOG.md` in this folder for what happened next (v3.5.41/42 and the final live-test result).

---

## RESOLVED (v3.5.38) - superseded above, kept for the historical trail

Three independent research passes (source-verified against two separate 3.3.5a FrameXML mirrors - Gethe's `3.3.5` tag and andrew6180's build-12340 dump - plus retail/Cataclysm source and WotLK nameplate-addon prior art) converged with this addon's own real `tfunc UnitFrame_UpdateThreatIndicator` traces (captured via the Ascension_UIDevelopmentTools dev console): both live captures showed only `PartyMemberFrame1/2PetFrameFlash` - ordinary party-pet threat-flash traffic, never anything named `aggroHighlight`.

**Verdict**: `UnitFrame_UpdateThreatIndicator` is structurally gated on a real unit token (`indicator.unit`/`indicator.feedbackUnit`, feeding `UnitThreatSituation`) that nameplates in this client's underlying model never carry into this function - it cannot be the nameplate aggroHighlight's driver. This is confirmed, not assumed - it matches every real trace captured.

Separately: `aggroHighlight` itself is a Cataclysm 4.0.1 CompactUnitFrame invention (parentKey-driven, `CompactUnitFrame_UpdateAggroHighlight`), completely absent from stock 3.3.5a. Yet a real frame matching that exact name and structure genuinely exists on THIS client (found via live `/coasp probe`, see below) - so Ascension backported or reimplemented something aggroHighlight-shaped, but through a mechanism with no Lua-reachable hook, mutable color table, or closure upvalue - nothing this addon can reach from inside its own sandbox.

**Action taken**: retired the `hooksecurefunc` hook on `UnitFrame_UpdateThreatIndicator` and the native-recolor "harmless bonus" calls from the production threat path. The hand-rolled glow texture (already production-primary since v3.5.29) is now, definitively and permanently, the addon's sole production threat signal. The locate/recolor primitives and isolated render-test modules remain in place as diagnostic tools, not production signal, in case the legacy WorldFrame-child-scan approach (the one real WotLK addons like TidyPlates/NotPlater use) is ever worth revisiting.

---

Client: WotLK 3.3.5a, Ascension private server ("Conquest of Azeroth", realm Vol'jin).
Addon: COA_GuardianPlates ("COA State Plates"), nameplate threat-coloring module (EnemyPlates.lua + Core.lua).
Nameplate driver: Ascension_NamePlates (client-embedded, no readable Lua/.toc source - confirmed via file search, same as Blizzard_NamePlates-style system addons).

## Goal

Enemy nameplates have TWO independent threat-state signals fighting for the same visual space:

1. **Our own hand-rolled glow** - a Texture region we create and own outright (tinted per threat state: secure/warning/danger). Fully reliable, zero re-assert issues, already production-primary.
2. **The client's native "aggroHighlight" indicator** - Ascension_NamePlates' own built-in "you currently have aggro on your target" cue. We'd like to recolor this to a neutral white (so it reads as plain presence, not a competing color signal) instead of its hardcoded red, or failing that, understand definitively why we can't.

## Confirmed: the native aggroHighlight structure

Found via `/coasp probe [unit]` (depth-limited recursive dump of every child frame/region under a nameplate):

- Nested inside the enemy nameplate's health bar: `Frame "<healthBarName>aggroHighlight"` containing `Texture "<healthBarName>aggroHighlightTexture"`.
- Texture path: `Interface/TargetingFrame/UI-TargetingFrame-BarFill`.
- Hardcoded `vertexColor = 1,0,0,1` (red), draw layer OVERLAY.
- Only shown by native logic when the player holds aggro on their own literal CURRENT TARGET, AND only while genuinely grouped (confirmed by Battlewrath: "the aggro highlight only works in a party" - solo testing cannot reproduce it at all).

## Confirmed: the re-assert race

`ns.SetNativeAggroHighlightColor(plate, color)` locates the texture and calls `SetVertexColor` on it. This call:

- **Always succeeds at the Lua level** - confirmed across many live `/coasp log` captures, zero errors, every single time.
- **Never visibly sticks in real combat** (pre-v3.5.40) - Battlewrath's direct test result: "IN combat, in a group, it was red. As is stock." - despite our white recolor call reporting success on the same tick.

Conclusion: something in the native code re-drives the texture's own color faster/more persistently than a one-shot-per-state-change call can hold it - a genuine timing race, not Blizzard's secure-execution/taint system (ruled out: taint blocks manifest as explicit `ADDON_ACTION_BLOCKED` errors, which never once appeared).

## Confirmed: the real driver function (superseded understanding - see SUPERSEDED section above)

`/coasp scanglobals threat` returned `UnitFrame_UpdateThreatIndicator` as a real, existing WotLK 3.3.5 global - but two independent `tfunc` traces proved nameplates never route through it (see below). The REAL driver, found later via `watchaggro`, is `CompactUnitFrame.lua:773 UpdateAggroHighlight` (file-local, not a plain global) - see CHANGELOG.md v3.5.39/40.

### Live `tfunc UnitFrame_UpdateThreatIndicator` trace results (real, in-game, both captures)

```
self = PartyMemberFrame1PetFrame { ... threatIndicator = PartyMemberFrame1PetFrameFlash {} ... unit = "partypet1" ... }
event = "UNIT_THREAT_SITUATION_UPDATE"
```
```
self = PartyMemberFrame2PetFrame { ... threatIndicator = PartyMemberFrame2PetFrameFlash {} ... }
```

Both real captures show the indicator named `"...Flash"` (party/pet frame convention), fired by `UNIT_THREAT_SITUATION_UPDATE` on `partypet1`/`partypet2` - ordinary party-pet-frame threat-flash traffic, NOT nameplate traffic.

## Diagnostic tools built (all in Core.lua, exposed via `/coasp` - see CODE_MAP.md for exact line numbers)

- `scanglobals <substring>` - lists every global FUNCTION whose name contains the substring.
- `scantables <substring>` - lists every global TABLE whose name contains the substring. **Result: clean negative** - no `ThreatColor`/`ThreatBarColor`-style table exists as a global.
- `upvalues <funcname>` - dumps closure upvalues via `debug.getupvalue`. **Result: blocked** - "not available on this client."
- `watchaggro [unit]` - hooks the real frame/texture INSTANCE directly, logs debugstack on Show/Hide/SetVertexColor. **This is what finally found the real driver.**
- `suppressaggro on|off [unit]` - persistent Hide() hook, same pattern as the color hook. Built, not yet confirmed working live (see CHANGELOG.md's final entry).

## Other context gathered (external research)

- A mature, actively-maintained multi-expansion nameplate-threat addon confirms the general re-assert-race phenomenon is real Blizzard-client behavior, but that same addon doesn't fight the race at all on Classic-family clients - it just sets its own color directly, no hook.
- No public source was found that specifically documents Ascension's own nameplate-to-CompactUnitFrame wiring - this appears to be genuinely undocumented, server-specific behavior, only confirmable by live capture (which is what `watchaggro` was built for and what eventually worked).
- A Google AI Mode search and a CurseForge addon (TargetNameplateIndicator) both surfaced plausible-sounding API/function names that turned out NOT to match this client's real, live-captured behavior - both were treated as unverified leads rather than acted on directly, consistent with this project's "verify before trusting a name" rule established early in the saga.

## Final status (end of session, v3.5.42)

Hand-rolled glow remains the addon's sole production threat signal - reliable, always renders, no per-frame cost. The native recolor (v3.5.40) and suppress (v3.5.42) primitives are built and dormant, using a mechanism now PROVEN to reach the real driver (unlike the earlier v3.5.33 dead end). A live macro test of the suppress concept (bypassing the addon, pure `/run`) showed no visible effect - cause not yet isolated. Paused due to testing fatigue, not a technical dead end - see CHANGELOG.md's closing entry for exactly where this left off.
