// =============================================================================
// Module: mult9
// Description: Multiplies a 3-bit input by 9 (Non-power-of-2: 8 + 1)
// Technology: SkyWater 130nm CMOS (sky130_fd_sc_hd)
// Author: Sri Charan Aitharaju
// =============================================================================

`timescale 1ns / 1ps

module mult9 (
    input  wire [2:0] a,
    output wire [5:0] y
);
    // Multiplication by 9 is: (a * 8) + a = (a << 3) + a
    // Requires an adder (logic gates)!
    assign y = a * 9;

endmodule
