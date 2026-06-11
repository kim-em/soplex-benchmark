import Lake
open System Lake DSL

/-! # `lp-benchmark` build configuration

  Benchmarks comparing the `lp` tactic (from `leanprover/lp`) against
  mathlib's `linarith` tactic (at PR #40110 — linarith with the syntactic
  atom-cache improvement).

  Both `LP` and `Mathlib` are required, pinned to commits/branches
  that share the `leanprover/lean4:v4.31.0-rc1` toolchain.

  Build: `lake exe cache get` then `lake build`. Run a benchmark file
  with `lake env lean Benchmark/<File>.lean` and read the
  `tactic execution` line from the profiler output.
-/

require LP from git "https://github.com/leanprover/lp" @
  "f5845726b4128e0cba17693c74a84960fe9e17a3"

-- Mathlib at PR #40110 (`perf(Tactic/Linarith): syntactic cache for atom lookup`)
require Mathlib from git "https://github.com/kim-em/mathlib4" @
  "7a00f3296b6766ea09eb22ace0f62001af122f7a"

package LPBenchmark

/-- `lake build` sanity target: elaborates one `by lp` and one
    `by linarith` example so CI proves the pins resolve and both
    tactics work. The profiling files (`Benchmark/Size*.lean`,
    `bench/Bench*.lean`) are driven by `scripts/bench.sh` via
    `lake env lean`, not built as part of this target. -/
@[default_target]
lean_lib Benchmark where
  roots := #[`Benchmark.Sanity]
