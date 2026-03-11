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

let mathSuite = suite("Math Operations", [
  test("addition", () => assertEqual(2 + 3, 5)),
  test("multiplication", () => assertEqual(4 * 5, 20)),
  test("comparison", () => assertGreaterThan(10, 5)),
  test("negative numbers", () => assertLessThan(-1, 0)),
])

let stringSuite = suite("String Operations", [
  test("contains substring", () => {
    assertContains("hello world", "world")
  }),
  test("matches pattern", () => {
    assertMatch("user@example.com", %re("/^[^@]+@[^@]+$/"))
  }),
  test("multiple assertions", () => {
    combineResults([
      assertEqual(String.trim("  hi  "), "hi"),
      assertEqual(String.toUpperCase("hello"), "HELLO"),
      assertContains("foobar", "bar"),
    ])
  }),
])

let optionSuite = suite("Option Handling", [
  test("Some value", () => assertSome(Some(42))),
  test("None value", () => assertNone(None)),
  test("array lookup", () => {
    let arr = [10, 20, 30]
    combineResults([
      assertSome(arr->Array.get(0)),
      assertNone(arr->Array.get(5)),
    ])
  }),
])

runSuites([mathSuite, stringSuite, optionSuite])`}
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

let asyncSuite = asyncSuite(
  "Async Operations",
  [
    asyncTest("resolves a promise", async () => {
      let value = await Promise.resolve(42)
      assertEqual(value, 42)
    }),
    asyncTest("handles timeout", async () => {
      // This test will fail if it takes more than 1 second
      let result = await slowOperation()
      assertOk(result)
    }, ~timeout=Some(1000)),
    asyncTest("multiple async assertions", async () => {
      let (a, b) = await Promise.all2((
        Promise.resolve(1),
        Promise.resolve(2),
      ))
      await combineAsyncResults([
        Promise.resolve(assertEqual(a, 1)),
        Promise.resolve(assertEqual(b, 2)),
      ])
    }),
  ],
)

runAsyncSuites([asyncSuite])`}
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

let buttonSuite = suite(
  "Button Behavior",
  [
    test("renders with correct text", () => {
      let {container} = Dom.render("<button>Click Me</button>")
      let btn = Dom.Query.getByRole(container, "button")
      Dom.Assert.toHaveTextContent(btn, "Click Me")
    }),
    test("can be disabled", () => {
      let {container} = Dom.render(\`<button disabled>Save</button>\`)
      let btn = Dom.Query.getByRole(container, "button")
      Dom.Assert.toBeDisabled(btn)
    }),
  ],
  ~afterEach=Some(() => Dom.cleanup()),
)

let formSuite = suite(
  "Form Interactions",
  [
    test("accepts text input", () => {
      let {container} = Dom.render(\`
        <label for="name">Name</label>
        <input id="name" type="text" />
      \`)
      let input = Dom.Query.getByLabelText(container, "Name")
      Dom.Event.typeText(input, "Alice")
      Dom.Assert.toHaveValue(input, "Alice")
    }),
    test("toggles checkbox", () => {
      let {container} = Dom.render(\`
        <input type="checkbox" aria-label="Accept terms" />
      \`)
      let cb = Dom.Query.getByRole(container, "checkbox")

      Dom.Assert.toNotBeChecked(cb)
      Dom.Event.check(cb)
      Dom.Assert.toBeChecked(cb)
    }),
    test("element not found returns None", () => {
      let {container} = Dom.render("<div>Hello</div>")
      Dom.Assert.toNotBeInTheDocument(
        Dom.Query.queryByText(container, "Goodbye")
      )
    }),
  ],
  ~afterEach=Some(() => Dom.cleanup()),
)

runSuites([buttonSuite, formSuite])`}
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

let hooksSuite = suite(
  "With Hooks",
  [
    test("starts empty", () => {
      assertEqual(items.contents, [])
    }),
    test("can add items", () => {
      items := Array.concat(items.contents, ["hello"])
      assertEqual(Array.length(items.contents), 1)
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

runSuites([hooksSuite])`}
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

let snapshotSuite = suite("Snapshots", [
  test("config snapshot", () => {
    let config = {
      "theme": "dark",
      "language": "en",
      "features": ["auth", "dashboard"],
    }
    assertMatchesSnapshot(config, ~name="app-config")
  }),
])

runSuites([snapshotSuite])`}
    />
    <EditOnGitHub pageName="Pages__Examples" />
  </div>
}
