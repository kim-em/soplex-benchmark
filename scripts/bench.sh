#!/usr/bin/env bash
# Run each benchmark file, capture the elapsed times for both `by lp` and
# `by linarith (config := {})` examples (via `#time`), median across runs.
#
# Usage: ./scripts/bench.sh [N]    (N runs per file; default 5)
#
# Side effect: writes results/median${N}.csv (one row per benchmark:
# name,lp_ms,linarith_ms) for scripts/plot.py.

set -eo pipefail

RUNS="${1:-5}"
cd "$(dirname "$0")/.."
mkdir -p results
CSV="results/median${RUNS}.csv"
: > "$CSV"

# Since LP's module-system migration, `lake env lean <file>` does not
# auto-load the precompiled FFI dynlibs, so `by lp` aborts with "Could
# not find native implementation of 'LP.solveExactFlat'". Pass them
# explicitly, the same way `leanprover/lp`'s own test runner does.
DYNLIB_ARGS=()
for lib in .lake/packages/LPCore/.lake/build/lib/libLPCore_LPCore.* \
           .lake/packages/SoplexFFI/.lake/build/lib/libSoplexFFI_SoplexFFI.*; do
  case "$lib" in
    *.dylib|*.so|*.dll) DYNLIB_ARGS+=("--load-dynlib" "$lib") ;;
  esac
done

median() {
  # Read all input, sort, pick the middle line.
  local tmp; tmp=$(mktemp)
  sort -n > "$tmp"
  local n; n=$(wc -l < "$tmp" | tr -d ' ')
  awk -v k="$(( (n + 1) / 2 ))" 'NR==k' "$tmp"
  rm "$tmp"
}

# Extract the k-th `time: <N>ms` value from a file's stdout.
extract_kth() {
  local file="$1" k="$2"
  awk '/^time: / { gsub(/[^0-9]/, "", $2); print $2 }' "$file" | awk -v k="$k" 'NR==k'
}

printf "%-12s %-12s %-12s %s\n" "file" "lp (ms)" "linarith (ms)" "ratio (lin/lp)"
printf "%-12s %-12s %-12s %s\n" "----" "-------" "-------------" "--------------"

for bench in Benchmark/*.lean; do
  name=$(basename "$bench" .lean)
  # Sanity is the `lake build` target (no #time lines), not a benchmark.
  [ "$name" = "Sanity" ] && continue
  lp_times=()
  lin_times=()
  fail=0
  for ((r=1; r<=RUNS; r++)); do
    out=$(mktemp)
    if ! lake env lean "${DYNLIB_ARGS[@]}" "$bench" >"$out" 2>&1; then
      printf "%-12s FAILED\n" "$name"
      rm "$out"; fail=1; break
    fi
    lp_times+=("$(extract_kth "$out" 1)")
    lin_times+=("$(extract_kth "$out" 2)")
    rm "$out"
  done
  [ $fail -eq 1 ] && continue
  lp_med=$(printf '%s\n' "${lp_times[@]}" | median)
  lin_med=$(printf '%s\n' "${lin_times[@]}" | median)
  ratio=$(echo "scale=2; $lin_med / $lp_med" | bc)
  printf "%-12s %-12s %-12s %sx\n" "$name" "$lp_med" "$lin_med" "$ratio"
  # CSV row: name,lp_ms,linarith_ms — only for the two-example files
  # (skip ConfigSanity, which has two linarith examples and no lp).
  if [ "$name" != "ConfigSanity" ]; then
    printf "%s,%s,%s\n" "$name" "$lp_med" "$lin_med" >> "$CSV"
  fi
done
