open Types

module HarnessFs = {
  @module("fs") external mkdirSync: (string, {"recursive": bool}) => unit = "mkdirSync"
  @module("fs") external writeFileSync: (string, string) => unit = "writeFileSync"
  @module("fs") external rmSync: (string, {"recursive": bool, "force": bool}) => unit = "rmSync"
  @module("path") external join: (string, string) => string = "join"
}

module HarnessProc = {
  type spawnResult = {status: Nullable.t<int>}
  @module("child_process")
  external spawnSync: (string, array<string>, {"stdio": string}) => spawnResult = "spawnSync"
}

let passingFixture = `import { make } from "../src/Suite.js";
import { make as testMake } from "../src/Test.js";
import { isTrue } from "../src/Assert.js";
make("Harness pass", [testMake("ok", () => isTrue(true, undefined))]);
`

let failingFixture = `import { make } from "../src/Suite.js";
import { make as testMake } from "../src/Test.js";
import { isTrue } from "../src/Assert.js";
make("Harness fail", [testMake("bad", () => isTrue(false, undefined))]);
`

let spawnHarness = (fixturePath: string): int => {
  let result = HarnessProc.spawnSync("node", [Cli.harnessPath, fixturePath], {"stdio": "ignore"})
  result.status->Nullable.toOption->Option.getOr(1)
}

type nodeUrl

// resolveRunnerUrl(testFile, baseUrl, exists) picks the Runner module whose
// compiled suffix matches the test file, so both share one Registry instance.
@module("../bin/resolve-runner.mjs")
external resolveRunnerUrl: (string, string, nodeUrl => bool) => string = "resolveRunnerUrl"

let harnessBase = "file:///pkg/bin/zekr-run.mjs"

let resolveRunnerUrlTests = Suite.make(
  "zekr-run resolveRunnerUrl",
  [
    Test.make("loads the suffix-matched Runner for .res.mjs test files", () => {
      let url = resolveRunnerUrl("tests/Foo.test.res.mjs", harnessBase, _ => true)
      Assert.isTrue(String.endsWith(url, "src/Runner.res.mjs"))
    }),
    Test.make("prefers .res.mjs over the shorter .mjs suffix", () => {
      // A .res.mjs file also ends with .mjs; the more specific match must win.
      let url = resolveRunnerUrl("tests/Foo.test.res.mjs", harnessBase, _ => true)
      Assert.isFalse(String.endsWith(url, "src/Runner.mjs"))
    }),
    Test.make("matches .bs.js test files to Runner.bs.js", () => {
      let url = resolveRunnerUrl("tests/Foo.test.bs.js", harnessBase, _ => true)
      Assert.isTrue(String.endsWith(url, "src/Runner.bs.js"))
    }),
    Test.make("uses Runner.js for plain .js test files", () => {
      let url = resolveRunnerUrl("tests/Foo.test.js", harnessBase, _ => true)
      Assert.isTrue(String.endsWith(url, "src/Runner.js"))
    }),
    Test.make("falls back to Runner.js when the suffix-matched Runner is absent", () => {
      let url = resolveRunnerUrl("tests/Foo.test.res.mjs", harnessBase, _ => false)
      Assert.isTrue(String.endsWith(url, "src/Runner.js"))
    }),
  ],
)

let harnessTests = Suite.make(
  "zekr-run harness",
  [
    Test.make("runs a registered passing suite and exits 0", () => {
      let root = HarnessFs.join(".", ".tmp_harness_pass")
      HarnessFs.rmSync(root, {"recursive": true, "force": true})
      HarnessFs.mkdirSync(root, {"recursive": true})
      let fixture = HarnessFs.join(root, "pass.mjs")
      HarnessFs.writeFileSync(fixture, passingFixture)
      let code = spawnHarness(fixture)
      HarnessFs.rmSync(root, {"recursive": true, "force": true})
      if code == 0 {
        Pass
      } else {
        Fail("Expected exit 0 for a passing registered suite, got " ++ Int.toString(code))
      }
    }),
    Test.make("runs a registered failing suite and exits 1", () => {
      let root = HarnessFs.join(".", ".tmp_harness_fail")
      HarnessFs.rmSync(root, {"recursive": true, "force": true})
      HarnessFs.mkdirSync(root, {"recursive": true})
      let fixture = HarnessFs.join(root, "fail.mjs")
      HarnessFs.writeFileSync(fixture, failingFixture)
      let code = spawnHarness(fixture)
      HarnessFs.rmSync(root, {"recursive": true, "force": true})
      if code == 1 {
        Pass
      } else {
        Fail("Expected exit 1 for a failing registered suite, got " ++ Int.toString(code))
      }
    }),
  ],
)

