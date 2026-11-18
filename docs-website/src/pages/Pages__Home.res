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

let span = (cls, text) =>
  Node.element("span", ~attrs=[Node.attr("class", cls)], ~children=[Node.text(text)], ())

// ---- Terminal output (mirrors the zekr CLI format) ----
type line =
  | Plain(string)
  | Dim(string)
  | Suite(string)
  | PassLine(string)
  | FailLine(string)
  | FailMsg(string)
  | Total(int, int)

let terminalLines = [
  Dim("$ npx zekr"),
  Plain(""),
  Suite("arithmetic"),
  Dim("--------------"),
  PassLine("adds two numbers"),
  PassLine("is positive"),
  PassLine("handles negatives"),
  Plain(""),
  Suite("login form"),
  Dim("--------------"),
  PassLine("renders the email field"),
  PassLine("types into the input"),
  FailLine("enables submit when valid"),
  FailMsg("Expected button to be enabled"),
  Plain(""),
  Dim("=================================="),
  Total(5, 1),
]

let renderLine = (l: line) =>
  switch l {
  | Plain(t) => Node.fragment([Node.text(t), Node.text("\n")])
  | Dim(t) => Node.fragment([span("t-dim", t), Node.text("\n")])
  | Suite(t) => Node.fragment([Node.text(" "), span("t-suite", t), Node.text("\n")])
  | PassLine(t) =>
    Node.fragment([Node.text("   "), span("t-pass", "✓"), Node.text(" " ++ t ++ "\n")])
  | FailLine(t) =>
    Node.fragment([Node.text("   "), span("t-fail", "✗"), Node.text(" " ++ t ++ "\n")])
  | FailMsg(t) => Node.fragment([Node.text("     "), span("t-fail", t), Node.text("\n")])
  | Total(p, f) =>
    Node.fragment([
      Node.text("Total: "),
      span("t-pass", Int.toString(p) ++ " passed"),
      Node.text(", "),
      span("t-fail", Int.toString(f) ++ " failed"),
    ])
  }

module Terminal = {
  type props = {}

  let make = (_props: props) => {
    <div class="terminal">
      <div class="terminal-bar">
        <span class="terminal-dot" />
        <span class="terminal-dot" />
        <span class="terminal-dot" />
        <span class="terminal-title"> {Node.text("npm test")} </span>
      </div>
      <pre class="terminal-body"> {Node.fragment(terminalLines->Array.map(renderLine))} </pre>
    </div>
  }
}

// ---- Install command with copy button ----
module InstallCommand = {
  type props = {}

  let command = "npm install --save-dev zekr"

  let make = (_props: props) => {
    let copied = Signal.make(false)

    Node.element(
      "button",
      ~attrs=[
        Node.attr("class", "install-cmd"),
        Node.attr("aria-label", "Copy install command"),
      ],
      ~events=[
        (
          "click",
          _ => {
            DomHelpers.copyToClipboard(command)
            Signal.set(copied, true)
            let _ = DomHelpers.setTimeout(() => Signal.set(copied, false), 2000)
          },
        ),
      ],
      ~children=[
        span("install-cmd-prompt", "$"),
        Node.text(" npm i -D zekr "),
        Node.signalFragment(
          Computed.make(() =>
            Signal.get(copied)
              ? [Basefn.Icon.make({name: Check, size: Sm})]
              : [Basefn.Icon.make({name: Copy, size: Sm})]
          ),
        ),
      ],
      (),
    )
  }
}

// ---- Hero ----
module Hero = {
  type props = {}

  let make = (_props: props) => {
    <section class="hero">
      <div class="hero-inner">
        <div class="hero-text">
          <span class="kicker"> {Node.text("TEST FRAMEWORK · RESCRIPT")} </span>
          <h1>
            {Node.text("A test framework for ")}
            <span class="accent"> {Node.text("ReScript")} </span>
          </h1>
          <p class="hero-subtitle">
            {Node.text("A suite is a list of tests. A test returns ")}
            <code class="code-pass"> {Node.text("Pass")} </code>
            {Node.text(" or ")}
            <code class="code-fail"> {Node.text("Fail(message)")} </code>
            {Node.text(
              ". Zekr also covers async tests, DOM testing, snapshots and a CLI with watch mode.",
            )}
          </p>
          <div class="hero-buttons">
            {Router.link(
              ~to="/getting-started",
              ~attrs=[Node.attr("class", "btn btn-primary")],
              ~children=[Node.text("Get started →")],
              (),
            )}
            <InstallCommand />
          </div>
        </div>
        <Terminal />
      </div>
    </section>
  }
}

// ---- Facts strip ----
module Facts = {
  type props = {}

  let facts = [
    "Zero runtime dependencies",
    "ReScript 12 and 13",
    "Watch mode re-runs only affected tests",
    "Coverage through compiler source maps",
  ]

  let make = (_props: props) => {
    <section class="facts">
      <div class="facts-inner">
        {Node.fragment(
          facts->Array.map(f =>
            <span class="fact">
              <span class="t-pass" ariaHidden=true> {Node.text("✓")} </span>
              {Node.text(f)}
            </span>
          ),
        )}
      </div>
    </section>
  }
}

// ---- Features ----
type feature = {
  tag: string,
  title: string,
  body: string,
  api: string,
  to: string,
}

