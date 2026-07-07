// 1 grid unit = 1 canvas px = 1 WeakAuras/WoW UI unit - the same unit
// x/y/width/height already use in Templates/schemas/*.schema.json and in
// the real shipped geometry in Tiers/resources_base.py (which includes
// half-unit values like -64.5). Snapping/nudging moves panes in whole
// 1-unit steps; the schema-driven fields panel below still accepts exact
// decimal entry so half-unit legacy positions can be authored precisely.
const GRID = 1;
const boardState = {
  board: null,
  selectedId: null,
  drag: null,
  saveTimer: null,
  dirty: false,
  saveStatus: 'Loading...',
  lastSavedAt: null,
  lastChange: 'Last change: none this session',
  changedPaneId: null,
  changedPaneTimer: null,
  lastRevision: null,
  revisionTimer: null,
  opportunityTypes: [],
  // Purely a rendering/interaction aid - never written into the saved
  // board JSON. Real WeakAuras elements range from ~3 units (a divider)
  // to ~130 units (a bar) against a 960x640+ canvas, so at a literal 1:1
  // zoom a lot of panes would render as unreadable slivers. zoom scales
  // on-screen pixels only; stored grid.x/y/w/h stay in exact real units.
  zoom: 2,
  // ELEMENT_INVENTORY.md's full documented slot mask (see listMaskSlots()
  // in paneBoard.js) - loaded once at boot, purely a background reference
  // layer. Never added to boardState.board.panes, so it's never part of
  // what gets saved/snapshotted - toggling it on/off has zero effect on
  // the real board content.
  maskSlots: [],
  showMask: false
};

function renderScale() {
  return GRID * boardState.zoom;
}

boot().catch((error) => showMessage(error.message));

async function boot() {
  await bootFrame();
  wireControls();
  boardState.opportunityTypes = await window.auraPaneBoard.listOpportunityTypes();
  populateOpportunityTypeOptions();
  await populateImportableClassOptions();
  await populateSnapshotOptions();
  await loadMaskSlots();
  boardState.board = await window.auraPaneBoard.load();
  boardState.lastRevision = await window.auraPaneBoard.revision();
  boardState.lastSavedAt = boardState.board.updatedAt || null;
  boardState.saveStatus = savedLabel(boardState.lastSavedAt);
  boardState.selectedId = boardState.board.panes[0]?.id || null;
  renderBoard();
  startRevisionWatch();
}

function populateOpportunityTypeOptions() {
  const select = document.querySelector('#pane-opportunity-type');
  select.textContent = '';
  const blank = document.createElement('option');
  blank.value = '';
  blank.textContent = '(unset - sketch only)';
  select.appendChild(blank);
  for (const schema of boardState.opportunityTypes) {
    const option = document.createElement('option');
    option.value = schema.id;
    option.textContent = schema.title;
    select.appendChild(option);
  }
}

async function populateImportableClassOptions() {
  const select = document.querySelector('#import-class-select');
  if (!select || !window.auraPaneBoard.listImportableClasses) {
    return;
  }
  const classes = await window.auraPaneBoard.listImportableClasses();
  select.textContent = '';
  const blank = document.createElement('option');
  blank.value = '';
  blank.textContent = '(choose a class)';
  select.appendChild(blank);
  for (const className of classes) {
    const option = document.createElement('option');
    option.value = className;
    option.textContent = className;
    select.appendChild(option);
  }
}

async function importClassLayout() {
  const select = document.querySelector('#import-class-select');
  const className = select.value;
  if (!className) {
    showMessage('Choose a class to import first.');
    return;
  }
  const button = document.querySelector('#import-class-button');
  button.disabled = true;
  try {
    const result = await window.auraPaneBoard.importClassLayout(className);
    await populateSnapshotOptions(result.path);
    showMessage(`Imported ${className} snapshot (${result.board.panes.length} panes) to ${relativePath(result.path)}. This board is untouched - use "Load snapshot into view" below to open it, now selected.`);
  } catch (error) {
    showMessage(error.message);
  } finally {
    button.disabled = false;
  }
}

async function populateSnapshotOptions(preselectPath = '') {
  const select = document.querySelector('#load-snapshot-select');
  if (!select || !window.auraPaneBoard.listSnapshots) {
    return;
  }
  const snapshots = await window.auraPaneBoard.listSnapshots();
  select.textContent = '';
  const blank = document.createElement('option');
  blank.value = '';
  blank.textContent = '(choose a snapshot)';
  select.appendChild(blank);
  for (const snapshot of snapshots) {
    const option = document.createElement('option');
    option.value = snapshot.path;
    option.textContent = `${snapshot.title} [${snapshot.status}]${snapshot.basedOn ? ` - ${snapshot.basedOn}` : ''}`;
    select.appendChild(option);
  }
  if (preselectPath) {
    select.value = preselectPath;
  }
}

async function loadSnapshotIntoView() {
  const select = document.querySelector('#load-snapshot-select');
  const snapshotPath = select.value;
  if (!snapshotPath) {
    showMessage('Choose a snapshot to load first.');
    return;
  }
  const button = document.querySelector('#load-snapshot-button');
  button.disabled = true;
  try {
    const result = await window.auraPaneBoard.loadSnapshot(snapshotPath);
    boardState.board = result.board;
    boardState.lastRevision = await window.auraPaneBoard.revision();
    boardState.dirty = false;
    boardState.lastSavedAt = boardState.board.updatedAt || null;
    boardState.saveStatus = savedLabel(boardState.lastSavedAt);
    boardState.selectedId = boardState.board.panes[0]?.id || null;
    setLastChange('disk-redraw', null, 'Human');
    renderBoard();
    await populateSnapshotOptions();
    showMessage(`Loaded snapshot into view. Your previous board was backed up to ${relativePath(result.backupPath)} first.`);
  } catch (error) {
    showMessage(error.message);
  } finally {
    button.disabled = false;
  }
}

