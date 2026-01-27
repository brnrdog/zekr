open Zekr

// Helper to simulate async operation
let delay = (ms: int) => {
  Promise.make((resolve, _reject) => {
    let _ = setTimeout(() => resolve(), ms)
    ()
  })
}

let asyncTestTests = asyncSuite("asyncTest", [
  asyncTest("passes for async operations that succeed", async () => {
    let _ = await delay(10)
    Pass
  }),
  asyncTest("fails for async operations that fail", async () => {
    let _ = await delay(10)
    let result = Fail("async failure")
    switch result {
    | Fail(_) => Pass
    | Pass => Fail("Expected Fail")
    }
  }),
])

let combineAsyncResultsTests = asyncSuite("combineAsyncResults", [
  asyncTest("returns Pass when all async results pass", async () => {
    let result = await combineAsyncResults([
      Promise.resolve(Pass),
      Promise.resolve(Pass),
      Promise.resolve(Pass),
    ])
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
  asyncTest("returns first Fail when any async result fails", async () => {
    let result = await combineAsyncResults([
      Promise.resolve(Pass),
      Promise.resolve(Fail("first")),
      Promise.resolve(Fail("second")),
    ])
    switch result {
    | Fail("first") => Pass
    | Fail(_) => Fail("Expected first failure message")
    | Pass => Fail("Expected Fail")
    }
  }),
  asyncTest("handles delayed results correctly", async () => {
    let delayedPass = async () => {
      let _ = await delay(10)
      Pass
    }
    let result = await combineAsyncResults([delayedPass(), Promise.resolve(Pass)])
    switch result {
    | Pass => Pass
    | Fail(_) => Fail("Expected Pass")
    }
  }),
])

// Track hook execution for verification
let hookLog: ref<array<string>> = ref([])

let asyncHooksTests = asyncSuite(
  "asyncSuite hooks execution",
  [
    asyncTest("first test sees beforeAll and beforeEach ran", async () => {
      let _ = await delay(5)
      // At this point beforeAll and beforeEach should have run
      let log = hookLog.contents
      if Array.includes(log, "beforeAll") && Array.includes(log, "beforeEach") {
        Pass
      } else {
        Fail(`Expected beforeAll and beforeEach in log, got: ${String.make(log)}`)
      }
    }),
    asyncTest("second test sees beforeEach ran again", async () => {
      let _ = await delay(5)
      // Count beforeEach occurrences
      let beforeEachCount =
        hookLog.contents->Array.filter(s => s == "beforeEach")->Array.length
      if beforeEachCount >= 2 {
        Pass
      } else {
        Fail(`Expected at least 2 beforeEach calls, got ${Int.toString(beforeEachCount)}`)
      }
    }),
  ],
  ~beforeAll=async () => {
    let _ = await delay(5)
    hookLog := Array.concat(hookLog.contents, ["beforeAll"])
  },
  ~afterAll=async () => {
    let _ = await delay(5)
    hookLog := Array.concat(hookLog.contents, ["afterAll"])
  },
  ~beforeEach=async () => {
    let _ = await delay(5)
    hookLog := Array.concat(hookLog.contents, ["beforeEach"])
  },
  ~afterEach=async () => {
    let _ = await delay(5)
    hookLog := Array.concat(hookLog.contents, ["afterEach"])
  },
)

let timeoutTests = asyncSuite("timeout and error handling", [
  asyncTest(
    "test passes within timeout",
    async () => {
      let _ = await delay(10)
      Pass
    },
    ~timeout=100,
  ),
  asyncTest(
    "test fails when exceeding timeout",
    async () => {
      // This tests that our timeout mechanism works
      // We create a test that would timeout, run it manually, and verify the result
      let slowTest = async () => {
        let _ = await delay(200)
        Pass
      }
      let result = await runWithTimeout(slowTest, Some(50))
      switch result {
      | Fail(msg) if String.includes(msg, "timed out") => Pass
      | _ => Fail("Expected timeout failure")
      }
    },
  ),
  asyncTest(
    "catches exceptions and returns Fail",
    async () => {
      let throwingTest = async () => {
        let _ = throw(Exn.raiseError("Test error"))
        Pass
      }
      let result = await runWithTimeout(throwingTest, None)
      switch result {
      | Fail(msg) if String.includes(msg, "exception") => Pass
      | _ => Fail("Expected exception to be caught")
      }
    },
  ),
])

let _ = runAsyncSuites([asyncTestTests, combineAsyncResultsTests, asyncHooksTests, timeoutTests])
