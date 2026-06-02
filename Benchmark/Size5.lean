import Mathlib.Tactic.Linarith
import Soplex
open Soplex Soplex.Verify

-- lp
set_option profiler true in
example (x0 x1 x2 x3 x4 : Rat) (a0 : 0 ≤ x0) (a1 : 0 ≤ x1) (a2 : 0 ≤ x2) (a3 : 0 ≤ x3) (a4 : 0 ≤ x4) (b0 : x0 ≤ 1) (b1 : x1 ≤ 1) (b2 : x2 ≤ 1) (b3 : x3 ≤ 1) (b4 : x4 ≤ 1) : x0 + x1 + x2 + x3 + x4 ≤ 5 := by lp

-- linarith (config := {})
set_option profiler true in
example (x0 x1 x2 x3 x4 : Rat) (a0 : 0 ≤ x0) (a1 : 0 ≤ x1) (a2 : 0 ≤ x2) (a3 : 0 ≤ x3) (a4 : 0 ≤ x4) (b0 : x0 ≤ 1) (b1 : x1 ≤ 1) (b2 : x2 ≤ 1) (b3 : x3 ≤ 1) (b4 : x4 ≤ 1) : x0 + x1 + x2 + x3 + x4 ≤ 5 := by linarith (config := {})
