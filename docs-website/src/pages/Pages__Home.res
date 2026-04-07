open Xote

// ---- Feature data ----
type feature = {
  title: string,
  description: string,
}

let features = [
  {
    title: "Simple API",
    description: "test, suite, and assertions. No magic, no ceremony.",
  },
  {
    title: "Sync & async",
    description: "First-class support for both, with configurable timeouts.",
  },
  {
    title: "DOM testing",
    description: "Built-in jsdom helpers inspired by Testing Library.",
  },
  {
    title: "Snapshots",
    description: "Capture and compare values across runs.",
  },
  {
    title: "Type-safe",
    description: "Every assertion is type-checked at compile time.",
  },
  {
    title: "Zero config",
    description: "No config files, no setup scripts \u2014 just import and go.",
  },
]

// ---- Feature row ----
module FeatureRow = {
  type props = {feature: feature}

  let make = (props: props) => {
    let {feature: f} = props
    <div class="feature-row">
      <h3> {Component.text(f.title)} </h3>
      <p> {Component.text(f.description)} </p>
    </div>
  }
}

// ---- Hero ----
module Hero = {
  type props = {}

  let make = (_props: props) => {
    <section class="hero">
      <div class="hero-inner">
        <h1>
          <span class="hero-name"> {Component.text("zekr")} </span>
          <span class="hero-tag">
            {Component.text("\u2014 a test framework for ReScript")}
          </span>
        </h1>
        <p class="hero-subtitle">
          {Component.text(
            "Sync and async tests, DOM testing, and snapshots. No config required.",
          )}
        </p>
        <div class="hero-buttons">
          {Router.link(
            ~to="/getting-started",
            ~attrs=[Component.attr("class", "btn btn-primary")],
            ~children=[Component.text("Get started")],
            (),
          )}
          <a href="https://github.com/brnrdog/zekr" target="_blank" class="btn btn-ghost">
            {Component.text("View source")}
          </a>
        </div>
      </div>
    </section>
  }
}

// ---- Features Section ----
module Features = {
  type props = {}

  let make = (_props: props) => {
    <section class="features-section">
      <div class="features-inner">
        <div class="features-list">
          {Component.fragment(features->Array.map(f => <FeatureRow feature={f} />))}
        </div>
      </div>
    </section>
  }
}

// ---- Install snippet ----
module Install = {
  type props = {}

  let make = (_props: props) => {
    <section class="install-section">
      <div class="install-inner">
        <pre class="install-snippet">
          <code>
            <span class="install-prompt"> {Component.text("$ ")} </span>
            {Component.text("npm install --save-dev zekr")}
          </code>
        </pre>
      </div>
    </section>
  }
}

// ---- Main page component ----
@jsx.component
let make = () => {
  <Layout children={Component.fragment([<Hero />, <Install />, <Features />])} />
}
