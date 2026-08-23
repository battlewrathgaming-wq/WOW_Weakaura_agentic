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

  // ★★★ THE ORIGINAL IS TAKEN FIRST AND RESTORED IN A `finally`, and that is not tidiness.
  // The restore used to be a plain statement after the work: any throw between the save and
  // it left the board nudged by one pixel. Harmless. ⟶ But once this can load a DIFFERENT
  // board (below), the same throw leaves the PERSON'S BOARD REPLACED by whatever was being
  // rendered. The new capability turns a small latent fault into a destructive one, so the
  // guard arrives with it rather than after the first time it bites.
  const board = readPaneBoard();
  try {
    // ★★ RENDER A NAMED PROPOSAL, on request. `WA_PANE_BOARD_SMOKE_BOARD=<id or file>` picks
    // a board out of agent-proposals/ and renders THAT instead of the current one - so an
    // agent can look at something it just proposed without a person opening the app, which is
    // the half of the two-way loop that has never run.
    // ⚠ Resolved inside `agent-proposals/` only, and the name is stripped of any path parts:
    // an env var is DATA and this reads a file, so it gets the same treatment the renderer's
    // own `normalizeMaterialPath` gives a material path.
    const wanted = String(process.env.WA_PANE_BOARD_SMOKE_BOARD || '').trim();
    let subject = null;
    let subjectSource = 'current board, nudged';
    if (wanted) {
      const bare = path.basename(wanted).replace(/\.json$/i, '');
      const file = path.join(paneBoardPaths().agent, `${bare}.json`);
      if (!fs.existsSync(file)) {
        // ⚠ NAMED, never a silent fall back to the current board - rendering the wrong board
        // and reporting "passed" is the failure this whole session keeps finding.
        throw new Error(`No proposal ${bare}.json in agent-proposals/`);
      }
      subject = normalizePaneBoard(JSON.parse(fs.readFileSync(file, 'utf8')));
      subjectSource = `agent-proposals/${bare}.json`;
    } else {
      subject = {
        ...board,
        title: 'Pane Board V1 smoke sketch',
        source: { ...(board.source || {}), basedOn: board.id },
        panes: board.panes.map((pane, index) => index === 0
          ? { ...pane, grid: { ...pane.grid, x: pane.grid.x + 1, y: pane.grid.y + 1 } }
          : pane)
      };
    }

    const saved = writePaneBoard(subject, 'pane-board-smoke-save');
    const snapshot = snapshotPaneBoard({
      board: saved,
      status: 'agent-proposal',
      title: wanted ? `Smoke render — ${subject.title}` : 'Pane Board V1 smoke proposal',
      basedOn: board.id
    });
    // ⚠⚠ RE-RENDER THE CANVAS, not just the title field. The original line loaded the board
    // into a local and wrote `#board-title` - so the DOM kept showing whatever it booted with.
    // Measured: the first named render returned `passed` with a PNG whose title said
    // `store-goldborder — nine-slice` and whose canvas showed the promoter's 27 panes.
    // ★ Driving the app's own `#refresh-board` control - which reloads from disk, resets the
    // selection and calls renderBoard() - means the smoke exercises the path a person does,
    // rather than reaching into private state and proving something only it can reach.
    await window.webContents.executeJavaScript(`
      document.querySelector('#refresh-board').click();
      // ⚠ 1:1 FOR THE CAPTURE. The renderer boots at 2x, which is right for dragging and
      // wrong for a picture: a 420x260 pane becomes 840x520, overflows the canvas, and the
      // export shows ONE CORNER of the thing being judged. A border is judged by its four
      // corners and three of them were outside the frame.
      // ★ Through the app's own control and a dispatched change event, not by assigning to
      // private state - the smoke should exercise the path a person uses.
      const zoom = document.querySelector('#pane-zoom');
      if (zoom) {
        zoom.value = '1';
        zoom.dispatchEvent(new Event('change', { bubbles: true }));
      }
    `);
    // ⚠ A material is a background-image / border-image the renderer fetches; the export can
    // out-run the decode and produce a PNG with the art missing, which reads as "the material
    // is wrong" rather than "the picture was taken too early".
    await delay(400);

    // ★★★ FIT THE WINDOW TO THE BOARD, THEN FRAME ON IT. A 240x674 board in a 960x640 window
    // is a ~200px visible strip, so the export was a picture of the SIDEBAR with a sliver of
    // canvas - it reported the right board id over the wrong image, which is the exact shape of
    // the three false `passed` results this harness has already produced.
    // ⚠ Measured through the DOM rather than computed from the board's viewport: zoom, chrome
    // and scroll all sit between the two numbers, and a computed guess is the thing that was
    // wrong the last three times.
    let rect = null;
    try {
      const probe = () => window.webContents.executeJavaScript(`
        (() => {
          const el = document.querySelector('#board-canvas');
          if (!el) { return null; }
          const r = el.getBoundingClientRect();
          return JSON.stringify({
            x: r.x, y: r.y,
            w: Math.max(el.scrollWidth, r.width),
            h: Math.max(el.scrollHeight, r.height)
          });
        })()
      `);
      const first = JSON.parse((await probe()) || 'null');
      if (first) {
        // Grow only - never shrink below the app's own minimums, and cap it so a runaway board
        // cannot ask for a window the display cannot hold.
        const wantH = Math.min(4000, Math.ceil(first.y + first.h + 24));
        const [curW, curH] = window.getContentSize();
        if (wantH > curH) {
          window.setContentSize(curW, wantH);
          await delay(250);
        }
        const after = JSON.parse((await probe()) || 'null');
        if (after) {
          const [w, h] = window.getContentSize();
          rect = {
            x: Math.max(0, Math.floor(after.x)),
            y: Math.max(0, Math.floor(after.y)),
            width: Math.min(Math.ceil(after.w), w - Math.floor(after.x)),
            height: Math.min(Math.ceil(after.h), h - Math.floor(after.y))
          };
          if (rect.width < 8 || rect.height < 8) { rect = null; }
        }
      }
    } catch (error) {
      // ⚠ NAMED, not swallowed: a framing failure falls back to the window shot rather than
      // failing the smoke, but it must not do so quietly - a silent fallback here is how the
      // picture stops matching the claim.
      rect = null;
      console.warn('[pane-board smoke] could not frame on the canvas:', error.message);
    }

    const png = await exportPaneBoardPng(window, {
      rect,
      board: snapshot.board,
      title: wanted ? `smoke-${path.basename(wanted).replace(/\.json$/i, '')}` : 'pane-board-smoke'
    });
    const capture = await capturePaneBoard(window, {
      board: saved,
      title: 'Pane Board V1 smoke resting capture',
      sourceArtifact: 'pane-board-smoke',
      humanSignal: 'Smoke capture checks board-local resting state.',
      includeScreenshot: true
    });
    writePaneBoardSmokeResult({
      status: 'passed',
      message: 'Pane Board smoke passed.',
      checked_at: new Date().toISOString(),
      rendered: subjectSource,
      current_board: path.relative(process.cwd(), paneBoardPaths().current),
      snapshot: path.relative(process.cwd(), snapshot.path),
      png: path.relative(process.cwd(), png.path),
      capture: path.relative(process.cwd(), capture.path),
      capture_screenshot: capture.capture.screenshot,
      board_id: snapshot.board.id,
      based_on: snapshot.board.source.basedOn,
      pane_count: snapshot.board.panes.length
    });
  } finally {
    // ⚠⚠ ALWAYS. Whatever happened above, the board on disk goes back to what the person had.
    writePaneBoard(board, 'pane-board-smoke-restore');
  }
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

