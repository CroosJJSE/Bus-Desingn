`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 04:44:47 PM
// Design Name: 
// Module Name: tb_simple_processor_ack_signal
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


module tb_simple_processor();

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
    parameter MEM_SIZE = 16;

    // Inputs to the processor
    reg clk;
    reg reset;
    reg [DATA_WIDTH-1:0] din;
    wire [ADDR_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] dout;
    wire write_enable;
    wire read_enable;
    reg ack;

    // External memory (8-bit x 16)
    reg [DATA_WIDTH-1:0] memory [0:MEM_SIZE-1];

    // Instantiate the processor
    simple_processor #(DATA_WIDTH, ADDR_WIDTH) uut (
        .clk(clk),
        .reset(reset),
        .din(din),
        .addr(addr),
        .dout(dout),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .ack(ack)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // Toggle clock every 5 time units
    end

    // Testbench procedure
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        din = 0;
        ack = 0;

        // Initialize memory with some default values
        memory[0] = 8'hAA;
        memory[1] = 8'hBB;
        memory[2] = 8'hCC;
        memory[3] = 8'hDD;
        memory[4] = 8'hEE;
        memory[5] = 8'hFF;
        memory[6] = 8'h11;
        memory[7] = 8'h22;
        memory[8] = 8'h33;
        memory[9] = 8'h44;
        memory[10] = 8'h55;
        memory[11] = 8'h66;
        memory[12] = 8'h77;
        memory[13] = 8'h88;
        memory[14] = 8'h99;
        memory[15] = 8'h00;

        // De-assert reset after some time
        #10 reset = 0;

        // Monitor signals
        $monitor("Time: %d, addr: %h, din: %h, dout: %h, read_enable: %b, write_enable: %b, ack: %b, memory[%h]: %h", 
                 $time, addr, din, dout, read_enable, write_enable, ack, addr, memory[addr]);

        // Run the simulation for a while
        #1000 $finish;
    end

    // Memory behavior with delayed ack signal
    always @(posedge clk) begin
        if (reset) begin
            ack <= 0;
        end else begin
            // Simulate read operation with delayed ack
            if (read_enable && !write_enable) begin
                #2 din <= memory[addr]; // Provide data after a 2-unit delay
                #10 ack <= 1;           // Acknowledge after a delay of 10 time units
                #10 ack <= 0;           // De-assert ack after 10 time units
            end
            // Simulate write operation with delayed ack
            else if (write_enable && !read_enable) begin
                #2 memory[addr] <= dout; // Write data after a 2-unit delay
                #50 ack <= 1;            // Acknowledge after a delay of 10 time units
                #10 ack <= 0;            // De-assert ack after 10 time units
            end
        end
    end

endmodule

