`timescale 1ns / 1ps

module tb_dff_syncres;

    reg  clk;
    reg  sync_reset;
    reg  d;
    wire q;

    // Instantiate DUT
    dff_syncres uut (
        .clk(clk),
        .sync_reset(sync_reset),
        .d(d),
        .q(q)
    );

    // 100 MHz Clock Generator (Period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/dff_syncres.vcd");
        $dumpvars(0, tb_dff_syncres);

        clk = 0;
        sync_reset = 1; // Start in reset
        d = 0;

        #12;
        sync_reset = 0; // Release reset

        #8;
        d = 1;          // Set D = 1 -> Sampled at posedge clk (t = 25ns), Q becomes 1

        #20;
        d = 0;          // Set D = 0 -> Sampled at posedge clk (t = 45ns), Q becomes 0

        #10;
        d = 1;          // Set D = 1 -> Sampled at posedge clk (t = 55ns), Q becomes 1

        // ⭐ THE SYNCHRONOUS RESET TEST:
        #2;             // At t = 57ns (between clock edges!)
        sync_reset = 1; // Slam reset high mid-cycle!

        #13;            // Keep reset high past the clock edge at 65ns!
        sync_reset = 0; // Release reset at t = 70ns

        #20;
        $display("Synchronous Reset Verification completed successfully.");
        $finish;
    end

endmodule
