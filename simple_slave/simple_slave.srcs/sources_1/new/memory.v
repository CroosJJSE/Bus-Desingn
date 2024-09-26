`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 10:15:15 PM
// Design Name: 
// Module Name: memory
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

module memory (
    input [1:0] addr,           // 2-bit address input
    input [7:0] write_data,     // 8-bit data to write
    output reg [7:0] read_data, // 8-bit data output
    input write_enable,         // Write enable
    input read_enable,          // Read enable
    input clk,                  // Clock
    output reg ack                   // Acknoledgment
);

    // 4 x 8-bit memory
    reg [7:0] mem_array [0:3];

    always @(posedge clk) begin
        if (write_enable) begin
            // Write data to memory at the specified address
            mem_array[addr] <= write_data;
            ack = 1;
        end
        if (read_enable) begin
            // Read data from memory at the specified address
            read_data <= mem_array[addr];
            ack = 1;
        end
        if (~read_enable && ~write_enable) begin
            ack = 0;
        end
        if (read_enable && write_enable) begin   //this is not happening
            ack = 0;
        end
    end

endmodule

