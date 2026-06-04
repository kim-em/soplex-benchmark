import Mathlib.Tactic.Linarith
import LP
open LP LP.Verify

#time example (x0 x1 x2 x3 x4 : Rat) (_a0 : 0 ≤ x0) (_a1 : 0 ≤ x1) (_a2 : 0 ≤ x2) (_a3 : 0 ≤ x3) (_a4 : 0 ≤ x4) (_b0 : x0 ≤ 1) (_b1 : x1 ≤ 1) (_b2 : x2 ≤ 1) (_b3 : x3 ≤ 1) (_b4 : x4 ≤ 1) : x0 + x1 + x2 + x3 + x4 ≤ 5 := by lp

#time example (x0 x1 x2 x3 x4 : Rat) (_a0 : 0 ≤ x0) (_a1 : 0 ≤ x1) (_a2 : 0 ≤ x2) (_a3 : 0 ≤ x3) (_a4 : 0 ≤ x4) (_b0 : x0 ≤ 1) (_b1 : x1 ≤ 1) (_b2 : x2 ≤ 1) (_b3 : x3 ≤ 1) (_b4 : x4 ≤ 1) : x0 + x1 + x2 + x3 + x4 ≤ 5 := by linarith (config := {})
