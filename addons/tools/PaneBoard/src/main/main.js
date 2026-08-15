/**
 * COA Pane Board - standalone Electron entry point.
 *
 * A spatial board for the COA_DungeonRun panes, and NOTHING else. Its one
 * job is answering taste questions the inventory cannot - "how big should
 * this be", "does it sit right" - by letting you drag the real rectangles
 * at real size. `addons/planning/dungeonrun_interface_inventory.md` stays the authority;
 * this carries no zone, kind or subject and never will, because the same
 * fact in two files is two files that must agree with nothing watching.
 *
 * Copied from the aura bench's own fork (`Weak Auras/Tools/PaneBoard`),
 * itself a fork of a tool from an unrelated project called AURA-Lab. A
 * COPY, not a shared instance - the same call he made for geometry.py.
 * Everything WeakAuras-specific was cut; see README.md for the list.
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
