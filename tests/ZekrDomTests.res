open Types

// === Render and Cleanup Tests ===

let renderTests = Suite.make(
  "DomTesting.render and cleanup",
  [
    Test.make("renders HTML into a container", () => {
      let {container} = DomTesting.render(`<p>Hello World</p>`)
      let result = DomTesting.Assert.toContainHTML(container, "<p>Hello World</p>")
      DomTesting.cleanup()
      result
    }),
    Test.make("container is in the document", () => {
      let {container} = DomTesting.render(`<div>test</div>`)
      let result = DomTesting.Assert.toBeInTheDocument(container)
      DomTesting.cleanup()
      result
    }),
    Test.make("cleanup removes containers from the document", () => {
      let {container} = DomTesting.render(`<div>to be removed</div>`)
      DomTesting.cleanup()
      DomTesting.Assert.toNotBeInTheDocument(Some(container))
    }),
    Test.make("multiple renders create separate containers", () => {
      let {container: c1} = DomTesting.render(`<p>First</p>`)
      let {container: c2} = DomTesting.render(`<p>Second</p>`)
      let result = Assert.combineResults([
        DomTesting.Assert.toContainHTML(c1, "First"),
        DomTesting.Assert.toContainHTML(c2, "Second"),
      ])
      DomTesting.cleanup()
      result
    }),
  ],
)

// === Query by Text Tests ===

let queryByTextTests = Suite.make(
  "DomTesting.Query - getByText",
  [
    Test.make("finds element by exact text", () => {
      let {container} = DomTesting.render(`<p>Hello World</p>`)
      let el = DomTesting.Query.getByText(container, "Hello World")
      let result = DomTesting.Assert.toHaveTextContent(el, "Hello World")
      DomTesting.cleanup()
      result
    }),
    Test.make("finds element by inexact text", () => {
      let {container} = DomTesting.render(`<p>Hello World</p>`)
      let el = DomTesting.Query.getByText(container, "hello", ~exact=false)
      let result = DomTesting.Assert.toHaveTextContent(el, "Hello World")
      DomTesting.cleanup()
      result
    }),
    Test.make("queryByText returns None when not found", () => {
      let {container} = DomTesting.render(`<p>Hello</p>`)
      let result = switch DomTesting.Query.queryByText(container, "Goodbye") {
      | None => Pass
      | Some(_) => Fail("Expected None, got Some")
      }
      DomTesting.cleanup()
      result
    }),
    Test.make("getAllByText returns multiple matches", () => {
      let {container} = DomTesting.render(`<li>Item</li><li>Item</li><li>Item</li>`)
      let items = DomTesting.Query.getAllByText(container, "Item")
      let result = Assert.assertEqual(Array.length(items), 3)
      DomTesting.cleanup()
      result
    }),
    Test.make("getByText throws for multiple matches", () => {
      let {container} = DomTesting.render(`<span>Same</span><span>Same</span>`)
      let result = Assert.assertThrows(() => DomTesting.Query.getByText(container, "Same"))
      DomTesting.cleanup()
      result
    }),
    Test.make("getByText throws when not found", () => {
      let {container} = DomTesting.render(`<p>Hello</p>`)
      let result = Assert.assertThrows(() => DomTesting.Query.getByText(container, "Nonexistent"))
      DomTesting.cleanup()
      result
    }),
  ],
)

// === Query by Role Tests ===

