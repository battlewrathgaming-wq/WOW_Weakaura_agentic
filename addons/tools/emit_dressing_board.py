# -*- coding: utf-8 -*-
r"""emit_dressing_board.py - candidate art on real rectangles, as a PaneBoard proposal.

    py addons\tools\emit_dressing_board.py store-goldborder-top challenges-timerbg
    py addons\tools\emit_dressing_board.py --set store-goldborder
    py addons\tools\emit_dressing_board.py --atlas ObjectiveTracker --free --limit 12

★★★ WHY, and it is a JOIN rather than a capability. Three pieces already existed and none of
them met:

    PaneBoard          renders a `material` on a pane - a PNG under workspace/pane-board/
                       materials/, with fit contain|cover|tile and an opacity, plus a sidebar
                       editor and a full two-way loop (agent-proposals / human-sketches /
                       captures carrying a humanSignal / board-events.ndjson)
    emit_atlas_sheet   `--materials` writes atlas art as PNGs into exactly that folder
    board_from_geom    already writes boards into agent-proposals/

⟶ But NOTHING HAS EVER SET `material` ON A PANE. That is why the materials folder was empty: not
a missing capability, a missing join. This is the join and nothing else.

★★ WHAT IT BUYS. `WA_PANE_BOARD_SMOKE=1` drives the board and exports a PNG, so the agent can
SEE the result without a person at the screen; and the same board opens for Battlewrath to drag,
resize and annotate, which is the human half of a loop that was built for two and has only ever
run for one. Flat sheets go one way; this goes both.

⚠⚠ AND IT WILL LIE ABOUT BORDERS, WHICH IS SAID ON THE BOARD ITSELF. PaneBoard's fits are
`contain` (letterbox), `cover` (stretch) and `tile` (repeat). None of them is a nine-slice, so a
border set on a resized pane smears its corners exactly as §563's stress sheet showed. ⟶ The
board is HONEST for flat art - fades, tiles, plates at native size - and MISLEADING for anything
nine-sliced. A `fit` is chosen per piece from its measured contract rather than by default, and
the pieces that cannot be trusted are labelled so on the pane.

⚠ Emitted as an AGENT PROPOSAL, never over `current-board.json` - `board_from_geom`'s rule, and
it is right: nothing should overwrite whatever a person has open.
"""
import argparse
import json
import re
import subprocess
import sys
from datetime import date
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

REPO = Path(__file__).resolve().parents[2]
TOOLS = REPO / "addons" / "tools"
PB = TOOLS / "PaneBoard" / "workspace" / "pane-board"
MATERIALS, PROPOSALS = PB / "materials", PB / "agent-proposals"
INVENTORY = REPO / "addons" / "staging" / "atlas" / "art_inventory.json"
SETS = REPO / "addons" / "staging" / "atlas" / "art_sets.json"
CENSUS = REPO / "addons" / "maps" / "atlas" / "atlas.census.json"

GAP = 12          # air between panes, so a border's overhang is visible rather than clipped
MARGIN = 20


def safe_material(name):
    """PaneBoard's own path rule, applied here rather than assumed of it.

    `normalizeMaterialPath` refuses a colon, a backslash, a leading slash or `..`, and requires
    a `materials/` prefix and a `.png` suffix. ⚠ A name is DATA; the rule is the consumer's, so
    it is enforced at the point of writing rather than trusted to be already true.
    """
    return "materials/" + re.sub(r"[^A-Za-z0-9._-]", "_", name) + ".png"


def fit_for(contract):
    """The fit a piece's measured contract actually justifies.

    ★ Not a default. `tile` is right for something uniform in both axes; `contain` keeps a
    fixed piece at its true shape rather than stretching it into a lie; `cover` is only ever
    honest for art that may genuinely be stretched both ways.
    """
    if contract in ("both",):
        return "tile"
    if contract in ("wide", "tall"):
        return "contain"
    return "contain"


