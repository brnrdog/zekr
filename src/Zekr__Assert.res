// Zekr__Assert - Assertion functions for test verification

open Zekr__Types

let assertEqual = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual == expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None =>
      `Assertion failed\n` ++
      `       ${Zekr__Colors.pass("+ expected")} ${Zekr__Colors.fail("- actual")}\n` ++
      `       ${Zekr__Colors.fail("- " ++ String.make(actual))}\n` ++
      `       ${Zekr__Colors.pass("+ " ++ String.make(expected))}`
    }
    Fail(msg)
  }
}

let assertNotEqual = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual != expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None =>
      `Assertion failed: values should not be equal\n` ++
      `       Both values: ${String.make(actual)}`
    }
    Fail(msg)
  }
}

let assertTrue = (condition: bool, ~message: option<string>=?): testResult => {
  if condition {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => "Expected true, got false"
    }
    Fail(msg)
  }
}

let assertFalse = (condition: bool, ~message: option<string>=?): testResult => {
  if !condition {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => "Expected false, got true"
    }
    Fail(msg)
  }
}

let assertGreaterThan = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual > expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None =>
      `Assertion failed: expected actual > threshold\n` ++
      `       actual:    ${String.make(actual)}\n` ++
      `       threshold: ${String.make(expected)}`
    }
    Fail(msg)
  }
}

let assertLessThan = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual < expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None =>
      `Assertion failed: expected actual < threshold\n` ++
      `       actual:    ${String.make(actual)}\n` ++
      `       threshold: ${String.make(expected)}`
    }
    Fail(msg)
  }
}

let assertGreaterThanOrEqual = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual >= expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None =>
      `Assertion failed: expected actual >= threshold\n` ++
      `       actual:    ${String.make(actual)}\n` ++
      `       threshold: ${String.make(expected)}`
    }
    Fail(msg)
  }
}

let assertLessThanOrEqual = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual <= expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None =>
      `Assertion failed: expected actual <= threshold\n` ++
      `       actual:    ${String.make(actual)}\n` ++
      `       threshold: ${String.make(expected)}`
    }
    Fail(msg)
  }
}

let assertContains = (haystack: string, needle: string, ~message: option<string>=?): testResult => {
  if String.includes(haystack, needle) {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None =>
      `Assertion failed: string does not contain substring\n` ++
      `       string:    "${haystack}"\n` ++
      `       expected:  "${needle}"`
    }
    Fail(msg)
  }
}

let assertArrayContains = (arr: array<'a>, item: 'a, ~message: option<string>=?): testResult => {
  if Array.includes(arr, item) {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None =>
      `Assertion failed: array does not contain item\n` ++
      `       expected to contain: ${String.make(item)}`
    }
    Fail(msg)
  }
}

let assertMatch = (str: string, pattern: RegExp.t, ~message: option<string>=?): testResult => {
  if RegExp.test(pattern, str) {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None => `Expected "${str}" to match pattern`
    }
    Fail(msg)
  }
}

let assertSome = (opt: option<'a>, ~message: option<string>=?): testResult => {
  switch opt {
  | Some(_) => Pass
  | None => {
      let msg = switch message {
      | Some(m) => m
      | None => "Expected Some, got None"
      }
      Fail(msg)
    }
  }
}

let assertNone = (opt: option<'a>, ~message: option<string>=?): testResult => {
  switch opt {
  | None => Pass
  | Some(_) => {
      let msg = switch message {
      | Some(m) => m
      | None => "Expected None, got Some"
      }
      Fail(msg)
    }
  }
}

let assertOk = (result: result<'a, 'e>, ~message: option<string>=?): testResult => {
  switch result {
  | Ok(_) => Pass
  | Error(_) => {
      let msg = switch message {
      | Some(m) => m
      | None => "Expected Ok, got Error"
      }
      Fail(msg)
    }
  }
}

let assertError = (result: result<'a, 'e>, ~message: option<string>=?): testResult => {
  switch result {
  | Error(_) => Pass
  | Ok(_) => {
      let msg = switch message {
      | Some(m) => m
      | None => "Expected Error, got Ok"
      }
      Fail(msg)
    }
  }
}

let assertThrows = (fn: unit => 'a, ~message: option<string>=?): testResult => {
  try {
    let _ = fn()
    let msg = switch message {
    | Some(m) => m
    | None => "Expected function to throw"
    }
    Fail(msg)
  } catch {
  | _ => Pass
  }
}

let combineResults = (results: array<testResult>): testResult => {
  let failures = results->Array.filter(r =>
    switch r {
    | Fail(_) => true
    | Pass => false
    }
  )

  if Array.length(failures) > 0 {
    failures->Array.get(0)->Option.getOr(Pass)
  } else {
    Pass
  }
}

let combineAsyncResults = async (results: array<promise<testResult>>): testResult => {
  let resolvedResults = await Promise.all(results)
  let failures = resolvedResults->Array.filter(r =>
    switch r {
    | Fail(_) => true
    | Pass => false
    }
  )

  if Array.length(failures) > 0 {
    failures->Array.get(0)->Option.getOr(Pass)
  } else {
    Pass
  }
}
