`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2024 11:29:10 AM
// Design Name: 
// Module Name: mux_3to1_8bit
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


module mux_3to1_8bit(
    input wire slave1_sel,
    input wire slave2_sel,
    input wire slave3_sel,
    input wire [7:0] slave1_data,
    input wire [7:0] slave2_data,
    input wire [7:0] slave3_data,
    output reg [7:0] selected_data
);
    always @(*) begin
        case ({slave1_sel, slave2_sel, slave3_sel})
            3'b100: selected_data = slave1_data; // Slave 1 is selected
            3'b010: selected_data = slave2_data; // Slave 2 is selected
            3'b001: selected_data = slave3_data; // Slave 3 is selected
            default: selected_data = 8'b0;        // Default case when none is selected
        endcase
    end
endmodule

