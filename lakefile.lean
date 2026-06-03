import Lake
open System Lake DSL

/-! # `soplex-benchmark` build configuration

  Benchmarks comparing the `lp` tactic (from `kim-em/soplex`) against
  mathlib's `linarith` tactic (at PR #40110 — linarith with the syntactic
  atom-cache improvement).

  Both `Soplex` and `Mathlib` are required, pinned to commits/branches
  that share the `leanprover/lean4:v4.31.0-rc1` toolchain.

  Build: `lake exe cache get` then `lake build`. Run a benchmark file
  with `lake env lean Benchmark/<File>.lean` and read the
  `tactic execution` line from the profiler output.
-/

require Soplex from git "https://github.com/kim-em/soplex" @
  "b22aceb36d32c9b9a3bffa4a8b2a662271df2478"

-- Mathlib at PR #40110 (`perf(Tactic/Linarith): syntactic cache for atom lookup`)
require Mathlib from git "https://github.com/kim-em/mathlib4" @
  "7a00f3296b6766ea09eb22ace0f62001af122f7a"

package SoplexBenchmark

@[default_target]
lean_lib SoplexBenchmark
