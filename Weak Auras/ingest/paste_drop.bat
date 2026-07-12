@echo off
REM WA paste-drop launcher - interactive WeakAuras export capture.
REM Double-click, paste export strings (!WA:2!...) then Enter -> ingest\inbox\.
REM Type 'quit' to stop. %~dp0 = this .bat's own folder, so path-independent.
title WA paste-drop
py "%~dp0paste_drop.py"
echo.
echo (session ended - press a key to close this window)
pause >nul
