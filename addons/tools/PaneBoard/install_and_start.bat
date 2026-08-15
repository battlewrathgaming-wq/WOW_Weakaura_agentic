@echo off
setlocal
set LOGFILE=%~dp0install_and_start_log.txt
cd /d "%~dp0"

> "%LOGFILE%" 2>&1 (
  echo === npm install ===
  call npm install

  echo === npm start ===
  call npm start

  echo === DONE ===
)

echo.
echo Finished. See install_and_start_log.txt in this folder for full details.
echo If a Pane Board window opened, leave it open - that's the real check.
echo This window will stay open (npm start blocks) until you close the Pane
echo Board window itself.
echo.
pause
