# -*- coding: utf-8 -*-
r"""Drive the emulation probe over both Ace3 revisions. In a file, because the paths
are Windows-backslashed and the shell keeps eating them."""
import os
import subprocess
import sys

REPO = r"F:\Projects_games\World of Warcraft - Conquest of Azeroth"
LUA = os.path.join(REPO, r".tools\lua51\lua5.1.exe")
PROBE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "smoke", "probe_ace.lua")

for d in ("wotlk-r960", "modern-r1403"):
    dist = os.path.join(REPO, "dependencies", "Ace3", d)
    r = subprocess.run([LUA, PROBE, dist], capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
    sys.stdout.write((r.stdout or "") + (r.stderr or "") + "\n")