UNTRUSTWORTHY = {"9slice", "wide-3", "tall-3", "9slice-part"}


def main():
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("names", nargs="*")
    ap.add_argument("--set", dest="set_", help="every piece of a named set (emit_art_sets stem)")
    ap.add_argument("--atlas", help="every named entry on a matching texture")
    ap.add_argument("--free", action="store_true")
    ap.add_argument("--limit", type=int, default=16)
    ap.add_argument("--no-export", action="store_true",
                    help="skip calling emit_atlas_sheet --materials (PNGs already written)")
    args = ap.parse_args()

    inv = {}
    if INVENTORY.is_file():
        inv = {r["name"]: r for r in json.load(open(INVENTORY, encoding="utf-8"))["entries"]}
    census = json.load(open(CENSUS, encoding="utf-8"))["atlases"] if CENSUS.is_file() else {}

    picked = list(args.names)
    if args.set_:
        if not SETS.is_file():
            print("--set needs art_sets.json - run emit_art_sets.py first")
            sys.exit(2)
        rows = json.load(open(SETS, encoding="utf-8"))["rows"]
        hit = next((r for r in rows if r["stem"].lower() == args.set_.lower()), None)
        if not hit:
            print(f"no set named {args.set_!r} - run emit_art_sets.py to list stems")
            sys.exit(2)
        picked += [hit["parts"][k] for k in sorted(hit["parts"])]
    if args.atlas:
        picked += [n for n, r in inv.items()
                   if args.atlas.lower() in r.get("texture", "").lower()]
    if not picked:
        print("nothing selected - give names, --set <stem> or --atlas <substring>")
        sys.exit(2)

    seen, ordered = set(), []
    for n in picked:
        if n not in seen:
            seen.add(n)
            ordered.append(n)
    if args.free:
        ordered = [n for n in ordered if not (census.get(n) or {}).get("claimed")]
    dropped = max(0, len(ordered) - args.limit)
    ordered = ordered[:args.limit]
    if not ordered:
        print("everything was filtered out")
        sys.exit(2)

    # ⚠ The PNGs must exist before the board points at them, or every pane renders empty and
    # the board looks like the ART is missing rather than the EXPORT.
    if not args.no_export:
        cmd = [sys.executable, str(TOOLS / "emit_atlas_sheet.py"), *ordered,
               "--materials", "--out", "dressing_source"]
        r = subprocess.run(cmd, capture_output=True, text=True)
        if r.returncode != 0:
            print("emit_atlas_sheet failed; the board would point at nothing:")
            print(r.stdout[-800:] or r.stderr[-800:])
            sys.exit(2)

    missing = [n for n in ordered if not (MATERIALS / safe_material(n).split("/")[1]).is_file()]
    if missing:
        print(f"⚠ {len(missing)} piece(s) have no PNG and are LEFT OFF the board, by name:")
        for n in missing:
            print(f"    {n}")
        ordered = [n for n in ordered if n not in missing]

    panes, x, y, row_h = [], MARGIN, MARGIN, 0
    width_cap = 900
    untrusted = []
    for n in ordered:
        r = inv.get(n) or {}
        w, h = int(r.get("w") or 64), int(r.get("h") or 64)
        contract = r.get("contract", "?")
        if x + w + MARGIN > width_cap and x > MARGIN:
            x, y = MARGIN, y + row_h + GAP
            row_h = 0
        note = [f"{n}", f"{w} x {h}   contract: {contract}",
                "CLAIMED by the client" if (census.get(n) or {}).get("claimed") else "free"]
        if contract in UNTRUSTWORTHY:
            untrusted.append(n)
            note.append("⚠ NINE-SLICE ART. PaneBoard cannot slice it - resize this pane and "
                        "the corners smear. Judge it at NATIVE SIZE ONLY.")
        panes.append({
            "id": re.sub(r"[^A-Za-z0-9_-]", "-", n).lower(),
            "label": n,
            "grid": {"x": x, "y": y, "w": w, "h": h},
            "importance": "show",
            "locked": False,
            "opportunityType": "",
            "fields": {},
            "material": {"type": "image", "path": safe_material(n),
                         "fit": fit_for(contract), "opacity": 1,
                         "role": "dressing-candidate"},
            "notes": "\n".join(note),
        })
        x += w + GAP
        row_h = max(row_h, h)

    # ⚠⚠ A SET WARNS DIFFERENTLY FROM A PIECE, and the first cut only knew how to warn about
    # pieces. Emitting `store-goldborder` produced eight panes and NO caution, because each
    # piece's own contract is honest - a `top` really is meant to stretch wide. What PaneBoard
    # cannot do is ASSEMBLE them into a frame, and that is a property of the SET, invisible in
    # every individual row. ⟶ The set caution is board-level, because that is where it is true.
    set_note = ""
    if args.set_:
        set_note = (
            f"⚠⚠ THESE ARE THE PIECES OF ONE SET ({args.set_}), NOT independent art. Each is "
            "honest on its own, and PaneBoard cannot ASSEMBLE them: there is no nine-slice fit, "
            "so a frame built from these can be judged for COLOUR and WEIGHT here and never for "
            "how it behaves at a size. That judgement needs the client, or a border-image fit. ")

    stamp = date.today().isoformat()
    agent = (
        set_note
        + "Candidate dressing, at NATIVE SIZE. Every rectangle is the art's own w x h from "
        "AtlasInfo, so nothing here is scaled and nothing is a judgement - the fit per pane "
        "comes from its measured contract, not a default. "
        "⚠ PaneBoard's fits are contain / cover / tile and NONE of them is a nine-slice, so "
        + (f"{len(untrusted)} piece(s) on this board will smear if you resize them and are "
           f"labelled so on the pane. " if untrusted else "")
        + "Drag them, judge them, and write what you think in the notes - the board is the "
          "two-way surface and this is the half that has never been used.")

    board = {
        "id": f"dressing-{stamp}-candidates",
        "title": f"Dressing candidates — {stamp}",
        "status": "agent-proposal",
        "viewport": {"preset": f"{width_cap}x{y + row_h + MARGIN}",
                     "width": width_cap, "height": y + row_h + MARGIN, "grid": 1},
        "source": {"createdBy": "agent",
                   "basedOn": "addons/staging/atlas/art_inventory.json",
                   "project": "COA UI dressing",
                   "context": "client art as candidates - taste only, nothing is decided"},
        "panes": panes,
        "review": {"humanIntent": "", "agentNotes": agent, "acceptedByHuman": False},
        "collaboration": {"notes": {"human": "", "labs": ""}, "commands": []},
        "screenNote": agent,
    }

    PROPOSALS.mkdir(parents=True, exist_ok=True)
    out = PROPOSALS / f"{board['id']}.json"
    out.write_text(json.dumps(board, indent=1, ensure_ascii=False), encoding="utf-8")

    print(f"wrote {out.relative_to(REPO).as_posix()}")
    print(f"  {len(panes)} pane(s), viewport {board['viewport']['preset']}"
          + (f", ⚠ {dropped} dropped by --limit" if dropped else ""))
    if untrusted:
        print(f"  ⚠ {len(untrusted)} nine-slice piece(s) labelled UNTRUSTWORTHY on the pane: "
              + ", ".join(untrusted[:4]))
    print("\n  open it in PaneBoard (it is a PROPOSAL - current-board.json is untouched),")
    print("  or let the agent render it:  set WA_PANE_BOARD_SMOKE=1 and start the app;")
    print("  the PNG path comes back in .tmp/pane-board-smoke/pane-board-smoke-result.json")
    print("  ⚠ Blizzard art: materials/ and staging/ are both gitignored.")


if __name__ == "__main__":
    main()
