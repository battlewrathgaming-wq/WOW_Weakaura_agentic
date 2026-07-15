// wa_encode.mjs - the WA import-string ENCODER in JS (Phase 1 of the picker build).
//
// A PORT of this repo's live-proven Python reference (Weak Auras/weakaura_codec.py):
//   "!WA:2!" + EncodeForPrint(CompressDeflate(LibSerialize.Serialize(value)))
// Encode-only by design - the picker EMITS and never ingests (one-time minting).
//
// Runs in BOTH:
//   - node (the cross-validation harness):  node wa_encode.mjs   reads JSON LINES on
//     stdin (one top-level value per line), writes one import string per line.
//   - the browser (the picker shell): import { encodeImportString } and pass a
//     deflate function (native CompressionStream('deflate-raw') wrapper below).
//
// Lua-key semantics over JSON (the one seam JSON can't carry):
//   - JSON arrays  -> Lua array part (identical bytes to a contiguous 1..N int-keyed table).
//   - JSON objects -> string-keyed maps, EXCEPT objects flagged "__luaMap__": true, whose
//     digit-string keys serialize as Lua NUMBERS (multiselect stored forms like {1:true,3:true}).
//     The flag key itself is never serialized. The emit/press gears on the Python side mark
//     these; see harness.py lua_to_json for the mirror.
//
// Map-part ordering note: JS object iteration reorders integer-like keys first; Python
// preserves insertion order. Bytes may differ in map ordering - the correctness criterion
// is DECODE-EQUIVALENCE (harness.py), never string bytes. DEFLATE output likewise varies
// legitimately per implementation.

// ---------------------------------------------------------------- LibSerialize writer
const SERIALIZATION_VERSION = 1;

const NIL = 0, NUM_FLOAT = 9, NUM_FLOATSTR_POS = 10,
      BOOL_T = 12, BOOL_F = 13;
const EMBEDDED_STRING = 0, EMBEDDED_TABLE = 1, EMBEDDED_ARRAY = 2, EMBEDDED_MIXED = 3;
const STR_BY_WIDTH = { 1: 14, 2: 15, 3: 16 };
const TABLE_BY_WIDTH = { 1: 17, 2: 18, 3: 19 };
const ARRAY_BY_WIDTH = { 1: 20, 2: 21, 3: 22 };
const MIXED_BY_WIDTH = { 1: 23, 2: 24, 3: 25 };
const STRINGREF_BY_WIDTH = { 1: 26, 2: 27, 3: 28 };
const TABLEREF_BY_WIDTH = { 1: 29, 2: 30, 3: 31 };
const NUM_BY_WIDTH_POS = { 2: 1, 3: 3, 4: 5, 7: 7 };

function requiredBytes(v) {
  if (v < 256) return 1;
  if (v < 65536) return 2;
  if (v < 16777216) return 3;
  throw new Error("Object limit exceeded (>16,777,215 entries/length)");
}
function requiredBytesNumber(v) {
  if (v < 256) return 1;
  if (v < 65536) return 2;
  if (v < 16777216) return 3;
  if (v < 4294967296) return 4;
  return 7;
}

const _te = new TextEncoder();

class Writer {
  constructor() {
    this.buf = [];
    this.stringRefs = new Map();  // string -> 1-based ref index
    this.tableRefs = new Map();   // object identity -> 1-based ref index
  }
  toBytes() { return Uint8Array.from(this.buf); }
  byte(v) { this.buf.push(v & 0xff); }
  int(n, width) {  // big-endian fixed width (safe: n < 2^53, width <= 7)
    for (let i = width - 1; i >= 0; i--) this.buf.push(Math.floor(n / 256 ** i) % 256);
  }
  raw(bytes) { for (const b of bytes) this.buf.push(b); }

  write(v) {
    if (v === null || v === undefined) this.byte(8 * NIL);
    else if (typeof v === "boolean") this.byte(8 * (v ? BOOL_T : BOOL_F));
    else if (typeof v === "number") this.number(v);
    else if (typeof v === "string") this.string(v);
    else if (typeof v === "object") this.table(v);
    else throw new Error(`Unsupported value type for LibSerialize: ${typeof v}`);
  }

