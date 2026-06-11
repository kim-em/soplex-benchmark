# lp-benchmark

[![Lean](https://img.shields.io/badge/Lean-4.31.0--rc1-blue.svg)](./lean-toolchain)

> **New here? Start at [`leanprover/lp`](https://github.com/leanprover/lp)** — the entry
> point for the `lp` / `maximize` tactics and the verified LP solver. This repository is one
> package of that family: benchmarks of the `lp` tactic against mathlib's `linarith`.

Benchmarks comparing the [`lp`](https://github.com/leanprover/lp) tactic
against mathlib's [`linarith`](https://github.com/leanprover-community/mathlib4/tree/master/Mathlib/Tactic/Linarith)
tactic on the same `ℚ`-typed linear arithmetic goals.

This is the companion benchmark repo to
[`leanprover/lp`](https://github.com/leanprover/lp) (the `by lp` tactic,
bundled end to end) and its engine
[`leanprover/lp-tactic`](https://github.com/leanprover/lp-tactic). See those repos
for the tactic itself, usage, and examples.

Both tactics close the same set of problems; this repo runs each through
Lean's `set_option profiler true` and reads off the `tactic execution`
line, then medians across runs to give an apples-to-apples comparison
for the lp announcement post.

## Versions pinned

- `LP`: leanprover/lp `ea9a0d5` (`main`), bundling the
  carrier-parametrized `lp` engine (leanprover/lp-tactic `main`) —
  the exact SHA is the `require LP` pin in [`lakefile.lean`](./lakefile.lean)
- `Mathlib`: kim-em/mathlib4 `7a00f329` (linarith with the syntactic
  atom-cache improvement from
  [PR #40110](https://github.com/leanprover-community/mathlib4/pull/40110))
- Lean: `v4.31.0-rc1`

## Build

```sh
lake exe cache get      # download mathlib oleans
lake build              # build LP (compiles vendored SoPlex; ~2-3 min first time)
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

We use `linarith (config := {})` rather than bare `linarith` for
consistency with our earlier methodology and to remove a small,
unrelated config-default-evaluation cost from the comparison. At the
pins used here the difference is about 4% (see the measurement in
"Why `linarith (config := {})`…" below — historically it was 2–3×;
the [fast-discharger work](https://github.com/leanprover/lp/issues/155)
has details on that artifact).

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

## Results

Median of 5 runs, M1 MacBook, `v4.31.0-rc1`, soplex `b22aceb` (main, carrier engine),
mathlib at PR #40110 head:

| Benchmark   | `by lp` | `by linarith (config := {})` | ratio (lin/lp) |
|-------------|--------:|-----------------------------:|---------------:|
| Headline    |   19 ms |                        53 ms |          2.79× |
| Size5       |   22 ms |                        46 ms |          2.09× |
| Size10      |   26 ms |                        57 ms |          2.19× |
| Size20      |   43 ms |                        84 ms |          1.95× |
| Size40      |   92 ms |                       163 ms |          1.77× |
| Size80      |  237 ms |                       417 ms |          1.76× |
| NonTrivial  |   86 ms |                       167 ms |          1.94× |

Geometric mean speedup: **~2.0×** in lp's favour. The lead is widest on
the small/headline problems (2.8×) and narrows toward 1.8× at n=80. `lp` runs
on the carrier-parametrized engine here; its `Rat` path keeps the original `Q`
fast-path, so these numbers match the pre-generalization engine within noise.

![Size sweep, log-log](results/size-sweep.png)

![All benchmarks, log scale](results/all-bars.png)

![Speedup ratios](results/ratios.png)

Reproduce: `./scripts/bench.sh 5 && python3 scripts/plot.py`.

## Multi-carrier sweep (unified `CarrierMethods` engine)

The `lp` tactic was generalized from a `Rat`-only discharger to a single
carrier-parametrized engine that proves the **same ℚ-Farkas implications**
over a family of ordered carriers: `Rat` (field), `Real` (field, via Mathlib),
`Int` (comm ring), `Dyadic` (comm ring, no inverses), and `Nat` (comm
semiring, no negation). The ℚ LP sent to SoPlex is identical across carriers;
only the reconstructed proof term differs. (No integer-cut/integrality
reasoning — that stays with `omega`/`cutsat`; `lp` proves ℚ-valid implications
only.)

The key performance question: does generalization cost the `Rat` baseline
anything, and how do the native computable carriers compare? Same box-LP
shape as `Size{5..80}` above, identical 2n-row structure across carriers,
median-of-5, same `v4.31.0-rc1` toolchain and carrier engine as the
`lp`-vs-`linarith` table above:

| size | Nat | Int | Dyadic | Rat | Real | linarith (Rat) |
|-----:|----:|----:|-------:|----:|-----:|---------------:|
| 5    | 13  | 15  | 14     | 20  | 35   | 45 |
| 10   | 12  | 13  | 14     | 17  | 39   | 39 |
| 20   | 25  | 27  | 28     | 35  | 73   | 66 |
| 40   | 64  | 69  | 69     | 86  | 153  | 140 |
| 80   | 190 | 205 | 207    | 229 | 381  | 380 |

Reading:

- **The native computable carriers (`Nat`, `Int`, `Dyadic`) are *faster*
  than the hand-optimized `Rat` baseline** — 0.65–0.90×. They render
  coefficients as their own kernel-reducible literals, so per-leaf
  arithmetic closes by `Eq.refl` with no proof term at all; `Nat` is fastest
  (most reducible literals). Generalization didn't regress `Rat` — `Rat`
  keeps its original `Q`-literal fast-path unchanged.
- **`Real` pays a flat ~1.6–2.3× over `Rat`** — it is non-computable, so
  coefficients render as `ofRat r` (not defeq to a user literal) and each
  needs a `userLit = ofRat r` bridge proof. This is inherent to an abstract
  field and is the *only* carrier that pays it.
- `lp` still beats `linarith` ~2× on the `Rat` column (the headline story
  above), and every native carrier widens that lead.

![Multi-carrier sweep, log-log](results/multicarrier-sweep.png)

![Per-carrier box-LP timing](results/multicarrier-bars.png)

![Carrier time relative to Rat](results/multicarrier-ratio.png)

Reproduce: the per-carrier `bench/Bench*.lean` files (box-LP over each carrier,
`import LP`) run median-of-5, then `python3 scripts/plot_multicarrier.py`.

## Why `linarith (config := {})` and not bare `linarith`?

A version of Lean's `linarith` extension elaboration evaluates default
config values lazily at each call, which historically inflated the
reported time for bare `linarith` by 2–3× on these benchmarks. As of
the pin used here (`v4.31.0-rc1` + PR #40110), the gap has shrunk
dramatically. `Benchmark/ConfigSanity.lean` measures both forms on the
Size40 shape:

| Call form | median ms |
|---|---:|
| `by linarith` | 154 |
| `by linarith (config := {})` | 148 |

So the `(config := {})` form is **~4% faster** than bare `linarith`,
not 2-3× faster. The choice does not meaningfully affect the comparison;
the headline ratios above would change by less than 5% in either
direction. We use `(config := {})` for consistency with our prior
methodology, and to remove this minor and unrelated noise source from
the comparison.
