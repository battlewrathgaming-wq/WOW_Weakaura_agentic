#!/bin/bash
# Builds a real Lua 5.1.5 interpreter from official source (lua.org),
# matching WoW 3.3.5a's actual Lua version - deliberately NOT a newer
# bundled interpreter (e.g. lupa's bundled Lua 5.5), specifically so
# behavior differences between Lua versions can't be mistaken for real
# WeakAuras behavior. Needs re-running each fresh sandbox session (the
# build directory doesn't persist between sessions), takes a few seconds.
#
# The "generic" make target is used deliberately - "make linux" pulls in
# readline for the standalone lua.c REPL, which isn't installed and
# can't be apt-installed without root in this sandbox. "generic" skips
# that dependency entirely (the interpreter is only ever run
# non-interactively here anyway, so the REPL's readline niceties are
# irrelevant).
set -e
BUILD_DIR="${1:-/tmp/lua-5.1.5}"
cd /tmp
curl -sO https://www.lua.org/ftp/lua-5.1.5.tar.gz
tar xzf lua-5.1.5.tar.gz
cd lua-5.1.5
make generic
echo "Built: $(pwd)/src/lua"
"$(pwd)/src/lua" -v
