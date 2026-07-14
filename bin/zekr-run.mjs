#!/usr/bin/env node
import { pathToFileURL } from "node:url";
import { resolve } from "node:path";
import { run } from "../src/Runner.js";

const file = process.argv[2];
if (!file) {
  console.error("Usage: zekr-run <file>");
  process.exit(1);
}
await import(pathToFileURL(resolve(process.cwd(), file)).href);
await run();
