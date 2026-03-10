// Zekr__DomEvent - User interaction simulation inspired by user-event

open Zekr__DomBindings

// === Mouse Events ===

let click = (element: Dom.element) => {
  let pointerOver = makeMouseEvent("pointerover", {bubbles: true, cancelable: true})
  let pointerEnter = makeMouseEvent("pointerenter", {bubbles: false, cancelable: false})
  let mouseOver = makeMouseEvent("mouseover", {bubbles: true, cancelable: true})
  let mouseEnter = makeMouseEvent("mouseenter", {bubbles: false, cancelable: false})
  let pointerDown = makeMouseEvent("pointerdown", {bubbles: true, cancelable: true})
  let mouseDown = makeMouseEvent("mousedown", {bubbles: true, cancelable: true})
  let pointerUp = makeMouseEvent("pointerup", {bubbles: true, cancelable: true})
  let mouseUp = makeMouseEvent("mouseup", {bubbles: true, cancelable: true})
  let clickEvent = makeMouseEvent("click", {bubbles: true, cancelable: true, detail: 1})

  let _ = dispatchEvent(element, pointerOver)
  let _ = dispatchEvent(element, pointerEnter)
  let _ = dispatchEvent(element, mouseOver)
  let _ = dispatchEvent(element, mouseEnter)
  let _ = dispatchEvent(element, pointerDown)
  let _ = dispatchEvent(element, mouseDown)
  focusElement(element)
  let _ = dispatchEvent(element, pointerUp)
  let _ = dispatchEvent(element, mouseUp)
  let _ = dispatchEvent(element, clickEvent)
}

let dblClick = (element: Dom.element) => {
  click(element)

  let pointerDown = makeMouseEvent("pointerdown", {bubbles: true, cancelable: true})
  let mouseDown = makeMouseEvent("mousedown", {bubbles: true, cancelable: true, detail: 2})
  let pointerUp = makeMouseEvent("pointerup", {bubbles: true, cancelable: true})
  let mouseUp = makeMouseEvent("mouseup", {bubbles: true, cancelable: true, detail: 2})
  let clickEvent = makeMouseEvent("click", {bubbles: true, cancelable: true, detail: 2})
  let dblClickEvent = makeMouseEvent("dblclick", {
    bubbles: true,
    cancelable: true,
    detail: 2,
  })

  let _ = dispatchEvent(element, pointerDown)
  let _ = dispatchEvent(element, mouseDown)
  let _ = dispatchEvent(element, pointerUp)
  let _ = dispatchEvent(element, mouseUp)
  let _ = dispatchEvent(element, clickEvent)
  let _ = dispatchEvent(element, dblClickEvent)
}

// === Keyboard / Text Input ===

let typeText = (element: Dom.element, text: string) => {
  focusElement(element)

  let chars = text->String.split("")
  chars->Array.forEach(char => {
    let keyDown = makeKeyboardEvent("keydown", {
      bubbles: true,
      cancelable: true,
      key: char,
    })
    let keyPress = makeKeyboardEvent("keypress", {
      bubbles: true,
      cancelable: true,
      key: char,
    })
    let beforeInput = makeInputEvent("beforeinput", {
      bubbles: true,
      cancelable: true,
      data: char,
      inputType: "insertText",
    })
    let input = makeInputEvent("input", {
      bubbles: true,
      cancelable: false,
      data: char,
      inputType: "insertText",
    })
    let keyUp = makeKeyboardEvent("keyup", {
      bubbles: true,
      cancelable: true,
      key: char,
    })

    let _ = dispatchEvent(element, keyDown)
    let _ = dispatchEvent(element, keyPress)
    let _ = dispatchEvent(element, beforeInput)
    setValue(element, value(element) ++ char)
    let _ = dispatchEvent(element, input)
    let _ = dispatchEvent(element, keyUp)
  })

  let change = makeEvent("change", {bubbles: true, cancelable: false})
  let _ = dispatchEvent(element, change)
}

