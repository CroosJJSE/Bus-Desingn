`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2024 11:23:10 AM
// Design Name: 
// Module Name: mux_3to1
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


module mux_3to1 (
    input wire slave1_sel,       // Slave 1 select signal
    input wire slave2_sel,       // Slave 2 select signal
    input wire slave3_sel,       // Slave 3 select signal
    input wire slave1_slack,     // Slave 1 slack signal
    input wire slave2_slack,     // Slave 2 slack signal
    input wire slave3_slack,     // Slave 3 slack signal
    output reg selected_slack    // Output slack signal selected by mux
);

always @(*) begin
    case ({slave1_sel, slave2_sel, slave3_sel})
        3'b100: selected_slack = slave1_slack;  // If slave 1 is selected
        3'b010: selected_slack = slave2_slack;  // If slave 2 is selected
        3'b001: selected_slack = slave3_slack;  // If slave 3 is selected
        default: selected_slack = 1'b0;         // Default case: no slack selected
    endcase
end

endmodule

