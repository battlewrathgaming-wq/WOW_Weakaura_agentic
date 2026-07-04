"""
tooltip_normalize.py - resolves WoW client tooltip escape syntax found raw in
Spell.dbc Description_0 text, so descriptions read like real tooltips instead
of leaking |cAARRGGBB color codes and $-variable tokens.

Confirmed empirically against real Necromancer spell text (see
Docs/PIPELINE.md section 9 / spell_family_index.json):
  - |cffffffffWord|r / |cff90ee90Word|r    -> color wrap, strip to "Word"
  - $s<N> / $m<N> (case-insensitive)        -> OWN EffectBasePoints[N-1]
  - $<spellid>s<N> / $<spellid>m<N>         -> ANOTHER spell's EffectBasePoints[N-1]
  - $/<div>;s<N> / $/<div>;<spellid>s<N>    -> EffectBasePoints[N-1] / <div> (own or cross)
  - $h / $<spellid>h                        -> ProcChance (own / another spell)
  - $u / $<spellid>u                        -> CumulativeAura, i.e. max stacks (own / another) -
                                                confirmed against Diabolical (706504): ProcCharges
                                                is 0 there, CumulativeAura=15 is the real stack cap
  - $t<N> / $T<N> / $<spellid>t<N>          -> EffectAuraPeriod[N-1] in seconds, BARE NUMBER
                                                (the source text already supplies "sec" after the
                                                token - confirmed by Flesh to Worms: "every $t1 sec")
  - $i / $<spellid>i                        -> first non-zero EffectChainTargets (own / another)
  - $a<N> / $<spellid>a<N>                  -> radius yards via EffectRadiusIndex -> SpellRadius.dbc
                                                (SpellRadius.dbc is ID + 3 FLOATS, not ints - verified
                                                against raw file: id 7 -> 2.0 yds, id 8 -> 5.0 yds, etc)
  - $d / $<spellid>d                        -> duration (own / another spell's), WITH unit
  - ${...}                                   -> arithmetic; inner $ tokens resolved first,
                                                 then evaluated if purely numeric
  - $?s<id>[X][Y]                            -> "if caster knows spell <id>" ternary; no build
                                                 context available, shows base-state branch X
                                                 (approximation - out of scope per project
                                                 instructions to not build a live calculator)

Display formula confirmed against 3 independent known-good examples (Command:
Banshee's basePoints 19 -> displayed 20%/40%, Grave Mastery's -21 -> 20%,
Graverobber's -31 -> 30%):
    display_value = abs(EffectBasePoints[i] + 1)
Classic WotLK "basePoints stores value-1" convention; abs() because
Ascension's text already says "reduces/drains" and expects a positive number.

Anything genuinely uncomputable without live caster stats (spell power,
intellect - tokens like $SP, $INT, $sps, $spfr, $<name>) is left as a plain
"(scales with caster stats)" note rather than a fabricated number. This
module intentionally does NOT try to be a talent-build calculator - see
project instructions ("calculation/selecting can be forgotten as a
requirement"); it only normalizes static display text.
"""
import re

COLOR_RE = re.compile(r'\|c[0-9A-Fa-f]{8}|\|r')
DOLLAR_BRACE_RE = re.compile(r'\$\{([^{}]*)\}')
TERNARY_RE = re.compile(r'\$\?s\d+\[([^\]]*)\]\[([^\]]*)\]')
DIV_TOKEN_RE = re.compile(r'\$/(\d+);(\d+)?([sSmM])(\d+)')
CROSS_TOKEN_RE = re.compile(r'\$(\d+)([sSmM])(\d+)')
OWN_TOKEN_RE = re.compile(r'\$([sSmM])(\d+)')
CROSS_H_RE = re.compile(r'\$(\d+)h\b')
OWN_H_RE = re.compile(r'\$h\b')
CROSS_U_RE = re.compile(r'\$(\d+)u\b')
OWN_U_RE = re.compile(r'\$u\b')
CROSS_T_RE = re.compile(r'\$(\d+)[tT](\d+)')
OWN_T_RE = re.compile(r'\$[tT](\d+)')
CROSS_I_RE = re.compile(r'\$(\d+)i\b')
OWN_I_RE = re.compile(r'\$i\b')
CROSS_A_RE = re.compile(r'\$(\d+)a(\d+)')
OWN_A_RE = re.compile(r'\$a(\d+)')
CROSS_DUR_RE = re.compile(r'\$(\d+)d\b')
OWN_DUR_RE = re.compile(r'\$d\b')
LEFTOVER_RE = re.compile(r'\$\??\w*(\[[^\]]*\]){0,2}')
TEACH_TAG_RE = re.compile(r'@s:\d+:\d+@')
SAFE_EXPR_RE = re.compile(r'^[0-9+\-*/(). ]+$')


def _base_value(rec, idx):
    val = (rec or {}).get(f'EffectBasePoints_{idx}')
    if val is None:
        return None
    return abs(val + 1)


def _first_nonzero_chain(rec):
    for i in range(3):
        v = (rec or {}).get(f'EffectChainTargets_{i}')
        if v:
            return v
    return None


def _fmt_num(v):
    if v is None:
        return '?'
    if float(v).is_integer():
        return str(int(v))
    return f'{v:g}'


