"""decode_build.py - decode an ascension.gg CoA builder export string / share URL.

Codec (reverse-engineered + validated 2026-07-27 on a real Reaper build):
  URL path segment (or raw string) -> URL-decode -> base64 -> raw DEFLATE
  (zlib wbits=-15) -> a ':'-delimited token list. Each token is an integer id,
  optionally suffixed 'tN':
    - plain id  = an ABILITY node, keyed by spellId
    - id + 'tN' = a TALENT node at rank N, keyed by the talent's node `id`

Selection is IMPLICIT: only chosen nodes appear (presence = selected), so there
is no "is this selected?" ambiguity - that's the string path's advantage over a
live talent-tree walk (which must answer that per node).

Names/context are mapped from this repo's own data:
  dependencies/coa_spells.json  (spellId -> name)
  Input/<class>_talents.json    (node id / spellId -> name, tree, entryType)

Usage:
  py decode_build.py "<export string>"
  py decode_build.py "https://ascension.gg/.../builder/coa/overview/<segment>"
"""
import base64, zlib, json, re, os, sys, urllib.parse, glob

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def extract_segment(arg):
    arg = arg.strip()
    if "/" in arg and ("builder" in arg or arg.lower().startswith("http")):
        seg = arg.rstrip("/").split("/")[-1]
    else:
        seg = arg
    return urllib.parse.unquote(seg)


def inflate(seg):
    raw = base64.b64decode(seg)
    for wb in (-15, 15, 31, 47):
        try:
            return zlib.decompress(raw, wb).decode("utf-8")
        except Exception:
            continue
    raise ValueError("could not inflate - the builder codec may have changed")


def parse_tokens(text):
    out = []
    for t in text.split(":"):
        m = re.match(r"^(\d+)(?:t(\d+))?$", t)
        if m:
            out.append((int(m.group(1)), int(m.group(2)) if m.group(2) else None))
    return out


def load_maps():
    spells = json.load(open(os.path.join(REPO, "dependencies", "coa_spells.json"), encoding="utf-8"))
    by_spell, by_node = {}, {}
    for path in glob.glob(os.path.join(REPO, "Input", "*_talents.json")):
        cls = os.path.basename(path).replace("_talents.json", "")
        data = json.load(open(path, encoding="utf-8"))

        def walk(o):
            if isinstance(o, dict):
                if "name" in o:
                    rec = {"name": o["name"], "tree": o.get("tree"),
                           "type": o.get("entryType"), "class": cls}
                    if o.get("spellId"):
                        by_spell.setdefault(int(o["spellId"]), rec)
                    if o.get("id"):
                        try:
                            by_node.setdefault(int(o["id"]), rec)
                        except (ValueError, TypeError):
                            pass
                for v in o.values():
                    walk(v)
            elif isinstance(o, list):
                for v in o:
                    walk(v)
        walk(data)
    return spells, by_spell, by_node


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    text = inflate(extract_segment(sys.argv[1]))
    entries = parse_tokens(text)
    spells, by_spell, by_node = load_maps()

    print(f"decoded {len(entries)} nodes\n")
    print(f"{'ID':>8} {'kind':<9} {'name':<26} {'tree / type / class'}")
    print("-" * 80)
    unresolved = []
    for sid, rank in entries:
        is_tal = rank is not None
        rec = (by_node.get(sid) if is_tal else by_spell.get(sid)) or by_spell.get(sid) or by_node.get(sid)
        sp = spells.get(str(sid))
        name = (rec or {}).get("name") or (sp["name"] if sp else None)
        if not name:
            unresolved.append(sid)
            name = "?? (not in repo snapshot)"
        ctx = f"{rec['tree']} / {rec['type']} / {rec['class']}" if rec else "-"
        kind = f"talent r{rank}" if is_tal else "ability"
        print(f"{sid:>8} {kind:<9} {name:<26} {ctx}")
    if unresolved:
        print(f"\nunresolved ids (not in this repo's data snapshot): {unresolved}")


if __name__ == "__main__":
    main()
