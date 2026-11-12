// Module: opt_check
// Description: Demonstrates MUX to AND gate logic optimization
// Author: Sri Charan Aitharaju

`timescale 1ns / 1ps

module opt_check (
    input  wire a,
    input  wire b,
    output wire y
);
    // In Verilog, this is written as a 2:1 Multiplexer (if a is 1, y=b, else y=0)
    // But in Boolean Algebra: y = (a & b) | (~a & 0) = (a & b)
    // Yosys will optimize away the MUX and synthesize a simple AND gate!
    assign y = a ? b : 1'b0;

endmodule
