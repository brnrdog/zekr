// Zekr - A simple test framework for ReScript
// This module serves as the public API facade

// Re-export all types and their constructors
include Types

// Test factory functions
let test = (name: string, run: unit => testResult): testCase => {
  {name, run, mode: Normal}
}

let testSkip = (name: string, run: unit => testResult): testCase => {
  {name, run, mode: Skip}
}

let testOnly = (name: string, run: unit => testResult): testCase => {
  {name, run, mode: Only}
}

let asyncTest = (
  name: string,
  run: unit => promise<testResult>,
  ~timeout: option<int>=?,
): asyncTestCase => {
  {name, run, mode: Normal, timeout}
}

let asyncTestSkip = (
  name: string,
  run: unit => promise<testResult>,
  ~timeout: option<int>=?,
): asyncTestCase => {
  {name, run, mode: Skip, timeout}
}

let asyncTestOnly = (
  name: string,
  run: unit => promise<testResult>,
  ~timeout: option<int>=?,
): asyncTestCase => {
  {name, run, mode: Only, timeout}
}

// Suite factory functions
let suite = (
  name: string,
  tests: array<testCase>,
  ~beforeAll: option<unit => unit>=?,
  ~afterAll: option<unit => unit>=?,
  ~beforeEach: option<unit => unit>=?,
  ~afterEach: option<unit => unit>=?,
): testSuite => {
  let hasHooks =
    beforeAll->Option.isSome ||
    afterAll->Option.isSome ||
    beforeEach->Option.isSome ||
    afterEach->Option.isSome
  {
    name,
    tests,
    hooks: if hasHooks {
      Some({beforeAll, afterAll, beforeEach, afterEach})
    } else {
      None
    },
  }
}

let asyncSuite = (
  name: string,
  tests: array<asyncTestCase>,
  ~beforeAll: option<unit => promise<unit>>=?,
  ~afterAll: option<unit => promise<unit>>=?,
  ~beforeEach: option<unit => promise<unit>>=?,
  ~afterEach: option<unit => promise<unit>>=?,
): asyncTestSuite => {
  let hasHooks =
    beforeAll->Option.isSome ||
    afterAll->Option.isSome ||
    beforeEach->Option.isSome ||
    afterEach->Option.isSome
  {
    name,
    tests,
    hooks: if hasHooks {
      Some({beforeAll, afterAll, beforeEach, afterEach})
    } else {
      None
    },
  }
}

// Re-export assertions
let assertEqual = Assert.assertEqual
let assertNotEqual = Assert.assertNotEqual
let assertTrue = Assert.assertTrue
let assertFalse = Assert.assertFalse
let assertGreaterThan = Assert.assertGreaterThan
let assertLessThan = Assert.assertLessThan
let assertGreaterThanOrEqual = Assert.assertGreaterThanOrEqual
let assertLessThanOrEqual = Assert.assertLessThanOrEqual
let assertContains = Assert.assertContains
let assertArrayContains = Assert.assertArrayContains
let assertMatch = Assert.assertMatch
let assertSome = Assert.assertSome
let assertNone = Assert.assertNone
let assertOk = Assert.assertOk
let assertError = Assert.assertError
let assertThrows = Assert.assertThrows
let combineResults = Assert.combineResults
let combineAsyncResults = Assert.combineAsyncResults

// Re-export snapshot testing
let setSnapshotDir = Snapshot.setSnapshotDir
let assertMatchesSnapshot = Snapshot.assertMatchesSnapshot
let updateSnapshot = Snapshot.updateSnapshot

// Re-export runners
let runSuite = Runner.runSuite
let runSuites = Runner.runSuites
let runAsyncSuite = Runner.runAsyncSuite
let runAsyncSuites = Runner.runAsyncSuites
let runWithTimeout = Runner.runWithTimeout

// Re-export filtering
let setFilterPattern = Runner.setFilterPattern
let setSkipPattern = Runner.setSkipPattern

// Re-export watch mode
let watchMode = Runner.watchMode

// Re-export DOM testing module
module Dom = DomTesting
