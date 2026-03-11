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
// - Dom.render / Dom.cleanup     — rendering & cleanup
// - Dom.Query                    — finding elements
// - Dom.Event                    — simulating user interactions
// - Dom.Assert                   — asserting on DOM state`}
    />
    <Separator />
    <div class="heading-anchor" id="rendering">
      <Typography text={static("Rendering")} variant={H2} />
      <a class="anchor-link" href="#rendering"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="dom-render">
      <Typography text={static("Dom.render(html)")} variant={H3} />
      <a class="anchor-link" href="#dom-render"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Renders an HTML string into a jsdom container. Returns a renderResult with container and baseElement.")} />
    <CodeBlock
      language="rescript"
      code={`let {container, baseElement} = Dom.render("<div>Hello World</div>")

// container — the div that wraps your rendered HTML
// baseElement — the document.body`}
    />
    <div class="heading-anchor" id="dom-cleanup">
      <Typography text={static("Dom.cleanup()")} variant={H3} />
      <a class="anchor-link" href="#dom-cleanup"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Cleans up the most recently rendered container. Call this after each test to avoid state leaking between tests.")} />
    <CodeBlock
      language="rescript"
      code={`let domSuite = suite(
  "DOM Tests",
  [
    test("renders content", () => {
      let {container} = Dom.render("<p>Hello</p>")
      Dom.Assert.toHaveTextContent(container, "Hello")
    }),
  ],
  ~afterEach=Some(() => Dom.cleanup()),
)`}
    />
    <div class="heading-anchor" id="dom-cleanup-all">
      <Typography text={static("Dom.cleanupAll()")} variant={H3} />
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
        <strong> {"Dom.Query"->Component.text} </strong>
        {" — Find elements by text, role, test ID, label, placeholder, and more. "->Component.text}
        <Router.Link to="/api/dom/queries" style="color: var(--basefn-color-primary);"> {"See Queries →"->Component.text} </Router.Link>
      </li>
      <li>
        <strong> {"Dom.Event"->Component.text} </strong>
        {" — Simulate user interactions: click, type, check, select, focus, and blur. "->Component.text}
        <Router.Link to="/api/dom/events" style="color: var(--basefn-color-primary);"> {"See Events →"->Component.text} </Router.Link>
      </li>
      <li>
        <strong> {"Dom.Assert"->Component.text} </strong>
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

let domSuite = suite(
  "Login Form",
  [
    test("shows input fields", () => {
      let {container} = Dom.render(\`
        <form>
          <label for="email">Email</label>
          <input id="email" type="text" placeholder="Enter email" />
          <label for="pass">Password</label>
          <input id="pass" type="password" placeholder="Enter password" />
          <button type="submit">Log In</button>
        </form>
      \`)

      combineResults([
        Dom.Assert.toBeInTheDocument(
          Dom.Query.getByLabelText(container, "Email")
        ),
        Dom.Assert.toBeInTheDocument(
          Dom.Query.getByRole(container, "button", ~name=Some("Log In"))
        ),
      ])
    }),
    test("accepts user input", () => {
      let {container} = Dom.render(\`
        <input type="text" placeholder="Type here" />
      \`)

      let input = Dom.Query.getByPlaceholder(container, "Type here")
      Dom.Event.typeText(input, "hello")
      Dom.Assert.toHaveValue(input, "hello")
    }),
  ],
  ~afterEach=Some(() => Dom.cleanup()),
)

runSuites([domSuite])`}
    />
    <EditOnGitHub pageName="Pages__ApiDomTesting" />
  </div>
}
