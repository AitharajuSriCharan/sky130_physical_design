// =============================================================================
// Module: multiple_modules (Hierarchical Design)
// Description: Top-level module instantiating sub_module1 and sub_module2
// Technology: SkyWater 130nm CMOS (sky130_fd_sc_hd)
// Author: Sri Charan Aitharaju
// =============================================================================

`timescale 1ns / 1ps

// Submodule 1: 2-input AND gate
module sub_module1 (
    input  wire a,
    input  wire b,
    output wire y
);
    assign y = a & b;
endmodule

// Submodule 2: 2-input OR gate
module sub_module2 (
    input  wire a,
    input  wire b,
    output wire y
);
    assign y = a | b;
endmodule

// Top-Level Module: Instantiates both submodules
module multiple_modules (
    input  wire a,
    input  wire b,
    input  wire c,
    output wire y
);
    wire net1;

    // Submodule 1 instantiation (net1 = a & b)
    sub_module1 inst1 (
        .a(a),
        .b(b),
        .y(net1)
    );

    // Submodule 2 instantiation (y = net1 | c = (a & b) | c)
    sub_module2 inst2 (
        .a(net1),
        .b(c),
        .y(y)
    );

endmodule
