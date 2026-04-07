open Xote
open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    <Typography text={static("Tests & Suites")} variant={H1} />
    <Typography
      text={static("Create synchronous and asynchronous tests, organized into suites with lifecycle hooks.")}
      variant={Lead}
    />
    <Separator />
    // Synchronous Tests
    <div class="heading-anchor" id="sync-tests">
      <Typography text={static("Synchronous Tests")} variant={H2} />
      <a class="anchor-link" href="#sync-tests"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="test">
      <Typography text={static("Test.make(name, fn)")} variant={H3} />
      <a class="anchor-link" href="#test"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Creates a test case that runs normally.")} />
    <CodeBlock
      language="rescript"
      code={`let myTest = Test.make("addition works", () => {
  Assert.equal(1 + 1, 2)
})`}
    />
    <div class="heading-anchor" id="test-skip">
      <Typography text={static("Test.skip(name, fn)")} variant={H3} />
      <a class="anchor-link" href="#test-skip"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Creates a test case that is always skipped. Useful for temporarily disabling tests.")} />
    <CodeBlock
      language="rescript"
      code={`let skipped = Test.skip("work in progress", () => {
  Assert.equal(todo(), expected)
})`}
    />
    <div class="heading-anchor" id="test-only">
      <Typography text={static("Test.only(name, fn)")} variant={H3} />
      <a class="anchor-link" href="#test-only"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Creates a test case in Only mode. When any test in a suite has Only mode, only those tests run.")} />
    <CodeBlock
      language="rescript"
      code={`let focused = Test.only("debug this test", () => {
  Assert.equal(buggyFunction(), expected)
})`}
    />
    <Separator />
    // Async Tests
    <div class="heading-anchor" id="async-tests">
      <Typography text={static("Asynchronous Tests")} variant={H2} />
      <a class="anchor-link" href="#async-tests"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="async-test">
      <Typography text={static("Test.async(name, fn, ~timeout?)")} variant={H3} />
      <a class="anchor-link" href="#async-test"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Creates an asynchronous test case. The function must return a promise<testResult>. An optional timeout in milliseconds can be provided — if the test exceeds it, it automatically fails.")} />
    <CodeBlock
      language="rescript"
      code={`let myAsyncTest = Test.async("fetches data", async () => {
  let response = await fetch("/api/data")
  Assert.equal(response.status, 200)
}, ~timeout=Some(5000))`}
    />
    <div class="heading-anchor" id="async-test-skip">
      <Typography text={static("Test.asyncSkip(name, fn, ~timeout?)")} variant={H3} />
      <a class="anchor-link" href="#async-test-skip"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Creates an async test that is always skipped.")} />
    <div class="heading-anchor" id="async-test-only">
      <Typography text={static("Test.asyncOnly(name, fn, ~timeout?)")} variant={H3} />
      <a class="anchor-link" href="#async-test-only"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Creates an async test in Only mode.")} />
    <Separator />
    // Suites
    <div class="heading-anchor" id="suites">
      <Typography text={static("Test Suites")} variant={H2} />
      <a class="anchor-link" href="#suites"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="suite">
      <Typography text={static("Suite.make(name, tests, ~beforeAll?, ~afterAll?, ~beforeEach?, ~afterEach?)")} variant={H3} />
      <a class="anchor-link" href="#suite"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Creates a test suite that groups related tests together. All lifecycle hooks are optional.")} />
    <CodeBlock
      language="rescript"
      code={`let mySuite = Suite.make(
  "String Utils",
  [
    Test.make("trims whitespace", () => {
      Assert.equal(String.trim("  hello  "), "hello")
    }),
    Test.make("converts to uppercase", () => {
      Assert.equal(String.toUpperCase("hello"), "HELLO")
    }),
  ],
  ~beforeEach=Some(() => {
    Console.log("Running next test...")
  }),
)`}
    />
    <div class="heading-anchor" id="async-suite">
      <Typography text={static("Suite.async(name, tests, ~beforeAll?, ~afterAll?, ~beforeEach?, ~afterEach?)")} variant={H3} />
      <a class="anchor-link" href="#async-suite"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Creates an async test suite. Hooks are also async (return promise<unit>).")} />
    <CodeBlock
      language="rescript"
      code={`let dbSuite = Suite.async(
  "Database",
  [
    Test.async("inserts record", async () => {
      let result = await db->insert({name: "Alice"})
      Assert.ok(result)
    }),
  ],
  ~beforeAll=Some(async () => {
    await db->connect()
  }),
  ~afterAll=Some(async () => {
    await db->disconnect()
  }),
)`}
    />
    <Separator />
    // Lifecycle Hooks
    <div class="heading-anchor" id="lifecycle">
      <Typography text={static("Lifecycle Hooks")} variant={H2} />
      <a class="anchor-link" href="#lifecycle"> {"#"->Component.text} </a>
    </div>
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> <strong> {"beforeAll"->Component.text} </strong> {" — Runs once before all tests in the suite."->Component.text} </li>
      <li> <strong> {"afterAll"->Component.text} </strong> {" — Runs once after all tests in the suite."->Component.text} </li>
      <li> <strong> {"beforeEach"->Component.text} </strong> {" — Runs before each individual test."->Component.text} </li>
      <li> <strong> {"afterEach"->Component.text} </strong> {" — Runs after each individual test."->Component.text} </li>
    </ul>
    <CodeBlock
      language="rescript"
      code={`let setupSuite = Suite.make(
  "With All Hooks",
  [Test.make("example", () => Assert.isTrue(true))],
  ~beforeAll=Some(() => Console.log("Suite starting")),
  ~afterAll=Some(() => Console.log("Suite done")),
  ~beforeEach=Some(() => Console.log("Before test")),
  ~afterEach=Some(() => Console.log("After test")),
)`}
    />
    <EditOnGitHub pageName="Pages__ApiTests" />
  </div>
}
