-- route_chain.lua - GENERATED, DO NOT EDIT BY HAND.
--
-- ★ Emitted by addons/tools/emit_chain_route.py from a landed capture. Every
-- beacon below IS a sample the player provably occupied, so the seed-once law
-- holds by construction and nothing here is invented.
--
--   source   20260817_075532__rfc_combat-20__markers.jsonl
--   run      rfc_combat   zone Ragefire Chasm
--   kind     pin   (6 beacons, ordered by marker time)
--   sha      f9092b22ff1ab851
--
-- ⚠ Re-emit rather than edit. A hand-touched route stops being traceable to the
-- capture it came from, which is the whole reason it is generated.
--
-- ★★★ WHY THIS IS A REFERENCE AND NOT THE THING §17 REFUSES.
-- It looks like per-dungeon authored content — a named dungeon's positions, in a
-- source file, in an addon. The audit flagged it as approaching that bound
-- (driver_reconciliation.md §2, C3 §5.3) and it was right to. Kept, annotated,
-- rather than hidden — Battlewrath, §292: keep it as a ref with its why-not.
--
-- The distinction, and it is not a technicality:
--
--   pfQuest / GatherMate2   ship authored node lists the addon DEPENDS ON. Remove
--                           the data and the product stops working. The knowledge
--                           IS the product.
--   this file               a FIXTURE regenerated from OUR OWN landed capture. No
--                           consumer reads it; no product path touches it; delete
--                           it and only a dev probe loses its input. It carries the
--                           capture's sha so it is traceable back to a run we took.
--
-- ⚠ Two things keep that true, and both are checkable: it lives in COA_DevDump (a
-- probe addon, never shipped as the product), and every beacon in it is a SAMPLE
-- rather than a placement — the seed-once law, by construction. If either stops
-- being true, this stops being a reference and becomes content.

local ADDON, D = ...

D.routeChain = {
    source = "20260817_075532__rfc_combat-20__markers.jsonl",
    run = "rfc_combat",
    zone = "Ragefire Chasm",
    kind = "pin",
    mapID = 389,
    sha = "f9092b22ff1ab851",
    beacons = {
        { x = -231.5076, y = -33.7944, z = -56.5227, mapID = 389, kind = "pin", n = 1 },
        { x = -298.4815, y = -43.4497, z = -60.9313, mapID = 389, kind = "pin", n = 2 },
        { x = -140.0803, y = 57.4936, z = -22.9057, mapID = 389, kind = "pin", n = 3 },
        { x = -247.6987, y = 140.5771, z = -18.5699, mapID = 389, kind = "pin", n = 4 },
        { x = -313.4181, y = 220.9806, z = -22.6443, mapID = 389, kind = "pin", n = 5 },
        { x = -366.8127, y = 171.6205, z = -21.8100, mapID = 389, kind = "pin", n = 6 },
    },
}
