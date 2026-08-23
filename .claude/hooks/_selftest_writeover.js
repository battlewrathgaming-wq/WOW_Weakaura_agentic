// Self-test for no-write-over.js — the three bounds, and the CONTENT of the ask.
// ★ Kept beside the hook, same as _selftest.js. This hook's value is not that it fires; it is
// WHAT IT SAYS when it fires — the file's own first line and its commit count are the two facts
// that separate "my scratch file" from "someone's tool". So the reason string is asserted, not
// just its presence.
const { execFileSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const HOOK = path.join(__dirname, "no-write-over.js");
const REPO = path.resolve(__dirname, "..", "..");

function ask(file) {
  const out = execFileSync("node", [HOOK], {
    input: JSON.stringify({ tool_input: { file_path: file } }),
  }).toString().trim();
  if (!out) return null;
  return JSON.parse(out).hookSpecificOutput.permissionDecisionReason;
}

let bad = 0;
function check(label, ok) {
  if (!ok) bad++;
  console.log(`  ${ok ? "ok  " : "FAIL"}  ${label}`);
}

// ── 1. AN EXISTING TRACKED FILE ASKS, and says enough to answer without looking anything up.
const r = ask(path.join(REPO, "addons/tools/mutate.py"));
check("a tracked file asks", r !== null);
check("  · it NAMES the file", !!r && r.includes("mutate.py"));
check("  · it QUOTES the file's own first line", !!r && r.includes("break each guard"));
check("  · it gives the commit count", !!r && /\d+ commits/.test(r));
check("  · it says Write REPLACES", !!r && r.includes("REPLACES"));

// ⚠ THE CASE THIS HOOK WAS BUILT FOR, asserted literally: the docstring shown must be the LUA
// harness's, never the checker one that was written over it.
check("  · it shows the SMOKE harness, the file that was destroyed",
      !!r && r.includes("smoke bites"));

// ── 2. A FILE THAT DOES NOT EXIST IS A CREATION — never touched.
check("a new path passes", ask(path.join(REPO, "addons/tools/does_not_exist_xyz.py")) === null);

// ── 3. AN UNTRACKED FILE PASSES. The bench is TOLD to write to the scratchpad; prompting on
//      untracked files would train the ask away, which is how a guard becomes furniture.
const tmp = path.join(__dirname, ".selftest_untracked.tmp");
fs.writeFileSync(tmp, "# a draft nobody committed\n");
try {
  check("an untracked file passes", ask(tmp) === null);
} finally {
  fs.unlinkSync(tmp);
}

// ── 4. A DIRECTORY IS NOT A FILE.
check("a directory passes", ask(path.join(REPO, "addons/tools")) === null);

// ── 5. MALFORMED INPUT MUST NEVER BLOCK. A broken hook must not stop the bench.
const m = execFileSync("node", [HOOK], { input: "not json" }).toString().trim();
check("malformed input never blocks", m.length === 0);
const e = execFileSync("node", [HOOK], { input: JSON.stringify({ tool_input: {} }) })
  .toString().trim();
check("a missing file_path never blocks", e.length === 0);

console.log(bad ? `\n${bad} FAILING` : "\nall cases hold");
process.exit(bad ? 1 : 0);
