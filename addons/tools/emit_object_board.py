"""The object pane, v2 - RESTING and TELLING, two boards from one declaration.

v1 was honest and timid: the hairline returned 95px of chrome and 14 lone content rows spent all
of it, landing at 674 against today's 575. The accounting is what found the better move.

★★★ THE CLAIM, and it is measurable rather than tasteful: FIVE of the eight readouts are TELLS -
`object.boss.tell` (no name, it will not listen), `object.match`, `object.stagematch`,
`object.ordinal.match`, `object.note.ghost`. Each reacts to the control above it and each holds a
permanent row to say something it only SOMETIMES has to say. A tell belongs to its CONTROL, not
to the column: it appears when it has something to say, and the pane is bigger exactly when you
want the room.

⚠ NOT AN INVENTION: `object.md` already records heights-per-subject, so a pane whose height
changes is in this design's existing vocabulary. This applies a rule they have; it does not add
one.

⚠ THE COST, stated up front because a proposal that only lists its wins is an advert: a pane that
resizes while you type MOVES CONTROLS UNDER THE CURSOR. That is the cousin of the "weird stalling
if it updates per entry" complaint. Which is why this emits BOTH states as boards to flip between
and judge, rather than a recommendation.
"""
import sys
sys.stdout.reconfigure(encoding="utf-8")

import json
from datetime import date
from pathlib import Path

PB = (Path(r"F:\Projects_games\World of Warcraft - Conquest of Azeroth")
      / "addons" / "tools" / "PaneBoard" / "workspace" / "pane-board")

H = {"edit": 20, "check": 20, "button": 20, "dropdown": 32, "readout": 14, "rule": 14}
COL_X, COL_W = 18, 204
GAP, ZONE_GAP = 6, 10
DD_ASK = 154            # a dropdown's ART is asked + 50, so 154 draws exactly the 204 column

# (name, kind, width, why, tell?) - `tell` marks a readout that reacts to the control above it
# and is therefore CONDITIONAL: absent in the resting state.
ZONES = [
    ("WHAT IT IS", [
        ("object.title", "readout", "full", "names the SUBJECT, not the surface", False),
        ("object.fact", "readout", "full", "what this object is, in one line", False),
        ("object.name", "edit", 150, "the name", False),
        ("object.move", "check", 26, "arms the MAP to drag this", False),
        ("object.path", "readout", "full", "the address read back, never typed", False),
        ("object.ordinal", "edit", 60, "position in THIS beacon - BLANK is a real answer", False),
        ("object.ordinal.match", "readout", 138, "how many others sit here", True),
        ("object.delete", "button", 80, "irreversible - warns before", False),
    ]),
    ("HOW IT DETECTS", [
        ("object.sense", "dropdown", DD_ASK, "stage one of sense", False),
        ("object.boss", "dropdown", DD_ASK, "picked from the loaded run", False),
        ("object.boss.tell", "readout", "full", "no name - it will not listen", True),
        ("object.role", "dropdown", DD_ASK, "which detector this child uses", False),
        ("object.match", "readout", "full", "another child already claims this role", True),
        ("object.shape", "dropdown", DD_ASK, "", False),
        ("object.reach", "edit", 60, "the flat radius", False),
        ("object.reach.up", "edit", 60, "the upward half of the band", False),
    ]),
    ("WHAT IT DOES", [
        ("object.action", "dropdown", DD_ASK, "the thinnest control, the most room", False),
        ("object.outcome.n", "edit", 60, "live only when outcome is go-to-stage", False),
        ("object.childstage", "edit", 60, "what this child WRITES when satisfied", False),
    ]),
    ("STAGE", [
        ("object.stage", "edit", 60, "", False),
        ("object.stagematch", "readout", 138, "a WARNING, not a readout", True),
        ("object.outcome", "dropdown", DD_ASK, "what satisfying does to the index", False),
    ]),
    ("ROUTE INSTRUCTIONS", [
        ("object.note", "edit", 196, "what the person running the route reads", False),
        ("object.note.ghost", "readout", "full", "a separate FontString, never placeholder", True),
    ]),
]


