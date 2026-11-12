# ==============================================================================
# Script: synth.tcl
# Project: Sky130 Physical Design - Module 02 (Logic Synthesis & Tech Mapping)
# Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
# ==============================================================================

set default_lib "/home/aravi/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

if {[info exists ::env(SKY130_LIB)]} {
    set lib $::env(SKY130_LIB)
} else {
    set lib $default_lib
}

puts "=== Synthesizing good_mux using Sky130 Liberty: $lib ==="

# Read RTL source (support both relative and local paths)
if {[file exists src/good_mux.v]} {
    yosys read_verilog src/good_mux.v
} else {
    yosys read_verilog ../01_RTL_Design_and_Verification/src/good_mux.v
}

# Check hierarchy and set top module
yosys hierarchy -check -top good_mux

# Translate processes to netlist primitives ($mux)
yosys proc
yosys opt

# Decompose coarse-grain primitives into fine-grain Boolean logic (AIG)
yosys techmap
yosys opt

# Map Boolean network to SkyWater 130nm High-Density library
yosys abc -liberty $lib

# Clean up unused nets and report statistics
yosys clean
yosys stat -liberty $lib

# Export silicon gate-level netlist
yosys write_verilog -noattr netlist/good_mux_synth.v

puts "=== Module 02 (good_mux) Synthesis Complete! Netlist: netlist/good_mux_synth.v ==="
