`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/25/2024 10:22:51 PM
// Design Name: 
// Module Name: slave_interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Updated slave interface to handle wait signal from memory module and state splitting
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ss_slave_interface (
    input clk,                 // Clock input
    input reset,               // Reset input
    input [7:0] data_in,       // Data input for writing to memory
    input [1:0] addr,          // Address input (2-bit address for 4 locations)
    input slave_select,        // Slave select signal
    input wr_en,               // Write enable (1 = write, 0 = read)
    output [7:0] data_out,     // Data output for reading from memory
    output reg ack,            // Acknowledge signal
    output [1:0] mem_addr,     // Address for memory module
    output mem_write_enable,   // Write enable for memory module
    output mem_read_enable,    // Read enable for memory module
    output [7:0] mem_write_data, // Write data to memory module
    input [7:0] mem_read_data,  // Data read from memory module
    input wait_signal,         // Wait signal from memory module
    input [1:0] master,        // 2-bit input to identify the master
    output reg split,              // split request to arbiter
    output reg [1:0] req_split_master, // Output to send the split master signal back
    input slack
);

    // State encoding
    localparam IDLE    = 2'b00;
    localparam SERVING = 2'b01;
    localparam SPLIT   = 2'b10;
    localparam REQ_SPLIT_STATE = 2'b11;

    // State registers
    reg [1:0] current_state, next_state;

    // Register to store the splitted master tag
    reg [1:0] splitted_master = 2'b00;
    

    // State transition logic
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
        ack = 0;
        req_split_master = 2'b00;
        next_state = current_state;
        split = 0;

        case (current_state)
            IDLE: begin
                ack = 0;
                if (slave_select) begin
                    next_state = SERVING;
                end
            end

            SERVING: begin
                if (wait_signal) begin
                    // Move to SPLIT state if wait_signal is asserted
                    splitted_master = master; // Save master tag
                    next_state = SPLIT;
                    split = 1 ;
                end else begin
                    // Normal operation (either read or write)
                    if(slack) begin
                        ack = 1;
                        next_state = IDLE;
                    end
                end
            end

            SPLIT: begin
                if(slave_select) begin
                    split = 1;
                end else begin
                    split = 0;
                end

                if (!wait_signal) begin
                    // After wait is over, move to REQ_SPLIT_STATE
                    next_state = REQ_SPLIT_STATE;
                end
            end

            REQ_SPLIT_STATE: begin
                req_split_master = splitted_master; // Send the saved master tag
                split = 0; // De-assert split signal
                if (slave_select) begin
                    // Once the ack signal is received, move back to SERVING
                    next_state = SERVING;
                    splitted_master = 2'b00;
                end
            end
        endcase
    end

    // Connect memory control signals
    assign mem_addr = addr;
    assign mem_write_enable = wr_en && slave_select;
    assign mem_read_enable = !wr_en && slave_select;
    assign mem_write_data = data_in;
    assign data_out = mem_read_data;

endmodule
