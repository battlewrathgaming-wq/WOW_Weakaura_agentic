const { contextBridge, ipcRenderer } = require('electron');

// Only the two bridges Pane Board's renderer actually calls (verified by
// grepping pane-board.js for window.* usage before trimming this down) -
// the AURA-Lab original also exposed a generic `window.aura` service-
// registry bridge that nothing here ever used.

contextBridge.exposeInMainWorld('boardWindow', {
  getState: () => ipcRenderer.invoke('board:window:get-state'),
  setAlwaysOnTop: (enabled) => ipcRenderer.invoke('board:window:set-always-on-top', enabled === true),
  minimize: () => ipcRenderer.invoke('board:window:minimize'),
  close: () => ipcRenderer.invoke('board:window:close')
});

contextBridge.exposeInMainWorld('paneBoard', {
  load: () => ipcRenderer.invoke('board:pane-board:load'),
  revision: () => ipcRenderer.invoke('board:pane-board:revision'),
  save: (board, reason = 'save') => ipcRenderer.invoke('board:pane-board:save', { board, reason }),
  snapshot: (request) => ipcRenderer.invoke('board:pane-board:snapshot', request),
  exportPng: (request = {}) => ipcRenderer.invoke('board:pane-board:export-png', request),
  capture: (request = {}) => ipcRenderer.invoke('board:pane-board:capture', request),
  listSnapshots: () => ipcRenderer.invoke('board:pane-board:list-snapshots'),
  loadSnapshot: (snapshotPath) => ipcRenderer.invoke('board:pane-board:load-snapshot', snapshotPath)
});
