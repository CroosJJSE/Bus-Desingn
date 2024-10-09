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
    input reset,                // Reset input
    output reg ack              // Acknowledgment signal
);

    // 4 x 8-bit memory
    reg [7:0] mem_array [0:3];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all memory locations to zero
            mem_array[0] <= 8'b10100101;
            mem_array[1] <= 8'b10100101;
            mem_array[2] <= 8'b0;
            mem_array[3] <= 8'b0;
            ack <= 0;            // Reset acknowledgment signal
        end else begin
            if (write_enable) begin
                // Write data to memory at the specified address
                mem_array[addr] <= write_data;
                ack <= 1;
            end
            if (read_enable) begin
                // Read data from memory at the specified address
                read_data <= mem_array[addr];
                ack <= 1;
            end
            if (~read_enable && ~write_enable) begin
                ack <= 0;
            end
            if (read_enable && write_enable) begin   // This should not happen simultaneously
                ack <= 0;
            end
        end
    end

endmodule