  number(num) {
    // floating-point = fractional or non-finite (Lua 5.1 numbers are doubles; so are JS's)
    if (!Number.isFinite(num) || !Number.isInteger(num)) { this.float(num); return; }
    if (!Number.isSafeInteger(num)) throw new Error(`Integer beyond 2^53: ${num}`);
    if (num >= 0 && num < 128) { this.byte(num * 2 + 1); return; }
    if (num > -4096 && num < 4096) {
      const sign = num < 0 ? 8 : 0;
      const mag = Math.abs(num);
      const packed = mag * 16 + sign + 4;
      this.byte(packed % 256);
      this.byte(Math.floor(packed / 256));
      return;
    }
    const sign = num < 0 ? 8 : 0;
    const mag = Math.abs(num);
    const width = requiredBytesNumber(mag);
    if (!(width in NUM_BY_WIDTH_POS)) throw new Error(`unexpected int width ${width}`);
    this.byte(sign + 8 * NUM_BY_WIDTH_POS[width]);
    this.int(mag, width);
  }

  float(num) {
    const sign = num < 0 ? 8 : 0;
    const mag = Math.abs(num);
    const asString = String(mag);
    // the compact-decimal fast path when it round-trips exactly and is short
    const roundTrips = Number.isFinite(mag) && parseFloat(asString) === mag;
    if (roundTrips && asString.length < 7) {
      this.byte(sign + 8 * NUM_FLOATSTR_POS);  // sign bit turns POS into NEG, as the original
      this.int(asString.length, 1);
      this.raw(_te.encode(asString));
    } else {
      this.byte(8 * NUM_FLOAT);
      const dv = new DataView(new ArrayBuffer(8));
      dv.setFloat64(0, num, false);  // big-endian IEEE-754 binary64
      for (let i = 0; i < 8; i++) this.buf.push(dv.getUint8(i));
    }
  }

  string(s) {
    const existing = this.stringRefs.get(s);
    if (existing !== undefined) {
      const width = requiredBytes(existing);
      this.byte(8 * STRINGREF_BY_WIDTH[width]);
      this.int(existing, width);
      return;
    }
    const data = _te.encode(s);
    const length = data.length;
    if (length < 16) this.byte(16 * length + 4 * EMBEDDED_STRING + 2);
    else {
      const width = requiredBytes(length);
      this.byte(8 * STR_BY_WIDTH[width]);
      this.int(length, width);
    }
    this.raw(data);
    if (length > 2) this.stringRefs.set(s, this.stringRefs.size + 1);
  }

  table(tab) {
    const existing = this.tableRefs.get(tab);
    if (existing !== undefined) {
      const width = requiredBytes(existing);
      this.byte(8 * TABLEREF_BY_WIDTH[width]);
      this.int(existing, width);
      return;
    }
    this.tableRefs.set(tab, this.tableRefs.size + 1);  // register BEFORE contents (self-refs)

    const [arrayItems, mapItems] = splitTable(tab);
    const ac = arrayItems.length, mc = mapItems.length;
    if (mc === 0) {
      this.arrayHeader(ac);
      for (const v of arrayItems) this.write(v);
    } else if (ac === 0) {
      this.mapHeader(mc);
      for (const [k, v] of mapItems) { this.write(k); this.write(v); }
    } else {
      this.mixedHeader(ac, mc);
      for (const v of arrayItems) this.write(v);
      for (const [k, v] of mapItems) { this.write(k); this.write(v); }
    }
  }

  arrayHeader(count) {
    if (count < 16) this.byte(16 * count + 4 * EMBEDDED_ARRAY + 2);
    else { const w = requiredBytes(count); this.byte(8 * ARRAY_BY_WIDTH[w]); this.int(count, w); }
  }
  mapHeader(count) {
    if (count < 16) this.byte(16 * count + 4 * EMBEDDED_TABLE + 2);
    else { const w = requiredBytes(count); this.byte(8 * TABLE_BY_WIDTH[w]); this.int(count, w); }
  }
  mixedHeader(ac, mc) {
    if (mc < 5 && ac < 5) this.byte(16 * ((mc - 1) * 4 + (ac - 1)) + 4 * EMBEDDED_MIXED + 2);
    else {
      const w = Math.max(requiredBytes(mc), requiredBytes(ac));
      this.byte(8 * MIXED_BY_WIDTH[w]);
      this.int(ac, w);
      this.int(mc, w);
    }
  }
}

