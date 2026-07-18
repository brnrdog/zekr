// Cli - test file discovery and execution for the `zekr` binary

type cliArgs = {pattern: option<string>, dir: option<string>, help: bool, watch: bool}
type config = {pattern: string, dir: string}
type fileConfig = {pattern: option<string>, dir: option<string>}
type runSummary = {total: int, passed: int, failed: int}

@val @scope("process") external exit: int => unit = "exit"

module NodeFs = {
  type stats
  @module("fs") external readdirSync: string => array<string> = "readdirSync"
  @module("fs") external statSync: string => stats = "statSync"
  @send external isDirectory: stats => bool = "isDirectory"
  @module("fs") external existsSync: string => bool = "existsSync"
  @module("fs") external readFileSync: (string, string) => string = "readFileSync"
}

module NodePath = {
  @module("path") external join: (string, string) => string = "join"
}

module NodeChildProcess = {
  type spawnResult = {status: Nullable.t<int>}
  @module("child_process")
  external spawnSync: (string, array<string>, {"stdio": string}) => spawnResult = "spawnSync"
}

module NodeUrl = {
  @module("url") external fileURLToPath: string => string = "fileURLToPath"
}

let harnessUrl: string = %raw(`new URL("../bin/zekr-run.mjs", import.meta.url).href`)
let harnessPath = NodeUrl.fileURLToPath(harnessUrl)

let parseArgs = (argv: array<string>): result<cliArgs, string> => {
  let pattern = ref(None)
  let dir = ref(None)
  let help = ref(false)
  let watch = ref(false)
  let error = ref(None)
  let i = ref(0)
  let n = Array.length(argv)

  while i.contents < n && error.contents == None {
    let arg = argv->Array.getUnsafe(i.contents)
    switch arg {
    | "--help" | "-h" => {
        help := true
        i := i.contents + 1
      }
    | "--watch" | "-w" => {
        watch := true
        i := i.contents + 1
      }
    | "--pattern" | "-p" =>
      switch argv->Array.get(i.contents + 1) {
      | Some(value) => {
          pattern := Some(value)
          i := i.contents + 2
        }
      | None => error := Some("Missing value for " ++ arg)
      }
    | "--dir" | "-d" =>
      switch argv->Array.get(i.contents + 1) {
      | Some(value) => {
          dir := Some(value)
          i := i.contents + 2
        }
      | None => error := Some("Missing value for " ++ arg)
      }
    | other => error := Some("Unknown argument: " ++ other)
    }
  }

  switch error.contents {
  | Some(message) => Error(message)
  | None =>
    Ok({pattern: pattern.contents, dir: dir.contents, help: help.contents, watch: watch.contents})
  }
}

let defaultPattern = ".test.res"
let defaultDir = "."

let firstSome = (primary: option<'a>, fallback: option<'a>): option<'a> => {
  switch primary {
  | Some(_) => primary
  | None => fallback
  }
}

let resolveConfig = (~args: cliArgs, ~file: fileConfig): config => {
  pattern: firstSome(args.pattern, file.pattern)->Option.getOr(defaultPattern),
  dir: firstSome(args.dir, file.dir)->Option.getOr(defaultDir),
}

let parseFileConfig = (contents: string): result<fileConfig, string> => {
  let parsed = try Some(JSON.parseOrThrow(contents)) catch {
  | _ => None
  }
  switch parsed {
  | None => Error("Invalid JSON in zekr.json")
  | Some(json) =>
    switch json {
    | JSON.Object(obj) => {
        let getStr = key =>
          switch obj->Dict.get(key) {
          | Some(JSON.String(value)) => Some(value)
          | _ => None
          }
        Ok({pattern: getStr("pattern"), dir: getStr("dir")})
      }
    | _ => Error("zekr.json must contain a JSON object")
    }
  }
}

let shouldSkipEntry = (entry: string): bool => {
  entry == "node_modules" || entry == "lib" || entry == ".git" || String.startsWith(entry, ".")
}

let findTestFiles = (~dir: string, ~suffix: string): array<string> => {
  if !NodeFs.existsSync(dir) {
    []
  } else {
  let results = []
  let rec walk = current => {
    NodeFs.readdirSync(current)->Array.forEach(entry => {
      if !shouldSkipEntry(entry) {
        let full = NodePath.join(current, entry)
        if NodeFs.statSync(full)->NodeFs.isDirectory {
          walk(full)
        } else if String.endsWith(entry, suffix) {
          results->Array.push(full)
        }
      }
    })
  }
  walk(dir)
  results
  }
}

let compiledExtensions = [".res.mjs", ".res.js", ".bs.js", ".mjs", ".cjs", ".js"]

let candidateSiblings = (source: string): array<string> => {
  let base = if String.endsWith(source, ".res") {
    String.slice(source, ~start=0, ~end=String.length(source) - 4)
  } else {
    source
  }
  compiledExtensions->Array.map(ext => base ++ ext)
}

