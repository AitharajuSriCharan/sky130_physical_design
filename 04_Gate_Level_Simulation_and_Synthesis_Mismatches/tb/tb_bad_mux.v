// ==============================================================================
// Testbench: tb_bad_mux
// Description: Exposes Sensitivity List Omission Mismatch between RTL behavioral
//              simulation and Gate-Level Netlist (GLS) simulation.
// Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
// ==============================================================================

`timescale 1ns / 1ps

module tb_bad_mux;

    reg  i0;
    reg  i1;
    reg  sel;
    wire y;

    // Instantiate Unit Under Test (UUT)
    bad_mux uut (
        .i0(i0),
        .i1(i1),
        .sel(sel),
        .y(y)
    );

    initial begin
`ifdef GLS
        $dumpfile("sim/bad_mux_gls.vcd");
`else
        $dumpfile("sim/bad_mux_rtl.vcd");
`endif
        $dumpvars(0, tb_bad_mux);

        $display("======================================================================");
`ifdef GLS
        $display("  [GLS MODE] Starting Gate-Level Simulation for bad_mux");
`else
        $display("  [RTL MODE] Starting Behavioral RTL Simulation for bad_mux");
`endif
        $display("  Monitoring: Time | sel | i0 | i1 | Output y");
        $display("======================================================================");
        $monitor("  %4t ns |  %b  |  %b |  %b |    %b", $time, sel, i0, i1, y);

        // Phase 1: Initialize inputs
        sel = 1'b0; i0 = 1'b0; i1 = 1'b0;
        #10; // Expected: y = 0

        // Phase 2: Toggle i0 while sel remains 0
        // RTL BEHAVIORAL: sel did NOT change -> block does NOT trigger -> y stays 0 (MISMATCH!)
        // HARDWARE / GLS: combinational MUX passes i0=1 -> y goes to 1 immediately!
        $display("[t=%0t] Stimulus: Changing i0 to 1 with sel=0 (RTL will fail to update!)", $time);
        i0 = 1'b1;
        #10;

        // Phase 3: Toggle sel to 1
        // Here sel changes -> both RTL and GLS trigger -> evaluates i1=0 -> y becomes 0
        $display("[t=%0t] Stimulus: Changing sel to 1 (RTL catches up)", $time);
        sel = 1'b1;
        #10;

        // Phase 4: Toggle i1 while sel remains 1
        // RTL BEHAVIORAL: sel did NOT change -> block does NOT trigger -> y stays 0 (MISMATCH!)
        // HARDWARE / GLS: combinational MUX passes i1=1 -> y goes to 1 immediately!
        $display("[t=%0t] Stimulus: Changing i1 to 1 with sel=1 (RTL will fail to update!)", $time);
        i1 = 1'b1;
        #10;

        // Phase 5: Toggle sel back to 0
        // sel changes -> evaluates i0=1 -> y becomes 1
        $display("[t=%0t] Stimulus: Changing sel to 0 (RTL catches up again)", $time);
        sel = 1'b0;
        #10;

        $display("======================================================================");
        $display("  Simulation Complete.");
        $display("======================================================================");
        $finish;
    end

endmodule
