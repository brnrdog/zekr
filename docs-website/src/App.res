open Xote
open Xote.ReactiveProp
open Basefn

// Fetch latest version from npm registry
@val external fetch: string => promise<'a> = "fetch"
@send external json: 'a => promise<'b> = "json"

let npmVersion = Signal.make("...")

let _ = fetch("https://registry.npmjs.org/zekr/latest")
->Promise.then(response => response->json)
->Promise.then((data: {"version": string}) => {
  Signal.set(npmVersion, data["version"])
  Promise.resolve()
})
->Promise.catch(_ => {
  Signal.set(npmVersion, "1.7.0")
  Promise.resolve()
})

// Helper to check if a URL matches the current path
let isActive = (url: string, pathname: string) => {
  url == pathname
}

@jsx.component
let make = () => {
  let location = Router.location()
  let isHomepage = Computed.make(() => Signal.get(location).pathname == "/")
  let currentPath = Computed.make(() => Signal.get(location).pathname)

  // Create reactive sections that update based on current path
  let makeSections = (pathname: string): array<sidebarNavSection> => [
    {
      title: Some("Getting Started"),
      items: [
        {label: "Installation", icon: None, active: isActive("/getting-started", pathname), url: "/getting-started"},
      ],
    },
    {
      title: Some("API Reference"),
      items: [
        {label: "Tests & Suites", icon: None, active: isActive("/api/tests", pathname), url: "/api/tests"},
        {label: "Assertions", icon: None, active: isActive("/api/assertions", pathname), url: "/api/assertions"},
        {label: "DOM Testing", icon: None, active: isActive("/api/dom", pathname), url: "/api/dom"},
        {label: "DOM Queries", icon: None, active: isActive("/api/dom/queries", pathname), url: "/api/dom/queries"},
        {label: "DOM Events", icon: None, active: isActive("/api/dom/events", pathname), url: "/api/dom/events"},
        {label: "DOM Assertions", icon: None, active: isActive("/api/dom/assertions", pathname), url: "/api/dom/assertions"},
        {label: "Snapshots", icon: None, active: isActive("/api/snapshots", pathname), url: "/api/snapshots"},
        {label: "Test Runner", icon: None, active: isActive("/api/runner", pathname), url: "/api/runner"},
      ],
    },
    {
      title: Some("Resources"),
      items: [
        {label: "Examples", icon: None, active: isActive("/examples", pathname), url: "/examples"},
        {label: "Release Notes", icon: None, active: isActive("/release-notes", pathname), url: "/release-notes"},
      ],
    },
  ]

  let sectionsSignal = Computed.make(() => makeSections(Signal.get(currentPath)))

  let logo =
    <Router.Link to="/" style="text-decoration: none; color: inherit;">
      <Typography text={static("zekr")} variant={H4} />
    </Router.Link>

  let topbarLeft =
    <div style="display: flex; align-items: center; gap: 1rem;">
      <Router.Link to="/" style="text-decoration: none; color: inherit; display: flex; align-items: center;">
        <Typography text={static("zekr")} variant={H5} />
      </Router.Link>
      <div class="topbar-nav-links">
        <Router.Link to="/getting-started"> {Component.text("Getting Started")} </Router.Link>
        <Router.Link to="/api/tests"> {Component.text("API Reference")} </Router.Link>
        <Router.Link to="/examples"> {Component.text("Examples")} </Router.Link>
      </div>
    </div>

  let topbarRight =
    <div style="display: flex; align-items: center; gap: 0.75rem;">
      <div style="width: 200px;">
        <Search />
      </div>
      <Badge label={Computed.make(() => "v" ++ Signal.get(npmVersion))} variant={Secondary} size={Sm} />
      <a
        href="https://github.com/brnrdog/zekr"
        target="_blank"
        style="color: inherit; display: flex; align-items: center;">
        <Icon name={GitHub} size={Md} />
      </a>
      <ThemeToggle />
    </div>

  let topbar = <Topbar leftContent={topbarLeft} rightContent={topbarRight} />

  let routes =
    Router.routes([
      {pattern: "/", render: _ => <Pages.Home />},
      {pattern: "/getting-started", render: _ => <Pages.GettingStarted />},
      {pattern: "/api/tests", render: _ => <Pages.ApiTests />},
      {pattern: "/api/assertions", render: _ => <Pages.ApiAssertions />},
      {pattern: "/api/dom", render: _ => <Pages.ApiDomTesting />},
      {pattern: "/api/dom/queries", render: _ => <Pages.ApiDomQueries />},
      {pattern: "/api/dom/events", render: _ => <Pages.ApiDomEvents />},
      {pattern: "/api/dom/assertions", render: _ => <Pages.ApiDomAssertions />},
      {pattern: "/api/snapshots", render: _ => <Pages.ApiSnapshots />},
      {pattern: "/api/runner", render: _ => <Pages.ApiRunner />},
      {pattern: "/examples", render: _ => <Pages.Examples />},
      {pattern: "/release-notes", render: _ => <Pages.ReleaseNotes />},
    ])

  // Render different layouts based on whether we're on the homepage
  Component.signalFragment(
    Computed.make(() => {
      if Signal.get(isHomepage) {
        [
          <div style="min-height: 100vh; display: flex; flex-direction: column;">
            {topbar}
            <main style="flex: 1;">
              {routes}
            </main>
          </div>,
        ]
      } else {
        let sections = Signal.get(sectionsSignal)
        let sidebar = <Sidebar logo sections />
        [
          <AppLayout sidebar topbar>
            <div class="doc-content">
              <Breadcrumbs />
              {routes}
              <PageNavigation />
            </div>
            <ScrollToTop />
          </AppLayout>,
        ]
      }
    }),
  )
}
