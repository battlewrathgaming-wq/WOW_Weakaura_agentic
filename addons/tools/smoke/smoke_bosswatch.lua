-- Offline smoke for COA_DungeonRun bosswatch.lua - THE BOSS-DEATH LISTENER (RI-66 · A6.2).
--
-- ★★★ THE ONE THING THIS FILE EXISTS TO PROVE, and it is the half a design cannot argue:
-- **the argument POSITIONS**. `operations/ROUTER.md` records CLEU on this fork as the
-- classic varargs tuple - `1` ts · `2` subevent · `3-5` src · `6-8` dst · `9+` suffix,
-- with `CombatLogGetCurrentEventInfo` FURNITURE here. A listener that reads the wrong
-- index is silent, not broken: it simply never fires, and the route never advances, and
-- nothing anywhere says why. ⟶ So the event is driven through the real handler.
--
-- ⚠ WHAT IT CANNOT SAY. That the client sends what ROUTER says it sends. That is a client
-- fact, measured elsewhere and cited here; this proves we READ that shape correctly.
--
-- Run: .tools/lua51/lua5.1.exe addons/tools/smoke/smoke_bosswatch.lua

local ROOT = [[F:\Projects_games\World of Warcraft - Conquest of Azeroth\]]
local ADDON = ROOT .. [[addons\COA_DungeonRun\]]

