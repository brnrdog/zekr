// DomAssert - DOM assertion functions returning testResult

open Types
open DomBindings

let toBeInTheDocument = (element: Dom.element): testResult => {
  let doc = ensureDocument()
  if documentContains(doc, element) {
    Pass
  } else {
    Fail("Expected element to be in the document, but it was not found")
  }
}

let toNotBeInTheDocument = (element: option<Dom.element>): testResult => {
  switch element {
  | None => Pass
  | Some(el) => {
      let doc = ensureDocument()
      if !documentContains(doc, el) {
        Pass
      } else {
        Fail("Expected element not to be in the document, but it was found")
      }
    }
  }
}

let toHaveTextContent = (element: Dom.element, expected: string, ~exact: bool=true): testResult => {
  let actual = DomQuery.normalizeText(textContent(element))
  let matches = if exact {
    actual === expected
  } else {
    actual->String.toLowerCase->String.includes(expected->String.toLowerCase)
  }

  if matches {
    Pass
  } else {
    Fail(
      `Expected element to have text content:\n` ++
      `       ${Colors.pass("+ expected")} ${Colors.fail("- actual")}\n` ++
      `       ${Colors.fail("- " ++ actual)}\n` ++
      `       ${Colors.pass("+ " ++ expected)}`,
    )
  }
}

let toHaveAttribute = (
  element: Dom.element,
  name: string,
  ~value: option<string>=?,
): testResult => {
  if !hasAttribute(element, name) {
    Fail(`Expected element to have attribute "${name}", but it does not`)
  } else {
    switch value {
    | None => Pass
    | Some(expectedValue) => {
        let actualValue =
          getAttribute(element, name)->Nullable.toOption->Option.getOr("")
        if actualValue === expectedValue {
          Pass
        } else {
          Fail(
            `Expected attribute "${name}" to have value "${expectedValue}", but got "${actualValue}"`,
          )
        }
      }
    }
  }
}

let toNotHaveAttribute = (element: Dom.element, name: string): testResult => {
  if hasAttribute(element, name) {
    Fail(`Expected element not to have attribute "${name}", but it does`)
  } else {
    Pass
  }
}

let toHaveClass = (element: Dom.element, className: string): testResult => {
  let classes = classList(element)
  let classNames = className->String.split(" ")
  let missingClasses = classNames->Array.filter(cls => !classListContains(classes, cls))

  if Array.length(missingClasses) === 0 {
    Pass
  } else {
    let missing = missingClasses->Array.join(", ")
    Fail(`Expected element to have class(es) "${className}", missing: ${missing}`)
  }
}

let toNotHaveClass = (element: Dom.element, className: string): testResult => {
  let classes = classList(element)
  let classNames = className->String.split(" ")
  let presentClasses = classNames->Array.filter(cls => classListContains(classes, cls))

  if Array.length(presentClasses) === 0 {
    Pass
  } else {
    let present = presentClasses->Array.join(", ")
    Fail(`Expected element not to have class(es) "${className}", but found: ${present}`)
  }
}

let toBeVisible = (element: Dom.element): testResult => {
  let win = getWindow()
  let computed = getComputedStyle(win, element)
  let display = styleDisplay(computed)
  let visibility = styleVisibility(computed)
  let opacity = styleOpacity(computed)

  let isHiddenByDisplay = display === "none"
  let isHiddenByVisibility = visibility === "hidden" || visibility === "collapse"
  let isHiddenByOpacity = opacity === "0"
  let isHiddenByAttribute = hasAttribute(element, "hidden")

  if isHiddenByDisplay || isHiddenByVisibility || isHiddenByOpacity || isHiddenByAttribute {
    let reason = if isHiddenByDisplay {
      "display: none"
    } else if isHiddenByVisibility {
      `visibility: ${visibility}`
    } else if isHiddenByOpacity {
      "opacity: 0"
    } else {
      "hidden attribute"
    }
    Fail(`Expected element to be visible, but it is hidden (${reason})`)
  } else {
    Pass
  }
}

let toNotBeVisible = (element: Dom.element): testResult => {
  switch toBeVisible(element) {
  | Pass => Fail("Expected element to be hidden, but it is visible")
  | Fail(_) => Pass
  }
}

let toBeDisabled = (element: Dom.element): testResult => {
  if disabled(element) {
    Pass
  } else {
    Fail("Expected element to be disabled, but it is enabled")
  }
}

let toBeEnabled = (element: Dom.element): testResult => {
  if !disabled(element) {
    Pass
  } else {
    Fail("Expected element to be enabled, but it is disabled")
  }
}

let toHaveValue = (element: Dom.element, expected: string): testResult => {
  let actual = DomBindings.value(element)
  if actual === expected {
    Pass
  } else {
    Fail(
      `Expected element to have value:\n` ++
      `       ${Colors.pass("+ expected")} ${Colors.fail("- actual")}\n` ++
      `       ${Colors.fail("- " ++ actual)}\n` ++
      `       ${Colors.pass("+ " ++ expected)}`,
    )
  }
}

let toBeChecked = (element: Dom.element): testResult => {
  if checked(element) {
    Pass
  } else {
    Fail("Expected element to be checked, but it is not")
  }
}

let toNotBeChecked = (element: Dom.element): testResult => {
  if !checked(element) {
    Pass
  } else {
    Fail("Expected element to be unchecked, but it is checked")
  }
}

let toContainElement = (container: Dom.element, child: Dom.element): testResult => {
  if contains(container, child) {
    Pass
  } else {
    Fail("Expected container to contain the given element, but it does not")
  }
}

let toNotContainElement = (container: Dom.element, child: Dom.element): testResult => {
  if !contains(container, child) {
    Pass
  } else {
    Fail("Expected container not to contain the given element, but it does")
  }
}

let toContainHTML = (element: Dom.element, htmlContent: string): testResult => {
  let html = innerHTML(element)
  if html->String.includes(htmlContent) {
    Pass
  } else {
    Fail(
      `Expected element to contain HTML "${htmlContent}", but innerHTML is:\n       "${html}"`,
    )
  }
}

let toBeEmptyDOMElement = (element: Dom.element): testResult => {
  if childElementCount(element) === 0 && textContent(element)->String.trim === "" {
    Pass
  } else {
    Fail("Expected element to be empty, but it has content")
  }
}

let toHaveStyle = (element: Dom.element, property: string, expected: string): testResult => {
  let inlineStyles = style(element)
  let actual = getPropertyValue(inlineStyles, property)
  if actual === expected {
    Pass
  } else {
    let win = getWindow()
    let computed = getComputedStyle(win, element)
    let computedValue = stylePropertyValue(computed, property)
    if computedValue === expected {
      Pass
    } else {
      Fail(
        `Expected element to have style "${property}: ${expected}", but got "${computedValue}"`,
      )
    }
  }
}

let toHaveFocus = (element: Dom.element): testResult => {
  let doc = ensureDocument()
  let active = activeElement(doc)->Nullable.toOption
  switch active {
  | Some(el) if el === element => Pass
  | _ => Fail("Expected element to have focus, but it does not")
  }
}

let toNotHaveFocus = (element: Dom.element): testResult => {
  switch toHaveFocus(element) {
  | Pass => Fail("Expected element not to have focus, but it does")
  | Fail(_) => Pass
  }
}
