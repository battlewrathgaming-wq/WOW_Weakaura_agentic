"""
lua_table.py - a small, dependency-free parser for the Lua-literal subset
that WoW writes into SavedVariables files (WeakAuras.lua etc.).

SavedVariables is DATA, not code: `Global = { ... }` statements whose values
are strings / numbers / booleans / nil / nested tables. That's a small,
regular grammar (no functions, no expressions), so a pure-Python parser -
matching weakaura_codec.py's own deliberate dependency-free ethos - is
enough, and weakaura_codec is the oracle that PROVES it correct (every
parsed aura is round-tripped through the codec's encode/decode in
aura_scrape.py; if the parser produced a faithful structure, the codec can
serialize and read it back unchanged).

Representation matches weakaura_codec's deserializer exactly, so the two
sources converge on one shape:
  - a table with >=1 entries, all positional  -> Python list
  - a table with any keyed entry              -> Python dict (positional
    entries kept under integer keys 1..n, as _read_mixed does)
  - an empty table                            -> Python dict {} (WA's empty
    tables are overwhelmingly maps; the codec normalizes empties to {} on
    round-trip anyway, and aura_scrape's diff treats [] == {}).

Known limitation (phase 1): a `\\ddd` byte escape inside a string is decoded
per-byte as Latin-1 (chr(byte)); a multi-byte UTF-8 char escaped that way
won't recombine. SavedVariables strings are overwhelmingly ASCII (spell
names, texture paths), so this doesn't bite the current corpus - flagged
here rather than over-engineered now.

    parse_file(path) -> {global_name: value, ...}
    parse(text)      -> same
"""
import re

_IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
_BARE_KEY = re.compile(r"[A-Za-z_][A-Za-z0-9_]*\s*=(?!=)")
_SPECIAL_NUM = re.compile(r"[-+]?(inf|nan|1\.#INF|1\.#IND|1\.#QNAN|nan\(ind\))", re.I)
_NUMBER = re.compile(r"[-+]?(0[xX][0-9A-Fa-f]+|(\d+\.?\d*|\.\d+)([eE][-+]?\d+)?)")


class LuaParseError(Exception):
    pass


