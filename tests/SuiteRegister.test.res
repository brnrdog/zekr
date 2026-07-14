open Types

let autoRegisterTests = Suite.make(
  "Suite auto-registration",
  [
    Test.make("Suite.make registers the built suite", () => {
      Registry.clear()
      let _ = Suite.make("Made", [Test.make("t", () => Pass)])
      let (sync, _) = Registry.snapshot()
      switch sync->Array.get(0) {
      | Some(s) if s.name == "Made" && Array.length(sync) == 1 => Pass
      | _ => Fail("Expected Suite.make to register exactly one suite named Made")
      }
    }),
    Test.make("Suite.async registers the built async suite", () => {
      Registry.clear()
      let _ = Suite.async("MadeAsync", [Test.async("t", async () => Pass)])
      let (_, async) = Registry.snapshot()
      switch async->Array.get(0) {
      | Some(s) if s.name == "MadeAsync" && Array.length(async) == 1 => Pass
      | _ => Fail("Expected Suite.async to register exactly one async suite named MadeAsync")
      }
    }),
  ],
)

