open Zekr

let assertEqualTests = suite("assertEqual", [
  test("passes when values are equal", () => {
    let result = assertEqual(1, 1)
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when values differ", () => {
    let result = assertEqual(1, 2)
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
  test("uses custom message when provided", () => {
    let result = assertEqual(1, 2, ~message="custom error")
    switch result {
    | Fail(msg) if msg == "custom error" => Pass
    | Fail(_) => Fail("Expected custom message")
    | Pass => Fail("Expected Fail")
    }
  }),
])

let assertNotEqualTests = suite("assertNotEqual", [
  test("passes when values differ", () => {
    let result = assertNotEqual(1, 2)
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when values are equal", () => {
    let result = assertNotEqual(1, 1)
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

let assertTrueTests = suite("assertTrue", [
  test("passes when condition is true", () => {
    let result = assertTrue(true)
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when condition is false", () => {
    let result = assertTrue(false)
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

let assertFalseTests = suite("assertFalse", [
  test("passes when condition is false", () => {
    let result = assertFalse(false)
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when condition is true", () => {
    let result = assertFalse(true)
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

let combineResultsTests = suite("combineResults", [
  test("returns Pass when all pass", () => {
    let result = combineResults([Pass, Pass, Pass])
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("returns first Fail when any fail", () => {
    let result = combineResults([Pass, Fail("first"), Fail("second")])
    switch result {
    | Fail("first") => Pass
    | Fail(_) => Fail("Expected first failure message")
    | Pass => Fail("Expected Fail")
    }
  }),
  test("returns Pass for empty array", () => {
    let result = combineResults([])
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
])

let assertGreaterThanTests = suite("assertGreaterThan", [
  test("passes when actual is greater", () => {
    let result = assertGreaterThan(5, 3)
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when actual is less", () => {
    let result = assertGreaterThan(3, 5)
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
  test("fails when values are equal", () => {
    let result = assertGreaterThan(5, 5)
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

let assertLessThanTests = suite("assertLessThan", [
  test("passes when actual is less", () => {
    let result = assertLessThan(3, 5)
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when actual is greater", () => {
    let result = assertLessThan(5, 3)
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

let assertContainsTests = suite("assertContains", [
  test("passes when string contains substring", () => {
    let result = assertContains("hello world", "world")
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when string does not contain substring", () => {
    let result = assertContains("hello world", "foo")
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

let assertArrayContainsTests = suite("assertArrayContains", [
  test("passes when array contains item", () => {
    let result = assertArrayContains([1, 2, 3], 2)
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when array does not contain item", () => {
    let result = assertArrayContains([1, 2, 3], 4)
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

let assertMatchTests = suite("assertMatch", [
  test("passes when string matches pattern", () => {
    let result = assertMatch("hello123", %re("/\d+/"))
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when string does not match pattern", () => {
    let result = assertMatch("hello", %re("/\d+/"))
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

let assertSomeTests = suite("assertSome", [
  test("passes when option is Some", () => {
    let result = assertSome(Some(42))
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when option is None", () => {
    let result = assertSome(None)
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

let assertNoneTests = suite("assertNone", [
  test("passes when option is None", () => {
    let result = assertNone(None)
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when option is Some", () => {
    let result = assertNone(Some(42))
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

let assertOkTests = suite("assertOk", [
  test("passes when result is Ok", () => {
    let result = assertOk(Ok(42))
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when result is Error", () => {
    let result = assertOk(Error("error"))
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

let assertErrorTests = suite("assertError", [
  test("passes when result is Error", () => {
    let result = assertError(Error("error"))
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when result is Ok", () => {
    let result = assertError(Ok(42))
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

let assertThrowsTests = suite("assertThrows", [
  test("passes when function throws", () => {
    let result = assertThrows(() => {
      throw(Not_found)
    })
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  test("fails when function does not throw", () => {
    let result = assertThrows(() => {
      42
    })
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

runSuites([
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
])
