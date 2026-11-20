// ==============================================================================
// Module: blocking_caveat
// Description: Combinational logic with out-of-order blocking assignments (=).
//              Demonstrates Synthesis-Simulation Mismatch where the simulator
//              uses stale values of intermediate variables, creating an artificial
//              delay, while the synthesizer collapses the logic into pure combinational
//              gates without delay.
// Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
// Process: SkyWater 130nm (sky130_fd_sc_hd)
// ==============================================================================

`timescale 1ns / 1ps

module blocking_caveat (
    input  wire a,
    input  wire b,
    input  wire c,
    output reg  d
);

    reg x;

    // INTENTIONAL DESIGN FLAW:
    // 'd' is calculated using 'x' BEFORE 'x' is updated with (a | b).
    // In behavioral simulation with blocking assignments (=), 'd' gets the OLD 'x'.
    // In physical synthesis, Yosys collapses this into d = (a | b) & c.
    always @(*) begin
        d = x & c;   // Uses stale value of x in simulation!
        x = a | b;   // x updated after d is already evaluated!
    end

endmodule
