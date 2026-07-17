r"""
emit_macro_basis.py - emit the MACRO surface basis from the client's own source.

The sheets model (Weak Auras/engine/Fact_basis/sheets) applied to the macro surface:
pay the source-trace ONCE, emit generously per DOMAIN, let every member self-report
its own evidence. Reasoning then READS instead of re-deriving.

START AT THE TOP DOMAINS, LET EVERYTHING SELF-REPORT (Battlewrath, 2026-07-17).
Five domains, discovered from source, never declared by an agent:

  commands      the typed verbs            <- ChatFrame.lua x GlobalStrings.lua
  actions       the `type` vocabulary      <- SecureTemplates.lua SECURE_ACTIONS
  conditionals  the option vocabulary      <- C-SIDE. no source witness. probe only.
  api           the macro C API + limits   <- runtime census x Blizzard_MacroUI.lua
  statedrivers  the 2nd conditional consumer <- runtime census (provenance OPEN)

GRAIN IS PER DOMAIN and stated in each file. They are NOT the same grain:
`commands`/`actions` are SOURCED-COMPLETE; `conditionals` is PROOF-PENDING with a
fully open rim; `statedrivers` is runtime-attested with unresolved provenance.

NOTHING here is written from an agent's WoW knowledge. This client is not a pure
3.3.5a (Legion/BfA CompactUnitFrame; Dragonflight /kb; Ascension's own [@cursor]
hack), so recall is inadmissible in BOTH directions. See operations/Macros.md.

Reads (never writes) the client at F:\games\Ascension_wow - source is a NO-EDIT
space. Archives are read via mpyq in memory; the patch-B study copy comes from
`py addons\tools\extract_interface.py`.

Usage:
    py macros\tools\emit_macro_basis.py
"""
import hashlib
import json
import re
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path

import mpyq

ROOT = Path(__file__).resolve().parents[2]
DATA = Path(r"F:\games\Ascension_wow\resources\ascension-live\Data")
EXTRACT = ROOT / "Outputs" / "client_interface" / "patch-B" / "Interface"
CENSUS = ROOT / "addons" / "maps" / "census" / "runtime" / "globals.json"
OUT = ROOT / "macros" / "basis"

# enUS locale archives, HIGHEST PRECEDENCE FIRST.
# RULE 1: precedence MERGE, not top-archive. patch-enUS-3 is NOT a superset
# (/lfg, /lfm live only below it). Today the archives are purely ADDITIVE, so
# precedence affects COMPLETENESS only - but a value conflict must get LOUD.
LOCALE_ORDER = [
    "patch-enUS-3.MPQ", "patch-enUS-2.MPQ", "patch-enUS.MPQ",
    "lichking-locale-enUS.MPQ", "expansion-locale-enUS.MPQ",
    "locale-enUS.MPQ", "base-enUS.MPQ",
]
GLOBALSTRINGS = "Interface\\FrameXML\\GlobalStrings.lua"


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def die(msg):
    print(f"STOP: {msg}")
    sys.exit(2)


# ---------------------------------------------------------------- source reads

def read_locale_tokens():
    """RULE 1: precedence merge across the locale archives, conflicts flagged."""
    merged, provenance, conflicts, anchors = {}, {}, [], []
    for name in LOCALE_ORDER:
        p = DATA / "enUS" / name
        if not p.is_file():
            continue
        try:
            arc = mpyq.MPQArchive(str(p))
            raw = arc.read_file(GLOBALSTRINGS)
        except Exception as e:
            print(f"  ! {name}: unlistable/unreadable ({type(e).__name__}) - skipped")
            continue
        if raw is None:
            continue
        anchors.append({"archive": name, "sha256": sha256(p)})
        toks = dict(re.findall(r'^(SLASH_[A-Z_0-9]+)\s*=\s*"([^"]*)"',
                               raw.decode("utf-8", "replace"), re.M))
        for k, v in toks.items():
            if k not in merged:              # higher precedence already won
                merged[k], provenance[k] = v, name
            elif merged[k] != v:
                conflicts.append({"token": k, "winner": merged[k],
                                  "winner_archive": provenance[k],
                                  "loser": v, "loser_archive": name})
    return merged, provenance, conflicts, anchors


