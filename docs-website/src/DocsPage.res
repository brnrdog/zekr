open Xote

// ---- DOM bindings for TOC ----
@val @scope("document") external querySelector: string => Nullable.t<Dom.element> = "querySelector"
@val @scope("document")
external querySelectorAll: string => array<Dom.element> = "querySelectorAll"
@get external textContent: Dom.element => string = "textContent"
@send external getAttribute: (Dom.element, string) => Nullable.t<string> = "getAttribute"
@val external setTimeout: (unit => unit, int) => int = "setTimeout"

// ---- Navigation data ----
type docItem = {
  title: string,
  path: string,
}

type docCategory = {
  label: string,
  items: array<docItem>,
}

let docsNav: array<docCategory> = [
  {
    label: "Getting Started",
    items: [{title: "Installation", path: "/getting-started"}],
  },
  {
    label: "API Reference",
    items: [
      {title: "Tests & Suites", path: "/api/tests"},
      {title: "Assertions", path: "/api/assertions"},
      {title: "DOM Testing", path: "/api/dom"},
      {title: "DOM Queries", path: "/api/dom/queries"},
      {title: "DOM Events", path: "/api/dom/events"},
      {title: "DOM Assertions", path: "/api/dom/assertions"},
      {title: "Snapshots", path: "/api/snapshots"},
      {title: "Test Runner", path: "/api/runner"},
      {title: "Test Coverage", path: "/api/coverage"},
    ],
  },
  {
    label: "Resources",
    items: [
      {title: "Examples", path: "/examples"},
      {title: "Release Notes", path: "/release-notes"},
    ],
  },
]

// Flatten for prev/next
let flatItems = docsNav->Array.flatMap(cat => cat.items)

// Find prev/next
let getPrevNext = (currentPath: string) => {
  let idx = flatItems->Array.findIndex(item => item.path == currentPath)
  let prev = if idx > 0 {
    flatItems->Array.get(idx - 1)
  } else {
    None
  }
  let next = if idx >= 0 && idx < Array.length(flatItems) - 1 {
    flatItems->Array.get(idx + 1)
  } else {
    None
  }
  (prev, next)
}

// Find category + title for breadcrumb
let getCategoryAndTitle = (currentPath: string) => {
  let result = ref(("", ""))
  docsNav->Array.forEach(cat => {
    cat.items->Array.forEach(item => {
      if item.path == currentPath {
        result := (cat.label, item.title)
      }
    })
  })
  result.contents
}

// ---- Sidebar ----
module Sidebar = {
  type props = {currentPath: string}

  let make = (props: props) => {
    let {currentPath} = props
    <aside class="docs-sidebar">
      {Component.fragment(
        docsNav->Array.map(category => {
          <div class="sidebar-section">
            <div class="sidebar-section-title"> {Component.text(category.label)} </div>
            {Component.fragment(
              category.items->Array.map(item => {
                let isActive = currentPath == item.path
                let className = "sidebar-link" ++ (isActive ? " active" : "")
                Router.link(
                  ~to=item.path,
                  ~attrs=[Component.attr("class", className)],
                  ~children=[Component.text(item.title)],
                  (),
                )
              }),
            )}
          </div>
        }),
      )}
    </aside>
  }
}

// ---- Breadcrumb ----
module DocsBreadcrumb = {
  type props = {currentPath: string}

  let make = (props: props) => {
    let (category, title) = getCategoryAndTitle(props.currentPath)
    <nav class="docs-breadcrumb">
      {Router.link(~to="/getting-started", ~children=[Component.text("Docs")], ())}
      {if category != "" && category != "Getting Started" {
        Component.fragment([
          <span class="docs-breadcrumb-sep"> {Component.text("/")} </span>,
          <span> {Component.text(category)} </span>,
        ])
      } else {
        Component.fragment([])
      }}
      <span class="docs-breadcrumb-sep"> {Component.text("/")} </span>
      <span class="docs-breadcrumb-current"> {Component.text(title)} </span>
    </nav>
  }
}

// ---- Prev/Next ----
module PrevNextNav = {
  type props = {currentPath: string}

  let make = (props: props) => {
    let (prev, next) = getPrevNext(props.currentPath)
    <div class="docs-prev-next">
      {switch prev {
      | Some(item) =>
        Router.link(
          ~to=item.path,
          ~attrs=[Component.attr("class", "docs-prev-next-link")],
          ~children=[
            <span class="docs-prev-next-label">
              {Component.text("\u2190 Previous")}
            </span>,
            <span class="docs-prev-next-title"> {Component.text(item.title)} </span>,
          ],
          (),
        )
      | None => <div />
      }}
      {switch next {
      | Some(item) =>
        Router.link(
          ~to=item.path,
          ~attrs=[Component.attr("class", "docs-prev-next-link next")],
          ~children=[
            <span class="docs-prev-next-label">
              {Component.text("Next \u2192")}
            </span>,
            <span class="docs-prev-next-title"> {Component.text(item.title)} </span>,
          ],
          (),
        )
      | None => <div />
      }}
    </div>
  }
}

