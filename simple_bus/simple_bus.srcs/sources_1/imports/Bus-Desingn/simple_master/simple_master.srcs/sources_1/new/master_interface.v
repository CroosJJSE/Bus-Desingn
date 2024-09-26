`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 05:46:22 PM
// Design Name: 
// Module Name: master_interface
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

module master_interface(
    input clk,
    input reset,
    input re,            // Read enable from processor
    input wr,            // Write enable from processor
    input grant,         // Grant signal from arbiter or memory
    input slack,         // Acknowledge signal from slave
    output reg ack,      // Acknowledge signal to the processor
    output reg request   // Request signal to arbiter or memory
);

    // State encoding
    localparam IDLE    = 2'b00;
    localparam REQUEST = 2'b01;
    localparam EXECUTE = 2'b10;

    // State registers
    reg [1:0] current_state, next_state;

    // Sequential logic to handle state transitions
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Combinational logic for next state and outputs
    always @(*) begin
        // Default values
        request = 0;
        ack = 0;
        next_state = current_state;

        case (current_state)
            IDLE: begin
                ack = 0;
                // If read or write is asserted, go to REQUEST state
                if (re || wr) begin
                    next_state = REQUEST;
                    request = 1;
                end
            end
            REQUEST: begin
                // Wait for the grant signal
                request = 1;  // Continue requesting until grant is given
                if (grant) begin
                    next_state = EXECUTE;
                end
            end
            EXECUTE: begin
                // Provide ack to processor, complete operation, go back to IDLE
                if (slack)begin
                    ack = 1;
                    next_state = IDLE;
                end else begin
                    ack = 0;
                end 
            end
        endcase
    end

endmodule

