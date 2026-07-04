@echo off
cd /d "%~dp0"

echo ============================================
echo   WOW_Weakaura_agentic - Status Check
echo ============================================
echo (read-only - this does not change or upload anything)
echo.

echo === Current branch / sync state ===
git status

echo.
echo === Last 5 commits ===
git log -5 --oneline

echo.
pause