// ---- Table of Contents (right-floating) ----
module TableOfContents = {
  type props = {currentPath: string}

  type tocItem = {
    id: string,
    label: string,
    level: int,
  }

  let scanHeadings = (): array<tocItem> => {
    let nodes = querySelectorAll(".docs-content .heading-anchor[id]")
    nodes->Array.filterMap(node => {
      switch getAttribute(node, "id")->Nullable.toOption {
      | Some(id) when id != "" =>
        let label = textContent(node)->String.trim->String.replaceRegExp(%re("/#$/"), "")->String.trim
        // Look at the first heading element inside the anchor wrapper to determine level
        let level = if Nullable.toOption(querySelector("#" ++ id ++ " h2")) != None {
          2
        } else if Nullable.toOption(querySelector("#" ++ id ++ " h3")) != None {
          3
        } else {
          2
        }
        Some({id, label, level})
      | _ => None
      }
    })
  }

  let make = (props: props) => {
    let items = Signal.make([])
    // Track active heading id (updated on scroll)
    let activeId = Signal.make("")

    // Re-scan whenever the page path changes
    let _ = Effect.run(() => {
      let _ = props.currentPath // depend on prop
      let _ = setTimeout(() => Signal.set(items, scanHeadings()), 50)
      let _ = setTimeout(() => Signal.set(items, scanHeadings()), 250)
      None
    })

    // Track which heading is currently in view
    let elementTop = (el: Dom.element): float => {
      let _ = el
      %raw(`el.getBoundingClientRect().top + window.scrollY`)
    }
    let _ = Effect.run(() => {
      let handleScroll = () => {
        let scrollY: float = %raw(`window.scrollY`)
        let offset = scrollY +. 100.0
        let current = ref("")
        Signal.peek(items)->Array.forEach(item => {
          switch querySelector("#" ++ item.id)->Nullable.toOption {
          | Some(el) =>
            if elementTop(el) <= offset {
              current := item.id
            }
          | None => ()
          }
        })
        Signal.set(activeId, current.contents)
      }
      let _ = %raw(`window.addEventListener("scroll", handleScroll, { passive: true })`)
      handleScroll()
      Some(() => %raw(`window.removeEventListener("scroll", handleScroll)`))
    })

    <aside class="docs-toc">
      <div class="docs-toc-title"> {Component.text("On this page")} </div>
      {Component.signalFragment(
        Computed.make(() => {
          let list = Signal.get(items)
          let active = Signal.get(activeId)
          if Array.length(list) == 0 {
            []
          } else {
            [
              Component.element(
                "ul",
                ~attrs=[Component.attr("class", "docs-toc-list")],
                ~children=list->Array.map(item => {
                  let cn =
                    "docs-toc-link docs-toc-level-" ++
                    Int.toString(item.level) ++ (item.id == active ? " active" : "")
                  Component.element(
                    "li",
                    ~children=[
                      Component.element(
                        "a",
                        ~attrs=[
                          Component.attr("href", "#" ++ item.id),
                          Component.attr("class", cn),
                        ],
                        ~children=[Component.text(item.label)],
                        (),
                      ),
                    ],
                    (),
                  )
                }),
                (),
              ),
            ]
          }
        }),
      )}
    </aside>
  }
}

// ---- Feedback Widget ----
module FeedbackWidget = {
  type props = {}

  let make = (_props: props) => {
    let feedback = Signal.make("")

    <div class="docs-feedback">
      {Component.text("Was this page helpful?")}
      {Component.element(
        "button",
        ~attrs=[
          Component.computedAttr("class", () =>
            "feedback-btn" ++ (Signal.get(feedback) == "yes" ? " selected" : "")
          ),
          Component.attr("title", "Yes"),
        ],
        ~events=[("click", _ => Signal.set(feedback, "yes"))],
        ~children=[Component.text("\u{1F44D}")],
        (),
      )}
      {Component.element(
        "button",
        ~attrs=[
          Component.computedAttr("class", () =>
            "feedback-btn" ++ (Signal.get(feedback) == "no" ? " selected" : "")
          ),
          Component.attr("title", "No"),
        ],
        ~events=[("click", _ => Signal.set(feedback, "no"))],
        ~children=[Component.text("\u{1F44E}")],
        (),
      )}
    </div>
  }
}

// ---- Main docs page component ----
type props = {
  currentPath: string,
  content: Component.node,
}

let make = (props: props) => {
  let {currentPath, content} = props

  <Layout
    children={
      <div class="docs-layout">
        <Sidebar currentPath />
        <div class="docs-main">
          <DocsBreadcrumb currentPath />
          <div class="docs-content"> {content} </div>
          <PrevNextNav currentPath />
          <FeedbackWidget />
        </div>
        <TableOfContents currentPath />
      </div>
    }
  />
}
