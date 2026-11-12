// =============================================================================
// Testbench: tb_dff_asyncres
// Description: Verification bench for Asynchronous Reset D-Flip-Flop
// Author: Sri Charan Aitharaju
// =============================================================================

`timescale 1ns / 1ps

module tb_dff_asyncres;

    reg  clk;
    reg  async_reset;
    reg  d;
    wire q;

    // Instantiate DUT (Device Under Test)
    dff_asyncres uut (
        .clk(clk),
        .async_reset(async_reset),
        .d(d),
        .q(q)
    );

    // 100 MHz Clock Generator: Period = 10ns (Toggles every 5ns)
    always #5 clk = ~clk;

    initial begin
        // Configure VCD dump for waveform visualization in GTKWave
        $dumpfile("sim/dff_asyncres.vcd");
        $dumpvars(0, tb_dff_asyncres);

        // --- Step 1: Initial Power-on State ---
        clk = 0;
        async_reset = 1; // Start in reset
        d = 0;

        // --- Step 2: Release Reset ---
        #12;             // Hold reset for 12ns
        async_reset = 0; // Release reset at t = 12ns

        // --- Step 3: Normal Clocking ---
        #8;              // At t = 20ns
        d = 1;           // Captured at posedge clk (t = 25ns) -> Q becomes 1

        #20;             // At t = 40ns
        d = 0;           // Captured at posedge clk (t = 45ns) -> Q becomes 0

        #10;             // At t = 50ns
        d = 1;           // Captured at posedge clk (t = 55ns) -> Q becomes 1

        // --- Step 4: Mid-Cycle Async Reset Stress Test ---
        #2;              // At t = 57ns (between clock edges!)
        async_reset = 1; // Assert reset asynchronously

        #13;             // Hold reset high until t = 70ns
        async_reset = 0; // Release reset

        #20;             // Run until t = 90ns
        $display("Verification completed successfully.");
        $finish;
    end

endmodule
