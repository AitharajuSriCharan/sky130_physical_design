// ==============================================================================
// Module: bad_mux
// Description: 2:1 Multiplexer with intentional Sensitivity List Omission.
//              Demonstrates Synthesis-Simulation Mismatch where RTL simulation
//              drops output transitions while synthesized hardware functions
//              correctly as a continuous combinational gate.
// Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
// Process: SkyWater 130nm (sky130_fd_sc_hd)
// ==============================================================================

`timescale 1ns / 1ps

module bad_mux (
    input  wire i0,    // Channel 0 data input
    input  wire i1,    // Channel 1 data input
    input  wire sel,   // Channel select signal
    output reg  y      // MUX output (registered in RTL semantics, wire in hardware)
);

    // INTENTIONAL DESIGN FLAW:
    // Only 'sel' is in the sensitivity list.
    // In IEEE 1364 behavioral simulation, this block ONLY wakes up when 'sel' changes.
    // Changes on 'i0' or 'i1' while 'sel' is steady are COMPLETELY IGNORED by the simulator!
    always @(sel) begin
        if (sel)
            y = i1;
        else
            y = i0;
    end

endmodule
