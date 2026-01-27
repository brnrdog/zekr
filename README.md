# zekr

[![npm version](https://badgen.net/npm/v/zekr)](https://www.npmjs.com/package/zekr)
[![license](https://badgen.net/npm/license/zekr)](https://github.com/brnrdog/zekr/blob/main/LICENSE)

A simple test framework for ReScript.

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

### Running Tests

```rescript
// Run a single suite
runSuite(mySuite)

// Run multiple suites
runSuites([suite1, suite2, suite3])
```

## License

MIT
