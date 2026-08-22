// Self-test for no-shell-python.js — every case that shaped the regex, run in one go.
// ★ Kept beside the hook rather than in a transcript: the hook's rule was narrowed once
// already (command position, not anywhere), and the next person to widen it needs the cases.
const { execFileSync } = require("child_process");
const path = require("path");
const HOOK = path.join(__dirname, "no-shell-python.js");

const CASES = [
  // [expect blocked?, command]
  [true, "py - <<PY\nprint(1)\nPY"],
  [true, 'py -c "import io"'],
  [true, "python3 -c 'x'"],
  [true, "cd /tmp && py - <<EOF"],
  [true, "python -c 'x'"],
  [false, "git commit -F -"],
  [false, "git commit -q -F -"],
  [false, "py addons/tools/check_inbox.py"],
  [false, 'py "F:/x/y.py" --flag'],
  [false, "cp a b"],
  // ★ the case that narrowed the rule: the pattern as DATA, not in command position
  [false, 'node -e "const s = \'py -c x\'"'],
  [false, "grep -n 'py -c' notes.md"],
  // ★★ the case that narrowed it a SECOND time: the house pattern carrying prose ABOUT the
  // pattern. With `\n` in the separator set this was refused, and the commit describing the
  // hook could not be written by the hook's own rule.
  [false, "git commit -q -F - <<'EOF'\nfixed the thing\n\npy -c was the failing shape\nEOF"],
  [false, "git commit -F -\n\n  1  as a RULE\n  py -c eats escapes\n"],
];

let bad = 0;
for (const [want, cmd] of CASES) {
  const payload = JSON.stringify({ tool_name: "Bash", tool_input: { command: cmd } });
  const out = execFileSync("node", [HOOK], { input: payload }).toString().trim();
  const got = out.length > 0;
  const ok = got === want;
  if (!ok) bad++;
  console.log(`${ok ? "  ok  " : "  FAIL"} ${got ? "BLOCK" : "allow"}  ${JSON.stringify(cmd)}`);
}
// malformed input must never block
const m = execFileSync("node", [HOOK], { input: "not json" }).toString().trim();
if (m.length) { console.log("  FAIL  malformed input blocked"); bad++; }
else console.log("  ok   allow  <malformed input never blocks>");

console.log(bad ? `\n${bad} FAILING` : "\nall cases hold");
process.exit(bad ? 1 : 0);
