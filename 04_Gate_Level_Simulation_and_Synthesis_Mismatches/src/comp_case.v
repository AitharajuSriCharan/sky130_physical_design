// ==============================================================================
// Module: comp_case
// Description: Fully specified CASE statement with 'default' branch.
//              Guarantees clean combinational multiplexer synthesis with
//              0 latches inferred.
// Author: Sri Charan Aitharaju (GitHub: @AitharajuSriCharan)
// Process: SkyWater 130nm (sky130_fd_sc_hd)
// ==============================================================================

`timescale 1ns / 1ps

module comp_case (
    input  wire [1:0] sel,
    input  wire       i0,
    input  wire       i1,
    input  wire       i2,
    input  wire       i3,
    output reg        y
);

    // CORRECT SYNTHESIZABLE CODING STYLE:
    // 'default' branch covers 2'b11 and any unhandled X/Z states.
    // Synthesizes cleanly into pure combinational MUX standard cells.
    always @(*) begin
        case (sel)
            2'b00: y = i0;
            2'b01: y = i1;
            2'b10: y = i2;
            default: y = i3;
        endcase
    end

endmodule
