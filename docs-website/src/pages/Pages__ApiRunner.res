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
      <a class="anchor-link" href="#running"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="run-suite">
      <Typography text={static("Runner.runSuite(suite)")} variant={H3} />
      <a class="anchor-link" href="#run-suite"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Runs a single synchronous test suite.")} />
    <div class="heading-anchor" id="run-suites">
      <Typography text={static("Runner.runSuites(suites)")} variant={H3} />
      <a class="anchor-link" href="#run-suites"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Runs multiple synchronous test suites.")} />
    <CodeBlock
      language="rescript"
      code={`open Zekr

let mathSuite = Suite.make("Math", [
  Test.make("adds", () => Assert.equal(1 + 1, 2)),
])

let stringSuite = Suite.make("String", [
  Test.make("trims", () => Assert.equal(String.trim("  hi  "), "hi")),
])

Runner.runSuites([mathSuite, stringSuite])`}
    />
    <div class="heading-anchor" id="run-async-suite">
      <Typography text={static("Runner.runAsyncSuite(suite)")} variant={H3} />
      <a class="anchor-link" href="#run-async-suite"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Runs a single async test suite.")} />
    <div class="heading-anchor" id="run-async-suites">
      <Typography text={static("Runner.runAsyncSuites(suites)")} variant={H3} />
      <a class="anchor-link" href="#run-async-suites"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Runs multiple async test suites.")} />
    <Separator />
    // Filtering
    <div class="heading-anchor" id="filtering">
      <Typography text={static("Test Filtering")} variant={H2} />
      <a class="anchor-link" href="#filtering"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="set-filter-pattern">
      <Typography text={static("setFilterPattern(pattern)")} variant={H3} />
      <a class="anchor-link" href="#set-filter-pattern"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Sets a pattern to run only tests whose name matches (case-insensitive). Pattern is matched against the combined suite + test name.")} />
    <CodeBlock
      language="rescript"
      code={`// Only run tests containing "math" in their name
setFilterPattern(Some("math"))`}
    />
    <div class="heading-anchor" id="set-skip-pattern">
      <Typography text={static("setSkipPattern(pattern)")} variant={H3} />
      <a class="anchor-link" href="#set-skip-pattern"> {"#"->Node.text} </a>
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
      <a class="anchor-link" href="#env-vars"> {"#"->Node.text} </a>
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
      <a class="anchor-link" href="#timeout"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="run-with-timeout">
      <Typography text={static("Runner.runWithTimeout(fn, timeout)")} variant={H3} />
      <a class="anchor-link" href="#run-with-timeout"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Runs an async function with an optional timeout. If the timeout is exceeded, it returns Fail. This is used internally by Test.async but can also be used directly.")} />
    <Separator />
    // Watch Mode
    <div class="heading-anchor" id="watch-mode">
      <Typography text={static("Watch Mode")} variant={H2} />
      <a class="anchor-link" href="#watch-mode"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="watch-mode-fn">
      <Typography text={static("Runner.watchMode(~testCommand, ~watchPaths, ~buildCommand?)")} variant={H3} />
      <a class="anchor-link" href="#watch-mode-fn"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Starts watch mode. Watches the specified paths for file changes, optionally runs a build command, then re-runs the test command. Changes are debounced by 100ms.")} />
    <CodeBlock
      language="rescript"
      code={`Runner.watchMode(
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
      <a class="anchor-link" href="#priority"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("When multiple filtering mechanisms are active, they are applied in this order:")} />
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> <strong> {"Test.only"->Node.text} </strong> {" — Highest priority. When any test has Only mode, only those tests run."->Node.text} </li>
      <li> <strong> {"Test.skip"->Node.text} </strong> {" — Always skipped, regardless of other filters."->Node.text} </li>
      <li> <strong> {"Filter/skip patterns"->Node.text} </strong> {" — Applied to remaining tests."->Node.text} </li>
      <li> <strong> {"Normal mode"->Node.text} </strong> {" — Runs if not filtered out."->Node.text} </li>
    </ul>
    <EditOnGitHub pageName="Pages__ApiRunner" />
  </div>
}
