# User config
set ::env(DESIGN_NAME) picorv32a

# Change if needed
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_NET) $::env(CLOCK_PORT)
set ::env(CLOCK_PERIOD) "24.000"

set ::env(FP_CORE_UTIL) 35
set ::env(PL_TARGET_DENSITY) 0.55

set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
    source $filename
}