def lua(rel):
    p = EXTRACT / rel
    if not p.is_file():
        die(f"missing {p}\n      run: py addons\\tools\\extract_interface.py")
    return p.read_text("utf-8", "replace")


def census_buckets():
    """Runtime function buckets - the witness for 'is this function stock?'"""
    if not CENSUS.is_file():
        print("  ! runtime census absent - custom-behaviour classification degraded")
        return {}
    f = json.load(open(CENSUS))["functions"]
    return {n: b for b, names in f.items() for n in names}


# ------------------------------------------------------- domain: commands

CALL = re.compile(r"\b([A-Za-z_][A-Za-z_0-9]*)\s*\(")
LUA_KW = {"if", "then", "else", "elseif", "end", "for", "while", "do", "return",
          "local", "function", "and", "or", "not", "in", "repeat", "until", "tonumber",
          "tostring", "type", "pairs", "ipairs", "print", "select", "unpack"}


def extract_named_function(lines, name):
    """Body of `function NAME(` / `local function NAME(`, closed at matching indent.

    Needed because a handler can be assigned a NAMED REFERENCE rather than an
    inline function (`SlashCmdList["COATALENTFOOTER"] = HandleFooterLayoutCommand`).
    """
    pat = re.compile(r"^(\s*)(?:local\s+)?function\s+" + re.escape(name) + r"\s*\(")
    for i, line in enumerate(lines):
        m = pat.match(line)
        if not m:
            continue
        indent = m.group(1)
        body = []
        for l in lines[i + 1:]:
            if re.match(rf"^{indent}end[;)]?\s*$", l):
                return body
            body.append(l)
        return body
    return None


def parse_command_handlers(src, path):
    """Walk a source file tracking the CURRENT handler.

    Three real definition FORMS, each found the hard way (a command went missing,
    and the missing one is what taught the form):
      inline    LIST["K"] = function ...           - the common case
      alias     LIST["K"] = LIST["J"]              - RULE 4; /use = /cast
      named ref LIST["K"] = SomeNamedHandler       - COATALENTFOOTER, STATLOGICDEBUG
    ...and definitions are NOT always at column 0 (BDRAFT is nested in a block), so
    the body terminator must match the DEFINITION'S OWN INDENT, not column 0.

    Owner MUST be cleared at that terminator, or SlashCmdList calls get misattributed
    to the last SecureCmdList key - the bug that produced a wrong count TWICE by hand
    (see operations/Macros.md method note).
    """
    lines = src.split("\n")
    defs, aliases, bodies, refs = {}, {}, defaultdict(list), {}
    owner, indent = None, ""
    for i, line in enumerate(lines, 1):
        m = re.match(r'(\s*)(SecureCmdList|SlashCmdList)\["([A-Z_0-9]+)"\]\s*=\s*(.*)', line)
        if m:
            ind, lst, key, rhs = m.groups()
            am = re.match(r'(SecureCmdList|SlashCmdList)\["([A-Z_0-9]+)"\]', rhs)
            if am:                                          # alias by assignment
                aliases[(lst, key)] = (am.group(1), am.group(2))
                owner = None
            elif rhs.startswith("function"):               # inline
                owner, indent = (lst, key), ind
                defs[owner] = f"{path}:{i}"
            elif (rm := re.match(r"([A-Za-z_][A-Za-z_0-9]*)\s*;?\s*$", rhs)):
                named = rm.group(1)                        # named reference
                defs[(lst, key)] = f"{path}:{i}"
                refs[(lst, key)] = named
                body = extract_named_function(lines, named)
                if body is not None:
                    bodies[(lst, key)] = body
                owner = None
            else:
                owner = None
            continue
        if owner and re.match(rf"^{indent}end;?\s*$", line):   # indent-matched terminator
            owner = None
            continue
        if owner:
            bodies[owner].append(line)
    return defs, aliases, bodies, refs


