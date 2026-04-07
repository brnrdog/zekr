// Test - Test case factory functions

open Types

let make = (name: string, run: unit => testResult): testCase => {
  {name, run, mode: Normal}
}

let skip = (name: string, run: unit => testResult): testCase => {
  {name, run, mode: Skip}
}

let only = (name: string, run: unit => testResult): testCase => {
  {name, run, mode: Only}
}

let async = (
  name: string,
  run: unit => promise<testResult>,
  ~timeout: option<int>=?,
): asyncTestCase => {
  {name, run, mode: Normal, timeout}
}

let asyncSkip = (
  name: string,
  run: unit => promise<testResult>,
  ~timeout: option<int>=?,
): asyncTestCase => {
  {name, run, mode: Skip, timeout}
}

let asyncOnly = (
  name: string,
  run: unit => promise<testResult>,
  ~timeout: option<int>=?,
): asyncTestCase => {
  {name, run, mode: Only, timeout}
}