// Loads ELEMENT_INVENTORY.md's full documented slot mask once at boot -
// read-only reference data, not something the user edits here. Failure
// (e.g. Python not resolvable, same class of error the class-layout
// importer can hit) degrades gracefully: the "Show mask" checkbox simply
// has nothing to show, rather than blocking the rest of the board from
// loading.
async function loadMaskSlots() {
  if (!window.auraPaneBoard.listMaskSlots) {
    return;
  }
  try {
    const result = await window.auraPaneBoard.listMaskSlots();
    boardState.maskSlots = result.slots || [];
  } catch (error) {
    boardState.maskSlots = [];
    showMessage(`Mask overlay unavailable: ${error.message}`);
  }
}

async function bootFrame() {
  if (!window.auraWindow) {
    return;
  }
  const frame = await window.auraWindow.getState();
  renderFrame(frame);
  document.querySelector('#pin-window').addEventListener('click', async () => {
    renderFrame(await window.auraWindow.setAlwaysOnTop(document.querySelector('#pin-window').classList.contains('active') !== true));
  });
  document.querySelector('#minimize-window').addEventListener('click', () => window.auraWindow.minimize());
  document.querySelector('#close-window').addEventListener('click', () => window.auraWindow.close());
}

function renderFrame(frame) {
  const pin = document.querySelector('#pin-window');
  pin.classList.toggle('active', frame?.alwaysOnTop === true);
  pin.textContent = frame?.alwaysOnTop ? 'Pinned' : 'Pin';
}

function wireControls() {
  document.querySelector('#board-title').addEventListener('input', (event) => {
    boardState.board.title = event.target.value;
    scheduleSave('title-edited', null);
    renderMeta();
  });
  document.querySelector('#viewport-preset').addEventListener('change', (event) => {
    setViewport(event.target.value);
  });
  document.querySelector('#pane-zoom').addEventListener('change', (event) => {
    boardState.zoom = Number.parseInt(event.target.value, 10) || 1;
    renderBoard();
  });
  document.querySelector('#board-status').addEventListener('change', (event) => {
    const previousStatus = boardState.board.status || 'human-sketch';
    if (event.target.value === 'agent-proposal' && !boardState.board.source?.basedOn) {
      event.target.value = previousStatus;
      showMessage('Use Grab state with Based on to create an agent proposal.');
      return;
    }
    boardState.board.status = event.target.value;
    boardState.board.source.createdBy = event.target.value === 'agent-proposal' ? 'agent' : 'human';
    if (event.target.value !== 'agent-proposal') {
      boardState.board.source.basedOn = null;
    }
    scheduleSave('status-edited', null);
    renderMeta();
  });
  document.querySelector('#screen-note-text').addEventListener('input', (event) => {
    boardState.board.screenNote = event.target.value;
    boardState.board.review.agentNotes = event.target.value;
    scheduleSave('screen-note-edited', null);
  });
  document.querySelector('#board-human-note').addEventListener('input', (event) => {
    ensureCollaboration();
    boardState.board.collaboration.notes.human = event.target.value;
    scheduleSave('human-note-edited', null);
  });
  document.querySelector('#board-labs-note').addEventListener('input', (event) => {
    ensureCollaboration();
    boardState.board.collaboration.notes.labs = event.target.value;
    scheduleSave('labs-note-edited', null);
  });
  document.querySelector('#add-board-command').addEventListener('click', addBoardCommand);
  document.querySelector('#add-pane').addEventListener('click', addPane);
  document.querySelector('#duplicate-pane').addEventListener('click', duplicatePane);
  document.querySelector('#delete-pane').addEventListener('click', deletePane);
  for (const selector of ['#pane-label', '#pane-importance', '#pane-notes', '#pane-material-path', '#pane-material-fit', '#pane-material-opacity', '#pane-material-role']) {
    document.querySelector(selector).addEventListener('input', updateSelectedPaneFromEditor);
  }
  document.querySelector('#pane-opportunity-type').addEventListener('change', (event) => updatePaneOpportunityType(event.target.value));
  document.querySelector('#clear-pane-material').addEventListener('click', clearSelectedPaneMaterial);
  document.querySelector('#lock-pane').addEventListener('click', toggleSelectedPaneLock);
  for (const button of document.querySelectorAll('.nudge-pane')) {
    button.addEventListener('click', () => nudgeSelectedPane(Number(button.dataset.dx), Number(button.dataset.dy)));
  }
  document.querySelector('#grab-state').addEventListener('click', grabState);
  document.querySelector('#export-png').addEventListener('click', exportPng);
  document.querySelector('#refresh-board').addEventListener('click', refreshBoard);
  document.querySelector('#return-sketch').addEventListener('click', returnToSketch);
  document.querySelector('#capture-board').addEventListener('click', captureBoard);
  document.querySelector('#import-class-button').addEventListener('click', importClassLayout);
  document.querySelector('#load-snapshot-button').addEventListener('click', loadSnapshotIntoView);
  document.querySelector('#show-mask-toggle').addEventListener('change', (event) => {
    boardState.showMask = event.target.checked === true;
    renderBoard();
  });
}

function setViewport(preset) {
  boardState.board.viewport = {
    preset: preset === '720x640' ? '720x640' : '960x640',
    width: preset === '720x640' ? 720 : 960,
    height: 640,
    grid: GRID
  };
  clampPanesToBoard();
  scheduleSave('viewport-edited', null);
  renderBoard();
}