def build(telling):
    """One layout function, two states - so the two boards cannot drift apart."""
    panes, y = [], 12
    for zone, items in ZONES:
        panes.append({
            "id": f"rule-{zone.lower().replace(' ', '-')}",
            "label": f"— {zone}",
            "grid": {"x": COL_X, "y": y, "w": COL_W, "h": H["rule"]},
            "importance": "backing", "locked": False, "opportunityType": "", "fields": {},
            "material": {"type": "image", "path": "materials/ChallengeMode-RankLineDivider.png",
                         "fit": "contain", "opacity": 1, "role": "zone-rule"},
            "notes": "ZONE RULE - 14px where a header block costs 39.\n"
                     "ChallengeMode-RankLineDivider: 193x9, wide-3, free, hue 50.8.",
        })
        y += H["rule"] + GAP

        live = [it for it in items if telling or not it[4]]
        i = 0
        while i < len(live):
            name, kind, w, why, is_tell = live[i]
            width = COL_W if w == "full" else w
            pair = None
            if i + 1 < len(live):
                n2, k2, w2, why2, t2 = live[i + 1]
                if w != "full" and w2 != "full" and width + w2 + GAP <= COL_W:
                    pair = live[i + 1]
            row_h = max(H[kind], H[pair[1]] if pair else 0)
            for idx, (nm, kd, wd, wy, tl) in enumerate([live[i]] + ([pair] if pair else [])):
                px = COL_X if idx == 0 else COL_X + width + GAP
                pw = (COL_W if wd == "full" else wd)
                panes.append({
                    "id": nm.replace(".", "-"),
                    "label": nm,
                    "grid": {"x": px, "y": y, "w": pw, "h": H[kd]},
                    "importance": "show", "locked": False,
                    "opportunityType": "conditional" if tl else "",
                    "fields": {},
                    "notes": f"{kd} · {pw}x{H[kd]}\n{wy}"
                             + ("\n★ A TELL - conditional, absent when it has nothing to say."
                                if tl else "")
                             + ("\n⚠ dropdown ART = asked + 50: 154 asked draws 204 = the column"
                                if kd == "dropdown" else ""),
                })
            if pair:
                i += 1
            y += row_h + GAP
            i += 1
        y += ZONE_GAP - GAP
    return panes, y + 12


built = {t: build(t) for t in (False, True)}
rest_n, rest_h = len(built[False][0]), built[False][1]
tell_n, tell_h = len(built[True][0]), built[True][1]

for telling in (False, True):
    panes, total = built[telling]
    state = "telling" if telling else "resting"
    agent = (
        f"THE OBJECT PANE - {state.upper()} state. {len(panes)} panes, {total}px. "
        f"Today's child: 575px. Resting {rest_h} · telling {tell_h}.\n\n"
        "★ THE MOVE: five of the eight readouts are TELLS - boss.tell, match, stagematch, "
        "ordinal.match, note.ghost. Each reacts to the control above it and each holds a "
        "permanent row to say something it only sometimes has to say. A tell belongs to its "
        "CONTROL, not to the column: it appears when it has something to say, and the pane is "
        "bigger exactly when you want the room.\n\n"
        "★ THE CHROME: a gold hairline (ChallengeMode-RankLineDivider, wide-3, free, hue 50.8) "
        "plus inline caption costs 14px where object.md's header block costs 39. Five zones: "
        "195 -> 100.\n\n"
        "⚠ NOT AN INVENTION: object.md already records heights-per-subject, so a pane whose "
        "height changes is in this design's existing vocabulary.\n\n"
        "⚠ THE COST, said up front: a pane that resizes while you type MOVES CONTROLS UNDER THE "
        "CURSOR - the cousin of the weird-stalling-per-entry complaint. Which is why this is two "
        "boards to flip between, not a recommendation.\n\n"
        "⚠ Every dropdown asks 154, not 204: its ART is asked + 50. The board draws the ASKED "
        "rect, so dropdowns LOOK inset here and would fill the column in the client - the "
        "art-vs-rect gap, visible in this very picture.")
    board = {
        "id": f"objectpane-{date.today().isoformat()}-{state}",
        "title": f"Object pane — {state} (child)",
        "status": "agent-proposal",
        "viewport": {"preset": f"240x{total}", "width": 240, "height": total, "grid": 1},
        "source": {"createdBy": "agent", "basedOn": "addons/planning/interface/object.md",
                   "project": "COA_DungeonRun",
                   "context": f"content reorganised, {state} state - spatial taste only"},
        "panes": panes,
        "review": {"humanIntent": "", "agentNotes": agent, "acceptedByHuman": False},
        "collaboration": {"notes": {"human": "", "labs": ""}, "commands": []},
        "screenNote": agent,
    }
    (PB / "agent-proposals" / f"{board['id']}.json").write_text(
        json.dumps(board, indent=1, ensure_ascii=False), encoding="utf-8")
    print(f"{state:<8} {len(panes):>3} panes  {total:>4}px  -> {board['id']}.json")

print(f"\nthe five tells cost {tell_h - rest_h}px of PERMANENT height in v1")
print(f"against today's 575: {575 - rest_h:+d} at rest, {575 - tell_h:+d} when all five speak")