def emit_commands(tokens, provenance, buckets):
    """Scan the WHOLE extraction, not just ChatFrame.lua.

    SecureCmdList is ChatFrame.lua-only (verified, not assumed), but SlashCmdList
    handlers are spread across 100+ definitions in Ascension_* addons, DebugTools
    and FrameXML. Scoping to one file discovers 27 custom commands and then drops
    26 of them - "source trace and miss the wider picture" (Battlewrath, 2026-07-17).

    ENTRY RULE - a command enters on any of three principled grounds:
      (a) SecureCmdList          - a macro-protected verb
      (b) takes conditionals     - computed, incl. non-secure ones
      (c) CoA-custom             - declared INLINE in UI code, not GlobalStrings
    Stock chat/UI commands (/say, /dance - ~500 GlobalStrings tokens) stay OUT.
    """
    defs, aliases, bodies, refs = {}, {}, {}, {}
    for p in sorted(EXTRACT.rglob("*.lua")):
        if not p.is_file():
            continue
        txt = p.read_text("utf-8", "replace")
        if "CmdList[" not in txt and "SLASH_" not in txt:
            continue
        rel = p.relative_to(EXTRACT.parent).as_posix()
        d, a, b, rf = parse_command_handlers(txt, rel)
        defs.update(d)
        aliases.update(a)
        bodies.update(b)
        refs.update(rf)

        # RULE 2: TWO token sources. GlobalStrings alone loses every custom command.
        for k, v in re.findall(r'^\s*(SLASH_[A-Z_0-9]+)\s*=\s*"([^"]*)"', txt, re.M):
            tokens.setdefault(k, v)
            provenance.setdefault(k, f"INLINE:{p.name}")

    def typed(key):
        out, i = [], 1
        while f"SLASH_{key}{i}" in tokens:
            t = tokens[f"SLASH_{key}{i}"]
            if t not in out:
                out.append(t)
            i += 1
        return out

    def calls(owner):
        body = "\n".join(bodies.get(owner, []))
        return sorted({c for c in CALL.findall(body) if c not in LUA_KW})

    # RULE 3: conditional support is COMPUTED, never hand-listed.
    direct = {o for o in bodies if "SecureCmdOptionParse" in "\n".join(bodies[o])}

    cmds = {}
    for (lst, key), where in sorted(defs.items(), key=lambda x: x[0][1]):
        called = calls((lst, key))
        # RULE 5: custom BEHAVIOUR falls out mechanically off the census buckets.
        custom = sorted(c for c in called
                        if c.startswith("Custom_") or buckets.get(c) == "unattributed")
        takes = (lst, key) in direct
        src_kind = provenance.get(f"SLASH_{key}1", "NONE")
        coa_custom = src_kind.startswith("INLINE")
        # ENTRY RULE (a) secure, (b) conditional-taking, (c) CoA-custom
        if lst == "SlashCmdList" and not takes and not coa_custom:
            continue
        cmds[key] = {
            "key": key, "list": lst, "typed": typed(key),
            "token_source": src_kind,
            "coa_custom_command": coa_custom,
            "entered_as": ("secure" if lst == "SecureCmdList" else
                           "conditional-taking" if takes else "coa-custom"),
            "takes_conditionals": takes,
            "conditional_support": "direct" if takes else "none",
            "alias_of": None,
            "source": where,
            "handler_form": ("named-ref -> " + refs[(lst, key)]) if (lst, key) in refs
                            else "inline",
            "body_resolved": bool(bodies.get((lst, key))),
            "calls": called,
            "custom_behaviour": custom or None,
        }
    # RULE 4: aliases inherit their target's handler - resolve or /use reads
    # as conditional-less, which is flatly false.
    for (lst, key), (tlst, tkey) in sorted(aliases.items()):
        if tkey not in cmds:
            continue
        base = cmds[tkey]
        cmds[key] = dict(base, key=key, list=lst, typed=typed(key),
                         token_source=provenance.get(f"SLASH_{key}1", "NONE"),
                         alias_of=tkey, entered_as=f"alias of {tkey}",
                         conditional_support=f"inherited via alias -> {tkey}"
                         if base["takes_conditionals"] else "none")

    # MAKE THE HOLE LOUD: a token declared inline but with no handler found is
    # either a parser gap or a dead token. Silence here is how 3 commands went
    # missing once already - so it gets REPORTED, never dropped.
    declared = {k[len("SLASH_"):].rstrip("0123456789")
                for k, v in provenance.items() if v.startswith("INLINE")}
    orphans = sorted(d for d in declared if d not in cmds)
    unresolved = sorted(k for k, c in cmds.items() if not c["body_resolved"])
    return cmds, len(direct), orphans, unresolved


