const { contextBridge, ipcRenderer } = require('electron');

// Only the two bridges Pane Board's renderer actually calls (verified by
// grepping pane-board.js for window.* usage before trimming this down) -
// the AURA-Lab original also exposed a generic `window.aura` service-
// registry bridge that nothing here ever used.

contextBridge.exposeInMainWorld('auraWindow', {
  getState: () => ipcRenderer.invoke('aura:window:get-state'),
  setAlwaysOnTop: (enabled) => ipcRenderer.invoke('aura:window:set-always-on-top', enabled === true),
  minimize: () => ipcRenderer.invoke('aura:window:minimize'),
  close: () => ipcRenderer.invoke('aura:window:close')
});

contextBridge.exposeInMainWorld('auraPaneBoard', {
  load: () => ipcRenderer.invoke('aura:pane-board:load'),
  revision: () => ipcRenderer.invoke('aura:pane-board:revision'),
  save: (board, reason = 'save') => ipcRenderer.invoke('aura:pane-board:save', { board, reason }),
  snapshot: (request) => ipcRenderer.invoke('aura:pane-board:snapshot', request),
  exportPng: (request = {}) => ipcRenderer.invoke('aura:pane-board:export-png', request),
  capture: (request = {}) => ipcRenderer.invoke('aura:pane-board:capture', request),
  listOpportunityTypes: () => ipcRenderer.invoke('aura:pane-board:list-opportunity-types'),
  listImportableClasses: () => ipcRenderer.invoke('aura:pane-board:list-importable-classes'),
  importClassLayout: (className) => ipcRenderer.invoke('aura:pane-board:import-class-layout', className),
  listSnapshots: () => ipcRenderer.invoke('aura:pane-board:list-snapshots'),
  loadSnapshot: (snapshotPath) => ipcRenderer.invoke('aura:pane-board:load-snapshot', snapshotPath),
  listMaskSlots: () => ipcRenderer.invoke('aura:pane-board:list-mask-slots')
});
