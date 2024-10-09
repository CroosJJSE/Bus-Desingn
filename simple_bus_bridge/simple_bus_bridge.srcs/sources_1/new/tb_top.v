`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2024 06:59:09 PM
// Design Name: 
// Module Name: tb_top
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


module top_tb();

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
    parameter DEPTH = 4;

    // Testbench Signals
    reg clk1, clk2, reset;
    wire [DATA_WIDTH-1:0] din_master1;
    wire slack_from_slave_bridge;
    wire [DATA_WIDTH-1:0] dout_master1;
    wire [ADDR_WIDTH-1:0] addr_master1;
    wire request_master1;
    wire wr_master1;
    
    reg slave_select1,slave_select2,grant_master1,grant_master2;
    
    wire [7:0] data_in_slave;
    wire [1:0] addr_slave;
    wire wr_en_slave;
    wire [7:0] data_out_slave;
    wire ack_slave;
    
    wire request_master2;
    
    
    // Connecting signals between master_bridge, slave_bridge_with_fifo, and slave
    wire [ADDR_WIDTH-1:0] addr_out_slave_bridge_to_master_bridge;
    wire [7:0] wd_out_slave_bridge_to_master_bridge, rd_in_slave_bridge_to_master_bridge;
    wire [1:0] addr_out_slave_bridge_to_master_bridge;
    wire w_en, r_en, ack_bridge;
    
    // Master1 module instantiation
    master1 #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) master1_inst (
        .clk(clk1),
        .reset(reset),
        .din(din_master1),      // Data input from master_bridge (read data)
        .slack(slack_from_slave_bridge),           // Acknowledge signal to master1
        .grant(grant_master1),           // Grant signal from master1
        .dout(dout_master1),     // Data output to master_bridge (write data)
        .addr(addr_master1),   // Address output to master_bridge
        .request(request_master1),       // Request signal from master1 to master_bridge
        .wr(wr_master1)                  // Write-read command to master_bridge
    );
    
    // Slave Bridge instantiation
    slave_bridge_with_fifo slave_bridge_inst (
        .clk_bus1(clk1),
        .clk_bus2(clk2),
        .reset(reset),
        .slave_select(slave_select1),
        .wr_en(wr_master1),
        .addr_in(addr_master1), // Truncate address for 2-bit slave address
        .wd_in(dout_master1),
        .rd_out(din_master1),
        .ack(slack_from_slave_bridge),
        .addr_out(addr_out_slave_bridge_to_master_bridge),
        .wd_out(wd_out_slave_bridge_to_master_bridge),
        .rd_in(rd_in_slave_bridge_to_master_bridge),
        .w_en(w_en),
        .r_en(r_en),
        .slack(ack_bridge)
    );
    
    // Slave Module instantiation
    slave slave_inst (
        .clk(clk2),
        .reset(reset),
        .data_in(data_in_slave),
        .addr(addr_slave[1:0]),
        .slave_select(slave_select2),
        .wr_en(wr_en_slave),
        .data_out(data_out_slave),
        .ack(ack_slave)
    );

    // Master Bridge instantiation
    master_bridge #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH(DEPTH)
    ) master_bridge_inst (
        .clk1(clk2),
        .reset(reset),
        .din(data_out_slave),            // Data input from slave (read data)
        .slack(ack_slave),               // Acknowledge signal from slave to master_bridge
        .grant(grant_master2),           // Grant signal from arbiter
        .wd_out(data_in_slave),   // Data output from master_bridge to slave_bridge
        .addr_out(addr_slave), // Address output from master_bridge to slave_bridge
        .request(request_master2),       // Request signal from master1
        .wr(wr_en_slave),                 // Write-read command from master1
        
        // Interface for master1
        .clk2(clk1),
        .write_enable(w_en),
        .read_enable(r_en),
        .wd_in(wd_out_slave_bridge_to_master_bridge),
        .rd_out(rd_in_slave_bridge_to_master_bridge),
        .addr_in(addr_out_slave_bridge_to_master_bridge),
        .ack(ack_bridge)
    );

    // Clock generation
    always #5 clk1 = ~clk1; // Clock for master bus
    always #7 clk2 = ~clk2; // Clock for slave bus

    // Testbench stimulus
    initial begin
        // Initialize inputs
        clk1 = 0;
        clk2 = 0;
        reset = 1;
       
        grant_master1 = 0;
        slave_select1 = 0;
        grant_master2 = 0;
        slave_select2 = 0;

        // Apply reset
        #15 reset = 0;
        
        #40 grant_master1 = 1;
        slave_select1 = 1;
        
        #60 grant_master2 = 1;
        slave_select2 = 1;
        
        #18 grant_master2=0;
        slave_select2=0;
        
        #22 grant_master1 = 0;
        slave_select1 = 0;
        
        #50 grant_master1 = 1;
        slave_select1 = 1;
        
        #60 grant_master2 = 1;
        slave_select2 = 1;
        
        #22 grant_master2=0;
        slave_select2=0;
        
        #18 grant_master1 = 0;
        slave_select1 = 0;
        

        // End simulation
        #100 $stop;
    end

endmodule
 
