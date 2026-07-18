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
    Test.make("sets watch for --watch and -w", () => {
      switch (Cli.parseArgs(["--watch"]), Cli.parseArgs(["-w"])) {
      | (Ok({watch: true}), Ok({watch: true})) => Pass
      | _ => Fail("Expected watch true for both spellings")
      }
    }),
    Test.make("watch defaults to false", () => {
      switch Cli.parseArgs(["--pattern", ".test.res"]) {
      | Ok({watch: false}) => Pass
      | _ => Fail("Expected watch false by default")
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
        ~args={pattern: None, dir: None, help: false, watch: false},
        ~file={pattern: None, dir: None},
      )
      Assert.equal(cfg, {pattern: ".test.res", dir: "."})
    }),
    Test.make("file config overrides defaults", () => {
      let cfg = Cli.resolveConfig(
        ~args={pattern: None, dir: None, help: false, watch: false},
        ~file={pattern: Some(".spec.res"), dir: Some("src")},
      )
      Assert.equal(cfg, {pattern: ".spec.res", dir: "src"})
    }),
    Test.make("flags override file config", () => {
      let cfg = Cli.resolveConfig(
        ~args={pattern: Some(".a.res"), dir: Some("a"), help: false, watch: false},
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

let moduleNameOfPathTests = Suite.make(
  "Cli.moduleNameOfPath",
  [
    Test.make("derives module name from a source path", () => {
      Assert.equal(Cli.moduleNameOfPath("src/Assert.res"), "Assert")
    }),
    Test.make("derives module name from compiled output", () => {
      Assert.equal(Cli.moduleNameOfPath("src/Assert.js"), "Assert")
    }),
    Test.make("stops at the first dot for test files", () => {
      Assert.equal(Cli.moduleNameOfPath("tests/ZekrCli.test.res"), "ZekrCli")
    }),
  ],
)

let toSourcePathTests = Suite.make(
  "Cli.toSourcePath",
  [
    Test.make("maps compiled output back to its .res source", () => {
      Assert.equal(Cli.toSourcePath("src/Assert.js"), "src/Assert.res")
    }),
    Test.make("maps a compiled test file back to its .res source", () => {
      Assert.equal(Cli.toSourcePath("tests/Foo.test.js"), "tests/Foo.test.res")
    }),
    Test.make("leaves a .res path untouched", () => {
      Assert.equal(Cli.toSourcePath("src/Assert.res"), "src/Assert.res")
    }),
  ],
)

let referencesModuleTests = Suite.make(
  "Cli.referencesModule",
  [
    Test.make("matches a qualified reference", () => {
      Assert.isTrue(Cli.referencesModule("let _ = Assert.equal(1, 1)", "Assert"))
    }),
    Test.make("matches an open", () => {
      Assert.isTrue(Cli.referencesModule("open Suite\n", "Suite"))
    }),
    Test.make("does not match an unrelated module", () => {
      Assert.isFalse(Cli.referencesModule("open Suite\n", "Assert"))
    }),
  ],
)

let impactedTestFilesTests = Suite.make(
  "Cli.impactedTestFiles",
  [
    Test.make("a changed test file impacts only itself", () => {
      let impacted = Cli.impactedTestFiles(
        ~changed="tests/Foo.test.js",
        ~testFiles=["./tests/Foo.test.res", "./tests/Bar.test.res"],
        ~suffix=".test.res",
        ~readFile=_ => None,
      )
      Assert.equal(impacted, ["./tests/Foo.test.res"])
    }),
    Test.make("a changed source impacts tests that reference its module", () => {
      let contents = Dict.fromArray([
        ("./tests/UsesAssert.test.res", "let _ = Assert.equal(1, 1)"),
        ("./tests/UsesSuite.test.res", "open Suite"),
      ])
      let impacted = Cli.impactedTestFiles(
        ~changed="src/Assert.js",
        ~testFiles=["./tests/UsesAssert.test.res", "./tests/UsesSuite.test.res"],
        ~suffix=".test.res",
        ~readFile=path => contents->Dict.get(path),
      )
      Assert.equal(impacted, ["./tests/UsesAssert.test.res"])
    }),
    Test.make("returns empty when nothing references the changed module", () => {
      let impacted = Cli.impactedTestFiles(
        ~changed="src/Colors.js",
        ~testFiles=["./tests/UsesAssert.test.res"],
        ~suffix=".test.res",
        ~readFile=_ => Some("let _ = Assert.equal(1, 1)"),
      )
      if Array.length(impacted) == 0 {
        Pass
      } else {
        Fail("Expected no impacted tests")
      }
    }),
  ],
)

let parseFailingTestsTests = Suite.make(
  "Cli.parseFailingTests",
  [
    Test.make("extracts failing test names, ignoring passes and ANSI colors", () => {
      let output =
        "\n \x1b[36m\x1b[1mMy Suite\x1b[0m\n" ++
        "   \x1b[32m✓\x1b[0m passing one\n" ++
        "   \x1b[31m✗\x1b[0m failing one\n" ++
        "     \x1b[31mexpected 1 to equal 2\x1b[0m\n" ++
        "   \x1b[31m✗\x1b[0m failing two\n"
      Assert.equal(Cli.parseFailingTests(output), ["failing one", "failing two"])
    }),
    Test.make("returns empty when nothing failed", () => {
      let output = "   \x1b[32m✓\x1b[0m all good\n"
      if Array.length(Cli.parseFailingTests(output)) == 0 {
        Pass
      } else {
        Fail("Expected no failing tests")
      }
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

