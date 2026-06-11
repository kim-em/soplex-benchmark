#!/usr/bin/env bash
# Run the per-carrier box-LP benchmarks (bench/Bench*.lean), median each
# `#time` line across N runs, and write results/multicarrier${N}.csv
# (carrier,size,lp_ms,linarith_ms) for scripts/plot_multicarrier.py.
#
# Usage: ./scripts/bench_multicarrier.sh [N]    (N runs per file; default 5)
#
# Each bench/Bench<Carrier>.lean has one `#time … by lp` example per size
# in SIZES order; BenchRat.lean additionally has the matching
# `by linarith (config := {})` examples after them (linarith only runs on
# the Rat carrier).

set -eo pipefail

RUNS="${1:-5}"
cd "$(dirname "$0")/.."
mkdir -p results
CSV="results/multicarrier${RUNS}.csv"
echo "carrier,size,lp_ms,linarith_ms" > "$CSV"

SIZES=(5 10 20 40 80)

# Since LP's module-system migration, `lake env lean <file>` does not
# auto-load the precompiled FFI dynlibs; pass them explicitly (same fix
# as scripts/bench.sh).
DYNLIB_ARGS=()
for lib in .lake/packages/LPCore/.lake/build/lib/libLPCore_LPCore.* \
           .lake/packages/SoplexFFI/.lake/build/lib/libSoplexFFI_SoplexFFI.*; do
  case "$lib" in
    *.dylib|*.so|*.dll) DYNLIB_ARGS+=("--load-dynlib" "$lib") ;;
  esac
done

median() {
  local tmp; tmp=$(mktemp)
  sort -n > "$tmp"
  local n; n=$(wc -l < "$tmp" | tr -d ' ')
  awk -v k="$(( (n + 1) / 2 ))" 'NR==k' "$tmp"
  rm "$tmp"
}

printf "%-8s %-6s %-10s %s\n" "carrier" "size" "lp (ms)" "linarith (ms)"

for bench in bench/Bench*.lean; do
  carrier=$(basename "$bench" .lean); carrier=${carrier#Bench}
  k_total=$(grep -c '^#time' "$bench")
  tmpdir=$(mktemp -d)
  fail=0
  for ((r=1; r<=RUNS; r++)); do
    if ! lake env lean "${DYNLIB_ARGS[@]}" "$bench" \
        > "$tmpdir/raw$r" 2>&1; then
      printf "%-8s FAILED\n" "$carrier"
      head -3 "$tmpdir/raw$r"; fail=1; break
    fi
    awk '/^time: / { gsub(/[^0-9]/, "", $2); print $2 }' "$tmpdir/raw$r" \
      > "$tmpdir/run$r"
  done
  if [ $fail -eq 1 ]; then rm -rf "$tmpdir"; continue; fi
  for ((k=1; k<=k_total; k++)); do
    med=$(for ((r=1; r<=RUNS; r++)); do sed -n "${k}p" "$tmpdir/run$r"; done | median)
    if (( k <= ${#SIZES[@]} )); then
      size=${SIZES[k-1]}
      lp_med[k]=$med
    else
      # BenchRat's trailing linarith examples, same size order.
      idx=$(( k - ${#SIZES[@]} ))
      lin_med[idx]=$med
    fi
  done
  for ((i=1; i<=${#SIZES[@]}; i++)); do
    size=${SIZES[i-1]}
    lin="${lin_med[i]:-}"
    printf "%-8s %-6s %-10s %s\n" "$carrier" "$size" "${lp_med[i]}" "${lin:--}"
    printf "%s,%s,%s,%s\n" "$carrier" "$size" "${lp_med[i]}" "$lin" >> "$CSV"
  done
  unset lp_med lin_med
  rm -rf "$tmpdir"
done

echo "Wrote $CSV"
