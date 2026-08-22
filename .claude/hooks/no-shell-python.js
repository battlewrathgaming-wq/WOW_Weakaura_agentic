// PreToolUse(Bash) — refuse Python authored through the shell.
//
// ★★★ WHY. Eight silent-corruption failures across three sessions, every one the same shape:
// `py - <<'EOF'` or `py -c "..."` carrying a Python string with `\n`, a backtick, or a nested
// quote. The shell is a language; text handed to it is parsed as code. The artefact came out
// wrong and the command came out GREEN — a shell-quoting fault is a silent-wrong, not an error.
//
// ⚠⚠ THE RULE THIS REPLACES WAS ALREADY WRITTEN, TWICE, AND STILL FAILED. First as a rule
// ("author in a file"), then as a mechanical trigger list ("if it contains \n, a backtick, or a
// nested quote"). A trigger list is STILL A JUDGEMENT — it must be consulted, at the moment of
// highest momentum, about text already half-composed. ⟶ The fix is to DELETE THE ALTERNATIVE,
// not to refine the test. "Is this Python?" has nothing to skip.
//
// ★ Bounded by the evidence, not widened past it: PROSE heredocs (`git commit -F -`) have never
// failed once and are the house pattern. They pass. Running a script file — `py path/to.py` —
// is the intended path and passes.
//
// ★★ AND IT IS AUTHORED IN A FILE, which is the rule it enforces. A hook that encoded this as a
// one-line shell regex would be the thing it exists to prevent.

let raw = "";
process.stdin.on("data", (d) => (raw += d));
process.stdin.on("end", () => {
  let cmd = "";
  try {
    cmd = (JSON.parse(raw).tool_input || {}).command || "";
  } catch (e) {
    process.exit(0); // ⚠ Unparseable input NEVER blocks — a broken hook must not stop the bench.
  }

  //   py -c "..."        python -c   python3 -c
  //   py - <<EOF         py -<<EOF   python - <<EOF
  // NOT: git commit -F -   ·   py addons/tools/x.py   ·   anything not py/python
  //
  // ⚠⚠ IT MUST BE IN COMMAND POSITION, AND THE HOOK CAUGHT ITS AUTHOR PROVING IT. The first
  // version matched anywhere in the string, so the very command written to VALIDATE the hook —
  // which carried `py -c "x"` inside a test payload, as DATA — was refused. ★ The hook fired
  // correctly and the rule was too wide: a command that MENTIONS the pattern is not a command
  // that RUNS it.
  // ⟶ So the token must start the command or follow a separator (; & | && || or an opening paren).
  //
  // ⚠⚠ AND A NEWLINE IS **NOT** A SEPARATOR HERE — the second narrowing, and it also came from
  // the hook firing on real use. With `\n` in the set, THIS REPOSITORY'S HOUSE PATTERN BROKE:
  // `git commit -F - <<'EOF'` carrying a prose message that DISCUSSES `py -c` was refused,
  // because every line of the message read as command position. The commit describing the hook
  // could not be written by the hook's own rule.
  // ★ Prose heredocs are the one thing this must never touch, so `\n` goes.
  //
  // ⚠ TWO STATED COSTS, neither hidden: a multi-line Bash command whose SECOND line begins
  // `py -c` is not caught (chained `&&` still is), and a quoted string sitting immediately after
  // `&&` still matches. Distinguishing data from code properly means parsing shell grammar —
  // more machinery than the fault is worth.
  const SHELL_PYTHON = /(?:^|[;&|(]|&&|\|\|)\s*(?:py|python3?)\s+-(?:c(?:\s|$)|\s*<<)/;

  if (!SHELL_PYTHON.test(cmd)) process.exit(0);

  process.stdout.write(
    JSON.stringify({
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason:
          "Python through the shell is blocked — 8 silent-corruption failures across 3 sessions " +
          "(heredoc and -c eat escapes; the artefact is wrong and the command is green). " +
          "Author the script with the Write tool into the scratchpad, then run it: py <path>. " +
          "Prose heredocs (git commit -F -) and running a .py file are unaffected.",
      },
    })
  );
});
