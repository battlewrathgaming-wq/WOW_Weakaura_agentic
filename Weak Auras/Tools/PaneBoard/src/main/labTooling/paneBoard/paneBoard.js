const path = require('node:path');
const fs = require('node:fs');
const { execFileSync } = require('node:child_process');
const { createFrameWindow } = require('../../../modules/Frame');

const PANE_BOARD_ROOT = path.join(process.cwd(), 'workspace', 'pane-board');
// Templates/schemas/*.schema.json is this project's single source of truth
// for opportunity-type field shapes (see Templates/build_templates.py's
// REGISTRY/FRAGMENTS + write_all()). Pane Board reads them at runtime
// instead of hand-maintaining a second copy of the same field lists.
const SCHEMAS_ROOT = path.join(process.cwd(), '..', '..', 'Templates', 'schemas');
// Weak Auras project root - where each class folder (Necromancer/, Reaper/)
// and its own inventory.py lives. Same "two levels up from Tools/PaneBoard"
// relationship as SCHEMAS_ROOT above.
const PROJECT_ROOT = path.join(process.cwd(), '..', '..');
const EXPORT_INVENTORY_SCRIPT = path.join(process.cwd(), 'scripts', 'export_inventory.py');
// ELEMENT_INVENTORY.md's full documented slot mask (every row A-F of the
// scaffold, not just whatever a given class's inventory.py has actually
// built yet). Same one-way, read-only relationship as EXPORT_INVENTORY_SCRIPT
// above: parse_element_inventory.py only ever reads ELEMENT_INVENTORY.md and
// prints JSON, never writes anything back.
const PARSE_ELEMENT_INVENTORY_SCRIPT = path.join(process.cwd(), 'scripts', 'parse_element_inventory.py');

function isPaneBoardSmokeMode() {
  return process.env.WA_PANE_BOARD_SMOKE === '1';
}

function createPaneBoardWindow({ app, preload, setMainWindow, waitForLoad, delay }) {
  const window = createFrameWindow(app, {
    width: 960,
    height: 640,
    minWidth: 720,
    minHeight: 640,
    title: 'Weak Auras Pane Board',
    preload,
    backgroundColor: '#101416',
    defaultAlwaysOnTop: false
  });

  setMainWindow(window);
  window.webContents.on('render-process-gone', (_event, details) => {
    if (isPaneBoardSmokeMode()) {
      writePaneBoardSmokeResult({
        status: 'failed',
        message: `Pane Board renderer exited: ${details.reason}`,
        checked_at: new Date().toISOString(),
        details
      });
    }
  });
  window.loadFile(path.join(__dirname, '..', '..', '..', 'renderer', 'pane-board', 'index.html')).catch((error) => {
    if (isPaneBoardSmokeMode()) {
      writePaneBoardSmokeResult({
        status: 'failed',
        message: error.message,
        checked_at: new Date().toISOString()
      });
    }
    app.quit();
  });
  if (isPaneBoardSmokeMode()) {
    runPaneBoardSmoke({ app, window, waitForLoad, delay }).catch((error) => {
      writePaneBoardSmokeResult({
        status: 'failed',
        message: error.message,
        checked_at: new Date().toISOString()
      });
      app.quit();
    });
  }
  return window;
}

function registerPaneBoardHandlers(ipcMain, getWindow) {
  ipcMain.handle('aura:pane-board:load', () => readPaneBoard());
  ipcMain.handle('aura:pane-board:revision', () => paneBoardRevision());
  ipcMain.handle('aura:pane-board:save', (_event, request = {}) => writePaneBoard(request.board, request.reason));
  ipcMain.handle('aura:pane-board:snapshot', (_event, request = {}) => snapshotPaneBoard(request));
  ipcMain.handle('aura:pane-board:export-png', (_event, request = {}) => exportPaneBoardPng(getWindow(), request));
  ipcMain.handle('aura:pane-board:capture', (_event, request = {}) => capturePaneBoard(getWindow(), request));
  ipcMain.handle('aura:pane-board:list-opportunity-types', () => listOpportunityTypes());
  ipcMain.handle('aura:pane-board:list-importable-classes', () => listImportableClasses());
  ipcMain.handle('aura:pane-board:import-class-layout', (_event, className) => importClassLayout(className));
  ipcMain.handle('aura:pane-board:list-snapshots', () => listPaneBoardSnapshots());
  ipcMain.handle('aura:pane-board:load-snapshot', (_event, snapshotPath) => loadPaneBoardSnapshot(snapshotPath));
  ipcMain.handle('aura:pane-board:list-mask-slots', () => listMaskSlots());
}

