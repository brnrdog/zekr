open Xote
open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    <Typography text={static("Snapshot Testing")} variant={H1} />
    <Typography
      text={static("Capture and compare snapshots of your data. Snapshots are stored as JSON files and automatically compared on subsequent runs.")}
      variant={Lead}
    />
    <Separator />
    <div class="heading-anchor" id="how-it-works">
      <Typography text={static("How It Works")} variant={H2} />
      <a class="anchor-link" href="#how-it-works"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("On the first run, assertMatchesSnapshot creates a new snapshot file. On subsequent runs, it compares the current value against the stored snapshot. If they differ, the test fails.")} />
    <Separator />
    <div class="heading-anchor" id="assert-matches-snapshot">
      <Typography text={static("assertMatchesSnapshot(value, ~name, ~snapshotPath?)")} variant={H2} />
      <a class="anchor-link" href="#assert-matches-snapshot"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Compares a value against a stored snapshot. The ~name parameter is used as the filename. Returns Pass if the value matches, Fail if it differs.")} />
    <CodeBlock
      language="rescript"
      code={`open Zekr

let snapshotSuite = suite("Snapshots", [
  test("user object matches snapshot", () => {
    let user = {
      "name": "Alice",
      "email": "alice@example.com",
      "role": "admin",
    }
    assertMatchesSnapshot(user, ~name="user-object")
  }),
  test("config matches snapshot", () => {
    let config = getAppConfig()
    assertMatchesSnapshot(config, ~name="app-config")
  }),
])`}
    />
    <Separator />
    <div class="heading-anchor" id="update-snapshot">
      <Typography text={static("updateSnapshot(value, ~name, ~snapshotPath?)")} variant={H2} />
      <a class="anchor-link" href="#update-snapshot"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Explicitly updates a stored snapshot with a new value. Use this when you intentionally change the expected output.")} />
    <CodeBlock
      language="rescript"
      code={`// When you've intentionally changed the output:
updateSnapshot(newUserObject, ~name="user-object")`}
    />
    <Separator />
    <div class="heading-anchor" id="set-snapshot-dir">
      <Typography text={static("setSnapshotDir(path)")} variant={H2} />
      <a class="anchor-link" href="#set-snapshot-dir"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Sets a custom directory for storing snapshot files. By default, snapshots are stored in __snapshots__/.")} />
    <CodeBlock
      language="rescript"
      code={`// Store snapshots in a custom directory
setSnapshotDir("./tests/snapshots")

// Now all snapshots will be written to ./tests/snapshots/`}
    />
    <Separator />
    <div class="heading-anchor" id="snapshot-format">
      <Typography text={static("Snapshot Format")} variant={H2} />
      <a class="anchor-link" href="#snapshot-format"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Snapshots are stored as JSON files. Each snapshot file is named after the ~name parameter you provide.")} />
    <CodeBlock
      language="bash"
      code={`__snapshots__/
  user-object.snap.json
  app-config.snap.json`}
    />
    <Typography text={static("It is recommended to commit snapshot files to version control so that changes can be reviewed in pull requests.")} />
    <EditOnGitHub pageName="Pages__ApiSnapshots" />
  </div>
}