let queryByRoleTests = Suite.make(
  "DomTesting.Query - getByRole",
  [
    Test.make("finds button by role", () => {
      let {container} = DomTesting.render(`<button>Click me</button>`)
      let btn = DomTesting.Query.getByRole(container, "button")
      let result = DomTesting.Assert.toHaveTextContent(btn, "Click me")
      DomTesting.cleanup()
      result
    }),
    Test.make("finds link by role", () => {
      let {container} = DomTesting.render(`<a href="/page">Go to page</a>`)
      let link = DomTesting.Query.getByRole(container, "link")
      let result = DomTesting.Assert.toHaveTextContent(link, "Go to page")
      DomTesting.cleanup()
      result
    }),
    Test.make("finds textbox input by role", () => {
      let {container} = DomTesting.render(`<input type="text" value="hello" />`)
      let input = DomTesting.Query.getByRole(container, "textbox")
      let result = DomTesting.Assert.toHaveValue(input, "hello")
      DomTesting.cleanup()
      result
    }),
    Test.make("finds checkbox by role", () => {
      let {container} = DomTesting.render(`<input type="checkbox" />`)
      let cb = DomTesting.Query.getByRole(container, "checkbox")
      let result = DomTesting.Assert.toNotBeChecked(cb)
      DomTesting.cleanup()
      result
    }),
    Test.make("finds heading by role with level", () => {
      let {container} = DomTesting.render(`<h1>Title</h1><h2>Subtitle</h2>`)
      let h2 = DomTesting.Query.getByRole(container, "heading", ~level=2)
      let result = DomTesting.Assert.toHaveTextContent(h2, "Subtitle")
      DomTesting.cleanup()
      result
    }),
    Test.make("finds element by role and name", () => {
      let {container} = DomTesting.render(
        `<button>Save</button><button>Cancel</button>`,
      )
      let btn = DomTesting.Query.getByRole(container, "button", ~name="Save")
      let result = DomTesting.Assert.toHaveTextContent(btn, "Save")
      DomTesting.cleanup()
      result
    }),
    Test.make("finds element with explicit role attribute", () => {
      let {container} = DomTesting.render(`<div role="alert">Warning!</div>`)
      let alert = DomTesting.Query.getByRole(container, "alert")
      let result = DomTesting.Assert.toHaveTextContent(alert, "Warning!")
      DomTesting.cleanup()
      result
    }),
    Test.make("finds navigation by implicit role", () => {
      let {container} = DomTesting.render(`<nav>Nav content</nav>`)
      let nav = DomTesting.Query.getByRole(container, "navigation")
      let result = DomTesting.Assert.toHaveTextContent(nav, "Nav content")
      DomTesting.cleanup()
      result
    }),
    Test.make("finds list items by role", () => {
      let {container} = DomTesting.render(`<ul><li>One</li><li>Two</li><li>Three</li></ul>`)
      let items = DomTesting.Query.getAllByRole(container, "listitem")
      let result = Assert.assertEqual(Array.length(items), 3)
      DomTesting.cleanup()
      result
    }),
  ],
)

// === Query by TestId Tests ===

let queryByTestIdTests = Suite.make(
  "DomTesting.Query - getByTestId",
  [
    Test.make("finds element by data-testid", () => {
      let {container} = DomTesting.render(`<div data-testid="greeting">Hello</div>`)
      let el = DomTesting.Query.getByTestId(container, "greeting")
      let result = DomTesting.Assert.toHaveTextContent(el, "Hello")
      DomTesting.cleanup()
      result
    }),
    Test.make("queryByTestId returns None when not found", () => {
      let {container} = DomTesting.render(`<div>No testid</div>`)
      let result = switch DomTesting.Query.queryByTestId(container, "missing") {
      | None => Pass
      | Some(_) => Fail("Expected None")
      }
      DomTesting.cleanup()
      result
    }),
  ],
)

// === Query by Placeholder Tests ===

let queryByPlaceholderTests = Suite.make(
  "DomTesting.Query - getByPlaceholder",
  [
    Test.make("finds input by placeholder text", () => {
      let {container} = DomTesting.render(`<input placeholder="Enter your email" />`)
      let input = DomTesting.Query.getByPlaceholder(container, "Enter your email")
      let result = DomTesting.Assert.toBeInTheDocument(input)
      DomTesting.cleanup()
      result
    }),
    Test.make("finds input by partial placeholder", () => {
      let {container} = DomTesting.render(`<input placeholder="Enter your email" />`)
      let input = DomTesting.Query.getByPlaceholder(container, "email", ~exact=false)
      let result = DomTesting.Assert.toBeInTheDocument(input)
      DomTesting.cleanup()
      result
    }),
  ],
)

