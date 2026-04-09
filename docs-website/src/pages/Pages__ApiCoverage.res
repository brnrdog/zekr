open Xote
open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    <Typography text={static("Test Coverage")} variant={H1} />
    <Typography
      text={static("Generate test coverage reports on your ReScript source files. Zekr uses c8 (V8 native coverage) combined with a custom sourcemap generator to map coverage data from compiled JavaScript back to .res files.")}
      variant={Lead}
    />
    <Separator />
    // How It Works
    <div class="heading-anchor" id="how-it-works">
      <Typography text={static("How It Works")} variant={H2} />
      <a class="anchor-link" href="#how-it-works"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("ReScript compiles .res files to JavaScript with function names and structure preserved. Zekr's sourcemap generator creates .js.map files that map the compiled output back to the original ReScript source. c8 then uses V8's built-in code coverage and these sourcemaps to produce coverage reports on .res files.")} />
    <Typography text={static("The pipeline works in three steps:")} />
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> <strong> {"1. Build"->Node.text} </strong> {" — ReScript compiles .res files to .js (in-source)"->Node.text} </li>
      <li> <strong> {"2. Generate sourcemaps"->Node.text} </strong> {" — The sourcemap generator creates .js.map files by matching declarations between .res and .js files"->Node.text} </li>
      <li> <strong> {"3. Collect coverage"->Node.text} </strong> {" — c8 runs your tests with V8 coverage enabled and remaps the results through the sourcemaps"->Node.text} </li>
    </ul>
    <Separator />
    // Setup
    <div class="heading-anchor" id="setup">
      <Typography text={static("Setup")} variant={H2} />
      <a class="anchor-link" href="#setup"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="install-dependencies">
      <Typography text={static("Install Dependencies")} variant={H3} />
      <a class="anchor-link" href="#install-dependencies"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Install c8 and source-map as dev dependencies:")} />
    <CodeBlock
      language="bash"
      code={`npm install --save-dev c8 source-map`}
    />
    <div class="heading-anchor" id="add-scripts">
      <Typography text={static("Add Coverage Scripts")} variant={H3} />
      <a class="anchor-link" href="#add-scripts"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Add the following scripts to your package.json. The precoverage script builds ReScript and generates sourcemaps, while the coverage script runs your tests under c8.")} />
    <CodeBlock
      language="json"
      code={`{
  "scripts": {
    "precoverage": "rescript && node node_modules/zekr/scripts/generate-sourcemaps.mjs src",
    "coverage": "c8 node tests/MyTests.js"
  }
}`}
    />
    <Typography text={static("If you have multiple test files that call process.exit(), run them separately and merge the results:")} />
    <CodeBlock
      language="json"
      code={`{
  "scripts": {
    "precoverage": "rescript && node node_modules/zekr/scripts/generate-sourcemaps.mjs src",
    "coverage": "rm -rf .c8_output && c8 --temp-directory .c8_output -r none node tests/SyncTests.js ; c8 --temp-directory .c8_output -r none node tests/AsyncTests.js ; c8 report --temp-directory .c8_output"
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
    "include": ["src/**/*.js"],
    "reporter": ["text", "html"],
    "report-dir": "coverage",
    "all": true
  }
}`}
    />
    <Typography text={static("Common configuration options:")} />
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> <strong> {"include"->Node.text} </strong> {" — Which files to include in coverage (glob patterns)"->Node.text} </li>
      <li> <strong> {"exclude"->Node.text} </strong> {" — Files to exclude from coverage"->Node.text} </li>
      <li> <strong> {"reporter"->Node.text} </strong> {" — Output formats: text (terminal table), html (browsable report), lcov, json, etc."->Node.text} </li>
      <li> <strong> {"report-dir"->Node.text} </strong> {" — Directory for HTML/lcov output"->Node.text} </li>
      <li> <strong> {"all"->Node.text} </strong> {" — Include files with 0% coverage (files not loaded by any test)"->Node.text} </li>
    </ul>
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
      code={`-----------------------|---------|----------|---------|---------|
File                   | % Stmts | % Branch | % Funcs | % Lines |
-----------------------|---------|----------|---------|---------|
All files              |   46.57 |    57.79 |   57.81 |   46.57 |
 Zekr.res              |   52.63 |    66.66 |      25 |   52.63 |
 Zekr__Assert.res      |   25.58 |    44.44 |   16.66 |   25.58 |
 Zekr__Colors.res      |   93.33 |      100 |      80 |   93.33 |
 Zekr__Dom.res         |   94.59 |      100 |   66.66 |   94.59 |
-----------------------|---------|----------|---------|---------|`}
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
    // Sourcemap Generator
    <div class="heading-anchor" id="sourcemap-generator">
      <Typography text={static("Sourcemap Generator")} variant={H2} />
      <a class="anchor-link" href="#sourcemap-generator"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("ReScript does not natively support sourcemap generation. Zekr includes a custom sourcemap generator (scripts/generate-sourcemaps.mjs) that works by:")} />
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> {"Parsing .res and .js files to extract top-level declarations (functions, let bindings, modules)"->Node.text} </li>
      <li> {"Matching declarations by name — ReScript preserves all identifiers in compiled output"->Node.text} </li>
      <li> {"Creating proportional line mappings within each declaration block"->Node.text} </li>
      <li> {"Embedding the original .res source in the sourcemap for display in coverage tools"->Node.text} </li>
    </ul>
    <Typography text={static("You can run the generator manually to generate sourcemaps for specific directories:")} />
    <CodeBlock
      language="bash"
      code={`# Generate sourcemaps for src/ (default)
node node_modules/zekr/scripts/generate-sourcemaps.mjs

# Generate sourcemaps for multiple directories
node node_modules/zekr/scripts/generate-sourcemaps.mjs src lib`}
    />
    <Separator />
    // Limitations
    <div class="heading-anchor" id="limitations">
      <Typography text={static("Limitations")} variant={H2} />
      <a class="anchor-link" href="#limitations"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Because sourcemaps are generated heuristically rather than by the compiler, there are some limitations to be aware of:")} />
    <ul style="line-height: 1.8; color: var(--basefn-text-secondary);">
      <li> <strong> {"Line-level granularity"->Node.text} </strong> {" — Coverage is mapped at the line level, not at the expression level. Column-level precision is not available."->Node.text} </li>
      <li> <strong> {"Proportional mapping"->Node.text} </strong> {" — Within a function body, lines are mapped proportionally. If the compiler significantly rearranges code within a function, the line mapping may be approximate."->Node.text} </li>
      <li> <strong> {"Type-only files"->Node.text} </strong> {" — Files that only contain type definitions (no runtime code) produce minimal JavaScript and should be excluded from coverage reports."->Node.text} </li>
    </ul>
    <Typography text={static("Despite these limitations, the coverage data is accurate at the function and branch level, which is typically sufficient for identifying untested code paths.")} />
    <EditOnGitHub pageName="Pages__ApiCoverage" />
  </div>
}
