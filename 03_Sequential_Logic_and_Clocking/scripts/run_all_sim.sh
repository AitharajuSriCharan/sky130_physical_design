#!/usr/bin/env bash
# ==============================================================================
# Script: run_all_sim.sh
# Project: Sky130 Physical Design - Module 03 (Sequential Logic & Clocking)
# Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
# ==============================================================================
set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
MODULE_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

cd "$MODULE_DIR"
mkdir -p sim

echo "======================================================================"
echo "  SkyWater 130nm ASIC Flow: Sequential Logic Simulation Suite"
echo "  Author: Sri Charan Aitharaju (@AitharajuSriCharan)"
echo "======================================================================"

TESTS=("dff_asyncres" "dff_async_set" "dff_syncres")
PASS_COUNT=0

for test in "${TESTS[@]}"; do
    echo ""
    echo ">> [SIM] Compiling and running testbench: tb_${test}.v ..."
    iverilog -o "sim/${test}.vvp" "src/${test}.v" "tb/tb_${test}.v"
    vvp "sim/${test}.vvp"
    echo "   [PASS] $test simulation complete -> sim/${test}.vcd"
    PASS_COUNT=$((PASS_COUNT + 1))
done

echo ""
echo "======================================================================"
echo "  Verification Result: $PASS_COUNT/${#TESTS[@]} Testbenches PASSED Successfully!"
echo "======================================================================"
