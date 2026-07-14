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
  py description_report.py agree    -> append each member's EFFECT CHAIN (the mechanics witness) and verdict the
                                       agreement: AGREE (both witnesses) | DESC? (mech speaks, words silent) |
                                       MECH? (words speak, mech scripted/dummy) | ?? (both silent - the dark rows)
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
    # NOTE: talent-scrape texts carry $-variable numbers ("for $8s seconds") which clean() strips -> numbers are
    # OPTIONAL in every pattern (the 51-hit "for seconds" lesson, mined from the DESC? pile 2026-07-14).
    "dot":      [r"damage over\s+(\d+\s*)?(sec|time)", r"over\s+(\d+(\.\d+)?\s*)?sec", r"(every|each)\s+(\d+(\.\d+)?\s*)?sec",
                 r"per second", r"\btick", r"\bbleed", r"\bburn(?:ing|s)?\b", r"\bpoison", r"\bdisease", r"\bdot\b",
                 r"builds over time", r"dealt slowly"],
    "maintain": [r"(takes?|taking|deal(s|ing)?)\s+(\d+%\s*)?(increased|more|additional)", r"increas\w+ damage taken",
                 r"damage taken by", r"vulnerab", r"reduc\w+ (their )?armor", r"armor (is )?reduced",
                 r"reduc\w+ healing", r"healing (received|taken)",
                 r"stacking(\s+\w+)?\s+times", r"\bstack(s|ing)\b",
                 r"(melee|ranged|attack|casting|movement)\s+(and\s+\w+\s+)?speed", r"reduc\w+[^.]{0,24}speed",
                 r"\bcurse", r"\binject", r"\bmark(s|ed|ing)?\b"],
    "window":   [r"(for|lasts?|over( the)? next)\s+(\d+(\.\d+)?\s*)?sec", r"until (removed|cancelled)",
                 r"\bappl(y|ies|ying)\b"],
    "builder":  [r"generat\w+", r"gain(s|ing)?\s+\d+", r"restor\w+ \d+", r"grant\w+ \d+ \w+$"],
    "cc":       [r"\bstun", r"\broot", r"\bslow(s|ed|ing)?\b", r"\bsilenc", r"\bimmobiliz", r"\bfear",
                 r"\bincapacitat", r"knock(s|ed)? (back|down)", r"\bdisorient"],
}
# ------------------------------------------------------------------------------------------------------------------


def clean(t):
    t = re.sub(r"\|c[0-9a-fA-F]{8}|\|r", "", t or "")
    t = re.sub(r"\$\w+", "", t)
    return re.sub(r"\s+", " ", t).strip().lower()


def find_text(d, desc, sids, depth=3):
    """a member's meaning text: own description, else walk the triggeredBy via-chain (triggered debuffs carry
    their text on the applying ability - sometimes two hops up)."""
    seen, frontier = set(), [str(s) for s in sids]
    for _ in range(depth):
        nxt = []
        for s in frontier:
            if s in seen:
                continue
            seen.add(s)
            if s in desc:
                return desc[s]
            for t in (d.get(s, {}).get("coa") or {}).get("triggeredBy") or []:
                nxt.append(str(t.get("via")))
        frontier = nxt
    return None


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
        text = clean(find_text(d, desc, sids) or "")
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


# the mechanics witness: aura families (from the flat-debuff work) that corroborate each word family
MAINTAIN_AURAS = {"mod_damage_percent_taken", "mod_spell_damage_from_caster", "mod_resistance", "mod_resistance_pct",
                  "mod_crit_chance_for_caster", "mod_healing_pct", "school_heal_absorb", "mod_damage_percent_done",
                  "mod_melee_ranged_haste", "mod_attack_power", "mod_hit_chance"}


def agree():
    desc = load_descs()
    members, d = selected_members()
    res = json.load(open(RESOLVED, encoding="utf-8"))
    lex = {fam: [re.compile(p) for p in pats] for fam, pats in LEXICON.items()}
    verdicts = Counter()
    review = []
    for cls, spec, fam, rep, sids in sorted(members):
        text = clean(find_text(d, desc, sids) or "")
        words = {family for family, pats in lex.items() if any(p.search(text) for p in pats)}
        auras = set()
        for s in sids:
            for e in (res.get(str(s), {}).get("edges") or []):
                if e.get("rel") == "applies_aura" and e.get("aura_name"):
                    auras.add(e["aura_name"])
        mech = set()
        if any("periodic" in a for a in auras):
            mech.add("dot")
        if auras & MAINTAIN_AURAS:
            mech.add("maintain")
        if auras & CC:
            mech.add("cc")
        core_w, core_m = words & {"dot", "maintain"}, mech & {"dot", "maintain"}
        if core_w & core_m:
            v = "AGREE"
        elif core_m and not core_w:
            v = "DESC?"
        elif core_w and not core_m:
            v = "MECH?"
        else:
            v = "??"
        if mech & {"cc"} or words & {"cc"}:
            v += "+cc"
        verdicts[v] += 1
        if not v.startswith("AGREE"):
            review.append("%-7s %s:%s:%s:%d: words=%s mech=%s auras=%s"
                          % (v, cls, spec, fam, rep, sorted(words) or "-", sorted(mech) or "-",
                             ",".join(sorted(auras))[:48] or "-"))
    print("verdicts over %d members:" % sum(verdicts.values()))
    for v, n in verdicts.most_common():
        print("  %-9s %d" % (v, n))
    print("\nREVIEW (everything not AGREE):")
    for r in review:
        print("  " + r)


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "rows"
    if mode == "mine":
        mine()
    elif mode == "agree":
        agree()
    else:
        rows("-misses" in sys.argv)
