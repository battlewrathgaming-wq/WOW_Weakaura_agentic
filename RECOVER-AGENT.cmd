@echo off
setlocal
cd /d "%~dp0"

rem ============================================================================
rem  RECOVER-AGENT.cmd - Battlewrath launches this. Nothing else does.
rem
rem  WHY IT IS AT THE REPO ROOT AND NOT IN operations/: in a hurry you should not
rem  have to remember where it lives. It is the one file here whose whole job is
rem  to be findable.
rem
rem  WHY IT IS A .cmd AND NOT PYTHON OR NODE: it must not depend on anything the
rem  agent depends on. cmd built-ins only - move, if exist, echo. No PATH lookup,
rem  no interpreter, no parser that a bad config could confuse. Git is used ONLY
rem  for the restore, and if git is missing the script says so and the manual
rem  rename still works.
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

if /i "%~1"=="off" goto :off
if /i "%~1"=="on"  goto :on

:status
echo.
echo   AGENT CONFIG RECOVERY
echo   ---------------------------------------------------------------
if exist "%S%"   echo   project settings : ACTIVE    %S%
if not exist "%S%" echo   project settings : disabled  ^(none loaded^)
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
echo   RECOVER-AGENT off    move the project settings aside  ^(clears hooks + bounds^)
echo   RECOVER-AGENT on     put them back, or restore from git
echo.
echo   After "off": start a NEW agent session. A running one may hold the old
echo   config in memory - the settings watcher does not always re-read.
echo.
goto :eof

:off
if not exist "%S%" (
  echo   Project settings are already disabled. Nothing to do.
  echo   If the terminal is still stuck, check the USER-level file named above.
  goto :eof
)
if exist "%OFF%" del "%OFF%"
move /y "%S%" "%OFF%" >nul
if errorlevel 1 (
  echo   [!] COULD NOT MOVE %S% - check it is not open in an editor.
  goto :eof
)
echo.
echo   Project settings moved to %OFF%
echo   No hooks and no permission bounds are loaded from this repo now.
echo.
echo   NEXT: start a NEW agent session, then fix the config, then RECOVER-AGENT on.
echo.
goto :eof

:on
if exist "%OFF%" (
  move /y "%OFF%" "%S%" >nul
  echo   Restored %S% from the parked copy.
  goto :verify
)
where git >nul 2>&1
if errorlevel 1 (
  echo   [!] No parked copy and git is not on PATH. Restore by hand:
  echo       the file is tracked, so any git client can check out .claude\settings.json
  goto :eof
)
git checkout -- .claude\settings.json .claude\hooks
if errorlevel 1 (
  echo   [!] git checkout failed. The repo may have uncommitted work - check by hand.
  goto :eof
)
echo   Restored .claude\settings.json and .claude\hooks from git.

:verify
echo.
where py >nul 2>&1
if errorlevel 1 (
  echo   ^(py not on PATH - skipping the verification run.^)
) else (
  echo   Verifying:
  py operations\toolcheck.py
)
goto :eof
