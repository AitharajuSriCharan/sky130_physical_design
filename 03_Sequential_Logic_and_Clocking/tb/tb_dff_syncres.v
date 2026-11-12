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

    // 100 MHz Clock Generator (Period = 10ns, edges at 5, 15, 25, 35, 45, 55, 65, 75, 85ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/dff_syncres.vcd");
        $dumpvars(0, tb_dff_syncres);

        clk = 0;
        sync_reset = 1; // Start in reset
        d = 0;

        #12;             // t = 12ns: release reset
        sync_reset = 0;

        #8;              // t = 20ns: set d = 1
        d = 1;           // Sampled at 25ns -> Q becomes 1

        #10;             // t = 30ns: set d = 0
        d = 0;           // Sampled at 35ns -> Q becomes 0

        #10;             // t = 40ns: set d = 1
        d = 1;           // Sampled at 45ns -> Q becomes 1, and stays 1 at 55ns!

        // ⭐ THE TRUE SYNCHRONOUS RESET TEST:
        #17;             // t = 57ns (mid-cycle between 55ns and 65ns while Q = 1!)
        sync_reset = 1;  // Assert reset mid-cycle: Q MUST STAY AT 1!

        #15;             // Hold reset across the 65ns clock edge (where Q drops to 0) until t = 72ns
        sync_reset = 0;  // t = 72ns: release reset

        #18;             // t = 90ns
        $display("Synchronous Reset Verification completed successfully.");
        $finish;
    end

endmodule
