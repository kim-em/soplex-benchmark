# soplex-benchmark

Benchmarks comparing the [`lp`](https://github.com/kim-em/soplex) tactic
against mathlib's [`linarith`](https://github.com/leanprover-community/mathlib4/tree/master/Mathlib/Tactic/Linarith)
tactic on the same `ℚ`-typed linear arithmetic goals.

Both tactics close the same set of problems; this repo runs each through
Lean's `set_option profiler true` and reads off the `tactic execution`
line, then medians across runs to give an apples-to-apples comparison
for the lp announcement post.

## Versions pinned

- `Soplex`: kim-em/soplex `d1b3dad` (`bump-v4.31.0-rc1` branch)
- `Mathlib`: kim-em/mathlib4 `7a00f329` (linarith with the syntactic
  atom-cache improvement from
  [PR #40110](https://github.com/leanprover-community/mathlib4/pull/40110))
- Lean: `v4.31.0-rc1`

## Build

```sh
lake exe cache get      # download mathlib oleans
lake build              # build Soplex (compiles vendored SoPlex; ~2-3 min first time)
```

## Run

```sh
./scripts/bench.sh        # median-of-5, prints a comparison table
./scripts/bench.sh 10     # median-of-10 for tighter numbers
```

## Methodology

Each `Benchmark/*.lean` file contains two `example`s on the same goal:

```lean
set_option profiler true in
example ... := by lp

set_option profiler true in
example ... := by linarith (config := {})
```

We use `linarith (config := {})` rather than bare `linarith` because the
latter triggers a config-default-evaluation cost that is unrelated to the
discharger work itself and roughly doubles the apparent linarith time
(see the [fast-discharger work](https://github.com/kim-em/soplex/issues/155)
for details on that artifact).

The script `scripts/bench.sh` runs each benchmark `N` times (default 5),
extracts the two `tactic execution` lines, medians across runs, and
prints the ratio. Both examples are run in the same Lean process so
elaboration overhead (cache warmth, etc.) is matched between them.

## Benchmark files

- **Headline.lean** — The lp README's textbook example: maximise
  `3x₀ + 5x₁` subject to 5 inequalities. Headline single-number
  comparison.
- **Size{5,10,20,40,80}.lean** — `n` non-negativity hypotheses and `n`
  upper-bound hypotheses, goal `Σ xᵢ ≤ n`. Shows scaling.
- **NonTrivial.lean** — 20 hypotheses `cᵢ · xᵢ ≤ 1` with `cᵢ ∈ 2..21`;
  goal `Σ xᵢ ≤ Σ 1/cᵢ`. Exercises non-trivial Farkas multipliers and
  rational coefficients in both the hypotheses and the goal.
