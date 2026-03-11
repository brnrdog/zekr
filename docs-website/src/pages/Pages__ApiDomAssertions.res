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
      <a class="anchor-link" href="#presence"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-be-in-document">
      <Typography text={static("Dom.Assert.toBeInTheDocument(element)")} variant={H3} />
      <a class="anchor-link" href="#to-be-in-document"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that an element is present in the document.")} />
    <div class="heading-anchor" id="to-not-be-in-document">
      <Typography text={static("Dom.Assert.toNotBeInTheDocument(option)")} variant={H3} />
      <a class="anchor-link" href="#to-not-be-in-document"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that an element is not present. Takes option<Dom.element> — typically from a queryBy* call.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render("<p>Hello</p>")

Dom.Assert.toBeInTheDocument(Dom.Query.getByText(container, "Hello"))
Dom.Assert.toNotBeInTheDocument(Dom.Query.queryByText(container, "Goodbye"))`}
    />
    <Separator />
    // Text Content
    <div class="heading-anchor" id="text-content">
      <Typography text={static("Text Content")} variant={H2} />
      <a class="anchor-link" href="#text-content"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-have-text-content">
      <Typography text={static("Dom.Assert.toHaveTextContent(element, text, ~exact?)")} variant={H3} />
      <a class="anchor-link" href="#to-have-text-content"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that an element has the expected text content.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render("<h1>Welcome Back</h1>")
let heading = Dom.Query.getByRole(container, "heading")
Dom.Assert.toHaveTextContent(heading, "Welcome Back")`}
    />
    <Separator />
    // Attributes
    <div class="heading-anchor" id="attributes">
      <Typography text={static("Attributes")} variant={H2} />
      <a class="anchor-link" href="#attributes"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-have-attribute">
      <Typography text={static("Dom.Assert.toHaveAttribute(element, name, ~value?)")} variant={H3} />
      <a class="anchor-link" href="#to-have-attribute"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that an element has a specific attribute, optionally with a specific value.")} />
    <div class="heading-anchor" id="to-not-have-attribute">
      <Typography text={static("Dom.Assert.toNotHaveAttribute(element, name)")} variant={H3} />
      <a class="anchor-link" href="#to-not-have-attribute"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that an element does not have a specific attribute.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render(\`<a href="/about" target="_blank">About</a>\`)
let link = Dom.Query.getByRole(container, "link")

Dom.Assert.toHaveAttribute(link, "href", ~value=Some("/about"))
Dom.Assert.toHaveAttribute(link, "target")
Dom.Assert.toNotHaveAttribute(link, "disabled")`}
    />
    <Separator />
    // Classes
    <div class="heading-anchor" id="classes">
      <Typography text={static("Classes")} variant={H2} />
      <a class="anchor-link" href="#classes"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-have-class">
      <Typography text={static("Dom.Assert.toHaveClass(element, className)")} variant={H3} />
      <a class="anchor-link" href="#to-have-class"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that an element has a CSS class. Can check multiple classes (space-separated).")} />
    <div class="heading-anchor" id="to-not-have-class">
      <Typography text={static("Dom.Assert.toNotHaveClass(element, className)")} variant={H3} />
      <a class="anchor-link" href="#to-not-have-class"> {"#"->Component.text} </a>
    </div>
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render(\`<div class="card active">Content</div>\`)
let el = Dom.Query.getByText(container, "Content")

Dom.Assert.toHaveClass(el, "card")
Dom.Assert.toHaveClass(el, "active")
Dom.Assert.toNotHaveClass(el, "hidden")`}
    />
    <Separator />
    // Visibility
    <div class="heading-anchor" id="visibility">
      <Typography text={static("Visibility")} variant={H2} />
      <a class="anchor-link" href="#visibility"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-be-visible">
      <Typography text={static("Dom.Assert.toBeVisible(element)")} variant={H3} />
      <a class="anchor-link" href="#to-be-visible"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that an element is visible. Checks display, visibility, opacity, and hidden attribute.")} />
    <div class="heading-anchor" id="to-not-be-visible">
      <Typography text={static("Dom.Assert.toNotBeVisible(element)")} variant={H3} />
      <a class="anchor-link" href="#to-not-be-visible"> {"#"->Component.text} </a>
    </div>
    <Separator />
    // Form State
    <div class="heading-anchor" id="form-state">
      <Typography text={static("Form State")} variant={H2} />
      <a class="anchor-link" href="#form-state"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-be-disabled">
      <Typography text={static("Dom.Assert.toBeDisabled(element)")} variant={H3} />
      <a class="anchor-link" href="#to-be-disabled"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-be-enabled">
      <Typography text={static("Dom.Assert.toBeEnabled(element)")} variant={H3} />
      <a class="anchor-link" href="#to-be-enabled"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-have-value">
      <Typography text={static("Dom.Assert.toHaveValue(element, value)")} variant={H3} />
      <a class="anchor-link" href="#to-have-value"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-be-checked">
      <Typography text={static("Dom.Assert.toBeChecked(element)")} variant={H3} />
      <a class="anchor-link" href="#to-be-checked"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-not-be-checked">
      <Typography text={static("Dom.Assert.toNotBeChecked(element)")} variant={H3} />
      <a class="anchor-link" href="#to-not-be-checked"> {"#"->Component.text} </a>
    </div>
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render(\`
  <input type="text" value="hello" />
  <button disabled>Submit</button>
  <input type="checkbox" checked />
\`)

Dom.Assert.toHaveValue(
  Dom.Query.getByRole(container, "textbox"), "hello"
)
Dom.Assert.toBeDisabled(
  Dom.Query.getByRole(container, "button")
)
Dom.Assert.toBeChecked(
  Dom.Query.getByRole(container, "checkbox")
)`}
    />
    <Separator />
    // Containment
    <div class="heading-anchor" id="containment">
      <Typography text={static("Containment")} variant={H2} />
      <a class="anchor-link" href="#containment"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-contain-element">
      <Typography text={static("Dom.Assert.toContainElement(parent, child)")} variant={H3} />
      <a class="anchor-link" href="#to-contain-element"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-not-contain-element">
      <Typography text={static("Dom.Assert.toNotContainElement(parent, child)")} variant={H3} />
      <a class="anchor-link" href="#to-not-contain-element"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-contain-html">
      <Typography text={static("Dom.Assert.toContainHTML(element, html)")} variant={H3} />
      <a class="anchor-link" href="#to-contain-html"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-be-empty">
      <Typography text={static("Dom.Assert.toBeEmptyDOMElement(element)")} variant={H3} />
      <a class="anchor-link" href="#to-be-empty"> {"#"->Component.text} </a>
    </div>
    <Separator />
    // Style & Focus
    <div class="heading-anchor" id="style-focus">
      <Typography text={static("Style & Focus")} variant={H2} />
      <a class="anchor-link" href="#style-focus"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-have-style">
      <Typography text={static("Dom.Assert.toHaveStyle(element, property, value)")} variant={H3} />
      <a class="anchor-link" href="#to-have-style"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that an element has a specific inline or computed style.")} />
    <div class="heading-anchor" id="to-have-focus">
      <Typography text={static("Dom.Assert.toHaveFocus(element)")} variant={H3} />
      <a class="anchor-link" href="#to-have-focus"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="to-not-have-focus">
      <Typography text={static("Dom.Assert.toNotHaveFocus(element)")} variant={H3} />
      <a class="anchor-link" href="#to-not-have-focus"> {"#"->Component.text} </a>
    </div>
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render(\`<input type="text" />\`)
let input = Dom.Query.getByRole(container, "textbox")

Dom.Event.focus(input)
Dom.Assert.toHaveFocus(input)

Dom.Event.blur(input)
Dom.Assert.toNotHaveFocus(input)`}
    />
    <EditOnGitHub pageName="Pages__ApiDomAssertions" />
  </div>
}
