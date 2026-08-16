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
echo     [6]  Pane Board     spatial board for the panes, own window (safe)
echo     [7]  Reconcile      read-only: where the DOCS and the CODE have drifted
echo     [A]  Advanced...    git push (changes or uploads)
echo     [Q]  Quit
echo.
REM  6 and 7 sit below the divider only so 1-5 keep the keys they have always had.
REM  Neither changes anything: 6 opens a window, 7 reads and reports.
choice /c 1234567AQ /n /m "   Press a key: "
if errorlevel 9 goto END
if errorlevel 8 goto ADVANCED
if errorlevel 7 goto RUN_RECONCILE
if errorlevel 6 goto RUN_BOARD
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
REM  Read-only, like the deploy check above it: says whether the addon census
REM  still matches the code, and writes nothing either way.
py "%BENCH%tools\emit_addon_census.py" --check
echo.
pause
goto MAIN

:RUN_STATUS
cls
call "%ROOT%git_status.bat"
goto MAIN

:RUN_RECONCILE
cls
echo ==================================================
echo    RECONCILE  -  read-only. Nothing here changes a file.
echo ==================================================
echo.
REM  His framing, and it is the whole reason this is one key rather than five:
REM
REM    "Curation of input is still needed. But so it's not justification. It's fact
REM     that there will be lag during active development. But so we can reconcile and
REM     shake out what proved false rather than keep building on them."
REM
REM  LAG IS EXPECTED. This does not grade and it does not assume the code is right -
REM  the docs are the authority, so a difference is a question, not a verdict.
echo   [1/5] the surface docs against the source
py "%BENCH%tools\check_interface.py"
echo.
echo   [2/5] outstanding footers
py "%BENCH%tools\emit_outstanding.py" --check
echo.
echo   [3/5] tagged notes reach the shelf
py "%BENCH%tools\emit_notes.py" --reach
echo.
echo   [4/5] the declared-surface census
py "%BENCH%tools\emit_addon_census.py" --check
echo.
echo   [5/5] repo against client
py "%BENCH%deploy.py"
echo.
echo ==================================================
echo    Nothing above was changed. Decide which side is
echo    wrong, then fix THAT side.
echo ==================================================
pause
goto MAIN

:RUN_BOARD
cls
REM  The board answers the taste questions the inventory cannot - how big
REM  should this be, does it sit right. Set the viewport to a pane's real size
REM  and it is 1:1 with the client. addons\planning\dungeonrun_interface_inventory.md stays the
REM  authority; the board never mirrors it.
REM
REM  First run pulls Electron (~200MB into node_modules\, gitignored); after
REM  that this is instant.
REM  The test names a FILE inside electron rather than the folder: a trailing
REM  backslash before a closing quote is a known cmd footgun, and package.json
REM  also tells a FINISHED install from a half-done one.
if not exist "%BENCH%tools\PaneBoard\node_modules\electron\package.json" (
    echo First run - installing Electron. This takes a minute.
    echo.
    pushd "%BENCH%tools\PaneBoard"
    call npm install
    popd
    echo.
)
echo Opening the Pane Board in its own window...
echo (Close that window when you are done; this menu stays up.)
start "COA Pane Board" /d "%BENCH%tools\PaneBoard" cmd /c npm start
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
REM  NOT because deploying makes it stale - deploy is repo->client, and the
REM  census reads REPO source, so it went stale when the .lua was EDITED,
REM  possibly hours ago. This is opportunistic: you are already at the bench and
REM  it costs milliseconds. --check on option [3] is the actual safeguard,
REM  because editing without ever deploying would never reach this line.
py "%BENCH%tools\emit_addon_census.py"
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
