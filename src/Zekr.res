// Zekr - A simple test framework for ReScript

// ANSI color codes
module Colors = {
  let reset = "\x1b[0m"
  let green = "\x1b[32m"
  let red = "\x1b[31m"
  let yellow = "\x1b[33m"
  let cyan = "\x1b[36m"
  let dim = "\x1b[2m"
  let bold = "\x1b[1m"

  let pass = text => `${green}${text}${reset}`
  let fail = text => `${red}${text}${reset}`
  let suite = text => `${cyan}${bold}${text}${reset}`
  let dimmed = text => `${dim}${text}${reset}`
}

type testResult = Pass | Fail(string)

type testCase = {
  name: string,
  run: unit => testResult,
}

type asyncTestCase = {
  name: string,
  run: unit => promise<testResult>,
}

type testSuite = {
  name: string,
  tests: array<testCase>,
}

type asyncTestSuite = {
  name: string,
  tests: array<asyncTestCase>,
}

let test = (name: string, run: unit => testResult): testCase => {
  {name, run}
}

let asyncTest = (name: string, run: unit => promise<testResult>): asyncTestCase => {
  {name, run}
}

let suite = (name: string, tests: array<testCase>): testSuite => {
  {name, tests}
}

let asyncSuite = (name: string, tests: array<asyncTestCase>): asyncTestSuite => {
  {name, tests}
}

let assertEqual = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual == expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => `Expected ${String.make(expected)}, got ${String.make(actual)}`
    }
    Fail(msg)
  }
}

let assertNotEqual = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual != expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => `Expected values to not be equal`
    }
    Fail(msg)
  }
}

let assertTrue = (condition: bool, ~message: option<string>=?): testResult => {
  if condition {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => "Expected true, got false"
    }
    Fail(msg)
  }
}

let assertFalse = (condition: bool, ~message: option<string>=?): testResult => {
  if !condition {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => "Expected false, got true"
    }
    Fail(msg)
  }
}

let assertGreaterThan = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual > expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => `Expected ${String.make(actual)} to be greater than ${String.make(expected)}`
    }
    Fail(msg)
  }
}

let assertLessThan = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual < expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => `Expected ${String.make(actual)} to be less than ${String.make(expected)}`
    }
    Fail(msg)
  }
}

let assertGreaterThanOrEqual = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual >= expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => `Expected ${String.make(actual)} to be greater than or equal to ${String.make(expected)}`
    }
    Fail(msg)
  }
}

let assertLessThanOrEqual = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual <= expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => `Expected ${String.make(actual)} to be less than or equal to ${String.make(expected)}`
    }
    Fail(msg)
  }
}

let assertContains = (haystack: string, needle: string, ~message: option<string>=?): testResult => {
  if String.includes(haystack, needle) {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => `Expected "${haystack}" to contain "${needle}"`
    }
    Fail(msg)
  }
}

let assertArrayContains = (arr: array<'a>, item: 'a, ~message: option<string>=?): testResult => {
  if Array.includes(arr, item) {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => `Expected array to contain ${String.make(item)}`
    }
    Fail(msg)
  }
}

let assertMatch = (str: string, pattern: RegExp.t, ~message: option<string>=?): testResult => {
  if RegExp.test(pattern, str) {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => `Expected "${str}" to match pattern`
    }
    Fail(msg)
  }
}

let assertSome = (opt: option<'a>, ~message: option<string>=?): testResult => {
  switch opt {
  | Some(_) => Pass
  | None => {
      let msg = switch message {
      | Some(m) => m
      | None => "Expected Some, got None"
      }
      Fail(msg)
    }
  }
}

let assertNone = (opt: option<'a>, ~message: option<string>=?): testResult => {
  switch opt {
  | None => Pass
  | Some(_) => {
      let msg = switch message {
      | Some(m) => m
      | None => "Expected None, got Some"
      }
      Fail(msg)
    }
  }
}

