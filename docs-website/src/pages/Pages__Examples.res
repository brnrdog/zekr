open Xote
open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    <Typography text={static("Examples")} variant={H1} />
    <Typography
      text={static("Complete examples showing common testing patterns with zekr.")}
      variant={Lead}
    />
    <Separator />
    // Basic Test Suite
    <div class="heading-anchor" id="basic-suite">
      <Typography text={static("Basic Test Suite")} variant={H2} />
      <a class="anchor-link" href="#basic-suite"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("A simple test file demonstrating the core API.")} />
    <CodeBlock
      language="rescript"
      code={`open Zekr

let mathSuite = Suite.make("Math Operations", [
  Test.make("addition", () => Assert.equal(2 + 3, 5)),
  Test.make("multiplication", () => Assert.equal(4 * 5, 20)),
  Test.make("comparison", () => Assert.greaterThan(10, 5)),
  Test.make("negative numbers", () => Assert.lessThan(-1, 0)),
])

let stringSuite = Suite.make("String Operations", [
  Test.make("contains substring", () => {
    Assert.contains("hello world", "world")
  }),
  Test.make("matches pattern", () => {
    Assert.matches("user@example.com", %re("/^[^@]+@[^@]+$/"))
  }),
  Test.make("multiple assertions", () => {
    Assert.combineResults([
      Assert.equal(String.trim("  hi  "), "hi"),
      Assert.equal(String.toUpperCase("hello"), "HELLO"),
      Assert.contains("foobar", "bar"),
    ])
  }),
])

let optionSuite = Suite.make("Option Handling", [
  Test.make("Some value", () => Assert.some(Some(42))),
  Test.make("None value", () => Assert.none(None)),
  Test.make("array lookup", () => {
    let arr = [10, 20, 30]
    Assert.combineResults([
      Assert.some(arr->Array.get(0)),
      Assert.none(arr->Array.get(5)),
    ])
  }),
])

Runner.runSuites([mathSuite, stringSuite, optionSuite])`}
    />
    <Separator />
    // Async Tests
    <div class="heading-anchor" id="async-example">
      <Typography text={static("Async Test Suite")} variant={H2} />
      <a class="anchor-link" href="#async-example"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Testing asynchronous operations with timeouts.")} />
    <CodeBlock
      language="rescript"
      code={`open Zekr

let asyncSuite = Suite.async(
  "Async Operations",
  [
    Test.async("resolves a promise", async () => {
      let value = await Promise.resolve(42)
      Assert.equal(value, 42)
    }),
    Test.async("handles timeout", async () => {
      // This test will fail if it takes more than 1 second
      let result = await slowOperation()
      Assert.ok(result)
    }, ~timeout=Some(1000)),
    Test.async("multiple async assertions", async () => {
      let (a, b) = await Promise.all2((
        Promise.resolve(1),
        Promise.resolve(2),
      ))
      await Assert.combineAsyncResults([
        Promise.resolve(Assert.equal(a, 1)),
        Promise.resolve(Assert.equal(b, 2)),
      ])
    }),
  ],
)

Runner.runAsyncSuites([asyncSuite])`}
    />
    <Separator />
    // DOM Testing
    <div class="heading-anchor" id="dom-example">
      <Typography text={static("DOM Testing")} variant={H2} />
      <a class="anchor-link" href="#dom-example"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Testing DOM elements with queries, events, and assertions.")} />
    <CodeBlock
      language="rescript"
      code={`open Zekr

let buttonSuite = Suite.make(
  "Button Behavior",
  [
    Test.make("renders with correct text", () => {
      let {container} = DomTesting.render("<button>Click Me</button>")
      let btn = DomTesting.Query.getByRole(container, "button")
      DomTesting.Assert.toHaveTextContent(btn, "Click Me")
    }),
    Test.make("can be disabled", () => {
      let {container} = DomTesting.render(\`<button disabled>Save</button>\`)
      let btn = DomTesting.Query.getByRole(container, "button")
      DomTesting.Assert.toBeDisabled(btn)
    }),
  ],
  ~afterEach=Some(() => DomTesting.cleanup()),
)

let formSuite = Suite.make(
  "Form Interactions",
  [
    Test.make("accepts text input", () => {
      let {container} = DomTesting.render(\`
        <label for="name">Name</label>
        <input id="name" type="text" />
      \`)
      let input = DomTesting.Query.getByLabelText(container, "Name")
      DomTesting.Event.typeText(input, "Alice")
      DomTesting.Assert.toHaveValue(input, "Alice")
    }),
    Test.make("toggles checkbox", () => {
      let {container} = DomTesting.render(\`
        <input type="checkbox" aria-label="Accept terms" />
      \`)
      let cb = DomTesting.Query.getByRole(container, "checkbox")

      DomTesting.Assert.toNotBeChecked(cb)
      DomTesting.Event.check(cb)
      DomTesting.Assert.toBeChecked(cb)
    }),
    Test.make("element not found returns None", () => {
      let {container} = DomTesting.render("<div>Hello</div>")
      DomTesting.Assert.toNotBeInTheDocument(
        DomTesting.Query.queryByText(container, "Goodbye")
      )
    }),
  ],
  ~afterEach=Some(() => DomTesting.cleanup()),
)

Runner.runSuites([buttonSuite, formSuite])`}
    />
    <Separator />
    // Lifecycle Hooks
    <div class="heading-anchor" id="hooks-example">
      <Typography text={static("Lifecycle Hooks")} variant={H2} />
      <a class="anchor-link" href="#hooks-example"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Using setup and teardown hooks for shared state.")} />
    <CodeBlock
      language="rescript"
      code={`open Zekr

let items: ref<array<string>> = ref([])

let hooksSuite = Suite.make(
  "With Hooks",
  [
    Test.make("starts empty", () => {
      Assert.equal(items.contents, [])
    }),
    Test.make("can add items", () => {
      items := Array.concat(items.contents, ["hello"])
      Assert.equal(Array.length(items.contents), 1)
    }),
  ],
  ~beforeEach=Some(() => {
    items := []
  }),
  ~beforeAll=Some(() => {
    Console.log("Starting test suite")
  }),
  ~afterAll=Some(() => {
    Console.log("All tests complete")
  }),
)

Runner.runSuites([hooksSuite])`}
    />
    <Separator />
    // Snapshot Testing
    <div class="heading-anchor" id="snapshot-example">
      <Typography text={static("Snapshot Testing")} variant={H2} />
      <a class="anchor-link" href="#snapshot-example"> {"#"->Component.text} </a>
    </div>
    <CodeBlock
      language="rescript"
      code={`open Zekr

let snapshotSuite = Suite.make("Snapshots", [
  Test.make("config snapshot", () => {
    let config = {
      "theme": "dark",
      "language": "en",
      "features": ["auth", "dashboard"],
    }
    Snapshot.matches(config, ~name="app-config")
  }),
])

Runner.runSuites([snapshotSuite])`}
    />
    <EditOnGitHub pageName="Pages__Examples" />
  </div>
}
