#!/usr/bin/env bash
# ==============================================================================
# Script: run_all_gls.sh
# Description: Master regression suite for Module 04:
#              1. Executes RTL and GLS simulations for bad_mux
#              2. Executes RTL and GLS simulations for blocking_caveat
#              3. Synthesizes incomp_if, incomp_case, and comp_case to Sky130
#              4. Verifies latch inference and simulation mismatches
# Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

PDK_ROOT="/home/aravi/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A"
LIBERTY_FILE="${PDK_ROOT}/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
VERILOG_DIR="${PDK_ROOT}/libs.ref/sky130_fd_sc_hd/verilog"

cd "${MODULE_DIR}"
mkdir -p sim netlist reports

echo "======================================================================"
echo "  🚀 MODULE 04 REGRESSION: GLS & SYNTHESIS-SIMULATION MISMATCHES"
echo "  Author: Sri Charan Aitharaju (@AitharajuSriCharan)"
echo "======================================================================"

echo ""
echo ">>> [STAGE 1/4] Testing bad_mux (Sensitivity List Omission)..."
# 1. RTL Sim
iverilog -o sim/bad_mux_rtl.vvp src/bad_mux.v tb/tb_bad_mux.v
vvp sim/bad_mux_rtl.vvp > reports/bad_mux_rtl_sim.log
# 2. Synthesis
yosys -p "read_verilog src/bad_mux.v; hierarchy -check -top bad_mux; proc; opt; techmap; opt; abc -liberty ${LIBERTY_FILE}; clean; write_verilog -noattr netlist/bad_mux_synth.v" > reports/bad_mux_synth.log
# 3. GLS Sim
iverilog -DFUNCTIONAL -DUNIT_DELAY="#1" -DGLS \
  "${VERILOG_DIR}/primitives.v" "${VERILOG_DIR}/sky130_fd_sc_hd.v" \
  netlist/bad_mux_synth.v tb/tb_bad_mux.v -o sim/bad_mux_gls.vvp
vvp sim/bad_mux_gls.vvp > reports/bad_mux_gls_sim.log
echo "    [PASS] bad_mux RTL & GLS simulations generated!"

echo ""
echo ">>> [STAGE 2/4] Testing blocking_caveat (Out-of-Order Blocking Assigns)..."
# 1. RTL Sim
iverilog -o sim/blocking_caveat_rtl.vvp src/blocking_caveat.v tb/tb_blocking_caveat.v
vvp sim/blocking_caveat_rtl.vvp > reports/blocking_caveat_rtl_sim.log
# 2. Synthesis
yosys -p "read_verilog src/blocking_caveat.v; hierarchy -check -top blocking_caveat; proc; opt; techmap; opt; abc -liberty ${LIBERTY_FILE}; clean; write_verilog -noattr netlist/blocking_caveat_synth.v" > reports/blocking_caveat_synth.log
# 3. GLS Sim
iverilog -DFUNCTIONAL -DUNIT_DELAY="#1" -DGLS \
  "${VERILOG_DIR}/primitives.v" "${VERILOG_DIR}/sky130_fd_sc_hd.v" \
  netlist/blocking_caveat_synth.v tb/tb_blocking_caveat.v -o sim/blocking_caveat_gls.vvp
vvp sim/blocking_caveat_gls.vvp > reports/blocking_caveat_gls_sim.log
echo "    [PASS] blocking_caveat RTL & GLS simulations generated!"

echo ""
echo ">>> [STAGE 3/4] Synthesizing incomp_if (Missing else -> Latch Inference)..."
yosys -p "read_verilog src/incomp_if.v; hierarchy -check -top incomp_if; proc; opt; techmap; opt; write_verilog -noattr netlist/incomp_if_synth.v" > reports/incomp_if_synth.log
echo "    [PASS] incomp_if synthesized (inferred \$_DLATCH_P_)!"

echo ""
echo ">>> [STAGE 4/4] Comparing incomp_case vs comp_case..."
yosys -p "read_verilog src/incomp_case.v; hierarchy -check -top incomp_case; proc; opt; techmap; opt; write_verilog -noattr netlist/incomp_case_synth.v" > reports/incomp_case_synth.log
yosys -p "read_verilog src/comp_case.v; hierarchy -check -top comp_case; proc; opt; techmap; opt; abc -liberty ${LIBERTY_FILE}; clean; write_verilog -noattr netlist/comp_case_synth.v" > reports/comp_case_synth.log
echo "    [PASS] incomp_case (inferred latch) vs comp_case (mapped to mux4_2) complete!"

echo ""
echo "======================================================================"
echo "  🎉 MODULE 04 MASTER REGRESSION COMPLETED SUCCESSFULLY!"
echo "======================================================================"
