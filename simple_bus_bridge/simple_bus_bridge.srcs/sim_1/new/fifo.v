`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2024 09:41:47 PM
// Design Name: 
// Module Name: fifo
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


module dual_clock_fifo #(
    parameter DATA_WIDTH = 8,   // Data width
    parameter DEPTH = 4         // Depth of FIFO
)(
    input wire wr_clk,           // Write clock
    input wire wr_en,            // Write enable
    input wire [DATA_WIDTH-1:0] wr_data, // Data input
    
    input wire rd_clk,           // Read clock
    input wire rd_en,            // Read enable
    output wire [DATA_WIDTH-1:0] rd_data, // Data output
    
    output wire full,            // FIFO full flag
    output wire empty            // FIFO empty flag
);

    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];  // FIFO memory array
    reg [3:0] wr_ptr = 0, rd_ptr = 0;           // Write and read pointers
    reg [3:0] wr_ptr_gray = 0, rd_ptr_gray = 0; // Gray code pointers
    reg [3:0] wr_ptr_gray_sync = 0, rd_ptr_gray_sync = 0;

    // Write operation (in the write clock domain)
    always @(posedge wr_clk) begin
        if (wr_en && !full) begin
            fifo_mem[wr_ptr] <= wr_data;
            wr_ptr <= wr_ptr + 1;
        end
        wr_ptr_gray <= (wr_ptr >> 1) ^ wr_ptr;  // Convert write pointer to Gray code
    end

    // Read operation (in the read clock domain)
    always @(posedge rd_clk) begin
        if (rd_en && !empty) begin
            rd_data <= fifo_mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
        rd_ptr_gray <= (rd_ptr >> 1) ^ rd_ptr;  // Convert read pointer to Gray code
    end

    // Synchronize Gray code pointers across clock domains
    always @(posedge wr_clk) rd_ptr_gray_sync <= rd_ptr_gray;
    always @(posedge rd_clk) wr_ptr_gray_sync <= wr_ptr_gray;

    // Full and empty status logic
    assign full = (wr_ptr_gray == {~rd_ptr_gray_sync[3:2], rd_ptr_gray_sync[1:0]});
    assign empty = (wr_ptr_gray_sync == rd_ptr_gray);

endmodule

