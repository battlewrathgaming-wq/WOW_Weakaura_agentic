// mint_check.mjs - Phase 4 harness helper: run the SHELL'S OWN mint (shell/mint.js) under node
// with a FIXED uid sequence, encode with the ported codec, print the import string.
// stdin: {templates, lane, classToken, specName, scope, picks, fragment, groupName, uids:[...]}
import { mintPack } from "../shell/mint.js";
import { encodeImportStringFromValue } from "./wa_encode.mjs";
import { deflateRawSync } from "node:zlib";

const deflate = async (b) => new Uint8Array(deflateRawSync(Buffer.from(b), { level: 9 }));

let input = "";
for await (const chunk of process.stdin) input += chunk;
const req = JSON.parse(input);
const uids = req.uids.slice();
const env = mintPack({ ...req, templates: req.templates, uidFn: () => uids.shift() });
process.stdout.write(await encodeImportStringFromValue(env, deflate));