// === Query by Label Text Tests ===

let queryByLabelTextTests = Suite.make(
  "DomTesting.Query - getByLabelText",
  [
    Test.make("finds input by associated label (for/id)", () => {
      let {container} = DomTesting.render(
        `<label for="email-input">Email</label><input id="email-input" type="email" />`,
      )
      let input = DomTesting.Query.getByLabelText(container, "Email")
      let result = DomTesting.Assert.toHaveAttribute(input, "type", ~value="email")
      DomTesting.cleanup()
      result
    }),
    Test.make("finds input nested within label", () => {
      let {container} = DomTesting.render(
        `<label>Username<input type="text" /></label>`,
      )
      let input = DomTesting.Query.getByLabelText(container, "Username")
      let result = DomTesting.Assert.toBeInTheDocument(input)
      DomTesting.cleanup()
      result
    }),
  ],
)

// === Query by Alt Text Tests ===

let queryByAltTextTests = Suite.make(
  "DomTesting.Query - getByAltText",
  [
    Test.make("finds image by alt text", () => {
      let {container} = DomTesting.render(`<img alt="Company logo" src="logo.png" />`)
      let img = DomTesting.Query.getByAltText(container, "Company logo")
      let result = DomTesting.Assert.toHaveAttribute(img, "src", ~value="logo.png")
      DomTesting.cleanup()
      result
    }),
  ],
)

// === Query by Title Tests ===

let queryByTitleTests = Suite.make(
  "DomTesting.Query - getByTitle",
  [
    Test.make("finds element by title attribute", () => {
      let {container} = DomTesting.render(`<span title="Close">X</span>`)
      let el = DomTesting.Query.getByTitle(container, "Close")
      let result = DomTesting.Assert.toHaveTextContent(el, "X")
      DomTesting.cleanup()
      result
    }),
  ],
)

// === Query by Display Value Tests ===

let queryByDisplayValueTests = Suite.make(
  "DomTesting.Query - getByDisplayValue",
  [
    Test.make("finds input by its current value", () => {
      let {container} = DomTesting.render(`<input type="text" value="current text" />`)
      let input = DomTesting.Query.getByDisplayValue(container, "current text")
      let result = DomTesting.Assert.toBeInTheDocument(input)
      DomTesting.cleanup()
      result
    }),
  ],
)

// === Event Tests ===