// Snapshot files live under human-sketches/, agent-proposals/, and
// accepted-layouts/ (see paneBoardSnapshotDir) - captures/ is deliberately
// excluded, since a capture wraps a board inside {id, title, kind, source,
// board, screenshot} rather than being a board itself at the top level.
function listPaneBoardSnapshots() {
  const paths = ensurePaneBoardDirs();
  const dirs = [
    { dir: paths.human, status: 'human-sketch' },
    { dir: paths.agent, status: 'agent-proposal' },
    { dir: paths.accepted, status: 'human-accepted' }
  ];
  const entries = [];
  for (const { dir } of dirs) {
    if (!fs.existsSync(dir)) {
      continue;
    }
    for (const file of fs.readdirSync(dir)) {
      if (!file.endsWith('.json')) {
        continue;
      }
      const fullPath = path.join(dir, file);
      let title = file;
      let status = 'human-sketch';
      let basedOn = null;
      try {
        const parsed = JSON.parse(fs.readFileSync(fullPath, 'utf8'));
        title = parsed.title || file;
        status = paneBoardStatus(parsed.status);
        basedOn = parsed.source?.basedOn || null;
      } catch (error) {
        // Unreadable/corrupt snapshot - still list it (by filename) so it's
        // visible, rather than silently hiding a file that exists on disk.
      }
      const stat = fs.statSync(fullPath);
      entries.push({
        path: fullPath,
        relativePath: path.relative(PANE_BOARD_ROOT, fullPath),
        title,
        status,
        basedOn,
        mtimeMs: stat.mtimeMs
      });
    }
  }
  entries.sort((a, b) => b.mtimeMs - a.mtimeMs);
  return entries;
}

// Loads a snapshot file INTO the live view (overwrites current-board.json)
// - the one operation that's actually destructive to whatever's currently
// open, so it auto-snapshots the current board first (same mechanism as
// the "Grab state" button) rather than silently discarding it. The
// snapshot itself is untouched by this - loading it doesn't delete or move
// the source file, so re-loading it again later still works.
function loadPaneBoardSnapshot(snapshotPath) {
  const paths = ensurePaneBoardDirs();
  const allowedDirs = [paths.human, paths.agent, paths.accepted];
  const resolved = path.resolve(String(snapshotPath || ''));
  const withinAllowedDir = allowedDirs.some((dir) => resolved.startsWith(`${path.resolve(dir)}${path.sep}`));
  if (!withinAllowedDir || !fs.existsSync(resolved)) {
    const error = new Error(`'${snapshotPath}' is not a known Pane Board snapshot file.`);
    error.code = 'PANE_BOARD_UNKNOWN_SNAPSHOT';
    throw error;
  }

  let parsed;
  try {
    parsed = JSON.parse(fs.readFileSync(resolved, 'utf8'));
  } catch (error) {
    const wrapped = new Error(`Could not parse snapshot '${snapshotPath}': ${error.message}`);
    wrapped.code = 'PANE_BOARD_SNAPSHOT_PARSE_FAILED';
    throw wrapped;
  }

  const currentBoard = readPaneBoard();
  const backup = snapshotPaneBoard({
    board: currentBoard,
    status: currentBoard.status === 'agent-proposal' ? 'agent-proposal' : 'human-sketch',
    title: `${currentBoard.title} (before loading ${parsed.title || 'snapshot'})`,
    basedOn: currentBoard.source?.basedOn || currentBoard.id
  });

  const loaded = writePaneBoard(parsed, 'snapshot-loaded');
  appendPaneBoardEvent({
    type: 'snapshot-loaded',
    loadedFrom: path.relative(PANE_BOARD_ROOT, resolved),
    boardId: loaded.id,
    backupPath: path.relative(PANE_BOARD_ROOT, backup.path)
  });
  return {
    board: loaded,
    backupPath: backup.path
  };
}

// `python3` is the right command on the sandbox/Linux/macOS, but a stock
// Windows machine (Battlewrath's real box, confirmed via
// install_and_start_log.txt 2026-07-06 on both Necromancer and Reaper)
// usually only has `python.exe`/`py.exe` on PATH - `python3` there resolves
// to the Microsoft Store's "App execution alias" stub, which prints
// "Python was not found; run without arguments to install from the
// Microsoft Store..." instead of actually running anything. Probe a short
// list of candidates once per process and cache whichever one actually
// runs `--version` successfully, rather than hard-coding one name.
let cachedPythonCommand = null;
function resolvePythonCommand() {
  if (cachedPythonCommand) {
    return cachedPythonCommand;
  }
  const candidates = process.platform === 'win32' ? ['py', 'python', 'python3'] : ['python3', 'python'];
  for (const candidate of candidates) {
    try {
      execFileSync(candidate, ['--version'], { encoding: 'utf8', stdio: ['ignore', 'ignore', 'ignore'] });
      cachedPythonCommand = candidate;
      return candidate;
    } catch (error) {
      // Try the next candidate - ENOENT (missing) and the Windows Store
      // alias stub (which exits non-zero rather than throwing ENOENT) both
      // land here.
    }
  }
  const error = new Error(`Could not find a working Python interpreter (tried: ${candidates.join(', ')}). Install Python from python.org and ensure it's on PATH.`);
  error.code = 'PANE_BOARD_NO_PYTHON';
  throw error;
}

// Any folder directly under the project root that has its own inventory.py
// is importable - same convention layer_builder.py already relies on
// (`python3 layer_builder.py <class folder> <inventory.py path> <layer>`).
function listImportableClasses() {
  if (!fs.existsSync(PROJECT_ROOT)) {
    return [];
  }
  return fs.readdirSync(PROJECT_ROOT, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name)
    .filter((name) => fs.existsSync(path.join(PROJECT_ROOT, name, 'inventory.py')))
    .sort();
}

