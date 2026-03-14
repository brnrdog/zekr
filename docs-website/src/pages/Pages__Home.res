open Xote

// ---- Helper bindings ----
module DomHelpers = {
  type clipboard
  @val @scope("navigator") external clipboard: clipboard = "clipboard"
  @send external writeText: (clipboard, string) => Promise.t<unit> = "writeText"

  let copyToClipboard = (text: string): unit => {
    clipboard->writeText(text)->ignore
  }

  @val external setTimeout: (unit => unit, int) => int = "setTimeout"
}

// ---- Feature data ----
type feature = {
  title: string,
  description: string,
  iconName: Basefn.Icon.name,
  linkText: option<string>,
  linkTo: option<string>,
}

let features = [
  {
    title: "Simple API",
    description: "Just test, suite, and assertions. No magic, no ceremony — write tests that read like documentation.",
    iconName: Basefn.Icon.Check,
    linkText: Some("API Reference"),
    linkTo: Some("/api/tests"),
  },
  {
    title: "Sync & Async Tests",
    description: "First-class support for both synchronous and asynchronous tests with configurable timeouts.",
    iconName: Basefn.Icon.Loader,
    linkText: Some("Learn more"),
    linkTo: Some("/api/tests"),
  },
  {
    title: "DOM Testing",
    description: "Built-in DOM testing with jsdom. Query elements, simulate events, and assert on the DOM — inspired by Testing Library.",
    iconName: Basefn.Icon.Edit,
    linkText: Some("DOM Testing docs"),
    linkTo: Some("/api/dom"),
  },
  {
    title: "Snapshot Testing",
    description: "Capture and compare snapshots of your data. Great for catching unexpected changes in complex outputs.",
    iconName: Basefn.Icon.Copy,
    linkText: Some("Snapshot docs"),
    linkTo: Some("/api/snapshots"),
  },
  {
    title: "Type-Safe by Default",
    description: "Built for ReScript's powerful type system. Every assertion is type-checked at compile time.",
    iconName: Basefn.Icon.Star,
    linkText: None,
    linkTo: None,
  },
  {
    title: "Zero Configuration",
    description: "Install and start testing. No config files, no setup scripts — just import and go.",
    iconName: Basefn.Icon.Download,
    linkText: Some("Get started"),
    linkTo: Some("/getting-started"),
  },
]

// ---- Feature Card ----
module FeatureCard = {
  type props = {feature: feature}

  let make = (props: props) => {
    let {feature: f} = props
    <div class="feature-card">
      <div class="feature-card-icon">
        {Basefn.Icon.make({name: f.iconName, size: Md})}
      </div>
      <h3> {Component.text(f.title)} </h3>
      <p> {Component.text(f.description)} </p>
      {switch (f.linkText, f.linkTo) {
      | (Some(text), Some(to)) =>
        Router.link(
          ~to,
          ~attrs=[Component.attr("class", "feature-card-link")],
          ~children=[
            Component.text(text ++ " "),
            Basefn.Icon.make({name: ChevronRight, size: Sm}),
          ],
          (),
        )
      | _ => Component.fragment([])
      }}
    </div>
  }
}

// ---- Hero ----
module Hero = {
  type props = {}

  let make = (_props: props) => {
    <section class="hero">
      <div class="hero-inner">
        <div class="hero-logo">
          <span class="hero-logo-text"> {Component.text("zekr")} </span>
        </div>
        <h1>
          {Component.text("A ")}
          <em> {Component.text("simple")} </em>
          {Component.text(" test framework for ")}
          <em> {Component.text("ReScript")} </em>
        </h1>
        <p class="hero-subtitle">
          {Component.text(
            "Sync and async tests, DOM testing, snapshots, and more \u2014 with zero configuration. Write tests that read like documentation.",
          )}
        </p>
        <div class="hero-buttons">
          {Router.link(
            ~to="/getting-started",
            ~attrs=[Component.attr("class", "btn btn-primary")],
            ~children=[
              Component.text("Get Started "),
              Basefn.Icon.make({name: ChevronRight, size: Sm}),
            ],
            (),
          )}
          <a href="https://github.com/brnrdog/zekr" target="_blank" class="btn btn-ghost">
            {Basefn.Icon.make({name: GitHub, size: Sm})}
            {Component.text(" View on GitHub")}
          </a>
        </div>
      </div>
    </section>
  }
}

// ---- Features Section ----
module Features = {
  type props = {}

  let make = (_props: props) => {
    <section class="features-section">
      <div class="features-inner">
        <div class="features-heading">
          <h2> {Component.text("Everything you need for testing ReScript")} </h2>
          <p>
            {Component.text(
              "A focused test framework with expressive assertions, DOM testing, and snapshot support \u2014 all type-safe.",
            )}
          </p>
        </div>
        <div class="features-grid">
          {Component.fragment(features->Array.map(f => <FeatureCard feature={f} />))}
        </div>
      </div>
    </section>
  }
}

// ---- Interactive Code Demo ----
module CodeDemo = {
  type props = {}

  let testCode = `open Zekr

let mathSuite = suite("Math", [
  test("addition", () =>
    assertEqual(1 + 1, 2)
  ),
  test("greater than", () =>
    assertGreaterThan(10, 5)
  ),
])

runSuites([mathSuite])`

  let asyncCode = `open Zekr

let apiSuite = asyncSuite("API", [
  asyncTest("fetches data", async () => {
    let data = await fetchData()
    assertEqual(data.status, "ok")
  }, ~timeout=Some(5000)),
])

runAsyncSuites([apiSuite])`

