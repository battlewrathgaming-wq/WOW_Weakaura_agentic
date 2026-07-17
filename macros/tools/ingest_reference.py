r"""
ingest_reference.py - ingest EXTERNAL macro material into macros/reference/.

reference/ IS NOT basis/. Nothing here is a fact about this client. This follows the
`ingest/reference/` pattern already in the repo: provenance-stamped external material,
kept SEPARATE from the clean corpus, trusted for STRUCTURE not FIELDS.

WHY AN EXTERNAL SOURCE IS ALLOWED AT ALL (the distinction that makes this safe):

  Recall and secondary sources are INADMISSIBLE as a FACT source
  but ADMISSIBLE as a QUESTION source - because the probe adjudicates.

  A wrong candidate costs one probe row reading "unsupported".
  A wrong fact poisons the basis silently.

That is the whole justification. The Ascension wiki's own Resources section points at
Wowpedia and wowwiki-archive for its "macro conditionals reference" - i.e. it INHERITS
its conditional list from retail documentation rather than verifying it against this
client. So its claims are exactly as unverified as an agent's recall. It is NOT a
witness. It is a CANDIDATE GENERATOR - it closes the standing limit named in
basis/conditionals.json ("a probe only ever proves conditionals someone thought to
ASK about") without anyone inventing the ask-list.

Its ABSENCES prove nothing either: it is a beginner guide, not a reference. A
conditional it omits is simply un-asked, not unsupported.

Determinism: the FETCH is network (not reproducible), so the raw source is saved
VERBATIM and stamped (revid + sha256). Candidate extraction from the saved raw IS
deterministic and re-runs offline by default.

Usage:
    py macros\tools\ingest_reference.py            re-derive from the saved raw
    py macros\tools\ingest_reference.py --fetch    re-fetch (revid change = LOUD)
"""
import hashlib
import json
import re
import sys
import urllib.request
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
REF = ROOT / "macros" / "reference"
UA = "Mozilla/5.0 (CoA macros bench; source-trace tooling)"

SOURCES = [{
    "name": "ascension-wiki-macros",
    "title": "Macros",
    "url": "https://project-ascension.fandom.com/wiki/Macros",
    "api": "https://project-ascension.fandom.com/api.php",
    "standing": "SECONDARY - candidate generator only, never a fact witness",
}]


def get(url):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read().decode("utf-8", "replace")


def fetch(src):
    wt = json.loads(get(f"{src['api']}?action=parse&page={src['title']}"
                        f"&prop=wikitext&format=json"))
    rv = json.loads(get(f"{src['api']}?action=query&prop=revisions"
                        f"&titles={src['title']}&rvprop=ids|timestamp|user&format=json"))
    page = next(iter(rv["query"]["pages"].values()))
    rev = page["revisions"][0]
    return wt["parse"]["wikitext"]["*"], {
        "pageid": wt["parse"]["pageid"], "revid": rev["revid"],
        "revision_timestamp": rev["timestamp"], "revision_user": rev["user"],
    }


# ------------------------------------------------------------- extraction

def extract_candidates(wikitext):
    """Pull CANDIDATE conditionals out of the wiki's tables and example macros.

    Every candidate carries `wiki_says` (their words, not ours) and `seen_in`.
    NONE of this is a claim about the client - it is a list of QUESTIONS.
    """
    cands = {}
    # `[condition]` is the page's own PLACEHOLDER prose ("built into macros using
    # [condition] brackets"), and [[File:...]] is wiki image markup - neither is a
    # conditional. Filtered by name, because a regex over `[...]` cannot tell prose
    # from syntax.
    NOISE = {"condition", "conditions", "spell", "x"}

    def add(tok, where, says=None):
        tok = tok.strip().strip("`'\"")
        if not tok or " " in tok or "|" in tok or tok.lower().startswith("file:"):
            return
        if tok.lower() in NOISE:
            return
        base, arg = (tok.split(":", 1) + [None])[:2]
        e = cands.setdefault(tok, {
            "token": tok,
            "kind": "unit-target" if tok.startswith("@") else "flag",
            "base": base,
            "arg_form": arg,
            "arg_is_placeholder": arg in ("X", "N") if arg else None,
            "negatable_guess": None,
            "wiki_says": says, "seen_in": [],
        })
        if where not in e["seen_in"]:
            e["seen_in"].append(where)
        if says and not e["wiki_says"]:
            e["wiki_says"] = says

    # Declaration tables. A cell can hold MULTIPLE <code> spans - the range rows
    # (`<code>@party1</code>-<code>@party4</code>`) are exactly that, and a
    # single-span pattern skips the whole row SILENTLY, losing @party*/@raid*.
    for m in re.finditer(r"^\|((?:\s*<code>[^<]+</code>\s*[^\n|]*)+)\n\|([^\n|]+)",
                         wikitext, re.M):
        cell, meaning = m.group(1), m.group(2).strip()
        spans = re.findall(r"<code>([^<]+)</code>", cell)
        for tok in spans:
            add(tok, "declaration-table", meaning)
        if len(spans) == 2:                       # a RANGE row: first-last
            lo, hi = spans
            if (mm := re.match(r"(@[a-z]+)(\d+)$", lo)) and re.match(r"@[a-z]+\d+$", hi):
                cands[lo]["range_to"] = hi
                cands[lo]["kind"] = "unit-target (indexed range)"
                cands[hi]["range_from"] = lo
                cands[hi]["kind"] = "unit-target (indexed range)"

    # every [ ... ] clause in example macros
    for m in re.finditer(r"\[([^\]\n]+)\]", wikitext):
        body = m.group(1)
        if body.lower().startswith("file:") or "|" in body:
            continue
        for part in body.split(","):
            add(part, "example-macro")

    # pair up no-prefixed forms the wiki itself declares (evidence of negation)
    for tok in list(cands):
        if tok.startswith("no") and tok[2:] in cands:
            cands[tok]["negatable_guess"] = f"negation of `{tok[2:]}` (wiki declares BOTH)"
            cands[tok[2:]]["negatable_guess"] = f"wiki declares `{tok}` too"
    return dict(sorted(cands.items()))


