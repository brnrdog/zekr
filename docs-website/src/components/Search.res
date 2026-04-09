open Xote
open Xote.ReactiveProp
open Basefn

// Search index - contains searchable content for each page
type searchResult = {
  title: string,
  description: string,
  url: string,
  category: string,
}

let searchIndex: array<searchResult> = [
  // Getting Started
  {
    title: "Installation",
    description: "Learn how to install zekr using npm, yarn, or pnpm",
    url: "/getting-started",
    category: "Getting Started",
  },
  // API - Tests
  {
    title: "test",
    description: "Create a synchronous test case",
    url: "/api/tests",
    category: "API",
  },
  {
    title: "Test.async",
    description: "Create an asynchronous test case with optional timeout",
    url: "/api/tests",
    category: "API",
  },
  {
    title: "suite",
    description: "Create a test suite with lifecycle hooks",
    url: "/api/tests",
    category: "API",
  },
  {
    title: "asyncSuite",
    description: "Create an async test suite with async lifecycle hooks",
    url: "/api/tests",
    category: "API",
  },
  // API - Assertions
  {
    title: "Assert.equal",
    description: "Assert that two values are equal",
    url: "/api/assertions",
    category: "API",
  },
  {
    title: "Assert.isTrue / Assert.isFalse",
    description: "Assert boolean values",
    url: "/api/assertions",
    category: "API",
  },
  {
    title: "Assert.contains",
    description: "Assert that a string contains a substring",
    url: "/api/assertions",
    category: "API",
  },
  {
    title: "Assert.combineResults",
    description: "Combine multiple assertion results into one",
    url: "/api/assertions",
    category: "API",
  },
  // API - DOM
  {
    title: "DomTesting.render",
    description: "Render HTML into a jsdom container for testing",
    url: "/api/dom",
    category: "API",
  },
  {
    title: "DomTesting.Query",
    description: "Query DOM elements by text, role, test ID, and more",
    url: "/api/dom/queries",
    category: "API",
  },
  {
    title: "DomTesting.Event",
    description: "Simulate user events like click, type, and focus",
    url: "/api/dom/events",
    category: "API",
  },
  {
    title: "DomTesting.Assert",
    description: "Assert DOM element state, visibility, and content",
    url: "/api/dom/assertions",
    category: "API",
  },
  // API - Snapshots
  {
    title: "Snapshot.matches",
    description: "Compare values against stored snapshots",
    url: "/api/snapshots",
    category: "API",
  },
  // API - Runner
  {
    title: "Runner.runSuites",
    description: "Run test suites and see results in the terminal",
    url: "/api/runner",
    category: "API",
  },
  {
    title: "Runner.watchMode",
    description: "Watch files for changes and re-run tests automatically",
    url: "/api/runner",
    category: "API",
  },
  // Examples
  {
    title: "Basic Test Example",
    description: "Simple test demonstrating assertions and suites",
    url: "/examples",
    category: "Examples",
  },
  {
    title: "DOM Testing Example",
    description: "Testing DOM elements with queries and events",
    url: "/examples",
    category: "Examples",
  },
  // Release Notes
  {
    title: "Release Notes",
    description: "View the changelog and release history",
    url: "/release-notes",
    category: "Resources",
  },
]

let search = (query: string): array<searchResult> => {
  if query->String.trim == "" {
    []
  } else {
    let lowerQuery = query->String.toLowerCase
    searchIndex->Array.filter(item => {
      item.title->String.toLowerCase->String.includes(lowerQuery) ||
      item.description->String.toLowerCase->String.includes(lowerQuery) ||
      item.category->String.toLowerCase->String.includes(lowerQuery)
    })
  }
}

// DOM helper
let getInputValue: Dom.event => string = %raw(`function(e) { return e.target.value }`)

@jsx.component
let make = () => {
  let query = Signal.make("")
  let isOpen = Signal.make(false)
  let results = Computed.make(() => search(Signal.get(query)))

  let handleInput = evt => {
    let value = getInputValue(evt)
    Signal.set(query, value)
    Signal.set(isOpen, value->String.trim != "")
  }

  let handleResultClick = (url: string) => {
    Signal.set(isOpen, false)
    Signal.set(query, "")
    Router.push(url, ())
  }

  <div style="position: relative;">
    <Input
      value={reactive(query)}
      onInput={handleInput}
      placeholder="Search docs..."
    />
    {Node.signalFragment(
      Computed.make(() => {
        if Signal.get(isOpen) {
          let items = Signal.get(results)
          [
            <div
              style="position: absolute; top: 100%; left: 0; right: 0; background: var(--basefn-color-background); border: 1px solid var(--basefn-color-border); border-radius: 8px; margin-top: 4px; max-height: 400px; overflow-y: auto; z-index: 1000; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);">
              {if items->Array.length == 0 {
                <div style="padding: 1rem; color: var(--basefn-color-muted);">
                  {Node.text("No results found")}
                </div>
              } else {
                <div>
                  {items
                  ->Array.map(item => {
                    <div
                      key={item.title ++ item.url}
                      onClick={_ => handleResultClick(item.url)}
                      style="padding: 0.75rem 1rem; cursor: pointer; border-bottom: 1px solid var(--basefn-color-border);"
                      class="search-result">
                      <div style="display: flex; justify-content: space-between; align-items: center;">
                        <Typography text={static(item.title)} variant={H5} />
                        <Badge label={Signal.make(item.category)} variant={Secondary} size={Sm} />
                      </div>
                      <Typography text={static(item.description)} variant={Small} />
                    </div>
                  })
                  ->Node.fragment}
                </div>
              }}
            </div>,
          ]
        } else {
          []
        }
      }),
    )}
  </div>
}
