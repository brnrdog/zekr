open Xote
open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    <Typography text={static("DOM Queries")} variant={H1} />
    <Typography
      text={static("Find elements in the rendered DOM by text, role, label, placeholder, test ID, and more.")}
      variant={Lead}
    />
    <Separator />
    <div class="heading-anchor" id="query-variants">
      <Typography text={static("Query Variants")} variant={H2} />
      <a class="anchor-link" href="#query-variants"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Each query type comes in three variants:")} />
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> <strong> {"getBy*"->Node.text} </strong> {" — Returns the element. Throws if not found or if multiple elements match."->Node.text} </li>
      <li> <strong> {"queryBy*"->Node.text} </strong> {" — Returns option<Dom.element>. Returns None if not found."->Node.text} </li>
      <li> <strong> {"getAllBy*"->Node.text} </strong> {" — Returns array<Dom.element>. Throws if none found."->Node.text} </li>
    </ul>
    <Separator />
    // By Text
    <div class="heading-anchor" id="by-text">
      <Typography text={static("By Text")} variant={H2} />
      <a class="anchor-link" href="#by-text"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-text">
      <Typography text={static("getByText(container, text, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-text"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Finds an element by its text content. Set ~exact=false for case-insensitive substring matching.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = DomTesting.render("<p>Hello World</p>")

let el = DomTesting.Query.getByText(container, "Hello World")
let el2 = DomTesting.Query.getByText(container, "hello", ~exact=false)`}
    />
    <Separator />
    // By Role
    <div class="heading-anchor" id="by-role">
      <Typography text={static("By Role")} variant={H2} />
      <a class="anchor-link" href="#by-role"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-role">
      <Typography text={static("getByRole(container, role, ~name?, ~checked?, ~level?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-role"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Finds an element by its ARIA role (implicit or explicit). Supports filtering by accessible name, checked state, and heading level.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = DomTesting.render(\`
  <button>Save</button>
  <button>Cancel</button>
  <h2>Title</h2>
  <input type="checkbox" aria-label="Agree" />
\`)

// By role
let saveBtn = DomTesting.Query.getByRole(container, "button", ~name=Some("Save"))

// Heading with level
let heading = DomTesting.Query.getByRole(container, "heading", ~level=Some(2))

// Checkbox by checked state
let checkbox = DomTesting.Query.getByRole(container, "checkbox", ~checked=Some(false))`}
    />
    <Typography text={static("Supported implicit roles: button, link, checkbox, radio, textbox, heading (with level), list, listitem, navigation, main, form, table, img, dialog, and more.")} />
    <Separator />
    // By Test ID
    <div class="heading-anchor" id="by-test-id">
      <Typography text={static("By Test ID")} variant={H2} />
      <a class="anchor-link" href="#by-test-id"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-test-id">
      <Typography text={static("getByTestId(container, testId)")} variant={H3} />
      <a class="anchor-link" href="#get-by-test-id"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Finds an element by its data-testid attribute.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = DomTesting.render(\`<div data-testid="greeting">Hi</div>\`)
let el = DomTesting.Query.getByTestId(container, "greeting")`}
    />
    <Separator />
    // By Label
    <div class="heading-anchor" id="by-label">
      <Typography text={static("By Label Text")} variant={H2} />
      <a class="anchor-link" href="#by-label"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-label-text">
      <Typography text={static("getByLabelText(container, text, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-label-text"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Finds a form element by its associated label text (via for/id or wrapping).")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = DomTesting.render(\`
  <label for="name">Full Name</label>
  <input id="name" type="text" />
\`)
let input = DomTesting.Query.getByLabelText(container, "Full Name")`}
    />
    <Separator />
    // By Placeholder
    <div class="heading-anchor" id="by-placeholder">
      <Typography text={static("By Placeholder")} variant={H2} />
      <a class="anchor-link" href="#by-placeholder"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-placeholder">
      <Typography text={static("getByPlaceholder(container, text, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-placeholder"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Finds an element by its placeholder attribute.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = DomTesting.render(\`<input placeholder="Search..." />\`)
let input = DomTesting.Query.getByPlaceholder(container, "Search...")`}
    />
    <Separator />
    // By Display Value
    <div class="heading-anchor" id="by-display-value">
      <Typography text={static("By Display Value")} variant={H2} />
      <a class="anchor-link" href="#by-display-value"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-display-value">
      <Typography text={static("getByDisplayValue(container, value, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-display-value"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Finds a form input element by its current display value.")} />
    <Separator />
    // By Alt Text
    <div class="heading-anchor" id="by-alt-text">
      <Typography text={static("By Alt Text")} variant={H2} />
      <a class="anchor-link" href="#by-alt-text"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-alt-text">
      <Typography text={static("getByAltText(container, text, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-alt-text"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Finds an element (typically an image) by its alt attribute.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = DomTesting.render(\`<img alt="User avatar" src="photo.jpg" />\`)
let img = DomTesting.Query.getByAltText(container, "User avatar")`}
    />
    <Separator />
    // By Title
    <div class="heading-anchor" id="by-title">
      <Typography text={static("By Title")} variant={H2} />
      <a class="anchor-link" href="#by-title"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-title">
      <Typography text={static("getByTitle(container, text, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-title"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Finds an element by its title attribute.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = DomTesting.render(\`<span title="Close">X</span>\`)
let el = DomTesting.Query.getByTitle(container, "Close")`}
    />
    <EditOnGitHub pageName="Pages__ApiDomQueries" />
  </div>
}
