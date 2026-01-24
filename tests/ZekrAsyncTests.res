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

let _ = runAsyncSuites([asyncTestTests, combineAsyncResultsTests])
