-- Build sanity module: the `lake build` default target. Confirms the
-- LP and Mathlib pins resolve together and both tactics close a goal,
-- without running any timing sweep (the `Benchmark/Size*.lean` files
-- are profiling runs driven by `scripts/bench.sh`, not build targets).
import Mathlib.Tactic.Linarith
import LP

example (a b : Rat) (_ : 2 * a + b ≤ 5) (_ : a - b ≤ 1) : 3 * a ≤ 6 := by lp

example (a b : Rat) (_ : 2 * a + b ≤ 5) (_ : a - b ≤ 1) : 3 * a ≤ 6 := by
  linarith (config := {})