def extract_commands(wikitext):
    return sorted({m.group(1) for m in re.finditer(r"(/[a-z]+)", wikitext)
                   if len(m.group(1)) > 2})


EXTRACT = ROOT / "Outputs" / "client_interface" / "patch-B" / "Interface"


def source_recognized_targets():
    """Target tokens the client's OWN Lua special-cases, e.g.

        local castAtCursor = target and target:lower() == "cursor"

    `target` here is what SecureCmdOptionParse HANDED BACK, so a handler comparing
    it to a literal is source evidence the C parser passes that token through. This
    is the ONLY source witness the conditional vocabulary has anywhere on this
    client - and it reaches TARGET TOKENS ONLY, never flags.

    Mechanical, not annotated: hand-listing this is how you miss the second one.
    """
    found = {}
    if not EXTRACT.is_dir():
        return found
    for p in sorted(EXTRACT.rglob("*.lua")):
        if not p.is_file():
            continue
        txt = p.read_text("utf-8", "replace")
        for m in re.finditer(r'target\s*(?::lower\(\))?\s*==\s*"([a-z]+)"', txt):
            line = txt[:m.start()].count("\n") + 1
            found.setdefault("@" + m.group(1), []).append(
                f"{p.relative_to(EXTRACT.parent).as_posix()}:{line}")
    return found


def join_corroborations(cands):
    """reference x basis - which wiki claims does the client's own source back?"""
    src = source_recognized_targets()
    out = []
    for tok, where in sorted(src.items()):
        out.append({
            "candidate": tok,
            "wiki_claims": tok in cands,
            "source_witness": where,
            "what_it_proves": (
                f'the client\'s own Lua compares the parser\'s returned target to "{tok[1:]}", '
                f"so a HANDLER anticipates {tok} and SecureCmdOptionParse can return it. "
                f"This proves the HANDLER supports it - it does NOT prove the parser "
                f"validates it (see two_mechanisms)."),
            "standing": "SOURCE-CORROBORATED (handler-side). Still wants the live probe.",
        })
    return out


TWO_MECHANISMS = {
    "why_this_matters": (
        "`@unit` and `[flag]` are NOT the same mechanism and do NOT have the same proof "
        "method. Conflating them is the easiest way to write a confident wrong guide."),
    "@unit / target=unit": {
        "mechanism": "HYPOTHESIS: a pass-through STRING. SecureCmdOptionParse appears to "
                     "return whatever follows @, and support lives DOWNSTREAM - in the "
                     "handler's own special-casing (/cast checks target=='cursor' and "
                     "hands off to Custom_HandleTerrainClick) and in unit resolution.",
        "consequence": "the differential-polarity matrix does NOT apply - there is likely "
                       "no [no@cursor]. Asking 'is @cursor supported' is really asking two "
                       "questions: does the parser return it, and does anything downstream "
                       "honour it.",
        "probe_row_that_settles_it": 'SecureCmdOptionParse("[@banana] X") - if it returns '
                                     'target="banana" for a nonsense unit, @ is pass-through '
                                     "and the vocabulary question does not apply to it at all.",
        "status": "HYPOTHESIS - not asserted. The probe settles it in one row.",
    },
    "[flag]": {
        "mechanism": "actually EVALUATED by the C parser (combat, mod:shift, group, ...).",
        "consequence": "this is what the differential-polarity matrix in "
                       "basis/conditionals.json is for. THIS is the vocabulary question.",
    },
}


