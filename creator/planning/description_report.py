"""
description_report.py - the descriptions SELF-REPORT: index every selected member as a row of trigger-word hits.

The validation's second opinion: the scraped descriptions are the game's own MEANING text, independent of the DBC
mechanics the select ran on. Two independent sources agreeing = confidence; disagreeing = a short review list.

Two modes:
  py description_report.py mine     -> derive lexicon CANDIDATES: the selected cohort's distinctive n-grams vs the
                                       all-descriptions background (the name_gaps lift method). Curate these into
                                       LEXICON below - the trigger words are DEFINED from evidence, then human-locked.
  py description_report.py rows     -> the index: CLASS:spec:family:spellID: hit-words   (tolerance = regex families)
  py description_report.py rows -misses  -> also report selected members with ZERO hits (leak candidates)
"""
import json
import os
import re
import sys
from collections import Counter, defaultdict

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.normpath(os.path.join(_THIS, "..", ".."))
sys.path.insert(0, _THIS)
from pull_target_tracker import CC, references_gain, spec_spells

COA = os.path.join(_ROOT, "dependencies", "coa_spells.json")
RESOLVED = os.path.join(_THIS, "resolved.json")
INV = os.path.join(_ROOT, "Weak Auras", "ability_inventory", "out")

# ---- THE LEXICON (DRAFT - curate from `mine` output; tolerance = regex, stems welcome) --------------------------
LEXICON = {
    "dot":      [r"damage over (\d+ )?(sec|time)", r"(every|each)\s+(\d+(\.\d+)?\s*)?sec", r"per second",
                 r"\btick", r"\bbleed", r"\bburn(?:ing|s)?\b", r"\bpoison", r"\bdisease", r"\bdot\b"],
    "maintain": [r"(takes?|taking|deal(s|ing)?)\s+\d+%\s*(increased|more|additional)", r"increas\w+ damage taken",
                 r"damage taken by", r"vulnerab", r"reduc\w+ (their )?armor", r"armor (is )?reduced",
                 r"reduc\w+ healing", r"healing (received|taken)"],
    "window":   [r"(for|lasts?|over( the)? next)\s+\d+(\.\d+)?\s*sec", r"until (removed|cancelled)"],
    "builder":  [r"generat\w+", r"gain(s|ing)?\s+\d+", r"restor\w+ \d+", r"grant\w+ \d+ \w+$"],
    "cc":       [r"\bstun", r"\broot", r"\bslow(s|ed|ing)?\b", r"\bsilenc", r"\bimmobiliz", r"\bfear",
                 r"\bincapacitat", r"knock(s|ed)? (back|down)", r"\bdisorient"],
}
# ------------------------------------------------------------------------------------------------------------------


def clean(t):
    t = re.sub(r"\|c[0-9a-fA-F]{8}|\|r", "", t or "")
    t = re.sub(r"\$\w+", "", t)
    return re.sub(r"\s+", " ", t).strip().lower()


def load_descs():
    desc = {}
    for f in os.listdir(INV):
        if not f.endswith(".json") or f in ("_summary.json", "captures.json"):
            continue
        for ab in json.load(open(os.path.join(INV, f), encoding="utf-8"))["abilities"].values():
            if ab.get("description"):
                for sid in ab.get("spellIds", []):
                    desc[str(sid)] = ab["description"]
    return desc


def selected_members():
    """(cls, spec, family, rep_sid, [sids]) for every Target-tracker member across all pairs."""
    d = json.load(open(COA, encoding="utf-8"))
    res = json.load(open(RESOLVED, encoding="utf-8"))
    pairs = sorted({(r["class"], r["spec"]) for s in d.values()
                    for r in (s.get("coa") or {}).get("direct", []) if r.get("class") and r.get("spec")})
    out = []
    for cls, spec in pairs:
        fams = defaultdict(list)
        for sid, s in spec_spells(d, cls, spec).items():
            ax = (res.get(sid) or {}).get("axes") or {}
            if ax.get("target") not in ("enemy", "both") or ax.get("persistence") != "window":
                continue
            auras = {e.get("aura_name") for e in (res.get(sid) or {}).get("edges", [])
                     if e.get("rel") == "applies_aura"} - {None}
            if auras and not (auras - CC):
                continue
            if references_gain(d, res, sid):
                continue
            fams[s.get("name") or sid].append(int(sid))
        for fam, sids in fams.items():
            out.append((cls, spec, fam, min(sids), sids))
    return out, d


def toks(t):
    words = [w for w in re.findall(r"[a-z]+", t) if len(w) >= 3]
    grams = set(words)
    grams |= {" ".join(words[i:i + 2]) for i in range(len(words) - 1)}
    grams |= {" ".join(words[i:i + 3]) for i in range(len(words) - 2)}
    return grams


def mine():
    desc = load_descs()
    members, _ = selected_members()
    sel_sids = {str(s) for _, _, _, _, sids in members for s in sids}
    fg, bg = Counter(), Counter()
    nf = nb = 0
    for sid, t in desc.items():
        grams = toks(clean(t))
        if sid in sel_sids:
            nf += 1
            for g in grams:
                fg[g] += 1
        nb += 1
        for g in grams:
            bg[g] += 1
    print("selected described: %d | background: %d\n" % (nf, nb))
    scored = sorted(((cnt / nf) / (bg[g] / nb + 1e-9), cnt, g) for g, cnt in fg.items() if cnt >= 12)
    scored.reverse()
    print("top distinctive n-grams of the SELECTED cohort (lift x, hits) - lexicon candidates:")
    for lift, cnt, g in scored[:60]:
        print("  %6.1fx  %4d  %s" % (lift, cnt, g))


def rows(show_misses=False):
    desc = load_descs()
    members, _ = selected_members()
    lex = {fam: [re.compile(p) for p in pats] for fam, pats in LEXICON.items()}
    d = json.load(open(COA, encoding="utf-8"))
    hit_rows, miss_rows = [], []
    for cls, spec, fam, rep, sids in sorted(members):
        text = next((desc[str(s)] for s in sids if str(s) in desc), None)
        if text is None:                                       # triggered debuffs carry no text of their own -
            for s in sids:                                     #  the MEANING lives on the applying ability
                tb = (d.get(str(s), {}).get("coa") or {}).get("triggeredBy") or []
                text = next((desc[str(t.get("via"))] for t in tb if str(t.get("via")) in desc), None)
                if text:
                    break
        text = clean(text or "")
        hits = []
        for family, pats in lex.items():
            words = sorted({m.group(0)[:24] for p in pats for m in [p.search(text)] if m})
            if words:
                hits.append("%s(%s)" % (family, "|".join(words)))
        row = "%s:%s:%s:%d: %s" % (cls, spec, fam, rep, ", ".join(hits) if hits else "-")
        (hit_rows if hits else miss_rows).append(row)
    for r in hit_rows:
        print(r)
    print("\n%d members with hits | %d with NO lexicon hit%s"
          % (len(hit_rows), len(miss_rows), " (leak candidates):" if show_misses and miss_rows else ""))
    if show_misses:
        for r in miss_rows:
            print("  MISS  " + r)


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "rows"
    if mode == "mine":
        mine()
    else:
        rows("-misses" in sys.argv)
