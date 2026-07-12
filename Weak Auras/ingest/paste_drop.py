"""
paste_drop.py - interactive capture terminal for WeakAuras exports.

Leave this running in a terminal while you test / build in-game. Paste a WA export
string (starts with !WA:2!) and hit Enter - it's written to ingest/inbox/ as a
timestamped .txt, exactly the shape `ingest.py` expects. No clipboard access, no
deps (stdlib only), no polling: it only ever sees what you deliberately paste.

  py paste_drop.py

Then downstream, at your choosing:
  - inspection / a live test  -> the raw string sits in inbox/, read directly
  - grow the reference pool    -> `py ingest.py` decodes inbox/ -> reference/

Type 'quit' (or Ctrl-C) to stop. Anything without a !WA: prefix is refused, so a
stray copy/paste can't dirty the inbox.
"""
import datetime
import os

_THIS = os.path.dirname(os.path.abspath(__file__))
INBOX = os.path.join(_THIS, "inbox")


def main():
    os.makedirs(INBOX, exist_ok=True)
    print("paste-drop ready - paste a WA export (!WA:2!...) then Enter. 'quit' to stop.")
    print(f"  dropping into: {INBOX}")
    n = 0
    while True:
        try:
            line = input("\nWA> ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nstopped.")
            break
        if not line:
            continue
        if line.lower() in ("quit", "exit", "q"):
            print("stopped.")
            break
        if not line.startswith("!WA:"):
            print(f"  refused: no !WA: prefix ({len(line)} chars) - not a WA export")
            continue
        n += 1
        ts = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        name = f"export_{ts}_{n:02d}.txt"
        with open(os.path.join(INBOX, name), "w", encoding="utf-8") as f:
            f.write(line + "\n")
        print(f"  captured {name}  ({len(line)} chars)  [{n} this session]")


if __name__ == "__main__":
    main()
