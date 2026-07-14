open Types

let assertEqualTests = Suite.make(
  "Assert.equal",
  [
    Test.make("passes when values are equal", () => {
      let result = Assert.equal(1, 1)
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when values differ", () => {
      let result = Assert.equal(1, 2)
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
    Test.make("uses custom message when provided", () => {
      let result = Assert.equal(1, 2, ~message="custom error")
      switch result {
      | Fail(msg) if msg == "custom error" => Pass
      | Fail(_) => Fail("Expected custom message")
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let assertNotEqualTests = Suite.make(
  "Assert.notEqual",
  [
    Test.make("passes when values differ", () => {
      let result = Assert.notEqual(1, 2)
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when values are equal", () => {
      let result = Assert.notEqual(1, 1)
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let assertTrueTests = Suite.make(
  "Assert.isTrue",
  [
    Test.make("passes when condition is true", () => {
      let result = Assert.isTrue(true)
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when condition is false", () => {
      let result = Assert.isTrue(false)
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let assertFalseTests = Suite.make(
  "Assert.isFalse",
  [
    Test.make("passes when condition is false", () => {
      let result = Assert.isFalse(false)
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when condition is true", () => {
      let result = Assert.isFalse(true)
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let combineResultsTests = Suite.make(
  "Assert.combineResults",
  [
    Test.make("returns Pass when all pass", () => {
      let result = Assert.combineResults([Pass, Pass, Pass])
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("returns first Fail when any fail", () => {
      let result = Assert.combineResults([Pass, Fail("first"), Fail("second")])
      switch result {
      | Fail("first") => Pass
      | Fail(_) => Fail("Expected first failure message")
      | Pass => Fail("Expected Fail")
      }
    }),
    Test.make("returns Pass for empty array", () => {
      let result = Assert.combineResults([])
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
  ],
)

let assertGreaterThanTests = Suite.make(
  "Assert.greaterThan",
  [
    Test.make("passes when actual is greater", () => {
      let result = Assert.greaterThan(5, 3)
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when actual is less", () => {
      let result = Assert.greaterThan(3, 5)
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
    Test.make("fails when values are equal", () => {
      let result = Assert.greaterThan(5, 5)
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let assertLessThanTests = Suite.make(
  "Assert.lessThan",
  [
    Test.make("passes when actual is less", () => {
      let result = Assert.lessThan(3, 5)
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when actual is greater", () => {
      let result = Assert.lessThan(5, 3)
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let assertContainsTests = Suite.make(
  "Assert.contains",
  [
    Test.make("passes when string contains substring", () => {
      let result = Assert.contains("hello world", "world")
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when string does not contain substring", () => {
      let result = Assert.contains("hello world", "foo")
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let assertArrayContainsTests = Suite.make(
  "Assert.arrayContains",
  [
    Test.make("passes when array contains item", () => {
      let result = Assert.arrayContains([1, 2, 3], 2)
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when array does not contain item", () => {
      let result = Assert.arrayContains([1, 2, 3], 4)
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let assertMatchTests = Suite.make(
  "Assert.matches",
  [
    Test.make("passes when string matches pattern", () => {
      let result = Assert.matches("hello123", /\d+/)
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when string does not match pattern", () => {
      let result = Assert.matches("hello", /\d+/)
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let assertSomeTests = Suite.make(
  "Assert.some",
  [
    Test.make("passes when option is Some", () => {
      let result = Assert.some(Some(42))
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when option is None", () => {
      let result = Assert.some(None)
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let assertNoneTests = Suite.make(
  "Assert.none",
  [
    Test.make("passes when option is None", () => {
      let result = Assert.none(None)
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when option is Some", () => {
      let result = Assert.none(Some(42))
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let assertOkTests = Suite.make(
  "Assert.ok",
  [
    Test.make("passes when result is Ok", () => {
      let result = Assert.ok(Ok(42))
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when result is Error", () => {
      let result = Assert.ok(Error("error"))
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let assertErrorTests = Suite.make(
  "Assert.error",
  [
    Test.make("passes when result is Error", () => {
      let result = Assert.error(Error("error"))
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when result is Ok", () => {
      let result = Assert.error(Ok(42))
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let assertThrowsTests = Suite.make(
  "Assert.throws",
  [
    Test.make("passes when function throws", () => {
      let result = Assert.throws(() => {
        throw(Not_found)
      })
      switch result {
      | Pass => Pass
      | Fail(_) => Fail("Expected Pass")
      }
    }),
    Test.make("fails when function does not throw", () => {
      let result = Assert.throws(() => {
        42
      })
      switch result {
      | Fail(_) => Pass
      | Pass => Fail("Expected Fail")
      }
    }),
  ],
)

let testModeTests = Suite.make(
  "Test.skip and Test.only",
  [
    Test.make("test creates Normal mode", () => {
      let tc = Test.make("example", () => Pass)
      Assert.equal(tc.mode, Normal)
    }),
    Test.make("Test.skip creates Skip mode", () => {
      let tc = Test.skip("example", () => Pass)
      Assert.equal(tc.mode, Skip)
    }),
    Test.make("Test.only creates Only mode", () => {
      let tc = Test.only("example", () => Pass)
      Assert.equal(tc.mode, Only)
    }),
    Test.make("Test.async creates Normal mode", () => {
      let tc = Test.async("example", async () => Pass)
      Assert.equal(tc.mode, Normal)
    }),
    Test.make("Test.asyncSkip creates Skip mode", () => {
      let tc = Test.asyncSkip("example", async () => Pass)
      Assert.equal(tc.mode, Skip)
    }),
    Test.make("Test.asyncOnly creates Only mode", () => {
      let tc = Test.asyncOnly("example", async () => Pass)
      Assert.equal(tc.mode, Only)
    }),
    Test.make("Test.async accepts timeout parameter", () => {
      let tc = Test.async("example", async () => Pass, ~timeout=1000)
      Assert.equal(tc.timeout, Some(1000))
    }),
    Test.make("Test.async has None timeout by default", () => {
      let tc = Test.async("example", async () => Pass)
      Assert.equal(tc.timeout, None)
    }),
  ],
)

let suiteHooksTests = Suite.make(
  "suite with hooks",
  [
    Test.make("creates suite with hooks", () => {
      let s = Suite.make(
        "test suite",
        [Test.make("t", () => Pass)],
        ~beforeAll=() => (),
        ~afterAll=() => (),
        ~beforeEach=() => (),
        ~afterEach=() => (),
      )
      switch s.hooks {
      | Some(_) => Pass
      | None => Fail("Expected hooks to be defined")
      }
    }),
    Test.make("suite without hooks has None hooks", () => {
      let s = Suite.make("test suite", [Test.make("t", () => Pass)])
      switch s.hooks {
      | None => Pass
      | Some(_) => Fail("Expected hooks to be None")
      }
    }),
    Test.make("suite allows partial hooks", () => {
      let s = Suite.make("test suite", [Test.make("t", () => Pass)], ~beforeEach=() => ())
      switch s.hooks {
      | Some({beforeEach: Some(_), afterEach: None, beforeAll: None, afterAll: None}) => Pass
      | _ => Fail("Expected only beforeEach to be defined")
      }
    }),
  ],
)

let asyncSuiteHooksTests = Suite.make(
  "asyncSuite with hooks",
  [
    Test.make("creates async suite with hooks", () => {
      let s = Suite.async(
        "test suite",
        [Test.async("t", async () => Pass)],
        ~beforeAll=async () => (),
        ~afterAll=async () => (),
        ~beforeEach=async () => (),
        ~afterEach=async () => (),
      )
      switch s.hooks {
      | Some(_) => Pass
      | None => Fail("Expected hooks to be defined")
      }
    }),
    Test.make("asyncSuite without hooks has None hooks", () => {
      let s = Suite.async("test suite", [Test.async("t", async () => Pass)])
      switch s.hooks {
      | None => Pass
      | Some(_) => Fail("Expected hooks to be None")
      }
    }),
  ],
)

// Use a test-specific snapshot directory
let _ = Snapshot.setDir("tests/__snapshots__")

let snapshotTests = Suite.make(
  "Snapshot.matches",
  [
    Test.make("creates and matches snapshot for simple value", () => {
      let result = Snapshot.matches(42, ~name="simple-number")
      result
    }),
    Test.make("creates and matches snapshot for object", () => {
      let obj = {"name": "test", "value": 123}
      let result = Snapshot.matches(obj, ~name="simple-object")
      result
    }),
    Test.make("creates and matches snapshot for array", () => {
      let arr = [1, 2, 3, 4, 5]
      let result = Snapshot.matches(arr, ~name="simple-array")
      result
    }),
    Test.make("creates and matches snapshot for nested structure", () => {
      let nested = {
        "users": [{"id": 1, "name": "Alice"}, {"id": 2, "name": "Bob"}],
        "count": 2,
      }
      let result = Snapshot.matches(nested, ~name="nested-structure")
      result
    }),
  ],
)

Runner.runSuites([
  assertEqualTests,
  assertNotEqualTests,
  assertTrueTests,
  assertFalseTests,
  combineResultsTests,
  assertGreaterThanTests,
  assertLessThanTests,
  assertContainsTests,
  assertArrayContainsTests,
  assertMatchTests,
  assertSomeTests,
  assertNoneTests,
  assertOkTests,
  assertErrorTests,
  assertThrowsTests,
  testModeTests,
  suiteHooksTests,
  asyncSuiteHooksTests,
  snapshotTests,
])
