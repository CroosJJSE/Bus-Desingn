`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 05:59:58 PM
// Design Name: 
// Module Name: tb_master_interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_master_interface();

    // Testbench signals
    reg clk;
    reg reset;
    reg re;
    reg we;
    reg grant;
    reg slack;
    wire ack;
    wire request;
    wire wr;

    // Instantiate the master_controller module
    master_interface uut (
        .clk(clk),
        .reset(reset),
        .re(re),
        .we(we),
        .grant(grant),
        .slack(slack),
        .ack(ack),
        .request(request),
        .wr(wr)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns clock period (100 MHz)

    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        re = 0;
        we = 0;
        grant = 0;
        slack = 0;

        // Hold reset for a few cycles
        #20 reset = 0;
        
        // Test Case 1: Read request
        #10 re = 1; // Read request asserted
        #20 grant = 1; // Grant is given after some cycles
        #20 slack = 1; // Slack signal asserted, ack should follow
        #10 re = 0; slack = 0; grant = 0; // Clear the signals
        
        // Test Case 2: Write request
        #20 we = 1; // Write request asserted
        #30 grant = 1; // Grant is given after a few cycles
        #20 slack = 1; // Slack signal asserted, ack should follow
        #10 we = 0; slack = 0; grant = 0; // Clear the signals
        
        // Test Case 3: No grant received
        #20 re = 1; // Read request asserted
        #30 grant = 0; // No grant given
        #50 re = 0; // Clear the signals, no ack should be given

        // Test Case 4: Grant with delayed slack
        #20 we = 1; // Write request asserted
        #20 grant = 1; // Grant given
        #50 slack = 1; // Slack delayed, ack after slack
        #10 we = 0; slack = 0; grant = 0; // Clear signals

        // End simulation
        #50 $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time=%t | reset=%b | re=%b | wr=%b | grant=%b | slack=%b | ack=%b | request=%b", 
                  $time, reset, re, wr, grant, slack, ack, request);
    end

endmodule

