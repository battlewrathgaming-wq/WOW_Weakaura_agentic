"""build_picker.py - Phase 3's assembly gear: shell template + data + JS -> ONE picker.html.

The HTML is a BUILD PRODUCT (pipeline law: never hand-edited - fix a gear or the shell source,
re-run this). Everything embeds: library.json (Phase 0), templates.json (Phase 2), the codec
port (Phase 1, exports stripped + the node-CLI block cut), mint.js, app.js, style.css.
Self-contained by law - no CDN, no external anything.

  py build_picker.py     -> out/picker.html + a receipt
"""
import json
import os
import re
import subprocess

_HERE = os.path.dirname(os.path.abspath(__file__))
SHELL = os.path.join(_HERE, "shell")
OUT = os.path.join(_HERE, "out", "picker.html")


def read(p):
    return open(p, encoding="utf-8").read()


def browser_js(mjs_source):
    """wa_encode.mjs -> inline browser JS: cut the node CLI block, strip `export `."""
    cut = mjs_source.split("// ---------------------------------------------------------------- node CLI")[0]
    return re.sub(r"^export ", "", cut, flags=re.M)


def main():
    lib = read(os.path.join(_HERE, "out", "library.json"))
    tpl = read(os.path.join(_HERE, "out", "templates.json"))
    try:
        rev = subprocess.run(["git", "rev-parse", "--short", "HEAD"], capture_output=True,
                             text=True, cwd=_HERE).stdout.strip() or "untracked"
    except OSError:
        rev = "untracked"
    counts = json.loads(lib)["_provenance"]["counts"]
    stamp = (f"build {rev} | {counts['classes']} classes / {counts.get('real_specs', '?')} specs / "
             f"{counts['cards']} talents / {counts['chain_spells']} chain spells")

    html = read(os.path.join(SHELL, "picker.html.template"))
    html = html.replace("/*__STYLE__*/", read(os.path.join(SHELL, "style.css")))
    html = html.replace("/*__LIBRARY_JSON__*/", lib)
    html = html.replace("/*__TEMPLATES_JSON__*/", tpl)
    html = html.replace("/*__WA_ENCODE_JS__*/", browser_js(read(os.path.join(_HERE, "codec", "wa_encode.mjs"))))
    html = html.replace("/*__MINT_JS__*/", re.sub(r"^export ", "", read(os.path.join(SHELL, "mint.js")), flags=re.M))
    html = html.replace("/*__APP_JS__*/", read(os.path.join(SHELL, "app.js")))
    html = html.replace("/*__BUILDSTAMP__*/", stamp)

    for marker in ("__STYLE__", "__LIBRARY_JSON__", "__TEMPLATES_JSON__",
                   "__WA_ENCODE_JS__", "__MINT_JS__", "__APP_JS__", "__BUILDSTAMP__"):
        assert marker not in html, f"unfilled marker: {marker}"

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write(html)
    print(f"picker.html built: {os.path.getsize(OUT)/1e6:.1f} MB  ({stamp})")


if __name__ == "__main__":
    main()