// One-way, read-only import: propagates a board FROM a class's already-
// shipped inventory.py, instead of a human manually redrawing panes to
// match what's already built (Battlewrath, 2026-07-06: "the ability to
// propagate the board from the index... instead of having to manually
// rebuild the current known UI per class by hand"). This NEVER writes back
// to inventory.py, and it never touches the currently-open board.json -
// see snapshotPaneBoard() above for the same "write to its own file, keyed
// by status" pattern this reuses. The result is tagged human-accepted
// (this mirrors currently-shipped, already-decided content, not a fresh
// sketch) with source.basedOn recording exactly which inventory.py it came
// from, so it's never confused with a from-scratch prototype.
function importClassLayout(className) {
  const allowed = listImportableClasses();
  if (!allowed.includes(className)) {
    const error = new Error(`'${className}' is not an importable class (no inventory.py found). Known: ${allowed.join(', ') || 'none'}`);
    error.code = 'PANE_BOARD_UNKNOWN_CLASS';
    throw error;
  }

  let raw;
  try {
    const pythonCommand = resolvePythonCommand();
    raw = execFileSync(pythonCommand, [EXPORT_INVENTORY_SCRIPT, className], { encoding: 'utf8', cwd: process.cwd() });
  } catch (error) {
    const wrapped = new Error(`export_inventory.py failed for '${className}': ${error.message}`);
    wrapped.code = error.code === 'PANE_BOARD_NO_PYTHON' ? error.code : 'PANE_BOARD_IMPORT_EXEC_FAILED';
    throw wrapped;
  }

  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch (error) {
    const wrapped = new Error(`export_inventory.py returned non-JSON output for '${className}'.`);
    wrapped.code = 'PANE_BOARD_IMPORT_BAD_OUTPUT';
    throw wrapped;
  }
  if (parsed.error) {
    const error = new Error(parsed.error);
    error.code = 'PANE_BOARD_IMPORT_SOURCE_ERROR';
    throw error;
  }

  const schemasById = new Map(listOpportunityTypes().map((schema) => [schema.id, schema]));
  const width = 960;
  const height = 640;
  const centerX = width / 2;
  const centerY = height / 2;

  // Tracks running placement offset per dynamicgroup layer, since a
  // dynamicgroup's slots only carry LOCAL x:0,y:0 (real position comes from
  // WeakAuras' own runtime flow layout via group_layout.grow/space) - not
  // something this importer can reproduce exactly without reimplementing
  // that layout engine. Approximates it by laying slots out along the
  // group's own grow direction, spaced by group_layout.space plus each
  // slot's own width/height, purely so the sketch board shows them as a
  // cluster near the real anchor rather than all stacked on one point.
  const dynamicGroupCursors = new Map();

  const panes = [];
  let index = 0;
  for (const entry of parsed.layers || []) {
    index += 1;
    const schema = schemasById.get(entry.template) || null;
    const params = entry.params || {};
    const fields = {};
    for (const [key, value] of Object.entries(params)) {
      if (key === 'x' || key === 'y') {
        continue;
      }
      fields[key] = value;
    }
    const fieldWidth = Number(params.width);
    const fieldHeight = Number(params.height);
    const schemaWidth = Number(schema?.properties?.width?.default);
    const schemaHeight = Number(schema?.properties?.height?.default);
    const paneWidth = Number.isFinite(fieldWidth) && fieldWidth > 0
      ? fieldWidth
      : (Number.isFinite(schemaWidth) && schemaWidth > 0 ? schemaWidth : 40);
    const paneHeight = Number.isFinite(fieldHeight) && fieldHeight > 0
      ? fieldHeight
      : (Number.isFinite(schemaHeight) && schemaHeight > 0 ? schemaHeight : 30);

    let realX = Number(params.x);
    let realY = Number(params.y);
    let approximated = false;
    if (entry.region_type === 'dynamicgroup' && entry.group_layout) {
      approximated = true;
      const anchorX = Number(entry.group_layout.xOffset) || 0;
      const anchorY = Number(entry.group_layout.yOffset) || 0;
      const space = Number(entry.group_layout.space) || 0;
      const grow = String(entry.group_layout.grow || 'RIGHT').toUpperCase();
      const cursor = dynamicGroupCursors.get(entry.layer) || 0;
      const advance = grow === 'DOWN' || grow === 'UP' ? paneHeight : paneWidth;
      const sign = grow === 'LEFT' || grow === 'UP' ? -1 : 1;
      realX = grow === 'DOWN' || grow === 'UP' ? anchorX : anchorX + sign * cursor;
      realY = grow === 'DOWN' || grow === 'UP' ? anchorY - sign * cursor : anchorY;
      dynamicGroupCursors.set(entry.layer, cursor + advance + space);
    }
    if (!Number.isFinite(realX)) {
      realX = 0;
    }
    if (!Number.isFinite(realY)) {
      realY = 0;
    }

    const label = String(params.name || `${entry.layer} ${index}`);
    const noteParts = [`Imported from ${className}/inventory.py, layer "${entry.layer}".`];
    if (approximated) {
      noteParts.push('Position is an APPROXIMATION: this slot belongs to a dynamicgroup whose real position comes from WeakAuras\' own runtime flow layout (grow/space), not a fixed x/y - do not treat this pane\'s exact coordinates as authoritative.');
    }
    if (!schema) {
      noteParts.push(`No known schema for template "${entry.template}" - width/height fell back to a 40x30 default.`);
    }

    panes.push({
      id: `${entry.layer}-${label}-${index}`,
      label,
      grid: {
        x: centerX + realX - paneWidth / 2,
        y: centerY - realY - paneHeight / 2,
        w: paneWidth,
        h: paneHeight
      },
      importance: 'supporting',
      locked: false,
      opportunityType: entry.template || '',
      fields,
      notes: noteParts.join(' ')
    });
  }

  const title = `${className} - imported from inventory.py`;
  const board = {
    title,
    status: 'human-accepted',
    viewport: { preset: '960x640', width, height, grid: 1 },
    source: {
      createdBy: 'human',
      basedOn: `${className}/inventory.py`,
      project: 'Weak Auras',
      context: `Auto-imported snapshot of ${className}'s currently shipped layout, generated ${new Date().toISOString()}. One-way, read-only: re-import to refresh from source; edits made here do NOT write back to inventory.py.`
    },
    panes,
    review: {
      humanIntent: `Mirrors ${className}'s currently shipped Pane layout, for reference while sketching - not itself the source of truth (inventory.py is).`,
      agentNotes: '',
      acceptedByHuman: false
    },
    collaboration: { notes: { human: '', labs: '' }, commands: [] },
    screenNote: `Imported snapshot of ${className}/inventory.py - re-import to refresh, do not hand-edit and expect it to propagate back.`
  };

  const paths = ensurePaneBoardDirs();
  const cleanBoard = normalizePaneBoard(board);
  const targetDir = paneBoardSnapshotDir(paths, cleanBoard.status);
  const targetPath = uniqueLayoutPath(targetDir, cleanBoard.id);
  fs.writeFileSync(targetPath, `${JSON.stringify(cleanBoard, null, 2)}\n`, 'utf8');
  appendPaneBoardEvent({
    type: 'class-layout-imported',
    className,
    boardId: cleanBoard.id,
    paneCount: cleanBoard.panes.length,
    path: path.relative(PANE_BOARD_ROOT, targetPath)
  });
  return {
    board: cleanBoard,
    path: targetPath
  };
}

