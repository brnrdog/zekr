open Xote

// ---- External bindings ----
@val @scope("document.documentElement")
external setHtmlAttribute: (string, string) => unit = "setAttribute"
@val @scope("localStorage") external getItem: string => Nullable.t<string> = "getItem"
@val @scope("localStorage") external setItem: (string, string) => unit = "setItem"
@val @scope("window") external addEventListener: (string, 'a) => unit = "addEventListener"
@val @scope("window") external removeEventListener: (string, 'a) => unit = "removeEventListener"

// ---- Theme management ----
let initialTheme = {
  switch getItem("zekr-theme")->Nullable.toOption {
  | Some("light") => "light"
  | _ => "dark"
  }
}

let _ = setHtmlAttribute("data-theme", initialTheme)

let theme = Signal.make(initialTheme)

let toggleTheme = () => {
  Signal.update(theme, current =>
    switch current {
    | "dark" => "light"
    | _ => "dark"
    }
  )
}

let _ = Effect.run(() => {
  let t = Signal.get(theme)
  setHtmlAttribute("data-theme", t)
  setItem("zekr-theme", t)
  Basefn.Theme.applyTheme(t == "dark" ? Basefn.Theme.Dark : Basefn.Theme.Light)
  None
})

// ---- Search state ----
let searchOpen = Signal.make(false)

let openSearch = () => Signal.set(searchOpen, true)
let closeSearch = () => Signal.set(searchOpen, false)

// ---- Scroll state ----
let isScrolled = Signal.make(false)

// ---- Search items ----
type searchItem = {
  title: string,
  path: string,
  section: string,
}

let searchItems: array<searchItem> = [
  {title: "Installation", path: "/getting-started", section: "Getting Started"},
  {title: "Tests & Suites", path: "/api/tests", section: "API Reference"},
  {title: "Assertions", path: "/api/assertions", section: "API Reference"},
  {title: "DOM Testing", path: "/api/dom", section: "API Reference"},
  {title: "DOM Queries", path: "/api/dom/queries", section: "API Reference"},
  {title: "DOM Events", path: "/api/dom/events", section: "API Reference"},
  {title: "DOM Assertions", path: "/api/dom/assertions", section: "API Reference"},
  {title: "Snapshots", path: "/api/snapshots", section: "API Reference"},
  {title: "Test Runner", path: "/api/runner", section: "API Reference"},
  {title: "Test Coverage", path: "/api/coverage", section: "API Reference"},
  {title: "Examples", path: "/examples", section: "Resources"},
  {title: "Release Notes", path: "/release-notes", section: "Resources"},
]

// ---- Search Modal ----
module SearchModal = {
  type props = {}

  let make = (_props: props) => {
    let query = Signal.make("")
    let selectedIndex = Signal.make(0)

    let filteredItems = Computed.make(() => {
      let q = Signal.get(query)->String.toLowerCase
      if q == "" {
        searchItems
      } else {
        searchItems->Array.filter(item =>
          item.title->String.toLowerCase->String.includes(q) ||
            item.section->String.toLowerCase->String.includes(q)
        )
      }
    })

    let handleInput = (_evt: Dom.event) => {
      let value: string = %raw(`_evt.target.value`)
      Signal.set(query, value)
      Signal.set(selectedIndex, 0)
    }

    let navigateToResult = () => {
      let items = Signal.peek(filteredItems)
      let idx = Signal.peek(selectedIndex)
      switch items->Array.get(idx) {
      | Some(item) =>
        Router.push(item.path, ())
        closeSearch()
        Signal.set(query, "")
      | None => ()
      }
    }

    let handleKeyDown = (_evt: Dom.event) => {
      let key: string = %raw(`_evt.key`)
      switch key {
      | "ArrowDown" => {
          let _ = %raw(`_evt.preventDefault()`)
          let items = Signal.peek(filteredItems)
          Signal.update(selectedIndex, i => i < Array.length(items) - 1 ? i + 1 : i)
        }
      | "ArrowUp" => {
          let _ = %raw(`_evt.preventDefault()`)
          Signal.update(selectedIndex, i => i > 0 ? i - 1 : 0)
        }
      | "Enter" => navigateToResult()
      | "Escape" => {
          closeSearch()
          Signal.set(query, "")
        }
      | _ => ()
      }
    }

    Node.signalFragment(
      Computed.make(() => {
        if Signal.get(searchOpen) {
          [
            Node.element(
              "div",
              ~attrs=[Node.attr("class", "search-overlay")],
              ~events=[
                (
                  "click",
                  _evt => {
                    let className: string = %raw(`_evt.target.className || ""`)
                    if className->String.includes("search-overlay") {
                      closeSearch()
                      Signal.set(query, "")
                    }
                  },
                ),
              ],
              ~children=[
                <div class="search-modal">
                  <div class="search-input-wrapper">
                    {Basefn.Icon.make({name: Search, size: Sm})}
                    {Html.input(
                      ~attrs=[
                        Node.attr("class", "search-input"),
                        Node.attr("placeholder", "Search documentation..."),
                        Node.attr("autofocus", "true"),
                      ],
                      ~events=[("input", handleInput), ("keydown", handleKeyDown)],
                      (),
                    )}
                    <div class="search-trigger-key"> {Node.text("esc")} </div>
                  </div>
                  <div class="search-results">
                    {Node.signalFragment(
                      Computed.make(() => {
                        let items = Signal.get(filteredItems)
                        let idx = Signal.get(selectedIndex)
                        if Array.length(items) == 0 {
                          [
                            <div class="search-empty">
                              {Node.text("No results found.")}
                            </div>,
                          ]
                        } else {
                          let currentSection = ref("")
                          let globalIdx = ref(0)
                          items->Array.flatMap(item => {
                            let nodes = []
                            if currentSection.contents != item.section {
                              currentSection := item.section
                              nodes
                              ->Array.push(
                                <div class="search-group-label">
                                  {Node.text(item.section)}
                                </div>,
                              )
                              ->ignore
                            }
                            let myIdx = globalIdx.contents
                            let isActive = myIdx == idx
                            let cn = "search-result-item" ++ (isActive ? " active" : "")
                            nodes
                            ->Array.push(
                              Node.element(
                                "div",
                                ~attrs=[Node.attr("class", cn)],
                                ~events=[
                                  (
                                    "click",
                                    _ => {
                                      Router.push(item.path, ())
                                      closeSearch()
                                      Signal.set(query, "")
                                    },
                                  ),
                                ],
                                ~children=[
                                  <div class="search-result-title">
                                    {Node.text(item.title)}
                                  </div>,
                                ],
                                (),
                              ),
                            )
                            ->ignore
                            globalIdx := myIdx + 1
                            nodes
                          })
                        }
                      }),
                    )}
                  </div>
                  <div class="search-footer">
                    {Node.text("Use arrow keys to navigate, Enter to select, Esc to close")}
                  </div>
                </div>,
              ],
              (),
            ),
          ]
        } else {
          []
        }
      }),
    )
  }
}

// ---- Header ----
module Header = {
  type props = {}

  let make = (_props: props) => {
    // Scroll listener
    let _ = Effect.run(() => {
      let handleScroll = () => {
        let scrollY: float = %raw(`window.scrollY`)
        Signal.set(isScrolled, scrollY > 10.0)
      }
      addEventListener("scroll", handleScroll)
      Some(() => removeEventListener("scroll", handleScroll))
    })

    Node.element(
      "header",
      ~attrs=[
        Node.computedAttr("class", () =>
          Signal.get(isScrolled) ? "site-header scrolled" : "site-header"
        ),
      ],
      ~children=[
        <div class="header-inner">
          <div class="header-left">
            {Router.link(
              ~to="/",
              ~attrs=[Node.attr("class", "header-logo-link")],
              ~children=[
                <span class="logo-text"> {Node.text("zekr")} </span>,
              ],
              (),
            )}
            <nav class="header-nav">
              {Router.link(
                ~to="/getting-started",
                ~attrs=[Node.attr("class", "header-nav-link")],
                ~children=[Node.text("Getting Started")],
                (),
              )}
              {Router.link(
                ~to="/api/tests",
                ~attrs=[Node.attr("class", "header-nav-link")],
                ~children=[Node.text("API Reference")],
                (),
              )}
              {Router.link(
                ~to="/examples",
                ~attrs=[Node.attr("class", "header-nav-link")],
                ~children=[Node.text("Examples")],
                (),
              )}
            </nav>
          </div>
          <div class="header-right">
            {Node.element(
              "button",
              ~attrs=[Node.attr("class", "search-trigger")],
              ~events=[("click", _ => openSearch())],
              ~children=[
                Basefn.Icon.make({name: Search, size: Sm}),
                <span> {Node.text("Search docs...")} </span>,
                <div class="search-trigger-keys">
                  <span class="search-trigger-key"> {Node.text("\u2318")} </span>
                  <span class="search-trigger-key"> {Node.text("K")} </span>
                </div>,
              ],
              (),
            )}
            {Node.element(
              "a",
              ~attrs=[
                Node.attr("href", "https://github.com/brnrdog/zekr"),
                Node.attr("target", "_blank"),
                Node.attr("class", "gh-star-btn"),
                Node.attr("title", "Star on GitHub"),
              ],
              ~children=[
                Basefn.Icon.make({name: Star, size: Sm}),
                Node.element(
                  "span",
                  ~attrs=[Node.attr("class", "gh-star-label")],
                  ~children=[Node.text("Star")],
                  (),
                ),
              ],
              (),
            )}
            {Node.element(
              "a",
              ~attrs=[
                Node.attr("href", "https://github.com/brnrdog/zekr"),
                Node.attr("target", "_blank"),
                Node.attr("class", "header-icon-btn"),
                Node.attr("title", "GitHub"),
              ],
              ~children=[Basefn.Icon.make({name: GitHub, size: Sm})],
              (),
            )}
            {Node.element(
              "button",
              ~attrs=[
                Node.attr("class", "header-icon-btn"),
                Node.attr("title", "Toggle theme"),
              ],
              ~events=[("click", _ => toggleTheme())],
              ~children=[
                Node.signalFragment(
                  Computed.make(() =>
                    Signal.get(theme) == "dark"
                      ? [Basefn.Icon.make({name: Sun, size: Sm})]
                      : [Basefn.Icon.make({name: Moon, size: Sm})]
                  ),
                ),
              ],
              (),
            )}
            {Node.element(
              "button",
              ~attrs=[
                Node.attr("class", "header-icon-btn mobile-menu-btn"),
                Node.attr("title", "Menu"),
              ],
              ~events=[("click", _ => openSearch())],
              ~children=[Basefn.Icon.make({name: Menu, size: Sm})],
              (),
            )}
          </div>
        </div>,
      ],
      (),
    )
  }
}

// ---- Footer ----
module Footer = {
  type props = {}

  let make = (_props: props) => {
    let year = Date.now()->Date.fromTime->Date.getFullYear->Int.toString

    <footer class="site-footer">
      <div class="footer-inner">
        <div class="footer-grid">
          <div class="footer-brand">
            <div class="footer-brand-logo">
              <span> {Node.text("zekr")} </span>
            </div>
            <p>
              {Node.text(
                "A simple, lightweight test framework for ReScript with support for sync/async tests, DOM testing, snapshots, and more.",
              )}
            </p>
          </div>
          <div class="footer-col">
            <h4> {Node.text("Docs")} </h4>
            <ul>
              <li>
                {Router.link(~to="/getting-started", ~children=[Node.text("Getting Started")], ())}
              </li>
              <li>
                {Router.link(~to="/api/tests", ~children=[Node.text("API Reference")], ())}
              </li>
              <li>
                {Router.link(~to="/examples", ~children=[Node.text("Examples")], ())}
              </li>
            </ul>
          </div>
          <div class="footer-col">
            <h4> {Node.text("Community")} </h4>
            <ul>
              <li>
                <a href="https://github.com/brnrdog/zekr" target="_blank">
                  {Node.text("GitHub")}
                </a>
              </li>
              <li>
                <a href="https://www.npmjs.com/package/zekr" target="_blank">
                  {Node.text("npm")}
                </a>
              </li>
            </ul>
          </div>
          <div class="footer-col">
            <h4> {Node.text("More")} </h4>
            <ul>
              <li>
                <a href="https://rescript-lang.org/" target="_blank">
                  {Node.text("ReScript")}
                </a>
              </li>
              <li>
                {Router.link(~to="/release-notes", ~children=[Node.text("Release Notes")], ())}
              </li>
            </ul>
          </div>
        </div>
        <div class="footer-bottom">
          <div> {Node.text(`Copyright \u00A9 ${year} Bernardo Gurgel. MIT License.`)} </div>
          <div class="footer-bottom-right">
            {Node.text("Built with xote")}
          </div>
        </div>
      </div>
    </footer>
  }
}

// ---- Global Cmd+K shortcut ----
let _ = Effect.run(() => {
  let handler = (_evt: Dom.event) => {
    let ctrlOrMeta: bool = %raw(`_evt.ctrlKey || _evt.metaKey`)
    let key: string = %raw(`_evt.key`)
    if ctrlOrMeta && key == "k" {
      let _ = %raw(`_evt.preventDefault()`)
      if Signal.peek(searchOpen) {
        closeSearch()
      } else {
        openSearch()
      }
    }
  }
  addEventListener("keydown", handler)
  Some(() => removeEventListener("keydown", handler))
})

// ---- Main layout wrapper ----
type props = {children: Node.node}

let make = (props: props) => {
  <div>
    <Header />
    <main id="main-content"> {props.children} </main>
    <Footer />
    <SearchModal />
  </div>
}
