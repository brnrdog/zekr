// Zekr - A simple test framework for ReScript
// This module serves as the public API facade

// Re-export all types and their constructors
include Zekr__Types

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
let assertEqual = Zekr__Assert.assertEqual
let assertNotEqual = Zekr__Assert.assertNotEqual
let assertTrue = Zekr__Assert.assertTrue
let assertFalse = Zekr__Assert.assertFalse
let assertGreaterThan = Zekr__Assert.assertGreaterThan
let assertLessThan = Zekr__Assert.assertLessThan
let assertGreaterThanOrEqual = Zekr__Assert.assertGreaterThanOrEqual
let assertLessThanOrEqual = Zekr__Assert.assertLessThanOrEqual
let assertContains = Zekr__Assert.assertContains
let assertArrayContains = Zekr__Assert.assertArrayContains
let assertMatch = Zekr__Assert.assertMatch
let assertSome = Zekr__Assert.assertSome
let assertNone = Zekr__Assert.assertNone
let assertOk = Zekr__Assert.assertOk
let assertError = Zekr__Assert.assertError
let assertThrows = Zekr__Assert.assertThrows
let combineResults = Zekr__Assert.combineResults
let combineAsyncResults = Zekr__Assert.combineAsyncResults

// Re-export snapshot testing
let setSnapshotDir = Zekr__Snapshot.setSnapshotDir
let assertMatchesSnapshot = Zekr__Snapshot.assertMatchesSnapshot
let updateSnapshot = Zekr__Snapshot.updateSnapshot

// Re-export runners
let runSuite = Zekr__Runner.runSuite
let runSuites = Zekr__Runner.runSuites
let runAsyncSuite = Zekr__Runner.runAsyncSuite
let runAsyncSuites = Zekr__Runner.runAsyncSuites
let runWithTimeout = Zekr__Runner.runWithTimeout

// Re-export filtering
let setFilterPattern = Zekr__Runner.setFilterPattern
let setSkipPattern = Zekr__Runner.setSkipPattern

// Re-export watch mode
let watchMode = Zekr__Runner.watchMode
