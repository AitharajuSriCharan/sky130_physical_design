// =============================================================================
// Module: mult8
// Description: Multiplies a 3-bit input by 8 (Power of 2: 2^3)
// Technology: SkyWater 130nm CMOS (sky130_fd_sc_hd)
// Author: Sri Charan Aitharaju
// =============================================================================

`timescale 1ns / 1ps

module mult8 (
    input  wire [2:0] a,
    output wire [5:0] y
);
    // Multiplication by 8 is a shift left by 3 bits: {a, 3'b000}
    // Synthesizes to ZERO gates / ZERO cells!
    assign y = a * 8;

endmodule
