#!/usr/bin/env python3
"""Plot the multi-carrier `lp` box-LP sweep (v4.31.0-rc1 unified CarrierMethods engine).

Input: results/multicarrier5.csv  (carrier,size,lp_ms,linarith_ms)
Outputs:
    results/multicarrier-sweep.png  — log-log size vs ms, one line per carrier + linarith
    results/multicarrier-bars.png   — grouped bars: lp ms per carrier per size
    results/multicarrier-ratio.png  — grouped bars: carrier/Rat ms ratio per size
"""
import csv
from pathlib import Path
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent.parent
RESULTS = ROOT / "results"
CSV_PATH = RESULTS / "multicarrier5.csv"

# Carrier draw order + colours (Rat is the baseline).
CARRIERS = ["Nat", "Int", "Dyadic", "Rat", "Real"]
COLORS = {"Nat": "#2ca02c", "Int": "#1f77b4", "Dyadic": "#17becf",
          "Rat": "#000000", "Real": "#d62728", "linarith": "#7f7f7f"}
KIND = {"Nat": "comm semiring (no neg)", "Int": "comm ring", "Dyadic": "comm ring (no inv)",
        "Rat": "field (Q fast-path)", "Real": "field (ofRat bridge)"}


def load():
    lp = {c: {} for c in CARRIERS}
    lin = {}
    sizes = set()
    with CSV_PATH.open() as f:
        rd = csv.DictReader(f)
        for r in rd:
            c, n = r["carrier"], int(r["size"])
            sizes.add(n)
            if r["lp_ms"]:
                lp.setdefault(c, {})[n] = float(r["lp_ms"])
            if r["linarith_ms"]:
                lin[n] = float(r["linarith_ms"])
    return lp, lin, sorted(sizes)


def plot_sweep(lp, lin, sizes):
    plt.figure(figsize=(8, 5.5))
    for c in CARRIERS:
        ys = [lp[c][n] for n in sizes]
        plt.plot(sizes, ys, "o-", color=COLORS[c], linewidth=2,
                 label=f"lp / {c} — {KIND[c]}")
    if lin:
        plt.plot(sizes, [lin[n] for n in sizes], "s--", color=COLORS["linarith"],
                 linewidth=1.6, label="linarith / Rat")
    plt.xscale("log"); plt.yscale("log")
    plt.xticks(sizes, [str(s) for s in sizes])
    plt.gca().get_xaxis().set_major_formatter(plt.matplotlib.ticker.ScalarFormatter())
    plt.xlabel("box-LP size n  (variables; 2n constraints)")
    plt.ylabel("tactic execution (ms, median-of-5)")
    plt.title("lp across carriers — one unified engine  (Lean v4.31.0-rc1)")
    plt.legend(fontsize=8, loc="upper left")
    plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    out = RESULTS / "multicarrier-sweep.png"
    plt.savefig(out, dpi=130); plt.close()
    print("wrote", out)


def plot_bars(lp, sizes):
    import numpy as np
    plt.figure(figsize=(9, 5.5))
    x = np.arange(len(sizes))
    w = 0.16
    for i, c in enumerate(CARRIERS):
        ys = [lp[c][n] for n in sizes]
        plt.bar(x + (i - 2) * w, ys, w, color=COLORS[c], label=c)
    plt.xticks(x, [f"Size{n}" for n in sizes])
    plt.ylabel("lp tactic execution (ms, median-of-5)")
    plt.title("lp per-carrier box-LP timing  (Lean v4.31.0-rc1)")
    plt.legend(fontsize=9)
    plt.grid(True, axis="y", alpha=0.3)
    plt.tight_layout()
    out = RESULTS / "multicarrier-bars.png"
    plt.savefig(out, dpi=130); plt.close()
    print("wrote", out)


def plot_ratio(lp, sizes):
    import numpy as np
    others = ["Nat", "Int", "Dyadic", "Real"]
    plt.figure(figsize=(9, 5.5))
    x = np.arange(len(sizes))
    w = 0.2
    for i, c in enumerate(others):
        ys = [lp[c][n] / lp["Rat"][n] for n in sizes]
        plt.bar(x + (i - 1.5) * w, ys, w, color=COLORS[c], label=c)
    plt.axhline(1.0, color="black", linewidth=1, linestyle="--", label="Rat baseline")
    plt.xticks(x, [f"Size{n}" for n in sizes])
    plt.ylabel("lp time relative to Rat  (lower = faster)")
    plt.title("Native computable carriers beat the Rat baseline; Real pays the ofRat bridge")
    plt.legend(fontsize=9)
    plt.grid(True, axis="y", alpha=0.3)
    plt.tight_layout()
    out = RESULTS / "multicarrier-ratio.png"
    plt.savefig(out, dpi=130); plt.close()
    print("wrote", out)


def main():
    lp, lin, sizes = load()
    plot_sweep(lp, lin, sizes)
    plot_bars(lp, sizes)
    plot_ratio(lp, sizes)


if __name__ == "__main__":
    main()
