r"""
ingest_reference.py - ingest EXTERNAL macro material into macros/reference/ and emit
the QUESTION REGISTER (candidates.json) that the live probe adjudicates.

reference/ IS NOT basis/. Nothing here is a fact about this client. Follows the repo's
`ingest/reference/` pattern: provenance-stamped external material, separate from the
clean corpus, trusted for STRUCTURE not FIELDS.

THE RULE THAT MAKES THIS SAFE:

    Recall and secondary sources are INADMISSIBLE as a FACT source
    but ADMISSIBLE as a QUESTION source - because the probe adjudicates.

    A wrong candidate costs one probe row reading "unsupported".
    A wrong fact poisons the basis silently.

THE SOURCE CHAIN (each cited by the one above it - we followed the citations):
  ascension-wiki/Macros            the server's own guide. Its Resources section points
                                   at the two below for its "conditionals reference" -
                                   i.e. it INHERITS from retail docs rather than
                                   verifying against this client.
  wowwiki-archive/Making_a_macro   the OLD wowwiki, frozen 2018. Documents spell RANKS
                                   (removed in Cataclysm) => genuinely WotLK-era, the
                                   closest external match to a 3.3.5a client. Carries
                                   the "Complete list" inline.
  wowpedia/Making_a_macro          fandom copy frozen ~2021 (Wowpedia moved to
                                   warcraft.wiki.gg). Delegates: {{main|Macro conditionals}}.
  wowpedia/Macro_conditionals      the delegation target. Following it is following the
                                   citation, not scope creep.

WHY BOTH RETAIL WIKIS, NOT JUST ONE - and the METHOD CORRECTION that came out of it:
  patch-dated             a {{Patch}} annotation (often Blizzard-cited) => EVIDENCE. If
                          the patch is > 3.x it POSTDATES the 3.3.5a base => present only
                          if BACKPORTED. @cursor = 7.1.0 (Legion), Blizzard-cited, AND
                          witnessed in CoA's own source = a CONFIRMED, DATED backport.
  archive-documented      in the wowwiki archive (content ~2010, WotLK/early-Cata) =>
                          expected present on a 3.3.5a base.
  retail-documented-only  retail lists it, the archive does not, NO patch annotation =>
                          UNDATED. We do NOT know when it shipped.

  This bucket was called "post-wotlk" and inferred from ABSENCE in the archive - the exact
  "absence proves nothing" error this slice writes into three files, committed by the tool
  built to prevent it, in the field the probe steers by. It was RIGHT for the 4 rows that
  carry patch annotations - by LUCK, not method. Absence is not evidence. Ever.
  (Surfaced by Battlewrath asking when @cursor actually shipped, 2026-07-17.)

PROOF MARK: every candidate carries its validation state. UNPROVEN until the probe
says otherwise. The probe writes verdicts back; nothing here is ever a fact on its own.

Determinism: the FETCH is network (not reproducible), so raws are saved VERBATIM and
stamped (revid + sha256); extraction re-derives offline from the saved copies by default.

Usage:
    py macros\tools\ingest_reference.py            re-derive from saved raws
    py macros\tools\ingest_reference.py --fetch    re-pull (revid change = LOUD)
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
EXTRACT = ROOT / "Outputs" / "client_interface" / "patch-B" / "Interface"
# wiki.gg returns a "Blocked" HTML page to a short UA; a real browser UA gets 200.
UA = ("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) "
      "Chrome/126.0.0.0 Safari/537.36")

SOURCES = [
    {"name": "ascension-wiki-macros", "host": "project-ascension.fandom.com",
     "page": "Macros", "era": "ascension", "format": "fandom-table",
     "standing": "SECONDARY - the server's own guide; inherits its conditional list "
                 "from the retail wikis below (see its Resources section)"},
    {"name": "wowwiki-archive-making-a-macro", "host": "wowwiki-archive.fandom.com",
     "page": "Making_a_macro", "era": "wotlk-era", "format": "bold-bullets",
     "standing": "SECONDARY (retail) - frozen 2018, documents spell RANKS => WotLK-era; "
                 "closest external match to a 3.3.5a client. Carries a COMPLETENESS "
                 "CLAIM for ITS era, which is not a claim about CoA."},
    {"name": "wowpedia-making-a-macro", "host": "wowpedia.fandom.com",
     "page": "Making_a_macro", "era": "retail-2021", "format": "delegates",
     "standing": "SECONDARY (retail) - cited by the Ascension wiki; delegates its "
                 "conditional list to Macro_conditionals"},
    {"name": "wowpedia-macro-conditionals", "host": "wowpedia.fandom.com",
     "page": "Macro_conditionals", "era": "retail-2021", "format": "deflist",
     "standing": "SECONDARY (retail) - the delegation target of the cited page"},
    # The UNIT TOKEN vocabulary - the OTHER half of the @ question (Battlewrath, 2026-07-17).
    # If @X is pass-through, the parser never decides whether @X works: the UNIT SYSTEM does,
    # downstream. So these pages supply the real @ candidate list, and their proof method is
    # UnitExists/UnitName - NOT SecureCmdOptionParse.
    {"name": "warcraft-wiki-unittoken", "host": "warcraft.wiki.gg",
     "page": "UnitToken", "era": "retail-current", "format": "unit-token-deflist",
     "standing": "SECONDARY (retail, CURRENT) - Wowpedia's live successor (moved off fandom "
                 "2023). The maintained unit-token reference."},
    {"name": "wowpedia-unitid", "host": "wowpedia.fandom.com",
     "page": "UnitId", "era": "retail-2021", "format": "unit-token-deflist",
     "standing": "SECONDARY (retail) - the frozen fandom copy of the same reference; the "
                 "pair brackets the era the way the macro wikis do."},
]

# Which sources are the UNIT TOKEN vocabulary (by format, not by era - a token claimed by
# BOTH the ascension macro wiki and a unit-token page is still a unit token).
UNIT_TOKEN_SOURCES = {s["name"]: True for s in SOURCES
                      if s["format"] == "unit-token-deflist"}

PROOF_MARKS = {
    "UNPROVEN": "claimed by a secondary source; NO witness of any kind on this client. "
                "A question, nothing more.",
    "SOURCE-CORROBORATED": "the client's own Lua witnesses the token (a handler compares "
                           "the parser's returned target to it). Handler-side only, and "
                           "target tokens only - never flags. Still wants the probe.",
    "PROVEN-TRUE": "probe: known and currently true. [PROBE WRITES THIS]",
    "PROVEN-FALSE": "probe: known and currently false. [PROBE WRITES THIS]",
    "UNSUPPORTED": "probe: parser rejects both polarities. [PROBE WRITES THIS]",
    "IGNORED": "probe: both polarities true => no-op. [PROBE WRITES THIS]",
}

# Prose placeholders and markup only. NEVER put a real conditional in here - `help`
# was in this set once and silently vanished from the register, which is exactly the
# quiet deletion this whole slice exists to prevent.
NOISE = {"condition", "conditions", "spell", "x", "n", "options", "and", "or",
         "no", "true", "false"}


def get(url):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read().decode("utf-8", "replace")


def fetch(src):
    api = f"https://{src['host']}/api.php"
    wt = json.loads(get(f"{api}?action=parse&page={src['page']}&prop=wikitext&format=json"))
    rv = json.loads(get(f"{api}?action=query&prop=revisions&titles={src['page']}"
                        f"&rvprop=ids|timestamp|user&format=json"))
    rev = next(iter(rv["query"]["pages"].values()))["revisions"][0]
    return wt["parse"]["wikitext"]["*"], {
        "url": f"https://{src['host']}/wiki/{src['page']}",
        "pageid": wt["parse"]["pageid"], "revid": rev["revid"],
        "revision_timestamp": rev["timestamp"], "revision_user": rev["user"],
    }


# ----------------------------------------------------------- per-format extractors

def clean(tok):
    # Resolve piped wiki links FIRST: [[Stance|stance]] -> stance. Stripping only the
    # brackets leaves "Stance|stance", which the `|` guard then rejects - that silently
    # dropped `stance` from the WotLK-era source and misfiled it as retail-only.
    tok = re.sub(r"\[\[[^\]|]*\|([^\]]+)\]\]", r"\1", tok)
    tok = re.sub(r"\[\[([^\]]+)\]\]", r"\1", tok)
    tok = re.sub(r"<[^>]+>|''+|&lt;|&gt;|\{\{|\}\}", "", tok).strip()
    return tok.strip("`'\"* ")


def _emit(out, tok, says, aliases=None):
    """Validate the BASE, not the whole token.

    An ARG may legitimately contain spaces or be a placeholder
    (`channeling:<spell name>`, `equipped:<item type>`). Rejecting the whole token on a
    space silently dropped every arg-taking conditional the archive documents - which
    misfiled channeling/equipped/worn/button as retail-only and INVERTED the era diff,
    the one derived field the probe actually steers by.
    """
    tok = clean(tok)
    if not tok or "|" in tok or tok.lower().startswith("file:"):
        return
    base, arg = (tok.split(":", 1) + [None])[:2]
    base = base.strip()
    if not base or " " in base or base.lower() in NOISE:
        return
    if not re.fullmatch(r"@?[A-Za-z][A-Za-z0-9]*", base):
        return
    if arg is not None:
        arg = arg.strip()
        # a placeholder ('<spell name>', 'X', 'n') is not a real argument value
        if not arg or " " in arg or arg in ("X", "N", "n") or not re.fullmatch(
                r"[A-Za-z0-9/.]+", arg):
            arg = None
    out.append({"token": base if arg is None else f"{base}:{arg}",
                "base": base, "arg_form": arg,
                "says": (says or "").strip()[:200], "aliases": aliases or []})


# Bases that legitimately begin with "no" - stripping the prefix here would invent a
# conditional that was never claimed. Empty today; the guard is the point.
NO_PREFIX_EXEMPT = set()


def normalize(tok):
    """Fold a written token to its BASE VOCABULARY entry.

    `nocombat` is not a conditional distinct from `combat` - `no` is GRAMMAR (the second
    row of the polarity pair). `mod:alt` is not distinct from `mod:shift` - `:alt` is an
    ARGUMENT. Without this, token-level matching marks Ascension-listed basics as
    'ascension-only' because the archive documents them generically, and the era diff -
    the whole diagnostic payload - becomes noise.

    Returns (key, negated, arg).
    """
    if tok.startswith("@"):
        return tok, False, None                      # targets: pass-through, not vocabulary
    base, arg = (tok.split(":", 1) + [None])[:2]
    negated = False
    if base.lower().startswith("no") and len(base) > 3 and base.lower() not in NO_PREFIX_EXEMPT:
        negated, base = True, base[2:]
    if arg in ("X", "N", "<arg>"):
        arg = None                                   # a placeholder is not an argument
    return (base if not arg else f"{base}"), negated, arg


def x_fandom_table(w):
    out = []
    for m in re.finditer(r"^\|((?:\s*<code>[^<]+</code>\s*[^\n|]*)+)\n\|([^\n|]+)", w, re.M):
        spans = re.findall(r"<code>([^<]+)</code>", m.group(1))
        for t in spans:
            _emit(out, t, m.group(2))
    for m in re.finditer(r"\[([^\]\n]+)\]", w):
        if m.group(1).lower().startswith("file:") or "|" in m.group(1):
            continue
        for part in m.group(1).split(","):
            _emit(out, part, None)
    return out


def x_bold_bullets(w):
    """wowwiki-archive 'Complete list': * '''name''' or '''alias''' - description

    Entries nest ITALICS inside the BOLD for placeholder args:
        * '''channeling:''<spell name>''''' - Channeling the given spell
    A `'''(.+?)'''` pattern cannot survive that (the closing run is `'''''`), so those
    lines silently failed to match and every arg-taking conditional vanished. Split on
    the em-dash FIRST, then clean the markup off the left side - which is robust to any
    quote nesting.
    """
    out = []
    i = w.find("=== Complete list ===")
    if i < 0:
        return out
    sec = w[i:]
    nxt = sec.find("\n==", 10)
    sec = sec[:nxt] if nxt > 0 else sec
    for line in sec.split("\n"):
        if not line.strip().startswith("*"):
            continue
        m = re.match(r"\*\s*(.+?)\s*[—–]\s*(.*)$", line)
        if not m:
            continue
        left, desc = m.group(1), m.group(2).strip()
        # Split alternatives on the RAW markup boundary (''' or '''), NOT on " or " in
        # cleaned prose. Cleaning first then splitting on " or " reaches INSIDE an
        # argument: `pet:''<pet name or type>''` -> ["pet:pet name", "type"], which
        # FABRICATED a [type] conditional that exists in no source. The tool inventing
        # a fact is precisely what this slice exists to prevent.
        parts = [p for p in re.split(r"'''\s*or\s*'''", left) if p.strip()]
        names = [clean(p).split(":")[0] for p in parts]
        for p, n in zip(parts, names):
            _emit(out, p, desc, [o for o in names if o and o != n])
    return out


def x_deflist(w):
    """wowpedia/Macro_conditionals - TWO formats on one page:

      ; @unitId : description                       (the 'Temporary targeting' section)
      | '''exists''' || {{api|...}} || description  (the Boolean condition WIKITABLES)

    The deflist alone yields 3 tokens and misses the ENTIRE boolean vocabulary - which
    is the post-WotLK backport test set, i.e. the whole reason this source is ingested.
    """
    out = []
    # 1. definition-list rows (temporary targeting: @unitId, @cursor, @none)
    for m in re.finditer(r"^;\s*([^:\n]+?)\s*:\s*(.+)$", w, re.M):
        for t in re.split(r"\s+or\s+|\s*/\s*", m.group(1)):
            _emit(out, t, m.group(2))
    # 2. wikitable rows: | '''a''', '''b''' || api || description
    for m in re.finditer(r"^\|\s*('''.+?)\s*\|\|\s*(.*?)\s*\|\|\s*(.+?)\s*$", w, re.M):
        toks = re.findall(r"'''([^']+)'''", m.group(1))
        desc, api = m.group(3), m.group(2)
        for t in toks:
            for part in re.split(r"\s*,\s*", t):
                _emit(out, part, f"{desc} (similar API: {clean(api)})" if api else desc)
    return out


def x_delegates(w):
    return []


def x_unit_token_deflist(w):
    """UnitToken / UnitId: `; <code>"player"</code> : description`

    Emits @-PREFIXED, because these are the `@X` target vocabulary. `N` placeholders
    (party''N'') are normalised to the bare base - `@party` with the index left as the
    known range, since @party1 and @party4 are not different vocabulary entries.

    NOTE what is NOT here: `cursor`. Neither page lists it, because it was never a unit -
    it is a macro-layer special case (Legion 7.1.0) that Ascension hand-rolls via
    Custom_HandleTerrainClick. Third independent confirmation of the two-mechanism split.
    """
    out = []
    # ONLY the vocabulary sections. "Target of unit" is the suffix GRAMMAR and "Examples"
    # is worked examples - harvesting those took a wiki editor's USERNAME (@Cogwheel) and
    # chained illustrations (@party1targettarget, @targettargetpettarget) as vocabulary.
    VOCAB = ("Base Values", "Soft Targeting", "Others")
    SKIP = ("Target of unit", "Examples", "Details", "Patch changes", "Used by",
            "References")
    section, keep = None, False
    for line in w.split("\n"):
        h = re.match(r"^==\s*([^=]+?)\s*==\s*$", line)
        if h:
            section = h.group(1).strip()
            keep = section in VOCAB
            continue
        if not keep:
            continue
        # `"+` not `"` before </code>: BOTH wikis carry a typo - `"nameplate''N''""` has a
        # stray extra quote (wiki.gg inherited it from fandom). A strict regex silently
        # dropped the token - and of all tokens, nameplateN is the sharpest question here
        # (Legion 7.0.3, and this client backports the Legion nameplate system). Source
        # markup is DIRTY; a strict pattern doesn't fail loudly, it just loses rows.
        m = re.match(r'^;\s*<code>"([^"]+)"+\s*</code>\s*:?\s*(.*)$', line)
        if not m:
            continue
        tok, desc = clean(m.group(1)), re.sub(r"\s+", " ", m.group(2)).strip()
        tok = re.sub(r"(N|<T><N>)$", "", tok).strip()
        if not tok or tok == "unitId":            # a placeholder, not a token
            continue
        _emit(out, "@" + tok, f"[{section}] {desc}")
    return out


EXTRACTORS = {"fandom-table": x_fandom_table, "bold-bullets": x_bold_bullets,
              "deflist": x_deflist, "delegates": x_delegates,
              "unit-token-deflist": x_unit_token_deflist}


def extract_patch_history(w, name):
    """SOURCED era data - the wikis' own ==Patch changes== annotations.

    This exists because of a real error. era_signal originally inferred "post-wotlk"
    from ABSENCE in the 2018 archive - the exact "absence proves nothing" mistake this
    slice writes into three files, committed by me, in the field the probe steers by.
    It happened to be RIGHT for the four conditionals that carry patch annotations, but
    right by LUCK, not by method.

    A patch annotation is EVIDENCE. Absence is not. Where a patch is sourced we date the
    conditional; where it is not, we say only "retail-documented-only" - which is all we
    actually know.

    Blizzard-cited examples: @cursor added 7.1.0 (Legion, Return to Karazhan);
    known 10.0.2; advflyable 10.0.7; pvpcombat 7.3.0; talent added 6.0.2 REMOVED 10.0.0.
    """
    out = []
    for m in re.finditer(r"\{\{Patch\s+([0-9][0-9.]*)\|note=(.*?)(?:<ref|\}\})", w, re.S):
        patch, note = m.group(1), re.sub(r"\s+", " ", m.group(2)).strip()
        # Two markup dialects for the SAME thing: the macro page writes "combat",
        # the unit-token page writes ''nameplateN''. Matching only the quoted form
        # silently yielded ZERO unit-token patch data - including nameplateN (7.0.3,
        # the backport test) and bossN (3.3.0, inside 3.3.5a's own era).
        toks = re.findall(r'"([a-z]+)"|\'\'([A-Za-z]+)\'\'|(@[a-z]+)', note)
        for a, b, c in toks:
            tok = a or b or c
            if not tok:
                continue
            tok = re.sub(r"N$", "", tok)          # nameplateN -> nameplate
            out.append({"token": tok, "patch": patch, "note": note[:120],
                        "action": "removed" if "removed" in note.lower() else "added",
                        "from": name, "cited": "<ref" in m.group(0)})
    return out


def wow_era(patch):
    """Map a patch number to its expansion. 3.3.5a is the CoA client's base."""
    major = int(patch.split(".")[0])
    return {1: "vanilla", 2: "TBC", 3: "WotLK", 4: "Cataclysm", 5: "MoP", 6: "WoD",
            7: "Legion", 8: "BfA", 9: "Shadowlands", 10: "Dragonflight"}.get(major, f"?{major}")


