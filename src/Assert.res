// Assert - Assertion functions for test verification

open Types

let equal = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
  if actual == expected {
    Pass
  } else {
    let msg = switch message {
    | Some(m) => m
    | None =>
      `Assertion failed\n` ++
      `       ${Colors.pass("+ expected")} ${Colors.fail("- actual")}\n` ++
      `       ${Colors.fail("- " ++ String.make(actual))}\n` ++
      `       ${Colors.pass("+ " ++ String.make(expected))}`
    }
    Fail(msg)
  }
}

let notEqual = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
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

let isTrue = (condition: bool, ~message: option<string>=?): testResult => {
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

let isFalse = (condition: bool, ~message: option<string>=?): testResult => {
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

let greaterThan = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
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

let lessThan = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
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

let greaterThanOrEqual = (
  actual: 'a,
  expected: 'a,
  ~message: option<string>=?,
): testResult => {
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

let lessThanOrEqual = (actual: 'a, expected: 'a, ~message: option<string>=?): testResult => {
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

let contains = (haystack: string, needle: string, ~message: option<string>=?): testResult => {
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

let arrayContains = (arr: array<'a>, item: 'a, ~message: option<string>=?): testResult => {
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

let matches = (str: string, pattern: RegExp.t, ~message: option<string>=?): testResult => {
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

let some = (opt: option<'a>, ~message: option<string>=?): testResult => {
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

let none = (opt: option<'a>, ~message: option<string>=?): testResult => {
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

let ok = (result: result<'a, 'e>, ~message: option<string>=?): testResult => {
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

let error = (result: result<'a, 'e>, ~message: option<string>=?): testResult => {
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

let throws = (fn: unit => 'a, ~message: option<string>=?): testResult => {
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
