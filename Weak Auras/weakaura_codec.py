#!/usr/bin/env python3
"""
weakaura_codec.py - Standalone, dependency-free WeakAuras import/export codec.

WHAT THIS IS
------------
A Python port of the exact encoding pipeline WeakAuras (v5.21.2, the build
installed for Conquest of Azeroth / Project Ascension) uses to produce and
consume import strings - the text you paste into WeakAuras' in-game Import
dialog. The pipeline, confirmed by reading this project's installed
Transmission.lua directly, is:

    "!WA:2!" + EncodeForPrint(CompressDeflate(LibSerialize.Serialize(table)))

This file reimplements each stage:

  1. LibSerialize's binary table-serialization format (ported from
     rossnichols/LibSerialize on GitHub - not bundled with this project's
     WeakAuras install, see WARNING below).
  2. Standard DEFLATE (RFC 1951) via Python's stdlib `zlib`, used in raw
     (no zlib header) mode - LibDeflate's compressed output is standard
     DEFLATE, so any compliant encoder/decoder interoperates with it in
     both directions. No custom compressor needed here.
  3. LibDeflate's `EncodeForPrint`/`DecodeForPrint` - a 6-bit-per-character
     printable encoding (ported directly from this project's installed
     LibDeflate.lua, byte-for-byte).

No third-party packages required - pure standard library (`zlib`, `struct`).

WHY THIS EXISTS
---------------
Direct hand-editing of WeakAuras' SavedVariables file was tested and
confirmed NOT to work (see USE_CASE.md, 2026-07-02 injection-stability
test): WeakAuras does not trust its own `displays` table blindly at load,
and a hand-added entry that didn't go through its own creation/import path
gets silently dropped and then permanently overwritten on next save. The
supported path for getting agent-authored aura data into the game is the
same one Wago.io-hosted auras use: a real import string, pasted through
WeakAuras' own Import dialog, which runs it through the addon's actual
validation/registration code instead of reading it as inert saved data.

This module produces (and can also decode/inspect) that exact string
format, so an aura can be designed programmatically (e.g. from the
ability-index pipeline data, see AURA_BLUEPRINT.md) and handed to a human
to paste in-game, without needing to hand-build it through the WeakAuras
UI every time.

STATUS - DECODE VALIDATED AGAINST REAL EXPORT, ENCODE NOT YET LIVE-TESTED
--------------------------------------------------------------------------
Updated 2026-07-02, later the same day: the "TestClone" aura ("Test") was
exported for real in-game (character Weakauratest / Area 52 - Free-Pick),
and both the resulting import string and WeakAuras' own debug-table dump
were captured. Decoding that real string with this codec
(`decode_import_string`) reproduces the debug-table dump exactly,
field-for-field, including nested subRegions/triggers/animation blocks and
the `tocversion` field WeakAuras' own CompressDisplay adds on export. See
`REAL_WEAKAURAS_EXPORT_STRING` and the corresponding self-test below.

This also resolves the earlier concern that this client's WeakAuras is
missing several libraries its own Init.lua checks for on load
(AceSerializer-3.0, AceComm-3.0, LibCompress, LibSerialize itself -
still confirmed absent as loose files from Interface/AddOns, only
LibStub, LibDeflate, and LibCustomGlow are bundled via Archivist) -
whatever the actual mechanism, Export demonstrably works on this client,
so Transmission.lua is not short-circuiting the way `IsLibsOK()` being
false would imply.

UPDATE (same day, later): the single-aura encoder was live-tested - a
string produced by `encode_import_string` was pasted into WeakAuras'
in-game Import dialog, imported cleanly as "Test", and survived being
deleted and reimported a second time. The full round trip (agent-authored
Python data to a real in-game aura) is confirmed working end to end.

GROUP SUPPORT (same day): added `encode_group_import_string`/
`decode_group_import_string` for FLAT WeakAuras groups (one parent group,
plain leaf children, no group nested inside another group). A real group
export ("Example_group", 4 icon children) was captured from this
project's client and used to validate the decoder byte-for-byte -
see `REAL_GROUP_EXPORT_STRING` and the group self-tests below.

GROUP ENCODER LIVE-VALIDATED (same day): a string produced by
`encode_group_import_string` (1 group + 4 icon children) was pasted into
WeakAuras' in-game Import dialog and imported with no malformation. Both
the single-aura and flat-group encode/decode paths are now confirmed
working end to end, in-game, not just via internal round-trip tests.

Nested groups (a group containing another group) are NOT supported - see
the comment above `encode_group_import_string` for why, and
`reference_library.py` for what a real nested pack (Fojji's Class Pack
Anchors) looks like structurally.

DEBUGGING CHECKLIST - if a pasted import string throws an error or
renders wrong in-game, check these in order before assuming the codec's
core encode/decode is broken (it's been live-validated repeatedly - the
two real incidents so far were both about incompletely-cloned data, not
the codec's serialization itself):

1. **Duplicate `uid` across children?** `uid` (not `id`) is WeakAuras'
   real identity key. Symptom: an element goes missing and/or others
   render at conflicting/overlapping positions after adding new
   children. Almost always caused by building a new child from
   `dict(existing_child)` and forgetting to overwrite `uid` - always
   call `generate_unique_id()` for anything copied this way. Check:
   decode the string and look for repeated `uid` values across `c[]`.
2. **`controlledChildren` not matching `c[]`?** Symptom:
   `attempt to index local 'pendingPickData' (a nil value)` in
   `WeakAurasOptions/OptionsFrames/Update.lua` (or similar update-flow
   errors) specifically when re-importing an update to an EXISTING
   aura, not on a fresh import. Caused by passing a `group_table` whose
   `controlledChildren` was decoded from a prior version and doesn't
   list every id actually in the new `children_tables`.
   `encode_group_import_string` always regenerates this field now, but
   if you ever hand-build the envelope another way, check `set(d.
   controlledChildren) == set(c["id"] for c in c_list)` explicitly.
3. **Still malformed and you can't tell why?** Delete the existing
   same-named aura in-game first, then paste as a fresh import rather
   than an update. `Update.lua`'s fresh-import path always sets up its
   post-import state correctly regardless of the above two issues - a
   fresh import sidesteps the whole old/new-arrangement diff logic that
   both real bugs above went through.
4. **Rows overlapping or spans wider/narrower than expected?** Not a
   codec bug - a geometry one. Run `space_audit.py` against the decoded
   children and check row-to-row gaps (should never be unexpectedly
   negative for genuinely sequential rows) and each row's own span
   before assuming a resize was applied correctly.
5. **Hand-typed a long import string into a file and it looks subtly
   wrong?** Don't retype it again to fix it - `diff` the file against
   whatever verified source you generated it from. A single dropped
   character mid-string is invisible by eye but breaks decoding; this
   has happened once already this project (see USE_CASE.md).
6. **Bash tool reads a file and it looks truncated or corrupted right
   after a Write/Edit tool call touched it?** This is a known mount-lag
   issue, not a real file problem - the Read tool's view is
   authoritative. Verify by re-reading with Read (not bash `cat`/`tail`)
   before concluding anything is actually broken; if you need to
   execute code against the file, rebuild from your own last verified
   copy rather than trusting a fresh bash read of the live path.

USAGE
-----
    import weakaura_codec as wa

    # A Python dict/list structure mirroring a Lua table (see
    # EXAMPLE_TEST_AURA below for a real one pulled from this project's
    # SavedVariables).
    aura_table = {"id": "Example", "width": 64, ...}

    import_string = wa.encode_import_string(aura_table)
    # -> paste this into WeakAuras' in-game Import dialog

    # Reverse direction - decoding a string you already have (e.g. one
    # copied out of SavedVariables via WeakAuras' own Export button):
    recovered_table = wa.decode_import_string(import_string)

Run this file directly to execute self-tests:

    python3 weakaura_codec.py

DECODING A STRING PASTED DIRECTLY IN CHAT (tool instructions, 2026-07-04)
--------------------------------------------------------------------------
When Battlewrath pastes a raw "!WA:2!..." string for inspection: it may be
a single aura OR a flat group, and there's no way to tell which just by
looking at the text. Try single-aura decode first, fall back to group
decode on failure:

    try:
        aura = wa.decode_import_string(pasted_string)
        # -> aura is one dict (single leaf aura)
    except ValueError:
        group, children = wa.decode_group_import_string(pasted_string)
        # -> group is the parent dict, children is a list of leaf auras

Both raise ValueError (not a crash) on the wrong envelope shape - see
decode_import_string's own check for the "c" key - so this try/except is
the correct, deliberate way to detect which kind it is, not a workaround.
Once decoded, print/dump `aura["conditions"]`, `aura["subRegions"]`, and
`aura["triggers"]` directly - see REAL_MULTI_CONDITION_EXAMPLE_STRING below
for a worked real example of exactly this, including what a multi-check
Conditions setup actually looks like (a real capture, not a guess - this
corrected a wrong assumption template_filler.py's glow-source mechanism
had been built on, see that file's own updated docstring for the fix).
"""

from __future__ import annotations

import random
import struct
import zlib
from typing import Any, Dict, List, Tuple, Union

LuaValue = Union[None, bool, int, float, str, "LuaTable"]
LuaTable = Union[Dict[Any, Any], List[Any]]


