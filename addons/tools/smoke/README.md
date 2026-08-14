# The offline smokes — and what they cannot see

_Run each with `.tools/lua51/lua5.1.exe addons/tools/smoke/<file>.lua`. Green means the LOGIC held
against our model of the client. This page is about the gap between that model and the client._

## ★★ We have the real Lua. We do not have the real client.

`.tools/lua51` is **Lua 5.1.5**, and WoW 3.3.5 runs **Lua 5.1**. So anything that is a question about
*the language* is answered exactly here — §77.1's dropped backslash was settled against this
interpreter after being wrong from memory, and that is the standing rule: **check string and number
behaviour against the binary, never from recall.**

⚠ **But there is no WoW API in it.** Every frame, every script handler, every `SetText` is a **stub —
our model.** An offline smoke is only ever as good as that model, and the failures it cannot see are
exactly where the two disagree.

## The divergences we model on purpose

`harness.lua` encodes them, and each is there because a real bug lived in it or would have:

| behaviour | why it is modelled |
|---|---|
| `SetText` fires `OnTextChanged` | the real EditBox does, **including when the value did not change**. §81 shipped a `refresh → SetText → refresh` loop that would have **frozen the client**; the smoke never went through a handler, so nothing could catch it |
| `Show` / `Hide` fire `OnShow` / `OnHide`, on transitions only | a pane that refreshes from `OnShow` is ordinary, and a `Show()` inside that refresh is the same loop shape |
| `SetTexture` resets `TexCoord` | §19. A stub that kept the crop would pass code that re-crops only at Init — testing the stub, not the addon |
| **the depth guard** | the necessary partner to firing anything. A re-entrant handler would otherwise **hang** the suite, and a hung test reports nothing and reads as an environment fault |

⚠ **`SetChecked` deliberately does NOT fire `OnClick`,** because the client's does not. Modelling a
call that never happens sends someone hunting a phantom, which is worse than modelling nothing.

★ **Only divergences we can name a reason for go in.** Guessing at the client replaces one fiction
with a more confident one.

## ⚠ What green does NOT cover

Read this list before concluding a change is safe:

- **Real hit-testing and frame layering.** Frame levels are asserted arithmetically; no click is ever
  actually routed. A control buried under another passes here.
- **Whether a texture path resolves.** `check_escapes.py` catches the *dropped-backslash* class
  (§77.1), but a correctly-formed path to a file that does not exist is silent everywhere — the
  frame just renders nothing.
- **Taint and protected calls.** Not exercised at all.
- **Timing under a real frame rate.** OnUpdate cost is *measured in-client* (`Driver.Cost`), never
  here. The census counts handlers; it cannot tell you what one costs.
- **SavedVariables serialisation** — depth limits, cycles, size.
- **The client's own event ordering**, and anything that depends on load order between addons.
- **Anything a template brings with it.** `UIPanelButtonTemplate`, `InputBoxTemplate` and the
  dropdown templates are names to the stub and behaviour in the client.

★ **The rule this list exists to enforce:** a mechanism can be perfectly tested and still be wired to
nothing. §77's two ticks enabled a capability with no handler behind it and every layer of
verification passed; §77.2's toggle changed a label and never moved the map. **Assert the outcome the
user would see, not that the control acknowledged the click.**