// Split a JS value into (arrayPart, mapPart) matching _split_table / the Lua original:
// the array part is the contiguous run of numeric keys 1..N, the map part is the rest.
function splitTable(tab) {
  if (Array.isArray(tab)) return [tab.slice(), []];
  const isLuaMap = tab.__luaMap__ === true;
  const typed = [];  // [typedKey, value] in JS iteration order
  const numeric = new Map();
  for (const k of Object.keys(tab)) {
    if (k === "__luaMap__") continue;
    const key = (isLuaMap && /^-?\d+$/.test(k)) ? parseInt(k, 10) : k;
    typed.push([key, tab[k]]);
    if (typeof key === "number") numeric.set(key, tab[k]);
  }
  const arrayItems = [];
  let n = 1;
  while (numeric.has(n)) { arrayItems.push(numeric.get(n)); n++; }
  const runEnd = n - 1;
  const mapItems = typed.filter(([k]) => !(typeof k === "number" && k >= 1 && k <= runEnd));
  return [arrayItems, mapItems];
}

export function serialize(...values) {
  const w = new Writer();
  w.byte(SERIALIZATION_VERSION);
  for (const v of values) w.write(v);
  return w.toBytes();
}

// ---------------------------------------------------------------- EncodeForPrint
// LibDeflate's 6-bit alphabet - NOT standard base64 ("(" and ")" replace "+" and "/").
const B2C = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()";

export function encodeForPrint(data) {
  const out = [];
  const length = data.length;
  let i = 0;
  while (i <= length - 3) {
    const cache = data[i] + data[i + 1] * 256 + data[i + 2] * 65536;
    i += 3;
    out.push(B2C[cache % 64], B2C[Math.floor(cache / 64) % 64],
             B2C[Math.floor(cache / 4096) % 64], B2C[Math.floor(cache / 262144)]);
  }
  let cache = 0, bits = 0;
  while (i < length) { cache += data[i] * 2 ** bits; bits += 8; i++; }
  while (bits > 0) { out.push(B2C[cache % 64]); cache = Math.floor(cache / 64); bits -= 6; }
  return out.join("");
}

// ---------------------------------------------------------------- deflate (raw, RFC 1951)
// Browser-native. In node the CLI uses node:zlib instead (below); both are compliant
// DEFLATE - WA decodes either. No CDN anywhere (self-contained law).
export async function deflateRawBrowser(bytes) {
  const cs = new CompressionStream("deflate-raw");
  const stream = new Blob([bytes]).stream().pipeThrough(cs);
  return new Uint8Array(await new Response(stream).arrayBuffer());
}

// ---------------------------------------------------------------- top level
export const WA_ENCODE_VERSION = 2;      // "!WA:2!" - the LibSerialize+LibDeflate path
export const AURA_TRANSMIT_VERSION = 1421;

// Encode ANY top-level value (e.g. a decoded envelope) - the raw chain.
export async function encodeImportStringFromValue(value, deflate) {
  const compressed = await deflate(serialize(value));
  return `!WA:${WA_ENCODE_VERSION}!${encodeForPrint(compressed)}`;
}

// Wrap ONE aura table in the standard envelope (what the picker mints).
export async function encodeImportString(auraTable, deflate, {
  version = AURA_TRANSMIT_VERSION,
  versionString = "coa_picker",
} = {}) {
  const envelope = { m: "d", d: auraTable, v: version, s: versionString };
  return encodeImportStringFromValue(envelope, deflate);
}

// ---------------------------------------------------------------- node CLI (the harness)
// JSON LINES on stdin (one top-level value each) -> one import string per line on stdout.
const isNodeCli = typeof process !== "undefined" && process.argv?.[1] &&
  /wa_encode\.mjs$/.test(process.argv[1].replace(/\\/g, "/"));
if (isNodeCli) {
  const { deflateRawSync } = await import("node:zlib");
  const deflate = async (b) => new Uint8Array(deflateRawSync(Buffer.from(b), { level: 9 }));
  let input = "";
  for await (const chunk of process.stdin) input += chunk;
  const lines = input.split("\n").filter((l) => l.trim().length);
  for (const line of lines) {
    const value = JSON.parse(line);
    process.stdout.write((await encodeImportStringFromValue(value, deflate)) + "\n");
  }
}
