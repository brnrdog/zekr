# Agent guide

This file gives AI coding assistants (and humans new to the repo) the minimum context needed to make changes safely.

## What Zekr is

Zekr is a test framework for ReScript. It provides test/suite factories, assertions, a runner, snapshot testing, and a jsdom-backed DOM testing module.

## Repository layout

```
src/            # Library source (ReScript)
  Test.res            # Test case factories   (Zekr.Test)
  Suite.res           # Suite factories       (Zekr.Suite)
  Assert.res          # Assertions            (Zekr.Assert)
  Runner.res          # Runner, filtering, watch mode (Zekr.Runner)
  Snapshot.res        # Snapshot testing      (Zekr.Snapshot)
  Types.res           # Shared types          (Zekr.Types)
  Colors.res          # Terminal colors       (Zekr.Colors)
  DomTesting.res      # DOM render/cleanup + re-exports Query/Event/Assert
  DomBindings.res     # Low-level jsdom bindings
  DomQuery.res        # Query helpers
  DomEvent.res        # User-event simulation
  DomAssert.res       # DOM assertions
  Zekr.js             # Manual JS barrel (see below)
tests/          # Tests for the library itself
docs-website/   # Vite + ReScript documentation site
scripts/        # Build / sourcemap helpers
```

## Module namespacing

`rescript.json` sets `"namespace": true`. The package name is `zekr`, so ReScript
wraps every top-level module in a synthesized `Zekr` module. Consumers see:

- `Zekr.Test.make`, `Zekr.Test.skip`, `Zekr.Test.only`, `Zekr.Test.async`, …
- `Zekr.Suite.make`, `Zekr.Suite.async`
- `Zekr.Assert.equal`, `Zekr.Assert.isTrue`, `Zekr.Assert.some`, …
- `Zekr.Runner.runSuite`, `Zekr.Runner.runSuites`, `Zekr.Runner.runAsyncSuite`, `Zekr.Runner.runAsyncSuites`, `Zekr.Runner.watchMode`
- `Zekr.Snapshot.setDir`, `Zekr.Snapshot.matches`, `Zekr.Snapshot.update`
- `Zekr.DomTesting.render`, `Zekr.DomTesting.cleanup`, plus `DomTesting.Query`, `DomTesting.Event`, `DomTesting.Assert`

There is **no** `Zekr.res` facade file. Do not reintroduce one — it conflicts
with the auto-generated namespace module. Add new public features by creating
new top-level `.res` files in `src/`.

### Why `DomTesting` and not `Dom`?

`Dom.res` would shadow ReScript stdlib's `Dom` module inside the package, which
`DomAssert`/`DomBindings`/`DomQuery`/`DomEvent` rely on for `Dom.element` and
`Dom.event`. The module is named `DomTesting` to avoid that collision.

### Reserved-word aliases in `Assert`

`true`, `false`, and `match` are reserved in ReScript, so the assertion
functions for those cases are named `isTrue`, `isFalse`, and `matches`.

## The `src/Zekr.js` barrel

`namespace: true` does not emit a runtime JS file for the namespace module, but
`package.json` has `"main": "./src/Zekr.js"`. A small hand-written barrel
re-exports every submodule so plain JS/TS consumers can do
`import { Test, Assert } from "zekr"`. It is checked into git via a
`!src/Zekr.js` exception in `.gitignore`. If you add or remove a top-level
module, update the barrel.

ReScript consumers do not need the barrel — they reach the submodules through
the synthesized `Zekr` namespace module at the type level.

## Development workflow

```bash
npm install
npx rescript build    # or: npx rescript -w
npm test              # builds and runs all three test files in tests/
```

Tests live in `tests/` as dev-only sources. They use the library API directly
(no facade), e.g. `open Types` for shared types plus `Test.make`, `Suite.make`,
`Assert.equal`, `Runner.runSuites`, etc.

## When making changes

- Keep the public module names stable. Renaming a top-level module is a
  breaking change for consumers.
- When adding a new top-level module, add it to `src/Zekr.js` and — if it's
  user-facing — to the README and to `docs-website/src/pages/`.
- Don't add `Zekr__` prefixes; they were removed by the namespace refactor.
- Don't reintroduce a `Zekr.res` facade.
- Tests must pass: `npm test` should report all tests green before you commit.
