// Module: mult2
// Description: Multiplies a 3-bit input by 2
// Author: Sri Charan Aitharaju

`timescale 1ns / 1ps

module mult2 (
    input  wire [2:0] a,
    output wire [3:0] y
);
    // Multiplication by 2:
    assign y = a * 2;
endmodule
