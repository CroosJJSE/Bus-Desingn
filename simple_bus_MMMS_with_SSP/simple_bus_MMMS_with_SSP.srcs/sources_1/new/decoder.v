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

module decoder (
    input [3:0] addr,      // 4-bit address input
    input grant1,           // Grant signal input
    input grant2,
    output reg slave1_sel, // Slave 1 select signal
    output reg slave2_sel, // Slave 2 select signal
    output reg slave3_sel  // Slave 3 select signal
);

always @(*) begin
    // Reset all slave select signals to low
    slave1_sel = 1'b0;
    slave2_sel = 1'b0;
    slave3_sel = 1'b0;

    // Only proceed if grant is high
    if (grant1 || grant2) begin
        // Check the most significant 2 bits of the address
        case (addr[3:2])
            2'b00: slave1_sel = 1'b1;  // Slave 1 select
            2'b01: slave2_sel = 1'b1;  // Slave 2 select
            2'b10: slave3_sel = 1'b1;  // Slave 3 select
            2'b11: begin
                // When addr[3:2] = 11, all slave select signals stay low
                slave1_sel = 1'b0;
                slave2_sel = 1'b0;
                slave3_sel = 1'b0;
            end
        endcase
    end
end

endmodule
