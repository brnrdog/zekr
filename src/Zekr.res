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
  let skip = text => `${yellow}${text}${reset}`
  let suite = text => `${cyan}${bold}${text}${reset}`
  let dimmed = text => `${dim}${text}${reset}`
}

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

let test = (name: string, run: unit => testResult): testCase => {
  {name, run, mode: Normal}
}

let testSkip = (name: string, run: unit => testResult): testCase => {
  {name, run, mode: Skip}
}

let testOnly = (name: string, run: unit => testResult): testCase => {
  {name, run, mode: Only}
}

let asyncTest = (name: string, run: unit => promise<testResult>): asyncTestCase => {
  {name, run, mode: Normal}
}

let asyncTestSkip = (name: string, run: unit => promise<testResult>): asyncTestCase => {
  {name, run, mode: Skip}
}

let asyncTestOnly = (name: string, run: unit => promise<testResult>): asyncTestCase => {
  {name, run, mode: Only}
}

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

let assertEqual = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual == expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None =>
      `Assertion failed\n` ++
      `       ${Colors.pass("+ expected")} ${Colors.fail("- actual")}\n` ++
      `       ${Colors.fail("- " ++ String.make(actual))}\n` ++
      `       ${Colors.pass("+ " ++ String.make(expected))}`
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
    | None =>
      `Assertion failed: values should not be equal\n` ++
      `       Both values: ${String.make(actual)}`
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
    | None =>
      `Assertion failed: expected actual > threshold\n` ++
      `       actual:    ${String.make(actual)}\n` ++
      `       threshold: ${String.make(expected)}`
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
    | None =>
      `Assertion failed: expected actual < threshold\n` ++
      `       actual:    ${String.make(actual)}\n` ++
      `       threshold: ${String.make(expected)}`
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
    | None =>
      `Assertion failed: expected actual >= threshold\n` ++
      `       actual:    ${String.make(actual)}\n` ++
      `       threshold: ${String.make(expected)}`
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
    | None =>
      `Assertion failed: expected actual <= threshold\n` ++
      `       actual:    ${String.make(actual)}\n` ++
      `       threshold: ${String.make(expected)}`
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
    | None =>
      `Assertion failed: string does not contain substring\n` ++
      `       string:    "${haystack}"\n` ++
      `       expected:  "${needle}"`
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
    | None =>
      `Assertion failed: array does not contain item\n` ++
      `       expected to contain: ${String.make(item)}`
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

// Node.js file system bindings for snapshot testing
module NodeFs = {
  @module("fs") external existsSync: string => bool = "existsSync"
  @module("fs") external readFileSync: (string, string) => string = "readFileSync"
  @module("fs") external writeFileSync: (string, string) => unit = "writeFileSync"
  @module("fs") external mkdirSync: (string, {"recursive": bool}) => unit = "mkdirSync"
}

module NodePath = {
  @module("path") external dirname: string => string = "dirname"
  @module("path") external join: (string, string) => string = "join"
}

// Snapshot testing
let snapshotDir = ref("__snapshots__")

let setSnapshotDir = (dir: string): unit => {
  snapshotDir := dir
}

let assertMatchesSnapshot = (
  value: 'a,
  ~name: string,
  ~snapshotPath: option<string>=?,
): testResult => {
  let serialized = JSON.stringifyAny(value)->Option.getOr("undefined")
  let formatted = try {
    let parsed = JSON.parseExn(serialized)
    JSON.stringifyWithIndent(parsed, 2)
  } catch {
  | _ => serialized
  }

  let dir = switch snapshotPath {
  | Some(p) => p
  | None => snapshotDir.contents
  }

  // Ensure snapshot directory exists
  if !NodeFs.existsSync(dir) {
    NodeFs.mkdirSync(dir, {"recursive": true})
  }

  let snapshotFile = NodePath.join(dir, name ++ ".snap")

  if NodeFs.existsSync(snapshotFile) {
    let existing = NodeFs.readFileSync(snapshotFile, "utf8")
    if existing == formatted {
      Pass
    } else {
      Fail(
        `Snapshot mismatch for "${name}"\n` ++
        `       ${Colors.pass("+ expected")} ${Colors.fail("- actual")}\n` ++
        `       ${Colors.fail("- " ++ formatted)}\n` ++
        `       ${Colors.pass("+ " ++ existing)}`,
      )
    }
  } else {
    // Create new snapshot
    NodeFs.writeFileSync(snapshotFile, formatted)
    Pass
  }
}