// Loads ELEMENT_INVENTORY.md's full documented slot mask - every row A-F of
// the intended Template_shadow scaffold, not just whatever a class's own
// inventory.py has built so far - as plain data for the renderer to draw as
// a non-interactive background layer (see pane-board.js's renderMaskLayer()).
// Read-only and one-way, same architecture as importClassLayout() above:
// invokes parse_element_inventory.py via the same resolvePythonCommand()
// probe, converts each slot's real x/y/w/h into this board's canvas-grid
// coordinates using the identical centerX/centerY transform importClassLayout
// uses, and never writes anything - the mask is never added to
// boardState.board.panes, so it can never accidentally get saved into a real
// board file.
function listMaskSlots() {
  let raw;
  try {
    const pythonCommand = resolvePythonCommand();
    raw = execFileSync(pythonCommand, [PARSE_ELEMENT_INVENTORY_SCRIPT], { encoding: 'utf8', cwd: process.cwd() });
  } catch (error) {
    const wrapped = new Error(`parse_element_inventory.py failed: ${error.message}`);
    wrapped.code = error.code === 'PANE_BOARD_NO_PYTHON' ? error.code : 'PANE_BOARD_MASK_EXEC_FAILED';
    throw wrapped;
  }

  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch (error) {
    const wrapped = new Error('parse_element_inventory.py returned non-JSON output.');
    wrapped.code = 'PANE_BOARD_MASK_BAD_OUTPUT';
    throw wrapped;
  }
  if (parsed.error) {
    const error = new Error(parsed.error);
    error.code = 'PANE_BOARD_MASK_SOURCE_ERROR';
    throw error;
  }

  const width = 960;
  const height = 640;
  const centerX = width / 2;
  const centerY = height / 2;

  const slots = (parsed.slots || []).map((slot) => ({
    id: slot.id,
    row: slot.row,
    regionType: slot.regionType || '',
    expectedFunction: slot.expectedFunction || '',
    real: { x: slot.x, y: slot.y, w: slot.w, h: slot.h },
    grid: {
      x: centerX + slot.x - slot.w / 2,
      y: centerY - slot.y - slot.h / 2,
      w: slot.w,
      h: slot.h
    }
  }));

  return { slots };
}

function listOpportunityTypes() {
  if (!fs.existsSync(SCHEMAS_ROOT)) {
    return [];
  }
  const files = fs.readdirSync(SCHEMAS_ROOT).filter((name) => name.endsWith('.schema.json'));
  const summaries = [];
  for (const file of files) {
    let raw;
    try {
      raw = JSON.parse(fs.readFileSync(path.join(SCHEMAS_ROOT, file), 'utf8'));
    } catch (error) {
      continue;
    }
    // Shared fragments (load_conditions, glow_source, power_threshold_effect,
    // press_wash_effect, stack_counter_overlay, class_accent_tick_end) carry
    // no opportunity_type - they compose onto a real template, they aren't
    // one themselves, so they're not offered as a standalone pane type here.
    if (!raw.opportunity_type) {
      continue;
    }
    summaries.push({
      id: file.replace(/\.schema\.json$/, ''),
      opportunityType: raw.opportunity_type,
      regionType: raw.region_type || '',
      title: raw.title || file,
      description: raw.description || '',
      required: Array.isArray(raw.required) ? raw.required : [],
      properties: raw.properties || {}
    });
  }
  summaries.sort((a, b) => a.title.localeCompare(b.title));
  return summaries;
}

