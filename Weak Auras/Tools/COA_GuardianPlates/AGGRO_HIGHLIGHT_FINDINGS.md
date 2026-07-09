# Aggro Highlight / Threat Indicator - Flattened Findings

## SUPERSEDED (v3.5.39/40) - the v3.5.38 verdict below was wrong on the mechanism

A follow-up research pass argued this client is actually a Legion/BfA-era CompactUnitFrame nameplate backport, not the plain WotLK path v3.5.38 concluded was unreachable. A live `/coasp watchaggro` capture confirmed it directly: the aggroHighlight texture's color is driven by `CompactUnitFrame.lua:773 UpdateAggroHighlight`, called via `UpdateAll <- SetUnit <- Ascension_NamePlates\NamePlateDriver.lua:227` - a real callstack, not an inferred name. `CompactUnitFrame.lua` itself is packed inside this client's MPQ archives (not a loose readable file), so this could only be confirmed by catching it live, which is exactly what the watchaggro probe was built to do.

The `watchaggro` hook that caught this was installed on the aggroHighlight **texture instance's own `SetVertexColor` method** (`hooksecurefunc(texture, "SetVertexColor", ...)`), not a guessed global function name - the same mechanism, upgraded from logging to recoloring, now backs `ns.SetNativeAggroHighlightColor` as a persistent per-texture post-hook (v3.5.40) that re-applies our desired color immediately after any native call, with a re-entrancy guard. This should actually hold now, unlike v3.5.33's hook which targeted `UnitFrame_UpdateThreatIndicator` - a function nameplates never passed through at all.

Status: built, not yet re-wired into production or confirmed holding on screen. Test via the isolated "nativeAggroColor" render test or real combat before deciding whether native recolor returns as production signal.

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
- Only shown by native logic when the player holds aggro on their own literal CURRENT TARGET - confirmed via live force-Show tests that this Show/Hide gate can't be reliably overridden from outside (Show()/SetAlpha(1) succeed at the Lua level but don't change on-screen behavior on non-targeted plates).

## Confirmed: the re-assert race

`ns.SetNativeAggroHighlightColor(plate, color)` locates the texture (via predictable name pattern, falling back to a `GetChildren()`/`GetRegions()` scan) and calls `SetVertexColor` on it. This call:

- **Always succeeds at the Lua level** - confirmed across many live `/coasp log` captures, zero errors, every single time.
- **Never visibly sticks in real combat** - Battlewrath's direct test result: "IN combat, in a group, it was red. As is stock." - despite our white recolor call reporting success on the same tick.

Conclusion: something in the native code re-drives the texture's own color faster/more persistently than our one-shot-per-state-change call can hold it. This is a genuine timing race, not Blizzard's secure-execution/taint system (ruled out: taint blocks manifest as explicit `ADDON_ACTION_BLOCKED` errors, which never once appeared; `SetVertexColor` is not a protected function).

## Confirmed: the real driver function

`/coasp scanglobals threat` (walks `_G` for matching global function names) returned `UnitFrame_UpdateThreatIndicator` as a real, existing WotLK 3.3.5 global. Its real stock source (from `wowgaming/3.3.5-interface-files`, `Interface/FrameXML/UnitFrame.lua`):

```lua
function UnitFrame_UpdateThreatIndicator(indicator, numericIndicator, unit)
    if ( not indicator ) then return end
    if ( not unit or unit == indicator.feedbackUnit ) then
        local status;
        if ( indicator.feedbackUnit ~= indicator.unit ) then
            status = UnitThreatSituation(indicator.feedbackUnit, indicator.unit);
        else
            status = UnitThreatSituation(indicator.feedbackUnit);
        end
        if ( IsThreatWarningEnabled() ) then
            if (status and status > 0) then
                indicator:SetVertexColor(GetThreatStatusColor(status));
                indicator:Show();
            else
                indicator:Hide();
            end
            ...
```

This function is genuinely SHARED - stock WotLK wires it up for TargetFrame/FocusFrame/PartyMemberFrame1-4/BossTargetFrame1-4 (per its own real caller, `UnitFrameThreatIndicator_Initialize`).

`/coasp scanglobals aggro` and a highlight-pattern scan turned up NOTHING resembling a nameplate-specific update function (only unrelated UI helpers and `InterfaceOptionsDisplayPanelAggroWarningDisplay_*` checkbox callbacks) - ruling out a retail-style `CompactUnitFrame_UpdateAggroHighlight` guess entirely.

## Hook attempt (v3.5.33/34) and its result