# -------------------------------------------------------- domain: actions

def emit_actions(buckets):
    """SECURE_ACTIONS - the `type` attribute vocabulary (/click + action buttons).

    Each handler SELF-REPORTS the attributes it reads via
    SecureButton_GetModifiedAttribute(self, "<attr>", ...) - the sheets' paired
    (lever, handling) rule, extracted rather than annotated.
    """
    src = lua("FrameXML/SecureTemplates.lua")
    lines = src.split("\n")
    starts = [(i, m.group(1)) for i, l in enumerate(lines, 1)
              if (m := re.match(r"SECURE_ACTIONS\.([A-Za-z_0-9]+)\s*=\s*$", l))]
    actions = {}
    for idx, (ln, name) in enumerate(starts):
        end = starts[idx + 1][0] - 1 if idx + 1 < len(starts) else len(lines)
        body = "\n".join(lines[ln:end])
        reads = sorted(set(re.findall(
            r'SecureButton_GetModifiedAttribute\(\s*self\s*,\s*"([A-Za-z_0-9]+)"', body)))
        called = sorted({c for c in CALL.findall(body) if c not in LUA_KW
                         and not c.startswith("SecureButton_")})
        custom = sorted(c for c in called
                        if c.startswith("Custom_") or buckets.get(c) == "unattributed")
        actions[name] = {
            "type": name,
            "attributes_read": reads,
            "calls": called,
            "custom_behaviour": custom or None,
            "source": f"Interface/FrameXML/SecureTemplates.lua:{ln}",
        }
    return actions


# --------------------------------------------------- domain: conditionals

def emit_conditionals():
    """The option vocabulary. C-SIDE - SecureCmdOptionParse is called but never
    defined in Lua; the runtime census buckets it stock-capi.

    ATTESTED SEED: conditionals the client's OWN code uses. Measured 2026-07-17:
    ZERO. No RegisterStateDriver call sites in shipped code, no conditional-bearing
    macrotext. The vocabulary has NO SOURCE WITNESS on this client, so the live
    differential probe is not one of two channels - it is the SOLE channel.

    An empty attested set is a TRUE statement. A vocabulary written from an agent's
    WoW recall would not be. This file stays empty until a probe fills it.
    """
    src = lua("FrameXML/ChatFrame.lua")
    attested = {}
    for p in sorted(EXTRACT.rglob("*")):
        if p.suffix.lower() not in (".lua", ".xml") or not p.is_file():
            continue
        t = p.read_text("utf-8", "replace")
        for m in re.finditer(r'Register(?:State|Attribute)Driver\s*\([^)]*"([^"]*\[[^"]*)"', t):
            for c in re.findall(r"\[([^\]]+)\]", m.group(1)):
                attested.setdefault(c.strip(), []).append(p.relative_to(EXTRACT).as_posix())
        for m in re.finditer(r'"macrotext"\s*,\s*"([^"]*\[[^"]*)"', t):
            for c in re.findall(r"\[([^\]]+)\]", m.group(1)):
                attested.setdefault(c.strip(), []).append(p.relative_to(EXTRACT).as_posix())
    return {
        "grain": "PROOF-PENDING - the rim is FULLY OPEN",
        "why": "SecureCmdOptionParse is C-side: called 49x in ChatFrame.lua, defined "
               "NOWHERE in Lua; runtime census buckets it stock-capi. The vocabulary "
               "lives in the client binary and no source read reaches it.",
        "attested_count": len(attested),
        "attested": {k: sorted(set(v)) for k, v in sorted(attested.items())},
        "attested_note": "MEASURED ZERO (2026-07-17): the client's own shipped code uses "
                         "no macro conditional literal - no RegisterStateDriver call sites, "
                         "no conditional-bearing macrotext. Not thin: zero.",
        "sole_channel": "LIVE DIFFERENTIAL PROBE via SecureCmdOptionParse (resident; "
                        "callable from a plain /run, which slips under the anti-cheat "
                        "restart constraint - resident Blizzard API only).",
        "probe_design": {
            "problem": "[combat] out of combat and [madeupword] are BOTH falsey - "
                       "unsupported and currently-false are indistinguishable, so a naive "
                       "probe silently reports half the vocabulary as missing.",
            "method": "test BOTH polarities of each candidate and read the PAIR",
            "matrix": {
                "X=false, noX=true": "known, currently false",
                "X=true,  noX=false": "known, currently true",
                "X=false, noX=false": "UNSUPPORTED - parser rejects both ways",
                "X=true,  noX=true": "ignored / no-op",
            },
            "unknown": "which row an unsupported conditional lands in is itself unknown; "
                       "the design does not need to know in advance, it needs to DISTINGUISH.",
            "cheaper_path": "/luaconsole + /devconsole are declared in shipped UI code - "
                            "if not dev-gated, the probe is interactive, no macro, no restart. "
                            "DECLARED != working: verify first.",
        },
        "standing_limit": "A probe only ever proves conditionals someone thought to ASK "
                          "about. The output is a PROVEN SET WITH AN HONEST RIM - never an "
                          "enumeration. That line is the difference between a fact basis and "
                          "a nicer-looking guess.",
        "inadmissible": "Agent WoW recall. This client is not a pure 3.3.5a (Legion/BfA "
                        "CompactUnitFrame; Dragonflight /kb; Ascension's own [@cursor] hack), "
                        "so a conditional can be ruled neither out for being post-WotLK nor "
                        "in for being WotLK-stock.",
    }


