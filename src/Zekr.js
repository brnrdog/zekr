// Zekr - JS entrypoint barrel file
// Re-exports all public modules so consumers can `import { Test, Suite, Assert, ... } from "zekr"`.

export * as Test from "./Test.js";
export * as Suite from "./Suite.js";
export * as Assert from "./Assert.js";
export * as Runner from "./Runner.js";
export * as Snapshot from "./Snapshot.js";
export * as Types from "./Types.js";
export * as DomTesting from "./DomTesting.js";
export * as DomBindings from "./DomBindings.js";
export * as DomQuery from "./DomQuery.js";
export * as DomEvent from "./DomEvent.js";
export * as DomAssert from "./DomAssert.js";
export * as Colors from "./Colors.js";
// Note: Cli (Zekr.Cli) is intentionally NOT re-exported here — it is the
// `zekr` binary's entry point, not a library API. See bin/zekr.mjs.
