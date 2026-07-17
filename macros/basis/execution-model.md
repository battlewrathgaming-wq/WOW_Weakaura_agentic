# Macro execution model — how lines run, how casts gate, how modifiers work

_Mixed provenance, marked per claim: **[TEST]** = live-proven by Battlewrath 2026-07-17 (during Reaper macro design); **[SOURCE]** = read from the extracted client; **[OPEN]** = not yet tested here, do not assume. These are the facts that decide what a macro CAN and CANNOT do — the ones that turn "I think it works like…" into "it does / it doesn't."_

## Line execution

- **[SOURCE]** `RunMacro` / `RunMacroText` are **C-side** (census: stock-capi). The line-split and iteration are in the binary — **not Lua-readable**, so the direction below was pinned by TEST, not a source read.
- **[TEST]** **Read direction is ASCENDING (top-to-bottom).** A 3-line `/run print("1")/print("2")/print("3")` macro printed `1 2 3`. And **all lines execute** — nothing stopped after line 1 (`/run` doesn't gate).

## How `/cast` lines gate each other

- **[TEST]** **The first castable `/cast` fires and gates the rest.** With Scythe Rush castable, `/cast Scythe Rush` ⏎ `/cast Reap` cast Scythe Rush and **did not attempt Reap** — the first cast took the GCD/press, later `/cast` lines were blocked.
- **[TEST]** ★ **OUT-OF-RANGE DOES NOT FALL THROUGH.** With Scythe Rush too close (inside its 8y charge minimum), the same macro reported **"Target is too close"** and **Reap was NOT attempted.** The out-of-range attempt **consumed the press**; execution did not fall to the next line.
  - **Consequence:** you **cannot** build an automatic *"cast A, or B if A is out of range"* macro on this client. The out-of-range line eats the press. (Castsequence fails the same case for a different reason — it advances only on cast SUCCESS, so an out-of-range spell never advances and the sequence sticks.)
  - Combined with **no `[range]` conditional** (never a candidate, never proven; native WoW has none), **automatic range-based branching is not buildable.** The tool for "A or B" is the **manual modifier branch**: `/cast [mod:shift] A; B` — you make the call, and only one cast is attempted so nothing gets eaten.
- **[OPEN]** Does an **on-cooldown** `/cast` fall through to the next line? (Retail says yes; **untested here** — do not assume.) Does the **20s per-target lockout** fall through or block like range did? (Untested — the range case was tested, not the lockout.)

## Modifiers

- **[SOURCE]** `[mod:]` recognises **only `shift`, `ctrl`, `alt`** (`SecureTemplates.lua:2` — "The modifier is one of 'shift-', 'ctrl-', 'alt-'"). There is no `[mod:mousebutton4]` or custom modifier name in the parser.
- **[SOURCE]** Modifier state is **READ from hardware** (`IsAltKeyDown` / `IsControlKeyDown` / `IsShiftKeyDown`, all stock-capi; the secure code checks `IsModifiedClick`). **No macro command writes modifier state** (checked across all 70 commands — none).
- **⇒ A macro CANNOT set or "project" a modifier.** `[mod:alt]` only ever reflects whether Alt is *physically* held.
- **Practical consequence:** to use a **mouse button as a macro modifier**, the button must **emit a real shift/ctrl/alt keypress** (mouse software remap). A button WoW sees as its own bindable key (e.g. "Button 4") can be a keybind, but **not** a `[mod:]`. So "mouse thumb = alt" (hardware/software) is the correct and only path to make `[mod:alt]` fire from the thumb — not a workaround, the mechanism.

## Why this is here

These are the load-bearing "does it actually work?" facts for macro *forming* — the layer that fails **silently** (an out-of-range macro that just whiffs, a `[mod:]` that never fires because the button isn't a real modifier). Each was either read from source or proven in a real fight, and the **[OPEN]** items are marked so nobody reasons past them. Provenance: `Outputs/client_interface/patch-B/Interface/FrameXML/SecureTemplates.lua`, the runtime census, and Battlewrath's live tests 2026-07-17.