function renderBoard() {
  if (!boardState.board) {
    return;
  }
  document.querySelector('#board-title').value = boardState.board.title || '';
  document.querySelector('#viewport-preset').value = boardState.board.viewport?.preset || '960x640';
  document.querySelector('#pane-zoom').value = String(boardState.zoom);
  document.querySelector('#board-status').value = boardState.board.status || 'human-sketch';
  document.querySelector('#show-mask-toggle').checked = boardState.showMask === true;
  document.querySelector('#screen-note-text').value = boardState.board.screenNote || boardState.board.review?.agentNotes || '';
  ensureCollaboration();
  document.querySelector('#board-human-note').value = boardState.board.collaboration.notes.human || '';
  document.querySelector('#board-labs-note').value = boardState.board.collaboration.notes.labs || '';

  const canvas = document.querySelector('#board-canvas');
  const scale = renderScale();
  canvas.style.width = `${boardState.board.viewport.width * scale}px`;
  canvas.style.height = `${boardState.board.viewport.height * scale}px`;
  canvas.style.backgroundSize = `${8 * scale}px ${8 * scale}px, ${8 * scale}px ${8 * scale}px`;
  canvas.textContent = '';
  // Mask nodes are appended FIRST, real panes after - later DOM siblings
  // paint on top in normal flow, so this keeps the non-interactive mask
  // strictly underneath every real, draggable pane without needing z-index.
  renderMaskLayer(canvas, scale);
  for (const pane of boardState.board.panes) {
    canvas.appendChild(renderPane(pane));
  }
  renderEditor();
  renderMeta();
  renderCommands();
  renderOrientation();
}

// Draws ELEMENT_INVENTORY.md's full documented slot mask as a background
// reference layer - purely visual, never interactive (pointer-events:none,
// no drag handlers, no click/focus wiring) and never added to
// boardState.board.panes, so it can never end up saved into a real board
// file. Each slot is tagged "filled" if its footprint overlaps an existing
// real pane on this board, or "gap" if nothing here covers it yet -
// Battlewrath, 2026-07-06: "So not interactable, but define the whole UI.
// (And show the gaps for what needs slotting.)"
function renderMaskLayer(canvas, scale) {
  const status = document.querySelector('#mask-status');
  if (!boardState.showMask) {
    if (status) {
      status.textContent = '';
    }
    return;
  }
  if (!boardState.maskSlots.length) {
    if (status) {
      status.textContent = 'No mask data loaded (see message above if the parser failed).';
    }
    return;
  }
  let gapCount = 0;
  const layer = document.createElement('div');
  layer.className = 'mask-layer';
  layer.setAttribute('aria-hidden', 'true');
  for (const slot of boardState.maskSlots) {
    const filled = boardState.board.panes.some((pane) => gridBoxesOverlap(pane.grid, slot.grid));
    if (!filled) {
      gapCount += 1;
    }
    const node = document.createElement('div');
    node.className = 'mask-node';
    node.dataset.status = filled ? 'filled' : 'gap';
    node.style.left = `${slot.grid.x * scale}px`;
    node.style.top = `${slot.grid.y * scale}px`;
    node.style.width = `${slot.grid.w * scale}px`;
    node.style.height = `${slot.grid.h * scale}px`;
    node.title = [slot.row, slot.id, slot.expectedFunction].filter(Boolean).join(' - ');
    const label = document.createElement('span');
    label.className = 'mask-node-label';
    label.textContent = slot.id;
    node.appendChild(label);
    layer.appendChild(node);
  }
  canvas.appendChild(layer);
  if (status) {
    status.textContent = `${boardState.maskSlots.length} documented slots - ${gapCount} not yet covered by a pane on this board.`;
  }
}

// Simple axis-aligned bounding-box overlap test in grid-unit space (same
// units both boxes are already stored in, before any zoom scale is
// applied) - true if the two rectangles share any area at all, not just a
// touching edge.
function gridBoxesOverlap(a, b) {
  return a.x < b.x + b.w && a.x + a.w > b.x && a.y < b.y + b.h && a.y + a.h > b.y;
}

function renderPane(pane) {
  const node = document.createElement('article');
  node.className = 'pane-node';
  node.dataset.paneId = pane.id;
  node.dataset.selected = pane.id === boardState.selectedId ? 'true' : 'false';
  node.dataset.locked = pane.locked ? 'true' : 'false';
  node.dataset.changed = pane.id === boardState.changedPaneId ? 'true' : 'false';
  const scale = renderScale();
  node.style.left = `${pane.grid.x * scale}px`;
  node.style.top = `${pane.grid.y * scale}px`;
  node.style.width = `${pane.grid.w * scale}px`;
  node.style.height = `${pane.grid.h * scale}px`;
  applyPanePadding(node, pane, scale);
  node.tabIndex = 0;

  const material = paneMaterial(pane);
  if (material) {
    const materialNode = document.createElement('span');
    materialNode.className = `pane-material pane-material-${material.fit}`;
    materialNode.style.opacity = material.opacity;
    materialNode.style.backgroundImage = `url("${materialUrl(material.path)}")`;
    materialNode.setAttribute('aria-hidden', 'true');
    node.appendChild(materialNode);
  }

  // On-canvas card is deliberately limited to slot title, opportunity
  // tag, and position - nothing else. Notes ("what this slot does"),
  // material, and every other field only read once you click the pane
  // and look at the sidebar editor; cramming them onto the card made
  // small real elements (a 15-unit bar, a 3-unit divider) unreadable.
  const header = document.createElement('div');
  header.className = 'pane-header';
  const label = document.createElement('strong');
  label.className = 'pane-title';
  label.textContent = pane.label || pane.id;
  header.appendChild(label);
  if (pane.opportunityType) {
    const tag = document.createElement('span');
    tag.className = 'pane-tag';
    tag.textContent = pane.opportunityType;
    header.appendChild(tag);
  }

  const meta = document.createElement('small');
  meta.textContent = paneMetaText(pane);
  const handle = document.createElement('i');
  handle.className = 'resize-handle';
  handle.setAttribute('aria-hidden', 'true');

  node.append(header, meta, handle);
  applyPaneTypography(node, pane, scale);
  node.addEventListener('pointerdown', (event) => startPointer(event, pane, event.target === handle ? 'resize' : 'move'));
  node.addEventListener('focus', () => selectPane(pane.id));
  node.addEventListener('click', () => selectPane(pane.id));
  return node;
}

