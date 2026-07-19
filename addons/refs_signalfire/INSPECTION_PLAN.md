# Inspection plan - top domains, self-reporting downward (agreed 2026-07-19)

Describe-don't-anchor applies throughout. Findings land as DATA in inspection/ (tables, not prose).

0. **The toc = the declared spine**: load order, SavedVariables names - the addon's own statement
   of its parts. Everything below hangs off this.
1. **Per-file self-report** (mechanical, one pass): globals it declares - events it registers -
   slash commands - frames it creates - SavedVariables keys it touches. One row-table per file.
2. **The five self-reporting domains**, each its own emitted table:
   persistence (SV shapes written) - transport (SendChatMessage/SendAddonMessage sites, prefixes,
   channel names) - events (the listen surface) - UI (frame construction) - time (timers, OnUpdate,
   polling cadence).
3. **★ THE HACKS LEDGER (special interest)**: their workarounds ARE the era-constraint evidence.
   Already visible from the API pass: the naming convention is a FOSSIL RECORD - version-suffixed
   generations kept alongside each other (SF573_/SF578_/BLFG_5625_...; SF139_OldSlashBLFG,
   SFALP_OldValidateCreateListing = old surfaces shimmed, not deleted). Catalogue each hack:
   what constraint forced it, what it works around, whether OUR fork removes the constraint.
4. Only AFTER 0-3 stand: the join layer (proposal fit, fork opportunities) as a separate doc.