def make_normalizer(spell_by_id, durations, radii, fmt_ms):
    """radii: dict from SpellRadius.dbc ID -> radius in yards (float). Must be
    loaded with a float-aware reader - the DBC stores ID + 3 floats, NOT 4
    ints (confirmed: record 7 -> 2.0 yds when read as float, garbage when
    read as int)."""

    def resolve_simple_tokens(s, rec):
        s = DIV_TOKEN_RE.sub(lambda m: _fmt_num((_base_value(spell_by_id.get(int(m.group(2))) if m.group(2) else rec, int(m.group(4)) - 1) or 0) / int(m.group(1))), s)
        s = CROSS_TOKEN_RE.sub(lambda m: _fmt_num(_base_value(spell_by_id.get(int(m.group(1))), int(m.group(3)) - 1)), s)
        s = OWN_TOKEN_RE.sub(lambda m: _fmt_num(_base_value(rec, int(m.group(2)) - 1)), s)
        s = CROSS_H_RE.sub(lambda m: _fmt_num(spell_by_id.get(int(m.group(1)), {}).get('ProcChance')), s)
        s = OWN_H_RE.sub(lambda m: _fmt_num(rec.get('ProcChance')), s)
        s = CROSS_U_RE.sub(lambda m: _fmt_num(spell_by_id.get(int(m.group(1)), {}).get('CumulativeAura')), s)
        s = OWN_U_RE.sub(lambda m: _fmt_num(rec.get('CumulativeAura')), s)
        s = CROSS_T_RE.sub(lambda m: _fmt_num((spell_by_id.get(int(m.group(1)), {}).get(f'EffectAuraPeriod_{int(m.group(2))-1}') or 0) / 1000), s)
        s = OWN_T_RE.sub(lambda m: _fmt_num((rec.get(f'EffectAuraPeriod_{int(m.group(1))-1}') or 0) / 1000), s)
        s = CROSS_I_RE.sub(lambda m: _fmt_num(_first_nonzero_chain(spell_by_id.get(int(m.group(1))))), s)
        s = OWN_I_RE.sub(lambda m: _fmt_num(_first_nonzero_chain(rec)), s)
        s = CROSS_A_RE.sub(lambda m: _fmt_num(radii.get((spell_by_id.get(int(m.group(1))) or {}).get(f'EffectRadiusIndex_{int(m.group(2))-1}'))), s)
        s = OWN_A_RE.sub(lambda m: _fmt_num(radii.get(rec.get(f'EffectRadiusIndex_{int(m.group(1))-1}'))), s)
        s = CROSS_DUR_RE.sub(lambda m: fmt_ms(durations.get((spell_by_id.get(int(m.group(1))) or {}).get('DurationIndex'))) or '?', s)
        s = OWN_DUR_RE.sub(lambda m: fmt_ms(durations.get(rec.get('DurationIndex'))) or '?', s)
        return s

    def resolve_brace(m, rec):
        inner = resolve_simple_tokens(m.group(1), rec)
        if not SAFE_EXPR_RE.match(inner):
            return '(scales with caster stats)'
        try:
            val = eval(inner, {'__builtins__': {}}, {})
            return _fmt_num(val)
        except Exception:
            return '(scales with caster stats)'

    def normalize(text, rec):
        if not text:
            return text
        text = text.replace('\r\n', '\n')
        text = TERNARY_RE.sub(lambda m: m.group(1), text)
        text = DOLLAR_BRACE_RE.sub(lambda m: resolve_brace(m, rec), text)
        text = resolve_simple_tokens(text, rec)
        text = re.sub(r'@ext:(.*?):ext@', lambda m: m.group(1), text, flags=re.S)  # Ascension's own 'extended info' tag - keep the text, drop the marker
        text = TEACH_TAG_RE.sub('', text)  # Ascension's own teach-tag marker (@s:<id>:<mask>@) -
                                            # used elsewhere to extract 'teaches' edges, but the
                                            # raw marker itself is never meant to be displayed
        text = LEFTOVER_RE.sub('', text)  # anything else uncomputable (stat scaling etc) - drop cleanly
        text = COLOR_RE.sub('', text)
        text = re.sub(r'[ \t]{2,}', ' ', text)
        return text

    return normalize


def load_float_dbc(mpq, name):
    """For DBCs shaped ID(int32) + N floats, e.g. SpellRadius.dbc (id, radius,
    radiusPerLevel, radiusMax). Returns {ID: first_float_value}."""
    import struct
    data = mpq.read_file('DBFilesClient\\' + name)
    magic, rc, fc, rs, sbs = struct.unpack('<4sIIII', data[:20])
    out = {}
    for i in range(rc):
        base = 20 + i * rs
        rec_id, val = struct.unpack('<if', data[base:base + 8])
        out[rec_id] = val
    return out


if __name__ == '__main__':
    import sys, json
    sys.path.insert(0, '.')
    from build_abilities_reference_dbc import load_spell_dbc, load_simple_dbc, open_mpq_set, fmt_ms

    data_dir = '/sessions/keen-relaxed-johnson/mnt/Ascension_wow/resources/ascension-live/Data'
    mpq = open_mpq_set(data_dir)
    spell_by_id = load_spell_dbc(mpq)
    durations = load_simple_dbc(mpq, 'SpellDuration.dbc')
    radii = load_float_dbc(mpq, 'SpellRadius.dbc')
    normalize = make_normalizer(spell_by_id, durations, radii, fmt_ms)

    test_ids = {
        'Game of Bones': 301198, 'Raise: Banshee': 504861, 'Skeletal Artillery': 302518,
        'Grave Mastery': 504439, 'Graverobber': 503757, 'Deadly Defense': 300580,
        'Harrowing Winds': 705745, 'Diabolical': 706504, 'Forbidden Technique': 561215,
        'Flesh to Worms': 500338, "Putricide's Formula": 707001, 'Necrotic Chains': 807978,
    }
    for name, sid in test_ids.items():
        rec = spell_by_id.get(sid)
        if not rec:
            print(name, sid, 'NOT FOUND'); continue
        out = normalize(rec['Description_0'], rec)
        print(f'--- {name} ({sid}) ---')
        print(out)
        print()
