// DomQuery - DOM query functions inspired by Testing Library

open DomBindings

exception QueryError(string)

// === Internal Helpers ===

let normalizeText = (text: string) => {
  text->String.trim->String.replaceRegExp(%re("/\s+/g"), " ")
}

let getTagName = (element: Dom.element) => {
  tagName(element)->String.toLowerCase
}

let getImplicitRole = (element: Dom.element) => {
  let tag = getTagName(element)
  switch tag {
  | "button" => Some("button")
  | "a" =>
    if hasAttribute(element, "href") {
      Some("link")
    } else {
      None
    }
  | "input" => {
      let inputType =
        getAttribute(element, "type")
        ->Nullable.toOption
        ->Option.getOr("text")
        ->String.toLowerCase
      switch inputType {
      | "button" | "submit" | "reset" => Some("button")
      | "checkbox" => Some("checkbox")
      | "radio" => Some("radio")
      | "text" | "email" | "password" | "search" | "tel" | "url" => Some("textbox")
      | "number" => Some("spinbutton")
      | "range" => Some("slider")
      | _ => None
      }
    }
  | "textarea" => Some("textbox")
  | "select" => Some("listbox")
  | "h1" | "h2" | "h3" | "h4" | "h5" | "h6" => Some("heading")
  | "ul" | "ol" => Some("list")
  | "li" => Some("listitem")
  | "nav" => Some("navigation")
  | "main" => Some("main")
  | "header" => Some("banner")
  | "footer" => Some("contentinfo")
  | "form" => Some("form")
  | "table" => Some("table")
  | "img" => Some("img")
  | "dialog" => Some("dialog")
  | "article" => Some("article")
  | "aside" => Some("complementary")
  | "section" =>
    if hasAttribute(element, "aria-label") || hasAttribute(element, "aria-labelledby") {
      Some("region")
    } else {
      None
    }
  | "progress" => Some("progressbar")
  | "meter" => Some("meter")
  | "output" => Some("status")
  | "details" => Some("group")
  | _ => None
  }
}

let getRole = (element: Dom.element) => {
  let explicitRole = getAttribute(element, "role")->Nullable.toOption
  switch explicitRole {
  | Some(role) => Some(role)
  | None => getImplicitRole(element)
  }
}

let getAllElements = (container: Dom.element) => {
  querySelectorAll(container, "*")
}

// === Query by Text ===

let findAllByText = (container: Dom.element, text: string, ~exact: bool=true) => {
  let elements = getAllElements(container)
  elements->Array.filter(el => {
    let content = normalizeText(textContent(el))
    if exact {
      content === text
    } else {
      content->String.toLowerCase->String.includes(text->String.toLowerCase)
    }
  })
}

let getAllByText = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByText(container, text, ~exact)
  if Array.length(results) === 0 {
    throw(QueryError(`Unable to find an element with the text: "${text}"`))
  }
  results
}

let getByText = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByText(container, text, ~exact)
  switch results {
  | [] => throw(QueryError(`Unable to find an element with the text: "${text}"`))
  | [el] => el
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the text: "${text}". Use getAllByText instead.`,
      ),
    )
  }
}

let queryByText = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByText(container, text, ~exact)
  switch results {
  | [] => None
  | [el] => Some(el)
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the text: "${text}". Use queryAllByText instead.`,
      ),
    )
  }
}

// === Query by Role ===

let findAllByRole = (
  container: Dom.element,
  role: string,
  ~name: option<string>=?,
  ~checked: option<bool>=?,
  ~level: option<int>=?,
) => {
  let elements = getAllElements(container)
  elements->Array.filter(el => {
    let elementRole = getRole(el)
    let roleMatches = elementRole === Some(role)

    let nameMatches = switch name {
    | None => true
    | Some(expectedName) => {
        let accessibleName =
          getAttribute(el, "aria-label")
          ->Nullable.toOption
          ->Option.getOr(normalizeText(textContent(el)))
        accessibleName === expectedName
      }
    }

    let checkedMatches = switch checked {
    | None => true
    | Some(expectedChecked) =>
      DomBindings.checked(el) === expectedChecked
    }

    let levelMatches = switch level {
    | None => true
    | Some(expectedLevel) => {
        let tag = getTagName(el)
        let ariaLevel =
          getAttribute(el, "aria-level")
          ->Nullable.toOption
          ->Option.flatMap(v => Int.fromString(v))
        switch ariaLevel {
        | Some(l) => l === expectedLevel
        | None =>
          switch tag {
          | "h1" => expectedLevel === 1
          | "h2" => expectedLevel === 2
          | "h3" => expectedLevel === 3
          | "h4" => expectedLevel === 4
          | "h5" => expectedLevel === 5
          | "h6" => expectedLevel === 6
          | _ => false
          }
        }
      }
    }

    roleMatches && nameMatches && checkedMatches && levelMatches
  })
}

