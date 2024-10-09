`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2024 10:57:01 PM
// Design Name: 
// Module Name: bus1
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


module bus1(
    input clk1,                 // Clock input of bus1  
    input reset,                // Reset input
    output clk1_SB,
    input clk2_SB,                 
    output [3:0] addr_SB,
    output r_en_SB,
    output w_en_SB,
    output [7:0] write_data_SB,
    input [7:0] read_data_SB,
    input slack_SB, 
    output clk1_MB,
    input clk2_MB,                 
    input [3:0] addr_MB,
    input r_en_MB,
    input w_en_MB,
    input [7:0] write_data_MB,
    output [7:0] read_data_MB,
    output slack_MB 
);

//other wires and reg's needed
wire [7:0] din_m,dout_m1,dout_m2;
wire slack_m1,grant_m1,request_m1,wr_m1;
wire slack_m2,grant_m2,request_m2,wr_m2;
wire [3:0] addr_m1,addr_m2;

wire [7:0] slave_din,slave1_dout,slave2_dout,slave3_dout;
wire wr,slave1_ack,slave2_ack,slave3_ack;
wire [3:0] addr_slave;

wire slave1_select,slave2_select,slave3_select;


//initialization of modules 
master1 m1(
    .clk(clk1),
    .reset(reset),
    .din(din_m),        // Data input from memory
    .slack(slack_m1),                       // Acknowledge signal from memory to master_controller
    .grant(grant_m1),                       // Grant signal from memory to master_controller
    .dout(dout_m1),      // Data output from processor to memory
    .addr(addr_m1),      // Address output from processor to memory
    .request(request_m1),                     // Request signal from master_controller to memory
    .wr(wr_m1)                           // write-read command to slave
);

master_bridge mbridge1 (
    .clk1(clk1),               // Clock for memory interface
    .reset(reset),                 // Reset signal
    .din(din_m),  // Data input from memory
    .slack(slack_m2),               // Acknowledge signal from memory
    .grant(grant_m2),             // Grant signal from arbiter
    .wd_out(dout_m2), // Data output to memory
    .addr_out(addr_m2), // Address output to memory
    .request(request_m2),      // Request signal to arbiter
    .wr(wr_m2),           // Write/read command to memory

    // Second interface (signals from processor)
    .clk1_out(clk1_MB),
    .clk2(clk2_MB),              // Clock for processor interface
    .write_enable(w_en_MB),     // Write enable signal from processor
    .read_enable(r_en_MB),      // Read enable signal from processor
    .wd_in(write_data_MB), // Data input from processor
    .rd_out(read_data_MB), // Data read from memory
    .addr_in(addr_MB),   // Address input from processor
    .ack(slack_MB)          // Acknowledge signal back to processor
);

slave slave1 (
    .clk(clk1),                 // Clock input
    .reset(reset),               // Reset input
    .data_in(slave_din),       // Data input for writing to memory
    .addr(addr_slave[1:0]),          // Address input (2-bit address for 4 locations)
    .slave_select(slave1_select),        // Slave select signal
    .wr_en(wr),               // Write enable (1 = write, 0 = read)
    .data_out(slave1_dout),     // Data output for reading from memory
    .ack(slave1_ack)                 // Acknowledge signal
);

slave slave2 (
    .clk(clk1),                 // Clock input
    .reset(reset),               // Reset input
    .data_in(slave_din),       // Data input for writing to memory
    .addr(addr_slave[1:0]),          // Address input (2-bit address for 4 locations)
    .slave_select(slave2_select),        // Slave select signal
    .wr_en(wr),               // Write enable (1 = write, 0 = read)
    .data_out(slave2_dout),     // Data output for reading from memory
    .ack(slave2_ack)                 // Acknowledge signal
);

slave_bridge slave_bridge1 (
    .clk_bus1(clk1),         // Clock for master bus
    .clk_bus2(clk2_SB),          // Clock for slave bus
    .clk_bus1_out(clk1_SB),
    .reset(reset),                // Reset input
    .slave_select(slave3_select),                 // Slave select signal
    
    .wr_en(wr),                 // Write enable (1 = write, 0 = read)
    .addr_in(addr_slave),      // Address input (from master side)
    .wd_in(slave_din),      // Data input (from master side)
    .rd_out(slave3_dout), // Data output (to master side)
    .ack(slave3_ack),           // Acknowledge signal
    
    .addr_out(addr_SB), // Address output (to slave side)
    .wd_out(write_data_SB),  // Write data output (to slave side)
    .rd_in(read_data_SB),        // Read data input (from slave side)
    
    .w_en(w_en_SB),   // Write enable to slave
    .r_en(r_en_SB),   // Read enable to slave
    
    .slack(slack_SB)           // Acknowledge signal from slave
);

decoder1 decoder_bus1(
    .addr(addr_slave),      // 4-bit address input
    .grant1(grant_m1),           // Grant signal input
    .grant2(grant_m2),
    .slave1_sel(slave1_select), // Slave 1 select signal
    .slave2_sel(slave2_select), // Slave 2 select signal
    .slave_bridge_sel(slave3_select)  // Slave 3 select signal
);

mux_2to1_addr_data mux_2to1_addr_data_bus1 (
    .grant1(grant_m1),                   // Grant signal for Master 1
    .grant2(grant_m2),                   // Grant signal for Master 2
    .addr1(addr_m1),              // Address from Master 1
    .data1(dout_m1),              // Data from Master 1
    .addr2(addr_m2),              // Address from Master 2
    .data2(dout_m2),              // Data from Master 2
    .wr1(wr_m1),                      // write-read signal from Master 1
    .wr2(wr_m2),                      // write-read signal from Master 2
    .selected_addr(addr_slave),      // Selected address output
    .selected_data(slave_din),      // Selected data output
    .Selected_wr(wr)                        // Selected wr signal   
);

mux_3to1_8bit mux_3to1_8bit_bus1(
    .slave1_sel(slave1_select),
    .slave2_sel(slave2_select),
    .slave3_sel(slave3_select),
    .slave1_data(slave1_dout),
    .slave2_data(slave2_dout),
    .slave3_data(slave3_dout),
    .selected_data(din_m)
);

mux_demux mux_demux_bus1(
    .select1(slave1_select),               // Select signal for input 1
    .select2(slave2_select),               // Select signal for input 2
    .select3(slave3_select),               // Select signal for input 3
    .grant1(grant_m1),                // Grant signal for Output 1
    .grant2(grant_m2),                // Grant signal for Output 2
    .input1(slave1_ack),                // Input 1
    .input2(slave2_ack),                // Input 2
    .input3(slave3_ack),                // Input 3
    .output1(slack_m1),               // Output 1
    .output2(slack_m2)                // Output 2
);

arbiter_fsm arbiter_bus1 (
    .clk(clk1),                // Clock signal
    .reset(reset),              // Reset signal
    .slack1(slack_m1),              // ack from slave to master 1
    .slack2(slack_m2),              // ack from slave to master 2
    .req_master1(request_m1),        // Request from Master 1
    .req_master2(request_m2),        // Request from Master 2
    .grant_master1(grant_m1), // Grant signal for Master 1
    .grant_master2(grant_m2)  // Grant signal for Master 2
);


endmodule