class _Parser:
    def __init__(self, text):
        self.s = text
        self.i = 0
        self.n = len(text)

    def _err(self, msg):
        line = self.s.count("\n", 0, self.i) + 1
        snippet = self.s[self.i:self.i + 40]
        raise LuaParseError(f"{msg} at line {line} (offset {self.i}): {snippet!r}")

    def _skip_ws(self):
        s, n = self.s, self.n
        while self.i < n:
            c = s[self.i]
            if c in " \t\r\n":
                self.i += 1
            elif c == "-" and self.i + 1 < n and s[self.i + 1] == "-":
                self.i += 2
                # long comment  --[[ ... ]]  /  --[==[ ... ]==]
                if self.i < n and s[self.i] == "[":
                    j = self.i + 1
                    eq = 0
                    while j < n and s[j] == "=":
                        eq += 1
                        j += 1
                    if j < n and s[j] == "[":
                        close = "]" + "=" * eq + "]"
                        end = s.find(close, j + 1)
                        if end == -1:
                            self._err("unterminated long comment")
                        self.i = end + len(close)
                        continue
                while self.i < n and s[self.i] != "\n":  # line comment
                    self.i += 1
            else:
                break

    def _expect(self, ch):
        if self.i >= self.n or self.s[self.i] != ch:
            self._err(f"expected {ch!r}")
        self.i += 1

    # --- grammar ---------------------------------------------------------
    def parse_top(self):
        result = {}
        self._skip_ws()
        while self.i < self.n:
            m = _IDENT.match(self.s, self.i)
            if not m:
                self._err("expected a global name")
            name = m.group(0)
            self.i = m.end()
            self._skip_ws()
            self._expect("=")
            result[name] = self.parse_value()
            self._skip_ws()
            if self.i < self.n and self.s[self.i] == ";":
                self.i += 1
                self._skip_ws()
        return result

    def parse_value(self):
        self._skip_ws()
        if self.i >= self.n:
            self._err("unexpected end of input")
        c = self.s[self.i]
        if c == "{":
            return self._parse_table()
        if c in "\"'":
            return self._parse_string()
        if c == "[":
            return self._parse_long_string()
        return self._parse_scalar()

    def _parse_table(self):
        self._expect("{")
        array = []
        mapping = {}
        has_key = False
        while True:
            self._skip_ws()
            if self.i < self.n and self.s[self.i] == "}":
                self.i += 1
                break
            if self.i >= self.n:
                self._err("unterminated table")
            c = self.s[self.i]
            if c == "[":
                # keyed entry: [ <key> ] = <value>
                self.i += 1
                key = self.parse_value()
                self._skip_ws()
                self._expect("]")
                self._skip_ws()
                self._expect("=")
                mapping[key] = self.parse_value()
                has_key = True
            elif c.isalpha() or c == "_":
                # bare key `name = value` (rare in SV) vs keyword value
                mk = _BARE_KEY.match(self.s, self.i)
                if mk:
                    name = _IDENT.match(self.s, self.i).group(0)
                    self.i = mk.end()  # past the '='
                    mapping[name] = self.parse_value()
                    has_key = True
                else:
                    array.append(self._parse_scalar())
            else:
                array.append(self.parse_value())
            self._skip_ws()
            if self.i < self.n and self.s[self.i] in ",;":
                self.i += 1

        if has_key:
            out = {}
            for idx, v in enumerate(array, start=1):
                out[idx] = v
            out.update(mapping)
            return out
        if array:
            return array
        return {}

    def _parse_scalar(self):
        s = self.s
        for kw, val in (("true", True), ("false", False), ("nil", None)):
            if s.startswith(kw, self.i):
                end = self.i + len(kw)
                if end >= self.n or not (s[end].isalnum() or s[end] == "_"):
                    self.i = end
                    return val
        m = _SPECIAL_NUM.match(s, self.i)
        if m:
            self.i = m.end()
            tok = m.group(0).lower()
            if "nan" in tok or "ind" in tok:
                return float("nan")
            return float("-inf") if tok.startswith("-") else float("inf")
        m = _NUMBER.match(s, self.i)
        if not m:
            self._err("expected a value")
        tok = m.group(0)
        self.i = m.end()
        low = tok.lower().lstrip("+-")
        if low.startswith("0x"):
            return int(tok, 16)
        if "." in tok or "e" in tok or "E" in tok:
            return float(tok)
        return int(tok)

    def _parse_string(self):
        q = self.s[self.i]
        self.i += 1
        s, n = self.s, self.n
        out = []
        simple = {"n": "\n", "t": "\t", "r": "\r", "a": "\a", "b": "\b",
                  "f": "\f", "v": "\v", "\\": "\\", '"': '"', "'": "'", "\n": "\n"}
        while self.i < n:
            c = s[self.i]
            if c == "\\":
                self.i += 1
                if self.i >= n:
                    self._err("unterminated escape")
                e = s[self.i]
                if e in simple:
                    out.append(simple[e])
                    self.i += 1
                elif e.isdigit():
                    digits = ""
                    while self.i < n and len(digits) < 3 and s[self.i].isdigit():
                        digits += s[self.i]
                        self.i += 1
                    out.append(chr(int(digits)))
                else:
                    out.append(e)
                    self.i += 1
            elif c == q:
                self.i += 1
                return "".join(out)
            else:
                out.append(c)
                self.i += 1
        self._err("unterminated string")

    def _parse_long_string(self):
        s, n = self.s, self.n
        j = self.i + 1
        eq = 0
        while j < n and s[j] == "=":
            eq += 1
            j += 1
        if j >= n or s[j] != "[":
            self._err("unexpected '['")
        start = j + 1
        if start < n and s[start] == "\n":  # leading newline is stripped in Lua
            start += 1
        close = "]" + "=" * eq + "]"
        end = s.find(close, start)
        if end == -1:
            self._err("unterminated long string")
        self.i = end + len(close)
        return s[start:end]


def parse(text):
    return _Parser(text).parse_top()


def parse_file(path):
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        return parse(f.read())


if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("usage: py lua_table.py <savedvariables.lua>")
        sys.exit(2)
    data = parse_file(sys.argv[1])
    print("top-level globals:", list(data))
    for name, val in data.items():
        kind = type(val).__name__
        size = len(val) if isinstance(val, (dict, list)) else "-"
        print(f"  {name}: {kind} (len {size})")
