"""emit_outstanding.py - collect each surface's OUTSTANDING items into its own footer.

★★★ WHY EMITTED AND NOT WRITTEN. Every surface file is full of marks, and you cannot
see what is outstanding for one surface without reading all of it. But a hand-written
summary at the foot would put the same fact in two places, which is the fault this
bench keeps finding. So the marks stay where they belong - beside the row they are
about - and this collects them.

★★ TWO MARKERS, BECAUSE ONE WAS DOING TWO JOBS:

    ☐   OUTSTANDING - the code disagrees with the file, or something declared is not
        built. A job. This is what gets collected.
    ⚠   CAUTION - a fact worth flagging that is nobody's job. "The grab area is four
        times the visual" is true and deliberate and will never be "done".

⚠ A blanket ⚠ scrape produced noise for exactly that reason: half of them are the
reason something IS the way it is.

★ THE OTHER HALF OF THE FOOTER IS AUTHORED AND IS NOT TOUCHED HERE. His:

    *"Their not technical in nature. Their expressions of what it should hold and do.
    The backlog to realize."*

So `## Hopes and dreams` is written by hand, in plain terms, and this tool writes only
between the OUTSTANDING markers.

Usage:
    py addons\\tools\\emit_outstanding.py            rewrite every surface footer
    py addons\\tools\\emit_outstanding.py --check    report only, non-zero if stale
"""
import io
import re
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")

HERE = Path(__file__).resolve().parent
SURFACES = HERE.parent / "planning" / "interface"

BEGIN = "<!-- OUTSTANDING:BEGIN - emitted by emit_outstanding.py, do not edit by hand -->"
END = "<!-- OUTSTANDING:END -->"

MARK = re.compile(r"^\s*(?:[-*]\s*)?☐\s*(.+?)\s*$")


def collect(text, nl):
    """Every ☐ line outside the emitted block, in file order."""
    out, inside, open_item = [], False, None
    for line in text.split(nl):
        if BEGIN in line:
            inside = True
            continue
        if END in line:
            inside = False
            continue
        if inside:
            continue
        m = MARK.match(line)
        if m:
            if open_item:
                out.append(open_item)
            # strip markdown emphasis so the footer reads as a list, not as shouting
            open_item = m.group(1).replace("**", "").strip()
            continue
        # ⚠ A WRAPPED ITEM IS STILL ONE ITEM. The first cut took only the marked
        # line, so a two-line note arrived in the footer ending "and no" - a summary
        # that stops mid-sentence is worse than no summary.
        if open_item is not None:
            if line.strip() == "" or line.startswith(("#", "```", "|", "---")):
                out.append(open_item)
                open_item = None
            else:
                open_item += " " + line.strip().replace("**", "")
    if open_item:
        out.append(open_item)
    return out


def block(items, nl):
    if not items:
        body = ["_Nothing outstanding._"]
    else:
        body = ["%d item%s:" % (len(items), "" if len(items) == 1 else "s"), ""]
        body += ["- %s" % i for i in items]
    return nl.join([BEGIN, ""] + body + ["", END])


def apply(path, write=True):
    text = io.open(path, encoding="utf-8", newline="").read()
    nl = "\r\n" if "\r\n" in text else "\n"
    items = collect(text, nl)
    new = block(items, nl)

    if BEGIN in text and END in text:
        lo = text.index(BEGIN)
        hi = text.index(END) + len(END)
        # ⚠ EAT THE TRAILING BLANK LINES BEFORE PUTTING ONE BACK. The first cut appended
        # one every run without consuming the old one, so the file grew by a line each
        # time and `--check` called a freshly-written footer STALE. A tool that is not
        # idempotent cannot be used to check anything, including itself.
        while text[hi:hi + len(nl)] == nl:
            hi += len(nl)
        updated = text[:lo] + new + nl * 2 + text[hi:]
    else:
        # ⚠ First run: the footer goes ABOVE any authored "Hopes and dreams" section,
        # so the emitted block never has to move once the hand-written half exists.
        head = "## Outstanding"
        hopes = nl + "## Hopes and dreams"
        anchor = text.index(hopes) if hopes in text else len(text)
        updated = (text[:anchor].rstrip(nl) + nl * 2 + "---" + nl * 2 + head + nl * 2
                   + new + nl + text[anchor:])

    changed = updated != text
    if changed and write:
        io.open(path, "w", encoding="utf-8", newline="").write(updated)
    return len(items), changed


def main():
    check = "--check" in sys.argv
    if not SURFACES.is_dir():
        print("no surface folder at %s" % SURFACES)
        return 2

    stale, total = [], 0
    for path in sorted(SURFACES.glob("*.md")):
        n, changed = apply(path, write=not check)
        total += n
        print("  %-18s %2d outstanding%s"
              % (path.stem, n, "   (STALE)" if (check and changed) else ""))
        if check and changed:
            stale.append(path.stem)

    print("\n%d outstanding across %d surface(s)"
          % (total, len(list(SURFACES.glob("*.md")))))
    if check and stale:
        print("⚠ stale footer(s): %s - run without --check" % ", ".join(stale))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