# ------------------------------------------------- domains: api + statedrivers

API_PAT = re.compile(r"^(Create|Delete|Edit|Get|Set|Pickup|Run|Stop|Cursor)?"
                     r".*(Macro|MacroItem|MacroSpell)", re.I)


def emit_api(buckets):
    macro_fns = sorted(n for n, b in buckets.items()
                       if b == "stock-capi" and re.search(r"Macro", n))
    extra = [n for n in ("SecureCmdOptionParse", "SpellIsTargeting", "CastSpellByName",
                         "CastSpellByID", "CastSpell", "UseAction")
             if buckets.get(n) == "stock-capi"]
    ui = lua("AddOns/Blizzard_MacroUI/Blizzard_MacroUI.lua")
    qk = lua("FrameXML/QuickKeybindActionPicker.lua")
    lim = {}
    for label, txt, path in (("Blizzard_MacroUI", ui, "Interface/AddOns/Blizzard_MacroUI/Blizzard_MacroUI.lua"),
                             ("QuickKeybindActionPicker", qk, "Interface/FrameXML/QuickKeybindActionPicker.lua")):
        for m in re.finditer(r"^(?:local\s+)?(MAX_(?:ACCOUNT|CHARACTER)_MACROS)\s*=\s*(\d+)", txt, re.M):
            scope = "local" if m.group(0).strip().startswith("local") else "global"
            lim.setdefault(m.group(1), []).append(
                {"value": int(m.group(2)), "scope": scope, "declared_in": label, "source": path})
    conflicts = {k: v for k, v in lim.items() if len({d["value"] for d in v}) > 1}
    return {
        "grain": "runtime-attested (stock-capi bucket) x source-read constants",
        "macro_api": macro_fns,
        "macro_api_count": len(macro_fns),
        "related": extra,
        "limits": lim,
        "limit_conflicts": conflicts,
        "limit_conflict_note": (
            "UNRESOLVED FROM SOURCE - the client disagrees with itself. Blizzard_MacroUI "
            "declares GLOBAL MAX_CHARACTER_MACROS=36; QuickKeybindActionPicker declares a "
            "LOCAL MAX_CHARACTER_MACROS=18 (stock WotLK value) that shadows it within that "
            "file. Hypothesis (NOT fact): the MacroUI was raised to 36 and the "
            "Dragonflight-backported keybind picker kept the stock local - which would mean "
            "the picker cannot see character macros 19-36. Live check: GetNumMacros(). "
            "Do not state a limit as fact until probed." if conflicts else None),
    }