let eventTests = Suite.make(
  "DomTesting.Event - user interactions",
  [
    Test.make("click dispatches click event", () => {
      let {container} = DomTesting.render(`<button data-clicked="no">Click me</button>`)
      let btn = DomTesting.Query.getByRole(container, "button")
      let _ = %raw(`btn.addEventListener("click", function() { btn.setAttribute("data-clicked", "yes") })`)
      DomTesting.Event.click(btn)
      let result = DomTesting.Assert.toHaveAttribute(btn, "data-clicked", ~value="yes")
      DomTesting.cleanup()
      result
    }),
    Test.make("dblClick dispatches dblclick event", () => {
      let {container} = DomTesting.render(`<button data-dblclicked="no">Click me</button>`)
      let btn = DomTesting.Query.getByRole(container, "button")
      let _ = %raw(`btn.addEventListener("dblclick", function() { btn.setAttribute("data-dblclicked", "yes") })`)
      DomTesting.Event.dblClick(btn)
      let result = DomTesting.Assert.toHaveAttribute(btn, "data-dblclicked", ~value="yes")
      DomTesting.cleanup()
      result
    }),
    Test.make("typeText enters text into input", () => {
      let {container} = DomTesting.render(`<input type="text" value="" />`)
      let input = DomTesting.Query.getByRole(container, "textbox")
      DomTesting.Event.typeText(input, "Hello")
      let result = DomTesting.Assert.toHaveValue(input, "Hello")
      DomTesting.cleanup()
      result
    }),
    Test.make("clear empties an input", () => {
      let {container} = DomTesting.render(`<input type="text" value="some text" />`)
      let input = DomTesting.Query.getByRole(container, "textbox")
      DomTesting.Event.clear(input)
      let result = DomTesting.Assert.toHaveValue(input, "")
      DomTesting.cleanup()
      result
    }),
    Test.make("check toggles checkbox on", () => {
      let {container} = DomTesting.render(`<input type="checkbox" />`)
      let cb = DomTesting.Query.getByRole(container, "checkbox")
      DomTesting.Event.check(cb)
      let result = DomTesting.Assert.toBeChecked(cb)
      DomTesting.cleanup()
      result
    }),
    Test.make("uncheck toggles checkbox off", () => {
      let {container} = DomTesting.render(`<input type="checkbox" checked />`)
      let cb = DomTesting.Query.getByRole(container, "checkbox")
      DomTesting.Event.uncheck(cb)
      let result = DomTesting.Assert.toNotBeChecked(cb)
      DomTesting.cleanup()
      result
    }),
    Test.make("focus gives element focus", () => {
      let {container} = DomTesting.render(`<input type="text" />`)
      let input = DomTesting.Query.getByRole(container, "textbox")
      DomTesting.Event.focus(input)
      let result = DomTesting.Assert.toHaveFocus(input)
      DomTesting.cleanup()
      result
    }),
    Test.make("blur removes focus from element", () => {
      let {container} = DomTesting.render(`<input type="text" />`)
      let input = DomTesting.Query.getByRole(container, "textbox")
      DomTesting.Event.focus(input)
      DomTesting.Event.blur(input)
      let result = DomTesting.Assert.toNotHaveFocus(input)
      DomTesting.cleanup()
      result
    }),
    Test.make("selectOptions selects an option in a select element", () => {
      let {container} = DomTesting.render(
        `<select><option value="a">Alpha</option><option value="b">Beta</option></select>`,
      )
      let select = DomTesting.Query.getByRole(container, "listbox")
      DomTesting.Event.selectOptions(select, ["b"])
      let result = DomTesting.Assert.toHaveValue(select, "b")
      DomTesting.cleanup()
      result
    }),
  ],
)

// === DOM Assertion Tests ===