def extract_grammar(wikitext):
    """Grammar CLAIMS - hypotheses about how clauses compose. Not verified."""
    claims = []
    for pat, claim in [
        (r"first valid one is used|first '''true''' condition",
         "clauses evaluate in order; the FIRST true one wins"),
        (r"commas.*group fallback|Use <code>,</code>",
         "`,` = AND within one clause"),
        (r"<code>;</code> to separate",
         "`;` = separates alternative condition sets"),
        (r"noexists.*shorthand",
         "`no` prefix negates a flag (wiki calls [noexists] 'shorthand')"),
        (r"reset=(\d+)",
         "/castsequence takes a `reset=N` parameter"),
        (r"#showtooltip",
         "#showtooltip as first line drives dynamic tooltip"),
    ]:
        if re.search(pat, wikitext):
            claims.append(claim)
    return claims


# ---------------------------------------------------------------- emission

def main():
    REF.mkdir(parents=True, exist_ok=True)
    do_fetch = "--fetch" in sys.argv

    for src in SOURCES:
        raw_path = REF / f"{src['name']}.wikitext"
        meta_path = REF / f"{src['name']}.json"

        if do_fetch or not raw_path.is_file():
            print(f"fetching {src['url']} ...")
            wikitext, rev = fetch(src)
            prev = None
            if meta_path.is_file():
                prev = json.load(open(meta_path, encoding="utf-8"))["provenance"].get("revid")
            if prev and prev != rev["revid"]:
                print(f"  !! REVID CHANGED {prev} -> {rev['revid']} - the page moved under us; "
                      f"re-read the diff before trusting derived candidates")
            raw_path.write_text(wikitext, encoding="utf-8")
        else:
            wikitext = raw_path.read_text(encoding="utf-8")
            rev = (json.load(open(meta_path, encoding="utf-8"))["provenance"]
                   if meta_path.is_file() else {})
            rev = {k: rev.get(k) for k in ("pageid", "revid", "revision_timestamp",
                                           "revision_user")}
            print(f"re-deriving from saved raw (revid {rev.get('revid')}) - "
                  f"pass --fetch to re-pull")

        cands = extract_candidates(wikitext)
        payload = {
            "standing": src["standing"],
            "NOT_A_FACT_SOURCE": (
                "Nothing in this file is a fact about the CoA client. These are CANDIDATES "
                "- questions for the live probe to adjudicate. Do not cite reference/ as "
                "basis/. The wiki's own Resources section points at Wowpedia and "
                "wowwiki-archive for its conditional reference, i.e. it inherits from RETAIL "
                "docs rather than verifying against this client - exactly as unverified as "
                "agent recall."),
            "why_allowed": (
                "Recall and secondary sources are inadmissible as a FACT source but "
                "admissible as a QUESTION source, because the probe adjudicates. A wrong "
                "candidate costs one probe row reading 'unsupported'. A wrong fact poisons "
                "the basis silently."),
            "absence_proves_nothing": (
                "This is a beginner guide, not a reference. A conditional it omits is "
                "UN-ASKED, not unsupported. The rim stays open after probing this list."),
            "provenance": {
                "url": src["url"], "api": src["api"],
                **rev,
                "raw_file": raw_path.name,
                "raw_sha256": hashlib.sha256(wikitext.encode("utf-8")).hexdigest(),
                "raw_chars": len(wikitext),
                "ingested_at": datetime.now().isoformat(timespec="seconds"),
                "ingested_by": "macros/tools/ingest_reference.py",
            },
            "candidate_count": len(cands),
            "candidates": cands,
            "grammar_claims": extract_grammar(wikitext),
            "commands_mentioned": extract_commands(wikitext),
            "two_mechanisms": TWO_MECHANISMS,
            "corroborations": join_corroborations(cands),
            "corroboration_note": (
                "The ONLY source witness the conditional vocabulary has on this client. "
                "It reaches TARGET TOKENS only (a handler comparing the parser's returned "
                "target to a literal), never flags like [combat]. Everything else in "
                "`candidates` has NO source witness of any kind and is purely a question "
                "for the probe."),
        }
        with open(meta_path, "w", encoding="utf-8") as f:
            json.dump(payload, f, indent=1, ensure_ascii=False)
            f.write("\n")
        print(f"  -> {meta_path.name}: {len(cands)} candidates, "
              f"{len(payload['grammar_claims'])} grammar claims "
              f"(revid {rev.get('revid')}, edited {rev.get('revision_timestamp')})")


if __name__ == "__main__":
    main()
