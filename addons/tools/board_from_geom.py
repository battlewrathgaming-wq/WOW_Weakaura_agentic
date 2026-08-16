r"""board_from_geom.py - the measured panes, as boards you can drag and annotate.

★★★ WHY (Battlewrath, 2026-08-16): *"Can you construct these for the pane board
instead? We can note in there and such."*

The SVG (§138) is a READ surface - it answers "where is it, what does it say, what does
it do" and then stops. The board is a WORK surface: rectangles you drag at real size,
with a notes field per control. So the same measurement lands somewhere an opinion can
be recorded against the thing rather than typed at me in a chat.

★ ONE BOARD PER SURFACE, because the board's viewport IS a pane - `grid.x/y/w/h` are
exact client pixels and the board is 1:1 with the client only when the viewport is the
pane's own size. Six panes, six boards, emitted as AGENT PROPOSALS so nothing overwrites
whatever is open.

⚠ THE BOARD IS NOT A SECOND INVENTORY - its README is emphatic and it is right. So the
notes carry what a person needs to have an opinion (what it says, what it does, how big)
and NOT `zone`, `kind` or `job`. Those live in one place and this is not it.

⚠ WHAT IS LEFT OUT, SAID ON EVERY BOARD: unregistered Textures (template art), and any
control the capture found unanchored. Both are counted in the board's own notes.

    py addons/tools/board_from_geom.py [record.json]
"""

import glob
import io
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__)).replace("\\", "/")
ROOT = os.path.dirname(os.path.dirname(HERE))
SURFACES = ROOT + "/addons/planning/interface"
OUT = HERE + "/PaneBoard/workspace/pane-board/agent-proposals"

# The surface file each pane's rows live in, so `does` can be lifted for the notes.
FILE_OF = {"object": "object.md", "promoter": "promotion.md", "editor": "curation.md",
           "map": "map.md", "mapcontrols": "map_controls.md", "remote": "remote.md"}
TITLE_OF = {"object": "Object", "promoter": "Promotion", "editor": "Curation",
            "map": "Map", "mapcontrols": "Map controls", "remote": "Remote"}

# ⚠ The board's Importance is a THREE-VALUE SELECT (primary/supporting/quiet), so usage
# cannot be poured into it. This is the mapping, stated rather than silent - and it is a
# starting position, not a claim: it is a dropdown he can change per control.
IMPORTANCE = {"action": "primary", "arm": "primary"}
QUIET = ("readout", "label", "icon", "—")

HEAD = re.compile(r"^([a-z_]+\.[\w.<>|]+)\s+(?:zone|kind)", re.M)
USAGE = re.compile(r"usage ([^\n]+?)(?:\s{2,}forms|\s*$)", re.M)
DOES = re.compile(r"^\s*does\s+(.+)$", re.M)
CODES = re.compile(r"\|c[fF][fF][0-9a-fA-F]{6}|\|r")


def rows_of(name):
    """key -> (usage, does) straight from the surface file."""
    out = {}
    p = os.path.join(SURFACES, name)
    if not os.path.isfile(p):
        return out
    t = io.open(p, encoding="utf-8", newline="").read()
    hits = list(HEAD.finditer(t))
    for i, m in enumerate(hits):
        blk = t[m.start(): hits[i + 1].start() if i + 1 < len(hits) else len(t)]
        u = USAGE.search(blk)
        d = DOES.search(blk)
        out[m.group(1)] = (u.group(1).strip() if u else "",
                           re.sub(r"\s+", " ", d.group(1)).strip() if d else "")
    return out


def slug(s):
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")[:80]


