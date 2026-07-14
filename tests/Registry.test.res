open Types

let emptySuite = (name: string): testSuite => {name, tests: [], hooks: None}
let emptyAsyncSuite = (name: string): asyncTestSuite => {name, tests: [], hooks: None}

let registryTests = Suite.make(
  "Registry",
  [
    Test.make("register then snapshot returns the sync suite", () => {
      Registry.clear()
      Registry.register(emptySuite("A"))
      let (sync, async) = Registry.snapshot()
      if Array.length(sync) == 1 && Array.length(async) == 0 {
        Pass
      } else {
        Fail("Expected one sync suite, no async suites")
      }
    }),
    Test.make("registerAsync then snapshot returns the async suite", () => {
      Registry.clear()
      Registry.registerAsync(emptyAsyncSuite("A"))
      let (sync, async) = Registry.snapshot()
      if Array.length(sync) == 0 && Array.length(async) == 1 {
        Pass
      } else {
        Fail("Expected no sync suites, one async suite")
      }
    }),
    Test.make("clear empties both lists", () => {
      Registry.register(emptySuite("A"))
      Registry.registerAsync(emptyAsyncSuite("B"))
      Registry.clear()
      let (sync, async) = Registry.snapshot()
      if Array.length(sync) == 0 && Array.length(async) == 0 {
        Pass
      } else {
        Fail("Expected both lists empty after clear")
      }
    }),
    Test.make("snapshot excludes suites registered after the snapshot", () => {
      Registry.clear()
      Registry.register(emptySuite("early"))
      let (sync, _) = Registry.snapshot()
      Registry.register(emptySuite("late"))
      if Array.length(sync) == 1 {
        Pass
      } else {
        Fail("Snapshot must not see suites registered after it was taken")
      }
    }),
  ],
)

