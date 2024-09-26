`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 11:13:51 PM
// Design Name: 
// Module Name: tb_slave
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

module tb_slave;

    // Parameters
    reg clk;
    reg reset;
    reg [7:0] data_in;         // Data input for writing to memory
    reg [1:0] addr;            // Address input (2-bit for 4 locations)
    reg slave_select;          // Slave select signal
    reg wr_en;                 // Write enable signal (1 = write, 0 = read)
    wire [7:0] data_out;       // Data output for reading from memory
    wire ack;                  // Acknowledge signal

    // Instantiate the slave module
    slave dut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .addr(addr),
        .slave_select(slave_select),
        .wr_en(wr_en),
        .data_out(data_out),
        .ack(ack)
    );

    // Clock generation
    always #5 clk = ~clk;  // 10ns clock period

    // Testbench initial block
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        data_in = 8'b0;
        addr = 2'b0;
        slave_select = 0;
        wr_en = 0;

        // Apply reset
        #10 reset = 0;

        // Test 1: Write operation
        #10 data_in = 8'hAB;        // Data to write
        addr = 2'b01;               // Address to write to
        wr_en = 1;                  // Enable write
        slave_select = 1;           // Select the slave
        #10 slave_select = 0;       // De-select slave
        #10 wr_en = 0;              // Disable write

        // Test 2: Read operation
        #20 addr = 2'b01;           // Address to read from
        slave_select = 1;           // Select the slave
        wr_en = 0;                  // Enable read
        #10 slave_select = 0;       // De-select slave

        // Test 3: Another Write operation
        #20 data_in = 8'hCD;        // Data to write
        addr = 2'b10;               // Address to write to
        wr_en = 1;                  // Enable write
        slave_select = 1;           // Select the slave
        #10 slave_select = 0;       // De-select slave
        #10 wr_en = 0;              // Disable write

        // Test 4: Another Read operation
        #20 addr = 2'b10;           // Address to read from
        wr_en = 0;                  // Enable read
        slave_select = 1;           // Select the slave
        #10 slave_select = 0;       // De-select slave

        // End simulation
        #50 $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time: %d, Slave Select: %b, Write Enable: %b, Addr: %b, Data In: %h, Data Out: %h, ACK: %b", 
                 $time, slave_select, wr_en, addr, data_in, data_out, ack);
    end

endmodule
