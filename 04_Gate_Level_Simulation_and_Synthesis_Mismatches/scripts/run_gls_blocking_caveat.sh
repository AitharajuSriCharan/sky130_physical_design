#!/usr/bin/env bash
# ==============================================================================
# Script: run_gls_blocking_caveat.sh
# Description: Compiles and runs Gate-Level Simulation (GLS) for blocking_caveat
#              using SkyWater 130nm standard cell models.
# Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

PDK_ROOT="/home/aravi/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A"
VERILOG_DIR="${PDK_ROOT}/libs.ref/sky130_fd_sc_hd/verilog"

cd "${MODULE_DIR}"

mkdir -p sim

echo "======================================================================"
echo "  [GLS] Compiling blocking_caveat with SkyWater 130nm Standard Cells..."
echo "======================================================================"

iverilog -DFUNCTIONAL -DUNIT_DELAY="#1" -DGLS \
  "${VERILOG_DIR}/primitives.v" \
  "${VERILOG_DIR}/sky130_fd_sc_hd.v" \
  netlist/blocking_caveat_synth.v \
  tb/tb_blocking_caveat.v \
  -o sim/blocking_caveat_gls.vvp

echo "======================================================================"
echo "  [GLS] Executing Gate-Level Simulation Model..."
echo "======================================================================"

vvp sim/blocking_caveat_gls.vvp

echo "======================================================================"
echo "  [GLS] GLS Completed! VCD dumped to sim/blocking_caveat_gls.vcd"
echo "======================================================================"
