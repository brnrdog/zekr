// Registry - internal global store of suites registered by Suite.make/async.
// NOT re-exported from the Zekr.js barrel — implementation detail of auto-run.

open Types

let syncSuites: ref<array<testSuite>> = ref([])
let asyncSuites: ref<array<asyncTestSuite>> = ref([])

let register = (suite: testSuite): unit => {
  syncSuites := syncSuites.contents->Array.concat([suite])
}

let registerAsync = (suite: asyncTestSuite): unit => {
  asyncSuites := asyncSuites.contents->Array.concat([suite])
}

let snapshot = (): (array<testSuite>, array<asyncTestSuite>) => {
  (syncSuites.contents, asyncSuites.contents)
}

let clear = (): unit => {
  syncSuites := []
  asyncSuites := []
}
