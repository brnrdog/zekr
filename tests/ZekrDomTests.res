open Zekr

// === Render and Cleanup Tests ===

let renderTests = suite(
  "Dom.render and cleanup",
  [
    test("renders HTML into a container", () => {
      let {container} = Dom.render(`<p>Hello World</p>`)
      let result = Dom.Assert.toContainHTML(container, "<p>Hello World</p>")
      Dom.cleanup()
      result
    }),
    test("container is in the document", () => {
      let {container} = Dom.render(`<div>test</div>`)
      let result = Dom.Assert.toBeInTheDocument(container)
      Dom.cleanup()
      result
    }),
    test("cleanup removes containers from the document", () => {
      let {container} = Dom.render(`<div>to be removed</div>`)
      Dom.cleanup()
      Dom.Assert.toNotBeInTheDocument(Some(container))
    }),
    test("multiple renders create separate containers", () => {
      let {container: c1} = Dom.render(`<p>First</p>`)
      let {container: c2} = Dom.render(`<p>Second</p>`)
      let result = combineResults([
        Dom.Assert.toContainHTML(c1, "First"),
        Dom.Assert.toContainHTML(c2, "Second"),
      ])
      Dom.cleanup()
      result
    }),
  ],
)

// === Query by Text Tests ===

let queryByTextTests = suite(
  "Dom.Query - getByText",
  [
    test("finds element by exact text", () => {
      let {container} = Dom.render(`<p>Hello World</p>`)
      let el = Dom.Query.getByText(container, "Hello World")
      let result = Dom.Assert.toHaveTextContent(el, "Hello World")
      Dom.cleanup()
      result
    }),
    test("finds element by inexact text", () => {
      let {container} = Dom.render(`<p>Hello World</p>`)
      let el = Dom.Query.getByText(container, "hello", ~exact=false)
      let result = Dom.Assert.toHaveTextContent(el, "Hello World")
      Dom.cleanup()
      result
    }),
    test("queryByText returns None when not found", () => {
      let {container} = Dom.render(`<p>Hello</p>`)
      let result = switch Dom.Query.queryByText(container, "Goodbye") {
      | None => Pass
      | Some(_) => Fail("Expected None, got Some")
      }
      Dom.cleanup()
      result
    }),
    test("getAllByText returns multiple matches", () => {
      let {container} = Dom.render(`<li>Item</li><li>Item</li><li>Item</li>`)
      let items = Dom.Query.getAllByText(container, "Item")
      let result = assertEqual(Array.length(items), 3)
      Dom.cleanup()
      result
    }),
    test("getByText throws for multiple matches", () => {
      let {container} = Dom.render(`<span>Same</span><span>Same</span>`)
      let result = assertThrows(() => Dom.Query.getByText(container, "Same"))
      Dom.cleanup()
      result
    }),
    test("getByText throws when not found", () => {
      let {container} = Dom.render(`<p>Hello</p>`)
      let result = assertThrows(() => Dom.Query.getByText(container, "Nonexistent"))
      Dom.cleanup()
      result
    }),
  ],
)

// === Query by Role Tests ===

