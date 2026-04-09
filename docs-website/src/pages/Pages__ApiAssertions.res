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
      <a class="anchor-link" href="#equality"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="assert-equal">
      <Typography text={static("Assert.equal(a, b, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-equal"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that two values are structurally equal.")} />
    <CodeBlock
      language="rescript"
      code={`Assert.equal(1 + 1, 2)
Assert.equal("hello", "hello")
Assert.equal([1, 2], [1, 2])`}
    />
    <div class="heading-anchor" id="assert-not-equal">
      <Typography text={static("Assert.notEqual(a, b, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-not-equal"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that two values are not equal.")} />
    <CodeBlock language="rescript" code={`Assert.notEqual(1, 2)`} />
    <Separator />
    // Boolean
    <div class="heading-anchor" id="boolean">
      <Typography text={static("Boolean")} variant={H2} />
      <a class="anchor-link" href="#boolean"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="assert-true">
      <Typography text={static("Assert.isTrue(value, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-true"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that a value is true.")} />
    <CodeBlock language="rescript" code={`Assert.isTrue(Array.length([1, 2]) > 0)`} />
    <div class="heading-anchor" id="assert-false">
      <Typography text={static("Assert.isFalse(value, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-false"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that a value is false.")} />
    <CodeBlock language="rescript" code={`Assert.isFalse(String.length("") > 0)`} />
    <Separator />
    // Comparison
    <div class="heading-anchor" id="comparison">
      <Typography text={static("Comparison")} variant={H2} />
      <a class="anchor-link" href="#comparison"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="assert-greater-than">
      <Typography text={static("Assert.greaterThan(a, b, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-greater-than"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that a > b.")} />
    <CodeBlock language="rescript" code={`Assert.greaterThan(10, 5)`} />
    <div class="heading-anchor" id="assert-less-than">
      <Typography text={static("Assert.lessThan(a, b, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-less-than"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that a < b.")} />
    <CodeBlock language="rescript" code={`Assert.lessThan(3, 7)`} />
    <div class="heading-anchor" id="assert-gte">
      <Typography text={static("Assert.greaterThanOrEqual(a, b, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-gte"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that a >= b.")} />
    <div class="heading-anchor" id="assert-lte">
      <Typography text={static("Assert.lessThanOrEqual(a, b, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-lte"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that a <= b.")} />
    <Separator />
    // String & Array
    <div class="heading-anchor" id="string-array">
      <Typography text={static("String & Array")} variant={H2} />
      <a class="anchor-link" href="#string-array"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="assert-contains">
      <Typography text={static("Assert.contains(string, substring, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-contains"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that a string contains a substring.")} />
    <CodeBlock language="rescript" code={`Assert.contains("hello world", "world")`} />
    <div class="heading-anchor" id="assert-array-contains">
      <Typography text={static("Assert.arrayContains(array, item, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-array-contains"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that an array contains a specific item.")} />
    <CodeBlock language="rescript" code={`Assert.arrayContains([1, 2, 3], 2)`} />
    <Separator />
    // Pattern Matching
    <div class="heading-anchor" id="pattern">
      <Typography text={static("Pattern Matching")} variant={H2} />
      <a class="anchor-link" href="#pattern"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="assert-match">
      <Typography text={static("Assert.matches(string, regex, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-match"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that a string matches a regular expression.")} />
    <CodeBlock language="rescript" code={`Assert.matches("hello123", %re("/\\d+/"))`} />
    <Separator />
    // Option & Result
    <div class="heading-anchor" id="option-result">
      <Typography text={static("Option & Result")} variant={H2} />
      <a class="anchor-link" href="#option-result"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="assert-some">
      <Typography text={static("Assert.some(option, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-some"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that an option is Some.")} />
    <CodeBlock language="rescript" code={`Assert.some(Array.get([1, 2], 0))`} />
    <div class="heading-anchor" id="assert-none">
      <Typography text={static("Assert.none(option, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-none"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that an option is None.")} />
    <CodeBlock language="rescript" code={`Assert.none(Map.get(emptyMap, "key"))`} />
    <div class="heading-anchor" id="assert-ok">
      <Typography text={static("Assert.ok(result, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-ok"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that a result is Ok.")} />
    <CodeBlock language="rescript" code={`Assert.ok(Ok(42))`} />
    <div class="heading-anchor" id="assert-error">
      <Typography text={static("Assert.error(result, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-error"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that a result is Error.")} />
    <CodeBlock language="rescript" code={`Assert.error(Error("not found"))`} />
    <Separator />
    // Exception
    <div class="heading-anchor" id="exception">
      <Typography text={static("Exceptions")} variant={H2} />
      <a class="anchor-link" href="#exception"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="assert-throws">
      <Typography text={static("Assert.throws(fn, ~message?)")} variant={H3} />
      <a class="anchor-link" href="#assert-throws"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Asserts that a function throws an exception.")} />
    <CodeBlock
      language="rescript"
      code={`Assert.throws(() => {
  Exn.raiseError("boom")
})`}
    />
    <Separator />
    // Combining Results
    <div class="heading-anchor" id="combining">
      <Typography text={static("Combining Results")} variant={H2} />
      <a class="anchor-link" href="#combining"> {"#"->Node.text} </a>
    </div>
    <div class="heading-anchor" id="combine-results">
      <Typography text={static("Assert.combineResults(results)")} variant={H3} />
      <a class="anchor-link" href="#combine-results"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Combines multiple testResult values into one. Returns Pass only if all results are Pass.")} />
    <CodeBlock
      language="rescript"
      code={`Test.make("multiple assertions", () => {
  Assert.combineResults([
    Assert.equal(1 + 1, 2),
    Assert.isTrue(Array.length([1]) > 0),
    Assert.contains("hello", "ell"),
  ])
})`}
    />
    <div class="heading-anchor" id="combine-async-results">
      <Typography text={static("Assert.combineAsyncResults(results)")} variant={H3} />
      <a class="anchor-link" href="#combine-async-results"> {"#"->Node.text} </a>
    </div>
    <Typography text={static("Combines multiple promise<testResult> values. Same behavior as Assert.combineResults but for async.")} />
    <CodeBlock
      language="rescript"
      code={`Test.async("multiple async checks", async () => {
  await Assert.combineAsyncResults([
    Promise.resolve(Assert.equal(1, 1)),
    Promise.resolve(Assert.isTrue(true)),
  ])
})`}
    />
    <EditOnGitHub pageName="Pages__ApiAssertions" />
  </div>
}
