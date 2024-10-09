`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2024 06:37:51 AM
// Design Name: 
// Module Name: slave_bridge_with_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: A slave bridge that connects two buses via FIFOs, supporting clock domain 
//              crossing and synchronized data transfer.
// 
// Dependencies: dual_clock_fifo module
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module slave_bridge (
    input clk_bus1,            // Clock master bus
    input clk_bus2,            // Clock slave bus
    output clk_bus1_out,
    input reset,               // Reset input
    input slave_select,        // Slave select
    
    input wr_en,               // Write enable (1 = write, 0 = read)
    input [3:0] addr_in,
    input [7:0] wd_in,
    output wire [7:0] rd_out, 
    output reg ack,            // Acknowledge signal
 
    output wire [3:0] addr_out,       
    output wire [7:0] wd_out,  
    input [7:0] rd_in, 
    output reg w_en,
    output reg r_en,    
    input slack               // Ack from other bus
);

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter  ADDR_WIDTH = 4;
    parameter DEPTH = 4; // FIFO depth

    // States
    localparam IDLE      = 3'b000;
    localparam FETCH     = 3'b001; // Saving addrs and data
    localparam SEND_DATA = 3'b010; // sending to other bus
    localparam WAIT_ACK  = 3'b011; // Waiting for data and/or ack from other bus
    localparam FETCH_DATA = 3'b100;
    localparam SENDBACK_DATA = 3'b101; 
    localparam SENDBACK_ACK = 3'b110; // Sending data and/or ack to master
    
    reg wr_en_addr_fifo;
    reg rd_en_addr_fifo;
    wire full_addr_fifo;
    wire empty_addr_fifo;
    
    reg wr_en_rd_fifo;
    reg rd_en_rd_fifo;
    wire full_rd_fifo;
    wire empty_rd_fifo;
    
    reg wr_en_wd_fifo;
    reg rd_en_wd_fifo;
    wire full_wd_fifo;
    wire empty_wd_fifo;
    
    reg slack_sync;

    // Instantiate dual clock FIFOs
    dual_clock_fifo #(
        .DATA_WIDTH(ADDR_WIDTH),
        .DEPTH(DEPTH)
    ) addr_fifo (
        .wr_clk(clk_bus1),
        .wr_en(wr_en_addr_fifo),
        .wr_data(addr_in),
        .rd_clk(clk_bus2),
        .rd_en(rd_en_addr_fifo),
        .rd_data(addr_out),
        .full(full_addr_fifo),
        .empty(empty_addr_fifo),
        .reset(reset)
    );
     
    dual_clock_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) rd_fifo (
        .wr_clk(clk_bus2),
        .wr_en(wr_en_rd_fifo),
        .wr_data(rd_in),
        .rd_clk(clk_bus1),
        .rd_en(rd_en_rd_fifo),
        .rd_data(rd_out),
        .full(full_rd_fifo),
        .empty(empty_rd_fifo),
        .reset(reset)
    );
    
    dual_clock_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) wd_fifo (
        .wr_clk(clk_bus1),
        .wr_en(wr_en_wd_fifo),
        .wr_data(wd_in),
        .rd_clk(clk_bus2),
        .rd_en(rd_en_wd_fifo),
        .rd_data(wd_out),
        .full(full_wd_fifo),
        .empty(empty_wd_fifo),
        .reset(reset)
    );

    // State register
    reg [2:0] current_state, next_state;
    
    assign clk_bus1_out = clk_bus1;
    
    // State transition logic
    always @(posedge clk_bus1 or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            slack_sync <= 0;

        end else begin
            current_state <= next_state;
        end
    end

    // Combinational logic for next state and outputs
    always @(*) begin
        // Default values
        ack = 0;
        wr_en_addr_fifo = 0;
        wr_en_wd_fifo = 0;
        wr_en_rd_fifo = 0;
        rd_en_addr_fifo = 0;
        rd_en_rd_fifo = 0;
        rd_en_wd_fifo = 0;
        w_en =0;
        r_en =0;

        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (slave_select) begin  // If slave is selected
                    next_state = FETCH;
                end
            end

            FETCH: begin
                if (wr_en) begin // If it's a write instruction
                    wr_en_addr_fifo = 1;
                    wr_en_wd_fifo = 1;
                    next_state = SEND_DATA; // Move to wait for ack
                end else begin   // If it's a read instruction
                    wr_en_addr_fifo = 1;
                    next_state = SEND_DATA;
                end
            end
            
            SEND_DATA: begin
            if (wr_en) begin // Write operation
                    // Send address and data but no ack yet
                    w_en = 1;
                    rd_en_addr_fifo = 1;
                    rd_en_wd_fifo = 1;          
                    next_state = WAIT_ACK;
                end else begin   // Read operation
                    r_en = 1;
                    rd_en_addr_fifo = 1;
                    next_state = WAIT_ACK;

                end
            
            end

            WAIT_ACK: begin
                if (wr_en) begin // Write operation
                    // Send address and data but no ack yet
                    w_en =1;
                    rd_en_addr_fifo = 0;
                    rd_en_wd_fifo = 0;
                    if (slack_sync) begin
                        next_state = SENDBACK_ACK;                     
                    end
                end else begin   // Read operation
                    r_en =1;
                    rd_en_addr_fifo = 0;
                    if (slack_sync) begin
                        next_state = FETCH_DATA;
                    end
                end
            end
            
            FETCH_DATA: begin
                wr_en_rd_fifo = 1; // Write the read data to FIFO
                next_state = SENDBACK_DATA;
            end
            
            SENDBACK_DATA: begin
                rd_en_rd_fifo = 1;
                next_state = SENDBACK_ACK;
            end

            SENDBACK_ACK: begin
                slack_sync = 0;
                if (!wr_en) begin // For read operation
                    ack = 1;      // Acknowledge the read data
                    next_state = IDLE;
                end else begin    // For write operation
                    ack = 1;      // Acknowledge the write operation
                    next_state = IDLE;
                end
            end
        endcase
    end
    
    //metastability ??
    always @(slack) begin
        if(slack) begin
            slack_sync = 1;
        end
    end

endmodule