def extract_grammar(w, name):
    claims = []
    for pat, claim in [
        (r"first valid one is used|first '''true''' condition|first one that",
         "clauses evaluate in order; the FIRST true one wins"),
        (r"Think of the comma as an [\"']and", "`,` = AND within one clause"),
        (r"<code>;</code> to separate|;.*separate condition", "`;` separates alternative clauses"),
        (r"<code>no</code> prefix reverses|no.*prefix.*reverse|nocombat.*is a valid",
         "`no` prefix negates a flag"),
        (r"reset=(\d+)|reset conditions", "/castsequence takes a `reset=` parameter"),
        (r"#showtooltip", "#show/#showtooltip accept conditionals too"),
        (r"target=.*alias for|<code>target=</code> is also an alias",
         "`target=` is an alias for `@`"),
        (r"always taken into account first|taken into account first",
         "`@unit`/`target=` is resolved FIRST, before the other conditionals"),
        (r"also sets the unit that the conditionals are checked against",
         "`@unit` also sets the unit the OTHER conditionals are checked against"),
        (r"shift/ctrl.*means .shift or control|/.*means .*or",
         "`/` = OR inside an argument (e.g. mod:shift/ctrl)"),
        (r"Replace with any valid \[\[unitId\]\]|any valid unitId",
         "`@unitId` takes ANY valid unitId => supports the PASS-THROUGH hypothesis"),
        (r"Append the suffix <code>target</code> to any UnitToken",
         "SUFFIX GRAMMAR: append `target` to ANY unit token, repeatable "
         "(pettarget, playertargettarget). This DERIVES tokens rather than listing them - "
         "which is exactly why no wiki lists @pettarget as a base token, and why its "
         "absence from every list proves nothing."),
        (r"UnitIds are case insensitive|[Uu]nit tokens are case insensitive",
         "unit tokens are CASE INSENSITIVE (consistent with CoA's handler doing "
         "target:lower() == 'cursor')"),
        (r"hyphens to separate the target chain",
         "a party/raid member's NAME works as a unit, with hyphens for the chain "
         "(Cogwheel-target-target)"),
    ]:
        if re.search(pat, w):
            claims.append({"claim": claim, "from": name})
    return claims


