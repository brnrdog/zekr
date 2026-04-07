open Xote
open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    <Typography text={static("DOM Testing")} variant={H1} />
    <Typography
      text={static("Render HTML, query elements, simulate events, and assert on the DOM — all powered by jsdom. Inspired by Testing Library.")}
      variant={Lead}
    />
    <Separator />
    <div class="heading-anchor" id="overview">
      <Typography text={static("Overview")} variant={H2} />
      <a class="anchor-link" href="#overview"> {"#"->Component.text} </a>
    </div>
    <Typography
      text={static(
        "Zekr provides a comprehensive DOM testing module through Zekr.Dom. It includes submodules for querying elements, simulating user events, and making assertions about the DOM state.",
      )}
    />
    <CodeBlock
      language="rescript"
      code={`open Zekr

// The Dom module provides:
// - DomTesting.render / DomTesting.cleanup     — rendering & cleanup
// - DomTesting.Query                    — finding elements
// - DomTesting.Event                    — simulating user interactions
// - DomTesting.Assert                   — asserting on DOM state`}
    />
    <Separator />
    <div class="heading-anchor" id="rendering">
      <Typography text={static("Rendering")} variant={H2} />
      <a class="anchor-link" href="#rendering"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="dom-render">
      <Typography text={static("DomTesting.render(html)")} variant={H3} />
      <a class="anchor-link" href="#dom-render"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Renders an HTML string into a jsdom container. Returns a renderResult with container and baseElement.")} />
    <CodeBlock
      language="rescript"
      code={`let {container, baseElement} = DomTesting.render("<div>Hello World</div>")

// container — the div that wraps your rendered HTML
// baseElement — the document.body`}
    />
    <div class="heading-anchor" id="dom-cleanup">
      <Typography text={static("DomTesting.cleanup()")} variant={H3} />
      <a class="anchor-link" href="#dom-cleanup"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Cleans up the most recently rendered container. Call this after each test to avoid state leaking between tests.")} />
    <CodeBlock
      language="rescript"
      code={`let domSuite = Suite.make(
  "DOM Tests",
  [
    Test.make("renders content", () => {
      let {container} = DomTesting.render("<p>Hello</p>")
      DomTesting.Assert.toHaveTextContent(container, "Hello")
    }),
  ],
  ~afterEach=Some(() => DomTesting.cleanup()),
)`}
    />
    <div class="heading-anchor" id="dom-cleanup-all">
      <Typography text={static("DomTesting.cleanupAll()")} variant={H3} />
      <a class="anchor-link" href="#dom-cleanup-all"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Resets the entire DOM environment. Use this for a complete reset between test suites.")} />
    <Separator />
    <div class="heading-anchor" id="submodules">
      <Typography text={static("Submodules")} variant={H2} />
      <a class="anchor-link" href="#submodules"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("The DOM module is organized into three submodules:")} />
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li>
        <strong> {"DomTesting.Query"->Component.text} </strong>
        {" — Find elements by text, role, test ID, label, placeholder, and more. "->Component.text}
        <Router.Link to="/api/dom/queries" style="color: var(--basefn-color-primary);"> {"See Queries →"->Component.text} </Router.Link>
      </li>
      <li>
        <strong> {"DomTesting.Event"->Component.text} </strong>
        {" — Simulate user interactions: click, type, check, select, focus, and blur. "->Component.text}
        <Router.Link to="/api/dom/events" style="color: var(--basefn-color-primary);"> {"See Events →"->Component.text} </Router.Link>
      </li>
      <li>
        <strong> {"DomTesting.Assert"->Component.text} </strong>
        {" — Assert on element presence, text content, attributes, visibility, and more. "->Component.text}
        <Router.Link to="/api/dom/assertions" style="color: var(--basefn-color-primary);"> {"See Assertions →"->Component.text} </Router.Link>
      </li>
    </ul>
    <Separator />
    <div class="heading-anchor" id="full-example">
      <Typography text={static("Full Example")} variant={H2} />
      <a class="anchor-link" href="#full-example"> {"#"->Component.text} </a>
    </div>
    <CodeBlock
      language="rescript"
      code={`open Zekr

let domSuite = Suite.make(
  "Login Form",
  [
    Test.make("shows input fields", () => {
      let {container} = DomTesting.render(\`
        <form>
          <label for="email">Email</label>
          <input id="email" type="text" placeholder="Enter email" />
          <label for="pass">Password</label>
          <input id="pass" type="password" placeholder="Enter password" />
          <button type="submit">Log In</button>
        </form>
      \`)

      Assert.combineResults([
        DomTesting.Assert.toBeInTheDocument(
          DomTesting.Query.getByLabelText(container, "Email")
        ),
        DomTesting.Assert.toBeInTheDocument(
          DomTesting.Query.getByRole(container, "button", ~name=Some("Log In"))
        ),
      ])
    }),
    Test.make("accepts user input", () => {
      let {container} = DomTesting.render(\`
        <input type="text" placeholder="Type here" />
      \`)

      let input = DomTesting.Query.getByPlaceholder(container, "Type here")
      DomTesting.Event.typeText(input, "hello")
      DomTesting.Assert.toHaveValue(input, "hello")
    }),
  ],
  ~afterEach=Some(() => DomTesting.cleanup()),
)

Runner.runSuites([domSuite])`}
    />
    <EditOnGitHub pageName="Pages__ApiDomTesting" />
  </div>
}