def emit_statedrivers(buckets):
    fns = sorted(n for n in ("RegisterStateDriver", "UnregisterStateDriver",
                             "RegisterUnitWatch", "UnregisterUnitWatch",
                             "UnitWatchRegistered", "RegisterAttributeDriver")
                 if n in buckets)
    src = lua("FrameXML/SecureTemplates.lua")
    sightings = [f"Interface/FrameXML/SecureTemplates.lua:{i}"
                 for i, l in enumerate(src.split("\n"), 1)
                 if re.search(r"RegisterUnitWatch|RegisterStateDriver", l)]
    return {
        "grain": "runtime-attested; PROVENANCE OPEN",
        "why_it_matters": "State drivers are the SECOND consumer of the conditional "
                          "vocabulary: the same [conditions] that route a macro also drive "
                          "frame visibility/state. Any conditional fact serves both.",
        "functions": {n: {"bucket": buckets[n]} for n in fns},
        "shipped_call_sites": sightings,
        "open_question": (
            "RegisterStateDriver et al. are LIVE (runtime census) but sit in the "
            "`unattributed` bucket, and there is NO SecureStateDriver.lua in the patch-B "
            "extraction. Stock WoW defines them in FrameXML/SecureStateDriver.lua. So on "
            "this client they are C-side, or supplied elsewhere, or (the census's own "
            "caveat) contributed by a loaded USER ADDON - the runtime census was captured "
            "with user addons loaded, so `unattributed` = engine-custom U user-addon. The "
            "CLEAN-PROFILE re-run banked in Addons_load.md splits this. Not asserted here."),
        "shipped_usage_note": "RegisterStateDriver has ZERO shipped call sites; only "
                              "RegisterUnitWatch is called (twice, SecureTemplates.lua). "
                              "This is why the attested-conditional seed is empty.",
    }


# --------------------------------------------------------------- emission

