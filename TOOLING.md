# TOOLING — the cross-runtime service bench

A small bench for driving the project's machines deterministically, and — optionally — across two
runtimes. The caller issues a **service call** from its runtime; the machines execute under **your**
runtime; a **receipt** comes back. Mechanical steps stay fixed, auditable gears; judgment lives at the
boundary (what's whitelisted) and the escalations (a `verify` FLAG), never at the per-call interior.

## Schematic

```
  CAPTURE                          SERVICES (whitelisted gears, Weak Auras/plane/)
  ingest/paste_drop.py             decode.py   peek(settled view) / diff / raw      [read-only]
   paste WA export -> inbox/*.txt  verify.py   assemble regression vs goldens/      [read-only]

  caller runtime                        |  your runtime
  --------------------------------------|------------------------------------------
    call.py  --write-->  runtime/queue/ | --poll(~1s)-->  runner.py  (SERVER)
    `py call.py <svc> [args]`           |                 executes ONLY whitelisted {decode, verify, seeds};
        ^                               |                 unknown svc = REFUSED; process-once invariant
        | reason from receipt           |                       |
    call.py <--read--- runtime/receipts/| <--write--------------+   (-> processed/ or errored/)
```

## Tools

| tool | role |
|---|---|
| `ingest/paste_drop.py` (+`.bat`) | Capture terminal. Paste a WeakAuras export (`!WA:2!…`) → timestamped `.txt` in `ingest/inbox/`. No clipboard, stdlib only. |
| `Weak Auras/plane/decode.py` | Decode an inbox export → legible **settled** view. `peek` (true levers, residue stripped) · `diff` (per-option delta of the two newest) · `raw`. |
| `Weak Auras/plane/verify.py` | Assemble-stage **regression harness**. `bless <bomstem>` saves a golden; default run verifies every golden reproduces and classifies each diff (inert → auto-pass, else → FLAG). Read-only. Goldens: `Weak Auras/plane/goldens/` (tracked). |
| `Weak Auras/wa_index/extract_seed_defaults.py` (`seeds probe`) | Probe WA source for function-driven trigger defaults, read-only (prints). `freeze` (writes `trigger_seed_defaults.json`) is local-only, refused via the runner. |
| `runner.py` (+ `runner.bat`) | **SERVER.** You launch it (own window, your process). Polls `runtime/queue/`, executes only whitelisted services, prints each call live, writes `runtime/receipts/`. Whitelist: `decode`, `verify`, `seeds`. |
| `call.py` | **CLIENT.** `py call.py <service> [args]` writes a queue file, holds open for the receipt, prints it. Executes nothing itself. |
| `menu.bat` / `Launcher.lnk` | Pinnable keys-only launcher (`choice`-gated): `[1]` paste-drop `[2]` git status `[3]` decode `[4]` diff `[5]` start runner; `[A]` advanced → git push (confirm). |

## Use

1. Launch the runner — menu `[5]`, or double-click `runner.bat`. Leave its window open.
2. Call a service: `py call.py verify` · `py call.py decode peek <export.txt>`. Each holds open and returns a receipt.
3. The runner window shows each call live; every call leaves a durable receipt in `runtime/receipts/`.

## Safety model

- **Whitelist** — the runner runs ONLY the services in its `SERVICES` map (read-only: `decode`, `verify`,
  `seeds`). An unknown service is **REFUSED** (a receipt records it; nothing executes). `verify bless` and
  `seeds freeze` (both write) are refused
  through the runner — moving a golden is a deliberate *local* action.
- **Decoupled** — the runner is *your* process; it survives the caller dying. In-flight calls finish,
  receipts land. Kill the caller, the machine still runs (the "kill-test").
- **Process-once** — every queue file is handled exactly once, then moved out of the queue (`processed/`
  or `errored/`). A stuck/looping file is impossible.
- **`call.py` runs nothing** — it only queues and awaits.
- `runtime/` and `Launcher.lnk` are gitignored (transient IPC / machine-specific).

## Add a service

Add one line to `runner.py`'s `SERVICES` map pointing at a **read-only, structured-output** tool, then
restart the runner (it loads the whitelist at startup). Keep write/destructive actions out of the whitelist.
