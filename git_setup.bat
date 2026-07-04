@echo off
setlocal
set LOGFILE=%~dp0git_setup_log.txt
cd /d "%~dp0"

> "%LOGFILE%" 2>&1 (
  echo === Removing old/broken .git folder if present ===
  if exist .git rmdir /s /q .git

  echo === git init ===
  git init

  echo === git branch -M main ===
  git branch -M main

  echo === git remote add origin ===
  git remote add origin https://github.com/battlewrathgaming-wq/WOW_Weakaura_agentic.git

  echo === git add -A ===
  git add -A

  echo === git commit ===
  git commit -m "Initial commit: WeakAuras procedural HUD system (Necromancer)"

  echo === git push -u origin main ===
  git push -u origin main

  echo === DONE ===
)

echo.
echo Finished. See git_setup_log.txt in this folder for full details.
echo If GitHub asked you to sign in just now, please finish that in the popup window.
echo.
pause
