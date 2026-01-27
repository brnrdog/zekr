// Zekr__Runner - Test execution and reporting

open Zekr__Types

let runSuite = (testSuite: testSuite): unit => {
  Console.log(`\n ${Zekr__Colors.suite(`Running test suite: ${testSuite.name}`)}`)
  Console.log(Zekr__Colors.dimmed("=" ++ String.repeat("-", String.length(testSuite.name) + 23)))

  let passed = ref(0)
  let failed = ref(0)
  let skipped = ref(0)

  // Run beforeAll hook if present
  switch testSuite.hooks {
  | Some({beforeAll: Some(fn)}) => fn()
  | _ => ()
  }

  // Check if there are any "Only" tests
  let hasOnly = testSuite.tests->Array.some(tc => tc.mode == Only)

  testSuite.tests->Array.forEach(testCase => {
    // Determine if this test should run
    let shouldRun = switch testCase.mode {
    | Skip => false
    | Only => true
    | Normal => !hasOnly
    }

    if shouldRun {
      // Run beforeEach hook if present
      switch testSuite.hooks {
      | Some({beforeEach: Some(fn)}) => fn()
      | _ => ()
      }

      switch testCase.run() {
      | Pass => {
          Console.log(`  ${Zekr__Colors.pass("✓")} ${testCase.name}`)
          passed := passed.contents + 1
        }
      | Fail(message) => {
          Console.log(`  ${Zekr__Colors.fail("✗")} ${testCase.name}`)
          Console.log(`    ${Zekr__Colors.fail(message)}`)
          failed := failed.contents + 1
        }
      }

      // Run afterEach hook if present
      switch testSuite.hooks {
      | Some({afterEach: Some(fn)}) => fn()
      | _ => ()
      }
    } else {
      Console.log(`  ${Zekr__Colors.skip("○")} ${Zekr__Colors.skip(testCase.name)} ${Zekr__Colors.dimmed("(skipped)")}`)
      skipped := skipped.contents + 1
    }
  })

  // Run afterAll hook if present
  switch testSuite.hooks {
  | Some({afterAll: Some(fn)}) => fn()
  | _ => ()
  }

  Console.log("")
  let skipMsg = if skipped.contents > 0 {
    `, ${Zekr__Colors.skip(Int.toString(skipped.contents) ++ " skipped")}`
  } else {
    ""
  }
  Console.log(
    `Results: ${Zekr__Colors.pass(Int.toString(passed.contents) ++ " passed")}, ${Zekr__Colors.fail(Int.toString(failed.contents) ++ " failed")}${skipMsg}`,
  )

  if failed.contents > 0 {
    Console.log(Zekr__Colors.fail(" Some tests failed"))
  } else {
    Console.log(Zekr__Colors.pass(" All tests passed!"))
  }
}

let runSuites = (suites: array<testSuite>): unit => {
  Console.log(`\n ${Zekr__Colors.suite("Running all test suites")}`)
  Console.log(Zekr__Colors.dimmed("========================\n"))

  let totalPassed = ref(0)
  let totalFailed = ref(0)
  let totalSkipped = ref(0)

  // Check if there are any "Only" tests across all suites
  let hasOnly = suites->Array.some(s => s.tests->Array.some(tc => tc.mode == Only))

  suites->Array.forEach(testSuite => {
    Console.log(`\n ${Zekr__Colors.suite(testSuite.name)}`)
    Console.log(Zekr__Colors.dimmed("-" ++ String.repeat("-", String.length(testSuite.name) + 3)))

    // Run beforeAll hook if present
    switch testSuite.hooks {
    | Some({beforeAll: Some(fn)}) => fn()
    | _ => ()
    }

    let suitePassed = ref(0)
    let suiteFailed = ref(0)
    let suiteSkipped = ref(0)

    testSuite.tests->Array.forEach(testCase => {
      // Determine if this test should run
      let shouldRun = switch testCase.mode {
      | Skip => false
      | Only => true
      | Normal => !hasOnly
      }

      if shouldRun {
        // Run beforeEach hook if present
        switch testSuite.hooks {
        | Some({beforeEach: Some(fn)}) => fn()
        | _ => ()
        }

        switch testCase.run() {
        | Pass => {
            Console.log(`   ${Zekr__Colors.pass("✓")} ${testCase.name}`)
            suitePassed := suitePassed.contents + 1
            totalPassed := totalPassed.contents + 1
          }
        | Fail(message) => {
            Console.log(`   ${Zekr__Colors.fail("✗")} ${testCase.name}`)
            Console.log(`     ${Zekr__Colors.fail(message)}`)
            suiteFailed := suiteFailed.contents + 1
            totalFailed := totalFailed.contents + 1
          }
        }

        // Run afterEach hook if present
        switch testSuite.hooks {
        | Some({afterEach: Some(fn)}) => fn()
        | _ => ()
        }
      } else {
        Console.log(`   ${Zekr__Colors.skip("○")} ${Zekr__Colors.skip(testCase.name)} ${Zekr__Colors.dimmed("(skipped)")}`)
        suiteSkipped := suiteSkipped.contents + 1
        totalSkipped := totalSkipped.contents + 1
      }
    })

    // Run afterAll hook if present
    switch testSuite.hooks {
    | Some({afterAll: Some(fn)}) => fn()
    | _ => ()
    }

    let skipMsg = if suiteSkipped.contents > 0 {
      `, ${Zekr__Colors.skip(Int.toString(suiteSkipped.contents) ++ " skipped")}`
    } else {
      ""
    }
    Console.log(
      `  ${Zekr__Colors.pass(Int.toString(suitePassed.contents) ++ " passed")}, ${Zekr__Colors.fail(Int.toString(suiteFailed.contents) ++ " failed")}${skipMsg}`,
    )
  })

  Console.log("\n" ++ Zekr__Colors.dimmed(String.repeat("=", 50)))
  let totalSkipMsg = if totalSkipped.contents > 0 {
    `, ${Zekr__Colors.skip(Int.toString(totalSkipped.contents) ++ " skipped")}`
  } else {
    ""
  }
  Console.log(
    `Total: ${Zekr__Colors.pass(Int.toString(totalPassed.contents) ++ " passed")}, ${Zekr__Colors.fail(Int.toString(totalFailed.contents) ++ " failed")}${totalSkipMsg}`,
  )

  if totalFailed.contents > 0 {
    Console.log(Zekr__Colors.fail(" Some tests failed\n"))
    %raw(`process.exit(1)`)
  } else {
    Console.log(Zekr__Colors.pass(" All tests passed!\n"))
    %raw(`process.exit(0)`)
  }
}

