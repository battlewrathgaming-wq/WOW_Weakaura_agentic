/**
 * Weak Auras Pane Board - standalone Electron entry point.
 *
 * This app IS Pane Board - unlike the AURA-Lab original (where Pane
 * Board was one env-var-gated mode inside a much larger presentation
 * app, wired through a shared "service registry" that this tool never
 * needed), there is no other mode to select and no service-registry
 * bridge. Trimmed down to exactly two things: the generic Frame window
 * chrome (pin/minimize/close, from src/modules/Frame - copied verbatim,
 * it was already fully generic) and the Pane Board module itself
 * (src/main/labTooling/paneBoard/paneBoard.js - copied verbatim except
 * for "Aura Lab" branding strings and the now-unused mode-gate env var).
 */
const path = require('node:path');
const { app, BrowserWindow, ipcMain } = require('electron');
const { registerFrameWindowHandlers } = require('../modules/Frame');
const { createPaneBoardWindow, registerPaneBoardHandlers, isPaneBoardSmokeMode } = require('./labTooling/paneBoard/paneBoard');

let mainWindow = null;

if (isPaneBoardSmokeMode()) {
  app.disableHardwareAcceleration();
}

function waitForLoad(window) {
  if (!window.webContents.isLoading()) {
    return Promise.resolve();
  }
  return new Promise((resolve) => {
    window.webContents.once('did-finish-load', resolve);
  });
}

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function createWindow() {
  return createPaneBoardWindow({
    app,
    preload: path.join(__dirname, 'preload.js'),
    setMainWindow: (window) => {
      mainWindow = window;
    },
    waitForLoad,
    delay
  });
}

app.whenReady().then(() => {
  registerFrameWindowHandlers(ipcMain, app, () => mainWindow);
  registerPaneBoardHandlers(ipcMain, () => mainWindow);
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
