// DomBindings - Low-level jsdom and DOM API bindings

// === JSDOM Types and Setup ===

type jsdom
type domWindow
type domDocument

module JSDOM = {
  @module("jsdom") @new
  external make: string => jsdom = "JSDOM"

  @get external window: jsdom => domWindow = "window"
  @get external document: domWindow => domDocument = "document"
}

// === Document Methods ===

@send external createElement: (domDocument, string) => Dom.element = "createElement"
@get external documentBody: domDocument => Dom.element = "body"
@send external documentContains: (domDocument, Dom.element) => bool = "contains"
@get external activeElement: domDocument => Nullable.t<Dom.element> = "activeElement"

// === Element Properties ===

@get external textContent: Dom.element => string = "textContent"
@get external innerHTML: Dom.element => string = "innerHTML"
@set external setInnerHTML: (Dom.element, string) => unit = "innerHTML"
@get external tagName: Dom.element => string = "tagName"
@get external nodeName: Dom.element => string = "nodeName"
@get external parentElement: Dom.element => Nullable.t<Dom.element> = "parentElement"
@get external childElementCount: Dom.element => int = "childElementCount"

// Form element properties
@get external value: Dom.element => string = "value"
@set external setValue: (Dom.element, string) => unit = "value"
@get external checked: Dom.element => bool = "checked"
@set external setChecked: (Dom.element, bool) => unit = "checked"
@get external disabled: Dom.element => bool = "disabled"
@get external selectedIndex: Dom.element => int = "selectedIndex"
@set external setSelectedIndex: (Dom.element, int) => unit = "selectedIndex"
@get external placeholder: Dom.element => string = "placeholder"

// Style and visibility
type computedStyle
@get external styleDisplay: computedStyle => string = "display"
@get external styleVisibility: computedStyle => string = "visibility"
@get external styleOpacity: computedStyle => string = "opacity"
@send external stylePropertyValue: (computedStyle, string) => string = "getPropertyValue"

type inlineStyle
@get external style: Dom.element => inlineStyle = "style"
@send external getPropertyValue: (inlineStyle, string) => string = "getPropertyValue"

// Element type checking
@get external elementType: Dom.element => string = "type"

// === Element Methods ===

@send external getAttribute: (Dom.element, string) => Nullable.t<string> = "getAttribute"
@send external hasAttribute: (Dom.element, string) => bool = "hasAttribute"
@send external querySelector: (Dom.element, string) => Nullable.t<Dom.element> = "querySelector"
@send external closest: (Dom.element, string) => Nullable.t<Dom.element> = "closest"
@send external matches: (Dom.element, string) => bool = "matches"
@send external contains: (Dom.element, Dom.element) => bool = "contains"
@send external appendChild: (Dom.element, Dom.element) => unit = "appendChild"
@send external removeChild: (Dom.element, Dom.element) => unit = "removeChild"
@send external remove: Dom.element => unit = "remove"

// classList
type classList
@get external classList: Dom.element => classList = "classList"
@send external classListContains: (classList, string) => bool = "contains"

// Native element methods
@send external clickElement: Dom.element => unit = "click"
@send external focusElement: Dom.element => unit = "focus"
@send external blurElement: Dom.element => unit = "blur"

// === querySelectorAll with Array conversion ===

type nodeList
@send external querySelectorAllRaw: (Dom.element, string) => nodeList = "querySelectorAll"
@val external arrayFrom: nodeList => array<Dom.element> = "Array.from"

let querySelectorAll = (element, selector) => arrayFrom(querySelectorAllRaw(element, selector))

// === Events ===

type eventInit = {
  bubbles?: bool,
  cancelable?: bool,
  composed?: bool,
}

type mouseEventInit = {
  bubbles?: bool,
  cancelable?: bool,
  composed?: bool,
  button?: int,
  detail?: int,
}

type keyboardEventInit = {
  bubbles?: bool,
  cancelable?: bool,
  key?: string,
  code?: string,
  charCode?: int,
}

type inputEventInit = {
  bubbles?: bool,
  cancelable?: bool,
  data?: string,
  inputType?: string,
}

// Event constructors - created from the jsdom window to ensure they exist in Node.js
let makeEvent: (string, eventInit) => Dom.event = %raw(`
  function(type, init) {
    var win = globalThis.__zekr_window;
    if (!win) throw new Error("DOM environment not initialized. Call render() first.");
    return new win.Event(type, init);
  }
`)

let makeMouseEvent: (string, mouseEventInit) => Dom.event = %raw(`
  function(type, init) {
    var win = globalThis.__zekr_window;
    if (!win) throw new Error("DOM environment not initialized. Call render() first.");
    return new win.MouseEvent(type, init);
  }
`)

let makeKeyboardEvent: (string, keyboardEventInit) => Dom.event = %raw(`
  function(type, init) {
    var win = globalThis.__zekr_window;
    if (!win) throw new Error("DOM environment not initialized. Call render() first.");
    return new win.KeyboardEvent(type, init);
  }
`)

let makeInputEvent: (string, inputEventInit) => Dom.event = %raw(`
  function(type, init) {
    var win = globalThis.__zekr_window;
    if (!win) throw new Error("DOM environment not initialized. Call render() first.");
    return new win.InputEvent(type, init);
  }
`)

@send external dispatchEvent: (Dom.element, Dom.event) => bool = "dispatchEvent"

// === Window Methods ===

@send external getComputedStyle: (domWindow, Dom.element) => computedStyle = "getComputedStyle"

// === Global State Management ===

let currentJsdom: ref<option<jsdom>> = ref(None)
let currentDocument: ref<option<domDocument>> = ref(None)
let currentWindow: ref<option<domWindow>> = ref(None)

@set external setGlobalWindow: ({..}, domWindow) => unit = "__zekr_window"
@val external globalThis: {..} = "globalThis"
@set external clearGlobalWindow: ({..}, Nullable.t<domWindow>) => unit = "__zekr_window"

let ensureDocument = () => {
  switch currentDocument.contents {
  | Some(doc) => doc
  | None => {
      let dom = JSDOM.make(
        "<!DOCTYPE html><html><head></head><body></body></html>",
      )
      let win = JSDOM.window(dom)
      let doc = JSDOM.document(win)
      currentJsdom := Some(dom)
      currentWindow := Some(win)
      currentDocument := Some(doc)
      setGlobalWindow(globalThis, win)
      doc
    }
  }
}

let getWindow = () => {
  let _ = ensureDocument()
  switch currentWindow.contents {
  | Some(win) => win
  | None => panic("DOM environment not initialized")
  }
}

let resetDom = () => {
  currentJsdom := None
  currentDocument := None
  currentWindow := None
  clearGlobalWindow(globalThis, Nullable.null)
}

// === Select element helpers ===

type selectOption
type optionsCollection
@get external selectOptionsRaw: Dom.element => optionsCollection = "options"
@val external arrayFromOptions: optionsCollection => array<selectOption> = "Array.from"
let selectOptions = (element) => arrayFromOptions(selectOptionsRaw(element))
@get external optionValue: selectOption => string = "value"
@set external setOptionSelected: (selectOption, bool) => unit = "selected"
@get external optionSelected: selectOption => bool = "selected"

// Labels
@get external htmlFor: Dom.element => string = "htmlFor"
@get external id: Dom.element => string = "id"
@get external altText: Dom.element => string = "alt"
@get external title: Dom.element => string = "title"
