// =============================================================================
// Module: dff_asyncres
// Description: Positive-edge triggered D-Flip-Flop with Active-High Asynchronous Reset
// Technology: SkyWater 130nm CMOS (sky130_fd_sc_hd)
// Author: Sri Charan Aitharaju
// =============================================================================

`timescale 1ns / 1ps

module dff_asyncres (
    input  wire clk,         // Master Clock Input
    input  wire async_reset, // Active-High Asynchronous Reset
    input  wire d,           // Data Input
    output reg  q            // Registered Data Output
);

    // Asynchronous Reset Logic:
    // Triggers on rising edge of clock OR rising edge of async_reset
    always @(posedge clk or posedge async_reset) begin
        if (async_reset) begin
            q <= 1'b0;       // Reset overrides clock immediately
        end else begin
            q <= d;          // Sample D input on clock edge
        end
    end

endmodule
