"""
build_reference.py - emit a single self-contained HTML reference of the ability inventory
+ the talent<->ability attachments (referencedTerms), for community handoff.

Sources: out/<CLASS>.json (the consolidated ability inventory) + Input/<class>_talents.json
(talents: name, spellId, tree, description, referencedTerms) matched by token via
wa_index/coa_value_domains.json.

Attachment = a talent's referencedTerm resolves to an ability (or another talent) in the
same class. First-pass name matching (exact-normalised or whole-substring, singular/plural
tolerant) - term RESOLUTION is a known later refinement; unresolved terms are shown as text.

Output: reference.html - search box, Class + Spec filters, and two views:
  * Abilities (with the talents attached to each)
  * Talents (with the abilities each references)
Ability rows show the spellId range across ranks.

    py build_reference.py
"""
import glob
import html
import json
import os
import re

_THIS = os.path.dirname(os.path.abspath(__file__))
_WA = os.path.dirname(_THIS)
_ROOT = os.path.dirname(_WA)
INPUT = os.path.join(_ROOT, "Input")
OUT = os.path.join(_THIS, "out")
COA = os.path.join(_WA, "wa_index", "coa_value_domains.json")


def norm(s):
    return re.sub(r"[^a-z0-9 ]", "", (s or "").lower()).strip()


def singular(s):
    return s[:-1] if s.endswith("s") and len(s) > 4 else s


def matches(term, name):
    """term (referencedTerm) vs an ability/talent name - first-pass resolver."""
    a, b = singular(norm(term)), singular(norm(name))
    if not a or not b:
        return False
    if a == b:
        return True
    short, long = (a, b) if len(a) <= len(b) else (b, a)
    return len(short) >= 5 and (" " + short + " ") in (" " + long + " ") or short == long


def talent_file_for(token, coa):
    disp = coa["class_types"].get(token)
    if not disp:
        return None
    fn = disp.lower().replace(" ", "_").replace("'", "") + "_talents.json"
    p = os.path.join(INPUT, fn)
    return p if os.path.exists(p) else None


def main():
    coa = json.load(open(COA, encoding="utf-8"))
    classes, abilities, talents = {}, [], []

    for f in sorted(glob.glob(os.path.join(OUT, "*.json"))):
        base = os.path.basename(f)
        if base in ("_summary.json", "captures.json"):
            continue
        inv = json.load(open(f, encoding="utf-8"))
        token = inv["class"]
        classes[token] = {"display": inv.get("display") or token,
                          "specs": sorted(inv.get("bySpec", {}).keys())}

        ab_idx = {}   # norm(name) -> global ability index (this class)
        for name, a in inv["abilities"].items():
            ids = sorted(int(x) for x in a.get("spellIds", []))
            gi = len(abilities)
            abilities.append({"i": gi, "c": token, "name": name, "spec": a.get("spec"),
                              "src": a.get("sources", []), "ids": ids,
                              "passive": bool(a.get("isPassive")), "tal": []})
            ab_idx[norm(name)] = gi

        tfile = talent_file_for(token, coa)
        if not tfile:
            continue
        tdata = json.load(open(tfile, encoding="utf-8"))
        tal_by_name = {}
        cls_talents = []
        for t in tdata.get("talents", []):
            gi = len(talents)
            rec = {"i": gi, "c": token, "name": t.get("name"), "spec": t.get("tree"),
                   "id": t.get("spellId"), "desc": t.get("description") or "",
                   "terms": t.get("referencedTerms") or [], "abl": []}
            talents.append(rec)
            cls_talents.append(rec)
            if t.get("name"):
                tal_by_name[norm(t["name"])] = gi

        # resolve attachments within this class
        cls_abils = [a for a in abilities if a["c"] == token]
        for rec in cls_talents:
            for term in rec["terms"]:
                for a in cls_abils:
                    if matches(term, a["name"]) and a["i"] not in rec["abl"]:
                        rec["abl"].append(a["i"])
                        abilities[a["i"]]["tal"].append(rec["i"])

    data = {"classes": classes, "abilities": abilities, "talents": talents}
    payload = json.dumps(data, ensure_ascii=False, separators=(",", ":"))

    html_out = _TEMPLATE.replace("/*DATA*/", payload)
    outp = os.path.join(_THIS, "reference.html")
    with open(outp, "w", encoding="utf-8") as fh:
        fh.write(html_out)

    n_att = sum(len(t["abl"]) for t in talents)
    print(f"classes {len(classes)} | abilities {len(abilities)} | talents {len(talents)} | "
          f"talent->ability attachments {n_att}")
    print(f"wrote {os.path.relpath(outp, _ROOT)}  ({os.path.getsize(outp)//1024} KB)")


