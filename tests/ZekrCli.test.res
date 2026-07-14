open Types

module TestFs = {
  @module("fs") external mkdirSync: (string, {"recursive": bool}) => unit = "mkdirSync"
  @module("fs") external writeFileSync: (string, string) => unit = "writeFileSync"
  @module("fs") external rmSync: (string, {"recursive": bool, "force": bool}) => unit = "rmSync"
  @module("path") external join: (string, string) => string = "join"
}

let parseArgsTests = Suite.make(
  "Cli.parseArgs",
  [
    Test.make("defaults to no flags", () => {
      switch Cli.parseArgs([]) {
      | Ok({pattern: None, dir: None, help: false}) => Pass
      | _ => Fail("Expected empty args")
      }
    }),
    Test.make("parses --pattern and --dir", () => {
      switch Cli.parseArgs(["--pattern", ".spec.res", "--dir", "src"]) {
      | Ok({pattern: Some(".spec.res"), dir: Some("src"), help: false}) => Pass
      | _ => Fail("Expected pattern and dir parsed")
      }
    }),
    Test.make("supports -p and -d aliases", () => {
      switch Cli.parseArgs(["-p", ".t.res", "-d", "."]) {
      | Ok({pattern: Some(".t.res"), dir: Some(".")}) => Pass
      | _ => Fail("Expected aliases parsed")
      }
    }),
    Test.make("sets help for --help", () => {
      switch Cli.parseArgs(["--help"]) {
      | Ok({help: true}) => Pass
      | _ => Fail("Expected help true")
      }
    }),
    Test.make("errors on unknown flag", () => {
      switch Cli.parseArgs(["--nope"]) {
      | Error(_) => Pass
      | Ok(_) => Fail("Expected error")
      }
    }),
    Test.make("errors on missing value", () => {
      switch Cli.parseArgs(["--pattern"]) {
      | Error(_) => Pass
      | Ok(_) => Fail("Expected error for missing value")
      }
    }),
  ],
)

let resolveConfigTests = Suite.make(
  "Cli.resolveConfig",
  [
    Test.make("falls back to defaults", () => {
      let cfg = Cli.resolveConfig(
        ~args={pattern: None, dir: None, help: false},
        ~file={pattern: None, dir: None},
      )
      Assert.equal(cfg, {pattern: ".test.res", dir: "."})
    }),
    Test.make("file config overrides defaults", () => {
      let cfg = Cli.resolveConfig(
        ~args={pattern: None, dir: None, help: false},
        ~file={pattern: Some(".spec.res"), dir: Some("src")},
      )
      Assert.equal(cfg, {pattern: ".spec.res", dir: "src"})
    }),
    Test.make("flags override file config", () => {
      let cfg = Cli.resolveConfig(
        ~args={pattern: Some(".a.res"), dir: Some("a"), help: false},
        ~file={pattern: Some(".b.res"), dir: Some("b")},
      )
      Assert.equal(cfg, {pattern: ".a.res", dir: "a"})
    }),
  ],
)

let parseFileConfigTests = Suite.make(
  "Cli.parseFileConfig",
  [
    Test.make("parses pattern and dir", () => {
      switch Cli.parseFileConfig(`{"pattern": ".spec.res", "dir": "src"}`) {
      | Ok({pattern: Some(".spec.res"), dir: Some("src")}) => Pass
      | _ => Fail("Expected parsed fields")
      }
    }),
    Test.make("missing keys become None", () => {
      switch Cli.parseFileConfig("{}") {
      | Ok({pattern: None, dir: None}) => Pass
      | _ => Fail("Expected empty config")
      }
    }),
    Test.make("errors on malformed JSON", () => {
      switch Cli.parseFileConfig("{not json") {
      | Error(_) => Pass
      | Ok(_) => Fail("Expected parse error")
      }
    }),
    Test.make("errors when top level is not an object", () => {
      switch Cli.parseFileConfig("[]") {
      | Error(_) => Pass
      | Ok(_) => Fail("Expected object error")
      }
    }),
  ],
)

