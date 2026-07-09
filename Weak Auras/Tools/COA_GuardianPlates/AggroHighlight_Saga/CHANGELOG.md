# Native aggroHighlight - Version-by-Version Changelog

Extracted verbatim from `COA_GuardianPlates.toc`'s `## Notes:` field (v3.5.16 through v3.5.42), the full run of versions dedicated to investigating and attempting to control Ascension_NamePlates' native "you have aggro" indicator. Unrelated addon history (v2.x-v3.4.x, the Necromancer/Reaper/etc. WeakAuras work) is intentionally excluded - see the .toc itself for the complete addon changelog.

---

### v3.5.16 (2026-07-09)
Battlewrath, after confirming Ascension_NamePlates (not TurboPlates) is the actual driver: "Shall we add boarder correction? A single color wheel picker for enemy plates?" Ascension_NamePlates is client-embedded with no extractable Lua/.toc source, so whether it even exposes a separate, colorable native border region (vs. the border being baked into the health bar's own texture) can't be answered by reading code - it has to be confirmed live. Added `/coasp probe [unit]` (defaults to target): walks every child frame/region under the unit's real nameplate (capturing Texture-specific detail - texture path, vertex color, draw layer - alongside FontString text capture) and pops a copyable text dump instead of requiring a /reload + SavedVariables round-trip. Purely diagnostic - the color-wheel picker itself is only worth building once a probe capture shows there's a distinct region to target.

### v3.5.17 (2026-07-09)
Battlewrath's first live `/coasp probe` capture found only a single Texture region (white, vertexColor 1,1,1,1) and reported "I think I found it. It's a name plate, your target highlight. That is red. (In some conditions.)" then "It'd be white, I can't recreate red right now" - confirming the white capture was simply the highlight in its non-red state, not a miss. But the v3.5.16 probe only walked one level deep - it never opened the 4 unnamed Frame children the first capture showed sitting under the health bar container. Rewrote the walk as a depth-limited (5 levels) recursive descent (`WalkProbeTree`) that opens every Frame-capable child's own children/regions in turn, tagging each entry with depth + path.

### v3.5.18 (2026-07-09)
The deeper probe paid off immediately: Battlewrath's next capture (targeting Moonrage Whitescalp) found it nested inside the health bar - `Frame "...aggroHighlight"` containing `Texture "...aggroHighlightTexture"` (`Interface/TargetingFrame/UI-TargetingFrame-BarFill`), hardcoded `vertexColor 1,0,0,1` at layer OVERLAY - Ascension_NamePlates' own native "you have aggro" indicator, entirely separate from this addon's own glow and drawn on top of it. Battlewrath chose recolor over suppress/leave-alone. Added `ns.GetNativeAggroHighlightTexture`/`ns.SetNativeAggroHighlightColor`/`ns.ClearNativeAggroHighlightColor` to Core.lua and wired it into EnemyPlates.lua's `ApplyThreatColorForUnit` (all 3 states), `DisarmThreatColors`, and the render-test rig.

### v3.5.19 (2026-07-09)
Battlewrath, watching the native recolor work: "It might be we dispatch of our current glow. Depending how this works. As they was trying to do the same thing" - our own LibCustomGlow effect and the native aggroHighlight were now both signaling the same state, and LibCustomGlow's animation carries a real per-frame OnUpdate cost the native recolor doesn't. Answer: "If it works. Set our current to something that doesn't actually render / cost performance. Then work out what that extra signal is good for." `ApplyThreatColorForUnit`/`RenderTestApply` now try the native recolor FIRST, falling back to our own animated glow only when no native texture is found at all.

### v3.5.20 (2026-07-09)
Battlewrath: "This only highlights your current target" and "Can we reuse that texture, so the same one that is on our current target, can [be] seen across the aggro cue group and such." Confirmed: `SetNativeAggroHighlightColor` already runs group-wide, but Ascension_NamePlates' own logic only ever Shows the aggroHighlight frame on the plate that's your current target - recoloring a Hidden texture elsewhere has no visible effect. Added `ns.GetNativeAggroHighlightFrame`, `ns.ForceShowNativeAggroHighlight`/`ns.ClearForcedNativeAggroHighlight` (force Show()/SetAlpha(1) directly), and a new "aggroBroadcast" render-test module to test whether a forced Show() on a non-targeted plate sticks or gets fought back.

### v3.5.21 (2026-07-09)
A one-off render test showed zero trace of the aggroBroadcast module firing - likely stale pre-v3.5.20 code still running (Lua files only reload on /reload, not on save). Separately, found and fixed a real filter bug: `RenderTestAggroBroadcast` had reused `IsPotentialThreatUnit` (which requires real combat engagement) as its own filter, so the broadcast test would always report 0 touched plates on an idle group of mobs. Added `ns.IsHostileUnit(unit)` (same hostile+attackable check, combat requirement dropped) for the broadcast test specifically, without touching the real production gate.

### v3.5.22 (2026-07-09)
That re-test settled it: `SetNativeAggroHighlightColor`/`ForceShowNativeAggroHighlight` reported "not found" 100% of the time, INCLUDING on Moonrage Whitescalp while actively tanked/targeted - the exact mob an earlier probe had already proven has this structure. Root cause: `GetNativeAggroHighlightFrame` read `healthBar.aggroHighlight` as a Lua field - a guess based on how the frame's NAME happened to look in the probe dump, but the probe actually found the frame by enumerating `healthBar:GetChildren()` positionally, never through that key. Fixed to try the frame's own predictable global name first (healthBar's name + "aggroHighlight" suffix), falling back to the `GetChildren()` scan.

### v3.5.23 (2026-07-09)
Even with the lookup fixed, `ForceShowNativeAggroHighlight` succeeded at the Lua level but produced no visible change on screen - Ascension_NamePlates' own logic still governs whether the frame actually renders, a fight not worth continuing. Battlewrath instead found a real answer via the client's in-game atlas/dev console: `"bonusobjectives-bar-glow-ring"`, a soft horizontal glow-ring sprite baked into `Interface\QuestFrame\bonusobjectives`. Added `ns.SetHandRolledGlow`/`ns.ClearHandRolledGlow` to Core.lua - a Texture region this addon creates and owns outright, so Show()/Hide()/SetVertexColor are guaranteed to actually apply.

### v3.5.24 (2026-07-09)
Screenshots showed the v3.5.23 texture rendering INSIDE the health bar's own bounds instead of a halo sitting behind/around the plate. Fixed: widened anchor padding substantially (-12/+12 horizontal, -10/+10 vertical) and dropped draw layer from OVERLAY to BACKGROUND so the bar's own art draws over the overlapping middle, leaving only the spillover visible as a halo.

### v3.5.25-v3.5.28 (2026-07-09)
Iterative visual tuning of the halo's position/size against the level-circle icon on the plate, based on Battlewrath's live screenshot feedback each round (scale down, shift right, stretch right edge, recenter, fix vertical asymmetry). Purely cosmetic; same underlying mechanism throughout.

### v3.5.29 (2026-07-09)
Once the halo was fully tuned: "Can we wire this in to the glow constant we made? Or do we now have a legacy hidden element to compute?" Live testing (v3.5.20-23) had already proven the v3.5.19 native-first/glow-fallback scheme was silently broken - native recolor succeeding only ever meant the texture exists, not that it's visible. `ApplyThreatColorForUnit`, `RenderTestApply`, `DisarmThreatColors`, and `OnUnitRemoved` now all route ordinary threat state through `ns.SetHandRolledGlow`/`ns.ClearHandRolledGlow` (proven, always-renders) instead of the native-gated dispatch. Native recolor kept only as a harmless bonus, no longer gates anything.

### v3.5.30 (2026-07-09)
Battlewrath: "Can we modify the colour? Keep it white so our glow isn't being competed with signal wise." Both call sites now recolor the native frame to a fixed neutral white instead of the resolved state color, so if it ever flashes it reads as plain presence, not a second, possibly-inconsistent color cue.

### v3.5.31 (2026-07-09)
Battlewrath: "Shall we add a render test to swap it's colors on the threat system on it's own? I can't test if it works when it already defaults to white outside of conditions." Added a new, state-logic-free render test module ("nativeAggroColor") that forces raw color swatches (white/red/yellow/green/clear) straight at `SetNativeAggroHighlightColor`, independent of threat states. Doesn't force the frame Shown - only visible while genuinely holding aggro on the real target, same as production.

### v3.5.32 (2026-07-09)
Battlewrath's live test (grouped, real combat) settled the open question: the aggroHighlight stayed stock red the whole time despite `SetNativeAggroHighlightColor` reporting "applied" every time with zero errors - a genuine re-assert race, not protection. Added `ns.ScanGlobalsForPattern`/`/coasp scanglobals <substring>` plus a speculative hooksecurefunc against candidate names (`UnitFrame_UpdateThreatIndicator`, `CompactUnitFrame_UpdateAggroHighlight`).

### v3.5.33 (2026-07-09)
`/coasp scanglobals threat` returned `UnitFrame_UpdateThreatIndicator` (confirmed real WotLK global: `indicator:SetVertexColor(GetThreatStatusColor(status))`); `scanglobals aggro` found nothing nameplate-specific, ruling out the retail `CompactUnitFrame_UpdateAggroHighlight` guess. The speculative hook fired repeatedly and predictably in combat, confirming the target. Upgraded from observe-only to a real fix: recolors the `indicator` argument to white whenever its name contains "aggroHighlight".

### v3.5.34 (2026-07-09)
Full client reboot (stronger than /reload) still showed no visible change - still red. The v3.5.33 hook only logged inside the match branch, making "never fires" and "fires on something unrelated" indistinguishable. Made the hook log unconditionally (every invocation, matched or not) to settle it definitively next capture.

### v3.5.35 (2026-07-09)
Battlewrath researched the race externally: "I'd rather work it as a part of the system." Found real prior art confirming the race is a known general WoW client behavior, but that on Classic-family clients the closest public analog doesn't fight the race at all - it just sets its own color directly, no hook. Several specific names from that research didn't match this client's own scans, treated as unverified. Added `ns.ScanGlobalTablesForPattern`/`/coasp scantables <substring>` to check whether `GetThreatStatusColor` reads from a mutable global color table.

### v3.5.36 (2026-07-09)
Both scans came back clean-negative: `scantables threat` returned only numeric threat-% display frames, `scantables color` returned only the generic UI palette - no `ThreatColor`-style table exists on this client under either substring. Combined with the confirmed race (v3.5.32) and the researched precedent (v3.5.35), every avenue for making the native recolor reliably stick was exhausted at this point - hand-rolled glow remained the addon's only guaranteed-reliable signal.

### v3.5.37 (2026-07-09)
Battlewrath: "Can we feed a function and ask what tables it calls?" A color table captured only as a closure upvalue would be invisible to `scanglobals`/`scantables`. Added `ns.DumpFunctionUpvalues`/`/coasp upvalues <funcname>` using `debug.getupvalue(fn, i)`. Read-only introspection, can't itself change behavior.

### v3.5.38 (2026-07-09) - FINAL VERDICT (later superseded, see v3.5.39)
Three independent research passes (two 3.3.5a FrameXML mirrors, retail/Cataclysm source, WotLK nameplate-addon prior art) converged with this addon's own real `tfunc UnitFrame_UpdateThreatIndicator` traces (dev console): both live captures showed only `PartyMemberFrame1/2PetFrameFlash`, never anything named `aggroHighlight`. Verdict: `UnitFrame_UpdateThreatIndicator` is structurally gated on a real unit token nameplates never carry into it - it cannot be the driver. Retired the hooksecurefunc installation and native-recolor "harmless bonus" calls from production. Hand-rolled glow declared the sole, permanent production signal.

### v3.5.39 (2026-07-09) - REOPENED
A follow-up research pass argued this client is actually a Legion/BfA-era CompactUnitFrame nameplate backport - real corroborating evidence already in this addon's own code (`ns.GetHealthBar`'s `.UnitFrame.healthBar` fallback branch, written defensively for exactly this case). Rather than trust an unverified function name a second time, added `ns.WatchNativeAggroHighlight`/`/coasp watchaggro [unit]` - hooks the actual, already-confirmed-real aggroHighlight frame/texture INSTANCE directly and logs a trimmed debugstack every time Show/Hide/SetVertexColor fires, so the real driver's name is discovered live rather than assumed.

### v3.5.40 (2026-07-09)
The watchaggro probe paid off immediately: live capture caught the real driver red-handed - `CompactUnitFrame.lua:773 UpdateAggroHighlight`, called via `UpdateAll <- SetUnit <- Ascension_NamePlates\NamePlateDriver.lua:227` - confirming the CompactUnitFrame backport theory. Upgraded `ns.SetNativeAggroHighlightColor` from a one-shot color set to a PERSISTENT per-texture post-hook: re-applies the desired color immediately after ANY native SetVertexColor call, with a re-entrancy guard. `ns.ClearNativeAggroHighlightColor` now just clears the desired-color record. NOT yet re-wired into production; confirming it holds on screen was the next step.

### v3.5.41 (2026-07-09)
Battlewrath, trying to capture live evidence of the recolor hook holding: "in 300 events it already ran through. so no budget to catch it." The existing dump/copy keyword filter only narrows results AFTER they're stored - routine noise still fills the 300-entry ring buffer first. Added a store-time filter: `ns.SetLogStoreFilter`/`ns.GetLogStoreFilter` plus `/coasp log filter <substring>|off|status` - drops non-matching entries before they're ever written to the buffer.

### v3.5.42 (2026-07-09)
Battlewrath found a CurseForge addon (TargetNameplateIndicator) hooking a global `"CompactUnitFrame_UpdateAggroFlash"` to Hide() the native aggro flash. Treated as unverified: this client's own live-captured callstack names the real function `"UpdateAggroHighlight"`, file-local to CompactUnitFrame.lua, not a plain global - hooking the pasted name would likely just error. Reused the SAME instance-scoped hooksecurefunc technique proven in v3.5.40, but to Hide() persistently instead of recolor. Added `ns.SuppressNativeAggroHighlight`/`ns.ClearNativeAggroHighlightSuppress` plus `/coasp suppressaggro on|off [unit]`.

---

## Post-v3.5.42 live test result (not a version bump - client couldn't be reloaded)

Battlewrath's anti-cheat setup treats `/reload`-level code injection into the running client as a memory violation, so v3.5.41/42 couldn't be loaded and tested through the addon itself this session. Built an equivalent pure `/run` macro (no addon dependency, using only already-resident Blizzard API: `C_NamePlate`, `hooksecurefunc`) to test the suppress concept live instead - see `CODE_MAP.md` for the exact macro text.

**Result: no effect.** The suppress macro reported no error but the native highlight showed no visible change during the live test. Root cause not yet isolated - candidates include the target's plate lacking `.UnitFrame` (macro has no fallback to `plate.healthBar` the way the full addon primitive does), the frame not actually being in a Show()-triggering state during the test, or something in the CompactUnitFrame backport still fighting Hide() the same way it fights color. Battlewrath paused testing here due to fatigue with the mechanical back-and-forth - **this is where the saga currently stands.**