let assertOk = (result: result<'a, 'e>, ~message: option<string>=?): testResult => {
  switch result {
  | Ok(_) => Pass
  | Error(_) => {
      let msg = switch message {
      | Some(m) => m
      | None => "Expected Ok, got Error"
      }
      Fail(msg)
    }
  }
}

let assertError = (result: result<'a, 'e>, ~message: option<string>=?): testResult => {
  switch result {
  | Error(_) => Pass
  | Ok(_) => {
      let msg = switch message {
      | Some(m) => m
      | None => "Expected Error, got Ok"
      }
      Fail(msg)
    }
  }
}

let assertThrows = (fn: unit => 'a, ~message: option<string>=?): testResult => {
  try {
    let _ = fn()
    let msg = switch message {
    | Some(m) => m
    | None => "Expected function to throw"
    }
    Fail(msg)
  } catch {
  | _ => Pass
  }
}

let combineResults = (results: array<testResult>): testResult => {
  let failures = results->Array.filter(r =>
    switch r {
    | Fail(_) => true
    | Pass => false
    }
  )

  if Array.length(failures) > 0 {
    failures->Array.get(0)->Option.getOr(Pass)
  } else {
    Pass
  }
}

let combineAsyncResults = async (results: array<promise<testResult>>): testResult => {
  let resolvedResults = await Promise.all(results)
  let failures = resolvedResults->Array.filter(r =>
    switch r {
    | Fail(_) => true
    | Pass => false
    }
  )

  if Array.length(failures) > 0 {
    failures->Array.get(0)->Option.getOr(Pass)
  } else {
    Pass
  }
}

let runSuite = (testSuite: testSuite): unit => {
  Console.log(`\n ${Colors.suite(`Running test suite: ${testSuite.name}`)}`)
  Console.log(Colors.dimmed("=" ++ String.repeat("-", String.length(testSuite.name) + 23)))

  let passed = ref(0)
  let failed = ref(0)

  testSuite.tests->Array.forEach(testCase => {
    switch testCase.run() {
    | Pass => {
        Console.log(`  ${Colors.pass("✓")} ${testCase.name}`)
        passed := passed.contents + 1
      }
    | Fail(message) => {
        Console.log(`  ${Colors.fail("✗")} ${testCase.name}`)
        Console.log(`    ${Colors.fail(message)}`)
        failed := failed.contents + 1
      }
    }
  })

  Console.log("")
  Console.log(
    `Results: ${Colors.pass(Int.toString(passed.contents) ++ " passed")}, ${Colors.fail(Int.toString(failed.contents) ++ " failed")}`,
  )

  if failed.contents > 0 {
    Console.log(Colors.fail(" Some tests failed"))
  } else {
    Console.log(Colors.pass(" All tests passed!"))
  }
}

let runSuites = (suites: array<testSuite>): unit => {
  Console.log(`\n ${Colors.suite("Running all test suites")}`)
  Console.log(Colors.dimmed("========================\n"))

  let totalPassed = ref(0)
  let totalFailed = ref(0)

  suites->Array.forEach(testSuite => {
    Console.log(`\n ${Colors.suite(testSuite.name)}`)
    Console.log(Colors.dimmed("-" ++ String.repeat("-", String.length(testSuite.name) + 3)))

    let suitePassed = ref(0)
    let suiteFailed = ref(0)

    testSuite.tests->Array.forEach(testCase => {
      switch testCase.run() {
      | Pass => {
          Console.log(`   ${Colors.pass("✓")} ${testCase.name}`)
          suitePassed := suitePassed.contents + 1
          totalPassed := totalPassed.contents + 1
        }
      | Fail(message) => {
          Console.log(`   ${Colors.fail("✗")} ${testCase.name}`)
          Console.log(`     ${Colors.fail(message)}`)
          suiteFailed := suiteFailed.contents + 1
          totalFailed := totalFailed.contents + 1
        }
      }
    })

    Console.log(
      `  ${Colors.pass(Int.toString(suitePassed.contents) ++ " passed")}, ${Colors.fail(Int.toString(suiteFailed.contents) ++ " failed")}`,
    )
  })

  Console.log("\n" ++ Colors.dimmed(String.repeat("=", 50)))
  Console.log(
    `Total: ${Colors.pass(Int.toString(totalPassed.contents) ++ " passed")}, ${Colors.fail(Int.toString(totalFailed.contents) ++ " failed")}`,
  )

  if totalFailed.contents > 0 {
    Console.log(Colors.fail(" Some tests failed\n"))
    %raw(`process.exit(1)`)
  } else {
    Console.log(Colors.pass(" All tests passed!\n"))
    %raw(`process.exit(0)`)
  }
}

