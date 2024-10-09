`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/01/2024 09:44:42 PM
// Design Name: 
// Module Name: dual_clock_fifo
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
// Create Date: 10/01/2024 09:44:42 PM
// Design Name: 
// Module Name: dual_clock_fifo
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
    input wire reset,            // Reset signal for both clock domains
    input wire [DATA_WIDTH-1:0] wr_data, // Data input
    
    input wire rd_clk,           // Read clock
    input wire rd_en,            // Read enable
    output reg [DATA_WIDTH-1:0] rd_data, // Data output
    
    output reg full,            // FIFO full flag
    output reg empty            // FIFO empty flag
);

    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];  // FIFO memory array
    reg [$clog2(DEPTH)-1:0] wr_ptr = 0, rd_ptr = 0;           // Write and read pointers
    reg [$clog2(DEPTH)-1:0] wr_ptr_sync = 0, rd_ptr_sync = 0;
    reg [$clog2(DEPTH)-1:0] next_wr_ptr = 2;

    // Write operation (in the write clock domain)
    always @(posedge wr_clk or posedge reset) begin
        if (reset) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            next_wr_ptr <= 2;
            full <= 0;
            empty <= 1;
        end else if (wr_en && !full) begin
            fifo_mem[wr_ptr] <= wr_data;
            wr_ptr <= wr_ptr + 1;
            next_wr_ptr <= next_wr_ptr + 1;
            if(empty) begin
                empty = 0;
            end
            if(next_wr_ptr == rd_ptr_sync) begin
                full <= 1;
            end else begin
                full <= 0;
            end
            
        end
    end

    // Read operation (in the read clock domain)
    always @(posedge rd_clk or posedge reset) begin
        if (reset) begin
            rd_ptr <= 0;
            rd_data <= 0;
        end else if (rd_en && !empty) begin
            rd_data <= fifo_mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
            if(full) begin
                full = 0;
            end
            if (wr_ptr_sync-1 == rd_ptr) begin
                empty = 1;
            end else begin
                empty = 0;
            end
        end
    end

    // Synchronize pointers across clock domains
    always @(posedge wr_clk or posedge reset) begin
        if (reset) begin
            rd_ptr_sync <= 0;
        end else begin
            rd_ptr_sync <= rd_ptr;
        end
    end

    always @(posedge rd_clk or posedge reset) begin
        if (reset) begin
            wr_ptr_sync <= 0;
        end else begin
            wr_ptr_sync <= wr_ptr;
        end
    end

endmodule


