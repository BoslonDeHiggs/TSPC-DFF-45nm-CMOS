#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

# ----------------------------
# Args
# ----------------------------
if len(sys.argv) < 2:
    print("Usage: python plot.py \"Title\" [data_file]")
    sys.exit(1)

Title = sys.argv[1]
data_path = sys.argv[2] if len(sys.argv) >= 3 else "results/TSPCFF_setup_explore.dat"

p = Path(data_path)
if not p.exists():
    print(f"Error: file not found: {data_path}")
    sys.exit(1)

# ----------------------------
# Load (skip header row)
# ----------------------------
# The file has:
#   col0 = islope(ns)
#   col1 = capa(fF)
#   then repeating pairs: (clk_delay(ps), propagation(ns)), possibly ending with a lone clk_delay
raw = np.loadtxt(data_path, skiprows=1)

# Ensure 2D even if there's only one row
if raw.ndim == 1:
    raw = raw.reshape(1, -1)

# ----------------------------
# Plot each row (one curve per islope/capacitor)
# ----------------------------
plt.figure()
for row in raw:
    islope_ns = row[0]
    capa_fF   = row[1]
    pairs = row[2:]

    # Keep complete (clk, prop) pairs only
    n_pairs = pairs.size // 2
    if n_pairs == 0:
        continue
    pairs = pairs[: 2 * n_pairs].reshape(-1, 2)

    clk_ps  = pairs[:, 0]
    prop_ns = pairs[:, 1]

    # Drop NaNs if present
    mask = np.isfinite(clk_ps) & np.isfinite(prop_ns)
    clk_ps  = clk_ps[mask]
    prop_ns = prop_ns[mask]
    if clk_ps.size == 0:
        continue

    # --- change here: total delay = propagation(ns) + clk_delay(ns) ---
    total_ns = prop_ns + (clk_ps / 1000.0)

    label = f"islope={islope_ns:.3f} ns, C={capa_fF:.3f} fF"
    plt.plot(clk_ps, total_ns, marker='o', linewidth=1.5, label=label)

# ----------------------------
# Cosmetics
# ----------------------------
plt.title(Title)
plt.xlabel("Setup time (ps)")
plt.ylabel("Propagation delay + setup time (ns)")
plt.grid(True, which="both", linestyle="--", alpha=0.4)

# Show legend only if any curves exist
handles, labels = plt.gca().get_legend_handles_labels()
if len(handles) > 0:
    plt.legend(loc="best", frameon=True)

plt.tight_layout()
plt.show()
