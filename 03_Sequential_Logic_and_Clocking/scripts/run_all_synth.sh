#!/usr/bin/env bash
# ==============================================================================
# Script: run_all_synth.sh
# Project: Sky130 Physical Design - Module 03 (Sequential Logic & Synthesis)
# Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
# ==============================================================================
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
MODULE_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

cd "$MODULE_DIR"
mkdir -p netlist

echo "======================================================================"
echo "  SkyWater 130nm ASIC Flow: Sequential Synthesis & Technology Mapping"
echo "  Author: Sri Charan Aitharaju (@AitharajuSriCharan)"
echo "======================================================================"

DEFAULT_LIB="/home/aravi/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

if [ -z "$SKY130_LIB" ]; then
    export SKY130_LIB="$DEFAULT_LIB"
fi

if [ ! -f "$SKY130_LIB" ]; then
    echo "ERROR: Sky130 Liberty library not found at: $SKY130_LIB"
    echo "Please set SKY130_LIB environment variable pointing to sky130_fd_sc_hd__tt_025C_1v80.lib"
    exit 1
fi

echo "Using Liberty Library: $SKY130_LIB"
yosys -c scripts/synth_all.tcl

echo ""
echo "======================================================================"
echo "  Synthesis Complete! Generated Gate-Level Netlists:"
echo "======================================================================"
ls -lh netlist/
