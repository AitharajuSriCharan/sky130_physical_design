#!/usr/bin/env bash
# ==============================================================================
# Script: run_all.sh
# Project: sky130_physical_design (Master ASIC Verification & Synthesis Suite)
# Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
# ==============================================================================
set -e

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$REPO_ROOT"

echo "======================================================================"
echo "  🚀 SkyWater 130nm ASIC Physical Design Flow: Master Regression Suite"
echo "  Author: Sri Charan Aitharaju (@AitharajuSriCharan)"
echo "======================================================================"
echo ""

# 1. Module 01: RTL Simulation
echo ">>> [STAGE 1/4] Running Module 01: RTL Simulation (2:1 MUX)..."
"$REPO_ROOT/01_RTL_Design_and_Verification/scripts/run_sim.sh"
echo ""

# 2. Module 02: Logic Synthesis
echo ">>> [STAGE 2/4] Running Module 02: Logic Synthesis & Technology Mapping..."
"$REPO_ROOT/02_Logic_Synthesis_and_Technology_Mapping/scripts/run_synth.sh"
echo ""

# 3. Module 03: Sequential Logic Simulation
echo ">>> [STAGE 3/4] Running Module 03: Sequential Simulation Suite..."
"$REPO_ROOT/03_Sequential_Logic_and_Clocking/scripts/run_all_sim.sh"
echo ""

# 4. Module 03: Sequential Technology Mapping & Synthesis
echo ">>> [STAGE 4/4] Running Module 03: Sequential Standard-Cell Synthesis..."
"$REPO_ROOT/03_Sequential_Logic_and_Clocking/scripts/run_all_synth.sh"
echo ""

echo "======================================================================"
echo "  🎉 MASTER REGRESSION COMPLETE: ALL STAGES PASSED SUCCESSFULLY!"
echo "======================================================================"