// Helper to run async test with timeout and error handling
let runWithTimeout = async (
  run: unit => promise<testResult>,
  timeout: option<int>,
): testResult => {
  let testPromise = async () => {
    try {
      await run()
    } catch {
    | exn =>
      let message = switch exn {
      | Exn.Error(err) =>
        switch Exn.message(err) {
        | Some(msg) => msg
        | None => "Unknown error"
        }
      | _ => "Test threw an exception"
      }
      Fail(`Test threw an exception: ${message}`)
    }
  }

  switch timeout {
  | None => await testPromise()
  | Some(ms) => {
      let timeoutPromise: promise<testResult> = Promise.make((resolve, _reject) => {
        let _ = setTimeout(() => {
          resolve(Fail(`Test timed out after ${Int.toString(ms)}ms`))
        }, ms)
      })
      await Promise.race([testPromise(), timeoutPromise])
    }
  }
}

let runAsyncSuite = async (asyncSuite: asyncTestSuite): unit => {
  Console.log(`\n ${Zekr__Colors.suite(`Running async test suite: ${asyncSuite.name}`)}`)
  Console.log(Zekr__Colors.dimmed("=" ++ String.repeat("-", String.length(asyncSuite.name) + 29)))

  let passed = ref(0)
  let failed = ref(0)
  let skipped = ref(0)

  // Run beforeAll hook if present
  switch asyncSuite.hooks {
  | Some({beforeAll: Some(fn)}) => await fn()
  | _ => ()
  }

  // Check if there are any "Only" tests
  let hasOnly = asyncSuite.tests->Array.some(tc => tc.mode == Only)

  for i in 0 to Array.length(asyncSuite.tests) - 1 {
    let testCase = asyncSuite.tests->Array.getUnsafe(i)

    // Determine if this test should run
    let shouldRun = switch testCase.mode {
    | Skip => false
    | Only => true
    | Normal => !hasOnly
    }

    if shouldRun {
      // Run beforeEach hook if present
      switch asyncSuite.hooks {
      | Some({beforeEach: Some(fn)}) => await fn()
      | _ => ()
      }

      let result = await runWithTimeout(testCase.run, testCase.timeout)
      switch result {
      | Pass => {
          Console.log(`  ${Zekr__Colors.pass("✓")} ${testCase.name}`)
          passed := passed.contents + 1
        }
      | Fail(message) => {
          Console.log(`  ${Zekr__Colors.fail("✗")} ${testCase.name}`)
          Console.log(`    ${Zekr__Colors.fail(message)}`)
          failed := failed.contents + 1
        }
      }

      // Run afterEach hook if present
      switch asyncSuite.hooks {
      | Some({afterEach: Some(fn)}) => await fn()
      | _ => ()
      }
    } else {
      Console.log(`  ${Zekr__Colors.skip("○")} ${Zekr__Colors.skip(testCase.name)} ${Zekr__Colors.dimmed("(skipped)")}`)
      skipped := skipped.contents + 1
    }
  }

  // Run afterAll hook if present
  switch asyncSuite.hooks {
  | Some({afterAll: Some(fn)}) => await fn()
  | _ => ()
  }

  Console.log("")
  let skipMsg = if skipped.contents > 0 {
    `, ${Zekr__Colors.skip(Int.toString(skipped.contents) ++ " skipped")}`
  } else {
    ""
  }
  Console.log(
    `Results: ${Zekr__Colors.pass(Int.toString(passed.contents) ++ " passed")}, ${Zekr__Colors.fail(Int.toString(failed.contents) ++ " failed")}${skipMsg}`,
  )

  if failed.contents > 0 {
    Console.log(Zekr__Colors.fail(" Some tests failed"))
  } else {
    Console.log(Zekr__Colors.pass(" All tests passed!"))
  }
}