async function exportPaneBoardPng(window, { board, title, rect } = {}) {
  const paths = ensurePaneBoardDirs();
  if (!window || window.isDestroyed()) {
    throw new Error('Pane Board window is not available for PNG export.');
  }
  const cleanBoard = normalizePaneBoard(board || readPaneBoard());
  // ⚠ `rect` is OPTIONAL and absent means the whole window - the person's Export PNG passes
  // nothing and keeps taking the shot it always took. Only the smoke asks for a framed one.
  const image = rect
    ? await window.webContents.capturePage(rect)
    : await window.webContents.capturePage();
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
  // ⚠⚠ THERE ARE TWO MATERIAL NORMALISERS AND THIS ONE IS THE GATEKEEPER. The renderer has its
  // own (`pane-board.js: paneMaterial`) for what it will DRAW; this one decides what is allowed
  // to be SAVED, and `writePaneBoard` runs it on every write. ★ Adding `nineslice` to the
  // renderer alone would have been silent and plausible: a board written here would come back
  // as `cover` with no slice, the border would render STRETCHED, and the picture would look
  // like a verdict about the ART rather than a field this function threw away.
  // ⟶ One contract, two enforcement points. They must move together; that is the cost of the
  // split, and it is written down here so the next person pays it deliberately.
  const fit = ['contain', 'cover', 'tile', 'nineslice'].includes(material.fit)
    ? material.fit
    : 'cover';
  const out = {
    type: 'image',
    path: normalizedPath,
    fit,
    opacity: clampNumber(material.opacity, 0.05, 1, 0.35),
    role: String(material.role || 'imagination-paint').slice(0, 80)
  };
  // ★ The slice belongs to the ART, not to the board, and it is validated the same way here as
  // in the renderer: four finite non-negative numbers or nothing. A malformed slice draws a
  // border that is subtly wrong rather than absent.
  if (Array.isArray(material.slice) && material.slice.length === 4) {
    const nums = material.slice.map((v) => Number.parseFloat(v));
    if (nums.every((n) => Number.isFinite(n) && n >= 0 && n <= 512)) {
      out.slice = nums;
    }
  }
  return out;
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
