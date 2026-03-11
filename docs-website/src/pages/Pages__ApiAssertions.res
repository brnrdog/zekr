open Xote
open Xote.ReactiveProp
open Basefn

@jsx.component
let make = () => {
  <div>
    <Typography text={static("Assertions")} variant={H1} />
    <Typography
      text={static("All assertion functions return a testResult — either Pass or Fail(message). An optional ~message parameter lets you provide custom failure messages.")}
      variant={Lead}
    />
    <Separator />
    // Equality
    <div class="heading-anchor" id="equality">
      <Typography text={static("Equality & Inequality")} variant={H2} />
      <a class="anchor-link" href="#equality"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="assert-equal">
      <Typography text={static("assertEqual(a, b, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-equal"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that two values are structurally equal.")} />
    <CodeBlock
      language="rescript"
      code={`assertEqual(1 + 1, 2)
assertEqual("hello", "hello")
assertEqual([1, 2], [1, 2])`}
    />
    <div class="heading-anchor" id="assert-not-equal">
      <Typography text={static("assertNotEqual(a, b, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-not-equal"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that two values are not equal.")} />
    <CodeBlock language="rescript" code={`assertNotEqual(1, 2)`} />
    <Separator />
    // Boolean
    <div class="heading-anchor" id="boolean">
      <Typography text={static("Boolean")} variant={H2} />
      <a class="anchor-link" href="#boolean"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="assert-true">
      <Typography text={static("assertTrue(value, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-true"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that a value is true.")} />
    <CodeBlock language="rescript" code={`assertTrue(Array.length([1, 2]) > 0)`} />
    <div class="heading-anchor" id="assert-false">
      <Typography text={static("assertFalse(value, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-false"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that a value is false.")} />
    <CodeBlock language="rescript" code={`assertFalse(String.length("") > 0)`} />
    <Separator />
    // Comparison
    <div class="heading-anchor" id="comparison">
      <Typography text={static("Comparison")} variant={H2} />
      <a class="anchor-link" href="#comparison"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="assert-greater-than">
      <Typography text={static("assertGreaterThan(a, b, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-greater-than"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that a > b.")} />
    <CodeBlock language="rescript" code={`assertGreaterThan(10, 5)`} />
    <div class="heading-anchor" id="assert-less-than">
      <Typography text={static("assertLessThan(a, b, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-less-than"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that a < b.")} />
    <CodeBlock language="rescript" code={`assertLessThan(3, 7)`} />
    <div class="heading-anchor" id="assert-gte">
      <Typography text={static("assertGreaterThanOrEqual(a, b, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-gte"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that a >= b.")} />
    <div class="heading-anchor" id="assert-lte">
      <Typography text={static("assertLessThanOrEqual(a, b, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-lte"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that a <= b.")} />
    <Separator />
    // String & Array
    <div class="heading-anchor" id="string-array">
      <Typography text={static("String & Array")} variant={H2} />
      <a class="anchor-link" href="#string-array"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="assert-contains">
      <Typography text={static("assertContains(string, substring, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-contains"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that a string contains a substring.")} />
    <CodeBlock language="rescript" code={`assertContains("hello world", "world")`} />
    <div class="heading-anchor" id="assert-array-contains">
      <Typography text={static("assertArrayContains(array, item, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-array-contains"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that an array contains a specific item.")} />
    <CodeBlock language="rescript" code={`assertArrayContains([1, 2, 3], 2)`} />
    <Separator />
    // Pattern Matching
    <div class="heading-anchor" id="pattern">
      <Typography text={static("Pattern Matching")} variant={H2} />
      <a class="anchor-link" href="#pattern"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="assert-match">
      <Typography text={static("assertMatch(string, regex, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-match"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that a string matches a regular expression.")} />
    <CodeBlock language="rescript" code={`assertMatch("hello123", %re("/\\d+/"))`} />
    <Separator />
    // Option & Result
    <div class="heading-anchor" id="option-result">
      <Typography text={static("Option & Result")} variant={H2} />
      <a class="anchor-link" href="#option-result"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="assert-some">
      <Typography text={static("assertSome(option, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-some"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that an option is Some.")} />
    <CodeBlock language="rescript" code={`assertSome(Array.get([1, 2], 0))`} />
    <div class="heading-anchor" id="assert-none">
      <Typography text={static("assertNone(option, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-none"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that an option is None.")} />
    <CodeBlock language="rescript" code={`assertNone(Map.get(emptyMap, "key"))`} />
    <div class="heading-anchor" id="assert-ok">
      <Typography text={static("assertOk(result, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-ok"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that a result is Ok.")} />
    <CodeBlock language="rescript" code={`assertOk(Ok(42))`} />
    <div class="heading-anchor" id="assert-error">
      <Typography text={static("assertError(result, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-error"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that a result is Error.")} />
    <CodeBlock language="rescript" code={`assertError(Error("not found"))`} />
    <Separator />
    // Exception
    <div class="heading-anchor" id="exception">
      <Typography text={static("Exceptions")} variant={H2} />
      <a class="anchor-link" href="#exception"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="assert-throws">
      <Typography text={static("assertThrows(fn, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-throws"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Asserts that a function throws an exception.")} />
    <CodeBlock
      language="rescript"
      code={`assertThrows(() => {
  Exn.raiseError("boom")
})`}
    />
    <Separator />
    // Combining Results
    <div class="heading-anchor" id="combining">
      <Typography text={static("Combining Results")} variant={H2} />
      <a class="anchor-link" href="#combining"> {"#"->Component.text} </a>
    </div>
    <div class="heading-anchor" id="combine-results">
      <Typography text={static("combineResults(results)")} variant={H3} />
      <a class="anchor-link" href="#combine-results"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Combines multiple testResult values into one. Returns Pass only if all results are Pass.")} />
    <CodeBlock
      language="rescript"
      code={`test("multiple assertions", () => {
  combineResults([
    assertEqual(1 + 1, 2),
    assertTrue(Array.length([1]) > 0),
    assertContains("hello", "ell"),
  ])
})`}
    />
    <div class="heading-anchor" id="combine-async-results">
      <Typography text={static("combineAsyncResults(results)")} variant={H3} />
      <a class="anchor-link" href="#combine-async-results"> {"#"->Component.text} </a>
    </div>
    <Typography text={static("Combines multiple promise<testResult> values. Same behavior as combineResults but for async.")} />
    <CodeBlock
      language="rescript"
      code={`asyncTest("multiple async checks", async () => {
  await combineAsyncResults([
    Promise.resolve(assertEqual(1, 1)),
    Promise.resolve(assertTrue(true)),
  ])
})`}
    />
    <EditOnGitHub pageName="Pages__ApiAssertions" />
  </div>
}
