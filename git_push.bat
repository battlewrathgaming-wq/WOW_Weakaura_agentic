@echo off
setlocal enabledelayedexpansion
set LOGFILE=%~dp0git_push_log.txt
cd /d "%~dp0"

echo ============================================
echo   WOW_Weakaura_agentic - Commit and Push
echo ============================================
echo.

> "%LOGFILE%" 2>&1 (
  echo === git status ===
  git status
)
type "%LOGFILE%"
echo.

set /p COMMITMSG=Enter a commit message (or press Enter for a default one):
if "%COMMITMSG%"=="" (
  for /f "tokens=1-3 delims=/ " %%a in ("%date%") do set DATESTAMP=%%a-%%b-%%c
  set COMMITMSG=Update - !DATESTAMP! !time!
)

echo.
echo Using commit message: !COMMITMSG!
echo.

>> "%LOGFILE%" 2>&1 (
  echo.
  echo === git add -A ===
  git add -A

  echo === git commit ===
  git commit -m "!COMMITMSG!"

  echo === git push origin main ===
  git push origin main

  echo === DONE ===
)

echo.
echo ---- Result ----
type "%LOGFILE%"
echo.
echo Finished. Full log saved to git_push_log.txt in this folder.
echo If GitHub asked you to sign in just now, please finish that in the popup window,
echo then run this script again to complete the push.
echo.
pause
