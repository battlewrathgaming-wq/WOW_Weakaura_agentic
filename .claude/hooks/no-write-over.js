// PreToolUse(Write) — a Write onto an EXISTING TRACKED file asks first, and shows what is there.
//
// ★★★ WHY. 2026-08-22: I wrote a new mutation harness to `addons/tools/mutate.py` and committed
// it. That path already held a 342-MUTATION suite for the Lua smokes, many sessions old, carrying
// six bad tests, one live bug and its own ruling. I used Write on a path I had never read.
// ⟶ Restored byte-exact from HEAD~1, but only because the tree was clean and it was caught in the
// same session. Nothing on the bench noticed: not a checker, not a test, not the commit.
//
// ⚠⚠ AN INDEX WOULD NOT HAVE CAUGHT IT, and that is the whole argument for a hook. I did not fail
// to FIND the file — I never looked. A registry is PULLED: it works only when the agent chooses to
// read it, at the moment of highest momentum, about a question it does not know it has. This fires
// whether or not anyone looked. ★ Same reasoning as `no-shell-python.js`: delete the alternative
// rather than refine a rule that must be consulted.
//
// ★ IT ASKS, IT DOES NOT DENY. Rewriting a file whole is ordinary and legitimate — this repo does
// it constantly. What was missing was never permission; it was KNOWING SOMETHING WAS THERE. So the
// reason string carries the file's own first line of documentation and its commit count, which is
// the one fact that separates "my scratch file from ten minutes ago" from "someone's tool".
//
// ★★ BOUNDED THREE WAYS, so it stays silent everywhere the hazard is not:
//   · the file must EXIST            — creating a new file is never touched
//   · it must be GIT-TRACKED         — the scratchpad, Outputs/ and untracked drafts pass freely
//   · Edit is not matched at all     — Edit already requires a prior Read; this is Write's gap
//
// ⚠ TWO STATED COSTS, neither hidden.
//
//   1  A Write onto a tracked file you HAVE read this session still asks. The hook cannot see the
//      transcript. One keypress, against a destroyed tool — and the ask carries enough to answer
//      it without looking anything up.
//
//   2 ⚠⚠ IT GUARDS THE **Write TOOL**, NOT WRITING. This bench authors most edits as Python
//      scripts run through Bash (`no-shell-python.js` requires exactly that), and a script doing
//      `open(path, "w")` never reaches a PreToolUse(Write) matcher. So the coverage is PARTIAL,
//      and saying otherwise would make it the kind of guard that reassures without checking.
//      ★ It is kept as-is because the fault it was built for WAS a Write tool call, and because
//      the alternative — matching Bash and parsing what a script will open — is the shell-grammar
//      problem `no-shell-python.js` already refused to take on. ⟶ The gap is real; the fix for it
//      is a person knowing it is there, which is why it is written here rather than in a backlog.

const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

let raw = "";
process.stdin.on("data", (d) => (raw += d));
process.stdin.on("end", () => {
  let file = "";
  try {
    file = (JSON.parse(raw).tool_input || {}).file_path || "";
  } catch (e) {
    process.exit(0); // ⚠ Unparseable input NEVER blocks — a broken hook must not stop the bench.
  }
  if (!file) process.exit(0);

  let stat = null;
  try {
    stat = fs.statSync(file);
  } catch (e) {
    process.exit(0); // does not exist → a creation, which is the safe case
  }
  if (!stat.isFile()) process.exit(0);

  const dir = path.dirname(path.resolve(file));

  // ⚠ TRACKED, not merely "inside a repo". An untracked draft has no history to destroy, and the
  // scratchpad is where this bench is TOLD to write — prompting there would train the ask away.
  let tracked = false;
  try {
    execFileSync("git", ["ls-files", "--error-unmatch", "--", path.resolve(file)], {
      cwd: dir,
      stdio: "ignore",
      timeout: 4000,
    });
    tracked = true;
  } catch (e) {
    process.exit(0);
  }
  if (!tracked) process.exit(0);

  // ── WHAT IS THERE. The first documentation line, in whatever this file's language calls one.
  let says = "";
  try {
    const head = fs.readFileSync(file, "utf8").split("\n").slice(0, 40);
    for (const line of head) {
      const m = line.match(/^\s*(?:#|--|\/\/|r?"""|r?'''|\*|<!--)\s*(\S.*?)\s*(?:-->)?\s*$/);
      if (!m) continue;
      const t = m[1];
      // skip the furniture that carries no meaning
      if (/^(-\*-|!\/|coding[:=]|=+$|-+$|\*+$)/.test(t)) continue;
      says = t;
      break;
    }
  } catch (e) {
    /* unreadable is not a reason to block */
  }

  let commits = "";
  try {
    const log = execFileSync("git", ["log", "--oneline", "--", path.resolve(file)], {
      cwd: dir,
      encoding: "utf8",
      timeout: 4000,
    }).trim();
    const n = log ? log.split("\n").length : 0;
    const first = log ? log.split("\n")[0] : "";
    commits = n ? `${n} commit${n === 1 ? "" : "s"}, last: ${first.slice(0, 72)}` : "";
  } catch (e) {
    /* no git, no history line */
  }

  const parts = [
    `${path.basename(file)} ALREADY EXISTS and is tracked.`,
    says ? `It says: "${says.slice(0, 140)}"` : "",
    commits,
    "Write REPLACES it whole. If you meant to add to it, Read it and use Edit. " +
      "If you meant a new tool, its NAME is a claim about what exists — pick a different one.",
  ].filter(Boolean);

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "ask",
        permissionDecisionReason: parts.join(" · "),
      },
    })
  );
});
