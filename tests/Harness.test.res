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

