# UI error messages — suppressing the red "cannot cast" text (sourced read)

_A **sourced read**, not an emission. Cites `Outputs/client_interface/patch-B/Interface/FrameXML/UIErrorsFrame.lua` and `ChatFrame.lua` (patch-B). Surfaced 2026-08-02 helping a player kill the "Spell is not ready yet." spam a hold-to-spam rotation macro throws every press._

## What the red text IS

The on-screen red messages ("Spell is not ready yet.", "Out of range", "Not enough mana"…) are **`UIErrorsFrame`** output. **[SOURCE]** `UIErrorsFrame_OnLoad` registers `SYSMSG`, `UI_INFO_MESSAGE`, `UI_ERROR_MESSAGE`; `UIErrorsFrame_OnEvent` routes each straight to `self:AddMessage(...)` (`UIErrorsFrame.lua:1–16`). **There is NO message filter** — every `UI_ERROR_MESSAGE` is displayed. So suppression is either the whole event (all-or-nothing) or a filter you add at the `AddMessage` layer.

## CoA built a macro switch for this — but left the slash unwired

**[SOURCE]** `ChatFrame.lua:2618`, their own comment: `-- easier method to turn on/off errors for macros`:
```lua
SlashCmdList["UI_ERRORS_OFF"] = function() UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE"); SetCVar("Sound_EnableSFX","0") end
SlashCmdList["UI_ERRORS_ON"]  = function() UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE");   SetCVar("Sound_EnableSFX","1") end
```
The **intent is explicit** (a macro error switch). But **no `SLASH_UI_ERRORS_OFF1` token binds it** — `commands.json` has no `UI_ERRORS_OFF` entry (the emitter merges GlobalStrings + inline `SLASH_*` and found the handler but no token). So **`/uierrorsoff` is not typeable** — the handler is orphaned (a CoA loose end, or the token lives in an archive we don't extract). Use the `/run` equivalent, which is guaranteed.

## The working lines

**Off (surgical — red text only, no sound change):**
```
/run UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
```
**On:**
```
/run UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
```
`/reload` also restores it (`UIErrorsFrame_OnLoad` re-registers on load). The CoA handler ALSO does `SetCVar("Sound_EnableSFX","0")` — that mutes **all** sound effects, not just the error; append `; SetCVar("Sound_EnableSFX","0")` only if you actually want that.

**All-or-nothing:** unregistering kills EVERY red error (out of range, no target, no mana…), not just "not ready." You cannot suppress only cooldown errors this way — the event carries no type the Lua side can branch on.

## Targeted suppression — filter one message, keep the rest

To drop ONE message and pass the others, wrap `AddMessage` (the display path the event routes through):
```
/run local f=UIErrorsFrame if not f._nf then f._nf=f.AddMessage function f:AddMessage(m,...) if type(m)=="string" and m:find("not ready",1,true) then return end return f._nf(self,m,...) end end
```
- Matched string → dropped (bare `return`); everything else → the **saved original** `f._nf` → displays normally, colours intact (the `...` carries r/g/b). It **suppresses**, it does not turn `AddMessage` off — the original still runs for every non-matching message.
- Guarded (`if not f._nf`) so re-running never wraps the wrapper (no recursion). `/reload` removes it.
- **This is a persistent HOOK — addon-shaped.** It runs fine inline as a macro line, but a permanent, robust version belongs in a tiny addon (addons bench's lane), not a macro.
- Locale-bound (English substring). To key it to the exact error constant instead, confirm the GlobalString live (`/dump ERR_SPELL_COOLDOWN`) and match `m == ERR_SPELL_COOLDOWN`.

## Provenance

Read 2026-08-02 from `Outputs/client_interface/patch-B/Interface/FrameXML/UIErrorsFrame.lua` + `ChatFrame.lua:2618`. Hand-authored **sourced read** — not emitted by `emit_macro_basis.py` (which owns only the JSON domains + `macros.routes.md`). Verify against the cited lines if the fork moves.
