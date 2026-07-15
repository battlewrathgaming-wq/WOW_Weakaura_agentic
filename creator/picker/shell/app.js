// app.js - the wizard + the library face. Every screen is a QUESTION, every answer a NARROWING
// (picker_tree.md, the 8 laws). Menus render FROM the data - nothing user-facing is hardcoded
// per class. The mint never authors structure (mint.js fills machine-pressed templates).

/* global LIBRARY, TEMPLATES, mintPack, defaultGroupName, encodeImportStringFromValue, deflateRawBrowser */

const $ = (sel) => document.querySelector(sel);
const el = (tag, attrs = {}, ...kids) => {
  const n = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (k === "class") n.className = v;
    else if (k.startsWith("on")) n.addEventListener(k.slice(2), v);
    else n.setAttribute(k, v);
  }
  for (const k of kids) n.append(k);
  return n;
};

const S = { tab: "wizard", screen: "class", cls: null, spec: null, lane: null,
            scope: null, picks: new Map(), fragment: null, chainSid: null };

const classes = () => Object.keys(LIBRARY.classes).sort();
const cdata = () => LIBRARY.classes[S.cls];
const realSpecs = (cls) => Object.entries(LIBRARY.classes[cls].specs)
  .filter(([, v]) => !v.pseudo && !v.ghost).map(([k]) => k).sort();
const shelf = () => (cdata().specs[S.spec].shelves.dot_target) || [];
const included = () => shelf().filter((r) => !r.excluded);

// ---------------------------------------------------------------- the wizard screens
function crumbs() {
  const parts = [];
  if (S.cls) parts.push(cdata().display);
  if (S.spec) parts.push(S.spec);
  if (S.lane) parts.push(S.lane === "pet" ? "Pets" : "DoTs");
  if (S.scope) parts.push(S.scope === "multi" ? "all targets" : "current target");
  return parts.join(" · ");
}

