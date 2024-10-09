`timescale 1ps / 1ps

module tb_top_level;

    // Inputs for the top module
    reg clk;
    reg reset;
    reg start_M1;
    reg start_M2;

    // Clock generation (50 MHz)
    always #10 clk = ~clk;  // Toggle clock every 10ns (50 MHz)

    // Instantiate the top module
    top dut (
        .clk(clk),
        .reset(reset),
        .start_M1(start_M1),
        .start_M2(start_M2)
    );

    // Simulation initialization
    initial begin
        // Initial states
        clk = 0;
        reset = 1;
        start_M1 = 0;
        start_M2 = 0;
        
        // Apply reset for the first 100 ns
        #20 reset = 0;  // Release reset

        // Start Master 1's request process
        #30 start_M1 = 1;
        #20 start_M1 = 0;

        // Wait for some time and then start Master 2's request process
        #100 start_M2 = 1;
        #20 start_M2 = 0;

        // Observe the behavior for another 300 ns
        #300;

        // Finish the simulation
        $finish;
    end

    // Monitor important signals for debugging
    initial begin
        $monitor("Time: %0dns, start_M1: %b, start_M2: %b, M1_request: %b, M2_request: %b, M1_grant: %b, M2_grant: %b, Data Bus: %h, Data Valid: %b",
                 $time, start_M1, start_M2, dut.M1_request, dut.M2_request, dut.M1_grant, dut.M2_grant, dut.data_bus, dut.data_valid_out);
    end

    // Waveform dump (optional)
    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
    end

endmodule
