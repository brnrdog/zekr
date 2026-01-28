// Zekr__Snapshot - Snapshot testing support

open Zekr__Types

// Node.js file system bindings for snapshot testing
module NodeFs = {
  @module("fs") external existsSync: string => bool = "existsSync"
  @module("fs") external readFileSync: (string, string) => string = "readFileSync"
  @module("fs") external writeFileSync: (string, string) => unit = "writeFileSync"
  @module("fs") external mkdirSync: (string, {"recursive": bool}) => unit = "mkdirSync"
  @module("fs")
  external watch: (string, {"recursive": bool}, (string, string) => unit) => unit = "watch"
}

module NodePath = {
  @module("path") external dirname: string => string = "dirname"
  @module("path") external join: (string, string) => string = "join"
}

// Snapshot directory configuration
let snapshotDir = ref("__snapshots__")

let setSnapshotDir = (dir: string): unit => {
  snapshotDir := dir
}

let assertMatchesSnapshot = (
  value: 'a,
  ~name: string,
  ~snapshotPath: option<string>=?,
): testResult => {
  let serialized = JSON.stringifyAny(value)->Option.getOr("undefined")
  let formatted = try {
    let parsed = JSON.parseExn(serialized)
    JSON.stringifyWithIndent(parsed, 2)
  } catch {
  | _ => serialized
  }

  let dir = switch snapshotPath {
  | Some(p) => p
  | None => snapshotDir.contents
  }

  // Ensure snapshot directory exists
  if !NodeFs.existsSync(dir) {
    NodeFs.mkdirSync(dir, {"recursive": true})
  }

  let snapshotFile = NodePath.join(dir, name ++ ".snap")

  if NodeFs.existsSync(snapshotFile) {
    let existing = NodeFs.readFileSync(snapshotFile, "utf8")
    if existing == formatted {
      Pass
    } else {
      Fail(
        `Snapshot mismatch for "${name}"\n` ++
        `       ${Zekr__Colors.pass("+ expected")} ${Zekr__Colors.fail("- actual")}\n` ++
        `       ${Zekr__Colors.fail("- " ++ formatted)}\n` ++
        `       ${Zekr__Colors.pass("+ " ++ existing)}`,
      )
    }
  } else {
    // Create new snapshot
    NodeFs.writeFileSync(snapshotFile, formatted)
    Pass
  }
}

let updateSnapshot = (value: 'a, ~name: string, ~snapshotPath: option<string>=?): unit => {
  let serialized = JSON.stringifyAny(value)->Option.getOr("undefined")
  let formatted = try {
    let parsed = JSON.parseExn(serialized)
    JSON.stringifyWithIndent(parsed, 2)
  } catch {
  | _ => serialized
  }

  let dir = switch snapshotPath {
  | Some(p) => p
  | None => snapshotDir.contents
  }

  if !NodeFs.existsSync(dir) {
    NodeFs.mkdirSync(dir, {"recursive": true})
  }

  let snapshotFile = NodePath.join(dir, name ++ ".snap")
  NodeFs.writeFileSync(snapshotFile, formatted)
}
