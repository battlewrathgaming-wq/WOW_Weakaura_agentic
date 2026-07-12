@echo off
REM ============================================================
REM  Project Launcher - a SAFE keys-only menu for the .bat tools.
REM  Uses the built-in `choice` command: it accepts ONLY the keys
REM  listed on each screen. There is no free-text prompt, so you
REM  cannot type (or mistype) a command - you can only pick an
REM  offered option. Non-safe tools sit one level deep under
REM  [A]dvanced, each behind a Yes/No confirm.
REM  %~dp0 = this file's own folder, so it works wherever the repo lives.
REM ============================================================
title Project Launcher
set "ROOT=%~dp0"

:MAIN
cls
echo ==================================================
echo    PROJECT LAUNCHER
echo    (safe menu - only the listed keys do anything)
echo ==================================================
echo.
echo   EVERYDAY / SAFE
echo     [1]  Paste-drop     capture WA exports into the inbox
echo     [2]  Git status     read-only: show changes ^& last commits
echo     [3]  Decode drop    settled view of the newest capture
echo     [4]  Diff drops     per-option write delta (last two)
echo.
echo   --------------------------------------------------
echo     [A]  Advanced...    push (changes or uploads)
echo     [Q]  Quit
echo.
choice /c 1234AQ /n /m "   Press a key: "
if errorlevel 6 goto END
if errorlevel 5 goto ADVANCED
if errorlevel 4 goto RUN_DIFF
if errorlevel 3 goto RUN_DECODE
if errorlevel 2 goto RUN_STATUS
if errorlevel 1 goto RUN_PASTE
goto END

:RUN_PASTE
cls
echo Launching paste-drop. Paste WA exports, then type quit to return here.
echo.
py "%ROOT%Weak Auras\ingest\paste_drop.py"
goto MAIN

:RUN_STATUS
cls
call "%ROOT%git_status.bat"
goto MAIN

:RUN_DECODE
cls
py "%ROOT%Weak Auras\plane\decode.py" peek
echo.
pause
goto MAIN

:RUN_DIFF
cls
py "%ROOT%Weak Auras\plane\decode.py" diff
echo.
pause
goto MAIN

:ADVANCED
cls
echo ==================================================
echo    ADVANCED  -  these CHANGE or UPLOAD things
echo ==================================================
echo.
echo     [1]  Git PUSH       commit everything ^& upload to GitHub
echo.
echo     [B]  Back to main menu
echo.
choice /c 1B /n /m "   Press a key: "
if errorlevel 2 goto MAIN
if errorlevel 1 goto RUN_PUSH
goto MAIN

:RUN_PUSH
cls
echo   Git PUSH will commit all current changes and upload them to GitHub.
echo.
choice /c YN /n /m "   Proceed?  [Y]es  [N]o: "
if errorlevel 2 goto ADVANCED
call "%ROOT%git_push.bat"
goto ADVANCED

:END