let queryByRoleTests = suite(
  "Dom.Query - getByRole",
  [
    test("finds button by role", () => {
      let {container} = Dom.render(`<button>Click me</button>`)
      let btn = Dom.Query.getByRole(container, "button")
      let result = Dom.Assert.toHaveTextContent(btn, "Click me")
      Dom.cleanup()
      result
    }),
    test("finds link by role", () => {
      let {container} = Dom.render(`<a href="/page">Go to page</a>`)
      let link = Dom.Query.getByRole(container, "link")
      let result = Dom.Assert.toHaveTextContent(link, "Go to page")
      Dom.cleanup()
      result
    }),
    test("finds textbox input by role", () => {
      let {container} = Dom.render(`<input type="text" value="hello" />`)
      let input = Dom.Query.getByRole(container, "textbox")
      let result = Dom.Assert.toHaveValue(input, "hello")
      Dom.cleanup()
      result
    }),
    test("finds checkbox by role", () => {
      let {container} = Dom.render(`<input type="checkbox" />`)
      let cb = Dom.Query.getByRole(container, "checkbox")
      let result = Dom.Assert.toNotBeChecked(cb)
      Dom.cleanup()
      result
    }),
    test("finds heading by role with level", () => {
      let {container} = Dom.render(`<h1>Title</h1><h2>Subtitle</h2>`)
      let h2 = Dom.Query.getByRole(container, "heading", ~level=2)
      let result = Dom.Assert.toHaveTextContent(h2, "Subtitle")
      Dom.cleanup()
      result
    }),
    test("finds element by role and name", () => {
      let {container} = Dom.render(
        `<button>Save</button><button>Cancel</button>`,
      )
      let btn = Dom.Query.getByRole(container, "button", ~name="Save")
      let result = Dom.Assert.toHaveTextContent(btn, "Save")
      Dom.cleanup()
      result
    }),
    test("finds element with explicit role attribute", () => {
      let {container} = Dom.render(`<div role="alert">Warning!</div>`)
      let alert = Dom.Query.getByRole(container, "alert")
      let result = Dom.Assert.toHaveTextContent(alert, "Warning!")
      Dom.cleanup()
      result
    }),
    test("finds navigation by implicit role", () => {
      let {container} = Dom.render(`<nav>Nav content</nav>`)
      let nav = Dom.Query.getByRole(container, "navigation")
      let result = Dom.Assert.toHaveTextContent(nav, "Nav content")
      Dom.cleanup()
      result
    }),
    test("finds list items by role", () => {
      let {container} = Dom.render(`<ul><li>One</li><li>Two</li><li>Three</li></ul>`)
      let items = Dom.Query.getAllByRole(container, "listitem")
      let result = assertEqual(Array.length(items), 3)
      Dom.cleanup()
      result
    }),
  ],
)

// === Query by TestId Tests ===

let queryByTestIdTests = suite(
  "Dom.Query - getByTestId",
  [
    test("finds element by data-testid", () => {
      let {container} = Dom.render(`<div data-testid="greeting">Hello</div>`)
      let el = Dom.Query.getByTestId(container, "greeting")
      let result = Dom.Assert.toHaveTextContent(el, "Hello")
      Dom.cleanup()
      result
    }),
    test("queryByTestId returns None when not found", () => {
      let {container} = Dom.render(`<div>No testid</div>`)
      let result = switch Dom.Query.queryByTestId(container, "missing") {
      | None => Pass
      | Some(_) => Fail("Expected None")
      }
      Dom.cleanup()
      result
    }),
  ],
)

// === Query by Placeholder Tests ===

let queryByPlaceholderTests = suite(
  "Dom.Query - getByPlaceholder",
  [
    test("finds input by placeholder text", () => {
      let {container} = Dom.render(`<input placeholder="Enter your email" />`)
      let input = Dom.Query.getByPlaceholder(container, "Enter your email")
      let result = Dom.Assert.toBeInTheDocument(input)
      Dom.cleanup()
      result
    }),
    test("finds input by partial placeholder", () => {
      let {container} = Dom.render(`<input placeholder="Enter your email" />`)
      let input = Dom.Query.getByPlaceholder(container, "email", ~exact=false)
      let result = Dom.Assert.toBeInTheDocument(input)
      Dom.cleanup()
      result
    }),
  ],
)

// === Query by Label Text Tests ===

let queryByLabelTextTests = suite(
  "Dom.Query - getByLabelText",
  [
    test("finds input by associated label (for/id)", () => {
      let {container} = Dom.render(
        `<label for="email-input">Email</label><input id="email-input" type="email" />`,
      )
      let input = Dom.Query.getByLabelText(container, "Email")
      let result = Dom.Assert.toHaveAttribute(input, "type", ~value="email")
      Dom.cleanup()
      result
    }),
    test("finds input nested within label", () => {
      let {container} = Dom.render(
        `<label>Username<input type="text" /></label>`,
      )
      let input = Dom.Query.getByLabelText(container, "Username")
      let result = Dom.Assert.toBeInTheDocument(input)
      Dom.cleanup()
      result
    }),
  ],
)

// === Query by Alt Text Tests ===

let queryByAltTextTests = suite(
  "Dom.Query - getByAltText",
  [
    test("finds image by alt text", () => {
      let {container} = Dom.render(`<img alt="Company logo" src="logo.png" />`)
      let img = Dom.Query.getByAltText(container, "Company logo")
      let result = Dom.Assert.toHaveAttribute(img, "src", ~value="logo.png")
      Dom.cleanup()
      result
    }),
  ],
)

// === Query by Title Tests ===