let runAsyncSuites = async (suites: array<asyncTestSuite>): unit => {
  Console.log(`\n ${Zekr__Colors.suite("Running all async test suites")}`)
  Console.log(Zekr__Colors.dimmed("==============================\n"))

  let totalPassed = ref(0)
  let totalFailed = ref(0)
  let totalSkipped = ref(0)

  // Check if there are any "Only" tests across all suites
  let hasOnly = suites->Array.some(s => s.tests->Array.some(tc => tc.mode == Only))

  for i in 0 to Array.length(suites) - 1 {
    let asyncSuite = suites->Array.getUnsafe(i)
    Console.log(`\n ${Zekr__Colors.suite(asyncSuite.name)}`)
    Console.log(Zekr__Colors.dimmed("-" ++ String.repeat("-", String.length(asyncSuite.name) + 3)))

    // Run beforeAll hook if present
    switch asyncSuite.hooks {
    | Some({beforeAll: Some(fn)}) => await fn()
    | _ => ()
    }

    let suitePassed = ref(0)
    let suiteFailed = ref(0)
    let suiteSkipped = ref(0)

    for j in 0 to Array.length(asyncSuite.tests) - 1 {
      let testCase = asyncSuite.tests->Array.getUnsafe(j)

      // Determine if this test should run
      let shouldRun = switch testCase.mode {
      | Skip => false
      | Only => true
      | Normal => !hasOnly
      }

      if shouldRun {
        // Run beforeEach hook if present
        switch asyncSuite.hooks {
        | Some({beforeEach: Some(fn)}) => await fn()
        | _ => ()
        }

        let result = await runWithTimeout(testCase.run, testCase.timeout)
        switch result {
        | Pass => {
            Console.log(`   ${Zekr__Colors.pass("✓")} ${testCase.name}`)
            suitePassed := suitePassed.contents + 1
            totalPassed := totalPassed.contents + 1
          }
        | Fail(message) => {
            Console.log(`   ${Zekr__Colors.fail("✗")} ${testCase.name}`)
            Console.log(`     ${Zekr__Colors.fail(message)}`)
            suiteFailed := suiteFailed.contents + 1
            totalFailed := totalFailed.contents + 1
          }
        }

        // Run afterEach hook if present
        switch asyncSuite.hooks {
        | Some({afterEach: Some(fn)}) => await fn()
        | _ => ()
        }
      } else {
        Console.log(`   ${Zekr__Colors.skip("○")} ${Zekr__Colors.skip(testCase.name)} ${Zekr__Colors.dimmed("(skipped)")}`)
        suiteSkipped := suiteSkipped.contents + 1
        totalSkipped := totalSkipped.contents + 1
      }
    }

    // Run afterAll hook if present
    switch asyncSuite.hooks {
    | Some({afterAll: Some(fn)}) => await fn()
    | _ => ()
    }

    let skipMsg = if suiteSkipped.contents > 0 {
      `, ${Zekr__Colors.skip(Int.toString(suiteSkipped.contents) ++ " skipped")}`
    } else {
      ""
    }
    Console.log(
      `  ${Zekr__Colors.pass(Int.toString(suitePassed.contents) ++ " passed")}, ${Zekr__Colors.fail(Int.toString(suiteFailed.contents) ++ " failed")}${skipMsg}`,
    )
  }

  Console.log("\n" ++ Zekr__Colors.dimmed(String.repeat("=", 50)))
  let totalSkipMsg = if totalSkipped.contents > 0 {
    `, ${Zekr__Colors.skip(Int.toString(totalSkipped.contents) ++ " skipped")}`
  } else {
    ""
  }
  Console.log(
    `Total: ${Zekr__Colors.pass(Int.toString(totalPassed.contents) ++ " passed")}, ${Zekr__Colors.fail(Int.toString(totalFailed.contents) ++ " failed")}${totalSkipMsg}`,
  )

  if totalFailed.contents > 0 {
    Console.log(Zekr__Colors.fail(" Some tests failed\n"))
    %raw(`process.exit(1)`)
  } else {
    Console.log(Zekr__Colors.pass(" All tests passed!\n"))
    %raw(`process.exit(0)`)
  }
}