let compiledSibling = (source: string): option<string> => {
  candidateSiblings(source)->Array.find(NodeFs.existsSync)
}

// --- Watch-mode impact analysis (pure helpers) -------------------------------

// Last path segment, e.g. "tests/Foo.test.res" -> "Foo.test.res".
let basename = (path: string): string => {
  let segments = path->String.split("/")
  segments->Array.get(Array.length(segments) - 1)->Option.getOr(path)
}

// The ReScript module name a file belongs to: the basename up to the first dot.
// "src/Assert.res" -> "Assert", "src/Assert.js" -> "Assert",
// "tests/ZekrCli.test.res" -> "ZekrCli".
let moduleNameOfPath = (path: string): string => {
  let base = basename(path)
  switch base->String.indexOf(".") {
  | -1 => base
  | dot => String.slice(base, ~start=0, ~end=dot)
  }
}

// True when `path` looks like ReScript-compiled output (any known suffix),
// as opposed to a raw `.res` source. Watch mode reacts to compiled changes so
// tests always run against freshly built output.
let isCompiledOutput = (path: string): bool =>
  compiledExtensions->Array.some(ext => String.endsWith(path, ext))

// Map a compiled (or source) path back to its `.res` source path, preserving
// the directory. "src/Assert.js" -> "src/Assert.res",
// "tests/Foo.test.js" -> "tests/Foo.test.res".
let toSourcePath = (path: string): string => {
  if String.endsWith(path, ".res") {
    path
  } else {
    switch compiledExtensions->Array.find(ext => String.endsWith(path, ext)) {
    | Some(ext) => String.slice(path, ~start=0, ~end=String.length(path) - String.length(ext)) ++ ".res"
    | None => path
    }
  }
}

// A test's source references a module when it qualifies a value with it
// (`Assert.equal`) or opens it (`open Suite`).
let referencesModule = (contents: string, moduleName: string): bool =>
  String.includes(contents, moduleName ++ ".") || String.includes(contents, "open " ++ moduleName)

// Given a changed file, return the subset of discovered test sources impacted
// by it. A changed test file impacts only itself; a changed source module
// impacts every test that references that module. `readFile` returns None when
// a file can't be read, so callers stay testable and IO-free.
let impactedTestFiles = (
  ~changed: string,
  ~testFiles: array<string>,
  ~suffix: string,
  ~readFile: string => option<string>,
): array<string> => {
  let source = toSourcePath(changed)
  if String.endsWith(source, suffix) {
    let changedBase = basename(source)
    testFiles->Array.filter(file => basename(file) == changedBase)
  } else {
    let moduleName = moduleNameOfPath(changed)
    testFiles->Array.filter(file =>
      switch readFile(file) {
      | Some(contents) => referencesModule(contents, moduleName)
      | None => false
      }
    )
  }
}

let runFiles = (files: array<string>): runSummary => {
  let passed = ref(0)
  let failed = ref(0)
  files->Array.forEach(file => {
    let result = NodeChildProcess.spawnSync("node", [harnessPath, file], {"stdio": "inherit"})
    let code = result.status->Nullable.toOption->Option.getOr(1)
    if code == 0 {
      passed := passed.contents + 1
    } else {
      failed := failed.contents + 1
    }
  })
  {total: Array.length(files), passed: passed.contents, failed: failed.contents}
}

// Compile-check a set of test sources, run those that are built, warn about the
// rest, print a summary, and return the total failure count (without exiting).
// Shared by the one-shot run and each watch-mode iteration.
let runDiscovered = (sources: array<string>): int => {
  let compiled = []
  let missing = []
  sources->Array.forEach(source =>
    switch compiledSibling(source) {
    | Some(js) => compiled->Array.push(js)
    | None => missing->Array.push(source)
    }
  )

  missing->Array.forEach(source =>
    Console.error(Colors.fail(`✗ ${source} — not compiled (run \`rescript\` first)`))
  )

  let summary = runFiles(compiled)
  let failedTotal = summary.failed + Array.length(missing)

  Console.log(
    `\nzekr: ${Int.toString(summary.total + Array.length(missing))} files, ${Colors.pass(
        Int.toString(summary.passed) ++ " passed",
      )}, ${Colors.fail(Int.toString(failedTotal) ++ " failed")}`,
  )

  failedTotal
}

let readFileConfig = (): result<fileConfig, string> => {
  if NodeFs.existsSync("zekr.json") {
    parseFileConfig(NodeFs.readFileSync("zekr.json", "utf8"))
  } else {
    Ok({pattern: None, dir: None})
  }
}

