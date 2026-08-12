# Prior art — three addons inspected before writing the brief

At Battlewrath's instruction, 2026-08-12: *"There are some addons we can inspect first for
handling."* Inspected for **handling lessons**, not for features to copy — law 11 already fixes
what we make. Findings are recorded as *what it teaches us*, and where a mechanism is
**irrelevant to us**, that is said plainly, because knowing what we do not need is the more
valuable half.

| Addon | Where | What it was inspected for |
|---|---|---|
| **pfQuest** (+`pfQuest-ascension`) | installed, client `AddOns/` | the arrow's **drive logic** |
| **GatherMate2** (+`_Data`, `Asc_Gathermate2`, `GatherHud`) | installed | **map / minimap population** |
| **Total RP 3: Extended** | source, `Inventory/InventoryDrop.lua` | the **stash** system — markers with user-assigned value |

---

## 1. Total RP 3: Extended — the stash system

**The closest analogue to what we are building**, and it arrived at our design independently.
Stashes are world-placed containers other players can find and open.

### ★ It corroborates four of our laws, from a mature addon solving a different problem

| Their behaviour | Our law |
|---|---|
| stores `posX, posY, posZ` **and** `uiMapID` **and** `mapX, mapY` | **law 5** — store both coordinate spaces at capture |
| *"If it's not a new stash, we don't want to replace its position"* — position captured at creation only, updates blocked | **laws 1 + 2** — born where you stood; the editor never relocates |
| **no automatic expiry**; deletion is a manual, confirmed act | **law 7** — version control belongs to the user |
| proximity **polled**, not evented (`createRefreshOnFrame`, every **0.15 s**) | our probe sampled at 0.2 s; F25 already told us stage state has no event |

**Why this matters beyond reassurance:** it means the *shape* of our design is standard, not
idiosyncratic. What is novel here is the **meaning layer** (laws 11 and 18), not the storage or
the proximity model. That is also a second, independent answer to the §8 gate's
*"it may be over-engineering"* stopper — the plumbing is what everyone builds; nobody builds
the meaning.

### What differs, and why ours is better placed

- **`MAX_SEARCH_DISTANCE = 15`** — a single flat radius, for *discovering someone else's* stash.
  Ours is a per-landmark tier (law 14), because we are answering *have I arrived at MY place*,
  which is a different question and genuinely varies by place.
- **Their distance is 2D despite storing `posZ`**: `sqrt((posY-myPosY)^2 + (posX-myPosX)^2)`.
  They store height and then ignore it. **We get 3D free from the engine (F28)** and do no
  distance maths at all.

### Not for us

Broadcast sharing (`SEARCH_STASHES_COMMAND` / P2P request-response) and creator-ID ownership
belong to a multiplayer discovery feature. The scrapbook is personal (§9 delta 4).

---

## 2. pfQuest — the arrow's drive logic

### ★ The headline: almost all of its machinery solves problems we do not have

pfQuest predates and works without the supertrack system, so it rebuilds navigation in Lua:

- **A 108-cell sprite sheet** (9 × 12, 56 × 42 px cells) picked per-frame to fake a rotating
  arrow, because this client's textures cannot rotate.
- **Direction maths from map-space**, `atan2(xDelta, -yDelta)` against
  `pfQuestCompat.GetPlayerFacing()`, credited to TomTomVanilla.
- **Its own distance**, computed in map-percentage units.

**We need none of it.** §2 stands reinforced: the engine draws the beacon, computes the
distance in yards, and projects it into the world. Every line above is a workaround for the
capability we already have.

### ★ But three things ARE transferable

1. **The two-tier throttle** (`route.lua:176`) — a genuinely good pattern:
   ```lua
   -- once per 1s when the player has not moved
   if (this.tick or 5) > GetTime() and lastpos == curpos then return else this.tick = GetTime() + 1 end
   -- but never faster than every .05s even when moving
   if (this.throttle or .2) > GetTime() then return else this.throttle = GetTime() + .05 end
   ```
   Cheap when static, responsive when moving. Our arrival poll should do the same.

