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

module ss_arbiter_v1 (
    input clk,                      // Clock signal
    input reset,                    // Reset signal
    input slack1,                   // Acknowledge from slave to Master 1
    input slack2,                   // Acknowledge from slave to Master 2
    input split,                    // Split signal from slave (split supported slave)
    input [1:0] req_split_slave,    // Request from split-supported slave (2 bits for 2 masters)
    input req_master1,              // Request from Master 1
    input req_master2,              // Request from Master 2
    output reg grant_master1,       // Grant signal for Master 1
    output reg grant_master2,       // Grant signal for Master 2
    output reg [1:0] active_master  // Currently active master
);

// State encoding
parameter IDLE = 2'b00,
          GRANT_MASTER1 = 2'b01,
          GRANT_MASTER2 = 2'b10;

// State variables
reg [1:0] current_state, next_state;

// Splitted master tracking (current and next values)
reg [1:0] splitted_master, next_splitted_master;
reg [1:0] req_splitted_master, next_req_splitted_master;  // Requested split masters
reg [1:0] split_done;

// Sequential logic: State transition and split-master tracking
always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= IDLE;                         // Reset to IDLE state
        splitted_master <= 2'b00;                      // Reset split master tracking
        req_splitted_master <= 2'b00;                  // Reset split request tracking
        active_master <= 2'b00;                        // No active master
    end else begin
        current_state <= next_state;                   // State transition
        splitted_master <= next_splitted_master;        // Update splitted master
        if (split_done == 2'b01) begin
            req_splitted_master <= 2'b00; 
        end else if (split_done == 2'b10) begin
            req_splitted_master <= 2'b00; 
        end else begin
            req_splitted_master <= next_req_splitted_master;  // Update split request tracking
        end
        
    end
end

// Combinational logic: Next state logic and output generation
always @(*) begin
    // Default grant signals and active master
    grant_master1 = 1'b0;
    grant_master2 = 1'b0;
    active_master = 2'b00;

    // Default next states for split tracking
    next_splitted_master = splitted_master;
    
    case (current_state)
        IDLE: begin
            if (req_master1 && !splitted_master[0]) begin
                next_state = GRANT_MASTER1;  // Prioritize Master 1
            end else if (req_master1 && splitted_master[0] && req_splitted_master[0]) begin
                next_state = GRANT_MASTER1;  // Handle split re-grant for Master 1
                next_splitted_master = 2'b00;
                split_done = 2'b01;
            end else if (req_master2 && splitted_master[1] && req_splitted_master[1]) begin
                next_state = GRANT_MASTER2;  // Handle split re-grant for Master 2
                next_splitted_master = 2'b00;
                split_done = 2'b10;
            end else if (req_master2 && !splitted_master[1]) begin
                next_state = GRANT_MASTER2;  // Move to GRANT_MASTER2 if Master 2 requests
            end else begin
                next_state = IDLE;           // Stay in IDLE if no requests
            end
        end
        
        GRANT_MASTER1: begin
            active_master = 2'b01;
            grant_master1 = 1'b1;            // Grant access to Master 1
            
            if (slack1) begin
                next_state = IDLE;            // Return to IDLE when Master 1 transaction completes
            end else if (split) begin
                next_state = IDLE;            // Return to IDLE if Master 1 splits
                next_splitted_master[0] = 1'b1;    // Mark Master 1 as split
                split_done = 2'b00;
            end else begin
                next_state = GRANT_MASTER1;    // Continue granting Master 1
            end
        end
        
        GRANT_MASTER2: begin
            active_master = 2'b10;
            grant_master2 = 1'b1;            // Grant access to Master 2
            
            if (slack2) begin
                next_state = IDLE;            // Return to IDLE when Master 2 transaction completes            
            end else if (split) begin
                next_state = IDLE;            // Return to IDLE if Master 2 splits
                next_splitted_master[1] = 1'b1;    // Mark Master 2 as split
                split_done = 2'b00;
            end else begin
                next_state = GRANT_MASTER2;    // Continue granting Master 2
            end
        end
        
        default: begin
            next_state = IDLE;  // Default to IDLE state in case of invalid state
        end
    endcase

    // Update next_req_splitted_master based on slave's split request
    if (req_split_slave == 2'b01) begin
        next_req_splitted_master = 2'b01;  // Slave requesting split for Master 1
    end else if (req_split_slave == 2'b10) begin
        next_req_splitted_master = 2'b10;  // Slave requesting split for Master 2
    end else begin
        next_req_splitted_master = req_splitted_master;  // Keep current value if no split request
    end
end

endmodule