let runAsyncSuite = async (asyncSuite: asyncTestSuite): unit => {
  Console.log(`\n ${Colors.suite(`Running async test suite: ${asyncSuite.name}`)}`)
  Console.log(Colors.dimmed("=" ++ String.repeat("-", String.length(asyncSuite.name) + 29)))

  let passed = ref(0)
  let failed = ref(0)

  for i in 0 to Array.length(asyncSuite.tests) - 1 {
    let testCase = asyncSuite.tests->Array.getUnsafe(i)
    let result = await testCase.run()
    switch result {
    | Pass => {
        Console.log(`  ${Colors.pass("✓")} ${testCase.name}`)
        passed := passed.contents + 1
      }
    | Fail(message) => {
        Console.log(`  ${Colors.fail("✗")} ${testCase.name}`)
        Console.log(`    ${Colors.fail(message)}`)
        failed := failed.contents + 1
      }
    }
  }

  Console.log("")
  Console.log(
    `Results: ${Colors.pass(Int.toString(passed.contents) ++ " passed")}, ${Colors.fail(Int.toString(failed.contents) ++ " failed")}`,
  )

  if failed.contents > 0 {
    Console.log(Colors.fail(" Some tests failed"))
  } else {
    Console.log(Colors.pass(" All tests passed!"))
  }
}

let runAsyncSuites = async (suites: array<asyncTestSuite>): unit => {
  Console.log(`\n ${Colors.suite("Running all async test suites")}`)
  Console.log(Colors.dimmed("==============================\n"))

  let totalPassed = ref(0)
  let totalFailed = ref(0)

  for i in 0 to Array.length(suites) - 1 {
    let asyncSuite = suites->Array.getUnsafe(i)
    Console.log(`\n ${Colors.suite(asyncSuite.name)}`)
    Console.log(Colors.dimmed("-" ++ String.repeat("-", String.length(asyncSuite.name) + 3)))

    let suitePassed = ref(0)
    let suiteFailed = ref(0)

    for j in 0 to Array.length(asyncSuite.tests) - 1 {
      let testCase = asyncSuite.tests->Array.getUnsafe(j)
      let result = await testCase.run()
      switch result {
      | Pass => {
          Console.log(`   ${Colors.pass("✓")} ${testCase.name}`)
          suitePassed := suitePassed.contents + 1
          totalPassed := totalPassed.contents + 1
        }
      | Fail(message) => {
          Console.log(`   ${Colors.fail("✗")} ${testCase.name}`)
          Console.log(`     ${Colors.fail(message)}`)
          suiteFailed := suiteFailed.contents + 1
          totalFailed := totalFailed.contents + 1
        }
      }
    }

    Console.log(
      `  ${Colors.pass(Int.toString(suitePassed.contents) ++ " passed")}, ${Colors.fail(Int.toString(suiteFailed.contents) ++ " failed")}`,
    )
  }

  Console.log("\n" ++ Colors.dimmed(String.repeat("=", 50)))
  Console.log(
    `Total: ${Colors.pass(Int.toString(totalPassed.contents) ++ " passed")}, ${Colors.fail(Int.toString(totalFailed.contents) ++ " failed")}`,
  )

  if totalFailed.contents > 0 {
    Console.log(Colors.fail(" Some tests failed\n"))
    %raw(`process.exit(1)`)
  } else {
    Console.log(Colors.pass(" All tests passed!\n"))
    %raw(`process.exit(0)`)
  }
}
