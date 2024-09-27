`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 10:46:54 PM
// Design Name: 
// Module Name: SMMS_bus_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench for the master-slave system with multiplexed data and slack signals
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module SMMS_bus_tb;

    // Parameters
    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 4;

    // Clock and reset signals
    reg clk;
    reg reset;

    // Master-slave signals
    wire [DATA_WIDTH-1:0] master_din;
    wire slack;
    wire grant;
    wire [DATA_WIDTH-1:0] master_dout;
    wire [ADDR_WIDTH-1:0] master_addr;
    wire wr;

    // Decoder output signals for slave selects
    wire slave1_sel;
    wire slave2_sel;
    wire slave3_sel;

    // Slack signals from slaves
    wire slave1_slack;
    wire slave2_slack;
    wire slave3_slack;

    // Data output signals from slaves
    wire [DATA_WIDTH-1:0] slave1_data_out;
    wire [DATA_WIDTH-1:0] slave2_data_out;
    wire [DATA_WIDTH-1:0] slave3_data_out;

    // Instantiate arbiter module to manage two masters (master2 is unused)
    wire req_master1; // Request signal for Master 1
    reg req_master2; // Request signal for Master 2 (not connected)
    
    arbiter_fsm arbiter_inst (
        .clk(clk),
        .reset(reset),
        .slack(slack),
        .req_master1(req_master1),
        .req_master2(req_master2), // This will remain unconnected
        .grant_master1(grant),
        .grant_master2() // Not used
    );

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
        .request(req_master1),
        .wr(wr)
    );

    // Instantiate decoder module to generate slave select signals
    decoder decoder_inst (
        .addr(master_addr),
        .grant(grant),
        .slave1_sel(slave1_sel),
        .slave2_sel(slave2_sel),
        .slave3_sel(slave3_sel)
    );

    // Instantiate three slave modules
    slave slave1_inst (
        .clk(clk),
        .reset(reset),
        .data_in(master_dout),
        .addr(master_addr[1:0]),  // Use lower 2 bits for address inside the slave
        .slave_select(slave1_sel),
        .wr_en(wr),
        .data_out(slave1_data_out),
        .ack(slave1_slack) // Slave 1 slack signal
    );

    slave slave2_inst (
        .clk(clk),
        .reset(reset),
        .data_in(master_dout),
        .addr(master_addr[1:0]),
        .slave_select(slave2_sel),
        .wr_en(wr),
        .data_out(slave2_data_out),
        .ack(slave2_slack) // Slave 2 slack signal
    );

    slave slave3_inst (
        .clk(clk),
        .reset(reset),
        .data_in(master_dout),
        .addr(master_addr[1:0]),
        .slave_select(slave3_sel),
        .wr_en(wr),
        .data_out(slave3_data_out),
        .ack(slave3_slack) // Slave 3 slack signal
    );

    // Instantiate 3-to-1 mux to select the appropriate slack signal
    mux_3to1 mux_slack_inst (
        .slave1_sel(slave1_sel),
        .slave2_sel(slave2_sel),
        .slave3_sel(slave3_sel),
        .slave1_slack(slave1_slack),
        .slave2_slack(slave2_slack),
        .slave3_slack(slave3_slack),
        .selected_slack(slack) // Connect the selected slack to the master's slack signal
    );

    // Instantiate 3-to-1 mux to select the appropriate data from slaves
    mux_3to1_8bit mux_data_inst (
        .slave1_sel(slave1_sel),
        .slave2_sel(slave2_sel),
        .slave3_sel(slave3_sel),
        .slave1_data(slave1_data_out),
        .slave2_data(slave2_data_out),
        .slave3_data(slave3_data_out),
        .selected_data(master_din) // Connect the selected data to the master's din signal
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

        // Release reset after a few clock cycles
        #10 reset = 0;
        
        // Test case 1: Master 1 requests access
        #10; // Grant access

        // Test case 2: Write operation for Slave 1 (addr[3:2] = 00)
        #40;
        
        // Test case 3: Read operation for Slave 2 (addr[3:2] = 01)
        #15;

        // Test case 4: Write operation for Slave 3 (addr[3:2] = 10)
        #80;

        // End the simulation after some delay
        #50;
        $finish;
    end

    // Monitor to observe signal changes
    initial begin
        $monitor("Time: %0t | Master Din: %h | Addr: %b | Write Enable: %b | Slave1 Select: %b | Slave2 Select: %b | Slave3 Select: %b",
                 $time, master_din, master_addr, wr, slave1_sel, slave2_sel, slave3_sel);
    end

endmodule
