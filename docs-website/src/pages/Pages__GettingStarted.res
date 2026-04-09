open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    <Typography text={static("Getting Started")} variant={H1} />
    <Typography
      text={static("Learn how to install and use zekr in your ReScript project.")}
      variant={Lead}
    />
    <Separator />
    <div class="heading-anchor" id="installation">
      <Typography text={static("Installation")} variant={H2} />
      <a class="anchor-link" href="#installation"> {"#"->Xote.Node.text} </a>
    </div>
    <Typography
      text={static("Install zekr using your preferred package manager:")}
    />
    <Tabs
      tabs=[
        {
          value: "npm",
          label: "npm",
          content: <CodeBlock language="bash" code="npm install zekr" />,
        },
        {
          value: "yarn",
          label: "yarn",
          content: <CodeBlock language="bash" code="yarn add zekr" />,
        },
        {
          value: "pnpm",
          label: "pnpm",
          content: <CodeBlock language="bash" code="pnpm add zekr" />,
        },
      ]
    />
    <Separator />
    <div class="heading-anchor" id="configuration">
      <Typography text={static("Configuration")} variant={H2} />
      <a class="anchor-link" href="#configuration"> {"#"->Xote.Node.text} </a>
    </div>
    <Typography text={static("Add zekr to your rescript.json dependencies:")} />
    <CodeBlock
      language="json"
      code={`{
  "dependencies": [
    "zekr"
  ]
}`}
    />
    <Typography text={static("Add a test source directory to your rescript.json:")} />
    <CodeBlock
      language="json"
      code={`{
  "sources": [
    { "dir": "src", "subdirs": true },
    { "dir": "tests", "subdirs": true, "type": "dev" }
  ]
}`}
    />
    <Separator />
    <div class="heading-anchor" id="your-first-test">
      <Typography text={static("Your First Test")} variant={H2} />
      <a class="anchor-link" href="#your-first-test"> {"#"->Xote.Node.text} </a>
    </div>
    <Typography
      text={static(
        "Create a test file in your tests directory and write your first test suite:",
      )}
    />
    <CodeBlock
      language="rescript"
      code={`open Zekr

let mathSuite = Suite.make("Math", [
  Test.make("addition works", () => {
    Assert.equal(1 + 1, 2)
  }),
  Test.make("string contains substring", () => {
    Assert.contains("hello world", "world")
  }),
  Test.make("option has value", () => {
    Assert.some(Some(42))
  }),
])

Runner.runSuites([mathSuite])`}
    />
    <Separator />
    <div class="heading-anchor" id="running-tests">
      <Typography text={static("Running Tests")} variant={H2} />
      <a class="anchor-link" href="#running-tests"> {"#"->Xote.Node.text} </a>
    </div>
    <Typography
      text={static("Build your ReScript project and run the compiled test file with Node.js:")}
    />
    <CodeBlock language="bash" code={`npx rescript && node tests/MyTests.js`} />
    <Typography
      text={static("You can also add a test script to your package.json:")}
    />
    <CodeBlock
      language="json"
      code={`{
  "scripts": {
    "test": "rescript && node tests/MyTests.js"
  }
}`}
    />
    <Separator />
    <div class="heading-anchor" id="core-concepts">
      <Typography text={static("Core Concepts")} variant={H2} />
      <a class="anchor-link" href="#core-concepts"> {"#"->Xote.Node.text} </a>
    </div>
    <Typography
      text={static(
        "Zekr is built around a few simple primitives:",
      )}
    />
    <div class="heading-anchor" id="test-results">
      <Typography text={static("Test Results")} variant={H3} />
      <a class="anchor-link" href="#test-results"> {"#"->Xote.Node.text} </a>
    </div>
    <Typography
      text={static(
        "Every assertion returns a testResult — either Pass or Fail(message). There is no implicit global state. Tests are just functions that return results.",
      )}
    />
    <CodeBlock
      language="rescript"
      code={`type testResult = Pass | Fail(string)`}
    />
    <div class="heading-anchor" id="test-modes">
      <Typography text={static("Test Modes")} variant={H3} />
      <a class="anchor-link" href="#test-modes"> {"#"->Xote.Node.text} </a>
    </div>
    <Typography
      text={static(
        "Tests can be in Normal, Skip, or Only mode. Use Test.skip to skip a test, or Test.only to run only specific tests (all other non-only tests will be skipped).",
      )}
    />
    <CodeBlock
      language="rescript"
      code={`let mySuite = Suite.make("Demo", [
  Test.make("runs normally", () => Assert.isTrue(true)),
  Test.skip("skipped for now", () => Assert.isTrue(false)),
  Test.only("only this runs", () => Assert.equal(1, 1)),
])`}
    />
    <div class="heading-anchor" id="lifecycle-hooks">
      <Typography text={static("Lifecycle Hooks")} variant={H3} />
      <a class="anchor-link" href="#lifecycle-hooks"> {"#"->Xote.Node.text} </a>
    </div>
    <Typography
      text={static(
        "Suites support beforeAll, afterAll, beforeEach, and afterEach hooks for setup and teardown logic.",
      )}
    />
    <CodeBlock
      language="rescript"
      code={`let mySuite = Suite.make(
  "With Hooks",
  [Test.make("something", () => Assert.isTrue(true))],
  ~beforeAll=Some(() => Console.log("Suite starting")),
  ~afterEach=Some(() => Console.log("Test done")),
)`}
    />
    <EditOnGitHub pageName="Pages__GettingStarted" />
  </div>
}
