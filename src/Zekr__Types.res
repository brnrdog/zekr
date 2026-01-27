// Zekr__Types - Core type definitions for the Zekr test framework

type testResult = Pass | Fail(string)

type testMode = Normal | Skip | Only

type testCase = {
  name: string,
  run: unit => testResult,
  mode: testMode,
}

type asyncTestCase = {
  name: string,
  run: unit => promise<testResult>,
  mode: testMode,
  timeout: option<int>,
}

type hooks = {
  beforeAll: option<unit => unit>,
  afterAll: option<unit => unit>,
  beforeEach: option<unit => unit>,
  afterEach: option<unit => unit>,
}

type asyncHooks = {
  beforeAll: option<unit => promise<unit>>,
  afterAll: option<unit => promise<unit>>,
  beforeEach: option<unit => promise<unit>>,
  afterEach: option<unit => promise<unit>>,
}

type testSuite = {
  name: string,
  tests: array<testCase>,
  hooks: option<hooks>,
}

type asyncTestSuite = {
  name: string,
  tests: array<asyncTestCase>,
  hooks: option<asyncHooks>,
}