# ============================================================================
# Section 1: LibSerialize port
#
# Ported from rossnichols/LibSerialize (LibSerialize.lua on GitHub - not
# bundled with this project's WeakAuras install, fetched and read directly
# for this port). Format summary (see the type-byte doc comment in the
# original source):
#
#   NNNN NNN1  - a 7 bit non-negative int, embedded directly in the byte
#   CCCC TT10  - a 2 bit embedded-type index + 4 bit count (string/table/
#                array/mixed with a small count), payload follows
#   NNNN S100  - a 12 bit signed int, 4 low bits + sign in this byte,
#                8 high bits in the following byte
#   TTTT T000  - a 5 bit "full" type index (see _ReaderIndex below),
#                type-dependent payload (including explicit counts) follows
#
# All multi-byte integers (lengths, back-reference indices, large number
# magnitudes) are big-endian, fixed-width (1/2/3/4/7 bytes chosen by
# magnitude) - there is no protobuf/LEB128-style continuation-bit varint
# anywhere in this format.
# ============================================================================

SERIALIZATION_VERSION = 1
DESERIALIZATION_VERSION = 2  # both 1 and 2 are accepted as this same format

_EMBEDDED_STRING = 0
_EMBEDDED_TABLE = 1
_EMBEDDED_ARRAY = 2
_EMBEDDED_MIXED = 3

_NIL = 0
_NUM_16_POS = 1
_NUM_16_NEG = 2
_NUM_24_POS = 3
_NUM_24_NEG = 4
_NUM_32_POS = 5
_NUM_32_NEG = 6
_NUM_64_POS = 7
_NUM_64_NEG = 8
_NUM_FLOAT = 9
_NUM_FLOATSTR_POS = 10
_NUM_FLOATSTR_NEG = 11
_BOOL_T = 12
_BOOL_F = 13
_STR_8 = 14
_STR_16 = 15
_STR_24 = 16
_TABLE_8 = 17
_TABLE_16 = 18
_TABLE_24 = 19
_ARRAY_8 = 20
_ARRAY_16 = 21
_ARRAY_24 = 22
_MIXED_8 = 23
_MIXED_16 = 24
_MIXED_24 = 25
_STRINGREF_8 = 26
_STRINGREF_16 = 27
_STRINGREF_24 = 28
_TABLEREF_8 = 29
_TABLEREF_16 = 30
_TABLEREF_24 = 31

_STR_BY_WIDTH = {1: _STR_8, 2: _STR_16, 3: _STR_24}
_TABLE_BY_WIDTH = {1: _TABLE_8, 2: _TABLE_16, 3: _TABLE_24}
_ARRAY_BY_WIDTH = {1: _ARRAY_8, 2: _ARRAY_16, 3: _ARRAY_24}
_MIXED_BY_WIDTH = {1: _MIXED_8, 2: _MIXED_16, 3: _MIXED_24}
_STRINGREF_BY_WIDTH = {1: _STRINGREF_8, 2: _STRINGREF_16, 3: _STRINGREF_24}
_TABLEREF_BY_WIDTH = {1: _TABLEREF_8, 2: _TABLEREF_16, 3: _TABLEREF_24}
_NUM_BY_WIDTH_POS = {2: _NUM_16_POS, 3: _NUM_24_POS, 4: _NUM_32_POS, 7: _NUM_64_POS}


def _required_bytes(value: int) -> int:
    """Matches GetRequiredBytes: width for lengths/ref indices, capped at 3."""
    if value < 256:
        return 1
    if value < 65536:
        return 2
    if value < 16777216:
        return 3
    raise ValueError("Object limit exceeded (>16,777,215 entries/length)")


def _required_bytes_number(value: int) -> int:
    """Matches GetRequiredBytesNumber: width for integer magnitudes, up to 7."""
    if value < 256:
        return 1
    if value < 65536:
        return 2
    if value < 16777216:
        return 3
    if value < 4294967296:
        return 4
    return 7


def _int_to_bytes(n: int, width: int) -> bytes:
    """Big-endian fixed-width int encode, matching IntToString."""
    return n.to_bytes(width, byteorder="big")


def _bytes_to_int(data: bytes, pos: int, width: int) -> int:
    """Big-endian fixed-width int decode, matching StringToInt."""
    return int.from_bytes(data[pos:pos + width], byteorder="big")


def _float_to_bytes(n: float) -> bytes:
    """
    Big-endian IEEE-754 binary64. The Lua original hand-rolls this via
    frexp/ldexp (no string.pack in Lua 5.1); struct.pack(">d", n) produces
    the same standard IEEE-754 layout.
    """
    return struct.pack(">d", n)


def _bytes_to_float(data: bytes) -> float:
    return struct.unpack(">d", data)[0]


def _is_fractional(value: float) -> bool:
    return value != int(value)


def _is_floating_point(value: float) -> bool:
    return _is_fractional(value) or not _is_finite(value)


def _is_finite(value: float) -> bool:
    return value == value and value not in (float("inf"), float("-inf"))


class _Writer:
    """Serializes a sequence of Lua-equivalent Python values to bytes."""

    def __init__(self) -> None:
        self._buf = bytearray()
        self._string_refs: Dict[str, int] = {}
        self._table_refs: Dict[int, int] = {}  # id(obj) -> ref index

    def to_bytes(self) -> bytes:
        return bytes(self._buf)

    def _write_byte(self, value: int) -> None:
        self._buf.append(value & 0xFF)

    def _write_int(self, n: int, width: int) -> None:
        self._buf.extend(_int_to_bytes(n, width))

    def _write_raw(self, data: bytes) -> None:
        self._buf.extend(data)

    def _add_string_ref(self, s: str) -> None:
        # Refs are 1-based insertion order, matching _AddReference.
        self._string_refs[s] = len(self._string_refs) + 1

    def _add_table_ref(self, key: int) -> None:
        self._table_refs[key] = len(self._table_refs) + 1

    def write(self, value: LuaValue) -> None:
        if value is None:
            self._write_byte(8 * _NIL)
        elif isinstance(value, bool):
            self._write_byte(8 * (_BOOL_T if value else _BOOL_F))
        elif isinstance(value, (int, float)):
            self._write_number(value)
        elif isinstance(value, str):
            self._write_string(value)
        elif isinstance(value, (dict, list)):
            self._write_table(value)
        else:
            raise TypeError(f"Unsupported value type for LibSerialize: {type(value)!r}")

    def _write_number(self, num: Union[int, float]) -> None:
        if _is_floating_point(num):
            self._write_float(float(num))
            return
        num = int(num)
        if 0 <= num < 128:
            self._write_byte(num * 2 + 1)
        elif -4096 < num < 4096:
            sign = 8 if num < 0 else 0
            mag = -num if num < 0 else num
            packed = mag * 16 + sign + 4
            lower = packed % 256
            upper = packed // 256
            self._write_byte(lower)
            self._write_byte(upper)
        else:
            sign = 8 if num < 0 else 0
            mag = -num if num < 0 else num
            width = _required_bytes_number(mag)
            index = _NUM_BY_WIDTH_POS[width] if width in _NUM_BY_WIDTH_POS else _NUM_BY_WIDTH_POS[2]
            self._write_byte(sign + 8 * index)
            self._write_int(mag, width)

    def _write_float(self, num: float) -> None:
        sign = 8 if num < 0 else 0
        mag = -num if num < 0 else num
        as_string = repr(mag) if mag == mag else "nan"  # str(mag) matches Lua tostring closely enough
        # Match the "compact decimal string" fast path when it round-trips
        # and is short, else fall back to raw IEEE-754 double bytes.
        try:
            round_trips = _is_finite(mag) and float(as_string) == mag
        except (ValueError, OverflowError):
            round_trips = False
        if round_trips and len(as_string) < 7:
            self._write_byte(sign + 8 * _NUM_FLOATSTR_POS)
            self._write_int(len(as_string), 1)
            self._write_raw(as_string.encode("ascii"))
        else:
            self._write_byte(8 * _NUM_FLOAT)
            self._write_raw(_float_to_bytes(num))

    def _write_string(self, s: str) -> None:
        data = s.encode("utf-8")
        existing_ref = self._string_refs.get(s)
        if existing_ref is not None:
            width = _required_bytes(existing_ref)
            self._write_byte(8 * _STRINGREF_BY_WIDTH[width])
            self._write_int(existing_ref, width)
            return

        length = len(data)
        if length < 16:
            self._write_byte(16 * length + 4 * _EMBEDDED_STRING + 2)
        else:
            width = _required_bytes(length)
            self._write_byte(8 * _STR_BY_WIDTH[width])
            self._write_int(length, width)
        self._write_raw(data)
        if length > 2:
            self._add_string_ref(s)

    def _write_table(self, tab: LuaTable) -> None:
        key = id(tab)
        existing_ref = self._table_refs.get(key)
        if existing_ref is not None:
            width = _required_bytes(existing_ref)
            self._write_byte(8 * _TABLEREF_BY_WIDTH[width])
            self._write_int(existing_ref, width)
            return

        # Register the ref BEFORE writing contents, so self-referencing
        # structures serialize correctly (matches the Lua original).
        self._add_table_ref(key)

        array_items, map_items = _split_table(tab)
        array_count = len(array_items)
        map_count = len(map_items)

        if map_count == 0:
            self._write_array_header(array_count)
            for v in array_items:
                self.write(v)
        elif array_count == 0:
            self._write_map_header(map_count)
            for k, v in map_items:
                self.write(k)
                self.write(v)
        else:
            self._write_mixed_header(array_count, map_count)
            for v in array_items:
                self.write(v)
            for k, v in map_items:
                self.write(k)
                self.write(v)

    def _write_array_header(self, count: int) -> None:
        if count < 16:
            self._write_byte(16 * count + 4 * _EMBEDDED_ARRAY + 2)
        else:
            width = _required_bytes(count)
            self._write_byte(8 * _ARRAY_BY_WIDTH[width])
            self._write_int(count, width)

    def _write_map_header(self, count: int) -> None:
        if count < 16:
            self._write_byte(16 * count + 4 * _EMBEDDED_TABLE + 2)
        else:
            width = _required_bytes(count)
            self._write_byte(8 * _TABLE_BY_WIDTH[width])
            self._write_int(count, width)

    def _write_mixed_header(self, array_count: int, map_count: int) -> None:
        if map_count < 5 and array_count < 5:
            combined = (map_count - 1) * 4 + (array_count - 1)
            self._write_byte(16 * combined + 4 * _EMBEDDED_MIXED + 2)
        else:
            width = max(_required_bytes(map_count), _required_bytes(array_count))
            self._write_byte(8 * _MIXED_BY_WIDTH[width])
            self._write_int(array_count, width)
            self._write_int(map_count, width)