def build(rec):
    payload = json.load(io.open(rec, encoding="utf-8"))["payload"]
    rows = payload["ours"]
    stamp = os.path.basename(rec)[:8]
    stamp = "%s-%s-%s" % (stamp[:4], stamp[4:6], stamp[6:8])

    made = []
    for pane in [r for r in rows if r.get("isPane")]:
        owner = pane["key"].split(".")[0]
        book = rows_of(FILE_OF.get(owner, ""))
        top = pane["bottom"] + pane["h"]

        items, skipped_art, skipped_unanchored, empties = [], 0, [], 0
        for r in rows:
            if r.get("isPane") or r["key"].split(".")[0] != owner:
                continue
            if r.get("isRegion") and not r.get("registered") \
                    and r.get("objectType") == "Texture":
                skipped_art += 1
                continue
            if r.get("left") is None:
                skipped_unanchored.append(r["key"])
                continue

            key = r["key"]
            usage, does = book.get(key, ("", ""))
            text = CODES.sub("", r.get("text") or "").strip()
            if r.get("isRegion") and not text:
                empties += 1

            note = []
            if text:
                note.append('shows: "%s"' % text[:180])
            elif r.get("isRegion"):
                note.append("shows: (empty at capture — a FontString with no text "
                            "measures 1 x 1, so this is present and blank, not absent)")
            if does:
                note.append("does: " + does[:220])
            if usage:
                note.append("usage: " + usage)
            note.append("%s, %.0f x %.0f" % (r.get("objectType") or "?",
                                             r.get("w") or 1, r.get("h") or 1))
            if not r.get("registered"):
                note.append("NOT IN THE INVENTORY — no key, nobody wrote it down")

            items.append({
                "id": slug(key),
                "label": (key.split(".", 1)[1] if "." in key else key)[:80],
                "grid": {
                    "x": int(round(r["left"] - pane["left"])),
                    "y": int(round(top - (r["bottom"] + (r.get("h") or 0)))),
                    "w": max(1, int(round(r.get("w") or 1))),
                    "h": max(1, int(round(r.get("h") or 1))),
                },
                "importance": IMPORTANCE.get(usage,
                                             "quiet" if (not usage or usage.startswith(QUIET))
                                             else "supporting"),
                "locked": False,
                "opportunityType": "",
                "fields": {},
                "notes": "\n".join(note)[:1000],
            })

        agent = ("Measured, not sketched — every rectangle is a position the client "
                 "reported on %s. %d controls. Left out: %d template textures (backdrops, "
                 "dropdown pieces, check frames — they would cover everything beneath)%s. "
                 "%d readouts were empty at capture and are drawn at 1 x 1. Importance is "
                 "a three-value select, so usage was mapped onto it: action/arm -> primary, "
                 "selection/input -> supporting, readout/label -> quiet. That is a starting "
                 "position, not a claim." % (
                     stamp, len(items), skipped_art,
                     ("; %d unanchored (%s)" % (len(skipped_unanchored),
                                                ", ".join(skipped_unanchored[:3]))
                      if skipped_unanchored else ""),
                     empties))

        board = {
            "id": "layout-%s-%s-measured" % (stamp, owner),
            "title": "%s — measured %s" % (TITLE_OF.get(owner, owner), stamp),
            "status": "agent-proposal",
            "viewport": {"preset": "%dx%d" % (round(pane["w"]), round(pane["h"])),
                         "width": int(round(pane["w"])), "height": int(round(pane["h"])),
                         "grid": 1},
            "source": {"createdBy": "agent",
                       "basedOn": "addons/landing/records/" + os.path.basename(rec),
                       "project": "COA_DungeonRun",
                       "context": "measured from the client — spatial taste only"},
            "panes": items,
            "review": {"humanIntent": "", "agentNotes": agent, "acceptedByHuman": False},
            "collaboration": {"notes": {"human": "", "labs": ""}, "commands": []},
            "screenNote": agent,
        }
        p = os.path.join(OUT, board["id"] + ".json")
        io.open(p, "w", encoding="utf-8", newline="\n").write(
            json.dumps(board, indent=1, ensure_ascii=False))
        made.append((board["title"], len(items), board["viewport"]["preset"]))
    return made


def main():
    args = [a for a in sys.argv[1:] if a.endswith(".json")]
    rec = args[0] if args else sorted(
        glob.glob(ROOT + "/addons/landing/records/*__geom.json"))[-1]
    if not os.path.isdir(OUT):
        os.makedirs(OUT)
    for title, n, preset in build(rec):
        print("  %-34s %-9s %d control(s)" % (title, preset, n))
    print("\nOpen the Pane Board and load one from Snapshots (agent-proposal).")


if __name__ == "__main__":
    main()
