`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 10:46:54 PM
// Design Name: 
// Module Name: slave
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


module master_slave_tb;

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 4;

    // Clock and reset signals
    reg clk;
    reg reset;

    // Master-slave signals
    wire [DATA_WIDTH-1:0] master_din;
    wire slack;
    reg grant;
    wire [DATA_WIDTH-1:0] master_dout;
    wire [ADDR_WIDTH-1:0] master_addr;
    wire request;
    wire wr;

    // Slave signals
    reg slave_select;

    // Instantiate master module
    master #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) master_inst (
        .clk(clk),
        .reset(reset),
        .din(master_din),
        .slack(slack),
        .grant(grant),
        .dout(master_dout),
        .addr(master_addr),
        .request(request),
        .wr(wr)
    );

    // Instantiate slave module
    slave slave_inst (
        .clk(clk),
        .reset(reset),
        .data_in(master_dout),
        .addr(master_addr[1:0]),
        .slave_select(slave_select),
        .wr_en(wr),
        .data_out(master_din),
        .ack(slack)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end
    
    // Stimulus block
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        grant = 0;
        slave_select = 0;

        // Release reset after a few clock cycles
        #10 reset = 0;
        
        
        // Give grant to the first instruction
        #40 grant = 1;
        slave_select = 1;
        
        // Test case 1: Write operation
        #15 grant = 0;
        slave_select = 0;


        // Test case 2: Read operation
        #80 grant = 1;
        slave_select = 1;

        #10;

        // End the simulation after some delay
        #50;
        $finish;
    end

    // Monitor to observe signal changes
    initial begin
        $monitor("Time: %0t | Master Din: %h |  Addr: %b | Write Enable: %b",
                 $time, master_din, master_addr, wr);
    end

endmodule