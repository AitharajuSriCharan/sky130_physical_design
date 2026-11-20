// ==============================================================================
// Testbench: tb_blocking_caveat
// Description: Exposes out-of-order blocking assignment mismatch between RTL
//              simulation and Gate-Level Netlist (GLS) simulation.
// Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
// ==============================================================================

`timescale 1ns / 1ps

module tb_blocking_caveat;

    reg  a;
    reg  b;
    reg  c;
    wire d;

    // Instantiate Unit Under Test (UUT)
    blocking_caveat uut (
        .a(a),
        .b(b),
        .c(c),
        .d(d)
    );

    initial begin
`ifdef GLS
        $dumpfile("sim/blocking_caveat_gls.vcd");
`else
        $dumpfile("sim/blocking_caveat_rtl.vcd");
`endif
        $dumpvars(0, tb_blocking_caveat);

        $display("======================================================================");
`ifdef GLS
        $display("  [GLS MODE] Starting Gate-Level Simulation for blocking_caveat");
`else
        $display("  [RTL MODE] Starting Behavioral RTL Simulation for blocking_caveat");
`endif
        $display("  Monitoring: Time | a | b | c | Output d (Expected: (a|b)&c)");
        $display("======================================================================");
        $monitor("  %4t ns | %b | %b | %b |    %b", $time, a, b, c, d);

        // Phase 1: Initialize
        a = 1'b0; b = 1'b0; c = 1'b0;
        #10;

        // Phase 2: a=1, b=0, c=1 -> Expected d = (1|0)&1 = 1
        // RTL BEHAVIORAL: d evaluates with OLD x=0 -> d stays 0! (MISMATCH!)
        // HARDWARE / GLS: combinational gate evaluates immediately -> d = 1!
        $display("[t=%0t] Stimulus: a=1, b=0, c=1 (Expected d=1; RTL will fail due to stale x!)", $time);
        a = 1'b1; b = 1'b0; c = 1'b1;
        #10;

        // Phase 3: Toggle c=0 -> d = 0
        $display("[t=%0t] Stimulus: c=0 (Both RTL and GLS output d=0)", $time);
        c = 1'b0;
        #10;

        // Phase 4: Toggle c=1 -> d = 1
        $display("[t=%0t] Stimulus: c=1 (Now RTL x is already 1, so d catches up to 1)", $time);
        c = 1'b1;
        #10;

        // Phase 5: Clear all
        a = 1'b0; b = 1'b0; c = 1'b0;
        #10;

        $display("======================================================================");
        $display("  Simulation Complete.");
        $display("======================================================================");
        $finish;
    end

endmodule
