open Xote
open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    <Typography text={static("Test Runner")} variant={H1} />
    <Typography
      text={static("Run test suites, filter tests, and watch files for changes.")}
      variant={Lead}
    />
    <Separator />
    // Running Tests
    <div class="heading-anchor" id="running">
      <Typography text={static("Running Tests")} variant={H2} />
      <a class="anchor-link" href="#running"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="run-suite">
      <Typography text={static("runSuite(suite)")} variant={H3} />
      <a class="anchor-link" href="#run-suite"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Runs a single synchronous test suite.")} />
    <div class="heading-anchor" id="run-suites">
      <Typography text={static("runSuites(suites)")} variant={H3} />
      <a class="anchor-link" href="#run-suites"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Runs multiple synchronous test suites.")} />
    <CodeBlock
      language="rescript"
      code={`open Zekr

let mathSuite = suite("Math", [
  test("adds", () => assertEqual(1 + 1, 2)),
])

let stringSuite = suite("String", [
  test("trims", () => assertEqual(String.trim("  hi  "), "hi")),
])

runSuites([mathSuite, stringSuite])`}
    />
    <div class="heading-anchor" id="run-async-suite">
      <Typography text={static("runAsyncSuite(suite)")} variant={H3} />
      <a class="anchor-link" href="#run-async-suite"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Runs a single async test suite.")} />
    <div class="heading-anchor" id="run-async-suites">
      <Typography text={static("runAsyncSuites(suites)")} variant={H3} />
      <a class="anchor-link" href="#run-async-suites"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Runs multiple async test suites.")} />
    <Separator />
    // Filtering
    <div class="heading-anchor" id="filtering">
      <Typography text={static("Test Filtering")} variant={H2} />
      <a class="anchor-link" href="#filtering"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="set-filter-pattern">
      <Typography text={static("setFilterPattern(pattern)")} variant={H3} />
      <a class="anchor-link" href="#set-filter-pattern"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Sets a pattern to run only tests whose name matches (case-insensitive). Pattern is matched against the combined suite + test name.")} />
    <CodeBlock
      language="rescript"
      code={`// Only run tests containing "math" in their name
setFilterPattern(Some("math"))`}
    />
    <div class="heading-anchor" id="set-skip-pattern">
      <Typography text={static("setSkipPattern(pattern)")} variant={H3} />
      <a class="anchor-link" href="#set-skip-pattern"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Sets a pattern to skip tests whose name matches.")} />
    <CodeBlock
      language="rescript"
      code={`// Skip all tests containing "slow"
setSkipPattern(Some("slow"))`}
    />
    <Separator />
    <div class="heading-anchor" id="env-vars">
      <Typography text={static("Environment Variables")} variant={H2} />
      <a class="anchor-link" href="#env-vars"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("You can also filter tests using environment variables:")} />
    <CodeBlock
      language="bash"
      code={`# Run only tests matching "math"
ZEKR_FILTER="math" node tests/MyTests.js

# Skip tests matching "slow"
ZEKR_SKIP="slow" node tests/MyTests.js`}
    />
    <Separator />
    // Timeout
    <div class="heading-anchor" id="timeout">
      <Typography text={static("Timeout Helper")} variant={H2} />
      <a class="anchor-link" href="#timeout"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="run-with-timeout">
      <Typography text={static("runWithTimeout(fn, timeout)")} variant={H3} />
      <a class="anchor-link" href="#run-with-timeout"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Runs an async function with an optional timeout. If the timeout is exceeded, it returns Fail. This is used internally by asyncTest but can also be used directly.")} />
    <Separator />
    // Watch Mode
    <div class="heading-anchor" id="watch-mode">
      <Typography text={static("Watch Mode")} variant={H2} />
      <a class="anchor-link" href="#watch-mode"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="watch-mode-fn">
      <Typography text={static("watchMode(~testCommand, ~watchPaths, ~buildCommand?)")} variant={H3} />
      <a class="anchor-link" href="#watch-mode-fn"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Starts watch mode. Watches the specified paths for file changes, optionally runs a build command, then re-runs the test command. Changes are debounced by 100ms.")} />
    <CodeBlock
      language="rescript"
      code={`watchMode(
  ~testCommand="node tests/MyTests.js",
  ~watchPaths=["src", "tests"],
  ~buildCommand=Some("npx rescript"),
)`}
    />
    <Typography text={static("Press Ctrl+C to stop watch mode.")} />
    <Separator />
    // Filter Priority
    <div class="heading-anchor" id="priority">
      <Typography text={static("Filter Priority")} variant={H2} />
      <a class="anchor-link" href="#priority"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("When multiple filtering mechanisms are active, they are applied in this order:")} />
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> <strong> {"testOnly"->Component.text} </strong> {" — Highest priority. When any test has Only mode, only those tests run."->Component.text} </li>
      <li> <strong> {"testSkip"->Component.text} </strong> {" — Always skipped, regardless of other filters."->Component.text} </li>
      <li> <strong> {"Filter/skip patterns"->Component.text} </strong> {" — Applied to remaining tests."->Component.text} </li>
      <li> <strong> {"Normal mode"->Component.text} </strong> {" — Runs if not filtered out."->Component.text} </li>
    </ul>
    <EditOnGitHub pageName="Pages__ApiRunner" />
  </div>
}
