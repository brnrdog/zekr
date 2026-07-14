open Xote
open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    <Typography text={static("CLI (zekr binary)")} variant={H1} />
    <Typography
      text={static("Discover and run your test files automatically with the zekr CLI.")}
      variant={Lead}
    />
    <Separator />
    // Overview
    <div class="heading-anchor" id="overview">
      <Typography text={static("Overview")} variant={H2} />
      <a class="anchor-link" href="#overview"> {"#"->Node.text} </a>
    </div>
    <Typography
      text={static(
        "The zekr binary scans your project for compiled test files and runs each one in its own Node process. Build with ReScript first, then invoke zekr:",
      )}
    />
    <CodeBlock
      language="jsonc"
      code={`// package.json
"scripts": {
  "test": "rescript && zekr"
}`}
    />
    <Typography
      text={static(
        "By default it scans the current directory for files ending in .test.res (e.g. Color.test.res) and runs each compiled sibling file in its own Node process.",
      )}
    />
    <Separator />
    // Flags
    <div class="heading-anchor" id="flags">
      <Typography text={static("Flags")} variant={H2} />
      <a class="anchor-link" href="#flags"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="flag-pattern">
      <Typography text={static("--pattern <suffix> / -p")} variant={H3} />
      <a class="anchor-link" href="#flag-pattern"> {"#"->Node.text} </a>
    </div>
    <Typography
      text={static(
        "Filename suffix to match. Defaults to .test.res. Any file whose name ends with this suffix is considered a test source.",
      )}
    />
    <div class="heading-anchor" id="flag-dir">
      <Typography text={static("--dir <path> / -d")} variant={H3} />
      <a class="anchor-link" href="#flag-dir"> {"#"->Node.text} </a>
    </div>
    <Typography
      text={static("Directory to scan recursively. Defaults to . (the current working directory).")}
    />
    <div class="heading-anchor" id="flag-help">
      <Typography text={static("--help / -h")} variant={H3} />
      <a class="anchor-link" href="#flag-help"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Print usage information and exit.")} />
    <CodeBlock
      language="bash"
      code={`# Use a custom suffix and directory
zekr --pattern .spec.res --dir src

# Short aliases
zekr -p .spec.res -d src`}
    />
    <Separator />
    // Config file
    <div class="heading-anchor" id="config-file">
      <Typography text={static("Config file (zekr.json)")} variant={H2} />
      <a class="anchor-link" href="#config-file"> {"#"->Node.text} </a>
    </div>
    <Typography
      text={static(
        "Instead of passing flags every time, place a zekr.json at your project root:",
      )}
    />
    <CodeBlock language="json" code={`{ "pattern": ".test.res", "dir": "." }`} />
    <Typography
      text={static(
        "Precedence: flags override zekr.json, which overrides the built-in defaults.",
      )}
    />
    <Separator />
    // Behavior
    <div class="heading-anchor" id="behavior">
      <Typography text={static("Behavior")} variant={H2} />
      <a class="anchor-link" href="#behavior"> {"#"->Node.text} </a>
    </div>
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li>
        <strong> {"Spawn-per-file"->Node.text} </strong>
        {" — each matched test file is run in its own Node.js child process, so global state is fully isolated between files."->Node.text}
      </li>
      <li>
        <strong> {"Skipped directories"->Node.text} </strong>
        {" — node_modules, lib, .git, and any dot-directories are never scanned."->Node.text}
      </li>
      <li>
        <strong> {"Compiled-sibling check"->Node.text} </strong>
        {" — zekr locates the compiled .js sibling next to each .res source. If the sibling is missing, zekr reports the file and exits non-zero. Run rescript before zekr."->Node.text}
      </li>
      <li>
        <strong> {"Exit code"->Node.text} </strong>
        {" — exits non-zero when any test file fails or when zero files match the pattern."->Node.text}
      </li>
    </ul>
    <Separator />
    // Implementation
    <div class="heading-anchor" id="implementation">
      <Typography text={static("Implementation notes")} variant={H2} />
      <a class="anchor-link" href="#implementation"> {"#"->Node.text} </a>
    </div>
    <Typography
      text={static(
        "src/Cli.res (compiled to Zekr.Cli) contains all discovery and execution logic. bin/zekr.mjs is a lightweight shebang shim that imports the compiled src/Cli.js. Zekr.Cli is not re-exported from the src/Zekr.js barrel — it is the CLI entry point, not a library API.",
      )}
    />
    <EditOnGitHub pageName="Pages__ApiCli" />
  </div>
}
