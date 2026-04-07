// Suite - Test suite factory functions

open Types

let make = (
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

let async = (
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
