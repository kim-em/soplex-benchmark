import Mathlib.Tactic.Linarith
import Soplex
open Soplex Soplex.Verify

-- lp
set_option profiler true in
example (x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 : Rat) (a0 : 0 ≤ x0) (a1 : 0 ≤ x1) (a2 : 0 ≤ x2) (a3 : 0 ≤ x3) (a4 : 0 ≤ x4) (a5 : 0 ≤ x5) (a6 : 0 ≤ x6) (a7 : 0 ≤ x7) (a8 : 0 ≤ x8) (a9 : 0 ≤ x9) (b0 : x0 ≤ 1) (b1 : x1 ≤ 1) (b2 : x2 ≤ 1) (b3 : x3 ≤ 1) (b4 : x4 ≤ 1) (b5 : x5 ≤ 1) (b6 : x6 ≤ 1) (b7 : x7 ≤ 1) (b8 : x8 ≤ 1) (b9 : x9 ≤ 1) : x0 + x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 ≤ 10 := by lp

-- linarith (config := {})
set_option profiler true in
example (x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 : Rat) (a0 : 0 ≤ x0) (a1 : 0 ≤ x1) (a2 : 0 ≤ x2) (a3 : 0 ≤ x3) (a4 : 0 ≤ x4) (a5 : 0 ≤ x5) (a6 : 0 ≤ x6) (a7 : 0 ≤ x7) (a8 : 0 ≤ x8) (a9 : 0 ≤ x9) (b0 : x0 ≤ 1) (b1 : x1 ≤ 1) (b2 : x2 ≤ 1) (b3 : x3 ≤ 1) (b4 : x4 ≤ 1) (b5 : x5 ≤ 1) (b6 : x6 ≤ 1) (b7 : x7 ≤ 1) (b8 : x8 ≤ 1) (b9 : x9 ≤ 1) : x0 + x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 ≤ 10 := by linarith (config := {})