async function runPaneBoardSmoke({ app, window, waitForLoad, delay }) {
  await waitForLoad(window);
  await delay(350);
  const board = readPaneBoard();
  const smokeBoard = {
    ...board,
    title: 'Pane Board V1 smoke sketch',
    source: {
      ...(board.source || {}),
      basedOn: board.id
    },
    panes: board.panes.map((pane, index) => index === 0
      ? {
          ...pane,
          grid: {
            ...pane.grid,
            x: pane.grid.x + 1,
            y: pane.grid.y + 1
          }
        }
      : pane)
  };
  const saved = writePaneBoard(smokeBoard, 'pane-board-smoke-save');
  const snapshot = snapshotPaneBoard({
    board: saved,
    status: 'agent-proposal',
    title: 'Pane Board V1 smoke proposal',
    basedOn: board.id
  });
  await window.webContents.executeJavaScript(`
    window.auraPaneBoard.load().then((board) => {
      document.querySelector('#board-title').value = board.title;
    });
  `);
  const png = await exportPaneBoardPng(window, { board: snapshot.board, title: 'pane-board-smoke' });
  const capture = await capturePaneBoard(window, {
    board: saved,
    title: 'Pane Board V1 smoke resting capture',
    sourceArtifact: 'pane-board-smoke',
    humanSignal: 'Smoke capture checks board-local resting state.',
    includeScreenshot: true
  });
  writePaneBoard(board, 'pane-board-smoke-restore');
  const result = {
    status: 'passed',
    message: 'Pane Board smoke passed.',
    checked_at: new Date().toISOString(),
    current_board: path.relative(process.cwd(), paneBoardPaths().current),
    snapshot: path.relative(process.cwd(), snapshot.path),
    png: path.relative(process.cwd(), png.path),
    capture: path.relative(process.cwd(), capture.path),
    capture_screenshot: capture.capture.screenshot,
    board_id: snapshot.board.id,
    based_on: snapshot.board.source.basedOn,
    pane_count: snapshot.board.panes.length
  };
  writePaneBoardSmokeResult(result);
  app.quit();
}

function writePaneBoardSmokeResult(result) {
  const dir = path.join(process.cwd(), '.tmp', 'pane-board-smoke');
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, 'pane-board-smoke-result.json'), `${JSON.stringify(result, null, 2)}\n`, 'utf8');
}

function paneBoardPaths() {
  return {
    root: PANE_BOARD_ROOT,
    current: path.join(PANE_BOARD_ROOT, 'current-board.json'),
    events: path.join(PANE_BOARD_ROOT, 'board-events.ndjson'),
    human: path.join(PANE_BOARD_ROOT, 'human-sketches'),
    agent: path.join(PANE_BOARD_ROOT, 'agent-proposals'),
    accepted: path.join(PANE_BOARD_ROOT, 'accepted-layouts'),
    captures: path.join(PANE_BOARD_ROOT, 'captures'),
    screenshots: path.join(PANE_BOARD_ROOT, 'screenshots'),
    materials: path.join(PANE_BOARD_ROOT, 'materials')
  };
}

function ensurePaneBoardDirs() {
  const paths = paneBoardPaths();
  for (const dir of [paths.root, paths.human, paths.agent, paths.accepted, paths.captures, paths.screenshots, paths.materials]) {
    fs.mkdirSync(dir, { recursive: true });
  }
  return paths;
}

function paneBoardRevision() {
  const paths = ensurePaneBoardDirs();
  if (!fs.existsSync(paths.current)) {
    return {
      exists: false,
      path: path.relative(process.cwd(), paths.current),
      mtimeMs: 0,
      size: 0
    };
  }
  const stat = fs.statSync(paths.current);
  return {
    exists: true,
    path: path.relative(process.cwd(), paths.current),
    mtimeMs: stat.mtimeMs,
    size: stat.size
  };
}

function readPaneBoard() {
  const paths = ensurePaneBoardDirs();
  if (fs.existsSync(paths.current)) {
    return normalizePaneBoard(JSON.parse(fs.readFileSync(paths.current, 'utf8')));
  }
  const board = defaultPaneBoard();
  writePaneBoard(board, 'create-default');
  return board;
}

function writePaneBoard(board, reason = 'save') {
  const paths = ensurePaneBoardDirs();
  const cleanBoard = normalizePaneBoard(board);
  validatePaneBoardOwnership(cleanBoard);
  fs.writeFileSync(paths.current, `${JSON.stringify(cleanBoard, null, 2)}\n`, 'utf8');
  appendPaneBoardEvent({
    type: 'board-saved',
    reason,
    boardId: cleanBoard.id,
    paneCount: cleanBoard.panes.length,
    status: cleanBoard.status
  });
  return cleanBoard;
}

