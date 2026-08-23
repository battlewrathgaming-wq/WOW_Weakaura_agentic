@echo off
setlocal
cd /d "%~dp0"

rem ============================================================================
rem  RECOVER-AGENT.cmd - Battlewrath launches this. Nothing else does.
rem
rem  THIS FILE IS DELIBERATELY BORING: PURE ASCII, CRLF LINE ENDINGS, cmd
rem  built-ins only. Its whole job is to work when everything else is broken, so
rem  it must not itself depend on anything clever.
rem
rem  *** AND BOTH OF THOSE ARE WRITTEN HERE BECAUSE IT FAILED ON THEM (2026-08-22)
rem  The first version was UTF-8 with LF endings. cmd.exe requires CRLF, so once
rem  the file grew past a few lines it stopped honouring "@echo off" and BEGAN
rem  EXECUTING ITS OWN COMMENTS - forty "not recognized as an internal command"
rem  errors from its own documentation. A recovery tool that runs its comments is
rem  worse than no recovery tool, because it is trusted at the worst moment.
rem  It passed its earlier tests by luck: the file was short enough.
rem
rem  WHY .cmd AND NOT PYTHON OR NODE: no interpreter, no PATH lookup, no parser a
rem  bad config could confuse. Git is used only as one restore tier, and there is
rem  a tier below it that needs nothing at all.
rem
rem  WHAT DEADLOCK LOOKS LIKE
rem    - every Bash command comes back refused (a PreToolUse hook too wide)
rem    - every Bash command hangs (a hook that never exits)
rem    - the agent cannot edit the config that would fix it (a permission deny)
rem  In all three the agent cannot rescue itself, because the tool it would use
rem  is the tool that is blocked. THIS IS THE OUTSIDE LEVER.
rem
rem  WHAT IT DOES: moves .claude\settings.json aside. With no settings file there
rem  are no hooks and no permission bounds, so the terminal path is clear. That
rem  is deliberately the crudest possible fix - it cannot itself get stuck.
rem ============================================================================

set "S=.claude\settings.json"
set "OFF=.claude\settings.json.disabled"

if /i "%~1"=="off" goto off
if /i "%~1"=="on"  goto on

:status
echo.
echo   AGENT CONFIG RECOVERY
echo   ---------------------------------------------------------------
if exist "%S%" (echo   project settings : ACTIVE    %S%) else (echo   project settings : disabled  [none loaded])
if exist "%OFF%" echo   a disabled copy is parked at  %OFF%
if exist ".claude\hooks\no-shell-python.js" (echo   refusal hook     : present) else (echo   refusal hook     : ABSENT)
if exist "%USERPROFILE%\.claude\settings.json" (
  echo.
  echo   [!] A USER-LEVEL settings file also exists:
  echo       %USERPROFILE%\.claude\settings.json
  echo       This script does NOT touch it. If the deadlock survives "off",
  echo       that file is the next place to look.
)
echo.
echo   RECOVER-AGENT off    move the project settings aside [clears hooks + bounds]
echo   RECOVER-AGENT on     put them back: parked copy, else git, else embedded
echo.
echo   After "off": start a NEW agent session. A running one may hold the old
echo   config in memory - the settings watcher does not always re-read.
echo.
goto end

:off
if not exist "%S%" (
  echo   Project settings are already disabled. Nothing to do.
  echo   If the terminal is still stuck, check the USER-level file named above.
  goto end
)
if exist "%OFF%" del "%OFF%"
move /y "%S%" "%OFF%" >nul
if errorlevel 1 (
  echo   [!] COULD NOT MOVE %S% - check it is not open in an editor.
  goto end
)
echo.
echo   Project settings moved to %OFF%
echo   No hooks and no permission bounds are loaded from this repo now.
echo.
echo   NEXT: start a NEW agent session, then fix the config, then RECOVER-AGENT on.
echo.
goto end

:on
if not exist "%OFF%" goto trygit
move /y "%OFF%" "%S%" >nul
echo   Restored %S% from the parked copy.
goto verify

:trygit
where git >nul 2>&1
if errorlevel 1 goto embedded
git checkout -- .claude\settings.json .claude\hooks
if errorlevel 1 goto embedded
echo   Restored .claude\settings.json and .claude\hooks from git.
goto verify

rem  TIER 3 - no parked copy, no usable git. Written out from this file.
rem  Measured 2026-08-22: git IS on the MACHINE PATH here (D:\Program Files\Git\
rem  cmd), so an Explorer-launched cmd does find it. This tier is not for today -
rem  it is for the day git is gone, or the repo is mid-rebase or detached and
rem  checkout refuses. A recovery whose last resort is "restore by hand" is not a
rem  recovery.
rem  *** IT IS A SECOND COPY OF THE DECLARATION, which is the fault this project
rem  keeps naming - so operations\toolcheck.py ASSERTS the two agree. A copy a
rem  machine reconciles cannot drift; one nobody checks is the thing to fear.
:embedded
echo   No parked copy and git could not restore. Writing the EMBEDDED known-good.
> "%S%" echo {
>>"%S%" echo   "permissions": {
>>"%S%" echo     "deny": [
>>"%S%" echo       "Edit(.claude/settings.local.json)",
>>"%S%" echo       "Write(.claude/settings.local.json)"
>>"%S%" echo     ],
>>"%S%" echo     "ask": [
>>"%S%" echo       "Edit(.claude/settings.json)",
>>"%S%" echo       "Write(.claude/settings.json)",
>>"%S%" echo       "Edit(.claude/hooks/**)",
>>"%S%" echo       "Write(.claude/hooks/**)"
>>"%S%" echo     ]
>>"%S%" echo   },
>>"%S%" echo   "hooks": {
>>"%S%" echo     "PreToolUse": [
>>"%S%" echo       {
>>"%S%" echo         "matcher": "Bash",
>>"%S%" echo         "hooks": [
>>"%S%" echo           {
>>"%S%" echo             "type": "command",
>>"%S%" echo             "command": "node .claude/hooks/no-shell-python.js",
>>"%S%" echo             "timeout": 10,
>>"%S%" echo             "statusMessage": "checking the instrument"
>>"%S%" echo           }
>>"%S%" echo         ]
>>"%S%" echo       },
>>"%S%" echo       {
>>"%S%" echo         "matcher": "Write",
>>"%S%" echo         "hooks": [
>>"%S%" echo           {
>>"%S%" echo             "type": "command",
>>"%S%" echo             "command": "node .claude/hooks/no-write-over.js",
>>"%S%" echo             "timeout": 10,
>>"%S%" echo             "statusMessage": "checking what is already there"
>>"%S%" echo           }
>>"%S%" echo         ]
>>"%S%" echo       }
>>"%S%" echo     ]
>>"%S%" echo   }
>>"%S%" echo }
echo   Written from the embedded copy.
echo   [!] The HOOK FILES are not embedded. If .claude\hooks is also missing the
echo       settings point at nothing and NO REFUSAL RUNS - restore those from git.

:verify
echo.
where py >nul 2>&1
if errorlevel 1 (
  echo   [py not on PATH - skipping the verification run.]
  goto end
)
echo   Verifying:
py operations\toolcheck.py

:end
endlocal
