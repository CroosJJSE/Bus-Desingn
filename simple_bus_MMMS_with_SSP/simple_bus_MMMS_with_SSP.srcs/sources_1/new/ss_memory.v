`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 10:15:15 PM
// Design Name: 
// Module Name: memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Modified memory module with wait functionality for both reading and writing
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ss_memory (
    input [1:0] addr,           // 2-bit address input
    input [7:0] write_data,     // 8-bit data to write
    output reg [7:0] read_data, // 8-bit data output
    input write_enable,         // Write enable
    input read_enable,          // Read enable
    input clk,                  // Clock
    input reset,                // Reset input
    output reg ack,             // Acknowledgment signal
    output reg wait_signal      // Wait signal for address 2 or 3
);
    
    // Parameter for wait cycles (default 12 cycles)
    parameter WAIT_CYCLES = 12;

    // Memory array (4 x 8 bits)
    reg [7:0] memory [3:0];

    // State encoding using parameters
    parameter IDLE        = 3'b000,
              READ        = 3'b001,
              WRITE       = 3'b010,
              WAITING     = 3'b011,
              REQUESTING  = 3'b100;

    // State registers
    reg [2:0] current_state, next_state;

    // Counter for wait cycles
    reg [3:0] wait_counter;

    // Sequential block: State transition and wait counter update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;       // Reset to IDLE state
            wait_counter <= 0;           // Reset wait counter
            ack <= 0;                    // Clear acknowledgment signal
            wait_signal <= 0;            // Clear wait signal
            memory[0] <= 8'b10100101;    // Initialize memory
            memory[1] <= 8'b10100101;
            memory[2] <= 8'b01011010;
            memory[3] <= 8'b10100101;
        end else begin
            current_state <= next_state; // Move to next state

            // Update the wait counter in the WAITING state
            if (current_state == WAITING) begin
                if (wait_counter < WAIT_CYCLES) begin
                    wait_counter <= wait_counter + 1;
                end else begin
                    wait_counter <= 0;  // Reset the counter after the wait period is over
                end
            end else begin
                wait_counter <= 0;      // Reset the counter in other states
            end
        end
    end

    // Combinational block: Next state logic and output generation
    always @(*) begin
        // Default signals
        ack = 0;
        read_data = 8'b0;
        next_state = current_state; // Stay in the same state by default

        case (current_state)
            IDLE: begin
                if (read_enable || write_enable) begin
                    if (addr == 2'b00 || addr == 2'b01) begin
                        // Direct transition to read/write for addr 0 or 1
                        next_state = (read_enable) ? READ : WRITE;
                    end else if (addr == 2'b10 || addr == 2'b11) begin
                        // Transition to WAITING state for addr 2 or 3
                        next_state = WAITING;
                    end
                end
            end

            READ: begin
                ack = 1;                    // Acknowledge read operation
                read_data = memory[addr];    // Read from memory
                next_state = IDLE;           // Return to IDLE after read
            end

            WRITE: begin
                ack = 1;                    // Acknowledge write operation
                memory[addr] = write_data;   // Write to memory
                next_state = IDLE;           // Return to IDLE after write
            end

            WAITING: begin
                wait_signal = 1;             // Indicate waiting state
                if (wait_counter >= WAIT_CYCLES) begin
                    // After wait, transition to REQUESTING state
                    next_state = REQUESTING;
                end else begin
                    next_state = WAITING;    // Stay in WAITING state until counter completes
                end
            end

            REQUESTING: begin
                wait_signal = 0;
                if (read_enable || write_enable) begin
                    // After waiting, proceed with the operation
                    next_state = (read_enable) ? READ : WRITE;
                end else begin
                    next_state = REQUESTING; // Stay in requesting until enabled
                end
            end

            default: begin
                next_state = IDLE;  // Default to IDLE state
            end
        endcase
    end

endmodule