let assertionTests = Suite.make(
  "DomTesting.Assert - DOM assertions",
  [
    Test.make("toHaveTextContent matches text", () => {
      let {container} = DomTesting.render(`<p>  Hello   World  </p>`)
      let el = DomTesting.Query.getByText(container, "Hello World")
      let result = DomTesting.Assert.toHaveTextContent(el, "Hello World")
      DomTesting.cleanup()
      result
    }),
    Test.make("toHaveTextContent with inexact match", () => {
      let {container} = DomTesting.render(`<p>Hello World</p>`)
      let el = DomTesting.Query.getByText(container, "Hello World")
      let result = DomTesting.Assert.toHaveTextContent(el, "hello", ~exact=false)
      DomTesting.cleanup()
      result
    }),
    Test.make("toHaveAttribute checks attribute existence", () => {
      let {container} = DomTesting.render(`<input type="email" required />`)
      let input = DomTesting.Query.getByRole(container, "textbox")
      let result = DomTesting.Assert.toHaveAttribute(input, "required")
      DomTesting.cleanup()
      result
    }),
    Test.make("toHaveAttribute checks attribute value", () => {
      let {container} = DomTesting.render(`<input type="email" />`)
      let input = DomTesting.Query.getByRole(container, "textbox")
      let result = DomTesting.Assert.toHaveAttribute(input, "type", ~value="email")
      DomTesting.cleanup()
      result
    }),
    Test.make("toNotHaveAttribute passes when missing", () => {
      let {container} = DomTesting.render(`<input type="text" />`)
      let input = DomTesting.Query.getByRole(container, "textbox")
      let result = DomTesting.Assert.toNotHaveAttribute(input, "disabled")
      DomTesting.cleanup()
      result
    }),
    Test.make("toHaveClass checks CSS class", () => {
      let {container} = DomTesting.render(`<div class="active primary">Content</div>`)
      let el = DomTesting.Query.getByText(container, "Content")
      let result = Assert.combineResults([
        DomTesting.Assert.toHaveClass(el, "active"),
        DomTesting.Assert.toHaveClass(el, "primary"),
        DomTesting.Assert.toHaveClass(el, "active primary"),
      ])
      DomTesting.cleanup()
      result
    }),
    Test.make("toNotHaveClass passes when class is missing", () => {
      let {container} = DomTesting.render(`<div class="active">Content</div>`)
      let el = DomTesting.Query.getByText(container, "Content")
      let result = DomTesting.Assert.toNotHaveClass(el, "hidden")
      DomTesting.cleanup()
      result
    }),
    Test.make("toBeVisible for visible element", () => {
      let {container} = DomTesting.render(`<div>Visible</div>`)
      let el = DomTesting.Query.getByText(container, "Visible")
      let result = DomTesting.Assert.toBeVisible(el)
      DomTesting.cleanup()
      result
    }),
    Test.make("toNotBeVisible for hidden element", () => {
      let {container} = DomTesting.render(`<div style="display: none">Hidden</div>`)
      let el = container->DomBindings.querySelector("div")->Nullable.getExn
      let result = DomTesting.Assert.toNotBeVisible(el)
      DomTesting.cleanup()
      result
    }),
    Test.make("toBeDisabled for disabled element", () => {
      let {container} = DomTesting.render(`<button disabled>Disabled</button>`)
      let btn = DomTesting.Query.getByRole(container, "button")
      let result = DomTesting.Assert.toBeDisabled(btn)
      DomTesting.cleanup()
      result
    }),
    Test.make("toBeEnabled for enabled element", () => {
      let {container} = DomTesting.render(`<button>Enabled</button>`)
      let btn = DomTesting.Query.getByRole(container, "button")
      let result = DomTesting.Assert.toBeEnabled(btn)
      DomTesting.cleanup()
      result
    }),
    Test.make("toHaveValue checks input value", () => {
      let {container} = DomTesting.render(`<input type="text" value="test value" />`)
      let input = DomTesting.Query.getByRole(container, "textbox")
      let result = DomTesting.Assert.toHaveValue(input, "test value")
      DomTesting.cleanup()
      result
    }),
    Test.make("toBeChecked for checked checkbox", () => {
      let {container} = DomTesting.render(`<input type="checkbox" checked />`)
      let cb = DomTesting.Query.getByRole(container, "checkbox")
      let result = DomTesting.Assert.toBeChecked(cb)
      DomTesting.cleanup()
      result
    }),
    Test.make("toNotBeChecked for unchecked checkbox", () => {
      let {container} = DomTesting.render(`<input type="checkbox" />`)
      let cb = DomTesting.Query.getByRole(container, "checkbox")
      let result = DomTesting.Assert.toNotBeChecked(cb)
      DomTesting.cleanup()
      result
    }),
    Test.make("toContainElement verifies parent-child relationship", () => {
      let {container} = DomTesting.render(`<div data-testid="parent"><span data-testid="child">Hi</span></div>`)
      let parent = DomTesting.Query.getByTestId(container, "parent")
      let child = DomTesting.Query.getByTestId(container, "child")
      let result = DomTesting.Assert.toContainElement(parent, child)
      DomTesting.cleanup()
      result
    }),
    Test.make("toNotContainElement verifies no parent-child relationship", () => {
      let {container} = DomTesting.render(
        `<div data-testid="a">A</div><div data-testid="b">B</div>`,
      )
      let a = DomTesting.Query.getByTestId(container, "a")
      let b = DomTesting.Query.getByTestId(container, "b")
      let result = DomTesting.Assert.toNotContainElement(a, b)
      DomTesting.cleanup()
      result
    }),
    Test.make("toContainHTML checks for HTML content", () => {
      let {container} = DomTesting.render(`<div><strong>Bold</strong> text</div>`)
      let el = DomTesting.Query.getByText(container, "Bold text", ~exact=false)
      let result = DomTesting.Assert.toContainHTML(el, "<strong>Bold</strong>")
      DomTesting.cleanup()
      result
    }),
    Test.make("toBeEmptyDOMElement for empty element", () => {
      let {container} = DomTesting.render(`<div data-testid="empty"></div>`)
      let el = DomTesting.Query.getByTestId(container, "empty")
      let result = DomTesting.Assert.toBeEmptyDOMElement(el)
      DomTesting.cleanup()
      result
    }),
    Test.make("toHaveFocus checks focused element", () => {
      let {container} = DomTesting.render(`<input type="text" />`)
      let input = DomTesting.Query.getByRole(container, "textbox")
      DomBindings.focusElement(input)
      let result = DomTesting.Assert.toHaveFocus(input)
      DomTesting.cleanup()
      result
    }),
  ],
)

