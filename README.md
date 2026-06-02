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

## Results

Median of 5 runs, M1 MacBook, `v4.31.0-rc1`, soplex `d1b3dad`, mathlib at
PR #40110 head:

| Benchmark   | `by lp` | `by linarith (config := {})` | ratio (lin/lp) |
|-------------|--------:|-----------------------------:|---------------:|
| Headline    |   18 ms |                        51 ms |          2.83× |
| Size5       |   19 ms |                        45 ms |          2.37× |
| Size10      |   23 ms |                        56 ms |          2.43× |
| Size20      |   41 ms |                        85 ms |          2.07× |
| Size40      |   86 ms |                       161 ms |          1.87× |
| Size80      |  225 ms |                       409 ms |          1.82× |
| NonTrivial  |   86 ms |                       170 ms |          1.98× |

Geometric mean speedup: **~2.2×** in lp's favour. The lead is widest on
the small/headline problems (2.8×) and narrows toward 1.8× at n=80.

![Size sweep, log-log](results/size-sweep.png)

![All benchmarks, log scale](results/all-bars.png)

![Speedup ratios](results/ratios.png)

Reproduce: `./scripts/bench.sh 5 && python3 scripts/plot.py`.

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
