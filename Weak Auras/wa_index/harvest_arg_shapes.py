"""
harvest_arg_shapes.py - derive the STORED-FORM grammar per arg.type from the fork's own ConstructFunction.

Why: three hand-written stored-form shapes were found in the gears (fill's load translation missing `use_class` - a
live-confirmed dead-config bug; expand's type-blind `use_` rule; expand's hand multiEntry array shape). One source
authors them all: WeakAuras.lua `singleTest` (the per-type test grammar) + `ConstructFunction` (the participation gate
+ the multiEntry array form). Harvest it ONCE into a map; the gears apply the map; hand-written shapes die.

Mechanical half: locate the singleTest/ConstructFunction spans, slice singleTest's per-type branches, record every
field-access pattern (use_<name>, <name>.single/.multi, <name>_operator, use_exact_<name>, ...) with its line.
Curated half: the authoring TEMPLATE per type, composed from those cited lines - the map carries BOTH, so the curation
is auditable against the extraction, never bare assertion.

Emits -> engine/Fact_basis/maps/arg_shapes.json (sibling of live_keys.json). Re-run on client patch; git diff = change control.

  py harvest_arg_shapes.py
"""
import json
import os
import re
import time

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)
SRC = r"F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns\WeakAuras\WeakAuras.lua"
OUT = os.path.join(_WA, "engine", "Fact_basis", "maps", "arg_shapes.json")

# access patterns -> canonical field-slot names (relative to the arg's `name`)
_PATTERNS = (
    (re.compile(r'trigger\["use_"\s*\.\.\s*name\]'), "use_<name>"),
    (re.compile(r'\bvalue\.single\b|\[name\]\.single'), "<name>.single"),
    (re.compile(r'\bvalue\.multi\b|\[name\]\.multi'), "<name>.multi"),
    (re.compile(r'name\s*\.\.\s*"_extraOption"'), "<name>_extraOption"),
    (re.compile(r'name\s*\.\.\s*"_operator"'), "<name>_operator"),
    (re.compile(r'name\s*\.\.\s*"_caseInsensitive"'), "<name>_caseInsensitive"),
    (re.compile(r'"use_exact_"\s*\.\.\s*name'), "use_exact_<name>"),
    (re.compile(r'trigger\[name\]'), "<name>"),
)

# CURATED authoring templates - composed from the cited branches; the gears substitute <name>/<value>.
TEMPLATES = {
    "multiselect": {
        "single_pick": {"use_<name>": True, "<name>": {"single": "<value>"}},
        "multi_pick": {"use_<name>": False, "<name>": {"multi": {"<value>": True}}},
        "off": "omit use_<name> entirely (participates only when use_<name> ~= nil)",
    },
    "toggle": {"on": {"use_<name>": True}, "off": {"use_<name>": False}},
    "tristate": {"require_true": {"use_<name>": True}, "require_false": {"use_<name>": False},
                 "dont_care": "omit use_<name>"},
    "tristatestring": {"equals": {"use_<name>": True, "<name>": "<value>"},
                       "not_equals": {"use_<name>": False, "<name>": "<value>"}},
    "string": {"on": {"use_<name>": True, "<name>": "<value>"}},
    "number": {"on": {"use_<name>": True, "<name>": "<value>", "<name>_operator": "<op>"}},
    "longstring": {"on": {"use_<name>": True, "<name>": "<value>", "<name>_operator": "<op>"}},
    "spell": {"on": {"use_<name>": True, "<name>": "<value>", "use_exact_<name>": False}},
    "talent": {"on": {"use_<name>": True, "<name>": "<value>", "use_exact_<name>": False}},
    "mysticenchant": {"on": {"use_<name>": True, "<name>": "<value>"}},
    "_multiEntry_variant": {
        "on": {"use_<name>": True, "<name>": ["<value>", "..."], "<name>_operator": ["<op>", "..."]},
        "note": "when the arg carries multiEntry, <name>/<name>_operator/<name>_caseInsensitive/use_exact_<name> are ARRAYS",
    },
}


def _span(lines, start_pat, stop_pat):
    start = next(i for i, ln in enumerate(lines, 1) if re.match(start_pat, ln))
    stop = next(i for i, ln in enumerate(lines[start:], start + 1) if re.match(stop_pat, ln))
    return start, stop - 1


def main():
    lines = open(SRC, encoding="utf-8", errors="replace").read().splitlines()
    st_a, st_b = _span(lines, r"local function singleTest\b", r"local function \w")
    cf_a, cf_b = _span(lines, r"local function ConstructFunction\b", r"^(local )?function \w")

    # slice singleTest into per-type branches
    branch_pat = re.compile(r'arg\.type == "(\w+)"')
    marks = [(i, m.group(1)) for i in range(st_a, st_b + 1)
             for m in [branch_pat.search(lines[i - 1])] if m]
    branches = {}
    for j, (ln, ty) in enumerate(marks):
        end = marks[j + 1][0] - 1 if j + 1 < len(marks) else st_b
        branches.setdefault(ty, []).append((ln, end))

    def accesses(a, b):
        found = {}
        for i in range(a, b + 1):
            for pat, slot in _PATTERNS:
                if pat.search(lines[i - 1]):
                    found.setdefault(slot, "%s:%d" % (os.path.basename(SRC), i))
        return found

    shapes = {}
    for ty, spans in branches.items():
        acc = {}
        for a, b in spans:
            acc.update(accesses(a, b))
        shapes[ty] = {"branch_lines": ["%d-%d" % (a, b) for a, b in spans], "accesses": acc,
                      "template": TEMPLATES.get(ty, "(no curated template yet - compose from accesses)")}

    # the generic reads + participation gate + multiEntry live in ConstructFunction, apply across types
    generic = accesses(cf_a, cf_b)
    gate_ln = next(i for i in range(cf_a, cf_b) if "multiselect" in lines[i - 1] and "~= nil" in lines[i - 1])
    me_ln = next(i for i in range(cf_a, cf_b) if "arg.multiEntry" in lines[i - 1])

    out = {
        "_meta": {
            "what": "stored-form grammar per arg.type (load + prototype args). Gears apply TEMPLATE; accesses = the "
                    "mechanical extraction the template is audited against.",
            "source": SRC, "harvested": time.strftime("%Y-%m-%d"),
            "spans": {"singleTest": "%d-%d" % (st_a, st_b), "ConstructFunction": "%d-%d" % (cf_a, cf_b)},
            "participation_gate": {
                "cite": "%s:%d" % (os.path.basename(SRC), gate_ln),
                "rule": "tristate/toggle/tristatestring: always evaluated | multiselect: ONLY when use_<name> ~= nil "
                        "(true=single, false=multi) | all others: ONLY when (use_<name> or required) and <name>",
            },
            "multiEntry": {"cite": "%s:%d" % (os.path.basename(SRC), me_ln),
                           "rule": TEMPLATES["_multiEntry_variant"]["note"]},
            "generic_reads": generic,
        },
        "types": shapes,
        "_templates_multiEntry": TEMPLATES["_multiEntry_variant"],
    }
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    json.dump(out, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("singleTest %d-%d | ConstructFunction %d-%d" % (st_a, st_b, cf_a, cf_b))
    for ty, s in sorted(shapes.items()):
        print("  %-14s branches %s  accesses: %s" % (ty, ",".join(s["branch_lines"]), ", ".join(sorted(s["accesses"]))))
    print("participation gate @ %d | multiEntry @ %d" % (gate_ln, me_ln))
    print("wrote %s" % os.path.relpath(OUT, _WA))


if __name__ == "__main__":
    main()