let getAllByRole = (
  container: Dom.element,
  role: string,
  ~name: option<string>=?,
  ~checked: option<bool>=?,
  ~level: option<int>=?,
) => {
  let results = findAllByRole(container, role, ~name?, ~checked?, ~level?)
  if Array.length(results) === 0 {
    throw(QueryError(`Unable to find an element with the role: "${role}"`))
  }
  results
}

let getByRole = (
  container: Dom.element,
  role: string,
  ~name: option<string>=?,
  ~checked: option<bool>=?,
  ~level: option<int>=?,
) => {
  let results = findAllByRole(container, role, ~name?, ~checked?, ~level?)
  switch results {
  | [] => throw(QueryError(`Unable to find an element with the role: "${role}"`))
  | [el] => el
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the role: "${role}". Use getAllByRole instead.`,
      ),
    )
  }
}

let queryByRole = (
  container: Dom.element,
  role: string,
  ~name: option<string>=?,
  ~checked: option<bool>=?,
  ~level: option<int>=?,
) => {
  let results = findAllByRole(container, role, ~name?, ~checked?, ~level?)
  switch results {
  | [] => None
  | [el] => Some(el)
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the role: "${role}". Use queryAllByRole instead.`,
      ),
    )
  }
}

// === Query by TestId ===

let findAllByTestId = (container: Dom.element, testId: string) => {
  querySelectorAll(container, `[data-testid="${testId}"]`)
}

let getAllByTestId = (container: Dom.element, testId: string) => {
  let results = findAllByTestId(container, testId)
  if Array.length(results) === 0 {
    throw(QueryError(`Unable to find an element with the test id: "${testId}"`))
  }
  results
}

let getByTestId = (container: Dom.element, testId: string) => {
  let results = findAllByTestId(container, testId)
  switch results {
  | [] => throw(QueryError(`Unable to find an element with the test id: "${testId}"`))
  | [el] => el
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the test id: "${testId}". Use getAllByTestId instead.`,
      ),
    )
  }
}

let queryByTestId = (container: Dom.element, testId: string) => {
  let results = findAllByTestId(container, testId)
  switch results {
  | [] => None
  | [el] => Some(el)
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the test id: "${testId}". Use queryAllByTestId instead.`,
      ),
    )
  }
}

// === Query by Placeholder ===

let findAllByPlaceholder = (container: Dom.element, placeholderText: string, ~exact: bool=true) => {
  let elements = querySelectorAll(container, "[placeholder]")
  elements->Array.filter(el => {
    let ph = placeholder(el)
    if exact {
      ph === placeholderText
    } else {
      ph->String.toLowerCase->String.includes(placeholderText->String.toLowerCase)
    }
  })
}

let getAllByPlaceholder = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByPlaceholder(container, text, ~exact)
  if Array.length(results) === 0 {
    throw(QueryError(`Unable to find an element with the placeholder: "${text}"`))
  }
  results
}

let getByPlaceholder = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByPlaceholder(container, text, ~exact)
  switch results {
  | [] => throw(QueryError(`Unable to find an element with the placeholder: "${text}"`))
  | [el] => el
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the placeholder: "${text}". Use getAllByPlaceholder instead.`,
      ),
    )
  }
}

let queryByPlaceholder = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByPlaceholder(container, text, ~exact)
  switch results {
  | [] => None
  | [el] => Some(el)
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the placeholder: "${text}". Use queryAllByPlaceholder instead.`,
      ),
    )
  }
}

// === Query by Label Text ===

let findAllByLabelText = (container: Dom.element, text: string, ~exact: bool=true) => {
  let labels = querySelectorAll(container, "label")
  let matchingLabels = labels->Array.filter(label => {
    let content = normalizeText(textContent(label))
    if exact {
      content === text
    } else {
      content->String.toLowerCase->String.includes(text->String.toLowerCase)
    }
  })

  matchingLabels->Array.filterMap(label => {
    let forAttr = htmlFor(label)
    if forAttr !== "" {
      querySelector(container, `#${forAttr}`)->Nullable.toOption
    } else {
      querySelector(label, "input, select, textarea")->Nullable.toOption
    }
  })
}

