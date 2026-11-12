#!/usr/bin/env bash
# ==============================================================================
# Script: run_sim.sh
# Project: Sky130 Physical Design - Module 01 (RTL Design & Verification)
# Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
# ==============================================================================
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
MODULE_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

mkdir -p "$MODULE_DIR/sim"
cd "$MODULE_DIR/sim"

echo "======================================================================"
echo "  SkyWater 130nm ASIC Flow: 2:1 Multiplexer Simulation"
echo "  Author: Sri Charan Aitharaju (@AitharajuSriCharan)"
echo "======================================================================"

iverilog -o good_mux.vvp "$MODULE_DIR/src/good_mux.v" "$MODULE_DIR/tb/tb_good_mux.v"
vvp good_mux.vvp

echo ""
echo "======================================================================"
echo "  [PASS] 2:1 MUX Simulation Passed! VCD dumped to sim/good_mux.vcd"
echo "======================================================================"
