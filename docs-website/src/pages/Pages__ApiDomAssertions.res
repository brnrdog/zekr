open Xote
open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    <Typography text={static("DOM Assertions")} variant={H1} />
    <Typography
      text={static("Assert on DOM element state — presence, text content, attributes, visibility, form values, and more. All return testResult.")}
      variant={Lead}
    />
    <Separator />
    // Presence
    <div class="heading-anchor" id="presence">
      <Typography text={static("Presence")} variant={H2} />
      <a class="anchor-link" href="#presence"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-be-in-document">
      <Typography text={static("DomTesting.Assert.toBeInTheDocument(element)")} variant={H3} />
      <a class="anchor-link" href="#to-be-in-document"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that an element is present in the document.")} />
    <div class="heading-anchor" id="to-not-be-in-document">
      <Typography text={static("DomTesting.Assert.toNotBeInTheDocument(option)")} variant={H3} />
      <a class="anchor-link" href="#to-not-be-in-document"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that an element is not present. Takes option<Dom.element> — typically from a queryBy* call.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = DomTesting.render("<p>Hello</p>")

DomTesting.Assert.toBeInTheDocument(DomTesting.Query.getByText(container, "Hello"))
DomTesting.Assert.toNotBeInTheDocument(DomTesting.Query.queryByText(container, "Goodbye"))`}
    />
    <Separator />
    // Text Content
    <div class="heading-anchor" id="text-content">
      <Typography text={static("Text Content")} variant={H2} />
      <a class="anchor-link" href="#text-content"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-have-text-content">
      <Typography text={static("DomTesting.Assert.toHaveTextContent(element, text, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#to-have-text-content"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that an element has the expected text content.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = DomTesting.render("<h1>Welcome Back</h1>")
let heading = DomTesting.Query.getByRole(container, "heading")
DomTesting.Assert.toHaveTextContent(heading, "Welcome Back")`}
    />
    <Separator />
    // Attributes
    <div class="heading-anchor" id="attributes">
      <Typography text={static("Attributes")} variant={H2} />
      <a class="anchor-link" href="#attributes"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-have-attribute">
      <Typography text={static("DomTesting.Assert.toHaveAttribute(element, name, ~value?)")} variant={H3} />
      <a class="anchor-link" href="#to-have-attribute"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that an element has a specific attribute, optionally with a specific value.")} />
    <div class="heading-anchor" id="to-not-have-attribute">
      <Typography text={static("DomTesting.Assert.toNotHaveAttribute(element, name)")} variant={H3} />
      <a class="anchor-link" href="#to-not-have-attribute"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that an element does not have a specific attribute.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = DomTesting.render(\`<a href="/about" target="_blank">About</a>\`)
let link = DomTesting.Query.getByRole(container, "link")

DomTesting.Assert.toHaveAttribute(link, "href", ~value=Some("/about"))
DomTesting.Assert.toHaveAttribute(link, "target")
DomTesting.Assert.toNotHaveAttribute(link, "disabled")`}
    />
    <Separator />
    // Classes
    <div class="heading-anchor" id="classes">
      <Typography text={static("Classes")} variant={H2} />
      <a class="anchor-link" href="#classes"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-have-class">
      <Typography text={static("DomTesting.Assert.toHaveClass(element, className)")} variant={H3} />
      <a class="anchor-link" href="#to-have-class"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that an element has a CSS class. Can check multiple classes (space-separated).")} />
    <div class="heading-anchor" id="to-not-have-class">
      <Typography text={static("DomTesting.Assert.toNotHaveClass(element, className)")} variant={H3} />
      <a class="anchor-link" href="#to-not-have-class"> {"#"->Node.text} </a>
    </div>
    <CodeBlock
      language="rescript"
      code={`let {container} = DomTesting.render(\`<div class="card active">Content</div>\`)
let el = DomTesting.Query.getByText(container, "Content")

DomTesting.Assert.toHaveClass(el, "card")
DomTesting.Assert.toHaveClass(el, "active")
DomTesting.Assert.toNotHaveClass(el, "hidden")`}
    />
    <Separator />
    // Visibility
    <div class="heading-anchor" id="visibility">
      <Typography text={static("Visibility")} variant={H2} />
      <a class="anchor-link" href="#visibility"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-be-visible">
      <Typography text={static("DomTesting.Assert.toBeVisible(element)")} variant={H3} />
      <a class="anchor-link" href="#to-be-visible"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that an element is visible. Checks display, visibility, opacity, and hidden attribute.")} />
    <div class="heading-anchor" id="to-not-be-visible">
      <Typography text={static("DomTesting.Assert.toNotBeVisible(element)")} variant={H3} />
      <a class="anchor-link" href="#to-not-be-visible"> {"#"->Node.text} </a>
    </div>
    <Separator />
    // Form State
    <div class="heading-anchor" id="form-state">
      <Typography text={static("Form State")} variant={H2} />
      <a class="anchor-link" href="#form-state"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-be-disabled">
      <Typography text={static("DomTesting.Assert.toBeDisabled(element)")} variant={H3} />
      <a class="anchor-link" href="#to-be-disabled"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-be-enabled">
      <Typography text={static("DomTesting.Assert.toBeEnabled(element)")} variant={H3} />
      <a class="anchor-link" href="#to-be-enabled"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-have-value">
      <Typography text={static("DomTesting.Assert.toHaveValue(element, value)")} variant={H3} />
      <a class="anchor-link" href="#to-have-value"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-be-checked">
      <Typography text={static("DomTesting.Assert.toBeChecked(element)")} variant={H3} />
      <a class="anchor-link" href="#to-be-checked"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-not-be-checked">
      <Typography text={static("DomTesting.Assert.toNotBeChecked(element)")} variant={H3} />
      <a class="anchor-link" href="#to-not-be-checked"> {"#"->Node.text} </a>
    </div>
    <CodeBlock
      language="rescript"
      code={`let {container} = DomTesting.render(\`
  <input type="text" value="hello" />
  <button disabled>Submit</button>
  <input type="checkbox" checked />
\`)

DomTesting.Assert.toHaveValue(
  DomTesting.Query.getByRole(container, "textbox"), "hello"
)
DomTesting.Assert.toBeDisabled(
  DomTesting.Query.getByRole(container, "button")
)
DomTesting.Assert.toBeChecked(
  DomTesting.Query.getByRole(container, "checkbox")
)`}
    />
    <Separator />
    // Containment
    <div class="heading-anchor" id="containment">
      <Typography text={static("Containment")} variant={H2} />
      <a class="anchor-link" href="#containment"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-contain-element">
      <Typography text={static("DomTesting.Assert.toContainElement(parent, child)")} variant={H3} />
      <a class="anchor-link" href="#to-contain-element"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-not-contain-element">
      <Typography text={static("DomTesting.Assert.toNotContainElement(parent, child)")} variant={H3} />
      <a class="anchor-link" href="#to-not-contain-element"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-contain-html">
      <Typography text={static("DomTesting.Assert.toContainHTML(element, html)")} variant={H3} />
      <a class="anchor-link" href="#to-contain-html"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-be-empty">
      <Typography text={static("DomTesting.Assert.toBeEmptyDOMElement(element)")} variant={H3} />
      <a class="anchor-link" href="#to-be-empty"> {"#"->Node.text} </a>
    </div>
    <Separator />
    // Style & Focus
    <div class="heading-anchor" id="style-focus">
      <Typography text={static("Style & Focus")} variant={H2} />
      <a class="anchor-link" href="#style-focus"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-have-style">
      <Typography text={static("DomTesting.Assert.toHaveStyle(element, property, value)")} variant={H3} />
      <a class="anchor-link" href="#to-have-style"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that an element has a specific inline or computed style.")} />
    <div class="heading-anchor" id="to-have-focus">
      <Typography text={static("DomTesting.Assert.toHaveFocus(element)")} variant={H3} />
      <a class="anchor-link" href="#to-have-focus"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="to-not-have-focus">
      <Typography text={static("DomTesting.Assert.toNotHaveFocus(element)")} variant={H3} />
      <a class="anchor-link" href="#to-not-have-focus"> {"#"->Node.text} </a>
    </div>
    <CodeBlock
      language="rescript"
      code={`let {container} = DomTesting.render(\`<input type="text" />\`)
let input = DomTesting.Query.getByRole(container, "textbox")

DomTesting.Event.focus(input)
DomTesting.Assert.toHaveFocus(input)

DomTesting.Event.blur(input)
DomTesting.Assert.toNotHaveFocus(input)`}
    />
    <EditOnGitHub pageName="Pages__ApiDomAssertions" />
  </div>
}
