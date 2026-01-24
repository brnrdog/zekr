// Zekr - A simple test framework for ReScript

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

let runSuite = (suite: testSuite): unit => {
  Console.log(`\n Running test suite: ${suite.name}`)
  Console.log("=" ++ String.repeat("-", String.length(suite.name) + 23))

  let passed = ref(0)
  let failed = ref(0)

  suite.tests->Array.forEach(testCase => {
    switch testCase.run() {
    | Pass => {
        Console.log(`  ${testCase.name}`)
        passed := passed.contents + 1
      }
    | Fail(message) => {
        Console.log(`  ${testCase.name}`)
        Console.log(`    ${message}`)
        failed := failed.contents + 1
      }
    }
  })

  Console.log("")
  Console.log(
    `Results: ${Int.toString(passed.contents)} passed, ${Int.toString(failed.contents)} failed`,
  )

  if failed.contents > 0 {
    Console.log(" Some tests failed")
  } else {
    Console.log(" All tests passed!")
  }
}

let runSuites = (suites: array<testSuite>): unit => {
  Console.log("\n Running all test suites")
  Console.log("========================\n")

  let totalPassed = ref(0)
  let totalFailed = ref(0)

  suites->Array.forEach(suite => {
    Console.log(`\n ${suite.name}`)
    Console.log("-" ++ String.repeat("-", String.length(suite.name) + 3))

    let suitePassed = ref(0)
    let suiteFailed = ref(0)

    suite.tests->Array.forEach(testCase => {
      switch testCase.run() {
      | Pass => {
          Console.log(`   ${testCase.name}`)
          suitePassed := suitePassed.contents + 1
          totalPassed := totalPassed.contents + 1
        }
      | Fail(message) => {
          Console.log(`   ${testCase.name}`)
          Console.log(`    ${message}`)
          suiteFailed := suiteFailed.contents + 1
          totalFailed := totalFailed.contents + 1
        }
      }
    })

    Console.log(
      `  ${Int.toString(suitePassed.contents)} passed, ${Int.toString(
          suiteFailed.contents,
        )} failed`,
    )
  })

  Console.log("\n" ++ String.repeat("=", 50))
  Console.log(
    `Total: ${Int.toString(totalPassed.contents)} passed, ${Int.toString(
        totalFailed.contents,
      )} failed`,
  )

  if totalFailed.contents > 0 {
    Console.log(" Some tests failed\n")
    %raw(`process.exit(1)`)
  } else {
    Console.log(" All tests passed!\n")
    %raw(`process.exit(0)`)
  }
}

let runAsyncSuite = async (suite: asyncTestSuite): unit => {
  Console.log(`\n Running async test suite: ${suite.name}`)
  Console.log("=" ++ String.repeat("-", String.length(suite.name) + 29))

  let passed = ref(0)
  let failed = ref(0)

  for i in 0 to Array.length(suite.tests) - 1 {
    let testCase = suite.tests->Array.getUnsafe(i)
    let result = await testCase.run()
    switch result {
    | Pass => {
        Console.log(`  ${testCase.name}`)
        passed := passed.contents + 1
      }
    | Fail(message) => {
        Console.log(`  ${testCase.name}`)
        Console.log(`    ${message}`)
        failed := failed.contents + 1
      }
    }
  }

  Console.log("")
  Console.log(
    `Results: ${Int.toString(passed.contents)} passed, ${Int.toString(failed.contents)} failed`,
  )

  if failed.contents > 0 {
    Console.log(" Some tests failed")
  } else {
    Console.log(" All tests passed!")
  }
}

let runAsyncSuites = async (suites: array<asyncTestSuite>): unit => {
  Console.log("\n Running all async test suites")
  Console.log("==============================\n")

  let totalPassed = ref(0)
  let totalFailed = ref(0)

  for i in 0 to Array.length(suites) - 1 {
    let suite = suites->Array.getUnsafe(i)
    Console.log(`\n ${suite.name}`)
    Console.log("-" ++ String.repeat("-", String.length(suite.name) + 3))

    let suitePassed = ref(0)
    let suiteFailed = ref(0)

    for j in 0 to Array.length(suite.tests) - 1 {
      let testCase = suite.tests->Array.getUnsafe(j)
      let result = await testCase.run()
      switch result {
      | Pass => {
          Console.log(`   ${testCase.name}`)
          suitePassed := suitePassed.contents + 1
          totalPassed := totalPassed.contents + 1
        }
      | Fail(message) => {
          Console.log(`   ${testCase.name}`)
          Console.log(`    ${message}`)
          suiteFailed := suiteFailed.contents + 1
          totalFailed := totalFailed.contents + 1
        }
      }
    }

    Console.log(
      `  ${Int.toString(suitePassed.contents)} passed, ${Int.toString(
          suiteFailed.contents,
        )} failed`,
    )
  }

  Console.log("\n" ++ String.repeat("=", 50))
  Console.log(
    `Total: ${Int.toString(totalPassed.contents)} passed, ${Int.toString(
        totalFailed.contents,
      )} failed`,
  )

  if totalFailed.contents > 0 {
    Console.log(" Some tests failed\n")
    %raw(`process.exit(1)`)
  } else {
    Console.log(" All tests passed!\n")
    %raw(`process.exit(0)`)
  }
}