let findTestFilesTests = Suite.make(
  "Cli.findTestFiles",
  [
    Test.make("returns empty array for a nonexistent directory", () => {
      let found = Cli.findTestFiles(
        ~dir="./.tmp_definitely_does_not_exist_zzz",
        ~suffix=".test.res",
      )
      if Array.length(found) == 0 {
        Pass
      } else {
        Fail("Expected empty array for nonexistent dir")
      }
    }),
    Test.make("finds matches recursively and skips node_modules", () => {
      let root = TestFs.join(".", ".tmp_find_test")
      TestFs.rmSync(root, {"recursive": true, "force": true})
      TestFs.mkdirSync(TestFs.join(root, "nested"), {"recursive": true})
      TestFs.mkdirSync(TestFs.join(root, "node_modules"), {"recursive": true})
      TestFs.writeFileSync(TestFs.join(root, "A.test.res"), "")
      TestFs.writeFileSync(TestFs.join(TestFs.join(root, "nested"), "B.test.res"), "")
      TestFs.writeFileSync(TestFs.join(root, "Ignored.res"), "")
      TestFs.writeFileSync(TestFs.join(TestFs.join(root, "node_modules"), "C.test.res"), "")

      let found = Cli.findTestFiles(~dir=root, ~suffix=".test.res")
      let hasA = found->Array.some(p => String.endsWith(p, "A.test.res"))
      let hasB = found->Array.some(p => String.endsWith(p, "B.test.res"))
      let hasC = found->Array.some(p => String.endsWith(p, "C.test.res"))

      TestFs.rmSync(root, {"recursive": true, "force": true})

      if Array.length(found) == 2 && hasA && hasB && !hasC {
        Pass
      } else {
        Fail("Expected only A and B matched")
      }
    }),
  ],
)

let candidateSiblingsTests = Suite.make(
  "Cli.candidateSiblings",
  [
    Test.make("maps source to probe list in order", () => {
      let got = Cli.candidateSiblings("a/Color.test.res")
      Assert.equal(
        got,
        [
          "a/Color.test.res.mjs",
          "a/Color.test.res.js",
          "a/Color.test.bs.js",
          "a/Color.test.mjs",
          "a/Color.test.cjs",
          "a/Color.test.js",
        ],
      )
    }),
  ],
)

let compiledSiblingTests = Suite.make(
  "Cli.compiledSibling",
  [
    Test.make("returns the first existing sibling", () => {
      let root = TestFs.join(".", ".tmp_sibling_test")
      TestFs.rmSync(root, {"recursive": true, "force": true})
      TestFs.mkdirSync(root, {"recursive": true})
      let source = TestFs.join(root, "Color.test.res")
      let compiled = TestFs.join(root, "Color.test.js")
      TestFs.writeFileSync(source, "")
      TestFs.writeFileSync(compiled, "")

      let result = Cli.compiledSibling(source)
      TestFs.rmSync(root, {"recursive": true, "force": true})

      switch result {
      | Some(path) if String.endsWith(path, "Color.test.js") => Pass
      | _ => Fail("Expected compiled sibling found")
      }
    }),
    Test.make("returns None when no sibling exists", () => {
      let root = TestFs.join(".", ".tmp_sibling_none")
      TestFs.rmSync(root, {"recursive": true, "force": true})
      TestFs.mkdirSync(root, {"recursive": true})
      let source = TestFs.join(root, "Lonely.test.res")
      TestFs.writeFileSync(source, "")

      let result = Cli.compiledSibling(source)
      TestFs.rmSync(root, {"recursive": true, "force": true})

      switch result {
      | None => Pass
      | Some(_) => Fail("Expected no sibling")
      }
    }),
  ],
)

let runFilesTests = Suite.make(
  "Cli.runFiles",
  [
    Test.make("counts passing and failing child processes", () => {
      let root = TestFs.join(".", ".tmp_run_test")
      TestFs.rmSync(root, {"recursive": true, "force": true})
      TestFs.mkdirSync(root, {"recursive": true})
      let passFile = TestFs.join(root, "pass.js")
      let failFile = TestFs.join(root, "fail.js")
      TestFs.writeFileSync(passFile, "process.exit(0)\n")
      TestFs.writeFileSync(failFile, "process.exit(1)\n")

      let summary = Cli.runFiles([passFile, failFile])
      TestFs.rmSync(root, {"recursive": true, "force": true})

      Assert.equal(summary, {total: 2, passed: 1, failed: 1})
    }),
  ],
)

let readFileConfigTests = Suite.make(
  "Cli.readFileConfig",
  [
    Test.make("returns empty config when zekr.json is absent", () => {
      // The repo root has no zekr.json; readFileConfig reads from cwd.
      switch Cli.readFileConfig() {
      | Ok({pattern: None, dir: None}) => Pass
      | Ok(_) => Fail("Expected empty config")
      | Error(msg) => Fail("Unexpected error: " ++ msg)
      }
    }),
  ],
)

Runner.runSuites([
  parseArgsTests,
  resolveConfigTests,
  parseFileConfigTests,
  findTestFilesTests,
  candidateSiblingsTests,
  compiledSiblingTests,
  runFilesTests,
  readFileConfigTests,
])
