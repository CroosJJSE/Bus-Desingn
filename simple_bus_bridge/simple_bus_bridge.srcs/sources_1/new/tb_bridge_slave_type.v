`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2024 12:34:55 AM
// Design Name: 
// Module Name: tb_bridge_slave_type
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

module tb_slave_bridge_with_fifo();

    // Inputs
    reg clk_bus1;
    reg clk_bus2;
    reg reset;
    reg slave_select;
    reg wr_en;
    reg [1:0] addr_in;
    reg [7:0] wd_in;
    reg [7:0] rd_in;
    reg slack;

    // Outputs
    wire [7:0] rd_out;
    wire ack;
    wire [1:0] addr_out;
    wire [7:0] wd_out;
    wire w_en;
    wire r_en;

    // Instantiate the Unit Under Test (UUT)
    slave_bridge_with_fifo uut (
        .clk_bus1(clk_bus1),
        .clk_bus2(clk_bus2),
        .reset(reset),
        .slave_select(slave_select),
        .wr_en(wr_en),
        .addr_in(addr_in),
        .wd_in(wd_in),
        .rd_out(rd_out),
        .ack(ack),
        .addr_out(addr_out),
        .wd_out(wd_out),
        .rd_in(rd_in),
        .slack(slack),
        .w_en(w_en),
        .r_en(r_en)
    );

    // Clock generation
    always #5 clk_bus1 = ~clk_bus1;
    always #7 clk_bus2 = ~clk_bus2; // Different clock frequencies

    initial begin
        // Initialize Inputs
        clk_bus1 = 0;
        clk_bus2 = 0;
        reset = 1;
        slave_select = 0;
        wr_en = 0;
        addr_in = 2'b00;
        wd_in = 8'b0;
        rd_in = 8'b0;
        slack = 0;

        // Apply reset
        #20 reset = 0;
        
        // Test Case 1: Write Operation
        #10 slave_select = 1;
        wr_en = 1;
        addr_in = 2'b01;
        wd_in = 8'hA5; // Writing A5 to address 01
        
        #40 slack = 1; // Simulate ack from the other side
        
        #10 slave_select = 0;
        wr_en = 0;
        slack = 0;
        
        // Test Case 2: Read Operation
        #30 slave_select = 1;
        wr_en = 0; // Read operation
        addr_in = 2'b10;
        #5;
        rd_in = 8'h5A; // Simulate reading 5A from address 10

        #40 slack = 1; // Simulate ack from the other side
        
        #10 slave_select = 0;
        slack = 0;
        
        
        #40;
        
        // Test Case 1: Write Operation
        #10 slave_select = 1;
        wr_en = 1;
        addr_in = 2'b01;
        wd_in = 8'hC5; // Writing A5 to address 01
        
        #40 slack = 1; // Simulate ack from the other side
        
        #10 slave_select = 0;
        wr_en = 0;
        slack = 0;
        
        // Test Case 2: Read Operation
        #30 slave_select = 1;
        wr_en = 0; // Read operation
        addr_in = 2'b10;
        #5;
        rd_in = 8'hB5; // Simulate reading 5A from address 10

        #40 slack = 1; // Simulate ack from the other side
        
        #10 slave_select = 0;
        slack = 0;



        // End simulation
        #100 $finish;
    end

    // Monitor the signals
    initial begin
        $monitor("Time: %0d | Addr_in: %b | Wd_in: %h | Rd_out: %h | Ack: %b | Slave Select: %b | WR_EN: %b", 
                 $time, addr_in, wd_in, rd_out, ack, slave_select, wr_en);
    end

endmodule