def _split_table(tab: LuaTable) -> Tuple[List[Any], List[Tuple[Any, Any]]]:
    """
    Splits a Python dict/list into (array_part, map_part), matching the
    Lua original's ipairs-run-then-remaining-pairs behavior: the array part
    is the contiguous run of integer keys 1..N with no gaps, the map part
    is everything else (any keys beyond that run, or non-integer keys).
    """
    if isinstance(tab, list):
        return list(tab), []

    array_items: List[Any] = []
    n = 1
    while n in tab:
        array_items.append(tab[n])
        n += 1
    array_run_end = n - 1

    map_items: List[Tuple[Any, Any]] = []
    for k, v in tab.items():
        if isinstance(k, int) and 1 <= k <= array_run_end:
            continue
        map_items.append((k, v))
    return array_items, map_items


class _Reader:
    """Deserializes bytes produced by LibSerialize's format back to Python."""

    def __init__(self, data: bytes) -> None:
        self._data = data
        self._pos = 0
        self._string_refs: Dict[int, str] = {}
        self._table_refs: Dict[int, LuaTable] = {}

    def _at_end(self) -> bool:
        return self._pos >= len(self._data)

    def _read_byte(self) -> int:
        b = self._data[self._pos]
        self._pos += 1
        return b

    def _read_int(self, width: int) -> int:
        value = _bytes_to_int(self._data, self._pos, width)
        self._pos += width
        return value

    def _read_raw(self, length: int) -> bytes:
        value = self._data[self._pos:self._pos + length]
        self._pos += length
        return value

    def read_all(self) -> List[LuaValue]:
        out = []
        while not self._at_end():
            out.append(self.read())
        return out

    def read(self) -> LuaValue:
        value = self._read_byte()

        if value % 2 == 1:
            return (value - 1) // 2

        if value % 4 == 2:
            typ_and_count = (value - 2) // 4
            count = typ_and_count // 4
            typ = typ_and_count % 4
            return self._read_embedded(typ, count)

        if value % 8 == 4:
            packed = self._read_byte() * 256 + value
            if value % 16 == 12:
                return -(packed - 12) // 16
            return (packed - 4) // 16

        typ = value // 8
        return self._read_full(typ)

    def _read_embedded(self, typ: int, count: int) -> LuaValue:
        if typ == _EMBEDDED_STRING:
            return self._read_string(count)
        if typ == _EMBEDDED_TABLE:
            return self._read_table(count)
        if typ == _EMBEDDED_ARRAY:
            return self._read_array(count)
        if typ == _EMBEDDED_MIXED:
            return self._read_mixed((count % 4) + 1, (count // 4) + 1)
        raise ValueError(f"Unknown embedded type index: {typ}")

    def _read_full(self, typ: int) -> LuaValue:
        if typ == _NIL:
            return None
        if typ == _NUM_16_POS:
            return self._read_int(2)
        if typ == _NUM_16_NEG:
            return -self._read_int(2)
        if typ == _NUM_24_POS:
            return self._read_int(3)
        if typ == _NUM_24_NEG:
            return -self._read_int(3)
        if typ == _NUM_32_POS:
            return self._read_int(4)
        if typ == _NUM_32_NEG:
            return -self._read_int(4)
        if typ == _NUM_64_POS:
            return self._read_int(7)
        if typ == _NUM_64_NEG:
            return -self._read_int(7)
        if typ == _NUM_FLOAT:
            return _bytes_to_float(self._read_raw(8))
        if typ == _NUM_FLOATSTR_POS:
            length = self._read_byte()
            return float(self._read_raw(length).decode("ascii"))
        if typ == _NUM_FLOATSTR_NEG:
            length = self._read_byte()
            return -float(self._read_raw(length).decode("ascii"))
        if typ == _BOOL_T:
            return True
        if typ == _BOOL_F:
            return False
        if typ == _STR_8:
            return self._read_string(self._read_int(1))
        if typ == _STR_16:
            return self._read_string(self._read_int(2))
        if typ == _STR_24:
            return self._read_string(self._read_int(3))
        if typ == _TABLE_8:
            return self._read_table(self._read_int(1))
        if typ == _TABLE_16:
            return self._read_table(self._read_int(2))
        if typ == _TABLE_24:
            return self._read_table(self._read_int(3))
        if typ == _ARRAY_8:
            return self._read_array(self._read_int(1))
        if typ == _ARRAY_16:
            return self._read_array(self._read_int(2))
        if typ == _ARRAY_24:
            return self._read_array(self._read_int(3))
        if typ == _MIXED_8:
            arr_count = self._read_int(1)
            map_count = self._read_int(1)
            return self._read_mixed(arr_count, map_count)
        if typ == _MIXED_16:
            arr_count = self._read_int(2)
            map_count = self._read_int(2)
            return self._read_mixed(arr_count, map_count)
        if typ == _MIXED_24:
            arr_count = self._read_int(3)
            map_count = self._read_int(3)
            return self._read_mixed(arr_count, map_count)
        if typ == _STRINGREF_8:
            return self._string_refs[self._read_int(1)]
        if typ == _STRINGREF_16:
            return self._string_refs[self._read_int(2)]
        if typ == _STRINGREF_24:
            return self._string_refs[self._read_int(3)]
        if typ == _TABLEREF_8:
            return self._table_refs[self._read_int(1)]
        if typ == _TABLEREF_16:
            return self._table_refs[self._read_int(2)]
        if typ == _TABLEREF_24:
            return self._table_refs[self._read_int(3)]
        raise ValueError(f"Unknown full type index: {typ}")

    def _read_string(self, length: int) -> str:
        data = self._read_raw(length)
        value = data.decode("utf-8")
        if length > 2:
            self._string_refs[len(self._string_refs) + 1] = value
        return value

    def _read_array(self, count: int) -> List[LuaValue]:
        value: List[LuaValue] = []
        self._table_refs[len(self._table_refs) + 1] = value
        for _ in range(count):
            value.append(self.read())
        return value

    def _read_table(self, count: int) -> Dict[Any, Any]:
        value: Dict[Any, Any] = {}
        self._table_refs[len(self._table_refs) + 1] = value
        for _ in range(count):
            k = self.read()
            v = self.read()
            value[k] = v
        return value

    def _read_mixed(self, array_count: int, map_count: int) -> Dict[Any, Any]:
        value: Dict[Any, Any] = {}
        self._table_refs[len(self._table_refs) + 1] = value
        for i in range(1, array_count + 1):
            value[i] = self.read()
        for _ in range(map_count):
            k = self.read()
            v = self.read()
            value[k] = v
        return value


def serialize(*values: LuaValue) -> bytes:
    """Equivalent to LibSerialize:Serialize(...) - writes a version byte
    then each value back-to-back."""
    writer = _Writer()
    writer._write_byte(SERIALIZATION_VERSION)
    for v in values:
        writer.write(v)
    return writer.to_bytes()


def deserialize(data: bytes) -> List[LuaValue]:
    """Equivalent to LibSerialize:Deserialize(...) - returns the list of
    values that were serialized together."""
    version = data[0]
    if version > DESERIALIZATION_VERSION:
        raise ValueError(f"Unknown serialization version: {version}")
    reader = _Reader(data[1:])
    return reader.read_all()


# ============================================================================
# Section 2: LibDeflate's EncodeForPrint / DecodeForPrint
#
# Ported directly (byte-for-byte) from this project's installed
# Interface/AddOns/WeakAuras/Libs/Archivist/libs/LibDeflate/LibDeflate.lua,
# lines ~3161-3310. A 6-bit-per-character encoding using a 64-character
# alphabet safe for chat/edit boxes (note: NOT standard base64 - this
# alphabet substitutes "(" and ")" for the usual "+" and "/", so stdlib
# base64 functions are not compatible here).
# ============================================================================

_BYTE_TO_6BIT_CHAR = (
    "abcdefghijklmnopqrstuvwxyz"
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    "0123456789()"
)
_6BIT_CHAR_TO_BYTE = {ch: i for i, ch in enumerate(_BYTE_TO_6BIT_CHAR)}


def encode_for_print(data: bytes) -> str:
    """Port of LibDeflate:EncodeForPrint. ~25% size increase; output is
    always one of 64 printable ASCII characters."""
    out = []
    length = len(data)
    i = 0
    while i <= length - 3:
        x1, x2, x3 = data[i], data[i + 1], data[i + 2]
        i += 3
        cache = x1 + x2 * 256 + x3 * 65536
        b1 = cache % 64
        cache //= 64
        b2 = cache % 64
        cache //= 64
        b3 = cache % 64
        b4 = cache // 64
        out.append(_BYTE_TO_6BIT_CHAR[b1])
        out.append(_BYTE_TO_6BIT_CHAR[b2])
        out.append(_BYTE_TO_6BIT_CHAR[b3])
        out.append(_BYTE_TO_6BIT_CHAR[b4])

    cache = 0
    cache_bitlen = 0
    while i < length:
        x = data[i]
        cache += x * (2 ** cache_bitlen)
        cache_bitlen += 8
        i += 1
    while cache_bitlen > 0:
        bit6 = cache % 64
        out.append(_BYTE_TO_6BIT_CHAR[bit6])
        cache //= 64
        cache_bitlen -= 6

    return "".join(out)


def decode_for_print(s: str) -> bytes:
    """Port of LibDeflate:DecodeForPrint. Strips leading/trailing control
    chars and spaces first, matching the original (handy for pasted text)."""
    s = s.strip(" \t\r\n\x00\x01\x02\x03\x04\x05\x06\x07\x08\x0b\x0c"
                "\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a"
                "\x1b\x1c\x1d\x1e\x1f\x7f")
    length = len(s)
    if length == 1:
        raise ValueError("Invalid encoded string (length 1)")

    out = bytearray()
    i = 0
    while i <= length - 4:
        try:
            x1 = _6BIT_CHAR_TO_BYTE[s[i]]
            x2 = _6BIT_CHAR_TO_BYTE[s[i + 1]]
            x3 = _6BIT_CHAR_TO_BYTE[s[i + 2]]
            x4 = _6BIT_CHAR_TO_BYTE[s[i + 3]]
        except KeyError as e:
            raise ValueError(f"Invalid character in encoded string: {e}") from e
        i += 4
        cache = x1 + x2 * 64 + x3 * 4096 + x4 * 262144
        b1 = cache % 256
        cache //= 256
        b2 = cache % 256
        b3 = cache // 256
        out.append(b1)
        out.append(b2)
        out.append(b3)

    cache = 0
    cache_bitlen = 0
    while i < length:
        try:
            x = _6BIT_CHAR_TO_BYTE[s[i]]
        except KeyError as e:
            raise ValueError(f"Invalid character in encoded string: {e}") from e
        cache += x * (2 ** cache_bitlen)
        cache_bitlen += 6
        i += 1

    while cache_bitlen >= 8:
        byte = cache % 256
        out.append(byte)
        cache //= 256
        cache_bitlen -= 8

    return bytes(out)


# ============================================================================
# Section 3: Standard DEFLATE (via stdlib zlib, raw mode)
#
# LibDeflate's compressed output is standard RFC 1951 DEFLATE - no custom
# format. Python's zlib (raw deflate, wbits=-15, i.e. no zlib/gzip header)
# is fully interoperable with it in both directions.
# ============================================================================

def compress_deflate(data: bytes) -> bytes:
    compressor = zlib.compressobj(level=9, wbits=-15)
    return compressor.compress(data) + compressor.flush()


def decompress_deflate(data: bytes) -> bytes:
    decompressor = zlib.decompressobj(wbits=-15)
    return decompressor.decompress(data) + decompressor.flush()


# ============================================================================
# Section 4: Top-level WeakAuras import-string encode/decode
#
# Real WeakAuras Export wraps the aura table in an envelope before
# serializing it - confirmed 2026-07-02 by exporting the real "Test" aura
# in-game and decoding it with this codec: the top-level serialized value
# is {"m": "d", "d": <aura table>, "v": <version int>, "s": <WeakAuras
# version string>}. WeakAuras.Import (Transmission.lua ~line 518) checks
# received.m == "d" and then uses received.d / .v / .c - so
# encode_import_string must produce this same envelope, not just the raw
# aura table on its own.
# ============================================================================

WA_ENCODE_VERSION = 2  # matches "!WA:2!" - LibSerialize + LibDeflate path
AURA_TRANSMIT_VERSION = 1421  # matches DisplayToString's non-group-aura version


def encode_import_string(
    aura_table: LuaTable,
    version: int = AURA_TRANSMIT_VERSION,
    version_string: str = "weakaura_codec (agent-generated)",
) -> str:
    """
    Takes a Python dict/list structure (mirroring a Lua table - e.g. one
    WeakAuras display entry) and produces a WeakAuras import string ready
    to paste into the in-game Import dialog. Wraps it in the same envelope
    real Export produces: {"m": "d", "d": aura_table, "v": version,
    "s": version_string} - confirmed by decoding a real in-game export of
    this project's "Test" aura (see REAL_WEAKAURAS_EXPORT_STRING below).
    version=1421 matches non-group auras; WeakAuras itself switches to
    2000 only when the aura has sub-groups (controlledChildren).
    """
    envelope = {"m": "d", "d": aura_table, "v": version, "s": version_string}
    serialized = serialize(envelope)
    compressed = compress_deflate(serialized)
    encoded = encode_for_print(compressed)
    return f"!WA:{WA_ENCODE_VERSION}!{encoded}"


def decode_import_string_raw(s: str) -> LuaValue:
    """
    Decodes a WeakAuras import string and returns the raw top-level value
    exactly as serialized - usually the {"m", "d", "v", "s"} envelope for
    a single-aura export. Exposed separately from decode_import_string so
    you can inspect real exported data (version, WeakAuras version string,
    a group aura's "c" children list) without assuming the envelope shape.
    """
    s = s.strip()
    if s.startswith("!WA:"):
        end = s.index("!", 4)
        version = int(s[4:end])
        encoded = s[end + 1:]
    elif s.startswith("!"):
        version = 1
        encoded = s[1:]
    else:
        version = 0
        encoded = s

    if version == 0:
        raise NotImplementedError(
            "Version 0 (old LibCompress/AceSerializer format) is not "
            "implemented in this codec - this project's WeakAuras build "
            "(v5.21.2) always encodes new exports as version 2."
        )

    compressed = decode_for_print(encoded)
    serialized = decompress_deflate(compressed)

    if version < 2:
        raise NotImplementedError(
            "Version 1 (AceSerializer format) is not implemented in this "
            "codec - only version 2 (LibSerialize) is, matching what this "
            "project's WeakAuras build actually produces."
        )

    values = deserialize(serialized)
    return values[0] if len(values) == 1 else values


def decode_import_string(s: str) -> LuaTable:
    """
    Reverse of encode_import_string - unwraps the {"m", "d", "v", "s"}
    envelope and returns just the aura table itself (the "d" field), which
    is what most callers actually want. Also accepts real strings copied
    out of WeakAuras' own Export button. Use decode_import_string_raw if
    you need the full envelope instead (version, WeakAuras version string,
    or a group aura's "c" children list).
    """
    envelope = decode_import_string_raw(s)
    if isinstance(envelope, dict) and envelope.get("m") == "d":
        if "c" in envelope:
            raise ValueError(
                "This import string is a GROUP export (it has a top-level "
                "'c' children array alongside 'd') - use "
                "decode_group_import_string() instead, or you will silently "
                "lose the child auras."
            )
        return envelope["d"]
    raise ValueError(
        f"Decoded data is not a single-aura ('m'=='d') export envelope: "
        f"{envelope!r}"
    )


# ============================================================================
# Section 5: Group-aura encode/decode (flat groups only)
#
# A WeakAuras group/dynamic-group export uses a different envelope shape
# than a single aura: the child auras live in a sibling top-level "c"
# array, not nested inside "d". Confirmed both by reading
# Transmission.lua's Private.DisplayToString/WeakAuras.Import directly,
# and by decoding a real group exported from this project's own client
# (2026-07-02, "Example_group", 4 icon children) - see
# REAL_GROUP_EXPORT_STRING below.
#
# Version matters here. WeakAuras.Import branches on it:
#   - version < 2000 (a FLAT group - one parent, plain leaf children, no
#     group nested inside a group): Import completely ignores whatever
#     "controlledChildren"/"parent" fields you hand it and rebuilds them
#     itself from the "c" list, in order - confirmed by the real capture,
#     where the transmitted "d" has controlledChildren stripped entirely
#     (CompressDisplay removes it before sending, since Import derives it
#     fresh from "c" anyway) and none of the 4 children have a "parent"
#     field set (Import assigns child.parent = d.id itself). This makes a
#     flat group easy and safe to hand-build: get the child ids right and
#     the rest is reconstructed for you.
#   - version >= 2000 (real nesting - a group containing another group):
#     Import trusts whatever topology is already baked into the data
#     instead of reconstructing it, which means every nested group's own
#     controlledChildren/parent must already be fully and correctly set
#     by whoever builds the export. NOT IMPLEMENTED here - encoding a
#     correct nested (multi-level) group export is meaningfully riskier
#     to get right without live validation, and hasn't been attempted.
#     Build nested layouts by hand-grouping a flat, codec-built group
#     in-game instead, for now.
# ============================================================================

GROUP_TRANSMIT_VERSION = 1421  # flat group only - see note above

# WeakAuras' own alphabet for GenerateUniqueID (Transmission.lua) - a-z,
# A-Z, 0-9, "(", ")", in exactly this order (0-63). Confirmed by reading
# Transmission.lua's `bytetoB64` table directly, not assumed.
_UID_ALPHABET = (
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()"
)


def generate_unique_id() -> str:
    """
    Python port of WeakAuras' own GenerateUniqueID() (Transmission.lua):
    an 11-character random string from _UID_ALPHABET.

    WHY THIS MATTERS (2026-07-02, live-tested the hard way): `uid`, not
    `id`, is WeakAuras' real identity key for an aura - `id` is just the
    display name and can even collide/get auto-renamed. A real incident:
    building two new children for Template_shadow.py v0.9 by copying an
    existing child's full field dict (to avoid missing required region
    fields) also copied that child's `uid` verbatim, without generating
    fresh ones. The result: 3 auras (the original, plus both copies)
    silently sharing one uid. WeakAuras' import/update logic treats a
    shared uid as "the same aura" - one of the three effectively
    vanished in-game, and the other two rendered at conflicting/
    overlapping positions. Any time a new child is built by cloning an
    existing one's dict, call this and overwrite "uid" explicitly -
    never carry a source child's uid into a copy.
    """
    return "".join(random.choice(_UID_ALPHABET) for _ in range(11))


def encode_group_import_string(
    group_table: LuaTable,
    children_tables: List[LuaTable],
    version: int = GROUP_TRANSMIT_VERSION,
    version_string: str = "weakaura_codec (agent-generated)",
) -> str:
    """
    Builds an import string for a WeakAuras group (regionType "group" or
    "dynamicgroup") with a FLAT list of leaf children - no group nested
    inside another group. See the module-level note above for why nesting
    isn't supported here.

    group_table: the group's own aura table (regionType="group", plus the
        usual anchor/border/frame fields - see EXAMPLE_GROUP_AURA for a
        real, working template). Its "controlledChildren" is ALWAYS
        overwritten here from children_tables' ids, regardless of
        whatever was already on group_table - see the correction below
        for why this can't be left as "fill in only if absent".
    children_tables: the leaf aura tables, in the order you want them to
        end up in the group. Each needs a unique "id" (and should have a
        unique "uid" - see weakaura_codec.py's own uid generation
        convention, e.g. GenerateUniqueID-style random base64 strings, if
        you're not otherwise assigning one). Their "parent" field does
        NOT need to be set - WeakAuras sets it automatically on import.

    CORRECTION (2026-07-02, live-tested): this docstring used to claim
    controlledChildren "isn't load-bearing" on the reasoning that
    WeakAuras.Import (Transmission.lua) rebuilds it from the "c" list on
    version < 2000 - true, but incomplete. That's the core import
    engine's behavior for a genuinely FRESH import. WeakAurasOptions'
    own update/merge flow (OptionsFrames/Update.lua) is a separate code
    path used whenever the pasted string looks like an update to
    something already present, and its BuildUidMap function (line ~349)
    reads group.controlledChildren DIRECTLY to build its structural map
    - entries in "c" that aren't listed there are invisible to it. A
    real incident: Template_shadow.py v0.9 added 2 new children to an
    existing group's "c" array by starting from a previously-decoded
    group table (which already had a "controlledChildren" of the OLD
    24 ids) - the old "only fill in if absent" logic then left that
    stale list untouched, so "c" had 26 entries but controlledChildren
    only claimed 24. Pasting that in-game threw `attempt to index local
    'pendingPickData' (a nil value)` in Update.lua:1867 - confirmed by
    reading that file directly: the structural mismatch pushed the
    update-diff logic into a code path that never assigns
    pendingPickData, which a few lines later gets indexed unconditionally.
    Fix: always regenerate controlledChildren from the actual final
    children_tables being encoded, unconditionally - never trust one
    carried over from a decoded prior version, since the whole point of
    this field (for the update-merge flow, if not the fresh-import
    engine) is that it has to match "c" exactly.
    """
    group_copy = dict(group_table)
    group_copy["controlledChildren"] = [child["id"] for child in children_tables]

    envelope = {
        "m": "d",
        "d": group_copy,
        "c": [dict(child) for child in children_tables],
        "v": version,
        "s": version_string,
    }
    serialized = serialize(envelope)
    compressed = compress_deflate(serialized)
    encoded = encode_for_print(compressed)
    return f"!WA:{WA_ENCODE_VERSION}!{encoded}"


def decode_group_import_string(s: str) -> Tuple[LuaTable, List[LuaTable]]:
    """
    Reverse of encode_group_import_string. Returns (group_table,
    children_tables) - the group's own table and the flat list of its
    children, exactly as encoded (or as a real WeakAuras group export
    produced them). Works for any version (1421 or 2000+) since decoding
    doesn't require reconstructing controlledChildren/parent - it just
    reports what's literally present in the string. (encode_group_import_
    string itself only ever produces version 1421 / flat-group output,
    but this decoder can still read a real, nested version-2000 export
    you got from elsewhere - you'll just see its topology exactly as
    transmitted, parent fields and all.)
    """
    envelope = decode_import_string_raw(s)
    if not (isinstance(envelope, dict) and envelope.get("m") == "d"):
        raise ValueError(f"Decoded data is not a 'm'=='d' export envelope: {envelope!r}")
    if "c" not in envelope:
        raise ValueError(
            "This import string has no top-level 'c' children array - it's "
            "a single-aura export, not a group. Use decode_import_string() "
            "instead."
        )
    return envelope["d"], envelope["c"]


# ============================================================================
# Self-tests
# ============================================================================

# A real aura pulled from this project's actual in-game debug-table export
# (2026-07-02, character Weakauratest / Area 52 - Free-Pick, aura "Test") -
# transcribed exactly from WeakAuras' own "Export debug table" output, not
# hand-approximated. This is the strongest test fixture available: real
# addon output, not synthetic data.
EXAMPLE_TEST_AURA = {
    "actions": {"finish": {}, "init": {}, "start": {}},
    "adjustedMax": "",
    "adjustedMin": "",
    "alpha": 1,
    "anchorFrameType": "SCREEN",
    "anchorPoint": "CENTER",
    "animation": {
        "finish": {"duration_type": "seconds", "easeStrength": 3, "easeType": "none", "type": "none"},
        "main": {"duration_type": "seconds", "easeStrength": 3, "easeType": "none", "type": "none"},
        "start": {"duration_type": "seconds", "easeStrength": 3, "easeType": "none", "type": "none"},
    },
    "authorOptions": {},
    "color": [1, 1, 1, 1],
    "conditions": {},
    "config": {},
    "cooldown": True,
    "cooldownEdge": False,
    "desaturate": False,
    "displayIcon": "",
    "frameStrata": 1,
    "height": 64,
    "icon": True,
    "iconSource": -1,
    "id": "Test",
    "information": {},
    "internalVersion": 86,
    "inverse": False,
    "keepAspectRatio": False,
    "load": {
        "class": {"multi": {}},
        "size": {"multi": {}},
        "spec": {"multi": {}},
    },
    "progressSource": [-1, ""],
    "regionType": "icon",
    "selfPoint": "CENTER",
    "subRegions": [
        {"type": "subbackground"},
        {
            "anchorXOffset": 0,
            "anchorYOffset": 0,
            "anchor_point": "INNER_BOTTOMRIGHT",
            "text_automaticWidth": "Auto",
            "text_color": [1, 1, 1, 1],
            "text_fixedWidth": 64,
            "text_font": "Friz Quadrata TT",
            "text_fontSize": 12,
            "text_fontType": "OUTLINE",
            "text_justify": "CENTER",
            "text_selfPoint": "AUTO",
            "text_shadowColor": [0, 0, 0, 1],
            "text_shadowXOffset": 0,
            "text_shadowYOffset": 0,
            "text_text": "Testest",
            "text_text_format_s_format": "none",
            "text_visible": True,
            "text_wordWrap": "WordWrap",
            "type": "subtext",
        },
        {
            "glow": False,
            "glowBorder": False,
            "glowColor": [1, 1, 1, 1],
            "glowDuration": 1,
            "glowFrequency": 0.25,
            "glowLength": 10,
            "glowLines": 8,
            "glowScale": 1,
            "glowThickness": 1,
            "glowType": "buttonOverlay",
            "glowXOffset": 0,
            "glowYOffset": 0,
            "type": "subglow",
            "useGlowColor": False,
        },
    ],
    "triggers": {
        1: {
            "trigger": {
                "debuffType": "HELPFUL",
                "event": "Health",
                "names": [],
                "spellIds": [],
                "subeventPrefix": "SPELL",
                "subeventSuffix": "_CAST_START",
                "type": "aura2",
                "unit": "player",
            },
            "untrigger": {},
        },
        "activeTriggerMode": -10,
    },
    "uid": "uMVM9ynrBIj",
    "useAdjustededMax": False,
    "useAdjustededMin": False,
    "width": 64,
    "xOffset": 0,
    "yOffset": 0,
    "zoom": 0,
}

# The real WeakAuras import string produced by exporting that same "Test"
# aura in-game (2026-07-02) - captured directly from WeakAuras' own Export
# button, not generated by this codec. Used below to validate
# decode_import_string against genuine addon output, not just this
# codec's own round-trip.
REAL_WEAKAURAS_EXPORT_STRING = (
    "!WA:2!DrvZUnUnq444cKwDiyJx0aSalqD3wKd9qqRb2a0EZY1EJl8pPYk)uGc4qjosIBKjvjPCSZT1"
    "hk2Z(rWNBVOhb)eiy0NGCOpa5jOKuYE7U(GbNVz0WVzMVHv6uBsnCn87pzfXNrhXs5(Wl3ZXNfZ4)s"
    "v1Vme(TPcjG7JMT)hmi095ZhgeiazLme1pIXVGrOsVwTh422zTpJfJz3tBJdHiBDUVDHKtcdbU4Wt4"
    "Lh)ZvyWlniWDEcWpVDVl6CzpBPYWbLYrnwisG44UyH1JIupykqLJurtMLnUvZrUJh520X1oLsKEjXO"
    "5aFxyxWbvyoJUODVEogeVZbuSmYHIMacRLP0skyLCeYxsMcUf29zy4V27jvPaCkk(kfFjm6F)ycNfY"
    "bHOOf9DVCV9xIOKjiPY7zocjIl7KFOnLrH1asaJKCGgkJoydwvk6OgRlmUau9cSyHogDzNx3EcIqvF"
    "BE98V(G8xL)n5FBEDVacLiI(uyv)sGK6ecrRufRdeQYS4Noo)WnktpK)DHCwkf)(NNutcZKJfri1C4"
    "MYrvYlmGM)cyCf9hlkpKxF5oFCxqnLfYKN9)YrlJMOsLkvFSafIdmZC7Mx6om55gquQKPBk(xtWYi7"
    "MkZNkUnYmaBaF3Mc9YVvYP1g)ADfjyE(b5hYvvIgBLXXhKIllPnvXRoCYd1)1uew1kq1DD)OQDBM3y"
    "WUNXXxZrjlUU8qXfoLiiEXWTRlyZ4eDPKCu3bdA7m2EOR7W(oDFZ5UB2DRJipaVOK838rxH2Rrdp8s"
    "3EDh0(F3egZUVdh(JuG6p)Ip77pTXRlkmTJ16)(5szr1fAl9xVXlvkz0HtbUsnVsd3ZOH(Ym95Tv1s"
    "TrRDDL1Pc4nBrImrULC2AJit8J8rXqvdTCJi(3rvs5Qgp9iQZhzUnBvdc4rErajms(o7ygcFMTAj0)"
    "yNjPXsILJFmsioo)klBHQBOpK8mfbAw(UG5zIOpfIqJwXnkvJI)lCU3Od4Zk55ITVwCBgMi0RYDvlj"
    "7B)aJnPIdkojcvDLK5pTyz8ZN(7VIGT1AupvCbKqRSaUAVwTZPudvFQye1rdPVqVrTCA3EWgL2ubpm"
    "r31fwnsj4S0(x1)hNt52DFlNq15hIE6oasAQRAPJEcfX1pqO(KZY)klB1AP0k)eRv61ysrQYi0IDi"
    "LL1YD7f5hutK96tB8dN2OUnir1M(p38F)"
)


# A real FLAT GROUP pulled from this project's own client (2026-07-02,
# character Weakauratest / Area 52 - Free-Pick): a group named
# "Example_group" containing 4 plain icon children (Test, Test 2, Test 3,
# Test 4). Transcribed exactly from WeakAuras' own debug-table dump of the
# group's own display entry - note "controlledChildren" IS present here
# (this is the live SavedVariables shape), but real Export strips it
# before transmission since Import derives it fresh from the "c" list -
# see the self-test below, which confirms the decoded transmitted "d"
# lacks this field even though this source-of-truth dict has it.
EXAMPLE_GROUP_AURA = {
    "actions": {"finish": {}, "init": {}, "start": {}},
    "alpha": 1,
    "anchorFrameType": "SCREEN",
    "anchorPoint": "CENTER",
    "animation": {
        "finish": {"duration_type": "seconds", "easeStrength": 3, "easeType": "none", "type": "none"},
        "main": {"duration_type": "seconds", "easeStrength": 3, "easeType": "none", "type": "none"},
        "start": {"duration_type": "seconds", "easeStrength": 3, "easeType": "none", "type": "none"},
    },
    "authorOptions": {},
    "backdropColor": [1, 1, 1, 0.5],
    "border": False,
    "borderBackdrop": "Blizzard Tooltip",
    "borderColor": [0, 0, 0, 1],
    "borderEdge": "Square Full White",
    "borderInset": 1,
    "borderOffset": 4,
    "borderSize": 2,
    "conditions": {},
    "config": {},
    "controlledChildren": ["Test", "Test 2", "Test 3", "Test 4"],
    "frameStrata": 1,
    "id": "Example_group",
    "information": {},
    "internalVersion": 86,
    "load": {
        "class": {"multi": {}},
        "size": {"multi": {}},
        "spec": {"multi": {}},
    },
    "regionType": "group",
    "scale": 1,
    "selfPoint": "CENTER",
    "sharedFrameLevel": True,
    "subRegions": {},
    "triggers": {
        1: {
            "trigger": {
                "debuffType": "HELPFUL",
                "event": "Health",
                "names": [],
                "spellIds": [],
                "subeventPrefix": "SPELL",
                "subeventSuffix": "_CAST_START",
                "type": "aura2",
                "unit": "player",
            },
            "untrigger": {},
        },
    },
    "uid": "q46MpIIUDqR",
    "xOffset": 0,
    "yOffset": 0,
}

# The real import string exported for that same group (captured directly
# from WeakAuras' Export button, not generated by this codec).
REAL_GROUP_EXPORT_STRING = (
    "!WA:2!Lxv3sTT1wymQPjr0MAmKmnNsBCt7HtAAktcbOnPnnJfyhCQngKf)K2CoMTK22AhKLeBjbgYmN"
    "ZbUidxZJGVU5g)iWtWA80NaUipa8e01wsgsGMzsVP30B0S3R9FR13plLAPm(DMCSXVZyJNvHgqY0mJz"
    "gZ9UwxDIXAMCxVPDTD5pwssAEPBp2KhQ7YnPCLKf9sRyZ2EBc3mRMRRDaZRDGRXguUpZ15cB80UKWal"
    "xEfVaCUV8(ehwtIy8uQ(beEqHdOeFA1ao1PrG15vc2YJQ446q7AgYJ2ynriUp1W1X0FxXU1WaWaknjm"
    "NcWfppiddaFa8HWLGb0RZCy(wNjCCsBX3Qs96(0GuDiogyAnVlZjqF68ZPLxTD8EQY2MEoV0(weo1Sa"
    "N0KwIUb1E1oXlhdgPsLsI3k5UsoyEZguVbRUEiEWSfcTTZUSflGYjgrL(uWfKH0Yky(fiVBaN1Obwv)"
    "Jr5jdFrBtQEy96IIJpB(sZxyXsGSkbrHX313JABx00x(q)qDmDCcQIBL1QtTPZvvRwvTCQAkH4nR7z"
    "t2IYvDW82xwnAR6Zsj2bwhF055u8OQvNpFPs7h6K8(YT50gyIkEF1gC3qVdIRR4Q8IQ(geBQ0((u76r"
    "Wgm81zMDZ3I00ZMwl6ehHHPChI9sX8)lvj2EwePJIr7i0uC)6vNwnF(5uSDjMtPGfNXvuBgIIhzvdBI"
    "V)vG7jR4JeHyGos81znK7uxCCuPqcisTXIrnkF9LhpKz2z9jMQSxXIloZ6QTfkfwSERdZPUlpwXjNqH"
    "fDW6rkJXJ3B02mCVvDd5g0r6RdX8zH(buZYmN(HmPGHGHpWaf1MUB6iyxl4tIyXreej8PxAu4ZEbCni"
    "lQ0(C46YWxaFjCt4RH)LmCd4RG)jmkClzVbfcGnOAXWCzxt6V2hC3xE0AuQxorThOkspl484Lx4yvlk"
    "GrHl8rNjs6thbfo(KaHBbZWF8(xbK7IOJW9kifhZ9gYltaTvqnutJLYkjYwVRgfm6tmgvZpzamW(hVg"
    "xJIyIFGx6x7ooXfCyC0EIcLClQvXBOOGOZ3vG8glZmdSuYHtpk(1yTOMrb3PBSY4jj50brRlybw9TGH"
    "bzowjIyTJwWOxNiP9tsBhmVkWzBNDHqIPqzKvt7nQ2E3C3OyBIcGL5eVDxozq3JVNiFxLf1kvCU8heN"
    "v18eLK3GfNBU8Q1uQOPvPSAXhnR2jNs0T4QjfXkVrrSbZNPBtx9vDBy7UzboD9qQJXwZ)E3ESXNureZ"
    "6aX3zsAZjTVyw1itwBXWsrDeVChX4Evr0EoUFS0bH(0h1lIvmAj2r0z6Lo7kMiQUU6HbbUovWMZytIO"
    "0sZIzSMd13p(1lXWXdg96kXnm1TOSgwb7aF7uW9fUr47I((9IVEPX3pxIPbTnKwwNoeZXc(gfHldUdm"
    "S6jeiOi3XK5lAxvexTFysyQtmGKw9RSTRBZuWd7ewEPY3BlhUsXNbNd)Jc21rrOjHjKGhiPUzKoc(4u"
    "WpiZzoI)8G2GnxfEFziN8U98VREOh3Tbhl1y7(nhPV(3BuyMr6tSXT7hY3ZYdf65Zthz1F7(CHbxy0r"
    ")(TKHhfzRHz7zKfguHr9eJ8PIK(mrkM4FHhV3qWpLckHXkdZbvISAW8WcGkuf02bwmfSKWFaldReJNp"
    "b(z4xsbpf(3W)bQbRceq)QGrkWC1xb0yzhu3cSTaljGDz4zPG1IpAdj8IAcRlbUGh4Kc4dc(wWBH1Hq"
    "lydKvHnfG(ocGe()RIyTa0FUGg6rt6cAk74W)DhbxHemYxiHoZe5YXwSyRzT1H)Nf0koj2QFusiejjS"
    "ss4tZm4B8o249meYF(oR)Lqii6FAcb5ibHGmHGqqE5DLqq8frqbqIWjQRFUWaT463O0kluU8Ylu6nzM"
    "7gXji1GeumpIChYiiTISjYPV2V7syfCP3D64V9(Jyq91BMeBus02)bMLjeCXdK6rmpStaTWJitpUbBY"
    "gcQz7iA9yVsMn(Tv(9p"
)


# A real single icon aura pasted directly by Battlewrath (2026-07-04),
# named "Multi-condition example" - captured specifically to settle what
# the "conditions" field actually looks like, since phase-3's glow-source
# mechanism (see template_filler.py) had been built on an UNVERIFIED guess
# at that shape. Decoding this corrected two wrong assumptions at once:
#
# 1. "conditions" is a LIST of {"changes": [...], "check": {...}} objects,
#    NOT a dict keyed by numbered condition-index strings ("1", "2", ...)
#    the way "triggers" is keyed by trigger-index. Multiple conditions can
#    coexist and all target the same property.
# 2. A "changes" entry's "property" is "sub.N.<field>" where N is the
#    target subRegion's 1-based POSITION in the aura's own "subRegions"
#    array at the time - not a fixed index. This aura's subRegions are
#    [subbackground, subtext, subglow], so the glow property is "sub.3.glow"
#    (position 3), not "sub.2.glow" - template_filler.py's fixed "sub.2..."
#    guess was wrong for any template whose subRegions array has more than
#    2 entries (e.g. one with a stack_counter overlay added), and has been
#    corrected to compute this position dynamically.
#
# The four real "check" objects captured here (all targeting the SAME
# "sub.3.glow" property - this is the "multiple glow conditions, of
# different types" Battlewrath described) are the first confirmed
# evidence of what a "check" can actually contain:
#   - {"trigger": -1, "variable": "alwaystrue"} - a global/pseudo-trigger
#     check (trigger index -1, not tied to any of the aura's own numbered
#     triggers) that's unconditionally true - a default/fallback rule.
#   - {"trigger": -1, "variable": "attackabletarget", "value": 1} - another
#     global check, this time on actual target state (do you have a valid,
#     attackable target), still trigger -1.
#   - {"trigger": 1, "variable": "show", "value": 1} - checks trigger 1's
#     (this aura's own aura2 trigger) OWN "show" state - i.e. "is this
#     aura's primary trigger currently active."
#   - {"trigger": 1, "variable": "duration", "op": "=="} - compares trigger
#     1's "duration" variable using an explicit "op" field.
#
# IMPORTANT SCOPE NOTE: this real example only has ONE trigger (trigger 1)
# - its glow conditions react to THAT SAME trigger's own derived state
# (show/duration) or to global checks, not to a genuinely second,
# independent trigger. It does NOT confirm or deny whether a real second
# trigger (triggers[2], for an unrelated ability's own proc/buff - the
# actual glow-source use case template_filler.py builds) works the same
# way - that specific case is still unverified pending either a real
# captured two-trigger example or a live test. What this DOES confirm,
# and what template_filler.py has been corrected to match, is the overall
# conditions-list shape and the dynamic sub-index addressing.
REAL_MULTI_CONDITION_EXAMPLE_STRING = (
    "!WA:2!LrvtUTTruyROcKwvadBfuxKaVWWiXaTa1O1bXlkqwi6kf7azjxk6yN0aipK8jotn1mmZmu)4Dr"
    "lkYADe062n6iOtaHqpbErpa(e03musPjvleF))73BkuRC3YHLd)WtMWce8wIuzaS9AYbn70rb6ctjH)E"
    "QsdHNsgCVpYW43toCLj8aQqEMGX1(hvTHxv3zbcrCOOpVAyeqDmr(QrAjlkcKQ13tUG8pMec(PD64nmb"
    "KhxT(z1oVUJgzCjPsYbJujqC8jHQs3Qs9HEax3cTMnyA7JQ0YRDlVkUEoPCM2pjMmeKUCsxqvY1AQ)Xa"
    "jwtx56zsaD1T1zvRxFCkFrjukztsGM1d8Y5pvec)5A3HTci5K4xH1ltW)RBtKIijOu5dOVF71U3yfe3X"
    "20z3h7dfrJ1SgOtWe6crOxQFERS1NJS(KGRJKIuE4hEqsznmq3wrj485YfJWKhAfA)RJq2LGgSGWHl4W"
    "4vQ39jQKn(pr4irSq(Ycfku82CPllkNkN71m5bwHKuTadfl4cwOM6ubzVlpxSbqOv47NNVfF9IkAMvVz"
    "BZ6mm7(zRlX(WiBIvrGnTfXFJxu0CDYg1KSB25xtjH4GGSJN3N0RlJ8CRS(cz4fssYOlwqKNWEmfZpgU"
    "AwE10oX0kjBEsJgvDB700ZR5PUN8IJ9MVkRTy3apCrXF5NKcJwlYQ55E1pPr1)zEuSOFnj8UuGhm8SV4"
    "h3)GNL3ygfZm)9lMDiU6koYWz8EUFQwl4n7bseJnXiUoWJ00VzQHEzxn2WC0QPYSuf8ILsOwlxvC2itz"
    "bxZr8urRJTciXqrhdj1kOodvUPnBo4acKuFkWIO637eliHh6GNgbB52nnwZk5getuQTYAuYrHtddrYgy"
    "buzX1Q94L(5IyC6ePfNAAZSVsAUdqq7HUknrQl53HXzkAjh8JU0ycN11oAom78AZaIcAPL2bbcoYE88W"
    "ftU2M7xPcWt(q1iJD2W)yNUegVw2RTwN9MSFl7T43x95sMY454EmuLCUri6wWLeNqjfNOfb9Yph)YEVD"
    "xwyY3EQP9)btMyg73bgq6MedU9Ti6PDK4ZbyvIGXI3LJqQzezki)wh5wTAJdszHtpV739MlEA1auNpgS"
    "oSOssg3KlG6(rK(C8mcdrZe7yQ0Kv5v9Y9CdOqW17L91BV2OEejJGG4jK4(KHkTmfKbucpcupARr4dj4"
    "8rp08mX(pDFZgEVmCOIEMjs2GO14Jfg3XLqeOD7rItHIzV7rBLjZu5Mwmt4OOI(zP)FfJwUi2vKS7ZF("
    "s9Jw(I8v3Dnajvm4hTRXqAz10NT)b)0(hSJdM0Y9(7l)3)"
)

# Decoded shape of REAL_MULTI_CONDITION_EXAMPLE_STRING's "conditions" field
# (transcribed exactly from decode_import_string() output, 2026-07-04) -
# kept here as a reference fixture, same spirit as EXAMPLE_TEST_AURA above.
REAL_MULTI_CONDITION_CONDITIONS = [
    {"changes": [{"property": "sub.3.glow"}], "check": {"trigger": -1, "variable": "alwaystrue"}},
    {"changes": [{"property": "sub.3.glow"}], "check": {"trigger": -1, "variable": "attackabletarget", "value": 1}},
    {"changes": [{"property": "sub.3.glow"}], "check": {"trigger": 1, "variable": "show", "value": 1}},
    {"changes": [{"property": "sub.3.glow"}], "check": {"trigger": 1, "variable": "duration", "op": "=="}},
]


def _clone_leaf_aura(base: LuaTable, new_id: str, new_uid: str, label: str) -> LuaTable:
    """
    Deep-enough copy of a leaf aura table (like EXAMPLE_TEST_AURA) with a
    new id/uid/display label, for building synthetic multi-child group
    test fixtures without retyping the whole aura shape 3 more times.
    """
    import copy as _copy

    clone = _copy.deepcopy(base)
    clone["id"] = new_id
    clone["uid"] = new_uid
    for sub in clone.get("subRegions", []):
        if sub.get("type") == "subtext":
            sub["text_text"] = label
    return clone


def _normalize_for_comparison(value: LuaValue) -> LuaValue:
    """
    Lua tables don't distinguish empty-array from empty-map - {} is both,
    simultaneously and losslessly, as far as Lua/LibSerialize is concerned.
    This codec has to pick a Python representation (list) for an empty
    table on decode, which means a round-trip test comparing against a
    dict literal {} in the original input would falsely report a mismatch.
    This normalizes both empty dicts and empty lists to the same sentinel
    purely for test comparison purposes - it does not affect encoding or
    decoding behavior, only how the self-tests judge equality.
    """
    if isinstance(value, dict):
        if not value:
            return []
        return {k: _normalize_for_comparison(v) for k, v in value.items()}
    if isinstance(value, list):
        return [_normalize_for_comparison(v) for v in value]
    return value


def _assert_round_trip(value: LuaValue, label: str) -> None:
    data = serialize(value)
    [recovered] = deserialize(data)
    if _normalize_for_comparison(recovered) != _normalize_for_comparison(value):
        raise AssertionError(f"Round-trip mismatch for {label}: {value!r} != {recovered!r}")
    print(f"  OK  serialize/deserialize round-trip: {label}")


def _assert_full_pipeline_round_trip(value: LuaTable, label: str) -> str:
    imported = encode_import_string(value)
    recovered = decode_import_string(imported)
    if _normalize_for_comparison(recovered) != _normalize_for_comparison(value):
        raise AssertionError(f"Full pipeline round-trip mismatch for {label}")
    print(f"  OK  full import-string round-trip: {label} ({len(imported)} chars)")
    return imported


def _self_test() -> None:
    print("Running weakaura_codec self-tests (internal round-trip only -")
    print("this does NOT confirm the real WeakAuras addon will accept the")
    print("output - see the WARNING in this file's docstring).\n")

    print("LibSerialize layer:")
    _assert_round_trip(None, "nil")
    _assert_round_trip(True, "true")
    _assert_round_trip(False, "false")
    _assert_round_trip(0, "small int 0")
    _assert_round_trip(127, "small int boundary 127")
    _assert_round_trip(128, "12-bit int boundary 128")
    _assert_round_trip(-1, "negative 12-bit int -1")
    _assert_round_trip(4095, "12-bit int boundary 4095")
    _assert_round_trip(4096, "full-width int boundary 4096")
    _assert_round_trip(-70000, "negative 24-bit-range int")
    _assert_round_trip(2**40, "large int needing 7-byte width")
    _assert_round_trip(0.5, "simple float 0.5")
    _assert_round_trip(3.14159265358979, "pi-ish float (long decimal)")
    _assert_round_trip(-2.5, "negative float")
    _assert_round_trip("", "empty string")
    _assert_round_trip("hi", "short string (<=2 bytes, no ref)")
    _assert_round_trip("hello world", "medium string (ref-eligible)")
    _assert_round_trip("x" * 300, "long string (24-bit length path)")
    _assert_round_trip([1, 2, 3], "pure array")
    _assert_round_trip({"a": 1, "b": 2}, "pure map")
    _assert_round_trip({1: "x", 2: "y", "extra": True}, "mixed table")
    _assert_round_trip(list(range(20)), "array >=16 (full-type-byte path)")
    _assert_round_trip({f"k{i}": i for i in range(20)}, "map >=16 (full-type-byte path)")
    repeated = ["duplicate-me"] * 5
    _assert_round_trip(repeated, "repeated string (exercises string refs)")

    print("\nFull pipeline (LibSerialize -> DEFLATE -> EncodeForPrint), envelope-aware:")
    _assert_full_pipeline_round_trip({"a": 1, "b": [1, 2, 3], "c": None}, "small nested table")
    example_import_string = _assert_full_pipeline_round_trip(
        EXAMPLE_TEST_AURA, "real 'Test' aura data (this codec's own encoder)"
    )

    print("\nValidation against a REAL in-game WeakAuras export (not generated by")
    print("this codec - captured 2026-07-02 via the addon's own Export button):")
    real_decoded = decode_import_string(REAL_WEAKAURAS_EXPORT_STRING)
    expected = dict(EXAMPLE_TEST_AURA)
    expected["tocversion"] = 30300  # added by WeakAuras' own CompressDisplay on export
    if _normalize_for_comparison(real_decoded) != _normalize_for_comparison(expected):
        raise AssertionError(
            "Decoding the REAL WeakAuras export did not match the expected "
            "debug-table transcription - see EXAMPLE_TEST_AURA vs real_decoded."
        )
    print("  OK  decode_import_string(REAL_WEAKAURAS_EXPORT_STRING) matches the")
    print("      real debug-table dump exactly (field-for-field, including nested")
    print("      subRegions, triggers, and the tocversion field WeakAuras itself adds)")

    real_envelope = decode_import_string_raw(REAL_WEAKAURAS_EXPORT_STRING)
    assert real_envelope["m"] == "d", "Real export envelope should have m=='d'"
    assert real_envelope["v"] == 1421, "Real export envelope should have v==1421 (non-group aura)"
    print(f"  OK  real export envelope: m={real_envelope['m']!r}, v={real_envelope['v']!r}, s={real_envelope['s']!r}")

    print("\nGroup-aura path, validated against a REAL in-game group export")
    print("('Example_group', 4 icon children - captured 2026-07-02):")
    real_group, real_children = decode_group_import_string(REAL_GROUP_EXPORT_STRING)
    assert real_group["id"] == "Example_group"
    assert real_group["regionType"] == "group"
    assert "controlledChildren" not in real_group, (
        "Real transmitted group data should NOT include controlledChildren - "
        "WeakAuras strips it before sending and rebuilds it from 'c' on import"
    )
    print("  OK  decode_group_import_string(REAL_GROUP_EXPORT_STRING): group 'd'")
    print("      matches expected shape (id, regionType, controlledChildren")
    print("      correctly absent from the transmitted data)")

    expected_child_ids = ["Test", "Test 2", "Test 3", "Test 4"]
    actual_child_ids = [child["id"] for child in real_children]
    if actual_child_ids != expected_child_ids:
        raise AssertionError(f"Group children ids mismatch: {actual_child_ids}")
    for child in real_children:
        assert "parent" not in child, (
            f"Real transmitted child {child['id']!r} should NOT have 'parent' set - "
            "WeakAuras assigns it on import, not before"
        )
    print(f"  OK  4 children present in order, ids={actual_child_ids},")
    print("      none carrying a 'parent' field (WeakAuras assigns it on import)")

    expected_first_child = dict(EXAMPLE_TEST_AURA)
    expected_first_child["tocversion"] = 30300
    if _normalize_for_comparison(real_children[0]) != _normalize_for_comparison(expected_first_child):
        raise AssertionError(
            "First child of the real group export does not match "
            "EXAMPLE_TEST_AURA - expected the same 'Test' aura content."
        )
    print("  OK  first child of the group is field-for-field identical to")
    print("      EXAMPLE_TEST_AURA (this is literally the same 'Test' aura,")
    print("      now captured as a group member instead of standalone)")

    print("\nFull group pipeline round-trip, using THIS codec's own encoder:")
    group_children = [
        EXAMPLE_TEST_AURA,
        _clone_leaf_aura(EXAMPLE_TEST_AURA, "Test 2", "syntheticUid02", "Test2"),
        _clone_leaf_aura(EXAMPLE_TEST_AURA, "Test 3", "syntheticUid03", "Test3"),
        _clone_leaf_aura(EXAMPLE_TEST_AURA, "Test 4", "syntheticUid04", "Test4"),
    ]
    example_group_import_string = encode_group_import_string(EXAMPLE_GROUP_AURA, group_children)
    round_trip_group, round_trip_children = decode_group_import_string(example_group_import_string)
    if [c["id"] for c in round_trip_children] != [c["id"] for c in group_children]:
        raise AssertionError("Group encode/decode round-trip lost or reordered children")
    if _normalize_for_comparison(round_trip_children[0]) != _normalize_for_comparison(group_children[0]):
        raise AssertionError("Group encode/decode round-trip corrupted child 0's content")
    print(f"  OK  full group import-string round-trip: 1 group + {len(group_children)}")
    print(f"      children ({len(example_group_import_string)} chars)")

    print("\nAll self-tests passed, including validation against real addon output")
    print("(both single-aura and group export/import paths).\n")
    print("Generated import string for EXAMPLE_TEST_AURA, using THIS codec's own")
    print("encoder (paste into WeakAuras' in-game Import dialog as the next real,")
    print("live acceptance test - does the game accept an agent-generated string,")
    print("not just a decoded one):\n")
    print(example_import_string)
    print("\nGenerated GROUP import string (1 group + 4 icon children), using THIS")
    print("codec's own encode_group_import_string - the next live acceptance test")
    print("for the group path specifically:\n")
    print(example_group_import_string)


if __name__ == "__main__":
    _self_test()