let getAllByLabelText = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByLabelText(container, text, ~exact)
  if Array.length(results) === 0 {
    throw(QueryError(`Unable to find an element with the label text: "${text}"`))
  }
  results
}

let getByLabelText = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByLabelText(container, text, ~exact)
  switch results {
  | [] => throw(QueryError(`Unable to find an element with the label text: "${text}"`))
  | [el] => el
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the label text: "${text}". Use getAllByLabelText instead.`,
      ),
    )
  }
}

let queryByLabelText = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByLabelText(container, text, ~exact)
  switch results {
  | [] => None
  | [el] => Some(el)
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the label text: "${text}". Use queryAllByLabelText instead.`,
      ),
    )
  }
}

// === Query by Alt Text ===

let findAllByAltText = (container: Dom.element, text: string, ~exact: bool=true) => {
  let elements = querySelectorAll(container, "[alt]")
  elements->Array.filter(el => {
    let alt = altText(el)
    if exact {
      alt === text
    } else {
      alt->String.toLowerCase->String.includes(text->String.toLowerCase)
    }
  })
}

let getAllByAltText = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByAltText(container, text, ~exact)
  if Array.length(results) === 0 {
    throw(QueryError(`Unable to find an element with the alt text: "${text}"`))
  }
  results
}

let getByAltText = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByAltText(container, text, ~exact)
  switch results {
  | [] => throw(QueryError(`Unable to find an element with the alt text: "${text}"`))
  | [el] => el
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the alt text: "${text}". Use getAllByAltText instead.`,
      ),
    )
  }
}

let queryByAltText = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByAltText(container, text, ~exact)
  switch results {
  | [] => None
  | [el] => Some(el)
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the alt text: "${text}". Use queryAllByAltText instead.`,
      ),
    )
  }
}

// === Query by Title ===

let findAllByTitle = (container: Dom.element, text: string, ~exact: bool=true) => {
  let elements = querySelectorAll(container, "[title]")
  elements->Array.filter(el => {
    let t = DomBindings.title(el)
    if exact {
      t === text
    } else {
      t->String.toLowerCase->String.includes(text->String.toLowerCase)
    }
  })
}

let getAllByTitle = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByTitle(container, text, ~exact)
  if Array.length(results) === 0 {
    throw(QueryError(`Unable to find an element with the title: "${text}"`))
  }
  results
}

let getByTitle = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByTitle(container, text, ~exact)
  switch results {
  | [] => throw(QueryError(`Unable to find an element with the title: "${text}"`))
  | [el] => el
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the title: "${text}". Use getAllByTitle instead.`,
      ),
    )
  }
}

let queryByTitle = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByTitle(container, text, ~exact)
  switch results {
  | [] => None
  | [el] => Some(el)
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the title: "${text}". Use queryAllByTitle instead.`,
      ),
    )
  }
}

// === Query by Display Value ===

let findAllByDisplayValue = (container: Dom.element, displayValue: string, ~exact: bool=true) => {
  let inputs = querySelectorAll(container, "input, textarea, select")
  inputs->Array.filter(el => {
    let val = value(el)
    if exact {
      val === displayValue
    } else {
      val->String.toLowerCase->String.includes(displayValue->String.toLowerCase)
    }
  })
}

let getAllByDisplayValue = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByDisplayValue(container, text, ~exact)
  if Array.length(results) === 0 {
    throw(QueryError(`Unable to find an element with the display value: "${text}"`))
  }
  results
}

let getByDisplayValue = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByDisplayValue(container, text, ~exact)
  switch results {
  | [] =>
    throw(QueryError(`Unable to find an element with the display value: "${text}"`))
  | [el] => el
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the display value: "${text}". Use getAllByDisplayValue instead.`,
      ),
    )
  }
}

let queryByDisplayValue = (container: Dom.element, text: string, ~exact: bool=true) => {
  let results = findAllByDisplayValue(container, text, ~exact)
  switch results {
  | [] => None
  | [el] => Some(el)
  | _ =>
    throw(
      QueryError(
        `Found multiple elements with the display value: "${text}". Use queryAllByDisplayValue instead.`,
      ),
    )
  }
}
