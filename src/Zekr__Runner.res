// Zekr__Runner - Test execution and reporting

open Zekr__Types

// Environment variable access for test filtering
@val @scope("process") external env: Dict.t<string> = "env"

let getEnvVar = (name: string): option<string> => {
  env->Dict.get(name)
}

// Test filtering configuration
let filterPattern = ref(None: option<string>)
let skipPattern = ref(None: option<string>)

let setFilterPattern = (pattern: option<string>): unit => {
  filterPattern := pattern
}

let setSkipPattern = (pattern: option<string>): unit => {
  skipPattern := pattern
}

let initFilterFromEnv = (): unit => {
  filterPattern := getEnvVar("ZEKR_FILTER")
  skipPattern := getEnvVar("ZEKR_SKIP")
}

let matchesPattern = (name: string, pattern: string): bool => {
  let lowerName = String.toLowerCase(name)
  let lowerPattern = String.toLowerCase(pattern)
  String.includes(lowerName, lowerPattern)
}

let shouldRunTest = (suiteName: string, testName: string): bool => {
  let fullName = suiteName ++ " " ++ testName

  let skipped = switch skipPattern.contents {
  | Some(pattern) => matchesPattern(fullName, pattern)
  | None => false
  }

  if skipped {
    false
  } else {
    switch filterPattern.contents {
    | Some(pattern) => matchesPattern(fullName, pattern)
    | None => true
    }
  }
}

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
  // Initialize filter patterns from environment
  initFilterFromEnv()

  Console.log(`\n ${Zekr__Colors.suite("Running all test suites")}`)
  Console.log(Zekr__Colors.dimmed("========================\n"))

  // Show active filters
  switch filterPattern.contents {
  | Some(p) => Console.log(Zekr__Colors.dimmed(`Filter: "${p}"`))
  | None => ()
  }
  switch skipPattern.contents {
  | Some(p) => Console.log(Zekr__Colors.dimmed(`Skip: "${p}"`))
  | None => ()
  }

  let totalPassed = ref(0)
  let totalFailed = ref(0)
  let totalSkipped = ref(0)
  let totalFiltered = ref(0)

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
      // Check filter first
      let passesFilter = shouldRunTest(testSuite.name, testCase.name)

      // Determine if this test should run based on mode
      let shouldRunByMode = switch testCase.mode {
      | Skip => false
      | Only => true
      | Normal => !hasOnly
      }

      let shouldRun = passesFilter && shouldRunByMode

      if !passesFilter {
        totalFiltered := totalFiltered.contents + 1
      } else if shouldRun {
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
  let totalFilterMsg = if totalFiltered.contents > 0 {
    `, ${Zekr__Colors.dimmed(Int.toString(totalFiltered.contents) ++ " filtered")}`
  } else {
    ""
  }
  Console.log(
    `Total: ${Zekr__Colors.pass(Int.toString(totalPassed.contents) ++ " passed")}, ${Zekr__Colors.fail(Int.toString(totalFailed.contents) ++ " failed")}${totalSkipMsg}${totalFilterMsg}`,
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
  // Initialize filter patterns from environment
  initFilterFromEnv()

  Console.log(`\n ${Zekr__Colors.suite("Running all async test suites")}`)
  Console.log(Zekr__Colors.dimmed("==============================\n"))

  // Show active filters
  switch filterPattern.contents {
  | Some(p) => Console.log(Zekr__Colors.dimmed(`Filter: "${p}"`))
  | None => ()
  }
  switch skipPattern.contents {
  | Some(p) => Console.log(Zekr__Colors.dimmed(`Skip: "${p}"`))
  | None => ()
  }

  let totalPassed = ref(0)
  let totalFailed = ref(0)
  let totalSkipped = ref(0)
  let totalFiltered = ref(0)

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

      // Check filter first
      let passesFilter = shouldRunTest(asyncSuite.name, testCase.name)

      // Determine if this test should run based on mode
      let shouldRunByMode = switch testCase.mode {
      | Skip => false
      | Only => true
      | Normal => !hasOnly
      }

      let shouldRun = passesFilter && shouldRunByMode

      if !passesFilter {
        totalFiltered := totalFiltered.contents + 1
      } else if shouldRun {
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
  let totalFilterMsg = if totalFiltered.contents > 0 {
    `, ${Zekr__Colors.dimmed(Int.toString(totalFiltered.contents) ++ " filtered")}`
  } else {
    ""
  }
  Console.log(
    `Total: ${Zekr__Colors.pass(Int.toString(totalPassed.contents) ++ " passed")}, ${Zekr__Colors.fail(Int.toString(totalFailed.contents) ++ " failed")}${totalSkipMsg}${totalFilterMsg}`,
  )

  if totalFailed.contents > 0 {
    Console.log(Zekr__Colors.fail(" Some tests failed\n"))
    %raw(`process.exit(1)`)
  } else {
    Console.log(Zekr__Colors.pass(" All tests passed!\n"))
    %raw(`process.exit(0)`)
  }
}

// Watch mode
module NodeChildProcess = {
  type spawnResult = {status: Nullable.t<int>}
  @module("child_process")
  external spawnSync: (string, array<string>, {"stdio": string}) => spawnResult = "spawnSync"
}

let watchMode = (
  ~testCommand: string,
  ~watchPaths: array<string>,
  ~buildCommand: option<string>=?,
): unit => {
  let lastRun = ref(Date.now())
  let debounceMs = 100.0

  let runTests = () => {
    Console.log("\n" ++ Zekr__Colors.dimmed(String.repeat("=", 50)))
    Console.log(Zekr__Colors.suite(" File change detected, re-running tests..."))
    Console.log(Zekr__Colors.dimmed(String.repeat("=", 50)))

    // Run build command if provided
    switch buildCommand {
    | Some(cmd) => {
        let parts = cmd->String.split(" ")
        let command = parts->Array.get(0)->Option.getOr("echo")
        let args = parts->Array.sliceToEnd(~start=1)
        let _ = NodeChildProcess.spawnSync(command, args, {"stdio": "inherit"})
      }
    | None => ()
    }

    // Run test command
    let parts = testCommand->String.split(" ")
    let command = parts->Array.get(0)->Option.getOr("node")
    let args = parts->Array.sliceToEnd(~start=1)
    let _ = NodeChildProcess.spawnSync(command, args, {"stdio": "inherit"})
  }

  let onChange = (_eventType: string, _filename: string) => {
    let now = Date.now()
    if now -. lastRun.contents > debounceMs {
      lastRun := now
      runTests()
    }
  }

  Console.log(Zekr__Colors.suite("\n Watch mode started"))
  Console.log(Zekr__Colors.dimmed(" Watching for file changes..."))
  Console.log(Zekr__Colors.dimmed(" Paths: " ++ watchPaths->Array.join(", ")))
  Console.log(Zekr__Colors.dimmed(" Press Ctrl+C to stop\n"))

  // Initial test run
  runTests()

  // Watch each path
  watchPaths->Array.forEach(path => {
    if Zekr__Snapshot.NodeFs.existsSync(path) {
      Zekr__Snapshot.NodeFs.watch(path, {"recursive": true}, onChange)
    } else {
      Console.log(Zekr__Colors.fail(" Warning: Path \"" ++ path ++ "\" does not exist"))
    }
  })
}
