`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 06:15:06 PM
// Design Name: 
// Module Name: master
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

module master #(
    parameter DATA_WIDTH = 8,          // Data bus width (8 bits)
    parameter ADDR_WIDTH = 4,          // Address bus width (4 bits)
    parameter REGFILE_SIZE = 8,        // Number of registers in processor
    parameter INSTR_WIDTH = 10         // Instruction width (10 bits)
) (
    input clk,
    input reset,
    input [DATA_WIDTH-1:0] din,        // Data input from memory
    input slack,                       // Acknowledge signal from memory to master_controller
    input grant,                       // Grant signal from memory to master_controller
    output [DATA_WIDTH-1:0] dout,      // Data output from processor to memory
    output [ADDR_WIDTH-1:0] addr,      // Address output from processor to memory
    output request,                     // Request signal from master_controller to memory
    output wr                           // write-read command to slave
);

    // Signals for connecting the simple_processor and master_controller
    wire ack_proc;                      // Acknowledge signal from master_controller to processor
    wire re_proc;                       // Read enable from processor
    wire we_proc;                       // Write enable from processor

    // Signals between processor and memory
    wire [DATA_WIDTH-1:0] dout_proc;    // Data output from processor to memory
    wire [ADDR_WIDTH-1:0] addr_proc;    // Address output from processor to memory
    wire write_enable_proc;             // Write enable to memory from processor
    wire read_enable_proc;              // Read enable to memory from processor
    wire wr_interface;                  // write-read command from master interface

    // Instantiate the simple_processor module
    simple_processor #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .REGFILE_SIZE(REGFILE_SIZE),
        .INSTR_WIDTH(INSTR_WIDTH)
    ) processor (
        .clk(clk),
        .reset(reset),
        .din(din),                      // Data input from memory
        .addr(addr_proc),                // Address output to memory
        .dout(dout_proc),                // Data output to memory
        .write_enable(we_proc),          // Write enable signal
        .read_enable(re_proc),           // Read enable signal
        .ack(ack_proc)                   // Acknowledge signal from master_controller
    );

    // Instantiate the master_controller module (no parameters required here)
    master_interface interface (
        .clk(clk),
        .reset(reset),
        .re(re_proc),                    // Read enable from processor
        .we(we_proc),                    // Write enable from processor
        .grant(grant),                   // Grant signal from memory
        .slack(slack),                   // Acknowledge signal from memory
        .ack(ack_proc),                  // Acknowledge signal to processor
        .request(request),               // Request signal to memory
        .wr(wr_interface)                // write-read command to slave
    );

    // Output connections
    assign dout = dout_proc;             // Output data from processor to memory
    assign addr = addr_proc;             // Output address from processor to memory
    assign wr   = wr_interface;           // Ouput  write-read command

endmodule

