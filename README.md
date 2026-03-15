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

let myTests = suite("My Tests", [
  test("addition works", () => {
    assertEqual(1 + 1, 2)
  }),
  test("strings match", () => {
    assertEqual("hello", "hello")
  }),
  test("condition is true", () => {
    assertTrue(10 > 5)
  }),
])

runSuites([myTests])
```

## API

### Creating Tests

```rescript
// Create a single test
let myTest = test("test name", () => {
  // return Pass or Fail(message)
  Pass
})

// Create a test suite
let mySuite = suite("Suite Name", [test1, test2, test3])
```

### Setup/Teardown Hooks

Add lifecycle hooks directly to your test suites:

```rescript
// Synchronous hooks
let mySuite = suite(
  "Database Tests",
  [test1, test2, test3],
  ~beforeAll=() => initializeDatabase(),
  ~afterAll=() => closeDatabase(),
  ~beforeEach=() => clearTables(),
  ~afterEach=() => resetState(),
)

// Async hooks
let myAsyncSuite = asyncSuite(
  "API Tests",
  [asyncTest1, asyncTest2],
  ~beforeAll=async () => await connectToServer(),
  ~afterAll=async () => await disconnectFromServer(),
  ~beforeEach=async () => await resetMocks(),
  ~afterEach=async () => await cleanup(),
)
```

All hooks are optional - you only need to provide the ones you need:

```rescript
// Only beforeEach hook
let mySuite = suite(
  "My Tests",
  [test1, test2],
  ~beforeEach=() => resetState(),
)
```

### Async Tests with Timeout

Async tests support an optional timeout parameter (in milliseconds). Tests that exceed the timeout will fail automatically. Uncaught exceptions in async tests are also caught and reported as failures.

```rescript
let myAsyncTests = asyncSuite("API Tests", [
  // Test with 5 second timeout
  asyncTest("fetches data", async () => {
    let data = await fetchData()
    assertEqual(data.status, "ok")
  }, ~timeout=5000),

  // Test without timeout (runs until completion)
  asyncTest("processes data", async () => {
    let result = await processData()
    assertTrue(result.success)
  }),
])
```

### Assertions

```rescript
// Check equality
assertEqual(actual, expected)
assertEqual(actual, expected, ~message="custom message")

// Check inequality
assertNotEqual(actual, expected)

// Check boolean conditions
assertTrue(condition)
assertFalse(condition)

// Combine multiple results
combineResults([result1, result2, result3])
```

### Snapshot Testing

Test complex data structures by comparing against stored snapshots:

```rescript
let snapshotTests = suite("API Response", [
  test("user data matches snapshot", () => {
    let user = {"id": 1, "name": "Alice", "roles": ["admin", "user"]}
    assertMatchesSnapshot(user, ~name="user-data")
  }),
])
```

On first run, snapshots are created in `__snapshots__/` directory. Subsequent runs compare against stored snapshots.

```rescript
// Configure custom snapshot directory
setSnapshotDir("tests/__snapshots__")

// Update a snapshot programmatically
updateSnapshot(newValue, ~name="snapshot-name")
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

watchMode(
  ~testCommand="node tests/MyTests.js",
  ~watchPaths=["src", "tests"],
  ~buildCommand="npx rescript",
)
```

Run with: `node watch.js`

The watch mode will:
- Run an initial test pass
- Watch specified paths for file changes
- Re-build (if buildCommand provided) and re-run tests on changes
- Debounce rapid file changes

### DOM Testing

Test DOM rendering, user interactions, and element assertions using a built-in jsdom environment. Inspired by [Testing Library](https://testing-library.com/).

#### Rendering

```rescript
open Zekr