2. **★ A DEBOUNCE BEFORE HIDING** (`route.lua:337`) — the arrow does not vanish the instant its
   target becomes invalid; it waits **1 second**, so transient invalid states do not flicker
   the UI:
   ```lua
   if invalid and invalid < GetTime() then this:Hide()
   elseif not invalid then invalid = GetTime() + 1 end
   ```
   **Directly applicable to F38.** A loading screen or a zone transition can produce a
   momentary `Invalid`; without a grace period our `[Map]` indicator would blink and our
   arrival guard would judge on a single frame.

3. **`GetNearest(xstart, ystart, db, blacklist)`** — nearest-unvisited selection with a
   blacklist. Not for the scrapbook (law 18: we are not a travel aid), but it is the shape the
   **route half** will want for ordering.

### ★ And one incidental answer to an open question

pfQuest hardcodes **`* 1.5`** on every x-delta to correct map-fraction aspect — one constant,
applied to all zones, in a mature addon with a full zone database. That is third-party evidence
that **the 3:2 map aspect DOES generalise** (§4, and an open question in §7). Not proof, but
it is a strong prior from people who would have noticed if it varied.

---

## 3. GatherMate2 — map and minimap population

Outside our use by law 15 (the minimap is out of scope), inspected for lessons at scale — it
draws hundreds of pins where we draw tens.

### ★ Pin pooling is the lesson

`Display:getMapPin()` never destroys a frame; it recycles through `pinCache`:

```lua
local function recyclePin(pin)
    pin:Hide(); pin.coords = nil; pin.nodeType = nil; pin.zone = nil
    pin.title = nil; pin.worldmap = false; pin.nodeID = 0; pin.keep = nil
    pinCache[pin] = true
end
function Display:getMapPin()
    local pin = next(pinCache)
    if pin then pinCache[pin] = nil; return pin end
    ...CreateFrame("Button", "GatherMatePin"..pinCount, WorldMapButton)
end
```

Frames cannot be destroyed in this API — only hidden — so a naive implementation leaks one
frame per pin per redraw, forever. **Any pin redraw we write must pool.** Note the recycle
explicitly nils *every* field: a pooled frame carrying stale data is the classic bug this
pattern invites.

### Its update loop, and the honest caveat

```lua
last_update = last_update + elapsed
if last_update > 2 or forceNextUpdate then Display:UpdateMiniMap(true); last_update = 0
else Display:UpdateIconPositions() end
```

A **full rebuild every 2 s, cheap repositioning every frame between**. Sound in principle —
but `UpdateIconPositions` running every frame is exactly the shape of cost the Mancer stutter
investigation was chasing. At our scale (tens of pins, world map only, and the world map is
usually closed) we should **rebuild on event, not on a timer**, and do nothing at all while the
map is hidden.

### ★ A warning, not a lesson

`showPin` disables a Blizzard frame's script and `hidePin` restores it:

```lua
WorldMapBlobFrame:SetScript("OnUpdate", nil)      -- on pin enter
WorldMapBlobFrame:SetScript("OnUpdate", WorldMapBlobFrame_OnUpdate)  -- on leave
```

A performance hack that **mutates a frame it does not own**. If anything else touched that
script in between, it is silently clobbered on restore. Our call-witness work landed the same
rule the other way round — restore only if the value is still ours. **Do not copy this.**

### Not for us

Minimap pin management (`getMiniPin`, `addMiniPin`, `MinimapZoom`, rotation handling) — law 15.
Recorded only so nobody re-derives it as a gap.

---

## What this changes in the brief

1. **Two new acceptance criteria**, both from pfQuest:
   - the **two-tier throttle** on the arrival poll;
   - a **debounce before acting on `Invalid`**, so F38's guard judges a sustained state and not
     a single frame across a loading screen.
2. **One from GatherMate:** world-map pins must **pool**, and must do nothing while the map is
   hidden.
3. **One thing confirmed rather than changed:** law 5's both-spaces storage and law 2's
   frozen-at-creation position are what a mature addon in this space also does.
4. **One open question softened:** the 3:2 aspect (§7) has third-party corroboration.
