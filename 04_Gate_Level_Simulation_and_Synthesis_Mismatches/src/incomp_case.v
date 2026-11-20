// ==============================================================================
// Module: incomp_case
// Description: Incomplete CASE statement demonstrating accidental latch inference.
//              Omitting state 2'b11 with no 'default' branch forces the synthesizer
//              to insert a transparent D-Latch to preserve state.
// Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
// Process: SkyWater 130nm (sky130_fd_sc_hd)
// ==============================================================================

`timescale 1ns / 1ps

module incomp_case (
    input  wire [1:0] sel,
    input  wire       i0,
    input  wire       i1,
    input  wire       i2,
    input  wire       i3,
    output reg        y
);

    // INTENTIONAL DESIGN FLAW:
    // Case 2'b11 is missing, and there is no 'default' branch!
    // Infers a transparent D-Latch in synthesis!
    always @(*) begin
        case (sel)
            2'b00: y = i0;
            2'b01: y = i1;
            2'b10: y = i2;
            // 2'b11 omitted!
        endcase
    end

endmodule
