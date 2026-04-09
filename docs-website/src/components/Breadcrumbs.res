open Xote

type breadcrumb = {
  label: string,
  url: option<string>,
}

// Map paths to their breadcrumb hierarchy
let getBreadcrumbs = (pathname: string): array<breadcrumb> => {
  switch pathname {
  | "/getting-started" => [{label: "Getting Started", url: None}]
  | "/api/tests" => [{label: "API Reference", url: None}, {label: "Tests & Suites", url: None}]
  | "/api/assertions" => [{label: "API Reference", url: None}, {label: "Assertions", url: None}]
  | "/api/dom" => [{label: "API Reference", url: None}, {label: "DOM Testing", url: None}]
  | "/api/dom/queries" => [{label: "API Reference", url: None}, {label: "DOM", url: Some("/api/dom")}, {label: "Queries", url: None}]
  | "/api/dom/events" => [{label: "API Reference", url: None}, {label: "DOM", url: Some("/api/dom")}, {label: "Events", url: None}]
  | "/api/dom/assertions" => [{label: "API Reference", url: None}, {label: "DOM", url: Some("/api/dom")}, {label: "Assertions", url: None}]
  | "/api/snapshots" => [{label: "API Reference", url: None}, {label: "Snapshots", url: None}]
  | "/api/runner" => [{label: "API Reference", url: None}, {label: "Test Runner", url: None}]
  | "/examples" => [{label: "Examples", url: None}]
  | "/release-notes" => [{label: "Release Notes", url: None}]
  | _ => []
  }
}

@jsx.component
let make = () => {
  let location = Router.location()
  let breadcrumbs = Computed.make(() => getBreadcrumbs(Signal.get(location).pathname))

  Node.signalFragment(
    Computed.make(() => {
      let crumbs = Signal.get(breadcrumbs)
      if Array.length(crumbs) == 0 {
        []
      } else {
        [
          <nav style="margin-bottom: 1.5rem;">
            <div style="display: flex; align-items: center; gap: 0.5rem; font-size: 0.875rem; color: var(--basefn-text-tertiary);">
              {Node.fragment(
                crumbs->Array.mapWithIndex((crumb, idx) => {
                  let isLast = idx == Array.length(crumbs) - 1
                  let separator = if !isLast {
                    <span style="color: var(--basefn-text-muted);"> {"/"->Node.text} </span>
                  } else {
                    <span />
                  }

                  switch crumb.url {
                  | Some(url) =>
                    <span>
                      <Router.Link to={url} style="color: var(--basefn-text-tertiary); text-decoration: none;">
                        {crumb.label->Node.text}
                      </Router.Link>
                      {separator}
                    </span>
                  | None =>
                    <span style={isLast ? "color: var(--basefn-text-primary);" : ""}>
                      {crumb.label->Node.text}
                      {separator}
                    </span>
                  }
                }),
              )}
            </div>
          </nav>,
        ]
      }
    }),
  )
}