function renderEditor() {
  const pane = selectedPane();
  const disabled = !pane;
  for (const selector of ['#pane-label', '#pane-opportunity-type', '#pane-importance', '#pane-notes', '#pane-material-path', '#pane-material-fit', '#pane-material-opacity', '#pane-material-role', '#clear-pane-material', '#lock-pane', '#duplicate-pane', '#delete-pane']) {
    document.querySelector(selector).disabled = disabled;
  }
  for (const button of document.querySelectorAll('.nudge-pane')) {
    button.disabled = disabled || pane?.locked === true;
  }
  if (!pane) {
    document.querySelector('#pane-fields').textContent = '';
    document.querySelector('#opportunity-type-hint').textContent = '';
    return;
  }
  document.querySelector('#pane-label').value = pane.label || '';
  document.querySelector('#pane-opportunity-type').value = pane.opportunityType || '';
  document.querySelector('#pane-importance').value = pane.importance || 'supporting';
  document.querySelector('#pane-notes').value = pane.notes || '';
  const material = paneMaterial(pane);
  document.querySelector('#pane-material-path').value = material?.path || '';
  document.querySelector('#pane-material-fit').value = material?.fit || 'cover';
  document.querySelector('#pane-material-opacity').value = material?.opacity ?? 0.35;
  document.querySelector('#pane-material-role').value = material?.role || 'imagination-paint';
  document.querySelector('#lock-pane').textContent = pane.locked ? 'Unlock' : 'Lock';
  renderPaneFields(pane);
}

function schemaForOpportunityType(id) {
  return boardState.opportunityTypes.find((entry) => entry.id === id) || null;
}

function renderPaneFields(pane) {
  const container = document.querySelector('#pane-fields');
  const hint = document.querySelector('#opportunity-type-hint');
  container.textContent = '';
  const schema = schemaForOpportunityType(pane.opportunityType);
  if (!schema) {
    hint.textContent = pane.opportunityType
      ? 'Unknown opportunity type (schema not found on disk).'
      : 'Unset - this pane is a sketch surface only, not bound to a real WeakAuras template.';
    return;
  }
  hint.textContent = schema.description || '';
  pane.fields = pane.fields || {};
  for (const [key, propSchema] of Object.entries(schema.properties || {})) {
    const row = document.createElement('div');
    row.className = 'pane-field-row';
    if (propSchema.description) {
      row.title = propSchema.description;
    }
    const label = document.createElement('label');
    const required = schema.required.includes(key);
    label.textContent = `${key}${required ? ' *' : ''}`;
    label.htmlFor = `pane-field-${key}`;
    const types = Array.isArray(propSchema.type) ? propSchema.type : [propSchema.type];
    const kind = types.includes('boolean') ? 'boolean' : (types.includes('number') || types.includes('integer')) ? 'number' : 'string';
    const input = document.createElement('input');
    input.id = `pane-field-${key}`;
    input.dataset.fieldKey = key;
    input.dataset.fieldKind = kind;
    if (kind === 'boolean') {
      input.type = 'checkbox';
      input.checked = pane.fields[key] ?? propSchema.default ?? false;
    } else if (kind === 'number') {
      input.type = 'number';
      input.step = 'any';
      input.value = pane.fields[key] ?? propSchema.default ?? '';
    } else {
      input.type = 'text';
      input.value = pane.fields[key] ?? propSchema.default ?? '';
    }
    input.addEventListener('input', updatePaneFieldFromEditor);
    row.append(label, input);
    container.appendChild(row);
  }
}

function updatePaneFieldFromEditor(event) {
  const pane = selectedPane();
  if (!pane) {
    return;
  }
  const key = event.target.dataset.fieldKey;
  const kind = event.target.dataset.fieldKind;
  pane.fields = pane.fields || {};
  if (kind === 'boolean') {
    pane.fields[key] = event.target.checked;
  } else if (kind === 'number') {
    const number = Number.parseFloat(event.target.value);
    if (Number.isFinite(number)) {
      pane.fields[key] = number;
    } else {
      delete pane.fields[key];
    }
  } else {
    pane.fields[key] = event.target.value;
  }
  // width/height are the template's own declared real-unit size (e.g.
  // buff_uptime_aurabar's 127.5x15 wide bar) - the on-canvas frame should
  // always reflect that, not drift into an arbitrary box shape.
  if (key === 'width' || key === 'height') {
    syncPaneGridToFields(pane);
  }
  scheduleSave('pane-field-edited', pane.id);
}

function syncPaneGridToFields(pane) {
  const width = Number(pane.fields?.width);
  const height = Number(pane.fields?.height);
  if (Number.isFinite(width) && width > 0) {
    pane.grid.w = Math.round(width);
  }
  if (Number.isFinite(height) && height > 0) {
    pane.grid.h = Math.round(height);
  }
  clampPane(pane);
  positionPaneNode(pane);
}

function updatePaneOpportunityType(value) {
  const pane = selectedPane();
  if (!pane) {
    return;
  }
  pane.opportunityType = value;
  const schema = schemaForOpportunityType(value);
  const previousFields = pane.fields || {};
  const nextFields = {};
  if (schema) {
    for (const [key, propSchema] of Object.entries(schema.properties || {})) {
      // width/height are the template's own declared real-unit size, not
      // user-authored data - carrying them over from a previous type just
      // freezes the frame at whatever type was picked first (e.g. every
      // aurabar type shares the literal key name "width", so the old value
      // kept winning the "preserve overlapping fields" check below forever).
      // Always take the new type's own default for these two.
      if (key === 'width' || key === 'height') {
        if (propSchema.default !== undefined) {
          nextFields[key] = propSchema.default;
        }
      } else if (Object.prototype.hasOwnProperty.call(previousFields, key)) {
        nextFields[key] = previousFields[key];
      } else if (propSchema.default !== undefined) {
        nextFields[key] = propSchema.default;
      }
    }
  }
  pane.fields = nextFields;
  syncPaneGridToFields(pane);
  scheduleSave('pane-opportunity-type-edited', pane.id);
  renderEditor();
  renderCanvas();
}

