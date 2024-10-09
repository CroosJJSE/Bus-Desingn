`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2024 12:35:19 AM
// Design Name: 
// Module Name: slave_bridge
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


module slave_bridge_interface(
    input clk,                 // Clock input
    input reset,               // Reset input
    input [7:0] data_in,       // Data input for writing to memory
    input [1:0] addr,          // Address input (2-bit address for 4 locations)
    input slave_select,        // Slave select signal
    input wr_en,               // Write enable (1 = write, 0 = idle
    output reg ack,            // Acknowledge signal
    output [1:0] mem_addr,     // Address for memory module
    output mem_write_enable,   // Write enable for memory module
    output mem_read_enable,    // Read enable for memory module
    output [7:0] mem_write_data, // Write data to memory module
    input [7:0] mem_read_data,  // Data read from memory module
    input slack                // ack from slave(memomry module)
);

endmodule
