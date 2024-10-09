`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2024 02:01:13 AM
// Design Name: 
// Module Name: tb_bridge_master_type
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


`timescale 1ns / 1ps

module tb_bridge_master_type();

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 2;
    parameter DEPTH = 4;

    // Inputs
    reg clk1;
    reg clk2;
    reg reset;
    reg [DATA_WIDTH-1:0] din;
    reg slack;
    reg grant;
    reg write_enable;
    reg read_enable;
    reg [DATA_WIDTH-1:0] write_data;
    reg [ADDR_WIDTH-1:0] addr_in;

    // Outputs
    wire [DATA_WIDTH-1:0] dout;
    wire [ADDR_WIDTH-1:0] addr;
    wire request;
    wire wr;
    wire [DATA_WIDTH-1:0] read_data;
    wire ack;

    // Instantiate the Unit Under Test (UUT)
    master_bridge #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .clk1(clk1),
        .clk2(clk2),
        .reset(reset),
        .din(din),
        .slack(slack),
        .grant(grant),
        .wd_out(dout),
        .addr_out(addr),
        .request(request),
        .wr(wr),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .wd_in(write_data),
        .rd_out(read_data),
        .addr_in(addr_in),
        .ack(ack)
    );

    // Clock generation
    always #5 clk1 = ~clk1;
    always #7 clk2 = ~clk2;

    // Test stimulus
    initial begin
        // Initialize Inputs
        clk1 = 0;
        clk2 = 0;
        reset = 1;
        din = 8'b0;
        slack = 0;
        grant = 0;
        write_enable = 0;
        read_enable = 0;
        write_data = 8'b0;
        addr_in = 2'b0;

        // Apply reset
        #20;
        reset = 0;
        #20;

        // Write Operation Test
        
        addr_in = 2'b11;
        write_data = 8'b11110000;
        
        #10 write_enable = 1;
        #30;

        // Grant signal to simulate arbiter granting access
        grant = 1;
        #25;
        slack = 1;
        #5;
        grant = 0; 
        #10 slack = 0;
        
        write_enable = 0;
        #100;

        // Read Operation Test
        addr_in = 2'b10;
        #10 read_enable = 1;
       
        #50; 
        // Grant again for read operation
        grant = 1;
        #15;
        din = 8'hBC;
        slack = 1;
        #10 slack = 0;
        #10;
        grant = 0;
        read_enable = 0;
        #50;

        // Finalize simulation
        $stop;
    end

endmodule

