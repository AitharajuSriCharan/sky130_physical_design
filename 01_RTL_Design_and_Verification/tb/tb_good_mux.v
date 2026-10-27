`timescale 1ns / 1ps

module tb_good_mux;

    // Testbench signals
    reg  i0;
    reg  i1;
    reg  sel;
    wire y;

    // Instantiate the Unit Under Test (UUT)
    good_mux uut (
        .i0(i0),
        .i1(i1),
        .sel(sel),
        .y(y)
    );

    // Stimulus process
    initial begin
        // Set up waveform dumping for GTKWave
        $dumpfile("good_mux.vcd");
        $dumpvars(0, tb_good_mux);

        // Initial state at t = 0ns
        i0 = 0; i1 = 0; sel = 0;

        // Apply test vectors with 10ns delays (#10)
        #10 i0 = 1; i1 = 0; sel = 0; // sel=0, i0=1 -> y should be 1
        #10 i0 = 0; i1 = 1; sel = 0; // sel=0, i0=0 -> y should be 0
        #10 i0 = 0; i1 = 1; sel = 1; // sel=1, i1=1 -> y should be 1
        #10 i0 = 1; i1 = 0; sel = 1; // sel=1, i1=0 -> y should be 0
        #10 i0 = 1; i1 = 1; sel = 0; // sel=0, i0=1 -> y should be 1
        #10 i0 = 1; i1 = 1; sel = 1; // sel=1, i1=1 -> y should be 1

        #10 $finish; // End simulation
    end

endmodule
