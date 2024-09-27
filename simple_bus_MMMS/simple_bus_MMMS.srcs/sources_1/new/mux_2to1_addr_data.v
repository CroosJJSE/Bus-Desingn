`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2024 03:10:12 PM
// Design Name: 
// Module Name: mux_2to1_addr_data
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


module mux_2to1_addr_data (
    input wire grant1,                   // Grant signal for Master 1
    input wire grant2,                   // Grant signal for Master 2
    input wire [3:0] addr1,              // Address from Master 1
    input wire [7:0] data1,              // Data from Master 1
    input wire [3:0] addr2,              // Address from Master 2
    input wire [7:0] data2,              // Data from Master 2
    input wire wr1,                      // write-read signal from Master 1
    input wire wr2,                      // write-read signal from Master 2
    output reg [3:0] selected_addr,      // Selected address output
    output reg [7:0] selected_data,      // Selected data output
    output reg Selected_wr                        // Selected wr signal   
);
    always @(*) begin
        if (grant1) begin
            selected_addr = addr1;       // Select address from Master 1
            selected_data = data1;       // Select data from Master 1
            Selected_wr   = wr1;         // Select wr from Master 1
            
        end else if (grant2) begin
            selected_addr = addr2;       // Select address from Master 2
            selected_data = data2;       // Select data from Master 2
            Selected_wr   = wr2;         // Select wr from Master 2
        end else begin
            selected_addr = addr1;       // Default to address from Master 1
            selected_data = data1;       // Default to data from Master 1
            Selected_wr   = wr1;         // Select wr from Master 1
        end
    end
endmodule
