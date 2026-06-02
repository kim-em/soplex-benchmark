#!/usr/bin/env bash
# Run each benchmark file, capture the tactic execution times for both
# `by lp` and `by linarith (config := {})` examples, and emit a compact
# table.
#
# Usage: ./scripts/bench.sh [N]    (N runs per file; default 5)
# Output: per-file lp time, linarith time, ratio. Median of N runs.

set -euo pipefail

RUNS="${1:-5}"
cd "$(dirname "$0")/.."

# Median of stdin (one number per line).
median() { sort -n | awk -v n="$(wc -l)" 'NR==int((n+1)/2)'; }

# Extract the tactic-execution time (ms) for the k-th example in a file's
# profiler output. The file has two `example`s — first `by lp`, second
# `by linarith`. We grep `tactic execution` lines in order.
extract_kth() {
  local file="$1" k="$2"
  awk '/^\ttactic execution / { print $3 }' "$file" | sed 's/ms$//' | awk -v k="$k" 'NR==k'
}

printf "%-12s %-10s %-10s %s\n" "file" "lp (ms)" "linarith (ms)" "ratio (lin/lp)"
printf "%-12s %-10s %-10s %s\n" "----" "-------" "-------------" "--------------"

for bench in Benchmark/*.lean; do
  name=$(basename "$bench" .lean)
  lp_times=()
  lin_times=()
  for ((r=1; r<=RUNS; r++)); do
    out=$(mktemp)
    lake env lean "$bench" 2>&1 >"$out" || { echo "$name: FAIL"; rm "$out"; continue 2; }
    lp_times+=("$(extract_kth "$out" 1)")
    lin_times+=("$(extract_kth "$out" 2)")
    rm "$out"
  done
  lp_med=$(printf '%s\n' "${lp_times[@]}" | median)
  lin_med=$(printf '%s\n' "${lin_times[@]}" | median)
  ratio=$(echo "scale=2; $lin_med / $lp_med" | bc)
  printf "%-12s %-10s %-10s %s\n" "$name" "$lp_med" "$lin_med" "${ratio}x"
done