let updateSnapshot = (value: 'a, ~name: string, ~snapshotPath: option<string>=?): unit => {
  let serialized = JSON.stringifyAny(value)->Option.getOr("undefined")
  let formatted = try {
    let parsed = JSON.parseExn(serialized)
    JSON.stringifyWithIndent(parsed, 2)
  } catch {
  | _ => serialized
  }

  let dir = switch snapshotPath {
  | Some(p) => p
  | None => snapshotDir.contents
  }

  if !NodeFs.existsSync(dir) {
    NodeFs.mkdirSync(dir, {"recursive": true})
  }

  let snapshotFile = NodePath.join(dir, name ++ ".snap")
  NodeFs.writeFileSync(snapshotFile, formatted)
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
          Console.log(`  ${Colors.pass("✓")} ${testCase.name}`)
          passed := passed.contents + 1
        }
      | Fail(message) => {
          Console.log(`  ${Colors.fail("✗")} ${testCase.name}`)
          Console.log(`    ${Colors.fail(message)}`)
          failed := failed.contents + 1
        }
      }

      // Run afterEach hook if present
      switch testSuite.hooks {
      | Some({afterEach: Some(fn)}) => fn()
      | _ => ()
      }
    } else {
      Console.log(`  ${Colors.skip("○")} ${Colors.skip(testCase.name)} ${Colors.dimmed("(skipped)")}`)
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
    `, ${Colors.skip(Int.toString(skipped.contents) ++ " skipped")}`
  } else {
    ""
  }
  Console.log(
    `Results: ${Colors.pass(Int.toString(passed.contents) ++ " passed")}, ${Colors.fail(Int.toString(failed.contents) ++ " failed")}${skipMsg}`,
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
  let totalSkipped = ref(0)

  // Check if there are any "Only" tests across all suites
  let hasOnly = suites->Array.some(s => s.tests->Array.some(tc => tc.mode == Only))

  suites->Array.forEach(testSuite => {
    Console.log(`\n ${Colors.suite(testSuite.name)}`)
    Console.log(Colors.dimmed("-" ++ String.repeat("-", String.length(testSuite.name) + 3)))

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

        // Run afterEach hook if present
        switch testSuite.hooks {
        | Some({afterEach: Some(fn)}) => fn()
        | _ => ()
        }
      } else {
        Console.log(`   ${Colors.skip("○")} ${Colors.skip(testCase.name)} ${Colors.dimmed("(skipped)")}`)
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
      `, ${Colors.skip(Int.toString(suiteSkipped.contents) ++ " skipped")}`
    } else {
      ""
    }
    Console.log(
      `  ${Colors.pass(Int.toString(suitePassed.contents) ++ " passed")}, ${Colors.fail(Int.toString(suiteFailed.contents) ++ " failed")}${skipMsg}`,
    )
  })

  Console.log("\n" ++ Colors.dimmed(String.repeat("=", 50)))
  let totalSkipMsg = if totalSkipped.contents > 0 {
    `, ${Colors.skip(Int.toString(totalSkipped.contents) ++ " skipped")}`
  } else {
    ""
  }
  Console.log(
    `Total: ${Colors.pass(Int.toString(totalPassed.contents) ++ " passed")}, ${Colors.fail(Int.toString(totalFailed.contents) ++ " failed")}${totalSkipMsg}`,
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

      // Run afterEach hook if present
      switch asyncSuite.hooks {
      | Some({afterEach: Some(fn)}) => await fn()
      | _ => ()
      }
    } else {
      Console.log(`  ${Colors.skip("○")} ${Colors.skip(testCase.name)} ${Colors.dimmed("(skipped)")}`)
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
    `, ${Colors.skip(Int.toString(skipped.contents) ++ " skipped")}`
  } else {
    ""
  }
  Console.log(
    `Results: ${Colors.pass(Int.toString(passed.contents) ++ " passed")}, ${Colors.fail(Int.toString(failed.contents) ++ " failed")}${skipMsg}`,
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
  let totalSkipped = ref(0)

  // Check if there are any "Only" tests across all suites
  let hasOnly = suites->Array.some(s => s.tests->Array.some(tc => tc.mode == Only))

  for i in 0 to Array.length(suites) - 1 {
    let asyncSuite = suites->Array.getUnsafe(i)
    Console.log(`\n ${Colors.suite(asyncSuite.name)}`)
    Console.log(Colors.dimmed("-" ++ String.repeat("-", String.length(asyncSuite.name) + 3)))

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

        // Run afterEach hook if present
        switch asyncSuite.hooks {
        | Some({afterEach: Some(fn)}) => await fn()
        | _ => ()
        }
      } else {
        Console.log(`   ${Colors.skip("○")} ${Colors.skip(testCase.name)} ${Colors.dimmed("(skipped)")}`)
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
      `, ${Colors.skip(Int.toString(suiteSkipped.contents) ++ " skipped")}`
    } else {
      ""
    }
    Console.log(
      `  ${Colors.pass(Int.toString(suitePassed.contents) ++ " passed")}, ${Colors.fail(Int.toString(suiteFailed.contents) ++ " failed")}${skipMsg}`,
    )
  }

  Console.log("\n" ++ Colors.dimmed(String.repeat("=", 50)))
  let totalSkipMsg = if totalSkipped.contents > 0 {
    `, ${Colors.skip(Int.toString(totalSkipped.contents) ++ " skipped")}`
  } else {
    ""
  }
  Console.log(
    `Total: ${Colors.pass(Int.toString(totalPassed.contents) ++ " passed")}, ${Colors.fail(Int.toString(totalFailed.contents) ++ " failed")}${totalSkipMsg}`,
  )

  if totalFailed.contents > 0 {
    Console.log(Colors.fail(" Some tests failed\n"))
    %raw(`process.exit(1)`)
  } else {
    Console.log(Colors.pass(" All tests passed!\n"))
    %raw(`process.exit(0)`)
  }
}
