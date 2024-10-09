`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2024 11:06:41 AM
// Design Name: 
// Module Name: decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Decoder module with grant signal.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module decoder2 (
    input [3:0] addr,      // 4-bit address input
    input grant1,           // Grant signal input
    input grant2,
    output reg slave1_sel, // Slave 1 select signal
    output reg slave2_sel, // Slave 2 select signal
    output reg slave_bridge_sel  // Slave 3 select signal
);

always @(*) begin
    // Reset all slave select signals to low
    slave1_sel = 1'b0;
    slave2_sel = 1'b0;
    slave_bridge_sel = 1'b0;

    // Only proceed if grant is high
    if (grant1 || grant2) begin
        // Check the most significant 2 bits of the address
        case (addr[3:2])
            2'b00: slave_bridge_sel = 1'b1;  // Slave bridge select
            2'b01: slave_bridge_sel = 1'b1; // Slave bridge select
            2'b10: slave1_sel = 1'b1;  // Slave 1 select
            2'b11: slave2_sel = 1'b1;  // Slave 2 select    
        endcase
    end
end

endmodule