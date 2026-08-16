const path = require('node:path');
const fs = require('node:fs');
const { createFrameWindow } = require('../../../modules/Frame');

// ⚠ ANCHORED TO THIS FILE, NOT TO THE CURRENT DIRECTORY. `process.cwd()` put
// the workspace wherever the app happened to be launched from, which quietly
// scatters boards across folders and is impossible to notice until half your
// work is in the wrong one. The board lives beside the app that owns it:
//   addons/tools/PaneBoard/workspace/pane-board/
// ★ In THIS repo - the aura bench's own workspace is a separate tool and is
// never read or written from here.
const APP_ROOT = path.join(__dirname, '..', '..', '..', '..');
const PANE_BOARD_ROOT = path.join(APP_ROOT, 'workspace', 'pane-board');

function isPaneBoardSmokeMode() {
  return process.env.WA_PANE_BOARD_SMOKE === '1';
}

function createPaneBoardWindow({ app, preload, setMainWindow, waitForLoad, delay }) {
  const window = createFrameWindow(app, {
    width: 960,
    height: 640,
    minWidth: 720,
    minHeight: 640,
    title: 'COA Pane Board',
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
  ipcMain.handle('board:pane-board:load', () => readPaneBoard());
  ipcMain.handle('board:pane-board:revision', () => paneBoardRevision());
  ipcMain.handle('board:pane-board:save', (_event, request = {}) => writePaneBoard(request.board, request.reason));
  ipcMain.handle('board:pane-board:snapshot', (_event, request = {}) => snapshotPaneBoard(request));
  ipcMain.handle('board:pane-board:export-png', (_event, request = {}) => exportPaneBoardPng(getWindow(), request));
  ipcMain.handle('board:pane-board:capture', (_event, request = {}) => capturePaneBoard(getWindow(), request));
  ipcMain.handle('board:pane-board:list-snapshots', () => listPaneBoardSnapshots());
  ipcMain.handle('board:pane-board:load-snapshot', (_event, snapshotPath) => loadPaneBoardSnapshot(snapshotPath));
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
    window.paneBoard.load().then((board) => {
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
      project: 'COA_DungeonRun',
      context: 'spatial taste reference'
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
    id: layoutId('object-pane'),
    title: 'Object pane',
    status: 'human-sketch',
    viewport: {
      preset: '240x600',
      width: 240,
      height: 600,
      // 1 grid unit = 1 CLIENT PIXEL. That is the whole reason this board is
      // usable here: a rectangle you drag is the rectangle in the game, so
      // the numbers that come out need no translation. A coarser grid would
      // be a tool convention with no relationship to what ships.
      grid: 1
    },
    source: {
      createdBy: 'human',
      basedOn: 'addons/planning/dungeonrun_interface_inventory.md',
      project: 'COA_DungeonRun',
      context: 'spatial taste only - the inventory stays the authority'
    },
    // Starts EMPTY on purpose. The old default shipped four invented panes
    // from another project, and opening a tool to someone else's sketch is
    // exactly the information bloat this fork exists to remove. Add what you
    // are actually deciding about.
    panes: [],
    review: {
      humanIntent: 'Answer the questions the inventory cannot: how big, and does it sit right.',
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
    screenNote: '',
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
    // WeakAuras' own schema list used to fill this; on this bench a pane's
    // kind lives in the INVENTORY, not here -
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
  // ⚠⚠ THE SIZE COMES FROM THE VIEWPORT, not from a fixed pair. This line used
  // to read `preset === '720x640' ? 720 : 960` with the height nailed to 640,
  // so every board on this bench was silently rewritten to 960x640 - including
  // the default one - and the pane sizes that make the board 1:1 with the
  // client were unreachable. ★ The preset IS the size.
  const parsed = String(viewport.preset || '').split('x').map(Number);
  const width = Number.isFinite(viewport.width) && viewport.width > 0
    ? Math.round(viewport.width)
    : (Number.isFinite(parsed[0]) && parsed[0] > 0 ? Math.round(parsed[0]) : 240);
  const height = Number.isFinite(viewport.height) && viewport.height > 0
    ? Math.round(viewport.height)
    : (Number.isFinite(parsed[1]) && parsed[1] > 0 ? Math.round(parsed[1]) : 600);
  const maxGridW = Math.floor(width / grid);
  const maxGridH = Math.floor(height / grid);
  const seenPaneIds = new Set();
  return {
    id: String(board?.id || layoutId(board?.title || 'pane-board')).slice(0, 96),
    title: String(board?.title || 'Object pane').slice(0, 120),
    status: paneBoardStatus(board?.status),
    viewport: {
      preset: `${width}x${height}`,
      width,
      height,
      grid
    },
    source: {
      createdBy: source.createdBy === 'agent' ? 'agent' : 'human',
      basedOn: source.basedOn ? String(source.basedOn).slice(0, 160) : null,
      project: 'COA_DungeonRun',
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

function normalizePane(entry, index, maxGridW = 240, maxGridH = 600, seenPaneIds = new Set()) {
  const grid = entry?.grid || {};
  const id = uniquePaneId(slug(entry?.id || entry?.label || `pane-${index + 1}`) || `pane-${index + 1}`, seenPaneIds);
  // ★★★ LAYER, not importance (2026-08-16). `show` is the default because a control
  // the capture said nothing about is one you can see. ⚠ An unrecognised value is
  // KEPT rather than coerced - an old board carrying `primary` still loads and reads
  // as `primary` in the select, which is visible, instead of being silently rewritten.
  const importance = String(entry?.importance || 'show').slice(0, 48);
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
    // kept as a free-form bag; fields holds whatever the caller's
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