let queryByTitleTests = suite(
  "Dom.Query - getByTitle",
  [
    test("finds element by title attribute", () => {
      let {container} = Dom.render(`<span title="Close">X</span>`)
      let el = Dom.Query.getByTitle(container, "Close")
      let result = Dom.Assert.toHaveTextContent(el, "X")
      Dom.cleanup()
      result
    }),
  ],
)

// === Query by Display Value Tests ===

let queryByDisplayValueTests = suite(
  "Dom.Query - getByDisplayValue",
  [
    test("finds input by its current value", () => {
      let {container} = Dom.render(`<input type="text" value="current text" />`)
      let input = Dom.Query.getByDisplayValue(container, "current text")
      let result = Dom.Assert.toBeInTheDocument(input)
      Dom.cleanup()
      result
    }),
  ],
)

// === Event Tests ===

let eventTests = suite(
  "Dom.Event - user interactions",
  [
    test("click dispatches click event", () => {
      let {container} = Dom.render(`<button data-clicked="no">Click me</button>`)
      let btn = Dom.Query.getByRole(container, "button")
      let _ = %raw(`btn.addEventListener("click", function() { btn.setAttribute("data-clicked", "yes") })`)
      Dom.Event.click(btn)
      let result = Dom.Assert.toHaveAttribute(btn, "data-clicked", ~value="yes")
      Dom.cleanup()
      result
    }),
    test("dblClick dispatches dblclick event", () => {
      let {container} = Dom.render(`<button data-dblclicked="no">Click me</button>`)
      let btn = Dom.Query.getByRole(container, "button")
      let _ = %raw(`btn.addEventListener("dblclick", function() { btn.setAttribute("data-dblclicked", "yes") })`)
      Dom.Event.dblClick(btn)
      let result = Dom.Assert.toHaveAttribute(btn, "data-dblclicked", ~value="yes")
      Dom.cleanup()
      result
    }),
    test("typeText enters text into input", () => {
      let {container} = Dom.render(`<input type="text" value="" />`)
      let input = Dom.Query.getByRole(container, "textbox")
      Dom.Event.typeText(input, "Hello")
      let result = Dom.Assert.toHaveValue(input, "Hello")
      Dom.cleanup()
      result
    }),
    test("clear empties an input", () => {
      let {container} = Dom.render(`<input type="text" value="some text" />`)
      let input = Dom.Query.getByRole(container, "textbox")
      Dom.Event.clear(input)
      let result = Dom.Assert.toHaveValue(input, "")
      Dom.cleanup()
      result
    }),
    test("check toggles checkbox on", () => {
      let {container} = Dom.render(`<input type="checkbox" />`)
      let cb = Dom.Query.getByRole(container, "checkbox")
      Dom.Event.check(cb)
      let result = Dom.Assert.toBeChecked(cb)
      Dom.cleanup()
      result
    }),
    test("uncheck toggles checkbox off", () => {
      let {container} = Dom.render(`<input type="checkbox" checked />`)
      let cb = Dom.Query.getByRole(container, "checkbox")
      Dom.Event.uncheck(cb)
      let result = Dom.Assert.toNotBeChecked(cb)
      Dom.cleanup()
      result
    }),
    test("focus gives element focus", () => {
      let {container} = Dom.render(`<input type="text" />`)
      let input = Dom.Query.getByRole(container, "textbox")
      Dom.Event.focus(input)
      let result = Dom.Assert.toHaveFocus(input)
      Dom.cleanup()
      result
    }),
    test("blur removes focus from element", () => {
      let {container} = Dom.render(`<input type="text" />`)
      let input = Dom.Query.getByRole(container, "textbox")
      Dom.Event.focus(input)
      Dom.Event.blur(input)
      let result = Dom.Assert.toNotHaveFocus(input)
      Dom.cleanup()
      result
    }),
    test("selectOptions selects an option in a select element", () => {
      let {container} = Dom.render(
        `<select><option value="a">Alpha</option><option value="b">Beta</option></select>`,
      )
      let select = Dom.Query.getByRole(container, "listbox")
      Dom.Event.selectOptions(select, ["b"])
      let result = Dom.Assert.toHaveValue(select, "b")
      Dom.cleanup()
      result
    }),
  ],
)

// === DOM Assertion Tests ===