let printUsage = (): unit => {
  Console.log(`Usage: zekr [options]

Options:
  -p, --pattern <suffix>   Filename suffix to match (default: ${defaultPattern})
  -d, --dir <path>         Directory to scan (default: ${defaultDir})
  -h, --help               Show this help

Config file (zekr.json, optional):
  { "pattern": "${defaultPattern}", "dir": "${defaultDir}" }

Options (watch):
  -w, --watch              Re-run only the tests impacted by each change

Flags override zekr.json, which overrides defaults.`)
}

// --- Watch mode (IO) ---------------------------------------------------------

type timeoutId
@val external setTimeout: (unit => unit, int) => timeoutId = "setTimeout"
@val external clearTimeout: timeoutId => unit = "clearTimeout"

module NodeFsWatch = {
  @module("fs")
  external watch: (string, {"recursive": bool}, (string, Nullable.t<string>) => unit) => unit = "watch"
}

// Reads a file for impact analysis, returning None when it can't be read.
let readSource = (path: string): option<string> =>
  if NodeFs.existsSync(path) {
    try Some(NodeFs.readFileSync(path, "utf8")) catch {
    | _ => None
    }
  } else {
    None
  }

let watchDebounceMs = 150

// Re-run the tests impacted by a single changed file.
let runImpacted = (~cfg: config, ~changed: string): unit => {
  let sources = findTestFiles(~dir=cfg.dir, ~suffix=cfg.pattern)
  let impacted = impactedTestFiles(
    ~changed,
    ~testFiles=sources,
    ~suffix=cfg.pattern,
    ~readFile=readSource,
  )

  switch impacted {
  | [] => Console.log(Colors.dimmed(`\n  ${changed} changed — no impacted tests`))
  | _ => {
      Console.log("\n" ++ Colors.dimmed(String.repeat("=", 50)))
      Console.log(
        Colors.suite(
          ` ${changed} changed — running ${Int.toString(
              Array.length(impacted),
            )} impacted test file(s)`,
        ),
      )
      Console.log(Colors.dimmed(String.repeat("=", 50)))
      let _ = runDiscovered(impacted)
    }
  }
}

let watch = (~cfg: config): unit => {
  if !NodeFs.existsSync(cfg.dir) {
    Console.error(Colors.fail(`Watch directory "${cfg.dir}" does not exist`))
    exit(1)
  } else {
    Console.log(Colors.suite("\n zekr watch mode"))
    Console.log(Colors.dimmed(` Watching "${cfg.dir}" for changes (pattern *${cfg.pattern})`))
    Console.log(
      Colors.dimmed(" Runs only the tests impacted by each change. Press Ctrl+C to stop."),
    )
    Console.log(Colors.dimmed(" Tip: run your compiler in watch mode alongside (e.g. `rescript -w`).\n"))

    // Initial full pass so the baseline is visible before watching.
    let sources = findTestFiles(~dir=cfg.dir, ~suffix=cfg.pattern)
    if Array.length(sources) == 0 {
      Console.error(
        Colors.fail(`No test files matching "${cfg.pattern}" found in "${cfg.dir}" yet`),
      )
    } else {
      let _ = runDiscovered(sources)
    }

    // Debounce a burst of change events (a save often touches source then its
    // compiled sibling) into a single impacted run.
    let pending = ref(None)
    let onChange = (_eventType: string, filename: Nullable.t<string>) =>
      switch Nullable.toOption(filename) {
      | None => ()
      | Some(name) =>
        // React to compiled output only, so tests run against freshly built
        // code rather than an unbuilt `.res` save.
        if isCompiledOutput(name) {
          switch pending.contents {
          | Some(id) => clearTimeout(id)
          | None => ()
          }
          pending :=
            Some(
              setTimeout(() => {
                pending := None
                runImpacted(~cfg, ~changed=name)
              }, watchDebounceMs),
            )
        }
      }

    NodeFsWatch.watch(cfg.dir, {"recursive": true}, onChange)
  }
}

let main = (argv: array<string>): unit => {
  switch parseArgs(argv) {
  | Error(message) => {
      Console.error(Colors.fail(message))
      printUsage()
      exit(1)
    }
  | Ok(args) if args.help => {
      printUsage()
      exit(0)
    }
  | Ok(args) =>
    switch readFileConfig() {
    | Error(message) => {
        Console.error(Colors.fail(message))
        exit(1)
      }
    | Ok(file) => {
        let cfg = resolveConfig(~args, ~file)

        if args.watch {
          watch(~cfg)
        } else {
          let sources = findTestFiles(~dir=cfg.dir, ~suffix=cfg.pattern)

          if Array.length(sources) == 0 {
            Console.error(
              Colors.fail(`No test files matching "${cfg.pattern}" found in "${cfg.dir}"`),
            )
            exit(1)
          } else {
            let failedTotal = runDiscovered(sources)

            if failedTotal > 0 {
              exit(1)
            } else {
              exit(0)
            }
          }
        }
      }
    }
  }
}