def main():
    if not EXTRACT.is_dir():
        die(f"no extraction at {EXTRACT}\n      run: py addons\\tools\\extract_interface.py")
    OUT.mkdir(parents=True, exist_ok=True)
    buckets = census_buckets()

    print("reading locale archives (precedence merge)...")
    tokens, provenance, conflicts, anchors = read_locale_tokens()
    if conflicts:
        print(f"  !! {len(conflicts)} TOKEN VALUE CONFLICTS - precedence now bites, read them")
    print(f"  {len(tokens)} SLASH_ tokens across {len(anchors)} archives")

    commands, direct_n, orphans, unresolved = emit_commands(tokens, provenance, buckets)
    actions = emit_actions(buckets)
    conditionals = emit_conditionals()
    api = emit_api(buckets)
    statedrivers = emit_statedrivers(buckets)

    takes = sorted(k for k, c in commands.items() if c["takes_conditionals"])
    secure = {k: c for k, c in commands.items() if c["list"] == "SecureCmdList"}
    nonsecure = {k: c for k, c in commands.items() if c["list"] == "SlashCmdList"}
    custom_cmds = sorted(k for k, c in commands.items() if c["coa_custom_command"])

    # cross-total: the check that catches misattribution (49 = 49 by hand).
    # Greps the WHOLE extraction, not one file - the scan does, so this must too,
    # or it silently stops reconciling the thing it is meant to guard.
    sites = sum(p.read_text("utf-8", "replace").count("SecureCmdOptionParse(")
                for p in EXTRACT.rglob("*.lua") if p.is_file())
    cross = {"direct_callers_found": direct_n, "grep_call_sites": sites,
             "reconciles": direct_n == sites,
             "what": "handlers found to call SecureCmdOptionParse vs raw call sites in "
                     "source. Must match. Guards the owner-tracking misattribution that "
                     "produced a wrong count TWICE by hand."}

    files = {
        "commands.json": {
            "grain": "SOURCED-COMPLETE. ChatFrame.lua x GlobalStrings.lua (precedence-merged) "
                     "+ inline SLASH_ declarations. Conditional support COMPUTED per handler.",
            "counts": {"total": len(commands), "secure": len(secure),
                       "non_secure_kept": len(nonsecure),
                       "non_secure_taking_conditionals":
                           len([k for k, c in nonsecure.items() if c["takes_conditionals"]]),
                       "take_conditionals": len(takes),
                       "coa_custom": len(custom_cmds)},
            "cross_total": cross,
            "token_conflicts": conflicts,
            "holes": {
                "declared_without_handler": orphans,
                "declared_without_handler_note":
                    "a SLASH_ token declared inline in UI code but no handler found - "
                    "a parser gap or a dead token. NOT dropped silently: 3 commands "
                    "(BDRAFT indented, COATALENTFOOTER/STATLOGICDEBUG named-ref) went "
                    "missing exactly this way before the parser learned those forms.",
                "handler_body_unresolved": unresolved,
                "handler_body_unresolved_note":
                    "handler found but its body could not be read (named ref defined "
                    "elsewhere, or built dynamically) - `calls`/`custom_behaviour` are "
                    "BLIND for these, so absence of custom_behaviour proves nothing here.",
            },
            "commands": commands,
        },
        "actions.json": {
            "grain": "SOURCED-COMPLETE. SECURE_ACTIONS in SecureTemplates.lua. Each type "
                     "self-reports the attributes it reads (the sheets paired rule).",
            "what": "the `type` attribute vocabulary - what a /click-driven button or action "
                    "button can BE. The half of the macro surface that is not a typed verb.",
            "count": len(actions),
            "actions": actions,
        },
        "conditionals.json": conditionals,
        "api.json": api,
        "statedrivers.json": statedrivers,
    }
    for name, payload in files.items():
        with open(OUT / name, "w", encoding="utf-8") as f:
            json.dump(payload, f, indent=1, ensure_ascii=False)
            f.write("\n")

    domains = {
        "what": "THE top-domain catalog - the entry point. Start here, then open the "
                "domain you want. Grain is PER DOMAIN and differs; each file states its own.",
        "domains": {
            "commands": {"file": "commands.json", "count": len(commands),
                         "grain": "SOURCED-COMPLETE", "what": "the typed verbs"},
            "actions": {"file": "actions.json", "count": len(actions),
                        "grain": "SOURCED-COMPLETE", "what": "the `type` vocabulary (/click)"},
            "conditionals": {"file": "conditionals.json",
                             "count": conditionals["attested_count"],
                             "grain": "PROOF-PENDING - RIM FULLY OPEN",
                             "what": "the option vocabulary; C-side; probe is the SOLE channel"},
            "api": {"file": "api.json", "count": api["macro_api_count"],
                    "grain": "runtime-attested x source constants",
                    "what": "the macro C API + limits (limits CONFLICT - unresolved)"},
            "statedrivers": {"file": "statedrivers.json",
                             "count": len(statedrivers["functions"]),
                             "grain": "runtime-attested; PROVENANCE OPEN",
                             "what": "the 2nd consumer of the conditional vocabulary"},
        },
    }
    with open(OUT / "domains.json", "w", encoding="utf-8") as f:
        json.dump(domains, f, indent=1, ensure_ascii=False)
        f.write("\n")

    meta = {
        "emitted_at": datetime.now().isoformat(timespec="seconds"),
        "emitter": "macros/tools/emit_macro_basis.py",
        "source_anchors": {
            "patch-B.MPQ": sha256(DATA / "patch-B.MPQ") if (DATA / "patch-B.MPQ").is_file() else None,
            "locale_archives": anchors,
        },
        "extraction": str(EXTRACT),
        "grain": "PER DOMAIN - see domains.json. commands/actions SOURCED-COMPLETE; "
                 "conditionals PROOF-PENDING with a fully open rim (no source witness "
                 "exists); api limits CONFLICT unresolved; statedrivers provenance OPEN.",
        "counts": {k: v["count"] for k, v in domains["domains"].items()},
        "inadmissible": "agent WoW recall - this client is not a pure 3.3.5a",
    }
    with open(OUT / "_meta.json", "w", encoding="utf-8") as f:
        json.dump(meta, f, indent=1, ensure_ascii=False)
        f.write("\n")

    # ---- routes: the light browse menu (two-tier; open the .json for detail)
    anchor = (meta["source_anchors"]["patch-B.MPQ"] or "?")[:16]
    r = [f"# macros.routes - the CoA macro surface (browse menu)",
         "",
         f"_Anchor: patch-B.MPQ sha256 `{anchor}...` | emitted {meta['emitted_at'][:10]} | "
         f"grain: PER DOMAIN, they differ - each file states its own._",
         "",
         "**Start here, open one domain.** Emitted by `macros/tools/emit_macro_basis.py`; "
         "nothing here is written from an agent's WoW knowledge (this client is not a pure "
         "3.3.5a). Foundation: `operations/Macros.md`.",
         ""]
    for d, info in domains["domains"].items():
        r += [f"## {d} ({info['count']}) - `{info['file']}`  ·  _{info['grain']}_",
              f"{info['what']}", ""]
        if d == "commands":
            r.append(f"- entry rule: **(a)** secure · **(b)** takes conditionals · **(c)** "
                     f"CoA-custom. Stock chat/UI commands stay out.")
            r.append(f"- {len(secure)} SecureCmdList · {len(nonsecure)} non-secure kept · "
                     f"**{len(takes)} take conditionals** · {len(custom_cmds)} CoA-custom "
                     f"(declared INLINE, invisible to GlobalStrings)")
            no = sorted(k for k, c in secure.items() if not c["takes_conditionals"])
            r.append(f"- secure commands taking NO conditionals: {', '.join(no) or 'none'}")
            cond_ns = sorted(k for k, c in nonsecure.items() if c["takes_conditionals"])
            r.append(f"- **non-secure that DO take conditionals**: {', '.join(cond_ns) or 'none'}")
            withcustom = sorted(k for k, c in commands.items() if c["custom_behaviour"])
            r.append(f"- **custom BEHAVIOUR** (stock command, non-stock handler): "
                     f"{', '.join(withcustom) or 'none'}")
            r.append(f"- **CoA-custom commands**: "
                     f"{', '.join(sorted(t for k in custom_cmds for t in commands[k]['typed'])) or 'none'}")
        elif d == "actions":
            r.append(f"- types: {', '.join(sorted(actions))}")
        elif d == "conditionals":
            r.append(f"- **attested: {conditionals['attested_count']}** - the client's own code "
                     f"uses NO conditional literal. Not thin: zero.")
            r.append("- the live differential probe is the SOLE channel; see `probe_design`.")
        elif d == "api":
            if api["limit_conflicts"]:
                r.append(f"- **LIMITS CONFLICT** (client disagrees with itself): "
                         f"{', '.join(api['limit_conflicts'])} - unresolved from source, "
                         f"do not state a limit as fact")
        elif d == "statedrivers":
            r.append("- PROVENANCE OPEN: live, but no SecureStateDriver.lua in the extraction "
                     "and `unattributed` mixes engine-custom with user-addon")
        r.append("")
    (OUT / "macros.routes.md").write_text("\n".join(r), encoding="utf-8")

    print(f"\nEMITTED -> {OUT}")
    for k, v in meta["counts"].items():
        print(f"  {k:14} {v}")
    print(f"  cross-total   direct={cross['direct_callers_found']} "
          f"grep={cross['grep_call_sites']} reconciles={cross['reconciles']}")
    if not cross["reconciles"]:
        print("  !! CROSS-TOTAL DOES NOT RECONCILE - handler attribution is wrong, "
              "do not trust the conditional counts")
    if conflicts:
        print(f"  !! token conflicts: {len(conflicts)}")
    if api["limit_conflicts"]:
        print(f"  !! limit conflicts: {list(api['limit_conflicts'])}")
    if orphans:
        print(f"  !! declared, no handler found: {orphans}")
    if unresolved:
        print(f"  !! handler body unresolved (calls are BLIND): {unresolved}")


if __name__ == "__main__":
    main()
