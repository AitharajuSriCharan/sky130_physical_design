// =============================================================================
// Module: dff_async_set
// Description: D-Flip-Flop with Active-High Asynchronous Set
// Technology: SkyWater 130nm CMOS (sky130_fd_sc_hd)
// Author: Sri Charan Aitharaju
// =============================================================================

`timescale 1ns / 1ps

module dff_async_set (
    input  wire clk,        // Master Clock
    input  wire async_set,  // Active-High Asynchronous Set
    input  wire d,          // Data Input
    output reg  q           // Registered Output
);

    // Wakes up on rising clock edge OR rising edge of async_set
    always @(posedge clk or posedge async_set) begin
        if (async_set) begin
            q <= 1'b1;      // Force to 1 immediately!
        end else begin
            q <= d;         // Normal clock sampling
        end
    end

endmodule
