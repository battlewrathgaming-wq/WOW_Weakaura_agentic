@echo off
setlocal

rem Copies COA_GuardianPlates from the project folder (source of truth) to the
rem live game AddOns folder. Plain byte-for-byte file copy - no retyping, so
rem this can't introduce the kind of leaked-text corruption a hand-rewritten
rem file could. Runs natively on this machine, so it isn't affected by any
rem sandbox/mount staleness - always copies the real, current project files.

rem v3.0: the addon is now split into Core.lua / GuardianPlates.lua /
rem ThreatPlates.lua (see COA_GuardianPlates.toc) instead of one monolithic
rem COA_GuardianPlates.lua. This script copies the 3 new files and removes
rem the old monolithic file from the game folder if present, so it can't be
rem left behind as stale dead weight.
rem
rem v3.0.1: GuardianPlates.lua was renamed to FriendlyPlates.lua (see the
rem .toc). This script now copies FriendlyPlates.lua and removes the old
rem GuardianPlates.lua from the game folder if present, same pattern as the
rem earlier monolithic-file cleanup.
rem
rem v3.1: brand pivot to "COA State Plates" (Title/UI text only - folder
rem name and SavedVariables key deliberately unchanged). ThreatPlates.lua
rem was renamed to EnemyPlates.lua; this script now copies EnemyPlates.lua
rem and removes the old ThreatPlates.lua from the game folder if present.

set "SRC=F:\Projects_games\World of Warcraft - Conquest of Azeroth\Weak Auras\Tools\COA_GuardianPlates"
set "DST=F:\games\Ascension_wow\resources\ascension-live\Interface\AddOns\COA_GuardianPlates"

echo Copying COA_GuardianPlates:
echo   FROM: %SRC%
echo   TO:   %DST%
echo.

if not exist "%DST%" (
    echo Destination folder does not exist - creating it.
    mkdir "%DST%"
)

copy /Y "%SRC%\COA_GuardianPlates.toc" "%DST%\COA_GuardianPlates.toc"
if errorlevel 1 (
    echo FAILED copying COA_GuardianPlates.toc
    goto :end
)

copy /Y "%SRC%\Core.lua" "%DST%\Core.lua"
if errorlevel 1 (
    echo FAILED copying Core.lua
    goto :end
)

copy /Y "%SRC%\FriendlyPlates.lua" "%DST%\FriendlyPlates.lua"
if errorlevel 1 (
    echo FAILED copying FriendlyPlates.lua
    goto :end
)

copy /Y "%SRC%\EnemyPlates.lua" "%DST%\EnemyPlates.lua"
if errorlevel 1 (
    echo FAILED copying EnemyPlates.lua
    goto :end
)

rem Remove the old pre-v3.0 monolithic file from the game folder if it's
rem still there - it's no longer listed in the .toc, so leaving it behind
rem would just be confusing dead weight (harmless, but pointless).
if exist "%DST%\COA_GuardianPlates.lua" (
    echo Removing superseded COA_GuardianPlates.lua from game folder...
    del /Q "%DST%\COA_GuardianPlates.lua"
)

rem Remove the old pre-v3.0.1 GuardianPlates.lua from the game folder if
rem it's still there - renamed to FriendlyPlates.lua, no longer listed in
rem the .toc.
if exist "%DST%\GuardianPlates.lua" (
    echo Removing superseded GuardianPlates.lua from game folder...
    del /Q "%DST%\GuardianPlates.lua"
)

rem Remove the old pre-v3.1 ThreatPlates.lua from the game folder if it's
rem still there - renamed to EnemyPlates.lua, no longer listed in the .toc.
if exist "%DST%\ThreatPlates.lua" (
    echo Removing superseded ThreatPlates.lua from game folder...
    del /Q "%DST%\ThreatPlates.lua"
)

rem Sync the embedded Libs folder (LibStub + LibCustomGlow-1.0), needed for
rem the animated threat-glow effect. /E includes subfolders (including
rem empty ones), /Y suppresses overwrite prompts.
if exist "%SRC%\Libs" (
    echo Copying Libs\ ...
    xcopy "%SRC%\Libs" "%DST%\Libs" /E /I /Y >nul
    if errorlevel 1 (
        echo FAILED copying Libs folder
        goto :end
    )
)

echo.
echo Done - Core.lua, FriendlyPlates.lua, EnemyPlates.lua, toc, and Libs copied.
echo Reload/relaunch the game to pick up the update.

:end
pause
