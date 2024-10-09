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
    input clk1,            // Clock master bus
    output clk1_out,
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
    input wire slack               // Ack from other bus
);


    // States
    localparam IDLE      = 3'b000;
    localparam FETCH     = 3'b001; // Saving addrs and data
    localparam SEND_DATA = 3'b010; // sending to other bus
    localparam WAIT_ACK  = 3'b011; // Waiting for data and/or ack from other bus
    localparam FETCH_DATA = 3'b100;
    localparam SENDBACK_DATA = 3'b101; 
    localparam SENDBACK_ACK = 3'b110; // Sending data and/or ack to master
    
    reg [7:0] write_data;
    reg [7:0] read_data;
    reg [3:0] addr;
    
    reg slack_sync;
    
    // State register
    reg [2:0] current_state, next_state;
    
    assign clk1_out = clk1;
    
    assign addr_out = addr;
    assign wd_out = write_data;
    assign rd_out = read_data;
    
    // State transition logic
    always @(posedge clk1 or posedge reset) begin
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
                    addr = addr_in;
                    write_data = wd_in;
                    next_state = SEND_DATA; // Move to wait for ack
                end else begin   // If it's a read instruction
                    addr = addr_in;
                    next_state = SEND_DATA;
                end
            end
            
            SEND_DATA: begin
            if (wr_en) begin // Write operation
                    // Send address and data but no ack yet
                    w_en = 1;           
                end else begin   // Read operation
                    r_en = 1;
                end
    
            
            if (slack_sync) begin
                if (wr_en) begin
                    next_state = SENDBACK_ACK;
                end else begin
                    next_state = SENDBACK_DATA;
                end
                
            end
            
            end 
            
            SENDBACK_DATA: begin
                read_data = rd_in;
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


