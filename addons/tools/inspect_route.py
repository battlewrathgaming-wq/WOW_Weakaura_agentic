# -*- coding: utf-8 -*-
"""INSPECT A REAL ROUTE - one shot, bounded output, no resident state.

★★★ WHY (Battlewrath, 2026-08-21): *"Is it worth building a terminal runtime so you inspect
instead of envoke?"* - **yes, scoped to this.** The smokes build `Bucket.Build` against a STUB
`Routes` with a hand-made node shape (`smoke_bucket.lua:4-10`). This runs the SAME code against a
REAL scraped store, which is where the two can differ - and E-0 is exactly a case where they do
(a real child carries no `rows`).

⚠⚠ AND WHAT IT DELIBERATELY IS NOT: **a REPL.** A resident state mutated across turns is state
only the agent holds, which is the temporal-memory problem this project was founded on. One shot,
prints, exits - so the output is a RECORD, quotable in a commit, reproducible by anyone.
★ His two conditions, and both are enforced here rather than remembered:
  · *"keep an eye on it repeating uncontrolled and how it grows content wise"* -> every section is
    CAPPED (`CAP`), and what is elided is COUNTED and said. There is no full-dump mode.
  · *"running in a route that already exists as a common port/sequence"* -> it reads the SCRAPED
    CORPUS, defaulting to the RFC run. It never synthesises a route.

Usage:  py addons/tools/inspect_route.py            # shape, on the default scrape
        py addons/tools/inspect_route.py bucket     # what Bucket.Build makes of a real route
        py addons/tools/inspect_route.py gate       # A12.2e: composed gate vs the prefix
        py addons/tools/inspect_route.py --list     # which scrapes are available
"""
import io
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, "landing", "raw")
SMOKE = os.path.join(ROOT, "tools", "smoke")
SRC = os.path.join(ROOT, "COA_DungeonRun")
LUA = os.path.join(os.path.dirname(ROOT), ".tools", "lua51", "lua5.1.exe")

# ⚠ THE CAP IS THE POINT, not a convenience. An unbounded inspector becomes a thing that is run
# repeatedly and read carelessly; a capped one has to say what it left out.
CAP = 12

DEFAULT = "rfc_combat"          # a real dungeon run, not a test fixture


def scrapes():
    if not os.path.isdir(RAW):
        return []
    return sorted(f for f in os.listdir(RAW) if f.endswith("dungeonrun.lua"))


def pick(hint):
    got = [f for f in scrapes() if hint in f]
    return os.path.join(RAW, got[-1]) if got else None


LUA_SRC = r"""
local scrape, mode, cap = ...
cap = tonumber(cap) or 12
local here = "%SMOKE%/"
dofile(scrape)
local db = COA_DungeonRunDB
if not db or not db.routes then print("  no routes in this scrape") return end

-- the route with the most beacons; ties -> first by id
local rid, r
for id, rt in pairs(db.routes) do
    local n = rt.beacons and #rt.beacons or 0
    if not r or n > (r.beacons and #r.beacons or 0) then rid, r = id, rt end
end
if not r then print("  no route") return end

local function keys(t)
    local out = {}
    for k in pairs(t) do if type(k) == "string" then out[#out+1] = k end end
    table.sort(out); return out
end
local function show(label, list)
    local shown = math.min(#list, cap)
    io.write(("  %-22s %d field(s): "):format(label, #list))
    for i = 1, shown do io.write(list[i], i < shown and " " or "") end
    if #list > shown then io.write((" ... +%d not shown"):format(#list - shown)) end
    print("")
end

print("")
print(("  ROUTE %s   map %s   beacons %d"):format(tostring(rid), tostring(r.mapID),
      r.beacons and #r.beacons or 0))

if mode == "shape" then
    print("")
    print("  MEASURED FROM THE LIVE STORE - not inferred from assignment sites")
    show("route", keys(r))
    local b = r.beacons and r.beacons[1]
    if b then
        show("beacon[1]", keys(b))
        local kids = b.children or {}
        print(("  %-22s %d"):format("beacon[1].children", #kids))
        if kids[1] then show("child[1]", keys(kids[1])) end
        if kids[1] then
            local rows = kids[1].rows
            print(("  %-22s %s"):format("child[1].rows",
                  rows and ("present, "..#rows.." row(s)") or "ABSENT"))
        end
    end
elseif mode == "bucket" then
    local Rule = assert(dofile(here .. "../../COA_DungeonRun/rule.lua"))
    local Routes
    Routes = {
        Get = function(id) return id == rid and r or nil end,
        ChildrenOf = function(b) return b.children or {} end,
        ReachOf = function(x) return x.radius, x.bandUp end,
        RowsOf = function(c) return c.rows or {} end,
    }
    _G.COA_DungeonRun_NS = { Rule = Rule, Routes = Routes,
                             Adaptor = { Has = function() return true end } }
    local Bucket = assert(dofile(here .. "../../COA_DungeonRun/bucket.lua"))
    print("")
    print("  Bucket.Build on the REAL store shape (smokes use a stub Routes):")
    local ok, why = Bucket.Build(r.mapID, rid, Routes)
    if not ok then
        print(("    REFUSED: %s"):format(tostring(why)))
        print("    * a refusal here is the tool working - it is what the bench needs to see")
    else
        local n = 0
        for _ in pairs(ok.stages or {}) do n = n + 1 end
        print(("    built: %d stage bucket(s), count %s, bounced %s"):format(
              n, tostring(ok.count), tostring(ok.bounced)))
    end
else
    print("  unknown mode: " .. tostring(mode))
end
print("")
"""


def main():
    if "--list" in sys.argv:
        for f in scrapes():
            print("   " + f)
        return 0
    mode = "shape"
    for a in sys.argv[1:]:
        if not a.startswith("-"):
            mode = a
    path = pick(DEFAULT) or (os.path.join(RAW, scrapes()[-1]) if scrapes() else None)
    if not path:
        print("   no scraped store found under landing/raw")
        return 1
    if not os.path.isfile(LUA):
        print("   lua5.1 not found at %s" % LUA)
        return 1
    src = LUA_SRC.replace("%SMOKE%", SMOKE.replace("\\", "/"))
    tmp = os.path.join(SMOKE, "_inspect_tmp.lua")
    io.open(tmp, "w", encoding="utf-8", newline="\n").write(src)
    try:
        print("   scrape: %s" % os.path.basename(path))
        out = subprocess.run([LUA, tmp, path.replace("\\", "/"), mode, str(CAP)],
                             capture_output=True, text=True, cwd=ROOT)
        sys.stdout.write(out.stdout)
        if out.returncode != 0:
            sys.stdout.write(out.stderr[:800])
    finally:
        if os.path.isfile(tmp):
            os.remove(tmp)
    return 0


if __name__ == "__main__":
    sys.exit(main())