let assertionTests = suite(
  "Dom.Assert - DOM assertions",
  [
    test("toHaveTextContent matches text", () => {
      let {container} = Dom.render(`<p>  Hello   World  </p>`)
      let el = Dom.Query.getByText(container, "Hello World")
      let result = Dom.Assert.toHaveTextContent(el, "Hello World")
      Dom.cleanup()
      result
    }),
    test("toHaveTextContent with inexact match", () => {
      let {container} = Dom.render(`<p>Hello World</p>`)
      let el = Dom.Query.getByText(container, "Hello World")
      let result = Dom.Assert.toHaveTextContent(el, "hello", ~exact=false)
      Dom.cleanup()
      result
    }),
    test("toHaveAttribute checks attribute existence", () => {
      let {container} = Dom.render(`<input type="email" required />`)
      let input = Dom.Query.getByRole(container, "textbox")
      let result = Dom.Assert.toHaveAttribute(input, "required")
      Dom.cleanup()
      result
    }),
    test("toHaveAttribute checks attribute value", () => {
      let {container} = Dom.render(`<input type="email" />`)
      let input = Dom.Query.getByRole(container, "textbox")
      let result = Dom.Assert.toHaveAttribute(input, "type", ~value="email")
      Dom.cleanup()
      result
    }),
    test("toNotHaveAttribute passes when missing", () => {
      let {container} = Dom.render(`<input type="text" />`)
      let input = Dom.Query.getByRole(container, "textbox")
      let result = Dom.Assert.toNotHaveAttribute(input, "disabled")
      Dom.cleanup()
      result
    }),
    test("toHaveClass checks CSS class", () => {
      let {container} = Dom.render(`<div class="active primary">Content</div>`)
      let el = Dom.Query.getByText(container, "Content")
      let result = combineResults([
        Dom.Assert.toHaveClass(el, "active"),
        Dom.Assert.toHaveClass(el, "primary"),
        Dom.Assert.toHaveClass(el, "active primary"),
      ])
      Dom.cleanup()
      result
    }),
    test("toNotHaveClass passes when class is missing", () => {
      let {container} = Dom.render(`<div class="active">Content</div>`)
      let el = Dom.Query.getByText(container, "Content")
      let result = Dom.Assert.toNotHaveClass(el, "hidden")
      Dom.cleanup()
      result
    }),
    test("toBeVisible for visible element", () => {
      let {container} = Dom.render(`<div>Visible</div>`)
      let el = Dom.Query.getByText(container, "Visible")
      let result = Dom.Assert.toBeVisible(el)
      Dom.cleanup()
      result
    }),
    test("toNotBeVisible for hidden element", () => {
      let {container} = Dom.render(`<div style="display: none">Hidden</div>`)
      let el = container->DomBindings.querySelector("div")->Nullable.getExn
      let result = Dom.Assert.toNotBeVisible(el)
      Dom.cleanup()
      result
    }),
    test("toBeDisabled for disabled element", () => {
      let {container} = Dom.render(`<button disabled>Disabled</button>`)
      let btn = Dom.Query.getByRole(container, "button")
      let result = Dom.Assert.toBeDisabled(btn)
      Dom.cleanup()
      result
    }),
    test("toBeEnabled for enabled element", () => {
      let {container} = Dom.render(`<button>Enabled</button>`)
      let btn = Dom.Query.getByRole(container, "button")
      let result = Dom.Assert.toBeEnabled(btn)
      Dom.cleanup()
      result
    }),
    test("toHaveValue checks input value", () => {
      let {container} = Dom.render(`<input type="text" value="test value" />`)
      let input = Dom.Query.getByRole(container, "textbox")
      let result = Dom.Assert.toHaveValue(input, "test value")
      Dom.cleanup()
      result
    }),
    test("toBeChecked for checked checkbox", () => {
      let {container} = Dom.render(`<input type="checkbox" checked />`)
      let cb = Dom.Query.getByRole(container, "checkbox")
      let result = Dom.Assert.toBeChecked(cb)
      Dom.cleanup()
      result
    }),
    test("toNotBeChecked for unchecked checkbox", () => {
      let {container} = Dom.render(`<input type="checkbox" />`)
      let cb = Dom.Query.getByRole(container, "checkbox")
      let result = Dom.Assert.toNotBeChecked(cb)
      Dom.cleanup()
      result
    }),
    test("toContainElement verifies parent-child relationship", () => {
      let {container} = Dom.render(`<div data-testid="parent"><span data-testid="child">Hi</span></div>`)
      let parent = Dom.Query.getByTestId(container, "parent")
      let child = Dom.Query.getByTestId(container, "child")
      let result = Dom.Assert.toContainElement(parent, child)
      Dom.cleanup()
      result
    }),
    test("toNotContainElement verifies no parent-child relationship", () => {
      let {container} = Dom.render(
        `<div data-testid="a">A</div><div data-testid="b">B</div>`,
      )
      let a = Dom.Query.getByTestId(container, "a")
      let b = Dom.Query.getByTestId(container, "b")
      let result = Dom.Assert.toNotContainElement(a, b)
      Dom.cleanup()
      result
    }),
    test("toContainHTML checks for HTML content", () => {
      let {container} = Dom.render(`<div><strong>Bold</strong> text</div>`)
      let el = Dom.Query.getByText(container, "Bold text", ~exact=false)
      let result = Dom.Assert.toContainHTML(el, "<strong>Bold</strong>")
      Dom.cleanup()
      result
    }),
    test("toBeEmptyDOMElement for empty element", () => {
      let {container} = Dom.render(`<div data-testid="empty"></div>`)
      let el = Dom.Query.getByTestId(container, "empty")
      let result = Dom.Assert.toBeEmptyDOMElement(el)
      Dom.cleanup()
      result
    }),
    test("toHaveFocus checks focused element", () => {
      let {container} = Dom.render(`<input type="text" />`)
      let input = Dom.Query.getByRole(container, "textbox")
      DomBindings.focusElement(input)
      let result = Dom.Assert.toHaveFocus(input)
      Dom.cleanup()
      result
    }),
  ],
)