Installed `hooksecurefunc("UnitFrame_UpdateThreatIndicator", ...)` - a post-hook (not an override, so it can't itself introduce taint) that recolors the `indicator` argument to white whenever its own name contains `"aggroHighlight"` (nameplate-specific naming), leaving anything named `"...Flash"` (party/target/boss frame naming) untouched.

Deployed, fully rebooted the client (stronger than `/reload`, rules out stale code) - still red on screen, no visible change. v3.5.34 made the hook log EVERY invocation unconditionally (not just matches) to find out why.

## Diagnostic tools built this session (all in Core.lua, exposed via `/coasp`)

- `scanglobals <substring>` - lists every global FUNCTION whose name contains the substring. Used to find `UnitFrame_UpdateThreatIndicator`.
- `scantables <substring>` - lists every global TABLE whose name contains the substring (in case `GetThreatStatusColor` reads from a mutable global color table we could edit directly instead of racing a redraw). **Result: clean negative.** `scantables threat` only returned `NumericalThreat` display-text frames (Boss1-4/Focus/Target's numeric threat-% widgets, not color data) and our own options-panel checkboxes. `scantables color` returned only the generic Blizzard UI palette (`RAID_CLASS_COLORS`, `POWER_COLORS`, `FACTION_BAR_COLORS`, etc.) - nothing threat-specific. No `ThreatColor`/`ThreatBarColor`-style table exists as a global under either substring.
- `upvalues <funcname>` - dumps a function's captured closure upvalues via `debug.getupvalue(fn, i)`, since a color table captured only as a local (never assigned to a global) would be invisible to `scantables`. **Result: blocked.** `debug.getupvalue` reports "not available on this client" from inside the addon's own sandboxed Lua environment - this client strips (or never exposes) that part of the `debug` library to regular addons.

## Dev console (`Ascension_UIDevelopmentTools` / DevConsole) - separate execution context

Client-embedded, no readable source (same as Ascension_NamePlates). Confirmed real commands relevant here:

- `tfunc <funcname>` - hooks a function to print its callstack, locals, and call args every time it's invoked. **This is the one producing real, decisive evidence** (regular multi-line pasted Lua scripts fail in this console - it appears to be a single-line/length-limited input, not a full script editor).
- `lookup` (alias `loo`) - a built-in global search command, not yet used but likely equivalent to our own `scanglobals`/`scantables`, run from a context that may have fuller `debug` library access than the addon sandbox.

### Live `tfunc UnitFrame_UpdateThreatIndicator` trace results (real, in-game, both captures so far)

```
self = PartyMemberFrame1PetFrame { ... threatIndicator = PartyMemberFrame1PetFrameFlash {} ... unit = "partypet1" ... }
event = "UNIT_THREAT_SITUATION_UPDATE"
```
```
self = PartyMemberFrame2PetFrame { ... threatIndicator = PartyMemberFrame2PetFrameFlash {} ... }
```

Both real captures show the indicator named `"...Flash"` (party/pet frame convention), fired by `UNIT_THREAT_SITUATION_UPDATE` on `partypet1`/`partypet2` - i.e., ordinary party-pet-frame threat-flash traffic, NOT nameplate traffic. This is exactly the case our v3.5.33/34 hook's name filter is designed to ignore (only names containing `"aggroHighlight"` get recolored).

## THE OPEN QUESTION (not yet resolved)

**Does a nameplate's `"...aggroHighlight"`-named indicator ever get passed through `UnitFrame_UpdateThreatIndicator` at all, or is nameplate aggro-highlighting driven by a completely separate, not-yet-identified mechanism inside Ascension_NamePlates?**

Every real `tfunc` capture so far has only ever shown party/pet-frame `"...Flash"` traffic. No capture has yet occurred while the player held real personal aggro on an enemy with a visible nameplate (the one condition that would make Ascension_NamePlates actually Show/color that nameplate's own `aggroHighlight` frame).

**The decisive test**: keep `tfunc UnitFrame_UpdateThreatIndicator` running, then take real personal aggro on a plated enemy (solo pull is sufficient) and watch whether any trace during that fight ever names its indicator `"...aggroHighlight"` instead of `"...Flash"`.

- If it NEVER does: proves nameplates don't route through this function at all - the v3.5.33/34 hook has been targeting the wrong mechanism from the start. Native recolor is not fixable this way; retire it, hand-rolled glow (already production-primary) becomes the addon's sole reliable signal.
- If it DOES show up: proves the hook's target is correct, and if the highlight still renders red on screen despite the hook firing and reporting success, that would point at a redraw-AFTER-hook timing issue rather than a wrong-function issue - a different, narrower problem than previously assumed.

## Other context gathered (external research, not fully conclusive for this specific client)

- A mature, actively-maintained multi-expansion nameplate-threat addon ("Nameplates_Threat"/"Blizzard Nameplates - Threat", 39 releases, real GitHub source read directly) confirms the general phenomenon (native code re-driving/marking a health bar's color "dirty" so a one-shot recolor doesn't stick) is a real, known behavior on Blizzard clients generally - its own source comment: retail health bars are "marked dirty from multiple places for next frame reset so we must recolor posthook."
- Critically, that same addon does NOT attempt this fix at all on Classic-family clients (its closest public analog to this one) - it's explicitly gated out (`if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC`), and instead just sets its own color directly via its own event-driven function, no hook, no race.
- No public source (WoWInterface, GitHub, CurseForge, Ascension forums) was found that specifically documents Ascension's own nameplate-to-`UnitFrame_UpdateThreatIndicator` wiring (or lack thereof) - this appears to be genuinely undocumented, server-specific behavior.
- A Google AI Mode search surfaced some plausible-sounding but likely-hallucinated retail-era API names (`CompactUnitFrame_UpdateThreatBorder`, `THREAT_STATUS_COLORS`, `CompactUnitFrame_LookForThreatUpdate`, a `nameplateShowThreatGlow` CVar) - none of which matched anything found in our own live `scanglobals`/`scantables` sweeps of this actual client. Treated as unverified, not acted on directly.

## Current production state (unaffected by the open question above)

- Hand-rolled glow texture (`Interface\QuestFrame\bonusobjectives`, `bonusobjectives-bar-glow-ring` sprite, tinted per state) is the addon's real, production-primary threat signal for all three states (secure/warning/danger). Always renders, zero re-assert issues, no per-frame animation cost.
- Native aggroHighlight recolor-to-white is still called on every threat-state change as a "harmless bonus" (in case it ever does visibly stick) but does not gate anything and nothing depends on it working.
- The v3.5.33/34 `hooksecurefunc` on `UnitFrame_UpdateThreatIndicator` is still installed, confirmed harmless (zero errors), but its actual effectiveness for nameplates remains unconfirmed pending the decisive test above.
