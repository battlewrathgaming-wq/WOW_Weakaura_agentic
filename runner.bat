@echo off
REM service-runner launcher - Claude's machinery-calling proxy, under YOUR runtime.
REM Double-click and leave open. Claude queues whitelisted service calls; this executes
REM them under YOUR process ownership and writes receipts. Kill Claude's session and this
REM keeps running - the steering (Claude) and the machinery (here) are decoupled.
REM %~dp0 = this file's own folder, so it's path-independent.
title service-runner (your runtime)
py "%~dp0runner.py"
echo.
echo (runner stopped - press a key to close)
pause >nul