-- A frame stub that RECORDS its registrations. The cost discipline is the whole reason
-- this module registers lazily, so "is it registered" has to be observable.
local reg = {}
local made = {}
function CreateFrame(_, name)
    local f = { _name = name, _scripts = {} }
    function f:SetScript(k, fn) self._scripts[k] = fn end
    function f:GetScript(k) return self._scripts[k] end
    function f:RegisterEvent(e) reg[e] = (reg[e] or 0) + 1 end
    function f:UnregisterEvent(e) reg[e] = nil end
    made[#made + 1] = f
    return f
end

local chat = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) chat[#chat + 1] = m end }

local NS = {}
NS.Say = function(m) DEFAULT_CHAT_FRAME:AddMessage(m) end
assert(loadfile(ADDON .. "bosswatch.lua"))("COA_DungeonRun", NS)
local Watch = assert(NS.BossWatch, "bosswatch.lua did not publish BossWatch")

-- =====================================================================
-- ★ NOTHING IS REGISTERED UNTIL A NAME IS ARMED
-- =====================================================================
-- ⚠ `cleu_on_this_fork.md` measured that a lean masked arm costs at or below the
-- no-listener arm, so cost is NOT the argument. The argument is the other one it made:
-- *"a thing we never registered cannot break when the client changes."*
assert(reg["COMBAT_LOG_EVENT_UNFILTERED"] == nil,
       "A LISTENER WAS REGISTERED AT LOAD: nothing is armed, so nothing may be listening")
assert(Watch.Armed() == 0, "and nothing is armed")
assert(Watch.Listening() == false, "and it says so")

-- =====================================================================
-- ★★★ THE ARGUMENT POSITIONS - driven through the REAL handler
-- =====================================================================
local killed = {}
assert(Watch.Arm("Baron Silverlaine", function(n) killed[#killed + 1] = n end)
       == "Baron Silverlaine", "arming returns the name it armed")
assert(reg["COMBAT_LOG_EVENT_UNFILTERED"] == 1, "the first arm registers the event")
assert(Watch.Listening(), "and it is listening")

local frame = made[#made]
local onEvent = assert(frame:GetScript("OnEvent"), "the watcher installs an OnEvent")

-- The tuple as ROUTER records it. ⚠ Written out in full rather than with placeholders so
-- a reader can COUNT to seven and see why 7 is the destination name.
--   1 ts · 2 subevent · 3 srcGUID · 4 srcName · 5 srcFlags · 6 dstGUID · 7 dstName · 8 dstFlags
local function cleu(sub, dstName)
    onEvent(frame, "COMBAT_LOG_EVENT_UNFILTERED",
            1700000000, sub,
            "0xSRC", "Gravekeeper", 0x512,
            "0xDST", dstName, 0xa48)
end

-- ⚠ EVERY OTHER SUBEVENT MUST COST NOTHING AND DO NOTHING. This is the traffic; UNIT_DIED
-- is the rare case.
cleu("SPELL_DAMAGE", "Baron Silverlaine")
assert(#killed == 0,
       "A NON-KILL SUBEVENT FIRED THE WATCH: `SPELL_DAMAGE` on the armed name completed a "
       .. "boss tab, so any hit on the boss would advance the stage")

cleu("UNIT_DIED", "Rethilgore")
assert(#killed == 0, "a kill of a name nobody armed does nothing")

cleu("UNIT_DIED", "Baron Silverlaine")
assert(#killed == 1 and killed[1] == "Baron Silverlaine",
       "THE ARMED NAME'S DEATH DID NOT FIRE: the destination name is the SEVENTH vararg on "
       .. "this fork, and a listener reading the wrong index is SILENT rather than broken")

-- ★★ AND IT DISARMS ITSELF ON THE KILL. A tab completes once; a listener that survived its
-- own completion would fire again on a later kill of the same name, in a stage nobody is
-- standing in.
assert(Watch.Armed("Baron Silverlaine") == false, "the kill takes the arm with it")
assert(reg["COMBAT_LOG_EVENT_UNFILTERED"] == nil,
       "and the LAST arm going unregisters the event - the cheapest listener is the one "
       .. "that is not registered")
cleu("UNIT_DIED", "Baron Silverlaine")
assert(#killed == 1, "a second death of the same boss fires nothing")

-- =====================================================================
-- ★ TWO TABS MAY WAIT ON ONE BOSS, and dropping one is a silent half-advance
-- =====================================================================
local both = 0
Watch.Arm("Fenrus", function() both = both + 1 end)
Watch.Arm("Fenrus", function() both = both + 1 end)
assert(Watch.Armed() == 1, "one NAME is armed, whatever the number of waiters")
Watch.Died("Fenrus")
assert(both == 2,
       "A SECOND WAITER ON ONE BOSS WAS DROPPED: two tabs can name the same kill, and "
       .. "completing only one of them leaves a route half-advanced with nothing to say")

-- =====================================================================
-- ★★★ A12.4c - DISARM IS THE FREQUENT CASE, not the rare one
-- =====================================================================
-- *"a reader leaves a node's reach mid-stage and its CLEU listener must go with it."*
-- Disarming only on ADVANCE leaves a boss killed anywhere later in the stage completing a
-- tab nobody is standing in.
local late = 0
Watch.Arm("Arugal", function() late = late + 1 end)
assert(Watch.Disarm("Arugal") == true, "a name can be disarmed by name")
Watch.Died("Arugal")
assert(late == 0,
       "A DISARMED LISTENER STILL FIRED: this is A12.4c's whole case - the reader left the "
       .. "node's reach, and a boss killed later in the stage must not complete its tab")
assert(Watch.Disarm("Arugal") == false, "disarming what is not armed says so")

-- Whole-clear, which is what a run STOPPING uses.
Watch.Arm("A", function() end)
Watch.Arm("B", function() end)
assert(Watch.Armed() == 2, "two names")
assert(#Watch.Names() == 2 and Watch.Names()[1] == "A", "and they are readable, sorted")
Watch.Disarm()
assert(Watch.Armed() == 0, "a bare Disarm clears every name")
assert(reg["COMBAT_LOG_EVENT_UNFILTERED"] == nil, "and stops listening")

-- =====================================================================
-- ★ THE REFUSALS - a bad arm must not half-register
-- =====================================================================
assert(Watch.Arm(nil, function() end) == nil, "no name, no arm")
assert(Watch.Arm("", function() end) == nil, "an empty name is not a name")
assert(Watch.Arm("Boss", nil) == nil, "no body, no arm")
assert(Watch.Armed() == 0 and reg["COMBAT_LOG_EVENT_UNFILTERED"] == nil,
       "A REFUSED ARM REGISTERED THE EVENT ANYWAY: a listener with nothing to tell is the "
       .. "cost with none of the benefit")
assert(Watch.Died("nobody") == 0, "a death nobody armed reports zero")

print("smoke_bosswatch: OK - the positions, the lazy registration, and A12.4c's disarm")
