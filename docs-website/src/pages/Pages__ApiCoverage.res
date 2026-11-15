open Xote
open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    <Typography text={static("Test Coverage")} variant={H1} />
    <Typography
      text={static("Generate test coverage reports on your ReScript source files. Zekr uses c8 (V8 native coverage) together with the source maps emitted by the ReScript 13 compiler to map coverage data from compiled JavaScript back to .res files.")}
      variant={Lead}
    />
    <Separator />
    // How It Works
    <div class="heading-anchor" id="how-it-works">
      <Typography text={static("How It Works")} variant={H2} />
      <a class="anchor-link" href="#how-it-works"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Starting with ReScript 13, the compiler can emit Source Map v3 files next to the JavaScript it generates. c8 collects V8's built-in code coverage while your tests run and remaps it through those source maps, so reports point at .res files and lines.")} />
    <Typography text={static("The pipeline works in two steps:")} />
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> <strong> {"1. Build"->Node.text} </strong> {" — ReScript compiles .res files to .js and writes a .js.map next to each one"->Node.text} </li>
      <li> <strong> {"2. Collect coverage"->Node.text} </strong> {" — c8 runs your tests with V8 coverage enabled and remaps the results through the source maps"->Node.text} </li>
    </ul>
    <Separator />
    // Setup
    <div class="heading-anchor" id="setup">
      <Typography text={static("Setup")} variant={H2} />
      <a class="anchor-link" href="#setup"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="enable-source-maps">
      <Typography text={static("Enable Source Maps")} variant={H3} />
      <a class="anchor-link" href="#enable-source-maps"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Source maps require ReScript 13 or newer. Enable them in your rescript.json:")} />
    <CodeBlock
      language="json"
      code={`{
  "sourceMap": {
    "enabled": "always",
    "mode": "linked"
  }
}`}
    />
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> <strong> {"enabled"->Node.text} </strong> {" — \"always\" emits source maps for both build and watch; \"dev\" only during watch mode. Coverage runs a regular build, so use \"always\"."->Node.text} </li>
      <li> <strong> {"mode"->Node.text} </strong> {" — \"linked\" writes a .js.map file and a sourceMappingURL comment; \"inline\" embeds the map as a data URI; \"hidden\" writes the file without the comment. c8 needs \"linked\" or \"inline\"."->Node.text} </li>
      <li> <strong> {"sourcesContent"->Node.text} </strong> {" — Optional. Embeds the original .res text in the map (default: false). Not needed when the .res files sit next to the output."->Node.text} </li>
    </ul>
    <div class="heading-anchor" id="install-dependencies">
      <Typography text={static("Install Dependencies")} variant={H3} />
      <a class="anchor-link" href="#install-dependencies"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Install c8 and monocart-coverage-reports as dev dependencies:")} />
    <CodeBlock
      language="bash"
      code={`npm install --save-dev c8 monocart-coverage-reports`}
    />
    <div class="heading-anchor" id="add-scripts">
      <Typography text={static("Add Coverage Scripts")} variant={H3} />
      <a class="anchor-link" href="#add-scripts"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Add the following scripts to your package.json. The precoverage script builds ReScript (emitting source maps), while the coverage script runs your tests under c8.")} />
    <CodeBlock
      language="json"
      code={`{
  "scripts": {
    "precoverage": "rescript",
    "coverage": "c8 zekr"
  }
}`}
    />
    <Separator />
    // Configuration
    <div class="heading-anchor" id="configuration">
      <Typography text={static("Configuration")} variant={H2} />
      <a class="anchor-link" href="#configuration"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Configure c8 in your package.json to set default options:")} />
    <CodeBlock
      language="json"
      code={`{
  "c8": {
    "experimental-monocart": true,
    "include": ["src/**/*.js"],
    "reporter": ["text", "html"],
    "report-dir": "coverage"
  }
}`}
    />
    <Typography text={static("Common configuration options:")} />
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> <strong> {"experimental-monocart"->Node.text} </strong> {" — Use the monocart remapper instead of v8-to-istanbul (see below). Required for accurate results."->Node.text} </li>
      <li> <strong> {"include"->Node.text} </strong> {" — Which compiled files to include in coverage (glob patterns)"->Node.text} </li>
      <li> <strong> {"exclude"->Node.text} </strong> {" — Files to exclude from coverage"->Node.text} </li>
      <li> <strong> {"reporter"->Node.text} </strong> {" — Output formats: text (terminal table), html (browsable report), lcov, json, etc."->Node.text} </li>
      <li> <strong> {"report-dir"->Node.text} </strong> {" — Directory for HTML/lcov output"->Node.text} </li>
    </ul>
    <div class="heading-anchor" id="why-monocart">
      <Typography text={static("Why monocart?")} variant={H3} />
      <a class="anchor-link" href="#why-monocart"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("The ReScript compiler only emits mappings for positions that come from your source, so generated-only lines such as closing braces have no mapping. c8's default remapper (v8-to-istanbul) silently drops uncovered ranges that end on such a line, which reports untested functions as covered. The monocart remapper handles these source maps correctly.")} />
    <Typography text={static("Avoid c8's all option with monocart: it compares the compiled .js paths against the remapped .res results and lists every .js file a second time at 0%.")} />
    <Typography text={static("Add coverage artifacts to your .gitignore:")} />
    <CodeBlock
      language="bash"
      code={`# .gitignore
*.js.map
/coverage/
/.c8_output/`}
    />
    <Separator />
    // Running Coverage
    <div class="heading-anchor" id="running">
      <Typography text={static("Running Coverage")} variant={H2} />
      <a class="anchor-link" href="#running"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Run the coverage command:")} />
    <CodeBlock
      language="bash"
      code={`npm run coverage`}
    />
    <Typography text={static("This outputs a text table in your terminal with per-file coverage:")} />
    <CodeBlock
      language="bash"
      code={`-----------------|---------|----------|---------|---------|---------------------
File             | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
-----------------|---------|----------|---------|---------|---------------------
All files        |   62.44 |    45.42 |   73.89 |   63.36 |
 Assert.res      |    87.5 |    72.72 |   89.47 |    87.5 | 89-118
 Colors.res      |     100 |      100 |     100 |     100 |
 Snapshot.res    |   53.84 |    33.33 |     100 |   54.16 | 47,55-90
-----------------|---------|----------|---------|---------|---------------------`}
    />
    <Typography text={static("The uncovered line numbers in the report point to lines in the original .res source files, not the compiled JavaScript.")} />
    <Separator />
    // HTML Report
    <div class="heading-anchor" id="html-report">
      <Typography text={static("HTML Report")} variant={H2} />
      <a class="anchor-link" href="#html-report"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("When the html reporter is enabled, a browsable coverage report is generated in the report-dir directory (default: coverage/). Open coverage/index.html in your browser to see:")} />
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> {"Per-file coverage summary with sortable columns"->Node.text} </li>
      <li> {"Line-by-line coverage highlighting on the original ReScript source code"->Node.text} </li>
      <li> {"Branch coverage markers showing which code paths were taken"->Node.text} </li>
    </ul>
    <Separator />
    // CI Integration
    <div class="heading-anchor" id="ci">
      <Typography text={static("CI Integration")} variant={H2} />
      <a class="anchor-link" href="#ci"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Replace your test command with the coverage command in your CI workflow to get coverage reports on every build:")} />
    <CodeBlock
      language="yaml"
      code={`# .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 'lts/*'
      - run: npm ci
      - run: npm run coverage`}
    />
    <Typography text={static("To upload coverage to a service like Codecov, add the lcov reporter and an upload step:")} />
    <CodeBlock
      language="json"
      code={`{
  "c8": {
    "experimental-monocart": true,
    "reporter": ["text", "lcov"],
    "report-dir": "coverage"
  }
}`}
    />
    <CodeBlock
      language="yaml"
      code={`      - run: npm run coverage
      - uses: codecov/codecov-action@v4
        with:
          files: coverage/lcov.info`}
    />
    <Separator />
    // Limitations
    <div class="heading-anchor" id="limitations">
      <Typography text={static("Limitations")} variant={H2} />
      <a class="anchor-link" href="#limitations"> {"#"->Node.text} </a>
    </div>
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> <strong> {"ReScript 13+"->Node.text} </strong> {" — Earlier compilers do not emit source maps; coverage on .res files is not available there."->Node.text} </li>
      <li> <strong> {"Type-only files"->Node.text} </strong> {" — Files that only contain type definitions (no runtime code) produce minimal JavaScript and should be excluded from coverage reports."->Node.text} </li>
      <li> <strong> {"Unloaded modules"->Node.text} </strong> {" — Without c8's all option, modules that no test imports do not appear in the report."->Node.text} </li>
    </ul>
    <EditOnGitHub pageName="Pages__ApiCoverage" />
  </div>
}
