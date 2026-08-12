@echo off
REM ============================================================
REM  COA Addons Bench - a SAFE keys-only menu, same model as the
REM  root Project Launcher: `choice` accepts ONLY the listed keys,
REM  no free-text prompt. This terminal is the bench's runtime
REM  env: it hosts the landing watcher and steers deploys.
REM  Pin it: right-click menu.bat -> Send to -> Desktop (create
REM  shortcut), then pin the shortcut to the taskbar.
REM  %~dp0 = this file's folder (addons\); ROOT = the repo.
REM ============================================================
title COA Addons Bench
set "BENCH=%~dp0"
set "ROOT=%~dp0..\"

:MAIN
cls
echo ==================================================
echo    COA ADDONS BENCH
echo    (safe menu - only the listed keys do anything)
echo ==================================================
echo.
echo   EVERYDAY / SAFE
echo     [1]  Watcher        landing watcher in its OWN window (leave open)
echo     [2]  Pull once      land the current mailbox now
echo     [3]  Deploy check   read-only: repo vs client sync state
echo     [4]  Git status     read-only: show changes ^& last commits
echo.
echo   --------------------------------------------------
echo     [5]  Deploy...      push addon files to the client (game CLOSED)
echo     [A]  Advanced...    git push (changes or uploads)
echo     [Q]  Quit
echo.
choice /c 12345AQ /n /m "   Press a key: "
if errorlevel 7 goto END
if errorlevel 6 goto ADVANCED
if errorlevel 5 goto DEPLOY
if errorlevel 4 goto RUN_STATUS
if errorlevel 3 goto RUN_CHECK
if errorlevel 2 goto RUN_PULL
if errorlevel 1 goto RUN_WATCH
goto END

:RUN_WATCH
cls
echo Opening the landing watcher in its own window...
echo (Leave it open. It lands every fresh mailbox flush automatically.
echo  Press Ctrl-C in that window to stop it.)
start "addons landing watcher" cmd /k py "%BENCH%landing\pull.py" watch
goto MAIN

:RUN_PULL
cls
py "%BENCH%landing\pull.py" once
echo.
pause
goto MAIN

:RUN_CHECK
cls
py "%BENCH%deploy.py"
echo.
pause
goto MAIN

:RUN_STATUS
cls
call "%ROOT%git_status.bat"
goto MAIN

:DEPLOY
cls
setlocal enabledelayedexpansion
echo ==================================================
echo    DEPLOY  -  writes into the client's AddOns folder
echo    (game must be CLOSED: new addon code needs a full
echo     client restart on this account - /reload can't load it)
echo ==================================================
echo.
REM  The resident list is ENUMERATED from deploy.py's MANIFEST, never
REM  hand-copied here. A duplicated list drifts - this one did, twice,
REM  and silently: new addons simply never appeared as an option.
set "KEYS="
set /a N=0
for /f "usebackq delims=" %%N in (`py "%BENCH%deploy.py" names`) do (
    set /a N+=1
    set "OPT!N!=%%N"
    set "KEYS=!KEYS!!N!"
    echo     [!N!]  %%N
)
echo.
echo     [A]  ALL residents   ^(unchanged files are skipped, so this is cheap^)
echo     [B]  Back to main menu
echo.
set "KEYS=!KEYS!AB"
choice /c !KEYS! /n /m "   Press a key: "
set /a PICK=%errorlevel%
set /a BACK=N+2
set /a ALL=N+1
if !PICK! equ !BACK! endlocal & goto MAIN
if !PICK! equ !ALL! (set "TARGET=all") else (
    for %%I in (!PICK!) do set "TARGET=!OPT%%I!"
)
echo.
choice /c YN /n /m "   Deploy !TARGET! (game closed)?  [Y]es  [N]o: "
if errorlevel 2 endlocal & goto DEPLOY
cls
py "%BENCH%deploy.py" !TARGET!
echo.
pause
endlocal
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
