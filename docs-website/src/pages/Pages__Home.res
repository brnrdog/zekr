open Xote
open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    // Hero Section
    <div class="hero-section">
      <Typography text={static("zekr")} variant={H1} class="hero-title" />
      <Typography
        text={static(
          "A simple, lightweight test framework for ReScript. Sync and async tests, DOM testing, snapshots, and more — with zero configuration.",
        )}
        variant={Lead}
        class="hero-subtitle"
      />
      <div class="hero-buttons">
        <Button variant={Primary} onClick={_ => Router.push("/getting-started", ())}>
          {Component.text("Get Started")}
        </Button>
        <Button variant={Secondary} onClick={_ => Router.push("/api/tests", ())}>
          {Component.text("API Reference")}
        </Button>
      </div>
    </div>
    // Why Section — split layout
    <div class="why-section">
      <div class="why-left">
        <Typography text={static("Why zekr?")} variant={H2} />
        <Typography
          text={static(
            "Built from the ground up for ReScript, zekr gives you a simple, expressive testing experience with no compromise.",
          )}
          variant={Muted}
        />
      </div>
      <div class="why-right">
        <div class="why-benefit">
          <Typography text={static("Simple API")} variant={H4} />
          <Typography
            text={static(
              "Just test, suite, and assertions. No magic, no ceremony — write tests that read like documentation.",
            )}
            variant={Muted}
          />
        </div>
        <div class="why-benefit">
          <Typography text={static("Sync & Async")} variant={H4} />
          <Typography
            text={static(
              "First-class support for both synchronous and asynchronous tests with configurable timeouts.",
            )}
            variant={Muted}
          />
        </div>
        <div class="why-benefit">
          <Typography text={static("DOM Testing")} variant={H4} />
          <Typography
            text={static(
              "Built-in DOM testing with jsdom. Query elements, simulate events, and assert on the DOM — inspired by Testing Library.",
            )}
            variant={Muted}
          />
        </div>
        <div class="why-benefit">
          <Typography text={static("Snapshot Testing")} variant={H4} />
          <Typography
            text={static(
              "Capture and compare snapshots of your data. Great for catching unexpected changes in complex outputs.",
            )}
            variant={Muted}
          />
        </div>
      </div>
    </div>
    // Code Showcase: Basic Test
    <div class="code-showcase">
      <Typography text={static("Write tests with a simple API")} variant={H3} />
      <Typography
        text={static(
          "Create test cases and suites with a clean, functional API. Each assertion returns a result — no implicit global state.",
        )}
        variant={Muted}
        style="margin-bottom: 1rem;"
      />
      <CodeBlock
        language="rescript"
        code={`open Zekr

let mathSuite = suite("Math", [
  test("addition", () => assertEqual(1 + 1, 2)),
  test("greater than", () => assertGreaterThan(10, 5)),
])

runSuites([mathSuite])`}
      />
    </div>
    // Code Showcase: Async Test
    <div class="code-showcase">
      <Typography text={static("Test async code with ease")} variant={H3} />
      <Typography
        text={static(
          "Async tests are first-class citizens. Set timeouts per test and use promises naturally.",
        )}
        variant={Muted}
        style="margin-bottom: 1rem;"
      />
      <CodeBlock
        language="rescript"
        code={`open Zekr

let apiSuite = asyncSuite("API", [
  asyncTest("fetches data", async () => {
    let data = await fetchData()
    assertEqual(data.status, "ok")
  }, ~timeout=Some(5000)),
])

runAsyncSuites([apiSuite])`}
      />
    </div>
    // Code Showcase: DOM Testing
    <div class="code-showcase">
      <Typography text={static("Test the DOM like a user")} variant={H3} />
      <Typography
        text={static(
          "Render HTML, query elements by role or text, simulate clicks and typing, and assert on the result.",
        )}
        variant={Muted}
        style="margin-bottom: 1rem;"
      />
      <CodeBlock
        language="rescript"
        code={`open Zekr

let {container} = Dom.render("<button>Click me</button>")
let btn = Dom.Query.getByRole(container, "button")

Dom.Event.click(btn)
Dom.Assert.toHaveTextContent(btn, "Click me")`}
      />
    </div>
    // Bottom CTA
    <div class="bottom-cta">
      <Typography text={static("Ready to get started?")} variant={H2} />
      <Typography
        text={static(
          "Install zekr and start writing tests for your ReScript project in minutes.",
        )}
        variant={Muted}
        style="margin-bottom: 2rem;"
      />
      <div style="display: flex; gap: 1rem; justify-content: center;">
        <Button variant={Primary} onClick={_ => Router.push("/getting-started", ())}>
          {Component.text("Read the Docs")}
        </Button>
        <Button variant={Ghost} onClick={_ => Router.push("/examples", ())}>
          {Component.text("See Examples")}
        </Button>
      </div>
    </div>
  </div>
}
