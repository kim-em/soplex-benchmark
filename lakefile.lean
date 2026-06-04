import Lake
open System Lake DSL

/-! # `soplex-benchmark` build configuration

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
  "5d1bf9675627cc2c5c0cdf2e2ea017eef380e62e"

-- Mathlib at PR #40110 (`perf(Tactic/Linarith): syntactic cache for atom lookup`)
require Mathlib from git "https://github.com/kim-em/mathlib4" @
  "7a00f3296b6766ea09eb22ace0f62001af122f7a"

package SoplexBenchmark

@[default_target]
lean_lib SoplexBenchmark
