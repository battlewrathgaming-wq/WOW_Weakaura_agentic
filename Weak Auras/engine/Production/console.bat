@echo off
rem Spawn the Production console in its own terminal. Double-click, or let the menu launch it (deferred wiring).
cd /d "%~dp0"
title COA Production console
py console.py
