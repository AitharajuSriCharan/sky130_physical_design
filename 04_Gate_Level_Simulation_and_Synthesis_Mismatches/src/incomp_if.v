// ==============================================================================
// Module: incomp_if
// Description: Incomplete IF statement demonstrating accidental latch inference.
//              Missing 'else' branch forces the synthesis engine to insert a
//              transparent level-sensitive D-Latch ($dlatch / dlxtp_1) to preserve
//              state when i0 is Low.
// Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
// Process: SkyWater 130nm (sky130_fd_sc_hd)
// ==============================================================================

`timescale 1ns / 1ps

module incomp_if (
    input  wire i0,    // Condition / Enable signal
    input  wire i1,    // Data input
    input  wire i2,    // Secondary input
    output reg  y      // Output (infers transparent latch!)
);

    // INTENTIONAL DESIGN FLAW:
    // Missing 'else' branch!
    // When i0 == 0, 'y' has no specified value.
    // Hardware must remember the previous 'y', inferring a transparent D-Latch!
    always @(*) begin
        if (i0)
            y = i1;
        // else y = ??? -> Infers physical latch!
    end

endmodule
