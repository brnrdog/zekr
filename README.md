# zekr

[![npm version](https://badgen.net/npm/v/zekr)](https://www.npmjs.com/package/zekr)
[![license](https://badgen.net/npm/license/zekr)](https://github.com/brnrdog/zekr/blob/main/LICENSE)

A test framework for ReScript applications.

## Installation

```bash
npm install zekr
```

Add to your `rescript.json`:

```json
{
  "dev-dependencies": ["zekr"]
}
```

## Usage

```rescript
open Zekr

let myTests = Suite.make("My Tests", [
  Test.make("addition works", () => {
    Assert.equal(1 + 1, 2)
  }),
  Test.make("strings match", () => {
    Assert.equal("hello", "hello")
  }),
  Test.make("condition is true", () => {
    Assert.isTrue(10 > 5)
  }),
])

Runner.runSuites([myTests])
```

## API

Zekr is organized as a set of submodules under the top-level `Zekr` namespace:

| Module           | Purpose                                         |
| ---------------- | ----------------------------------------------- |
| `Zekr.Test`      | Test case factories (`make`, `skip`, `only`, …) |
| `Zekr.Suite`     | Suite factories (`make`, `async`)               |
| `Zekr.Assert`    | Assertions (`equal`, `isTrue`, `some`, …)       |
| `Zekr.Runner`    | Running suites and filtering                    |
| `Zekr.Snapshot`  | Snapshot testing                                |
| `Zekr.DomTesting`| DOM rendering, queries, events, assertions      |

You can `open Zekr` to bring the submodules into scope and write `Test.make(...)`, `Assert.equal(...)`, etc.

### Creating Tests

```rescript
// Create a single test
let myTest = Test.make("test name", () => {
  // return Pass or Fail(message)
  Pass
})

// Skip or focus a test
let skipped = Test.skip("wip", () => Pass)
let focused = Test.only("focus me", () => Pass)

// Create a test suite
let mySuite = Suite.make("Suite Name", [test1, test2, test3])
```

### Setup/Teardown Hooks

Add lifecycle hooks directly to your test suites:

```rescript
// Synchronous hooks
let mySuite = Suite.make(
  "Database Tests",
  [test1, test2, test3],
  ~beforeAll=() => initializeDatabase(),
  ~afterAll=() => closeDatabase(),
  ~beforeEach=() => clearTables(),
  ~afterEach=() => resetState(),
)

// Async hooks
let myAsyncSuite = Suite.async(
  "API Tests",
  [asyncTest1, asyncTest2],
  ~beforeAll=async () => await connectToServer(),
  ~afterAll=async () => await disconnectFromServer(),
  ~beforeEach=async () => await resetMocks(),
  ~afterEach=async () => await cleanup(),
)
```

All hooks are optional — only provide the ones you need:

```rescript
let mySuite = Suite.make(
  "My Tests",
  [test1, test2],
  ~beforeEach=() => resetState(),
)
```

### Async Tests with Timeout

Async tests support an optional timeout parameter (in milliseconds). Tests that exceed the timeout will fail automatically. Uncaught exceptions in async tests are also caught and reported as failures.

```rescript
let myAsyncTests = Suite.async("API Tests", [
  // Test with 5 second timeout
  Test.async("fetches data", async () => {
    let data = await fetchData()
    Assert.equal(data.status, "ok")
  }, ~timeout=5000),

  // Test without timeout (runs until completion)
  Test.async("processes data", async () => {
    let result = await processData()
    Assert.isTrue(result.success)
  }),
])
```

### Assertions

```rescript
// Check equality
Assert.equal(actual, expected)
Assert.equal(actual, expected, ~message="custom message")

// Check inequality
Assert.notEqual(actual, expected)

// Check boolean conditions
Assert.isTrue(condition)
Assert.isFalse(condition)

// Ordering
Assert.greaterThan(actual, expected)
Assert.lessThan(actual, expected)
Assert.greaterThanOrEqual(actual, expected)
Assert.lessThanOrEqual(actual, expected)

// Collections and strings
Assert.contains(haystack, needle)
Assert.arrayContains(arr, item)
Assert.matches(str, regex)

// Option and result
Assert.some(maybeValue)
Assert.none(maybeValue)
Assert.ok(result)
Assert.error(result)

// Exceptions
Assert.throws(() => someFn())

// Combine multiple results
Assert.combineResults([result1, result2, result3])
```

### Snapshot Testing

Test complex data structures by comparing against stored snapshots:

```rescript
let snapshotTests = Suite.make("API Response", [
  Test.make("user data matches snapshot", () => {
    let user = {"id": 1, "name": "Alice", "roles": ["admin", "user"]}
    Snapshot.matches(user, ~name="user-data")
  }),
])
```

On first run, snapshots are created in `__snapshots__/`. Subsequent runs compare against stored snapshots.

```rescript
// Configure custom snapshot directory
Snapshot.setDir("tests/__snapshots__")

// Update a snapshot programmatically
Snapshot.update(newValue, ~name="snapshot-name")
```

### Test Filtering

Filter tests using environment variables:

```bash
# Run only tests matching "user"
ZEKR_FILTER="user" node tests/MyTests.js

# Skip tests matching "slow"
ZEKR_SKIP="slow" node tests/MyTests.js

# Combine filter and skip
ZEKR_FILTER="api" ZEKR_SKIP="integration" node tests/MyTests.js
```

Filtering is case-insensitive and matches against both suite and test names.

### Watch Mode

Automatically re-run tests when files change:

```rescript
// In a separate watch script (e.g., watch.res)
open Zekr

Runner.watchMode(
  ~testCommand="node tests/MyTests.js",
  ~watchPaths=["src", "tests"],
  ~buildCommand="npx rescript",
)
```

Run with: `node watch.js`

The watch mode will:
- Run an initial test pass
- Watch specified paths for file changes
- Re-build (if `buildCommand` provided) and re-run tests on changes
- Debounce rapid file changes

### DOM Testing

Test DOM rendering, user interactions, and element assertions using a built-in jsdom environment. Inspired by [Testing Library](https://testing-library.com/).

#### Rendering

```rescript
open Zekr

let myTests = Suite.make("Login Form", [
  Test.make("renders and accepts input", () => {
    // Render HTML into a jsdom container
    let {container} = DomTesting.render(`
      <form>
        <label for="email">Email</label>
        <input id="email" type="email" value="" />
        <button type="submit">Sign In</button>
      </form>
    `)

    let input = container->DomTesting.Query.getByLabelText("Email")
    DomTesting.Event.typeText(input, "user@example.com")

    let result = DomTesting.Assert.toHaveValue(input, "user@example.com")

    // Clean up the rendered DOM after each test
    DomTesting.cleanup()
    result
  }),
])
```

#### Queries

Find elements in the rendered DOM. Each query type comes in three variants:

- `getBy*` — returns the element, throws if not found or if multiple match
- `queryBy*` — returns `option<Dom.element>`, `None` if not found
- `getAllBy*` — returns `array<Dom.element>`, throws if none found

```rescript
// By text content
container->DomTesting.Query.getByText("Hello World")
container->DomTesting.Query.getByText("hello", ~exact=false)

// By ARIA role (implicit roles from HTML tags are supported)
container->DomTesting.Query.getByRole("button")
container->DomTesting.Query.getByRole("heading", ~level=2)
container->DomTesting.Query.getByRole("button", ~name="Submit")
container->DomTesting.Query.getByRole("checkbox", ~checked=true)

// By test id
container->DomTesting.Query.getByTestId("submit-btn")

// By form attributes
container->DomTesting.Query.getByPlaceholder("Enter your email")
container->DomTesting.Query.getByLabelText("Username")
container->DomTesting.Query.getByDisplayValue("current text")

// By other attributes
container->DomTesting.Query.getByAltText("Company logo")
container->DomTesting.Query.getByTitle("Close")
```

#### User Events

Simulate user interactions. Events fire realistic event sequences (pointer, mouse, keyboard, input events).

```rescript
// Mouse
DomTesting.Event.click(element)
DomTesting.Event.dblClick(element)
DomTesting.Event.hover(element)
DomTesting.Event.unhover(element)

// Keyboard / Text
DomTesting.Event.typeText(input, "Hello World")
DomTesting.Event.clear(input)

// Form controls
DomTesting.Event.check(checkbox)
DomTesting.Event.uncheck(checkbox)
DomTesting.Event.selectOptions(select, ["option-value"])

// Focus
DomTesting.Event.focus(element)
DomTesting.Event.blur(element)

// Low-level custom event dispatch
DomTesting.Event.fire(element, someEvent)
```

#### DOM Assertions

All assertions return `testResult` (`Pass` or `Fail(message)`), integrating with zekr's existing assertion system.

```rescript
// Presence
DomTesting.Assert.toBeInTheDocument(element)
DomTesting.Assert.toNotBeInTheDocument(optionElement)

// Text content
DomTesting.Assert.toHaveTextContent(element, "Hello")
DomTesting.Assert.toHaveTextContent(element, "hello", ~exact=false)

// Attributes and classes
DomTesting.Assert.toHaveAttribute(element, "href")
DomTesting.Assert.toHaveAttribute(element, "href", ~value="/home")
DomTesting.Assert.toNotHaveAttribute(element, "disabled")
DomTesting.Assert.toHaveClass(element, "active primary")
DomTesting.Assert.toNotHaveClass(element, "hidden")

// Visibility and state
DomTesting.Assert.toBeVisible(element)
DomTesting.Assert.toNotBeVisible(element)
DomTesting.Assert.toBeDisabled(element)
DomTesting.Assert.toBeEnabled(element)

// Form values
DomTesting.Assert.toHaveValue(input, "hello")
DomTesting.Assert.toBeChecked(checkbox)
DomTesting.Assert.toNotBeChecked(checkbox)

// Containment
DomTesting.Assert.toContainElement(parent, child)
DomTesting.Assert.toNotContainElement(parent, child)
DomTesting.Assert.toContainHTML(element, "<strong>Bold</strong>")
DomTesting.Assert.toBeEmptyDOMElement(element)

// Style and focus
DomTesting.Assert.toHaveStyle(element, "color", "red")
DomTesting.Assert.toHaveFocus(element)
DomTesting.Assert.toNotHaveFocus(element)
```

#### Combining Results

Use `Assert.combineResults` to check multiple assertions in a single test:

```rescript
Test.make("form state is correct", () => {
  let {container} = DomTesting.render(`...`)
  let input = container->DomTesting.Query.getByRole("textbox")
  let button = container->DomTesting.Query.getByRole("button")

  let result = Assert.combineResults([
    DomTesting.Assert.toHaveValue(input, ""),
    DomTesting.Assert.toBeEnabled(button),
    DomTesting.Assert.toBeVisible(button),
  ])

  DomTesting.cleanup()
  result
})
```

## Running tests with the CLI

Zekr ships a `zekr` binary that discovers and runs your test files. Build with
ReScript first, then run `zekr`:

```jsonc
// package.json
"scripts": {
  "test": "rescript && zekr"
}
```

By default it scans the current directory for files ending in `.test.res`
(e.g. `Color.test.res`) and runs each compiled file in its own Node process.

### Options

| Flag | Alias | Default | Description |
| ---- | ----- | ------- | ----------- |
| `--pattern <suffix>` | `-p` | `.test.res` | Filename suffix to match |
| `--dir <path>` | `-d` | `.` | Directory to scan |
| `--watch` | `-w` | | Watch for changes and re-run only impacted tests |
| `--help` | `-h` | | Show usage |

### Watch mode (`--watch`)

`zekr --watch` runs a full pass, then watches the scan directory and re-runs
**only the tests impacted by each change**:

- Change a **test file** (`Foo.test.res`) → only that test file re-runs.
- Change a **source module** (`Foo.res`) → every test that references `Foo`
  (`Foo.something` or `open Foo`) re-runs.

Run your compiler in watch mode alongside it so tests always run against
freshly built output:

```jsonc
// package.json
"scripts": {
  "test:watch": "rescript -w"  // in one terminal
  // and `zekr --watch` in another
}
```

zekr reacts to compiled output (`.js`, `.res.mjs`, …), not raw `.res` saves,
so it never runs stale code. Rapid change bursts are debounced into a single
run. Press `Ctrl+C` to stop.

When any test fails, watch mode prints a **Failing tests** summary at the end
of the run — grouping the failing test names under each file — so you don't
have to scroll back through the output to find what broke:

```
zekr: 1 files, 0 passed, 1 failed

Failing tests:
  tests/Math.test.res
    ✗ addition is broken
    ✗ handles negatives
```

### Config file

Instead of flags, add a `zekr.json` at your project root:

```json
{ "pattern": ".test.res", "dir": "." }
```

Flags override `zekr.json`, which overrides the defaults. `node_modules`,
`lib`, `.git`, and dot-directories are skipped. If a matched source has no
compiled output, `zekr` reports it and exits non-zero — run `rescript` first.

### Custom ReScript `suffix`

Zekr works whatever `suffix` your `rescript.json` sets (`.res.mjs`, `.mjs`,
`.bs.js`, `.js`, …). ReScript compiles the whole build graph — including
zekr's own sources — with that suffix, so the CLI discovers the matching
compiled test files and runs each one against the Runner compiled with the
same suffix. This keeps the internal suite registry a single shared instance;
without it, tests compiled to `Foo.test.res.mjs` would register into a
different module instance than the runner read, and the CLI would report zero
tests (a false green).

### Running Tests

```rescript
// Run a single suite
Runner.runSuite(mySuite)

// Run multiple suites
Runner.runSuites([suite1, suite2, suite3])

// Async variants
await Runner.runAsyncSuite(myAsyncSuite)
await Runner.runAsyncSuites([suite1, suite2])
```

### Test Coverage

Generate test coverage reports on your ReScript source files using [c8](https://github.com/bcoe/c8) (V8 native coverage). Since ReScript doesn't support sourcemaps natively, Zekr includes a sourcemap generator that maps compiled JavaScript back to `.res` files.

#### Setup

Install the required dev dependencies:

```bash
npm install --save-dev c8 source-map
```

Add coverage scripts to your `package.json`:

```json
{
  "scripts": {
    "precoverage": "rescript && node node_modules/zekr/scripts/generate-sourcemaps.mjs src",
    "coverage": "c8 node tests/MyTests.js"
  },
  "c8": {
    "include": ["src/**/*.js"],
    "reporter": ["text", "html"],
    "report-dir": "coverage",
    "all": true
  }
}
```

Run coverage:

```bash
npm run coverage
```

The text report shows coverage on `.res` files with line numbers pointing to your ReScript source, and the HTML report (in `coverage/`) renders the original ReScript code with highlighted coverage.

See the [Coverage documentation](https://brnrdog.github.io/zekr/api/coverage) for more details.

## License

MIT