function renderMeta() {
  const meta = document.querySelector('#board-meta');
  const board = boardState.board;
  const updatedAt = board.updatedAt ? new Date(board.updatedAt) : null;
  meta.textContent = '';
  for (const value of [
    board.title,
    board.status,
    board.id,
    board.viewport.preset,
    `${board.panes.length} panes`,
    `grid ${board.viewport.grid}px`,
    `zoom ${boardState.zoom}x`,
    updatedAt && !Number.isNaN(updatedAt.getTime()) ? `updated ${formatTime(updatedAt)}` : null
  ]) {
    if (!value) {
      continue;
    }
    const chip = document.createElement('span');
    chip.textContent = value;
    meta.appendChild(chip);
  }
  renderOwnershipBanner();
}

function renderOrientation() {
  document.querySelector('#save-status').textContent = boardState.saveStatus || 'Changed';
  document.querySelector('#last-change').textContent = boardState.lastChange || 'Last change: none this session';
}

function renderCommands() {
  ensureCollaboration();
  const list = document.querySelector('#board-command-list');
  list.textContent = '';
  for (const command of boardState.board.collaboration.commands) {
    const item = document.createElement('li');
    item.textContent = `${command.text} / ${command.scope}`;
    list.appendChild(item);
  }
}

function renderOwnershipBanner() {
  const banner = document.querySelector('#ownership-banner');
  const board = boardState.board;
  const owner = board.source?.createdBy === 'agent' ? 'agent' : 'human';
  const basedOn = board.source?.basedOn ? ` / based on ${board.source.basedOn}` : '';
  banner.dataset.status = board.status || 'human-sketch';
  banner.textContent = `${statusLabel(board.status)} / ${owner}${basedOn}`;
}

function statusLabel(status) {
  const labels = {
    'human-sketch': 'Human sketch',
    'agent-proposal': 'Agent proposal',
    'human-accepted': 'Accepted',
    superseded: 'Superseded',
    parked: 'Parked',
    rejected: 'Rejected'
  };
  return labels[status] || 'Working view';
}

function selectPane(id) {
  boardState.selectedId = id;
  updateSelectionAttrs();
  renderEditor();
}

function selectedPane() {
  return boardState.board?.panes.find((pane) => pane.id === boardState.selectedId) || null;
}

function paneMaterial(pane) {
  if (!pane?.material || pane.material.type !== 'image') {
    return null;
  }
  const materialPath = normalizeMaterialPath(pane.material.path);
  if (!materialPath) {
    return null;
  }
  return {
    type: 'image',
    path: materialPath,
    fit: ['contain', 'cover', 'tile'].includes(pane.material.fit) ? pane.material.fit : 'cover',
    opacity: clampNumber(pane.material.opacity, 0.05, 1, 0.35),
    role: String(pane.material.role || 'imagination-paint').slice(0, 80)
  };
}

function materialFromEditor() {
  const materialPath = normalizeMaterialPath(document.querySelector('#pane-material-path').value);
  if (!materialPath) {
    return null;
  }
  return {
    type: 'image',
    path: materialPath,
    fit: document.querySelector('#pane-material-fit').value,
    opacity: clampNumber(document.querySelector('#pane-material-opacity').value, 0.05, 1, 0.35),
    role: document.querySelector('#pane-material-role').value || 'imagination-paint'
  };
}

function normalizeMaterialPath(value) {
  const raw = String(value || '').replace(/\\/g, '/').trim();
  if (!raw || raw.includes('\0') || raw.includes(':') || raw.startsWith('/') || raw.startsWith('..')) {
    return null;
  }
  const parts = raw.split('/');
  if (parts[0] !== 'materials' || parts.some((part) => !part || part === '.' || part === '..')) {
    return null;
  }
  if (!/\.png$/i.test(raw)) {
    return null;
  }
  return raw.slice(0, 220);
}

function materialUrl(materialPath) {
  return `../../../workspace/pane-board/${materialPath.split('/').map(encodeURIComponent).join('/')}`;
}

function clampNumber(value, min, max, fallback) {
  const number = Number.parseFloat(value);
  if (!Number.isFinite(number)) {
    return fallback;
  }
  return Math.max(min, Math.min(max, number));
}

function startPointer(event, pane, mode) {
  boardState.selectedId = pane.id;
  updateSelectionAttrs();
  renderEditor();
  if (pane.locked) {
    return;
  }
  event.preventDefault();
  event.currentTarget.setPointerCapture(event.pointerId);
  boardState.drag = {
    id: pane.id,
    mode,
    startX: event.clientX,
    startY: event.clientY,
    grid: { ...pane.grid }
  };
  event.currentTarget.addEventListener('pointermove', movePointer);
  event.currentTarget.addEventListener('pointerup', endPointer, { once: true });
}

function movePointer(event) {
  const drag = boardState.drag;
  if (!drag) {
    return;
  }
  const pane = boardState.board.panes.find((entry) => entry.id === drag.id);
  if (!pane) {
    return;
  }
  const scale = renderScale();
  const dx = Math.round((event.clientX - drag.startX) / scale);
  const dy = Math.round((event.clientY - drag.startY) / scale);
  if (drag.mode === 'resize') {
    pane.grid.w = Math.max(1, drag.grid.w + dx);
    pane.grid.h = Math.max(1, drag.grid.h + dy);
  } else {
    pane.grid.x = Math.max(0, drag.grid.x + dx);
    pane.grid.y = Math.max(0, drag.grid.y + dy);
  }
  clampPane(pane);
  positionPaneNode(pane);
  renderEditor();
}

function endPointer(event) {
  event.currentTarget.removeEventListener('pointermove', movePointer);
  const changedPaneId = boardState.drag?.id || null;
  boardState.drag = null;
  scheduleSave('pane-moved', changedPaneId);
}

function updateSelectedPaneFromEditor(event) {
  const pane = selectedPane();
  if (!pane) {
    return;
  }
  pane.label = document.querySelector('#pane-label').value;
  pane.importance = document.querySelector('#pane-importance').value;
  pane.notes = document.querySelector('#pane-notes').value;
  pane.material = materialFromEditor();
  const reason = event?.target?.id?.startsWith('pane-material-') ? 'pane-material-edited' : 'pane-edited';
  scheduleSave(reason, pane.id);
  renderCanvas();
  renderMeta();
}

