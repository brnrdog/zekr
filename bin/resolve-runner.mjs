import { existsSync } from "node:fs";

// Compiled-output suffixes ReScript can emit, most specific first. A consumer's
// rescript.json `suffix` decides which one the whole build graph — including
// zekr's own sources — is emitted with. The harness must load the Runner
// compiled with the SAME suffix as the test file it runs; otherwise it imports
// a different Registry module instance than the one the suites registered into
// and reports zero tests (a false green).
export const compiledExtensions = [
  ".res.mjs",
  ".res.js",
  ".bs.js",
  ".mjs",
  ".cjs",
  ".js",
];

// Pick the Runner module whose suffix matches the compiled test file, so both
// resolve to a single shared Registry instance. Falls back to Runner.js when no
// suffix-matched Runner sits next to the harness (e.g. a standalone .mjs test
// that imports the shipped .js sources directly).
export function resolveRunnerUrl(testFile, baseUrl, exists = existsSync) {
  const ext = compiledExtensions.find((e) => testFile.endsWith(e)) ?? ".js";
  const candidate = new URL(`../src/Runner${ext}`, baseUrl);
  return exists(candidate)
    ? candidate.href
    : new URL("../src/Runner.js", baseUrl).href;
}