// === Integration Tests ===

let integrationTests = Suite.make(
  "Dom - integration scenarios",
  [
    Test.make("form interaction: fill and verify", () => {
      let {container} = DomTesting.render(
        `<form>
          <label for="name">Name</label>
          <input id="name" type="text" value="" />
          <label for="agree">I agree</label>
          <input id="agree" type="checkbox" />
          <button type="submit">Submit</button>
        </form>`,
      )

      let nameInput = DomTesting.Query.getByLabelText(container, "Name")
      DomTesting.Event.typeText(nameInput, "John Doe")

      let checkbox = DomTesting.Query.getByLabelText(container, "I agree")
      DomTesting.Event.check(checkbox)

      let submitBtn = DomTesting.Query.getByRole(container, "button", ~name="Submit")

      let result = Assert.combineResults([
        DomTesting.Assert.toHaveValue(nameInput, "John Doe"),
        DomTesting.Assert.toBeChecked(checkbox),
        DomTesting.Assert.toBeEnabled(submitBtn),
      ])
      DomTesting.cleanup()
      result
    }),
    Test.make("dynamic content: click changes text", () => {
      let {container} = DomTesting.render(
        `<div>
          <span data-testid="counter">0</span>
          <button>Increment</button>
        </div>`,
      )

      let counter = DomTesting.Query.getByTestId(container, "counter")
      let btn = DomTesting.Query.getByRole(container, "button", ~name="Increment")

      let _ = %raw(`btn.addEventListener("click", () => { counter.textContent = "1" })`)

      let before = DomTesting.Assert.toHaveTextContent(counter, "0")
      DomTesting.Event.click(btn)
      let after = DomTesting.Assert.toHaveTextContent(counter, "1")

      let result = Assert.combineResults([before, after])
      DomTesting.cleanup()
      result
    }),
    Test.make("todo list: add and verify items", () => {
      let {container} = DomTesting.render(
        `<div>
          <input data-testid="todo-input" type="text" value="" />
          <ul data-testid="todo-list"></ul>
        </div>`,
      )

      let input = DomTesting.Query.getByTestId(container, "todo-input")
      DomTesting.Event.typeText(input, "Buy groceries")

      let result = Assert.combineResults([
        DomTesting.Assert.toHaveValue(input, "Buy groceries"),
        DomTesting.Assert.toBeInTheDocument(input),
      ])
      DomTesting.cleanup()
      result
    }),
  ],
)

// Run all DOM test suites
Runner.runSuites([
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