let clear = (element: Dom.element) => {
  focusElement(element)

  let selectAll = makeKeyboardEvent("keydown", {
    bubbles: true,
    cancelable: true,
    key: "a",
    code: "KeyA",
  })
  let _ = dispatchEvent(element, selectAll)

  let beforeInput = makeInputEvent("beforeinput", {
    bubbles: true,
    cancelable: true,
    inputType: "deleteContentBackward",
  })
  let _ = dispatchEvent(element, beforeInput)

  setValue(element, "")

  let input = makeInputEvent("input", {
    bubbles: true,
    cancelable: false,
    inputType: "deleteContentBackward",
  })
  let _ = dispatchEvent(element, input)

  let change = makeEvent("change", {bubbles: true, cancelable: false})
  let _ = dispatchEvent(element, change)
}

// === Checkbox / Radio ===

let check = (element: Dom.element) => {
  if !checked(element) {
    click(element)
    setChecked(element, true)
    let change = makeEvent("change", {bubbles: true, cancelable: false})
    let _ = dispatchEvent(element, change)
  }
}

let uncheck = (element: Dom.element) => {
  if checked(element) {
    click(element)
    setChecked(element, false)
    let change = makeEvent("change", {bubbles: true, cancelable: false})
    let _ = dispatchEvent(element, change)
  }
}

// === Select ===

let selectOptions = (element: Dom.element, values: array<string>) => {
  focusElement(element)

  let options = Zekr__DomBindings.selectOptions(element)
  options->Array.forEach(option => {
    let optVal = optionValue(option)
    let shouldSelect = values->Array.includes(optVal)
    setOptionSelected(option, shouldSelect)
  })

  let input = makeEvent("input", {bubbles: true, cancelable: false})
  let _ = dispatchEvent(element, input)
  let change = makeEvent("change", {bubbles: true, cancelable: false})
  let _ = dispatchEvent(element, change)
}

// === Focus Management ===

let focus = (element: Dom.element) => {
  let focusIn = makeEvent("focusin", {bubbles: true, cancelable: false})
  let focusEvent = makeEvent("focus", {bubbles: false, cancelable: false})
  focusElement(element)
  let _ = dispatchEvent(element, focusIn)
  let _ = dispatchEvent(element, focusEvent)
}

let blur = (element: Dom.element) => {
  let focusOut = makeEvent("focusout", {bubbles: true, cancelable: false})
  let blurEvent = makeEvent("blur", {bubbles: false, cancelable: false})
  blurElement(element)
  let _ = dispatchEvent(element, focusOut)
  let _ = dispatchEvent(element, blurEvent)
}

// === Hover ===

let hover = (element: Dom.element) => {
  let pointerOver = makeMouseEvent("pointerover", {bubbles: true, cancelable: true})
  let pointerEnter = makeMouseEvent("pointerenter", {bubbles: false, cancelable: false})
  let mouseOver = makeMouseEvent("mouseover", {bubbles: true, cancelable: true})
  let mouseEnter = makeMouseEvent("mouseenter", {bubbles: false, cancelable: false})

  let _ = dispatchEvent(element, pointerOver)
  let _ = dispatchEvent(element, pointerEnter)
  let _ = dispatchEvent(element, mouseOver)
  let _ = dispatchEvent(element, mouseEnter)
}

let unhover = (element: Dom.element) => {
  let pointerOut = makeMouseEvent("pointerout", {bubbles: true, cancelable: true})
  let pointerLeave = makeMouseEvent("pointerleave", {bubbles: false, cancelable: false})
  let mouseOut = makeMouseEvent("mouseout", {bubbles: true, cancelable: true})
  let mouseLeave = makeMouseEvent("mouseleave", {bubbles: false, cancelable: false})

  let _ = dispatchEvent(element, pointerOut)
  let _ = dispatchEvent(element, pointerLeave)
  let _ = dispatchEvent(element, mouseOut)
  let _ = dispatchEvent(element, mouseLeave)
}

// === Low-level Event Dispatch ===

let fireEvent = (element: Dom.element, event: Dom.event) => {
  let _ = dispatchEvent(element, event)
}