let features = [
  {
    tag: "Test · Suite",
    title: "Tests and suites",
    body: "Tests and suites are plain values. Suites take optional before and after hooks. Use skip and only to narrow a run.",
    api: "Test.make · Suite.make",
    to: "/api/tests",
  },
  {
    tag: "async",
    title: "Async tests",
    body: "Async tests and async hooks, with an optional timeout per test.",
    api: "Test.async(~timeout=5000)",
    to: "/api/tests",
  },
  {
    tag: "DomTesting",
    title: "DOM testing",
    body: "Render HTML into jsdom, then query, fire events and assert on it. The API follows Testing Library.",
    api: "getByRole · typeText · toHaveValue",
    to: "/api/dom",
  },
  {
    tag: "Snapshot",
    title: "Snapshots",
    body: "The first run writes the value to a file. Later runs compare against it.",
    api: "Snapshot.matches(~name)",
    to: "/api/snapshots",
  },
  {
    tag: "zekr CLI",
    title: "CLI and watch mode",
    body: "Finds every *.test.res file and runs each in its own process. In watch mode, only the tests a change affects run again.",
    api: "zekr --watch",
    to: "/api/cli",
  },
  {
    tag: "coverage",
    title: "Coverage",
    body: "c8 reports coverage on your .res files using the compiler source maps.",
    api: "npm run coverage",
    to: "/api/coverage",
  },
]

module SectionHeading = {
  type props = {kicker: string, title: string}

  let make = (props: props) => {
    <div class="section-heading">
      <span class="kicker"> {Node.text(props.kicker)} </span>
      <h2> {Node.text(props.title)} </h2>
    </div>
  }
}

module Features = {
  type props = {}

  let make = (_props: props) => {
    <section class="section">
      <div class="section-inner">
        <SectionHeading kicker="FEATURES" title="What's included" />
        <div class="features-grid">
          {Node.fragment(
            features->Array.map(f =>
              Router.link(
                ~to=f.to,
                ~attrs=[Node.attr("class", "feature-card")],
                ~children=[
                  span("chip chip-pass", f.tag),
                  <h3> {Node.text(f.title)} </h3>,
                  <p> {Node.text(f.body)} </p>,
                  <code class="feature-card-api"> {Node.text(f.api)} </code>,
                ],
                (),
              )
            ),
          )}
        </div>
      </div>
    </section>
  }
}

// ---- How it works ----
module HowItWorks = {
  type props = {}

  let code = `open Zekr

let arithmetic = Suite.make("arithmetic", [
  Test.make("adds", () => Assert.equal(1 + 1, 2)),
  Test.make("is positive", () =>
    Assert.isTrue(1 + 1 > 0)
  ),
  Test.async("fetches", async () => {
    let user = await Api.getUser(1)
    Assert.equal(user.name, "Ada")
  }, ~timeout=5000),
])

// No runner call needed: the zekr CLI finds *.test.res`

  let make = (_props: props) => {
    <section class="section section-surface">
      <div class="section-inner split">
        <div class="split-text">
          <SectionHeading kicker="HOW IT WORKS" title="Every test returns a result" />
          <p>
            {Node.text("A test function returns a ")}
            <code> {Node.text("testResult")} </code>
            {Node.text(
              ". Assertions return one too, so a test can return an assertion directly. Assertions don't throw: a failure is a ",
            )}
            <code class="code-fail"> {Node.text("Fail")} </code>
            {Node.text(" with a message that shows the actual and expected values.")}
          </p>
          <div class="result-chips">
            <span class="result-chip result-chip-pass">
              <span class="result-dot" ariaHidden=true> {Node.text("✓")} </span>
              <code> {Node.text("Pass")} </code>
            </span>
            <span class="result-chip result-chip-fail">
              <span class="result-dot" ariaHidden=true> {Node.text("✗")} </span>
              <code> {Node.text("Fail(string)")} </code>
            </span>
          </div>
        </div>
        <div class="code-panel">
          <div class="code-panel-bar">
            <span> {Node.text("tests/Arithmetic.test.res")} </span>
            <span> {Node.text("rescript")} </span>
          </div>
          <pre class="code-panel-body"> <code> {SyntaxHighlight.highlight(code)} </code> </pre>
        </div>
      </div>
    </section>
  }
}

// ---- Setup ----
module Setup = {
  type props = {}

  let steps = [
    ("01", "Install", "npm install --save-dev zekr"),
    ("02", "Add to rescript.json", `{ "dev-dependencies": ["zekr"] }`),
    ("03", "Run", "npx zekr --watch"),
  ]

  let make = (_props: props) => {
    <section class="section">
      <div class="section-inner">
        <SectionHeading kicker="SETUP" title="Install and run" />
        <div class="steps-grid">
          {Node.fragment(
            steps->Array.map(((n, title, cmd)) =>
              <div class="step">
                <span class="step-number"> {Node.text(n)} </span>
                <h3> {Node.text(title)} </h3>
                <pre class="step-cmd"> {Node.text(cmd)} </pre>
              </div>
            ),
          )}
        </div>
      </div>
    </section>
  }
}

// ---- Call to action ----
module NextStep = {
  type props = {}

  let make = (_props: props) => {
    <section class="section section-tight">
      <div class="section-inner">
        <div class="cta-band">
          <div class="cta-text">
            <h2> {Node.text("Write your first test")} </h2>
            <p>
              {Node.text(
                "The getting started guide covers installation, a first suite and running it with the CLI.",
              )}
            </p>
          </div>
          <div class="cta-buttons">
            {Router.link(
              ~to="/getting-started",
              ~attrs=[Node.attr("class", "btn btn-inverse")],
              ~children=[Node.text("Getting started")],
              (),
            )}
            <a href="https://github.com/brnrdog/zekr" target="_blank" class="btn btn-inverse-ghost">
              {Node.text("GitHub")}
            </a>
          </div>
        </div>
      </div>
    </section>
  }
}

// ---- Main page component ----
@jsx.component
let make = () => {
  <Layout
    children={Node.fragment([
      <Hero />,
      <Facts />,
      <Features />,
      <HowItWorks />,
      <Setup />,
      <NextStep />,
    ])}
  />
}
