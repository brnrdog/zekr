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
      <a class="anchor-link" href="#query-variants"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Each query type comes in three variants:")} />
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> <strong> {"getBy*"->Component.text} </strong> {" — Returns the element. Throws if not found or if multiple elements match."->Component.text} </li>
      <li> <strong> {"queryBy*"->Component.text} </strong> {" — Returns option<Dom.element>. Returns None if not found."->Component.text} </li>
      <li> <strong> {"getAllBy*"->Component.text} </strong> {" — Returns array<Dom.element>. Throws if none found."->Component.text} </li>
    </ul>
    <Separator />
    // By Text
    <div class="heading-anchor" id="by-text">
      <Typography text={static("By Text")} variant={H2} />
      <a class="anchor-link" href="#by-text"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-text">
      <Typography text={static("getByText(container, text, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-text"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Finds an element by its text content. Set ~exact=false for case-insensitive substring matching.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render("<p>Hello World</p>")

let el = Dom.Query.getByText(container, "Hello World")
let el2 = Dom.Query.getByText(container, "hello", ~exact=false)`}
    />
    <Separator />
    // By Role
    <div class="heading-anchor" id="by-role">
      <Typography text={static("By Role")} variant={H2} />
      <a class="anchor-link" href="#by-role"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-role">
      <Typography text={static("getByRole(container, role, ~name?, ~checked?, ~level?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-role"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Finds an element by its ARIA role (implicit or explicit). Supports filtering by accessible name, checked state, and heading level.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render(\`
  <button>Save</button>
  <button>Cancel</button>
  <h2>Title</h2>
  <input type="checkbox" aria-label="Agree" />
\`)

// By role
let saveBtn = Dom.Query.getByRole(container, "button", ~name=Some("Save"))

// Heading with level
let heading = Dom.Query.getByRole(container, "heading", ~level=Some(2))

// Checkbox by checked state
let checkbox = Dom.Query.getByRole(container, "checkbox", ~checked=Some(false))`}
    />
    <Typography text={static("Supported implicit roles: button, link, checkbox, radio, textbox, heading (with level), list, listitem, navigation, main, form, table, img, dialog, and more.")} />
    <Separator />
    // By Test ID
    <div class="heading-anchor" id="by-test-id">
      <Typography text={static("By Test ID")} variant={H2} />
      <a class="anchor-link" href="#by-test-id"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-test-id">
      <Typography text={static("getByTestId(container, testId)")} variant={H3} />
      <a class="anchor-link" href="#get-by-test-id"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Finds an element by its data-testid attribute.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render(\`<div data-testid="greeting">Hi</div>\`)
let el = Dom.Query.getByTestId(container, "greeting")`}
    />
    <Separator />
    // By Label
    <div class="heading-anchor" id="by-label">
      <Typography text={static("By Label Text")} variant={H2} />
      <a class="anchor-link" href="#by-label"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-label-text">
      <Typography text={static("getByLabelText(container, text, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-label-text"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Finds a form element by its associated label text (via for/id or wrapping).")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render(\`
  <label for="name">Full Name</label>
  <input id="name" type="text" />
\`)
let input = Dom.Query.getByLabelText(container, "Full Name")`}
    />
    <Separator />
    // By Placeholder
    <div class="heading-anchor" id="by-placeholder">
      <Typography text={static("By Placeholder")} variant={H2} />
      <a class="anchor-link" href="#by-placeholder"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-placeholder">
      <Typography text={static("getByPlaceholder(container, text, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-placeholder"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Finds an element by its placeholder attribute.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render(\`<input placeholder="Search..." />\`)
let input = Dom.Query.getByPlaceholder(container, "Search...")`}
    />
    <Separator />
    // By Display Value
    <div class="heading-anchor" id="by-display-value">
      <Typography text={static("By Display Value")} variant={H2} />
      <a class="anchor-link" href="#by-display-value"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-display-value">
      <Typography text={static("getByDisplayValue(container, value, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-display-value"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Finds a form input element by its current display value.")} />
    <Separator />
    // By Alt Text
    <div class="heading-anchor" id="by-alt-text">
      <Typography text={static("By Alt Text")} variant={H2} />
      <a class="anchor-link" href="#by-alt-text"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-alt-text">
      <Typography text={static("getByAltText(container, text, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-alt-text"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Finds an element (typically an image) by its alt attribute.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render(\`<img alt="User avatar" src="photo.jpg" />\`)
let img = Dom.Query.getByAltText(container, "User avatar")`}
    />
    <Separator />
    // By Title
    <div class="heading-anchor" id="by-title">
      <Typography text={static("By Title")} variant={H2} />
      <a class="anchor-link" href="#by-title"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="get-by-title">
      <Typography text={static("getByTitle(container, text, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#get-by-title"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Finds an element by its title attribute.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render(\`<span title="Close">X</span>\`)
let el = Dom.Query.getByTitle(container, "Close")`}
    />
    <EditOnGitHub pageName="Pages__ApiDomQueries" />
  </div>
}