function clearSelectedPaneMaterial() {
  const pane = selectedPane();
  if (!pane) {
    return;
  }
  pane.material = null;
  scheduleSave('pane-material-cleared', pane.id);
  renderBoard();
}

function renderCanvas() {
  const canvas = document.querySelector('#board-canvas');
  canvas.textContent = '';
  for (const pane of boardState.board.panes) {
    canvas.appendChild(renderPane(pane));
  }
}

function positionPaneNode(pane) {
  const node = document.querySelector(`[data-pane-id="${pane.id}"]`);
  if (!node) {
    return;
  }
  const scale = renderScale();
  node.style.left = `${pane.grid.x * scale}px`;
  node.style.top = `${pane.grid.y * scale}px`;
  node.style.width = `${pane.grid.w * scale}px`;
  node.style.height = `${pane.grid.h * scale}px`;
  applyPanePadding(node, pane, scale);
  applyPaneTypography(node, pane, scale);
  const meta = node.querySelector('small');
  if (meta) {
    meta.textContent = paneMetaText(pane);
  }
}

// CSS's `padding: 9px` on .pane-node is a FIXED amount - a box can never
// render narrower than its own padding+border (content can shrink to 0, but
// padding/border never do), so a real, genuinely tiny element (e.g.
// Tiers/resources_base.py's 3-unit-wide center-seam divider strip) was
// still being inflated to ~20px (9px padding x2 + 1px border x2) and
// bleeding into its flush neighbor, even after the min-width:32px floor
// was removed (confirmed 2026-07-06 - min-width wasn't the whole story).
// Scale padding down for small rendered boxes instead of leaving it fixed,
// so a pane never gets padding wider than a fraction of its own true pixel
// size - normal-sized panes (Mana, Cast Bar, ~200px+) still get the full,
// roomy 9px since the cap only bites once a box is genuinely small.
function applyPanePadding(node, pane, scale) {
  const pixelWidth = pane.grid.w * scale;
  const pixelHeight = pane.grid.h * scale;
  const padding = Math.max(0, Math.min(9, Math.floor(Math.min(pixelWidth, pixelHeight) / 4)));
  node.style.padding = `${padding}px`;
}

// Same problem as applyPanePadding, one level down: title/tag font sizes
// were fixed (1.2rem/0.6rem), so a real, genuinely short bar (Cast Bar
// Backing etc. are only 15 units tall) didn't have room for its own title
// line plus a wrapped tag line without the two visually overlapping -
// this isn't cross-pane bleed (that was the padding bug above), it's a
// same-pane vertical squeeze. Scales down toward the shortest pane
// dimension, floored so text never becomes fully illegible, capped at the
// original design size so normal/roomy panes look exactly as before.
function applyPaneTypography(node, pane, scale) {
  const pixelWidth = pane.grid.w * scale;
  const pixelHeight = pane.grid.h * scale;
  const shortest = Math.min(pixelWidth, pixelHeight);
  const titleSize = Math.max(9, Math.min(19.2, shortest * 0.32));
  const tagSize = Math.max(7, Math.min(9.6, shortest * 0.16));
  const metaSize = Math.max(7, Math.min(10.56, shortest * 0.18));
  const title = node.querySelector('.pane-title');
  const tag = node.querySelector('.pane-tag');
  const meta = node.querySelector('small');
  if (title) {
    title.style.fontSize = `${titleSize}px`;
  }
  if (tag) {
    tag.style.fontSize = `${tagSize}px`;
  }
  if (meta) {
    meta.style.fontSize = `${metaSize}px`;
  }
}

function paneMetaText(pane) {
  // Position only - the title already carries the pane's identity, so
  // repeating its id here was redundant.
  return `${pane.grid.x},${pane.grid.y} / ${pane.grid.w}x${pane.grid.h}`;
}

function updateSelectionAttrs() {
  for (const node of document.querySelectorAll('.pane-node')) {
    node.dataset.selected = node.dataset.paneId === boardState.selectedId ? 'true' : 'false';
    node.dataset.changed = node.dataset.paneId === boardState.changedPaneId ? 'true' : 'false';
  }
}

function toggleSelectedPaneLock() {
  const pane = selectedPane();
  if (!pane) {
    return;
  }
  pane.locked = !pane.locked;
  scheduleSave(pane.locked ? 'pane-locked' : 'pane-unlocked', pane.id);
  renderBoard();
}

function nudgeSelectedPane(dx, dy) {
  const pane = selectedPane();
  if (!pane || pane.locked) {
    return;
  }
  pane.grid.x += dx;
  pane.grid.y += dy;
  clampPane(pane);
  positionPaneNode(pane);
  renderEditor();
  scheduleSave('pane-nudged', pane.id);
}

function addPane() {
  const index = boardState.board.panes.length + 1;
  const pane = {
    id: uniquePaneId(`pane-${index}`),
    label: `Pane ${index}`,
    grid: { x: (6 + index) * 8, y: (6 + index) * 8, w: 224, h: 112 },
    importance: 'supporting',
    locked: false,
    opportunityType: '',
    fields: {},
    notes: ''
  };
  boardState.board.panes.push(pane);
  boardState.selectedId = pane.id;
  scheduleSave('pane-added', pane.id);
  renderBoard();
}

function duplicatePane() {
  const pane = selectedPane();
  if (!pane) {
    return;
  }
  const copy = structuredClone(pane);
  copy.id = uniquePaneId(`${pane.id}-copy`);
  copy.label = `${pane.label} copy`;
  copy.grid = { ...pane.grid, x: pane.grid.x + 16, y: pane.grid.y + 16 };
  copy.locked = false;
  clampPane(copy);
  boardState.board.panes.push(copy);
  boardState.selectedId = copy.id;
  scheduleSave('pane-duplicated', copy.id);
  renderBoard();
}

