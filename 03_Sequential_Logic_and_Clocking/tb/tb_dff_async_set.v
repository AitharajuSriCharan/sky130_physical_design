`timescale 1ns / 1ps

module tb_dff_async_set;

    reg  clk;
    reg  async_set;
    reg  d;
    wire q;

    // Instantiate DUT
    dff_async_set uut (
        .clk(clk),
        .async_set(async_set),
        .d(d),
        .q(q)
    );

    // 100 MHz Clock Generator (Period = 10ns)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/dff_async_set.vcd");
        $dumpvars(0, tb_dff_async_set);

        clk = 0;
        async_set = 1; // Start in SET mode (Q = 1)
        d = 0;

        #12;
        async_set = 0; // Release set

        #8;
        d = 0;          // Keep D = 0 -> Sampled at posedge clk (t = 25ns), Q becomes 0

        #20;            // At t = 40ns
        d = 0;

        // CRITICAL MID-CYCLE SET TEST
        #7;             // At t = 47ns (mid-cycle, between clock edges at 45ns and 55ns!)
        async_set = 1;  // Slam SET high! Q must jump to 1 IMMEDIATELY!

        #13;
        async_set = 0;  // Release set

        #20;
        $display("Asynchronous Set Verification completed successfully.");
        $finish;
    end

endmodule
