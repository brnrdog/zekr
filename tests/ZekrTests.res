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

runSuites([
  assertEqualTests,
  assertNotEqualTests,
  assertTrueTests,
  assertFalseTests,
  combineResultsTests,
])