  let domCode = `open Zekr

let {container} = Dom.render(
  "<button>Click me</button>"
)

let btn =
  Dom.Query.getByRole(container, "button")

Dom.Event.click(btn)
Dom.Assert.toHaveTextContent(
  btn, "Click me"
)`

  let testOutput = `  Math
    \u2713 addition
    \u2713 greater than

  2 passing (3ms)`

  let asyncOutput = `  API
    \u2713 fetches data (120ms)

  1 passing (125ms)`

  let domOutput = `  DOM
    \u2713 button renders correctly
    \u2713 click handler fires
    \u2713 text content matches

  3 passing (8ms)`

  let make = (_props: props) => {
    let activeTab = Signal.make("test")
    let copied = Signal.make(false)

    let setTab = (tab: string) => (_evt: Dom.event) => Signal.set(activeTab, tab)

    let handleCopy = (_evt: Dom.event) => {
      let snippet = switch Signal.peek(activeTab) {
      | "test" => testCode
      | "async" => asyncCode
      | _ => domCode
      }
      DomHelpers.copyToClipboard(snippet)
      Signal.set(copied, true)
      let _ = DomHelpers.setTimeout(() => Signal.set(copied, false), 2000)
    }

    <section class="code-demo-section">
      <div class="code-demo-inner">
        <div class="code-demo-heading">
          <h2> {Component.text("Tests, async, and DOM testing")} </h2>
          <p>
            {Component.text(
              "Three powerful capabilities in a clean, functional API. Write expressive tests with zero boilerplate.",
            )}
          </p>
        </div>
        <div class="code-demo-container">
          <div class="code-editor-pane">
            <div class="code-editor-tabs">
              {Component.element(
                "div",
                ~attrs=[
                  Component.computedAttr("class", () =>
                    "code-editor-tab" ++ (Signal.get(activeTab) == "test" ? " active" : "")
                  ),
                ],
                ~events=[("click", setTab("test"))],
                ~children=[Component.text("Test.res")],
                (),
              )}
              {Component.element(
                "div",
                ~attrs=[
                  Component.computedAttr("class", () =>
                    "code-editor-tab" ++ (Signal.get(activeTab) == "async" ? " active" : "")
                  ),
                ],
                ~events=[("click", setTab("async"))],
                ~children=[Component.text("Async.res")],
                (),
              )}
              {Component.element(
                "div",
                ~attrs=[
                  Component.computedAttr("class", () =>
                    "code-editor-tab" ++ (Signal.get(activeTab) == "dom" ? " active" : "")
                  ),
                ],
                ~events=[("click", setTab("dom"))],
                ~children=[Component.text("Dom.res")],
                (),
              )}
            </div>
            <div class="code-editor-body">
              {Component.element(
                "button",
                ~attrs=[
                  Component.computedAttr("class", () =>
                    "code-copy-btn" ++ (Signal.get(copied) ? " copied" : "")
                  ),
                ],
                ~events=[("click", handleCopy)],
                ~children=[
                  Component.signalFragment(
                    Computed.make(() =>
                      Signal.get(copied)
                        ? [Basefn.Icon.make({name: Check, size: Sm}), Component.text(" Copied")]
                        : [Basefn.Icon.make({name: Copy, size: Sm}), Component.text(" Copy")]
                    ),
                  ),
                ],
                (),
              )}
              <pre class="code-editor-pre">
                <code>
                  {Component.signalFragment(
                    Computed.make(() => {
                      let code = switch Signal.get(activeTab) {
                      | "test" => testCode
                      | "async" => asyncCode
                      | _ => domCode
                      }
                      [SyntaxHighlight.highlight(code)]
                    }),
                  )}
                </code>
              </pre>
            </div>
          </div>
          <div class="code-preview-pane">
            <div class="code-preview-header">
              <div class="browser-dots">
                <span class="browser-dot browser-dot-red" />
                <span class="browser-dot browser-dot-yellow" />
                <span class="browser-dot browser-dot-green" />
              </div>
              <div class="browser-url"> {Component.text("terminal")} </div>
            </div>
            <div class="code-preview-body">
              <div class="terminal-output">
                {Component.signalFragment(
                  Computed.make(() => {
                    let output = switch Signal.get(activeTab) {
                    | "test" => testOutput
                    | "async" => asyncOutput
                    | _ => domOutput
                    }
                    [<pre style="margin: 0; font-family: inherit; font-size: inherit; white-space: pre-wrap;"> {Component.text(output)} </pre>]
                  }),
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  }
}

// ---- Community Section ----
module Community = {
  type props = {}

  let make = (_props: props) => {
    <section class="community-section">
      <div class="community-inner">
        <h2> {Component.text("Ready to get started?")} </h2>
        <p>
          {Component.text(
            "Install zekr and start writing tests for your ReScript project in minutes. No configuration needed.",
          )}
        </p>
        <div class="community-links">
          {Router.link(
            ~to="/getting-started",
            ~attrs=[Component.attr("class", "btn btn-primary")],
            ~children=[Component.text("Read the Docs")],
            (),
          )}
          <a href="https://github.com/brnrdog/zekr" target="_blank" class="btn btn-ghost">
            {Basefn.Icon.make({name: GitHub, size: Sm})}
            {Component.text(" GitHub")}
          </a>
          <a href="https://www.npmjs.com/package/zekr" target="_blank" class="btn btn-ghost">
            {Basefn.Icon.make({name: Download, size: Sm})}
            {Component.text(" npm")}
          </a>
        </div>
      </div>
    </section>
  }
}

// ---- Main page component ----
@jsx.component
let make = () => {
  <Layout children={Component.fragment([<Hero />, <Features />, <CodeDemo />, <Community />])} />
}
