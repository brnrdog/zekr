#!/usr/bin/env node
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";
import { resolveRunnerUrl } from "./resolve-runner.mjs";

const file = process.argv[2];
if (!file) {
  console.error("Usage: zekr-run <file>");
  process.exit(1);
}

// Load the Runner compiled with the same suffix as the test file so both share
// one Registry instance; then import the test file (registering its suites) and
// run them.
const { run } = await import(resolveRunnerUrl(file, import.meta.url));
await import(pathToFileURL(resolve(process.cwd(), file)).href);
await run();
