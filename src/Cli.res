// Cli - test file discovery and execution for the `zekr` binary

type cliArgs = {pattern: option<string>, dir: option<string>, help: bool}
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

let parseArgs = (argv: array<string>): result<cliArgs, string> => {
  let pattern = ref(None)
  let dir = ref(None)
  let help = ref(false)
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
  | None => Ok({pattern: pattern.contents, dir: dir.contents, help: help.contents})
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

let runFiles = (files: array<string>): runSummary => {
  let passed = ref(0)
  let failed = ref(0)
  files->Array.forEach(file => {
    let result = NodeChildProcess.spawnSync("node", [file], {"stdio": "inherit"})
    let code = result.status->Nullable.toOption->Option.getOr(1)
    if code == 0 {
      passed := passed.contents + 1
    } else {
      failed := failed.contents + 1
    }
  })
  {total: Array.length(files), passed: passed.contents, failed: failed.contents}
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

Flags override zekr.json, which overrides defaults.`)
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
        let sources = findTestFiles(~dir=cfg.dir, ~suffix=cfg.pattern)

        if Array.length(sources) == 0 {
          Console.error(
            Colors.fail(`No test files matching "${cfg.pattern}" found in "${cfg.dir}"`),
          )
          exit(1)
        } else {
          let compiled = []
          let missing = []
          sources->Array.forEach(source =>
            switch compiledSibling(source) {
            | Some(js) => compiled->Array.push(js)
            | None => missing->Array.push(source)
            }
          )

          missing->Array.forEach(source =>
            Console.error(
              Colors.fail(`✗ ${source} — not compiled (run \`rescript\` first)`),
            )
          )

          let summary = runFiles(compiled)
          let failedTotal = summary.failed + Array.length(missing)

          Console.log(
            `\nzekr: ${Int.toString(summary.total + Array.length(missing))} files, ${Colors.pass(
                Int.toString(summary.passed) ++ " passed",
              )}, ${Colors.fail(Int.toString(failedTotal) ++ " failed")}`,
          )

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
