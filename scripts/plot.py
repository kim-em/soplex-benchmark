#!/usr/bin/env python3
"""Generate comparison plots from a benchmark CSV.

Input CSV format (no header, one row per benchmark):
    name,lp_ms,linarith_ms

Outputs:
    results/size-sweep.png      — log-log: n vs ms for Size{5..80}, lp and linarith
    results/all-bars.png        — bar chart: all benchmarks, lp vs linarith side by side
    results/ratios.png          — bar chart: linarith/lp ratio per benchmark
"""

import csv
import math
import sys
from pathlib import Path

import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parent.parent
RESULTS = ROOT / "results"
RESULTS.mkdir(exist_ok=True)
CSV_PATH = RESULTS / "median5.csv"


def sort_key(name: str) -> tuple[int, float]:
    # Headline first, then Size sweep numerical, then everything else.
    if name == "Headline":
        return (0, 0)
    if name.startswith("Size"):
        try:
            return (1, int(name[4:]))
        except ValueError:
            return (1, float("inf"))
    return (2, 0)


def load() -> list[tuple[str, float, float]]:
    rows = []
    with CSV_PATH.open() as f:
        for r in csv.reader(f):
            if len(r) >= 3 and r[0]:
                rows.append((r[0], float(r[1]), float(r[2])))
    rows.sort(key=lambda r: sort_key(r[0]))
    return rows


def plot_size_sweep(data):
    sizes = []
    for name, lp, lin in data:
        if name.startswith("Size"):
            try:
                n = int(name[4:])
                sizes.append((n, lp, lin))
            except ValueError:
                pass
    sizes.sort()
    if not sizes:
        return
    ns = [s[0] for s in sizes]
    lps = [s[1] for s in sizes]
    lins = [s[2] for s in sizes]

    fig, ax = plt.subplots(figsize=(6.5, 4.5))
    ax.plot(ns, lps, marker="o", label="lp", linewidth=2)
    ax.plot(ns, lins, marker="s", label="linarith (config := {})", linewidth=2)
    ax.set_xscale("log", base=2)
    ax.set_yscale("log")
    ax.set_xticks(ns)
    ax.set_xticklabels([str(n) for n in ns])
    ax.set_xlabel("Problem size n (number of variables / hypothesis pairs)")
    ax.set_ylabel("Time (ms)")
    ax.set_title("lp vs linarith on the Size{5..80} sweep (log-log)")
    ax.grid(True, which="both", alpha=0.3)
    ax.legend()
    fig.tight_layout()
    fig.savefig(RESULTS / "size-sweep.png", dpi=150)
    plt.close(fig)


def plot_all_bars(data):
    if not data:
        return
    names = [r[0] for r in data]
    lps = [r[1] for r in data]
    lins = [r[2] for r in data]

    fig, ax = plt.subplots(figsize=(9, 4.5))
    x = list(range(len(names)))
    w = 0.4
    ax.bar([i - w / 2 for i in x], lps, width=w, label="lp", color="#1f77b4")
    ax.bar([i + w / 2 for i in x], lins, width=w,
           label="linarith (config := {})", color="#ff7f0e")
    ax.set_yscale("log")
    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=20, ha="right")
    ax.set_ylabel("Time (ms, log scale)")
    ax.set_title("lp vs linarith — all benchmarks (median of 5 runs)")
    ax.grid(True, axis="y", which="both", alpha=0.3)
    ax.legend()
    fig.tight_layout()
    fig.savefig(RESULTS / "all-bars.png", dpi=150)
    plt.close(fig)


def plot_ratios(data):
    if not data:
        return
    names = [r[0] for r in data]
    ratios = [r[2] / r[1] for r in data]

    fig, ax = plt.subplots(figsize=(9, 4))
    bars = ax.bar(names, ratios, color="#2ca02c")
    for bar, r in zip(bars, ratios):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.02,
                f"{r:.2f}×", ha="center", va="bottom", fontsize=9)
    ax.axhline(1.0, color="gray", linestyle="--", linewidth=1)
    ax.set_xticks(range(len(names)))
    ax.set_xticklabels(names, rotation=20, ha="right")
    ax.set_ylabel("Speedup ratio (linarith / lp)")
    ax.set_ylim(0, max(ratios) * 1.15)
    ax.set_title("How much faster is `lp` than `linarith (config := {})`")
    ax.grid(True, axis="y", alpha=0.3)
    fig.tight_layout()
    fig.savefig(RESULTS / "ratios.png", dpi=150)
    plt.close(fig)


def main():
    data = load()
    if not data:
        print(f"No data in {CSV_PATH}", file=sys.stderr)
        sys.exit(1)
    plot_size_sweep(data)
    plot_all_bars(data)
    plot_ratios(data)
    print(f"Wrote plots to {RESULTS}/")


if __name__ == "__main__":
    main()