function deletePane() {
  const pane = selectedPane();
  if (!pane) {
    return;
  }
  boardState.board.panes = boardState.board.panes.filter((entry) => entry.id !== pane.id);
  boardState.selectedId = boardState.board.panes[0]?.id || null;
  scheduleSave('pane-deleted', null);
  renderBoard();
}

async function scheduleSave(reason, paneId = null) {
  clearTimeout(boardState.saveTimer);
  boardState.dirty = true;
  boardState.saveStatus = 'Changed';
  setLastChange(reason, paneId, 'Human');
  if (paneId) {
    flashChangedPane(paneId);
  }
  renderOrientation();
  boardState.saveTimer = setTimeout(async () => {
    boardState.saveTimer = null;
    boardState.saveStatus = 'Saving...';
    renderOrientation();
    try {
      boardState.board = await window.auraPaneBoard.save(boardState.board, reason);
      boardState.lastRevision = await window.auraPaneBoard.revision();
      boardState.dirty = false;
      boardState.lastSavedAt = boardState.board.updatedAt || new Date().toISOString();
      boardState.saveStatus = savedLabel(boardState.lastSavedAt);
      showMessage('Saved current board.');
      renderBoard();
    } catch (error) {
      boardState.saveStatus = 'Changed';
      showMessage(error.message);
      renderBoard();
    }
  }, 120);
}

async function grabState() {
  clearTimeout(boardState.saveTimer);
  boardState.saveTimer = null;
  boardState.saveStatus = 'Saving...';
  renderOrientation();
  boardState.board = await window.auraPaneBoard.save(boardState.board, 'before-snapshot');
  boardState.lastRevision = await window.auraPaneBoard.revision();
  boardState.dirty = false;
  boardState.lastSavedAt = boardState.board.updatedAt || new Date().toISOString();
  boardState.saveStatus = savedLabel(boardState.lastSavedAt);
  setLastChange('before-snapshot', null, 'Human');
  const status = document.querySelector('#snapshot-status').value;
  const title = document.querySelector('#snapshot-title').value || boardState.board.title;
  const basedOnInput = document.querySelector('#snapshot-based-on');
  const basedOn = basedOnInput.value || (status === 'agent-proposal' ? boardState.board.id : '');
  basedOnInput.value = basedOn;
  try {
    const result = await window.auraPaneBoard.snapshot({ board: boardState.board, status, title, basedOn });
    showMessage(`Grabbed ${relativePath(result.path)}.`);
    renderBoard();
  } catch (error) {
    showMessage(error.message);
  }
}

async function exportPng() {
  clearTimeout(boardState.saveTimer);
  boardState.saveTimer = null;
  clearChangedPaneCue();
  boardState.saveStatus = 'Saving...';
  renderOrientation();
  boardState.board = await window.auraPaneBoard.save(boardState.board, 'before-png-export');
  boardState.lastRevision = await window.auraPaneBoard.revision();
  boardState.dirty = false;
  boardState.lastSavedAt = boardState.board.updatedAt || new Date().toISOString();
  boardState.saveStatus = savedLabel(boardState.lastSavedAt);
  setLastChange('before-png-export', null, 'Human');
  renderBoard();
  setStableCaptureMode(true);
  try {
    const result = await window.auraPaneBoard.exportPng({ board: boardState.board, title: boardState.board.title });
    showMessage(`PNG saved ${relativePath(result.path)}.`);
  } finally {
    setStableCaptureMode(false);
  }
}

async function refreshBoard(message = 'Refreshed from disk.', options = {}) {
  clearTimeout(boardState.saveTimer);
  boardState.saveTimer = null;
  boardState.board = await window.auraPaneBoard.load();
  boardState.lastRevision = await window.auraPaneBoard.revision();
  boardState.dirty = false;
  boardState.lastSavedAt = boardState.board.updatedAt || null;
  boardState.saveStatus = savedLabel(boardState.lastSavedAt);
  if (options.externalChange === true) {
    setLastChange('disk-redraw', null, 'Labs');
  }
  boardState.selectedId = boardState.board.panes[0]?.id || null;
  renderBoard();
  showMessage(message);
}

async function returnToSketch() {
  clearTimeout(boardState.saveTimer);
  boardState.saveTimer = null;
  boardState.saveStatus = 'Saving...';
  renderOrientation();
  boardState.board.status = 'human-sketch';
  boardState.board.source = {
    ...(boardState.board.source || {}),
    createdBy: 'human',
    basedOn: null,
    project: 'Weak Auras',
    context: 'layout intent sketch'
  };
  boardState.board = await window.auraPaneBoard.save(boardState.board, 'return-to-human-sketch');
  boardState.lastRevision = await window.auraPaneBoard.revision();
  boardState.dirty = false;
  boardState.lastSavedAt = boardState.board.updatedAt || new Date().toISOString();
  boardState.saveStatus = savedLabel(boardState.lastSavedAt);
  setLastChange('return-to-human-sketch', null, 'Human');
  renderBoard();
  showMessage('Returned current board to Human sketch.');
}

function addBoardCommand() {
  const input = document.querySelector('#board-command-input');
  const text = input.value.trim();
  if (!text) {
    showMessage('Add board-local guidance first.');
    return;
  }
  ensureCollaboration();
  boardState.board.collaboration.commands.push({
    id: `board-guidance-${Date.now()}`,
    text,
    createdBy: 'human',
    scope: 'board-only',
    status: 'open',
    createdAt: new Date().toISOString()
  });
  boardState.board.collaboration.commands = boardState.board.collaboration.commands.slice(-24);
  input.value = '';
  scheduleSave('board-guidance-added', null);
  renderCommands();
}

