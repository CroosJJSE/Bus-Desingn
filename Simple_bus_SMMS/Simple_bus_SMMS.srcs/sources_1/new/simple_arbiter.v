`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2024
// Design Name: 
// Module Name: arbiter_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Arbiter to handle two masters with priority for Master 1 using a state machine
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module arbiter_fsm (
    input clk,                // Clock signal
    input reset,              // Reset signal
    input slack1,              // ack from slave to master 1
    input slack2,              // ack from slave to master 2
    input req_master1,        // Request from Master 1
    input req_master2,        // Request from Master 2
    output reg grant_master1, // Grant signal for Master 1
    output reg grant_master2  // Grant signal for Master 2
);

// State encoding
parameter IDLE = 2'b00,
          GRANT_MASTER1 = 2'b01,
          GRANT_MASTER2 = 2'b10;

// State variables
reg [1:0] current_state, next_state;

// State transition logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= IDLE;  // Reset to IDLE state
    end else begin
        current_state <= next_state; // Transition to the next state
    end
end

// Next state logic
always @(*) begin
    // Default grant signals
    grant_master1 = 1'b0;
    grant_master2 = 1'b0;
    
    case (current_state)
        IDLE: begin
            if (req_master1) begin
                next_state = GRANT_MASTER1; // Move to GRANT_MASTER1 state
            end else if (req_master2) begin
                next_state = GRANT_MASTER2; // Move to GRANT_MASTER2 state
            end else begin
                next_state = IDLE;           // Stay in IDLE state
            end
        end
        
        GRANT_MASTER1: begin
            grant_master1 = 1'b1; // Grant access to Master 1
            if (slack1) begin
                next_state = IDLE;   // Go back to IDLE if Master 1 no longer requests
            end else begin
                next_state = GRANT_MASTER1; // Stay in GRANT_MASTER1 if Master 1 still requests
            end
        end
        
        GRANT_MASTER2: begin
            grant_master2 = 1'b1; // Grant access to Master 2
            if (slack2) begin
                next_state = IDLE;   // Go back to IDLE if Master 2 no longer requests
            end else begin
                next_state = GRANT_MASTER2; // Stay in GRANT_MASTER2 if Master 2 still requests
            end
        end
        
        default: begin
            next_state = IDLE; // Default to IDLE state
        end
    endcase
end

endmodule