let myTests = suite("Login Form", [
  test("renders and accepts input", () => {
    // Render HTML into a jsdom container
    let {container} = Dom.render(`
      <form>
        <label for="email">Email</label>
        <input id="email" type="email" value="" />
        <button type="submit">Sign In</button>
      </form>
    `)

    let input = container->Dom.Query.getByLabelText("Email")
    Dom.Event.typeText(input, "user@example.com")

    let result = Dom.Assert.toHaveValue(input, "user@example.com")

    // Clean up the rendered DOM after each test
    Dom.cleanup()
    result
  }),
])
```

#### Queries

Find elements in the rendered DOM. Each query type comes in three variants:

- `getBy*` - returns the element, throws if not found or if multiple match
- `queryBy*` - returns `option<Dom.element>`, `None` if not found
- `getAllBy*` - returns `array<Dom.element>`, throws if none found

```rescript
// By text content
container->Dom.Query.getByText("Hello World")
container->Dom.Query.getByText("hello", ~exact=false)

// By ARIA role (implicit roles from HTML tags are supported)
container->Dom.Query.getByRole("button")
container->Dom.Query.getByRole("heading", ~level=2)
container->Dom.Query.getByRole("button", ~name="Submit")
container->Dom.Query.getByRole("checkbox", ~checked=true)

// By test id
container->Dom.Query.getByTestId("submit-btn")

// By form attributes
container->Dom.Query.getByPlaceholder("Enter your email")
container->Dom.Query.getByLabelText("Username")
container->Dom.Query.getByDisplayValue("current text")

// By other attributes
container->Dom.Query.getByAltText("Company logo")
container->Dom.Query.getByTitle("Close")
```

#### User Events

Simulate user interactions. Events fire realistic event sequences (pointer, mouse, keyboard, input events).

```rescript
// Mouse
Dom.Event.click(element)
Dom.Event.dblClick(element)
Dom.Event.hover(element)
Dom.Event.unhover(element)

// Keyboard / Text
Dom.Event.typeText(input, "Hello World")
Dom.Event.clear(input)

// Form controls
Dom.Event.check(checkbox)
Dom.Event.uncheck(checkbox)
Dom.Event.selectOptions(select, ["option-value"])

// Focus
Dom.Event.focus(element)
Dom.Event.blur(element)

// Low-level custom event dispatch
Dom.Event.fireEvent(element, someEvent)
```

#### DOM Assertions

All assertions return `testResult` (`Pass` or `Fail(message)`), integrating with zekr's existing assertion system.

```rescript
// Presence
Dom.Assert.toBeInTheDocument(element)
Dom.Assert.toNotBeInTheDocument(optionElement)

// Text content
Dom.Assert.toHaveTextContent(element, "Hello")
Dom.Assert.toHaveTextContent(element, "hello", ~exact=false)

// Attributes and classes
Dom.Assert.toHaveAttribute(element, "href")
Dom.Assert.toHaveAttribute(element, "href", ~value="/home")
Dom.Assert.toNotHaveAttribute(element, "disabled")
Dom.Assert.toHaveClass(element, "active primary")
Dom.Assert.toNotHaveClass(element, "hidden")

// Visibility and state
Dom.Assert.toBeVisible(element)
Dom.Assert.toNotBeVisible(element)
Dom.Assert.toBeDisabled(element)
Dom.Assert.toBeEnabled(element)

// Form values
Dom.Assert.toHaveValue(input, "hello")
Dom.Assert.toBeChecked(checkbox)
Dom.Assert.toNotBeChecked(checkbox)

// Containment
Dom.Assert.toContainElement(parent, child)
Dom.Assert.toNotContainElement(parent, child)
Dom.Assert.toContainHTML(element, "<strong>Bold</strong>")
Dom.Assert.toBeEmptyDOMElement(element)

// Style and focus
Dom.Assert.toHaveStyle(element, "color", "red")
Dom.Assert.toHaveFocus(element)
Dom.Assert.toNotHaveFocus(element)
```

#### Combining Results

Use `combineResults` to check multiple assertions in a single test:

```rescript
test("form state is correct", () => {
  let {container} = Dom.render(`...`)
  let input = container->Dom.Query.getByRole("textbox")
  let button = container->Dom.Query.getByRole("button")

  let result = combineResults([
    Dom.Assert.toHaveValue(input, ""),
    Dom.Assert.toBeEnabled(button),
    Dom.Assert.toBeVisible(button),
  ])

  Dom.cleanup()
  result
})
```

### Running Tests

```rescript
// Run a single suite
runSuite(mySuite)

// Run multiple suites
runSuites([suite1, suite2, suite3])
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
