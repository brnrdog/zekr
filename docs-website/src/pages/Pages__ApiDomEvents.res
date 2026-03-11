open Xote
open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    <Typography text={static("DOM Events")} variant={H1} />
    <Typography
      text={static("Simulate realistic user interactions including clicks, typing, checking, and focus management.")}
      variant={Lead}
    />
    <Separator />
    // Mouse Events
    <div class="heading-anchor" id="mouse">
      <Typography text={static("Mouse Events")} variant={H2} />
      <a class="anchor-link" href="#mouse"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="click">
      <Typography text={static("Dom.Event.click(element)")} variant={H3} />
      <a class="anchor-link" href="#click"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Simulates a realistic click event sequence: pointerdown, mousedown, pointerup, mouseup, click. Also manages focus.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render("<button>Submit</button>")
let btn = Dom.Query.getByRole(container, "button")
Dom.Event.click(btn)`}
    />
    <div class="heading-anchor" id="dbl-click">
      <Typography text={static("Dom.Event.dblClick(element)")} variant={H3} />
      <a class="anchor-link" href="#dbl-click"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Simulates a double-click event.")} />
    <div class="heading-anchor" id="hover">
      <Typography text={static("Dom.Event.hover(element)")} variant={H3} />
      <a class="anchor-link" href="#hover"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Simulates hovering over an element (pointerenter, mouseenter, pointermove, mousemove).")} />
    <div class="heading-anchor" id="unhover">
      <Typography text={static("Dom.Event.unhover(element)")} variant={H3} />
      <a class="anchor-link" href="#unhover"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Simulates moving the pointer away from an element (pointermove, mousemove, pointerleave, mouseleave).")} />
    <Separator />
    // Keyboard / Text Input
    <div class="heading-anchor" id="keyboard">
      <Typography text={static("Keyboard / Text Input")} variant={H2} />
      <a class="anchor-link" href="#keyboard"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="type-text">
      <Typography text={static("Dom.Event.typeText(element, text)")} variant={H3} />
      <a class="anchor-link" href="#type-text"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Types text into an input element character by character. Fires keydown, keypress, beforeinput, input, keyup, and change events for each character. Updates the element's value.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render(\`<input type="text" />\`)
let input = Dom.Query.getByRole(container, "textbox")

Dom.Event.typeText(input, "hello world")
// input.value is now "hello world"`}
    />
    <div class="heading-anchor" id="clear">
      <Typography text={static("Dom.Event.clear(element)")} variant={H3} />
      <a class="anchor-link" href="#clear"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Clears the value of an input element. Simulates Select All + Delete.")} />
    <CodeBlock
      language="rescript"
      code={`Dom.Event.typeText(input, "hello")
Dom.Event.clear(input)
// input.value is now ""`}
    />
    <Separator />
    // Checkbox & Radio
    <div class="heading-anchor" id="checkbox">
      <Typography text={static("Checkbox & Radio")} variant={H2} />
      <a class="anchor-link" href="#checkbox"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="check">
      <Typography text={static("Dom.Event.check(element)")} variant={H3} />
      <a class="anchor-link" href="#check"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Checks a checkbox or radio button.")} />
    <div class="heading-anchor" id="uncheck">
      <Typography text={static("Dom.Event.uncheck(element)")} variant={H3} />
      <a class="anchor-link" href="#uncheck"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Unchecks a checkbox.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render(\`<input type="checkbox" />\`)
let cb = Dom.Query.getByRole(container, "checkbox")

Dom.Event.check(cb)
// cb.checked is now true

Dom.Event.uncheck(cb)
// cb.checked is now false`}
    />
    <Separator />
    // Select
    <div class="heading-anchor" id="select">
      <Typography text={static("Select")} variant={H2} />
      <a class="anchor-link" href="#select"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="select-options">
      <Typography text={static("Dom.Event.selectOptions(element, values)")} variant={H3} />
      <a class="anchor-link" href="#select-options"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Selects options in a <select> element by their value attributes.")} />
    <CodeBlock
      language="rescript"
      code={`let {container} = Dom.render(\`
  <select>
    <option value="a">Alpha</option>
    <option value="b">Beta</option>
  </select>
\`)
let select = Dom.Query.getByRole(container, "listbox")
Dom.Event.selectOptions(select, ["b"])`}
    />
    <Separator />
    // Focus
    <div class="heading-anchor" id="focus">
      <Typography text={static("Focus Management")} variant={H2} />
      <a class="anchor-link" href="#focus"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="focus-fn">
      <Typography text={static("Dom.Event.focus(element)")} variant={H3} />
      <a class="anchor-link" href="#focus-fn"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Focuses an element.")} />
    <div class="heading-anchor" id="blur-fn">
      <Typography text={static("Dom.Event.blur(element)")} variant={H3} />
      <a class="anchor-link" href="#blur-fn"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Removes focus from an element.")} />
    <Separator />
    // Custom Events
    <div class="heading-anchor" id="custom">
      <Typography text={static("Custom Events")} variant={H2} />
      <a class="anchor-link" href="#custom"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="fire-event">
      <Typography text={static("Dom.Event.fireEvent(element, event)")} variant={H3} />
      <a class="anchor-link" href="#fire-event"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Dispatches a custom DOM event on an element. Use this for events not covered by the built-in helpers.")} />
    <EditOnGitHub pageName="Pages__ApiDomEvents" />
  </div>
}