function snapshotPaneBoard({ board, status, title, basedOn } = {}) {
  const paths = ensurePaneBoardDirs();
  const cleanBoard = normalizePaneBoard(board || readPaneBoard());
  const nextStatus = paneBoardStatus(status);
  if (nextStatus === 'agent-proposal' && !basedOn && !cleanBoard.source?.basedOn) {
    const error = new Error('Agent proposals must include basedOn.');
    error.code = 'PANE_BOARD_BASED_ON_REQUIRED';
    throw error;
  }
  const snapshot = {
    ...cleanBoard,
    id: layoutId(title || cleanBoard.title || nextStatus),
    title: String(title || cleanBoard.title || 'Pane Board snapshot').slice(0, 120),
    status: nextStatus,
    source: {
      ...(cleanBoard.source || {}),
      createdBy: nextStatus === 'agent-proposal' ? 'agent' : nextStatus === 'human-sketch' ? 'human' : cleanBoard.source?.createdBy || 'human',
      basedOn: basedOn || cleanBoard.source?.basedOn || null,
      project: 'Weak Auras',
      context: 'layout intent reference'
    },
    updatedAt: new Date().toISOString()
  };
  const targetDir = paneBoardSnapshotDir(paths, nextStatus);
  const targetPath = uniqueLayoutPath(targetDir, snapshot.id);
  fs.writeFileSync(targetPath, `${JSON.stringify(snapshot, null, 2)}\n`, 'utf8');
  appendPaneBoardEvent({
    type: 'snapshot-created',
    status: nextStatus,
    boardId: snapshot.id,
    basedOn: snapshot.source.basedOn,
    path: path.relative(PANE_BOARD_ROOT, targetPath)
  });
  return {
    board: snapshot,
    path: targetPath
  };
}

function validatePaneBoardOwnership(board) {
  if (board?.status === 'agent-proposal') {
    if (board.source?.createdBy !== 'agent') {
      const error = new Error('Agent proposal boards must be agent-authored.');
      error.code = 'PANE_BOARD_AGENT_AUTHOR_REQUIRED';
      throw error;
    }
    if (typeof board.source?.basedOn !== 'string' || board.source.basedOn.length === 0) {
      const error = new Error('Current board cannot be an agent proposal without basedOn.');
      error.code = 'PANE_BOARD_CURRENT_BASED_ON_REQUIRED';
      throw error;
    }
  }
}

async function exportPaneBoardPng(window, { board, title } = {}) {
  const paths = ensurePaneBoardDirs();
  if (!window || window.isDestroyed()) {
    throw new Error('Pane Board window is not available for PNG export.');
  }
  const cleanBoard = normalizePaneBoard(board || readPaneBoard());
  const image = await window.webContents.capturePage();
  const fileBase = slug(`${cleanBoard.id}-${title || 'pane-board'}`) || cleanBoard.id;
  const outputPath = uniquePngPath(paths.screenshots, fileBase);
  fs.writeFileSync(outputPath, image.toPNG());
  appendPaneBoardEvent({
    type: 'png-exported',
    boardId: cleanBoard.id,
    path: path.relative(PANE_BOARD_ROOT, outputPath)
  });
  return {
    path: outputPath
  };
}

async function capturePaneBoard(window, { board, title, sourceArtifact, humanSignal, includeScreenshot } = {}) {
  const paths = ensurePaneBoardDirs();
  const cleanBoard = normalizePaneBoard(board || readPaneBoard());
  validatePaneBoardOwnership(cleanBoard);
  const captureTitle = String(title || cleanBoard.title || 'Pane Board resting capture').slice(0, 120);
  const capture = {
    id: layoutId(captureTitle),
    title: captureTitle,
    kind: 'pane-board-resting-capture',
    createdAt: new Date().toISOString(),
    source: {
      boardId: cleanBoard.id,
      boardTitle: cleanBoard.title,
      boardStatus: cleanBoard.status,
      createdBy: cleanBoard.source?.createdBy || 'human',
      basedOn: cleanBoard.source?.basedOn || null,
      boardUpdatedAt: cleanBoard.updatedAt,
      viewport: cleanBoard.viewport?.preset || '',
      paneCount: cleanBoard.panes.length,
      sourceArtifact: String(sourceArtifact || '').slice(0, 260),
      humanSignal: String(humanSignal || '').slice(0, 500),
      scope: 'board-local layout guidance'
    },
    board: cleanBoard,
    screenshot: null
  };
  if (includeScreenshot === true) {
    const png = await exportPaneBoardPng(window, { board: cleanBoard, title: `${captureTitle}-capture` });
    capture.screenshot = path.relative(PANE_BOARD_ROOT, png.path);
  }
  const targetPath = uniqueLayoutPath(paths.captures, capture.id);
  fs.writeFileSync(targetPath, `${JSON.stringify(capture, null, 2)}\n`, 'utf8');
  appendPaneBoardEvent({
    type: 'capture-created',
    boardId: cleanBoard.id,
    captureId: capture.id,
    path: path.relative(PANE_BOARD_ROOT, targetPath),
    screenshot: capture.screenshot
  });
  return {
    capture,
    path: targetPath
  };
}

function appendPaneBoardEvent(event) {
  const paths = ensurePaneBoardDirs();
  const entry = {
    at: new Date().toISOString(),
    ...event
  };
  fs.appendFileSync(paths.events, `${JSON.stringify(entry)}\n`, 'utf8');
}

function paneBoardSnapshotDir(paths, status) {
  if (status === 'agent-proposal') {
    return paths.agent;
  }
  if (status === 'human-accepted') {
    return paths.accepted;
  }
  return paths.human;
}

