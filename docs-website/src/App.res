open Xote

@jsx.component
let make = () => {
  Router.routes([
    {pattern: "/", render: _ => <Pages.Home />},
    {
      pattern: "/getting-started",
      render: _ =>
        <DocsPage
          currentPath="/getting-started"
          content={<Pages.GettingStarted />}
        />,
    },
    {
      pattern: "/api/tests",
      render: _ =>
        <DocsPage
          currentPath="/api/tests"
          content={<Pages.ApiTests />}
        />,
    },
    {
      pattern: "/api/assertions",
      render: _ =>
        <DocsPage
          currentPath="/api/assertions"
          content={<Pages.ApiAssertions />}
        />,
    },
    {
      pattern: "/api/dom",
      render: _ =>
        <DocsPage
          currentPath="/api/dom"
          content={<Pages.ApiDomTesting />}
        />,
    },
    {
      pattern: "/api/dom/queries",
      render: _ =>
        <DocsPage
          currentPath="/api/dom/queries"
          content={<Pages.ApiDomQueries />}
        />,
    },
    {
      pattern: "/api/dom/events",
      render: _ =>
        <DocsPage
          currentPath="/api/dom/events"
          content={<Pages.ApiDomEvents />}
        />,
    },
    {
      pattern: "/api/dom/assertions",
      render: _ =>
        <DocsPage
          currentPath="/api/dom/assertions"
          content={<Pages.ApiDomAssertions />}
        />,
    },
    {
      pattern: "/api/snapshots",
      render: _ =>
        <DocsPage
          currentPath="/api/snapshots"
          content={<Pages.ApiSnapshots />}
        />,
    },
    {
      pattern: "/api/runner",
      render: _ =>
        <DocsPage
          currentPath="/api/runner"
          content={<Pages.ApiRunner />}
        />,
    },
    {
      pattern: "/api/coverage",
      render: _ =>
        <DocsPage
          currentPath="/api/coverage"
          content={<Pages.ApiCoverage />}
        />,
    },
    {
      pattern: "/examples",
      render: _ =>
        <DocsPage
          currentPath="/examples"
          content={<Pages.Examples />}
        />,
    },
    {
      pattern: "/release-notes",
      render: _ =>
        <DocsPage
          currentPath="/release-notes"
          content={<Pages.ReleaseNotes />}
        />,
    },
  ])
}
