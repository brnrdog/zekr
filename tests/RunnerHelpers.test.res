open Types

let syncHelperTests = Suite.make(
  "Runner accumulate helpers (sync)",
  [
    Test.make("runSuiteAccumulate counts pass, fail, and skip", () => {
      Runner.setFilterPattern(None)
      Runner.setSkipPattern(None)
      let suite: testSuite = {
        name: "Sample",
        tests: [
          {name: "p", run: () => Pass, mode: Normal},
          {name: "f", run: () => Fail("boom"), mode: Normal},
          {name: "s", run: () => Pass, mode: Skip},
        ],
        hooks: None,
      }
      let (passed, failed, skipped, filtered) = Runner.runSuiteAccumulate(suite, ~hasOnly=false)
      if passed == 1 && failed == 1 && skipped == 1 && filtered == 0 {
        Pass
      } else {
        Fail("Expected (1,1,1,0)")
      }
    }),
  ],
)

let asyncHelperTests = Suite.async(
  "Runner accumulate helpers (async)",
  [
    Test.async("runAsyncSuiteAccumulate counts pass and fail", async () => {
      Runner.setFilterPattern(None)
      Runner.setSkipPattern(None)
      let suite: asyncTestSuite = {
        name: "SampleAsync",
        tests: [
          {name: "p", run: async () => Pass, mode: Normal, timeout: None},
          {name: "f", run: async () => Fail("boom"), mode: Normal, timeout: None},
        ],
        hooks: None,
      }
      let (passed, failed, skipped, filtered) = await Runner.runAsyncSuiteAccumulate(
        suite,
        ~hasOnly=false,
      )
      if passed == 1 && failed == 1 && skipped == 0 && filtered == 0 {
        Pass
      } else {
        Fail("Expected (1,1,0,0)")
      }
    }),
  ],
)

