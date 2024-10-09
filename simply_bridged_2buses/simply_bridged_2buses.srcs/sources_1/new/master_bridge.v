`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2024 11:49:55 PM
// Design Name: 
// Module Name: master_bridge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Master bridge module that communicates with memory via FIFOs.
//              It supports both read and write operations with separate clocks
//              for two interfaces. The bridge requests access to memory, performs
//              the operation, and sends feedback to the processor.
// 
// Dependencies: Dual clock FIFOs
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module master_bridge #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter DEPTH = 4 // FIFO depth
) (
    input clk1,                   // Clock for memory interface
    input reset,                  // Reset signal
    input [DATA_WIDTH-1:0] din,   // Data input from memory
    input slack,                  // Acknowledge signal from memory
    input grant,                  // Grant signal from arbiter
    output wire [DATA_WIDTH-1:0] wd_out, // Data output to memory
    output wire [ADDR_WIDTH-1:0] addr_out, // Address output to memory
    output reg request,           // Request signal to arbiter
    output reg wr,                // Write/read command to memory

    // Second interface (signals from master interface)
    input clk2,                   // Clock for the second interface
    output clk1_out,
    input write_enable,           // Write enable signal
    input read_enable,            // Read enable signal
    input [DATA_WIDTH-1:0] wd_in, // Data to be written
    output wire [DATA_WIDTH-1:0] rd_out, // Data read from memory
    input [ADDR_WIDTH-1:0] addr_in,    // Address to access
    output reg ack                // Acknowledge signal back to the processor
);

    // State encoding
    localparam IDLE     = 3'b000;
    localparam FETCH_DATA = 3'b001;
    localparam DELAY1     = 3'b110;
    localparam PUT_DATA = 3'b010;
    localparam REQUEST  = 3'b011;
    localparam EXECUTE  = 3'b100;
    localparam FEEDBACK = 3'b101;

    reg [2:0] current_state, next_state;

    // FIFO control signals
    reg wr_en_addr_fifo, rd_en_addr_fifo;
    wire full_addr_fifo, empty_addr_fifo;
    reg wr_en_wd_fifo, rd_en_wd_fifo;
    wire full_wd_fifo, empty_wd_fifo;
    reg wr_en_rd_fifo, rd_en_rd_fifo;
    wire full_rd_fifo, empty_rd_fifo;


 


    // Dual clock FIFO instances
    dual_clock_fifo #(
        .DATA_WIDTH(ADDR_WIDTH),
        .DEPTH(DEPTH)
    ) addr_fifo (
        .wr_clk(clk2),
        .wr_en(wr_en_addr_fifo),
        .wr_data(addr_in),
        .rd_clk(clk1),
        .rd_en(rd_en_addr_fifo),
        .rd_data(addr_out),
        .full(full_addr_fifo),
        .empty(empty_addr_fifo),
        .reset(reset)
    );

    dual_clock_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) wd_fifo (
        .wr_clk(clk2),
        .wr_en(wr_en_wd_fifo),
        .wr_data(wd_in),
        .rd_clk(clk1),
        .rd_en(rd_en_wd_fifo),
        .rd_data(wd_out),
        .full(full_wd_fifo),
        .empty(empty_wd_fifo),
        .reset(reset)
    );

    dual_clock_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) rd_fifo (
        .wr_clk(clk1),
        .wr_en(wr_en_rd_fifo),
        .wr_data(din),
        .rd_clk(clk2),
        .rd_en(rd_en_rd_fifo),
        .rd_data(rd_out),
        .full(full_rd_fifo),
        .empty(empty_rd_fifo),
        .reset(reset)
    );
    
    assign clk1_out = clk1;

    // Sequential logic for state transitions
    always @(posedge clk1 or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Combinational logic for next state and outputs
    always @(*) begin
        // Default values
        next_state = current_state;
        request = 0;
        wr = 0;
        ack = 0;
        wr_en_addr_fifo = 0;
        rd_en_addr_fifo = 0;
        wr_en_wd_fifo = 0;
        rd_en_wd_fifo = 0;
        wr_en_rd_fifo = 0;
        rd_en_rd_fifo = 0;

        case (current_state)
            IDLE: begin
                if (write_enable || read_enable) begin
                    // Move to REQUEST state and enable FIFO writes
                    next_state = FETCH_DATA;
                end
            end
            
            FETCH_DATA: begin
                wr_en_addr_fifo = 1;
                if (write_enable) begin
                    wr_en_wd_fifo = 1;
                end
                next_state = DELAY1;
            end 
            
            DELAY1: begin
                next_state = PUT_DATA;
            end
            
            PUT_DATA: begin
                rd_en_addr_fifo = 1;
                if (write_enable) begin
                    rd_en_wd_fifo = 1;
                end
                next_state = REQUEST;
                wr = write_enable;  // Set write/read flag
            end

            REQUEST: begin
                // Send request to arbiter and wait for grant signal
                request = 1;
                wr = write_enable;  // Set write/read flag
                if (grant) begin
                    next_state = EXECUTE;
                end
            end

            EXECUTE: begin
                // Execute the read/write operation
                request = 1;
                wr = write_enable;  // Set write/read flag
                if (write_enable) begin
                    if(slack) begin
                        next_state = FEEDBACK ;
                    end
                end else if (read_enable) begin
                    if(slack) begin 
                        wr_en_rd_fifo = 1;
                        next_state = FEEDBACK ;
                    end               
                end    
            end

            FEEDBACK: begin
                // Provide feedback (ack or read data) to the processor
                if (read_enable) begin
                    rd_en_rd_fifo = 1;
                    ack = 1;
                end else if (write_enable) begin
                    ack = 1;
                end
                next_state = IDLE;
            end
        endcase
    end

endmodule

