-- Headline example from the lp README:
-- Maximise 3x₀ + 5x₁ subject to x₀ ≤ 4, 2x₁ ≤ 12, 3x₀ + 2x₁ ≤ 18, x₀,x₁ ≥ 0.
-- Optimum is x = (2, 6) with objective 36.
import Mathlib.Tactic.Linarith
import Soplex
open Soplex Soplex.Verify

#time example (x₀ x₁ : Rat) (_ : x₀ ≤ 4) (_ : 2 * x₁ ≤ 12) (_ : 3 * x₀ + 2 * x₁ ≤ 18)
    (_ : 0 ≤ x₀) (_ : 0 ≤ x₁) : 3 * x₀ + 5 * x₁ ≤ 36 := by lp

#time example (x₀ x₁ : Rat) (_ : x₀ ≤ 4) (_ : 2 * x₁ ≤ 12) (_ : 3 * x₀ + 2 * x₁ ≤ 18)
    (_ : 0 ≤ x₀) (_ : 0 ≤ x₁) : 3 * x₀ + 5 * x₁ ≤ 36 := by linarith (config := {})
