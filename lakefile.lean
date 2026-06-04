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
  "af0e65b4b9284bfdeabba78426c0a54563bcb1c5"

-- Mathlib at PR #40110 (`perf(Tactic/Linarith): syntactic cache for atom lookup`)
require Mathlib from git "https://github.com/kim-em/mathlib4" @
  "7a00f3296b6766ea09eb22ace0f62001af122f7a"

package SoplexBenchmark

@[default_target]
lean_lib SoplexBenchmark
