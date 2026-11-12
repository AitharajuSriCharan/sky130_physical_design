# ==============================================================================
# Script: synth_all.tcl
# Project: Sky130 Physical Design - Module 03 (Sequential Logic & Synthesis)
# Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
# ==============================================================================

# Target PDK Liberty file resolution
set default_lib "/home/aravi/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

if {[info exists ::env(SKY130_LIB)]} {
    set lib $::env(SKY130_LIB)
} else {
    set lib $default_lib
}

puts "=== Using Sky130 Liberty Library: $lib ==="

# ------------------------------------------------------------------------------
# 1. Asynchronous Reset Flip-Flop (dff_asyncres)
# ------------------------------------------------------------------------------
puts "\n>>> Synthesizing: dff_asyncres <<<"
yosys read_verilog src/dff_asyncres.v
yosys hierarchy -check -top dff_asyncres
yosys proc
yosys opt
yosys techmap
yosys opt
yosys dfflibmap -liberty $lib
yosys abc -liberty $lib
yosys clean
yosys stat -liberty $lib
yosys write_verilog -noattr netlist/dff_asyncres_synth.v
yosys design -reset

# ------------------------------------------------------------------------------
# 2. Asynchronous Set Flip-Flop (dff_async_set)
# ------------------------------------------------------------------------------
puts "\n>>> Synthesizing: dff_async_set <<<"
yosys read_verilog src/dff_async_set.v
yosys hierarchy -check -top dff_async_set
yosys proc
yosys opt
yosys techmap
yosys opt
yosys dfflibmap -liberty $lib
yosys abc -liberty $lib
yosys clean
yosys stat -liberty $lib
yosys write_verilog -noattr netlist/dff_async_set_synth.v
yosys design -reset

# ------------------------------------------------------------------------------
# 3. Synchronous Reset Flip-Flop (dff_syncres)
# ------------------------------------------------------------------------------
puts "\n>>> Synthesizing: dff_syncres <<<"
yosys read_verilog src/dff_syncres.v
yosys hierarchy -check -top dff_syncres
yosys proc
yosys opt
yosys techmap
yosys opt
yosys dfflibmap -liberty $lib
yosys abc -liberty $lib
yosys clean
yosys stat -liberty $lib
yosys write_verilog -noattr netlist/dff_syncres_synth.v
yosys design -reset

# ------------------------------------------------------------------------------
# 4. Multiple Modules - Hierarchical Synthesis
# ------------------------------------------------------------------------------
puts "\n>>> Synthesizing: multiple_modules (Hierarchical) <<<"
yosys read_verilog src/multiple_modules.v
yosys hierarchy -check -top multiple_modules
yosys proc
yosys opt
yosys techmap
yosys opt
yosys abc -liberty $lib
yosys clean
yosys stat -liberty $lib
yosys write_verilog -noattr netlist/multiple_modules_hier.v
yosys design -reset

# ------------------------------------------------------------------------------
# 5. Multiple Modules - Flattened Synthesis
# ------------------------------------------------------------------------------
puts "\n>>> Synthesizing: multiple_modules (Flattened) <<<"
yosys read_verilog src/multiple_modules.v
yosys hierarchy -check -top multiple_modules
yosys proc
yosys opt
yosys flatten
yosys techmap
yosys opt
yosys abc -liberty $lib
yosys clean
yosys stat -liberty $lib
yosys write_verilog -noattr netlist/multiple_modules_flat.v
yosys design -reset

# ------------------------------------------------------------------------------
# 6. Constant Multipliers (Power of 2 vs Non-Power of 2)
# ------------------------------------------------------------------------------
puts "\n>>> Synthesizing: mult2 (Power of 2 -> Zero Cell Shift) <<<"
yosys read_verilog src/mult2.v
yosys hierarchy -check -top mult2
yosys proc
yosys opt
yosys clean
yosys stat
yosys write_verilog -noattr netlist/mult2_synth.v
yosys design -reset

puts "\n>>> Synthesizing: mult8 (Power of 2 -> Zero Cell Shift) <<<"
yosys read_verilog src/mult8.v
yosys hierarchy -check -top mult8
yosys proc
yosys opt
yosys clean
yosys stat
yosys write_verilog -noattr netlist/mult8_synth.v
yosys design -reset

puts "\n>>> Synthesizing: mult9 (Non-Power of 2 -> Multiplier Logic) <<<"
yosys read_verilog src/mult9.v
yosys hierarchy -check -top mult9
yosys proc
yosys opt
yosys clean
yosys stat
yosys write_verilog -noattr netlist/mult9_synth.v
yosys design -reset

# ------------------------------------------------------------------------------
# 7. Boolean Gating Optimization (opt_check: A ? B : 0 -> AND)
# ------------------------------------------------------------------------------
puts "\n>>> Synthesizing: opt_check <<<"
yosys read_verilog src/opt_check.v
yosys hierarchy -check -top opt_check
yosys proc
yosys opt
yosys techmap
yosys opt
yosys abc -liberty $lib
yosys clean
yosys stat -liberty $lib
yosys write_verilog -noattr netlist/opt_check_synth.v
yosys design -reset

puts "\n=== All Module 03 Designs Synthesized Successfully! ==="