const SCREENS = {
  class() {
    return frame("What class are you?", "One click - everything after this is your class only.",
      el("div", { class: "grid" }, ...classes().map((c) =>
        el("button", { class: "card", onclick: () => { S.cls = c; go("spec"); } },
          el("b", {}, LIBRARY.classes[c].display)))));
  },
  spec() {
    return frame("Which spec?", "Your common-pool abilities are already folded in - pick where you live.",
      el("div", { class: "grid" }, ...realSpecs(S.cls).map((sp) => {
        const cap = cdata().specs[sp].caption;
        return el("button", { class: "card", onclick: () => { S.spec = sp; go("lane"); } },
          el("b", {}, sp), el("small", {}, cap ? `${cap.spells} abilities` : ""));
      })));
  },
  lane() {
    const dots = included().length;
    const cards = [];
    if (dots) cards.push(el("button", { class: "card", onclick: () => { S.lane = "dot_target"; go("scope"); } },
      el("b", {}, "My DoTs on enemies"), el("small", {}, `${dots} trackable`)));
    cards.push(el("button", { class: "card", onclick: () => { S.lane = "pet"; S.scope = null; go("out"); } },
      el("b", {}, "My pets"), el("small", {}, "guardian health bars")));
    return frame("What do you want on your screen?",
      "Pick a lane, populate it. More lanes (cooldowns, procs, resources) arrive as their contracts land - browse the Library to see everything meanwhile.",
      el("div", { class: "grid" }, ...cards));
  },
  scope() {
    return frame("Watched how?", "This decides the most visible thing about the result.",
      el("div", { class: "grid" },
        el("button", { class: "card wide", onclick: () => { S.scope = "target"; go("picks"); } },
          el("b", {}, "On my current target"),
          el("small", {}, "what's ticking on the thing I'm hitting right now - icons")),
        el("button", { class: "card wide", onclick: () => { S.scope = "multi"; S.lane = "dot_multi"; go("picks"); } },
          el("b", {}, "On everything I've tagged"),
          el("small", {}, "every DoT I've got out, each bar named with its victim - soonest to fall on top"))));
  },
  picks() {
    const rows = shelf().map((r) => {
      if (r.excluded) return el("div", { class: "row excluded" },
        el("span", {}, r.family), el("span", { class: "why" }, r.excluded));
      const id = "pk_" + r.family.replace(/\W/g, "");
      const cb = el("input", { type: "checkbox", id });
      if (S.picks.has(r.family)) cb.checked = true;
      cb.addEventListener("change", () => cb.checked
        ? S.picks.set(r.family, r.spellIds[0]) : S.picks.delete(r.family));
      return el("div", { class: "row" }, cb,
        el("label", { for: id }, r.family),
        el("span", { class: "meta" }, `${r.flavour} · ${r.durS.join("/")}s`));
    });
    return frame("Which ones?", "Your spec's shelf - nothing to type, nothing to know.",
      el("div", { class: "panel" }, ...rows),
      el("div", { class: "actions" },
        el("button", { class: "go", onclick: () => {
          if (!S.picks.size) return;
          go(S.lane === "dot_target" ? "behaviour" : "out");
        } }, "Continue"),
        el("span", { class: "note" }, "excluded rows are listed so the near-miss is readable")));
  },
  behaviour() {
    // decide the NEXT screen at click time - a screen must never redirect mid-render
    // (the everything-ticked walk used to collapse to a blank page here)
    const next = () => included().some((r) => !S.picks.has(r.family)) ? "closer" : "out";
    return frame("Show them only when it matters, or keep them always in place?", "",
      el("div", { class: "grid" },
        el("button", { class: "card wide", onclick: () => { S.fragment = "appear"; go(next()); } },
          el("b", {}, "Appear while it's on them"),
          el("small", {}, "the icon existing IS the signal - gone when the DoT is gone")),
        el("button", { class: "card wide", onclick: () => { S.fragment = "persist"; go(next()); } },
          el("b", {}, "Always there - full colour while it runs, dims when missing"),
          el("small", {}, "the should-I-debuff check: dim = press me"))));
  },
  closer() {
    const rest = included().filter((r) => !S.picks.has(r.family));
    if (!rest.length) { S.screen = "out"; return SCREENS.out(); }  // render out DIRECTLY, no mid-render go
    const rows = rest.map((r) => {
      const id = "cl_" + r.family.replace(/\W/g, "");
      const cb = el("input", { type: "checkbox", id });
      cb.addEventListener("change", () => cb.checked
        ? S.picks.set(r.family, r.spellIds[0]) : S.picks.delete(r.family));
      return el("div", { class: "row" }, cb, el("label", { for: id }, r.family),
        el("span", { class: "meta" }, `${r.flavour} · ${r.durS.join("/")}s`));
    });
    return frame("Add the rest with the same treatment?",
      "Same behaviour, one checkbox pass - anything else at the door.",
      el("div", { class: "panel" }, ...rows),
      el("div", { class: "actions" },
        el("button", { class: "go", onclick: () => go("out") }, "Done - make my string")));
  },
  out() {
    const name = defaultGroupName({ specName: S.spec, lane: S.lane, scope: S.scope });
    const nameInput = el("input", { type: "text", value: name });
    const ta = el("textarea", { class: "out", readonly: "" }, "");
    const status = el("span", { class: "note" }, "");
    const mintNow = async () => {
      try {
        const picks = [...S.picks.entries()].map(([family, repId]) => ({ family, repId }));
        const env = mintPack({ lane: S.lane, templates: TEMPLATES, classToken: S.cls,
          specName: S.spec, scope: S.scope, picks, fragment: S.fragment,
          groupName: nameInput.value || name });
        ta.value = await encodeImportStringFromValue(env, deflateRawBrowser);
        status.textContent = `${env.c.length} aura${env.c.length === 1 ? "" : "s"} in one group - fresh mint, safe to import`;
        status.className = "note ok";
      } catch (e) { ta.value = ""; status.textContent = "mint failed: " + e.message; status.className = "note gap"; }
    };
    const copy = async () => {
      ta.select();
      try { await navigator.clipboard.writeText(ta.value); status.textContent = "copied"; }
      catch { document.execCommand("copy"); status.textContent = "copied (fallback)"; }
    };
    setTimeout(mintNow, 0);
    return frame("Here's your pack.",
      "In game: type /wa → Import → paste. Drag the group where you like.",
      el("div", { class: "searchbar" }, nameInput),
      ta,
      el("div", { class: "actions" },
        el("button", { class: "go", onclick: copy }, "Copy"),
        el("button", { class: "quiet", onclick: mintNow }, "Re-mint"),
        status),
      el("div", { class: "law" },
        "This isn't build-your-full-UI-in-one-go - you get packs, you arrange them in game. ",
        "The styling is a starting point: the group and every aura are fully yours to edit in WeakAuras' own UI."),
      el("div", { class: "actions" },
        el("button", { class: "quiet", onclick: () => { S.lane = null; S.scope = null;
          S.picks = new Map(); S.fragment = null; go("lane"); } }, "Another lane?"),
        el("button", { class: "quiet", onclick: () => { Object.assign(S,
          { screen: "class", cls: null, spec: null, lane: null, scope: null,
            picks: new Map(), fragment: null }); render(); } }, "Start over")));
  },
};

