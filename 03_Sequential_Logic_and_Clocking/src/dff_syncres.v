// =============================================================================
// Module: dff_syncres
// Description: D-Flip-Flop with Active-High Synchronous Reset
// Technology: SkyWater 130nm CMOS (sky130_fd_sc_hd)
// Author: Sri Charan Aitharaju
// =============================================================================

`timescale 1ns / 1ps

module dff_syncres (
    input  wire clk,        // Master Clock
    input  wire sync_reset, // Active-High Synchronous Reset
    input  wire d,          // Data Input
    output reg  q           // Registered Output
);

    // Synchronous Reset:
    // Notice: ONLY 'clk' is in the sensitivity list.
    // 'sync_reset' is only checked WHEN the clock rises!
    always @(posedge clk) begin
        if (sync_reset) begin
            q <= 1'b0;      // Cleared only on active clock edge
        end else begin
            q <= d;         // Normal data sampling
        end
    end

endmodule
