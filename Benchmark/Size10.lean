import Mathlib.Tactic.Linarith
import Soplex
open Soplex Soplex.Verify

#time example (x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 : Rat) (_a0 : 0 ≤ x0) (_a1 : 0 ≤ x1) (_a2 : 0 ≤ x2) (_a3 : 0 ≤ x3) (_a4 : 0 ≤ x4) (_a5 : 0 ≤ x5) (_a6 : 0 ≤ x6) (_a7 : 0 ≤ x7) (_a8 : 0 ≤ x8) (_a9 : 0 ≤ x9) (_b0 : x0 ≤ 1) (_b1 : x1 ≤ 1) (_b2 : x2 ≤ 1) (_b3 : x3 ≤ 1) (_b4 : x4 ≤ 1) (_b5 : x5 ≤ 1) (_b6 : x6 ≤ 1) (_b7 : x7 ≤ 1) (_b8 : x8 ≤ 1) (_b9 : x9 ≤ 1) : x0 + x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 ≤ 10 := by lp

#time example (x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 : Rat) (_a0 : 0 ≤ x0) (_a1 : 0 ≤ x1) (_a2 : 0 ≤ x2) (_a3 : 0 ≤ x3) (_a4 : 0 ≤ x4) (_a5 : 0 ≤ x5) (_a6 : 0 ≤ x6) (_a7 : 0 ≤ x7) (_a8 : 0 ≤ x8) (_a9 : 0 ≤ x9) (_b0 : x0 ≤ 1) (_b1 : x1 ≤ 1) (_b2 : x2 ≤ 1) (_b3 : x3 ≤ 1) (_b4 : x4 ≤ 1) (_b5 : x5 ≤ 1) (_b6 : x6 ≤ 1) (_b7 : x7 ≤ 1) (_b8 : x8 ≤ 1) (_b9 : x9 ≤ 1) : x0 + x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 ≤ 10 := by linarith (config := {})