function frame(q, subtext, ...body) {
  return el("div", {},
    el("div", { class: "crumbs" }, crumbs() ? el("span", {}, "", el("b", {}, crumbs())) : ""),
    el("h2", {}, q),
    subtext ? el("p", { class: "sub" }, subtext) : "",
    ...body);
}

function go(screen) { S.screen = screen; render(); }

// ---------------------------------------------------------------- the library face
function libraryFace() {
  const wrap = el("div", {});
  const clsSel = el("select", {}, ...classes().map((c) =>
    el("option", { value: c }, LIBRARY.classes[c].display)));
  if (S.cls) clsSel.value = S.cls;
  const specWrap = el("div", {});
  const detail = el("div", {});
  let trail = [];   // the chain walk's history - back-stepping is first-class
  let origin = null; // where the walk was ENTERED from (cards / search) - probing returns there

  // the pseudo trees speak plainly - never "Necromancer - Class". General doesn't get a tile
  // at all (Battlewrath: ~5 racials + misc reads far bigger than it is); its spells stay
  // reachable through search, and its trackables are folded into every spec's shelf anyway.
  const specLabel = (sp) => sp === "Class" ? "Common pool (the Class tree)" : sp;

  const showSpecs = () => {
    const c = LIBRARY.classes[clsSel.value];
    trail = []; origin = null;
    specWrap.replaceChildren(el("div", { class: "grid" },
      ...Object.entries(c.specs).sort()
        .filter(([sp]) => sp !== "General")
        .map(([sp, v]) => {
          const tag = v.ghost ? " · ghost (not a dev tree)" : "";
          return el("button", { class: "card", onclick: () => showCards(clsSel.value, sp) },
            el("b", {}, specLabel(sp) + tag),
            el("small", {}, v.caption ? `${v.caption.spells} spells · hub: ${v.caption.hub}` : `${v.cards.length} talents`));
        })));
    detail.replaceChildren();
  };

  const showCards = (cls, sp) => {
    const v = LIBRARY.classes[cls].specs[sp];
    trail = [];
    origin = () => showCards(cls, sp);   // a chain entered from here returns here
    const body = v.cards.length
      ? el("div", { class: "panel" }, ...v.cards.map((card) =>
          el("div", { class: "row" },
            el("label", {},
              el("b", {}, card.name + (card.isPassive === "True" ? "  (passive)" : "")),
              el("div", { class: "kv" }, card.description || ""),
              el("div", { class: "chain" },
                el("a", { onclick: () => showChain(cls, String(card.spellId)) }, `chain ${card.spellId} →`))))))
      : el("p", { class: "note" }, v.pseudo
          ? "No dev-authored talent cards here - this is the one general spell tab (racials, professions, class commons). Anything trackable from it is already folded into every spec's shelf."
          : v.ghost
            ? "A ghost: these spells exist in the live DB but no dev tree claims them. Find them through the spell search."
            : "No cards recorded for this tree.");
    detail.replaceChildren(el("h2", {}, `${LIBRARY.classes[cls].display} - ${specLabel(sp)}`), body);
  };

  const showChain = (cls, sid, isBack = false) => {
    const chains = LIBRARY.classes[cls].chains;
    const row = chains[sid];
    if (!row) { detail.prepend(el("p", { class: "gap" }, `spell ${sid}: not in this class's chain slice`)); return; }
    if (!isBack) trail.push(sid);
    const effects = (row.effects || []).map((e) =>
      e.name && e.name.startsWith("CUSTOM_effect_")
        ? el("div", { class: "gap" }, `slot ${e.slot}: effect ${e.effect} - not provided by CoA`)
        : el("div", {}, `slot ${e.slot}: ${e.name}`));
    // an edge renders from what it CARRIES: aura_name-only (applies_aura), a walkable dst, or
    // a dst outside this class's slice - never "undefined"
    const edges = (row.edges || []).map((e) => {
      const rel = e.rel + (e.slot != null ? ` (slot ${e.slot})` : "");
      if (!e.dst) return el("div", {}, `${rel} → ${e.aura_name || "(no destination recorded)"}`);
      const hit = chains[e.dst];
      const label = `${(hit && hit.name) || e.aura_name || "spell"} (${e.dst})`;
      return hit
        ? el("div", {}, `${rel} → `, el("a", { onclick: () => showChain(cls, e.dst) }, label))
        : el("div", { class: "kv" }, `${rel} → ${label} - outside this class's slice`);
    });
    const ax = row.axes || {};
    const backBtn = trail.length > 1
      ? el("button", { class: "quiet", onclick: () => { trail.pop(); showChain(cls, trail[trail.length - 1], true); } },
          "← back along the chain")
      : "";
    const returnBtn = origin
      ? el("button", { class: "quiet", onclick: () => { trail = []; origin(); } }, "↩ return to selection")
      : "";
    const trailLine = trail.length > 1
      ? el("div", { class: "kv" }, "walk: " + trail.map((s) => (chains[s] || {}).name || s).join(" → "))
      : "";
    detail.replaceChildren(
      el("h2", {}, `${row.name || sid}  `, el("span", { class: "kv" }, sid)),
      el("div", { class: "actions" }, backBtn, returnBtn),
      trailLine,
      el("div", { class: "detail chain" },
        el("div", { class: "kv" }, `axes: `,
          el("b", {}, `${ax.invocation || "?"} · ${ax.persistence || "?"} · target:${ax.target || "?"} · ${ax.verb || "?"}`)),
        el("h2", {}, "effects"), ...(effects.length ? effects : [el("div", { class: "kv" }, "none recorded")]),
        el("h2", {}, "edges"), ...(edges.length ? edges : [el("div", { class: "kv" }, "no outgoing edges")])));
  };

  const search = el("input", { type: "search", placeholder: "find a spell by name or id (this class)" });
  const renderSearch = (q) => {
    const chains = LIBRARY.classes[clsSel.value].chains;
    const hits = Object.entries(chains)
      .filter(([sid, r]) => sid.includes(q) || (r.name || "").toLowerCase().includes(q)).slice(0, 30);
    origin = () => renderSearch(q);      // a chain entered from these results returns to them
    detail.replaceChildren(el("div", { class: "panel" }, ...hits.map(([sid, r]) =>
      el("div", { class: "row" }, el("label", {},
        el("a", { class: "chain", onclick: () => { trail = []; showChain(clsSel.value, sid); } },
          `${r.name || "(unnamed)"} (${sid})`))))));
  };
  search.addEventListener("input", () => {
    const q = search.value.trim().toLowerCase();
    if (q.length >= 2) renderSearch(q);
  });

  clsSel.addEventListener("change", showSpecs);
  wrap.append(
    el("p", { class: "sub" },
      "The flattened game as a library: what exists, its effect chains, what spawns what - ID → ID → ID. ",
      "The library teaches; the wizard presses."),
    el("div", { class: "actions" }, clsSel),
    el("div", { class: "searchbar" }, search),
    specWrap, detail);
  showSpecs();
  return wrap;
}

// ---------------------------------------------------------------- render loop
function render() {
  const root = $("#root");
  const tabs = el("div", { class: "tabs" },
    el("button", { class: S.tab === "wizard" ? "on" : "", onclick: () => { S.tab = "wizard"; render(); } }, "Build a pack"),
    el("button", { class: S.tab === "library" ? "on" : "", onclick: () => { S.tab = "library"; render(); } }, "Library"));
  root.replaceChildren(tabs, S.tab === "wizard" ? SCREENS[S.screen]() : libraryFace());
}
render();
