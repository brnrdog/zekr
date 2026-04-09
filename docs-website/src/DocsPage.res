open Xote

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
      {Node.fragment(
        docsNav->Array.map(category => {
          <div class="sidebar-section">
            <div class="sidebar-section-title"> {Node.text(category.label)} </div>
            {Node.fragment(
              category.items->Array.map(item => {
                let isActive = currentPath == item.path
                let className = "sidebar-link" ++ (isActive ? " active" : "")
                Router.link(
                  ~to=item.path,
                  ~attrs=[Node.attr("class", className)],
                  ~children=[Node.text(item.title)],
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
      {Router.link(~to="/getting-started", ~children=[Node.text("Docs")], ())}
      {if category != "" && category != "Getting Started" {
        Node.fragment([
          <span class="docs-breadcrumb-sep"> {Node.text("/")} </span>,
          <span> {Node.text(category)} </span>,
        ])
      } else {
        Node.fragment([])
      }}
      <span class="docs-breadcrumb-sep"> {Node.text("/")} </span>
      <span class="docs-breadcrumb-current"> {Node.text(title)} </span>
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
          ~attrs=[Node.attr("class", "docs-prev-next-link")],
          ~children=[
            <span class="docs-prev-next-label">
              {Node.text("\u2190 Previous")}
            </span>,
            <span class="docs-prev-next-title"> {Node.text(item.title)} </span>,
          ],
          (),
        )
      | None => <div />
      }}
      {switch next {
      | Some(item) =>
        Router.link(
          ~to=item.path,
          ~attrs=[Node.attr("class", "docs-prev-next-link next")],
          ~children=[
            <span class="docs-prev-next-label">
              {Node.text("Next \u2192")}
            </span>,
            <span class="docs-prev-next-title"> {Node.text(item.title)} </span>,
          ],
          (),
        )
      | None => <div />
      }}
    </div>
  }
}

// ---- Feedback Widget ----
module FeedbackWidget = {
  type props = {}

  let make = (_props: props) => {
    let feedback = Signal.make("")

    <div class="docs-feedback">
      {Node.text("Was this page helpful?")}
      {Node.element(
        "button",
        ~attrs=[
          Node.computedAttr("class", () =>
            "feedback-btn" ++ (Signal.get(feedback) == "yes" ? " selected" : "")
          ),
          Node.attr("title", "Yes"),
        ],
        ~events=[("click", _ => Signal.set(feedback, "yes"))],
        ~children=[Node.text("\u{1F44D}")],
        (),
      )}
      {Node.element(
        "button",
        ~attrs=[
          Node.computedAttr("class", () =>
            "feedback-btn" ++ (Signal.get(feedback) == "no" ? " selected" : "")
          ),
          Node.attr("title", "No"),
        ],
        ~events=[("click", _ => Signal.set(feedback, "no"))],
        ~children=[Node.text("\u{1F44E}")],
        (),
      )}
    </div>
  }
}

// ---- Main docs page component ----
type props = {
  currentPath: string,
  content: Node.node,
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
      </div>
    }
  />
}
