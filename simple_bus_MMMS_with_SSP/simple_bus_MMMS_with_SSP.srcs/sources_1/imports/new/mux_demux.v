`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2024 03:16:24 PM
// Design Name: 
// Module Name: mux_demux
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


module mux_demux (
    input wire select1,               // Select signal for input 1
    input wire select2,               // Select signal for input 2
    input wire select3,               // Select signal for input 3
    input wire grant1,                // Grant signal for Output 1
    input wire grant2,                // Grant signal for Output 2
    input wire input1,                // Input 1
    input wire input2,                // Input 2
    input wire input3,                // Input 3
    output reg output1,               // Output 1
    output reg output2                // Output 2
);

    always @(*) begin
        // Initialize outputs to zero
        output1 = 0;
        output2 = 0;

        // Check grants and select inputs based on grants
        if (grant1) begin
            // If grant1 is active, select output1
            if (select1) begin
                output1 = input1;      // Select input 1
            end else if (select2) begin
                output1 = input2;      // Select input 2
            end else if (select3) begin
                output1 = input3;      // Select input 3
            end
        end else if (grant2) begin
            // If grant2 is active, select output2
            if (select1) begin
                output2 = input1;      // Select input 1
            end else if (select2) begin
                output2 = input2;      // Select input 2
            end else if (select3) begin
                output2 = input3;      // Select input 3
            end
        end
    end
endmodule