// === Integration Tests ===

let integrationTests = suite(
  "Dom - integration scenarios",
  [
    test("form interaction: fill and verify", () => {
      let {container} = Dom.render(
        `<form>
          <label for="name">Name</label>
          <input id="name" type="text" value="" />
          <label for="agree">I agree</label>
          <input id="agree" type="checkbox" />
          <button type="submit">Submit</button>
        </form>`,
      )

      let nameInput = Dom.Query.getByLabelText(container, "Name")
      Dom.Event.typeText(nameInput, "John Doe")

      let checkbox = Dom.Query.getByLabelText(container, "I agree")
      Dom.Event.check(checkbox)

      let submitBtn = Dom.Query.getByRole(container, "button", ~name="Submit")

      let result = combineResults([
        Dom.Assert.toHaveValue(nameInput, "John Doe"),
        Dom.Assert.toBeChecked(checkbox),
        Dom.Assert.toBeEnabled(submitBtn),
      ])
      Dom.cleanup()
      result
    }),
    test("dynamic content: click changes text", () => {
      let {container} = Dom.render(
        `<div>
          <span data-testid="counter">0</span>
          <button>Increment</button>
        </div>`,
      )

      let counter = Dom.Query.getByTestId(container, "counter")
      let btn = Dom.Query.getByRole(container, "button", ~name="Increment")

      let _ = %raw(`btn.addEventListener("click", () => { counter.textContent = "1" })`)

      let before = Dom.Assert.toHaveTextContent(counter, "0")
      Dom.Event.click(btn)
      let after = Dom.Assert.toHaveTextContent(counter, "1")

      let result = combineResults([before, after])
      Dom.cleanup()
      result
    }),
    test("todo list: add and verify items", () => {
      let {container} = Dom.render(
        `<div>
          <input data-testid="todo-input" type="text" value="" />
          <ul data-testid="todo-list"></ul>
        </div>`,
      )

      let input = Dom.Query.getByTestId(container, "todo-input")
      Dom.Event.typeText(input, "Buy groceries")

      let result = combineResults([
        Dom.Assert.toHaveValue(input, "Buy groceries"),
        Dom.Assert.toBeInTheDocument(input),
      ])
      Dom.cleanup()
      result
    }),
  ],
)

// Run all DOM test suites
runSuites([
  renderTests,
  queryByTextTests,
  queryByRoleTests,
  queryByTestIdTests,
  queryByPlaceholderTests,
  queryByLabelTextTests,
  queryByAltTextTests,
  queryByTitleTests,
  queryByDisplayValueTests,
  eventTests,
  assertionTests,
  integrationTests,
])