function uniqueLayoutPath(dir, id) {
  let candidate = path.join(dir, `${slug(id)}.json`);
  let index = 2;
  while (fs.existsSync(candidate)) {
    candidate = path.join(dir, `${slug(id)}-${index}.json`);
    index += 1;
  }
  return candidate;
}

function uniquePngPath(dir, id) {
  let candidate = path.join(dir, `${slug(id)}.png`);
  let index = 2;
  while (fs.existsSync(candidate)) {
    candidate = path.join(dir, `${slug(id)}-${index}.png`);
    index += 1;
  }
  return candidate;
}

function defaultPaneBoard() {
  return {
    id: layoutId('pane-board-v1'),
    title: 'Pane Board V1 working sketch',
    status: 'human-sketch',
    viewport: {
      preset: '960x640',
      width: 960,
      height: 640,
      // 1 grid unit = 1 canvas px. This is deliberately the same unit
      // WeakAuras' own x/y/width/height fields already use (see
      // Templates/schemas/*.schema.json - x/y/width/height are typed
      // "number", not "integer", and real shipped geometry in
      // Tiers/resources_base.py uses half-unit values like -64.5). A
      // coarser grid here would just be an arbitrary tool convention with
      // no relationship to the real values this board is meant to help
      // author.
      grid: 1
    },
    source: {
      createdBy: 'human',
      basedOn: null,
      project: 'Weak Auras',
      context: 'layout intent sketch'
    },
    panes: [
      pane('status-band', 'Status band', 24, 24, 912, 72, 'primary', 'Glanceable first-read state.'),
      pane('primary-readout', 'Primary readout', 24, 120, 544, 240, 'primary', 'Main shape under discussion.'),
      pane('detail-drawer', 'Detail drawer', 24, 392, 544, 192, 'supporting', 'Longer explanation and comparison space.'),
      pane('notes', 'Notes', 600, 120, 336, 464, 'supporting', 'Soft intent, questions, and alternate relationship notes.')
    ],
    review: {
      humanIntent: 'Use this board to describe spatial intent without turning it into product UI.',
      agentNotes: '',
      acceptedByHuman: false
    },
    collaboration: {
      notes: {
        human: '',
        labs: ''
      },
      commands: []
    },
    screenNote: 'Dev note: this board is a cooperative spatial sketch surface. Treat positions as intent, not instruction.',
    updatedAt: new Date().toISOString()
  };
}

function pane(id, label, x, y, w, h, importance, notes) {
  return {
    id,
    label,
    grid: { x, y, w, h },
    importance,
    locked: false,
    // Real WeakAuras meaning lives here instead of free-text role/anchor/
    // relationship fields: opportunityType picks a schema from
    // Templates/schemas/*.schema.json (see listOpportunityTypes above),
    // and fields holds that schema's own properties (name, spell_id, x, y,
    // width, height, show_when_missing, ...), pre-seeded from its defaults
    // client-side when the pane's opportunityType is set/changed.
    opportunityType: '',
    fields: {},
    notes
  };
}

function normalizePaneBoard(board) {
  const source = board?.source || {};
  const viewport = board?.viewport || {};
  const grid = Number.isFinite(viewport.grid) && viewport.grid > 0 ? viewport.grid : 1;
  const width = viewport.preset === '720x640' ? 720 : 960;
  const height = 640;
  const maxGridW = Math.floor(width / grid);
  const maxGridH = Math.floor(height / grid);
  const seenPaneIds = new Set();
  return {
    id: String(board?.id || layoutId(board?.title || 'pane-board')).slice(0, 96),
    title: String(board?.title || 'Pane Board V1 working sketch').slice(0, 120),
    status: paneBoardStatus(board?.status),
    viewport: {
      preset: width === 720 ? '720x640' : '960x640',
      width,
      height,
      grid
    },
    source: {
      createdBy: source.createdBy === 'agent' ? 'agent' : 'human',
      basedOn: source.basedOn ? String(source.basedOn).slice(0, 160) : null,
      project: 'Weak Auras',
      context: String(source.context || 'layout intent sketch').slice(0, 120)
    },
    panes: Array.isArray(board?.panes)
      ? board.panes.map((entry, index) => normalizePane(entry, index, maxGridW, maxGridH, seenPaneIds))
      : [],
    review: {
      humanIntent: String(board?.review?.humanIntent || '').slice(0, 1000),
      agentNotes: String(board?.review?.agentNotes || '').slice(0, 1000),
      acceptedByHuman: board?.review?.acceptedByHuman === true
    },
    collaboration: normalizeCollaboration(board?.collaboration),
    screenNote: String(board?.screenNote || board?.review?.agentNotes || '').slice(0, 1000),
    updatedAt: new Date().toISOString()
  };
}

function normalizeCollaboration(collaboration = {}) {
  const notes = collaboration.notes || {};
  return {
    notes: {
      human: String(notes.human || '').slice(0, 1200),
      labs: String(notes.labs || '').slice(0, 1200)
    },
    commands: Array.isArray(collaboration.commands)
      ? collaboration.commands.slice(-24).map((command, index) => normalizeBoardCommand(command, index))
      : []
  };
}