_TEMPLATE = r"""<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Conquest of Azeroth - Ability & Talent Reference</title>
<style>
:root{--bg:#14161c;--panel:#1c1f28;--panel2:#232734;--fg:#e7e9ee;--dim:#9aa2b1;--acc:#c8a24a;--line:#2c3140;--link:#6fb3ff}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--fg);font:14px/1.5 system-ui,Segoe UI,Roboto,sans-serif}
header{position:sticky;top:0;background:var(--panel);border-bottom:1px solid var(--line);padding:12px 16px;z-index:5}
h1{margin:0 0 8px;font-size:16px;letter-spacing:.3px}h1 small{color:var(--dim);font-weight:400}
.controls{display:flex;flex-wrap:wrap;gap:8px;align-items:center}
input,select{background:var(--panel2);color:var(--fg);border:1px solid var(--line);border-radius:6px;padding:7px 9px;font-size:13px}
input#q{flex:1;min-width:180px}
.tabs{display:flex;gap:4px;margin-left:auto}
.tab{padding:7px 12px;border:1px solid var(--line);border-radius:6px;background:var(--panel2);cursor:pointer;color:var(--dim)}
.tab.on{color:var(--bg);background:var(--acc);border-color:var(--acc);font-weight:600}
#count{color:var(--dim);font-size:12px;padding:6px 16px}
main{padding:4px 16px 40px;max-width:1100px;margin:0 auto}
.row{border:1px solid var(--line);border-radius:8px;margin:6px 0;background:var(--panel);overflow:hidden}
.head{display:flex;gap:10px;align-items:center;padding:9px 12px;cursor:pointer}
.head:hover{background:var(--panel2)}
.nm{font-weight:600}
.badge{font-size:11px;padding:1px 7px;border-radius:10px;border:1px solid var(--line);color:var(--dim);white-space:nowrap}
.badge.spec{color:var(--acc);border-color:#4a3f22}
.ids{color:var(--dim);font-size:12px;font-variant-numeric:tabular-nums;margin-left:auto;white-space:nowrap}
.src{font-size:10px;color:var(--dim);text-transform:uppercase;letter-spacing:.5px}
.body{display:none;padding:4px 12px 12px;border-top:1px solid var(--line);color:var(--dim)}
.row.open .body{display:block}
.desc{color:var(--fg);white-space:pre-wrap;margin:6px 0}
.att{margin:8px 0 2px;font-size:12px;color:var(--dim);text-transform:uppercase;letter-spacing:.5px}
.chip{display:inline-block;margin:2px 4px 2px 0;padding:2px 8px;border:1px solid var(--line);border-radius:6px;background:var(--panel2);cursor:pointer;font-size:12px}
.chip:hover{border-color:var(--link);color:var(--link)}
.term{display:inline-block;margin:2px 4px 2px 0;padding:2px 8px;border:1px dashed var(--line);border-radius:6px;color:var(--dim);font-size:12px}
.none{color:var(--dim);font-style:italic}
</style></head><body>
<header>
<h1>Conquest of Azeroth &mdash; Ability &amp; Talent Reference <small id="sub"></small></h1>
<div class="controls">
<input id="q" placeholder="Search name…" autocomplete="off">
<select id="cls"></select>
<select id="spec"></select>
<div class="tabs"><div class="tab on" data-v="ability">Abilities</div><div class="tab" data-v="talent">Talents</div></div>
</div></header>
<div id="count"></div>
<main id="list"></main>
<script>
const DATA=/*DATA*/;
const A=DATA.abilities, T=DATA.talents, C=DATA.classes;
let view="ability", q="", cls="", spec="";
const el=id=>document.getElementById(id);
const esc=s=>(s||"").replace(/[&<>]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;'}[c]));
const idrange=ids=>!ids||!ids.length?"":ids.length==1?(""+ids[0]):(ids[0]+"–"+ids[ids.length-1]+" ("+ids.length+" ranks)");

el("sub").textContent="· "+Object.keys(C).length+" classes · "+A.length+" abilities · "+T.length+" talents";
// class filter
const csel=el("cls"); csel.innerHTML='<option value="">All classes</option>'+
  Object.entries(C).sort((a,b)=>a[1].display.localeCompare(b[1].display))
   .map(([t,c])=>`<option value="${t}">${esc(c.display)}</option>`).join("");
function fillSpecs(){const s=el("spec");let specs=new Set();
  Object.entries(C).forEach(([t,c])=>{if(!cls||t==cls)c.specs.forEach(x=>specs.add(x));});
  s.innerHTML='<option value="">All specs</option>'+[...specs].sort().map(x=>`<option>${esc(x)}</option>`).join("");}
fillSpecs();

function talChip(i){const t=T[i];return `<span class="chip" data-go="talent:${i}">${esc(t.name)}<span class="src"> ${esc(t.spec||"")}</span></span>`;}
function ablChip(i){const a=A[i];return `<span class="chip" data-go="ability:${i}">${esc(a.name)}</span>`;}

function render(){
  const items=(view=="ability"?A:T).filter(x=>{
    if(cls&&x.c!=cls)return false;
    if(spec&&x.spec!=spec)return false;
    if(q&&!(x.name||"").toLowerCase().includes(q))return false;
    return true;});
  el("count").textContent=items.length+" "+(view=="ability"?"abilities":"talents");
  const rows=items.map(x=>{
    const disp=C[x.c].display;
    if(view=="ability"){
      const tal=x.tal.length?x.tal.map(talChip).join(""):'<span class="none">no talents reference this</span>';
      return `<div class="row" data-k="ability:${x.i}"><div class="head">
        <span class="nm">${esc(x.name)}</span>
        <span class="badge">${esc(disp)}</span><span class="badge spec">${esc(x.spec||"")}</span>
        ${x.passive?'<span class="badge">passive</span>':''}
        <span class="ids">${idrange(x.ids)}</span></div>
        <div class="body"><div class="src">${esc((x.src||[]).join(" · "))}</div>
        <div class="att">Talents attached</div>${tal}</div></div>`;
    } else {
      const abl=x.abl.length?x.abl.map(ablChip).join(""):"";
      const terms=(x.terms||[]).map(tm=>`<span class="term">${esc(tm)}</span>`).join("");
      return `<div class="row" data-k="talent:${x.i}"><div class="head">
        <span class="nm">${esc(x.name)}</span>
        <span class="badge">${esc(disp)}</span><span class="badge spec">${esc(x.spec||"")}</span>
        <span class="ids">${x.id||""}</span></div>
        <div class="body"><div class="desc">${esc(x.desc)}</div>
        <div class="att">Abilities referenced</div>${abl||'<span class="none">none resolved</span>'}
        <div class="att">Referenced terms</div>${terms||'<span class="none">none</span>'}</div></div>`;
    }
  }).join("");
  el("list").innerHTML=rows||'<p class="none">No matches.</p>';
}

el("list").addEventListener("click",e=>{
  const go=e.target.closest("[data-go]");
  if(go){const [v,i]=go.dataset.go.split(":");switchTo(v,+i);return;}
  const r=e.target.closest(".row");if(r)r.classList.toggle("open");
});
function switchTo(v,i){
  view=v;document.querySelectorAll(".tab").forEach(t=>t.classList.toggle("on",t.dataset.v==v));
  cls=T[i]?(v=="talent"?T[i].c:A[i].c):cls; // keep class context
  const obj=(v=="ability"?A:T)[i]; cls=obj.c; spec=""; q="";
  el("cls").value=cls; fillSpecs(); el("spec").value=""; el("q").value="";
  render();
  requestAnimationFrame(()=>{const node=document.querySelector(`[data-k="${v}:${i}"]`);
    if(node){node.classList.add("open");node.scrollIntoView({block:"center"});}});
}
el("q").addEventListener("input",e=>{q=e.target.value.trim().toLowerCase();render();});
el("cls").addEventListener("change",e=>{cls=e.target.value;spec="";fillSpecs();el("spec").value="";render();});
el("spec").addEventListener("change",e=>{spec=e.target.value;render();});
document.querySelectorAll(".tab").forEach(t=>t.addEventListener("click",()=>{
  view=t.dataset.v;document.querySelectorAll(".tab").forEach(x=>x.classList.toggle("on",x==t));render();}));
render();
</script></body></html>"""


if __name__ == "__main__":
    main()
