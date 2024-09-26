`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 04:15:03 PM
// Design Name: 
// Module Name: tb_simple_processor
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
        memory[0] = 8'h00;
        memory[1] = 8'h00;
        memory[2] = 8'h00;
        memory[3] = 8'h00;
        memory[4] = 8'h00;
        memory[5] = 8'h00;
        memory[6] = 8'h00;
        memory[7] = 8'h00;
        memory[8] = 8'h00;
        memory[9] = 8'h00;
        memory[10] = 8'h00;
        memory[11] = 8'h00;
        memory[12] = 8'h00;
        memory[13] = 8'h00;
        memory[14] = 8'h00;
        memory[15] = 8'h00;

        // De-assert reset after some time
        #10 reset = 0;

        // Monitor signals
        $monitor("Time: %d, addr: %h, din: %h, dout: %h, read_enable: %b, write_enable: %b, ack: %b, memory[%h]: %h", 
                 $time, addr, din, dout, read_enable, write_enable, ack, addr, memory[addr]);

        // Run the simulation for a while
        #1000 $finish;
    end

    // Memory behavior
    always @(posedge clk) begin
        if (reset) begin
            ack <= 0;
        end else begin
            // Simulate read operation
            if (read_enable && !write_enable) begin
                din <= memory[addr]; // Provide data after 1 unit delay
                ack <= 1;              // Acknowledge the read
            end
            // Simulate write operation
            else if (write_enable && !read_enable) begin
                memory[addr] <= dout; // Write data after 1 unit delay
                ack <= 1;               // Acknowledge the write
            end else begin
                ack <= 0; // No operation
            end
        end
    end

endmodule

