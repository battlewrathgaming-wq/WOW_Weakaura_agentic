// mint.js - the picker's MINT: pressed templates + the user's picks -> one WA import envelope.
// PURE functions (no DOM): the shell calls mintPack in the browser; the Phase-4 harness calls it
// under node with a fixed uidFn for decode-diff cross-validation against the machine.
//
// Laws carried here (picker_tree.md):
//   - one-time minting: fresh uids per mint (WA's own GenerateUniqueID alphabet), no update flow
//   - the shell NEVER authors structure - templates are machine-pressed; this file only fills slots
//   - envelope pinned off a decoded live-check pack: {m,d,c,v:1421,s}; c children carry NO parent
//   - load transform: member load.class = {multi:{[TOKEN]:true}} + use_class:false
//     (the multiselect stored form: false = match-any-of-multi; live-proven by the 110-pack run)

const WA_UID_ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

function mintUid() {
  let s = "";
  for (let i = 0; i < 11; i++) s += WA_UID_ALPHABET[Math.floor(Math.random() * WA_UID_ALPHABET.length)];
  return s;
}

function clone(o) { return JSON.parse(JSON.stringify(o)); }

function setClassLoad(table, classToken) {
  const load = table.load || (table.load = {});
  load.class = { multi: { [classToken]: true } };
  load.use_class = false; // multiselect stored form: false = match any of .multi
}

// picks: [{family, repId}]  (dot_target: one member per pick; dot_multi: one member, all ids)
export function mintPack({ lane, templates, classToken, specName, scope, picks, fragment,
                           groupName, uidFn = mintUid }) {
  const t = templates.lanes[lane];
  if (!t) throw new Error(`unknown lane: ${lane}`);
  const members = [];

  if (lane === "dot_target") {
    const tmpl = t.members[fragment || "appear"];
    if (!tmpl) throw new Error(`unknown fragment: ${fragment}`);
    for (const p of picks) {
      const m = clone(tmpl);
      m.id = p.family;
      m.uid = uidFn();
      m.triggers[0].trigger.auranames = [String(p.repId)];
      setClassLoad(m, classToken);
      members.push(m);
    }
  } else if (lane === "dot_multi") {
    const m = clone(t.members.default);
    m.id = `${specName} DoTs - all targets`;
    m.uid = uidFn();
    m.triggers[0].trigger.auranames = picks.map((p) => String(p.repId));
    setClassLoad(m, classToken);
    members.push(m);
  } else if (lane === "pet") {
    const m = clone(t.members.default);
    m.id = `${specName} - guardian health`;
    m.uid = uidFn();
    members.push(m); // the proven shape rides as-is (load stays as pressed)
  } else {
    throw new Error(`lane not pressed: ${lane}`);
  }

  const group = clone(t.group);
  group.id = groupName;
  group.uid = uidFn();
  group.controlledChildren = members.map((m) => m.id);

  // the pinned envelope: d = group, c = members WITHOUT parent (WA rebuilds wiring on import)
  return { m: "d", d: group, c: members, v: 1421, s: "coa_picker" };
}

export function defaultGroupName({ specName, lane, scope }) {
  if (lane === "pet") return `COA - ${specName} Pets`;
  return `COA - ${specName} DoTs (${scope === "multi" ? "all targets" : "target"})`;
}