function normalizeBoardCommand(command, index) {
  const text = String(command?.text || '').slice(0, 220);
  return {
    id: String(command?.id || `board-guidance-${index + 1}`).slice(0, 80),
    text,
    createdBy: command?.createdBy === 'labs' ? 'labs' : 'human',
    scope: 'board-only',
    status: command?.status === 'done' ? 'done' : command?.status === 'parked' ? 'parked' : 'open',
    createdAt: typeof command?.createdAt === 'string' && !Number.isNaN(Date.parse(command.createdAt))
      ? command.createdAt
      : new Date().toISOString()
  };
}

function normalizePane(entry, index, maxGridW = 960, maxGridH = 640, seenPaneIds = new Set()) {
  const grid = entry?.grid || {};
  const id = uniquePaneId(slug(entry?.id || entry?.label || `pane-${index + 1}`) || `pane-${index + 1}`, seenPaneIds);
  const importance = String(entry?.importance || 'supporting').slice(0, 48);
  // Minimum 1 unit in any dimension (not 4) - the real, already-shipped
  // DIVIDER_POS element in Tiers/resources_base.py is only 3 units wide,
  // which a 4-unit floor made unrepresentable.
  const w = clampCoord(grid.w, 1, maxGridW);
  const h = clampCoord(grid.h, 1, maxGridH);
  const pane = {
    id,
    label: String(entry?.label || id).slice(0, 80),
    grid: {
      x: clampCoord(grid.x, 0, maxGridW - w),
      y: clampCoord(grid.y, 0, maxGridH - h),
      w,
      h
    },
    importance,
    locked: entry?.locked === true,
    // opportunityType selects a schema from Templates/schemas/*.schema.json
    // (see listOpportunityTypes); fields holds that schema's own
    // properties. This replaces the old free-text role/anchor/relationship
    // fields with the real field shapes this project already uses.
    opportunityType: String(entry?.opportunityType || '').slice(0, 64),
    fields: normalizePaneFields(entry?.fields),
    notes: String(entry?.notes || '').slice(0, 1000)
  };
  const material = normalizePaneMaterial(entry?.material);
  if (material) {
    pane.material = material;
  }
  return pane;
}

function normalizePaneFields(fields) {
  if (!fields || typeof fields !== 'object') {
    return {};
  }
  const clean = {};
  for (const [key, value] of Object.entries(fields)) {
    const cleanKey = String(key).slice(0, 64);
    if (typeof value === 'string') {
      clean[cleanKey] = value.slice(0, 500);
    } else if (typeof value === 'number' && Number.isFinite(value)) {
      clean[cleanKey] = value;
    } else if (typeof value === 'boolean') {
      clean[cleanKey] = value;
    }
  }
  return clean;
}

function normalizePaneMaterial(material) {
  if (!material || material.type !== 'image') {
    return null;
  }
  const normalizedPath = normalizeMaterialPath(material.path);
  if (!normalizedPath) {
    return null;
  }
  const fit = ['contain', 'cover', 'tile'].includes(material.fit) ? material.fit : 'cover';
  return {
    type: 'image',
    path: normalizedPath,
    fit,
    opacity: clampNumber(material.opacity, 0.05, 1, 0.35),
    role: String(material.role || 'imagination-paint').slice(0, 80)
  };
}

function normalizeMaterialPath(value) {
  const raw = String(value || '').replace(/\\/g, '/').trim();
  if (!raw || raw.includes('\0') || raw.includes(':') || raw.startsWith('/') || raw.startsWith('..')) {
    return null;
  }
  const normalized = path.posix.normalize(raw);
  if (normalized !== raw || normalized.includes('../') || !normalized.startsWith('materials/')) {
    return null;
  }
  if (!/\.png$/i.test(normalized)) {
    return null;
  }
  return normalized.slice(0, 220);
}

function uniquePaneId(id, seenPaneIds) {
  let candidate = id;
  let index = 2;
  while (seenPaneIds.has(candidate)) {
    candidate = `${id}-${index}`;
    index += 1;
  }
  seenPaneIds.add(candidate);
  return candidate;
}

function paneBoardStatus(status) {
  const allowed = ['human-sketch', 'agent-proposal', 'human-accepted', 'superseded', 'parked', 'rejected'];
  return allowed.includes(status) ? status : 'human-sketch';
}

function layoutId(title) {
  return `layout-${new Date().toISOString().slice(0, 10)}-${slug(title || 'pane-board')}`;
}

function slug(value) {
  return String(value || '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 80);
}

function clampCoord(value, min, max) {
  // Deliberately parseFloat, not parseInt: real shipped WeakAuras geometry
  // (Tiers/resources_base.py's CLASS_RESOURCE_POS, CAST_BAR_POS, etc.) uses
  // half-unit values like -64.5. Truncating to an integer here would
  // silently corrupt any pane authored to match those real positions.
  const number = Number.parseFloat(value);
  const safe = Number.isFinite(number) ? number : 0;
  return Math.max(min, Math.min(max, safe));
}

function clampNumber(value, min, max, fallback) {
  const number = Number.parseFloat(value);
  if (!Number.isFinite(number)) {
    return fallback;
  }
  return Math.max(min, Math.min(max, number));
}

module.exports = {
  createPaneBoardWindow,
  isPaneBoardSmokeMode,
  registerPaneBoardHandlers
};
