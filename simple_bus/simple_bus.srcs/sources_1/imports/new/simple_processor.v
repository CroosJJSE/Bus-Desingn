`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ENTC_BME
// Engineer: Marasinghe M.M.H.N.B.
// 
// Create Date: 09/25/2024 03:10:36 PM
// Design Name: Simple_bus
// Module Name: simple_processor
// Project Name: Bus_Design
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


module simple_processor #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter REGFILE_SIZE = 8,
    parameter INSTR_WIDTH = 10
) (
    input clk,
    input reset,
    input [DATA_WIDTH-1:0] din,       // Data input from memory
    output reg [ADDR_WIDTH-1:0] addr, // Address output to memory
    output reg [DATA_WIDTH-1:0] dout, // Data output to memory
    output reg write_enable,          // Write enable to memory
    output reg read_enable,           // Read enable to memory
    input ack                         // Acknowledge from memory
);

    // Parameters for opcodes
    parameter OP_IDLE  = 2'b00;
    parameter OP_READ  = 2'b01;
    parameter OP_WRITE = 2'b10;

    // Register file
    reg [DATA_WIDTH-1:0] regfile [0:REGFILE_SIZE-1];

    // Instruction memory, 8 instructions
    reg [INSTR_WIDTH-1:0] instr_mem [0:7];

    // Instruction fields
    reg [1:0] opcode;
    reg [3:0] mem_addr;
    reg [3:0] reg_addr;

    // State variables
    reg [2:0] pc; // Program counter
    reg [DATA_WIDTH-1:0] temp_reg; // Temporary register for data

    // Processor states
    reg [1:0] state;
    parameter IDLE = 2'b00;
    parameter FETCH = 2'b01;
    parameter EXECUTE = 2'b10;
    parameter WAIT_ACK = 2'b11;

    // Initialize register file and instruction memory
    initial begin
        // Initialize regfile with values 1 to 8
        regfile[0] = 8'd1;
        regfile[1] = 8'd2;
        regfile[2] = 8'd3;
        regfile[3] = 8'd4;
        regfile[4] = 8'd5;
        regfile[5] = 8'd6;
        regfile[6] = 8'd7;
        regfile[7] = 8'd8;

        // Initialize instruction memory (example instructions)
        instr_mem[0] = {OP_READ, 4'b0001, 4'b0000};   // Read from memory address 1 to regfile[0]
        instr_mem[1] = {OP_WRITE, 4'b0010, 4'b0001};  // Write regfile[1] to memory address 2
        instr_mem[2] = {OP_READ, 4'b0011, 4'b0010};   // Read from memory address 3 to regfile[2]
        instr_mem[3] = {OP_IDLE, 4'b0000, 4'b0000};   // Idle
        instr_mem[4] = {OP_WRITE, 4'b0100, 4'b0011};  // Write regfile[3] to memory address 4
        instr_mem[5] = {OP_READ, 4'b0101, 4'b0100};   // Read from memory address 5 to regfile[4]
        instr_mem[6] = {OP_WRITE, 4'b0110, 4'b0101};  // Write regfile[5] to memory address 6
        instr_mem[7] = {OP_IDLE, 4'b0000, 4'b0000};   // Idle

        // Initialize state
        pc = 0;
        state = IDLE;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            state <= IDLE;
            write_enable <= 0;
            read_enable <= 0;
            addr <= 0;
            dout <= 0;
        end else begin
            case (state)
                IDLE: begin
                    state <= FETCH;
                end

                FETCH: begin
                    // Fetch instruction from instruction memory              
                    {opcode, mem_addr, reg_addr} <= instr_mem[pc];
                    state <= EXECUTE;
                end

                EXECUTE: begin
                    case (opcode)
                        OP_IDLE: begin
                            // No operation
                            pc <= (pc == 7) ? 0 : pc + 1; // Loop back PC to 0 after reaching 7
                            state <= IDLE;
                        end

                        OP_READ: begin
                            // Set memory address and enable read
                            addr <= mem_addr;
                            read_enable <= 1;
                            write_enable <= 0;
                            state <= WAIT_ACK;
                        end

                        OP_WRITE: begin
                            // Set memory address, write data from regfile, and enable write
                            addr <= mem_addr;
                            dout <= regfile[reg_addr];
                            write_enable <= 1;
                            read_enable <= 0;
                            state <= WAIT_ACK;
                        end
                    endcase
                end

                WAIT_ACK: begin
                    if (ack) begin
                        // Communication finished, process next instruction
                        if (opcode == OP_READ) begin
                            regfile[reg_addr] <= din; // Store read data in regfile
                        end
                        write_enable <= 0;
                        read_enable <= 0;
                        pc <= (pc == 7) ? 0 : pc + 1; // Loop back PC to 0 after reaching 7
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