async function captureBoard() {
  clearTimeout(boardState.saveTimer);
  boardState.saveTimer = null;
  clearChangedPaneCue();
  boardState.saveStatus = 'Saving...';
  renderOrientation();
  boardState.board = await window.auraPaneBoard.save(boardState.board, 'before-resting-capture');
  boardState.lastRevision = await window.auraPaneBoard.revision();
  boardState.dirty = false;
  boardState.lastSavedAt = boardState.board.updatedAt || new Date().toISOString();
  boardState.saveStatus = savedLabel(boardState.lastSavedAt);
  setLastChange('before-resting-capture', null, 'Human');
  renderBoard();
  setStableCaptureMode(true);
  try {
    const result = await window.auraPaneBoard.capture({
      board: boardState.board,
      title: document.querySelector('#capture-title').value || boardState.board.title,
      sourceArtifact: document.querySelector('#capture-source-artifact').value,
      humanSignal: document.querySelector('#capture-human-signal').value,
      includeScreenshot: document.querySelector('#capture-include-screenshot').checked
    });
    showMessage(`Captured ${relativePath(result.path)}.`);
  } finally {
    setStableCaptureMode(false);
  }
}

function startRevisionWatch() {
  clearInterval(boardState.revisionTimer);
  boardState.revisionTimer = setInterval(async () => {
    if (boardState.dirty || boardState.saveTimer) {
      return;
    }
    const revision = await window.auraPaneBoard.revision();
    if (hasRevisionChanged(revision, boardState.lastRevision)) {
      await refreshBoard('Redrew from disk change.', { externalChange: true });
    }
  }, 1800);
}

function hasRevisionChanged(nextRevision, previousRevision) {
  return nextRevision?.exists === true
    && previousRevision?.exists === true
    && (nextRevision.mtimeMs !== previousRevision.mtimeMs || nextRevision.size !== previousRevision.size);
}

function ensureCollaboration() {
  boardState.board.collaboration = boardState.board.collaboration || {};
  boardState.board.collaboration.notes = boardState.board.collaboration.notes || {};
  boardState.board.collaboration.notes.human = boardState.board.collaboration.notes.human || '';
  boardState.board.collaboration.notes.labs = boardState.board.collaboration.notes.labs || '';
  boardState.board.collaboration.commands = Array.isArray(boardState.board.collaboration.commands)
    ? boardState.board.collaboration.commands
    : [];
}

function clampPanesToBoard() {
  for (const pane of boardState.board.panes) {
    clampPane(pane);
  }
}

function clampPane(pane) {
  const maxW = Math.floor(boardState.board.viewport.width / GRID);
  const maxH = Math.floor(boardState.board.viewport.height / GRID);
  pane.grid.w = Math.min(Math.max(1, pane.grid.w), maxW);
  pane.grid.h = Math.min(Math.max(1, pane.grid.h), maxH);
  pane.grid.x = Math.min(Math.max(0, pane.grid.x), maxW - pane.grid.w);
  pane.grid.y = Math.min(Math.max(0, pane.grid.y), maxH - pane.grid.h);
}

function uniquePaneId(seed) {
  let id = slug(seed);
  let count = 2;
  while (boardState.board.panes.some((pane) => pane.id === id)) {
    id = `${slug(seed)}-${count}`;
    count += 1;
  }
  return id;
}

function slug(value) {
  return String(value || 'pane')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 48) || 'pane';
}

function setLastChange(reason, paneId, actor) {
  boardState.lastChange = `Last change: ${changeLabel(reason, paneId, actor)}`;
}

function changeLabel(reason, paneId, actor) {
  const who = actor === 'Labs' ? 'Labs' : 'Human';
  const paneLabel = paneId ? ` ${paneId}` : '';
  const labels = {
    'title-edited': `${who} changed board title`,
    'viewport-edited': `${who} changed viewport`,
    'status-edited': `${who} changed board state`,
    'screen-note-edited': `${who} changed surface note`,
    'human-note-edited': 'Human changed Human note',
    'labs-note-edited': 'Labs changed Labs note',
    'board-guidance-added': 'Human added board guidance',
    'pane-added': `${who} added${paneLabel}`,
    'pane-duplicated': `${who} duplicated${paneLabel}`,
    'pane-deleted': `${who} deleted a pane`,
    'pane-moved': `${who} moved${paneLabel}`,
    'pane-nudged': `${who} nudged${paneLabel}`,
    'pane-edited': `${who} edited${paneLabel}`,
    'pane-opportunity-type-edited': `${who} changed opportunity type on${paneLabel}`,
    'pane-field-edited': `${who} edited a field on${paneLabel}`,
    'pane-material-edited': `${who} changed material on${paneLabel}`,
    'pane-material-cleared': `${who} cleared material on${paneLabel}`,
    'pane-locked': `${who} locked${paneLabel}`,
    'pane-unlocked': `${who} unlocked${paneLabel}`,
    'before-snapshot': `${who} saved before grab`,
    'before-png-export': `${who} saved before PNG export`,
    'before-resting-capture': `${who} saved before resting capture`,
    'return-to-human-sketch': `${who} returned board to Human sketch`,
    'disk-redraw': 'Labs/disk changed board state'
  };
  return labels[reason] || `${who} changed board`;
}

function flashChangedPane(paneId) {
  clearTimeout(boardState.changedPaneTimer);
  boardState.changedPaneId = paneId;
  updateSelectionAttrs();
  boardState.changedPaneTimer = setTimeout(() => {
    clearChangedPaneCue();
  }, 2200);
}

function clearChangedPaneCue() {
  clearTimeout(boardState.changedPaneTimer);
  boardState.changedPaneTimer = null;
  boardState.changedPaneId = null;
  updateSelectionAttrs();
}

function savedLabel(value) {
  const date = value ? new Date(value) : new Date();
  return `Saved ${formatTime(date)}`;
}

function formatTime(value) {
  const date = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(date.getTime())) {
    return '--:--:--';
  }
  return date.toLocaleTimeString([], {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false
  });
}

function setStableCaptureMode(enabled) {
  document.body.dataset.captureStable = enabled ? 'true' : 'false';
}

function relativePath(value) {
  return String(value || '').replace(/^.*workspace[\\/]/, 'workspace/');
}

function showMessage(message) {
  document.querySelector('#board-message').textContent = message;
}
