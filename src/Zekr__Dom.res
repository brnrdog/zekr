// Zekr__Dom - DOM rendering and testing utilities

open Zekr__DomBindings

type renderResult = {
  container: Dom.element,
  baseElement: Dom.element,
}

let containers: ref<array<Dom.element>> = ref([])

let render = (html: string) => {
  let doc = ensureDocument()
  let body = documentBody(doc)
  let container = createElement(doc, "div")
  setInnerHTML(container, html)
  appendChild(body, container)
  containers := containers.contents->Array.concat([container])
  {container, baseElement: body}
}

let cleanup = () => {
  containers.contents->Array.forEach(container => {
    remove(container)
  })
  containers := []
}

let cleanupAll = () => {
  cleanup()
  resetDom()
}

// Re-export submodules for convenient access
module Query = Zekr__DomQuery
module Event = Zekr__DomEvent
module Assert = Zekr__DomAssert