# -------------------------------------------------------- the client-source join

def source_recognized_targets():
    """Target tokens the client's OWN Lua special-cases:

        local castAtCursor = target and target:lower() == "cursor"

    `target` is what SecureCmdOptionParse HANDED BACK, so a handler comparing it to a
    literal proves the HANDLER anticipates that token. It does NOT prove the parser
    validates it. Reaches TARGET TOKENS ONLY - never flags.
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


TWO_MECHANISMS = {
    "why_this_matters": "`@unit` and `[flag]` are NOT the same mechanism and do NOT share "
                        "a proof method. Conflating them is the easiest way to write a "
                        "confident wrong guide.",
    "@unit / target=": {
        "mechanism": "HYPOTHESIS: a pass-through STRING. SecureCmdOptionParse appears to "
                     "return whatever follows @; support lives DOWNSTREAM in the handler's "
                     "own special-casing (/cast checks target=='cursor' -> "
                     "Custom_HandleTerrainClick) and in unit resolution.",
        "independent_support": "wowpedia/Macro_conditionals states '@unitId : Replace with "
                               "any valid unitId' and '`target=` is also an alias for `@`' - "
                               "a RETAIL doc describing the same pass-through shape the CoA "
                               "handler code implies. Two directions, one hypothesis. Still "
                               "a hypothesis.",
        "consequence": "the polarity matrix does NOT apply; there is likely no [no@cursor].",
        "probe_row_that_settles_it": 'SecureCmdOptionParse("[@banana] X") - if a nonsense '
                                     'unit returns target="banana", @ is pass-through and '
                                     "the vocabulary question does not apply to it at all.",
        "status": "HYPOTHESIS - not asserted. One probe row settles it.",
    },
    "[flag]": {
        "mechanism": "actually EVALUATED by the C parser (combat, mod:shift, group, ...).",
        "consequence": "THIS is the vocabulary question, and what the polarity matrix is for.",
    },
    "the_cursor_collision": {
        "why_this_matters": "THREE different mechanisms collide on the word 'cursor'. They "
                            "are not variants of each other and none became another. "
                            "Conflating any two writes a confidently wrong guide.",
        "@cursor": {
            "is": "a ground LOCATION - the terrain point under the pointer. NOT a unit: it "
                  "appears in NO unit-token list on either wiki.",
            "dated": "SOURCED 7.1.0 (Legion), Blizzard-cited",
            "on_CoA": "hand-rolled by Ascension - /cast checks target=='cursor' and hands "
                      "off to Custom_HandleTerrainClick. A CONFIRMED, DATED backport.",
        },
        "@mouseover": {
            "is": "a UNIT - 'the unit which the mouse is currently (or was most recently) "
                  "hovering over'. A real unit token; resolves via UnitExists.",
            "dated": "UNDATED in every source we hold. The macro SYSTEM itself dates to "
                     "2.0.1 (sourced), so mouseover-as-a-macro-target is >= 2.0.1 - but "
                     "that is a floor, not a date. We do not know when it shipped.",
        },
        "[cursor]": {
            "is": "a FLAG - 'what the cursor is currently HOLDING' (drag-and-drop state; "
                  "GetCursorInfo). Neither a location nor a unit.",
            "dated": "documented in the ~2010 archive (WotLK/early-Cata)",
        },
        "the_history_read": (
            "Battlewrath, 2026-07-17: 'the cursor is first a location selector, and then "
            "later became mouseover casting.' RIGHT about the mechanic, inverted about the "
            "token. The ground RETICLE is the older thing - the Ascension wiki frames "
            "@cursor as 'remove the reticle delay', so the reticle pre-existed and @cursor "
            "AUTOMATES it. But as macro TOKENS the order reverses: @mouseover is undated "
            "and old (>= the 2.0.1 macro system), @cursor is 7.1.0 - about nine years "
            "later. Sequence: reticle (location, pre-macro) -> 2.0 macro system brings "
            "mouseover casting -> @cursor (7.1.0) arrives late to automate the ORIGINAL "
            "location role. They are parallel, not a lineage."),
        "status": "the DATES are sourced; the SEQUENCE above is a reading of them, not a "
                  "fact claim. Nothing here changes what the probe asks.",
    },
}


# ---------------------------------------------------------------------- emission

def main():
    REF.mkdir(parents=True, exist_ok=True)
    do_fetch = "--fetch" in sys.argv
    per_source, grammar, all_c, raw_per_source, patches = {}, [], {}, {}, []

    for src in SOURCES:
        raw_path = REF / f"{src['name']}.wikitext"
        if do_fetch or not raw_path.is_file():
            print(f"fetching {src['host']}/{src['page']} ...")
            w, rev = fetch(src)
            old = per_source_prev_revid(src)
            if old and old != rev["revid"]:
                print(f"  !! REVID CHANGED {old} -> {rev['revid']} - page moved under us; "
                      f"read the diff before trusting derived candidates")
            raw_path.write_text(w, encoding="utf-8")
            (REF / f"{src['name']}.provenance.json").write_text(
                json.dumps(rev, indent=1), encoding="utf-8")
        else:
            w = raw_path.read_text(encoding="utf-8")
            rev = json.loads((REF / f"{src['name']}.provenance.json").read_text(encoding="utf-8"))

        cands = EXTRACTORS[src["format"]](w)
        grammar += extract_grammar(w, src["name"])
        patches += extract_patch_history(w, src["name"])
        per_source[src["name"]] = {
            "standing": src["standing"], "era": src["era"], "format": src["format"],
            "provenance": {**rev, "raw_file": raw_path.name,
                           "raw_sha256": hashlib.sha256(w.encode()).hexdigest(),
                           "raw_chars": len(w)},
            "candidate_count": len(cands),
        }
        raw_per_source.setdefault(src["name"], []).extend(c["token"] for c in cands)
        for c in cands:
            key, negated, arg = normalize(c["token"])
            e = all_c.setdefault(key, {
                "token": key,
                "kind": "unit-target" if key.startswith("@") else "flag",
                "base": key.split(":")[0], "arg_forms": [],
                "aliases": [], "claimed_by": [], "era_signal": None,
                "negation_documented": False,
                "source_witness": None, "proof_mark": "UNPROVEN",
                "probe_method": None, "probe_rows": [],
            })
            if negated:
                # `no` is GRAMMAR, not a separate conditional - it is the second row of
                # this candidate's own polarity pair. A wiki spelling out [nocombat] is
                # evidence the negation grammar is real, not a new vocabulary entry.
                e["negation_documented"] = True
            if arg:
                # `/` = OR inside an argument (mod:shift/ctrl documents TWO values, not
                # one literal "shift/ctrl"), so split before recording. Otherwise the
                # arg list dups into shift/ctrl/alt/shift/ctrl/.
                for a in (p for p in arg.split("/") if p and p != "..."):
                    if a not in e["arg_forms"]:
                        e["arg_forms"].append(a)
            for a in c["aliases"]:
                if a and a not in e["aliases"]:
                    e["aliases"].append(a)
            if not any(x["source"] == src["name"] for x in e["claimed_by"]):
                e["claimed_by"].append({"source": src["name"], "era": src["era"],
                                        "says": c["says"], "revid": rev.get("revid"),
                                        "as_written": c["token"]})
        print(f"  {src['name']:32} {len(cands):3} candidates  (revid {rev.get('revid')}, "
              f"{rev.get('revision_timestamp','?')[:10]})")

    # ---- derived: era signal (the diagnostic split) + proof mark + probe method
    witnesses = source_recognized_targets()
    by_tok = {}
    for p in patches:
        by_tok.setdefault(p["token"], []).append(p)

    for tok, e in all_c.items():
        eras = {c["era"] for c in e["claimed_by"]}
        # The client-source witness is INDEPENDENT of era and must be assigned for EVERY
        # candidate, before any era branch can `continue` past it. It was assigned after
        # the branching once, and the patch-dated `continue` silently stripped @cursor of
        # its witness - deleting the register's single most important datum (the one
        # CONFIRMED backport) while the run still printed success.
        if tok in witnesses:
            e["source_witness"] = witnesses[tok]
            e["proof_mark"] = "SOURCE-CORROBORATED"
        # SOURCED patch data first - it is EVIDENCE. Absence never is.
        # Patch notes name tokens BARE ("Added ''nameplateN''"); the register keys unit
        # tokens @-PREFIXED. Without stripping the @, every unit-token patch date silently
        # failed to join - losing boss (3.3.0, inside 3.3.5a's era), focus (2.0.0),
        # nameplate (7.0.3) and the six 10.0.0 soft/any tokens.
        pd = (by_tok.get(tok) or by_tok.get(e["base"])
              or (by_tok.get(tok.lstrip("@")) if tok.startswith("@") else None))
        if pd:
            e["patch_history"] = [{"patch": x["patch"], "expansion": wow_era(x["patch"]),
                                   "action": x["action"], "cited": x["cited"],
                                   "note": x["note"], "from": x["from"]} for x in pd]
            added = [x for x in pd if x["action"] == "added"]
            if added:
                pv = added[0]["patch"]
                e["era_signal"] = "patch-dated"
                e["era_note"] = (
                    f"SOURCED: added in patch {pv} ({wow_era(pv)}). The CoA client is "
                    f"3.3.5a (WotLK), so this POSTDATES its base => present here only if "
                    f"BACKPORTED. This client backports freely, and @cursor (7.1.0) is a "
                    f"CONFIRMED backport witnessed in its own source - so presence is a "
                    f"real question, not a formality."
                    if int(pv.split(".")[0]) > 3 else
                    f"SOURCED: added in patch {pv} ({wow_era(pv)}) => predates/matches the "
                    f"3.3.5a base; expected present.")
                continue
        if "wotlk-era" in eras:
            e["era_signal"] = "archive-documented"
            e["era_note"] = ("documented in the wowwiki archive (content frozen ~2010, "
                             "WotLK/early-Cata) => expected present on a 3.3.5a base. An "
                             "UNSUPPORTED here would be a real finding.")
        elif tok.startswith("@") and any(
                UNIT_TOKEN_SOURCES.get(c["source"]) for c in e["claimed_by"]):
            e["era_signal"] = "unit-token-vocabulary"
            e["era_note"] = ("a UNIT TOKEN, not a conditional. The parser does not decide "
                             "whether @X works - the UNIT SYSTEM does, downstream. Proof "
                             "method is UnitExists/UnitName, NOT the polarity matrix. "
                             "Context-bound (@party1 needs a party), so read it against the "
                             "context stamp.")
        elif "retail-2021" in eras:
            # NOT "post-wotlk" - that asserts a history we have NO evidence for. All we
            # know is that a retail wiki lists it and an older one does not. Absence is
            # not evidence; saying otherwise is the mistake this whole slice guards against.
            e["era_signal"] = "retail-documented-only"
            e["era_note"] = ("listed by the retail wiki, ABSENT from the ~2010 archive, and "
                             "NO patch annotation found. We do NOT know when it shipped - "
                             "absence is not evidence. Treat as UNDATED: it may predate "
                             "3.3.5a and simply be undocumented there, or postdate it. "
                             "The probe answers; the wiki cannot.")
        else:
            e["era_signal"] = "ascension-claimed"
            e["era_note"] = "claimed only by the Ascension wiki"
        # probe method follows the MECHANISM, not the token
        if e["kind"] == "unit-target":
            e["probe_method"] = "pass-through test (NOT polarity - see two_mechanisms)"
            e["probe_rows"] = [f"[{tok}]"]
        else:
            e["probe_method"] = "polarity-pair"
            # one pair per ARGUMENT form, because [mod] and [mod:alt] are different
            # questions - a bare base can be supported while an arg form is not.
            forms = [tok] + [f"{tok}:{a}" for a in e["arg_forms"]]
            e["probe_rows"] = [r for f in forms for r in (f"[{f}]", f"[no{f}]")]

    # tokens our source witnesses that NO wiki claims - absence proves nothing, shown
    unclaimed = sorted(t for t in witnesses if t not in all_c)
    for t in unclaimed:
        # SAME SCHEMA as the main path - `arg_forms`, not `arg_form`. A second shape for
        # the same record type is how a consumer silently KeyErrors on one branch.
        all_c[t] = {"token": t, "kind": "unit-target", "base": t, "arg_forms": [],
                    "aliases": [], "claimed_by": [], "era_signal": "NOT-IN-ANY-WIKI",
                    "era_note": "found ONLY in this client's own Lua - no wiki mentions it. "
                                "Proof that a wiki's ABSENCE proves nothing.",
                    "negation_documented": False,
                    "source_witness": witnesses[t], "proof_mark": "SOURCE-CORROBORATED",
                    "probe_method": "pass-through test", "probe_rows": [f"[{t}]"]}

    payload = {
        "what": "THE QUESTION REGISTER - every candidate conditional + its PROOF MARK. "
                "This is the probe's ask-list, not a fact table.",
        "NOT_A_FACT_SOURCE": "Nothing here is a fact about the CoA client. Every entry is a "
                             "QUESTION until a probe verdict replaces its proof_mark. Do not "
                             "cite reference/ as basis/.",
        "why_allowed": "Recall and secondary sources are inadmissible as a FACT source but "
                       "admissible as a QUESTION source, because the probe adjudicates. A "
                       "wrong candidate costs one probe row reading 'unsupported'. A wrong "
                       "fact poisons the basis silently.",
        "absence_proves_nothing": "A conditional no wiki lists is UN-ASKED, not unsupported. "
                                  f"Demonstrated mechanically: {unclaimed or 'none'} "
                                  "witnessed in this client's own Lua and in NO wiki.",
        "proof_marks": PROOF_MARKS,
        "two_mechanisms": TWO_MECHANISMS,
        "era_signal_legend": {
            "patch-dated": "SOURCED - the wiki carries a {{Patch}} annotation (often with a "
                           "Blizzard citation). EVIDENCE. If the patch is > 3.x it postdates "
                           "the 3.3.5a base => present only if BACKPORTED.",
            "archive-documented": "in the wowwiki archive (content ~2010, WotLK/early-Cata) "
                                  "=> expected present on a 3.3.5a base",
            "retail-documented-only": "retail wiki lists it, the ~2010 archive does not, and "
                                      "NO patch annotation exists => UNDATED. We do NOT know "
                                      "when it shipped. Absence is not evidence.",
            "ascension-claimed": "only the Ascension wiki says so",
            "NOT-IN-ANY-WIKI": "only this client's own source says so",
        },
        "era_method_correction": (
            "era_signal originally called this bucket 'post-wotlk', inferring the history "
            "from ABSENCE in the ~2010 archive - the exact 'absence proves nothing' error "
            "this slice writes into three files, committed by the tool built to prevent it, "
            "in the field the probe steers by. It was RIGHT for the 4 conditionals carrying "
            "patch annotations - by LUCK, not method. Now: a patch annotation is evidence "
            "and dates the row; absence yields only 'retail-documented-only' = UNDATED."),
        "patch_history": sorted(patches, key=lambda x: x["patch"]),
        "sources": per_source,
        "counts": {
            "total": len(all_c),
            "by_era": {k: sum(1 for e in all_c.values() if e["era_signal"] == k)
                       for k in ("patch-dated", "archive-documented",
                                 "retail-documented-only", "unit-token-vocabulary",
                                 "ascension-claimed", "NOT-IN-ANY-WIKI")},
            "by_kind": {k: sum(1 for e in all_c.values() if e["kind"] == k)
                        for k in ("flag", "unit-target")},
            "by_proof_mark": {k: sum(1 for e in all_c.values() if e["proof_mark"] == k)
                              for k in ("UNPROVEN", "SOURCE-CORROBORATED")},
        },
        "grammar_claims": grammar,
        "candidates": dict(sorted(all_c.items())),
    }
    with open(REF / "candidates.json", "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=1, ensure_ascii=False)
        f.write("\n")
    print(f"\n-> reference/candidates.json  {len(all_c)} candidates")
    for k, v in payload["counts"]["by_era"].items():
        print(f"   {k:22} {v}")
    print(f"   flags={payload['counts']['by_kind']['flag']} "
          f"targets={payload['counts']['by_kind']['unit-target']}")
    print(f"   grammar claims: {len(grammar)}")


def per_source_prev_revid(src):
    p = REF / f"{src['name']}.provenance.json"
    if p.is_file():
        return json.loads(p.read_text(encoding="utf-8")).get("revid")
    return None


if __name__ == "__main__":
    main()
