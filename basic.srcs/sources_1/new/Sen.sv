`timescale 1ns/1ps 

module master(
    input logic CLK, // Clock signal
    input logic RSTN, // Reset signal (active low)
    output logic M_DVALID, // Data valid signal
    output logic M_BSY, // Busy signal
    output logic [7:0] M_DOUT, // Data output
    input logic [7:0] M_DIN, // Data input
    input logic [15:0] M_ADDR, // Address input
    input logic M_RW, // Read/Write control signal
    input logic M_EXECUTE, // Execute command signal
    input logic M_HOLD, // Hold signal
    output logic A_ADD, // Address add signal
    input logic B_READY, // Ready signal from bus
    output logic B_UTIL, // Bus utilization signal
    input logic B_ACK, // Acknowledge signal from bus
    output logic B_RW, // Bus Read/Write control signal
    output logic B_REQ, // Bus request signal
    output logic B_DONE, // Bus done signal
    input logic B_GRANT, // Bus grant signal
    input logic B_BUS_IN, // Bus input data
    output logic B_BUS_OUT // Bus output data
);

    // State definitions
    typedef enum logic [2:0] {
        IDLE, ADDRESS, ACKNAR, WRITE, ACKNWR, READ, HOLD
    } state_t;

    state_t state, add_state, ackad_state, ackwr_state, rd_state; // State variables

    // Parameters
    localparam WIDTH = 4; // Width parameter for counters

    // Internal signals
    logic rst, incr; // Reset and increment signals for the first counter
    logic [WIDTH-1:0] count; // Counter value for the first counter
    logic rst1, incr1; // Reset and increment signals for the second counter
    logic [WIDTH-1:0] count1; // Counter value for the second counter
    reg [15:0] REG_ADDRESS; // Register to store address
    reg [7:0] REG_DATAIN; // Register to store input data
    reg [7:0] REG_DATAOUT; // Register to store output data
    logic Index_RD; // Index for read operation

    // Counter instances
    counter #(.WIDTH(WIDTH)) counter (
        .rst(rst), 
        .CLK(CLK), 
        .incr(incr),
        .count(count)
    );

    counter #(.WIDTH(WIDTH)) counter1 (
        .rst(rst1), 
        .CLK(CLK), 
        .incr(incr1),
        .count(count1)
    );

    // Assignments
    assign M_DOUT = REG_DATAOUT; // Assign output data to register value
    assign Index_RD = 4'd7 - count; // Calculate read index

    // Combinational logic
    always_comb begin
        B_REQ = (M_HOLD) ? 1'b1 : 1'b0; // Set bus request based on hold signal
        M_BSY = (B_GRANT & M_HOLD) ? 1'b1 : 1'b0; // Set busy signal based on grant and hold signals
        unique case (M_RW)
            1'b0: ackad_state = (B_ACK) ? READ : ADDRESS; // Set state based on acknowledge signal for read
            1'b1: ackad_state = (B_ACK) ? WRITE : ADDRESS; // Set state based on acknowledge signal for write
        endcase
        add_state = (B_GRANT) ? ACKNAR : IDLE; // Set add state based on grant signal
        ackwr_state = (B_ACK) ? IDLE : WRITE; // Set write acknowledge state based on acknowledge signal
        rd_state = (B_GRANT) ? READ : HOLD; // Set read state based on grant signal
        B_RW = M_RW; // Assign bus read/write control signal
    end

    // Sequential logic
    always_ff @(posedge CLK or negedge RSTN) begin
        if (!RSTN) begin
            state <= IDLE; // Set initial state to IDLE
            rst <= 1'b1; // Set reset signal
            incr <= 1'b0; // Clear increment signal
            rst1 <= 1'b1; // Set reset signal for second counter
            incr1 <= 1'b0; // Clear increment signal for second counter
            B_UTIL <= 1'b0; // Clear bus utilization signal
            REG_ADDRESS <= 16'd0; // Clear address register
            REG_DATAIN <= 8'd0; // Clear input data register
            REG_DATAOUT <= 8'd0; // Clear output data register
            B_BUS_OUT <= 1'b0; // Clear bus output signal
            A_ADD <= 1'b0; // Clear address add signal
            B_DONE <= 1'b0; // Clear bus done signal
            M_DVALID <= 1'b0; // Clear data valid signal
        end else begin
            B_UTIL <= 1'b0; // Clear bus utilization signal
            incr <= (M_EXECUTE & B_GRANT) ? 1'b1 : 1'b0; // Set increment signal based on execute and grant signals
            A_ADD <= 1'b0; // Clear address add signal
            REG_ADDRESS <= M_ADDR; // Load address register
            REG_DATAIN <= M_DIN; // Load input data register
            B_BUS_OUT <= 1'b0; // Clear bus output signal
            M_DVALID <= M_DVALID; // Maintain data valid signal
            rst1 <= 1'b1; // Set reset signal for second counter
            incr1 <= 1'b0; // Clear increment signal for second counter

            unique case (state)
                IDLE: begin
                    state <= (M_EXECUTE & B_GRANT) ? ADDRESS : IDLE; // Transition to ADDRESS state if execute and grant signals are set
                    rst <= 1'b0; // Clear reset signal
                    B_DONE <= (M_EXECUTE) ? 1'b0 : B_DONE; // Clear bus done signal if execute signal is set
                end
                ADDRESS: begin
                    if (M_EXECUTE & B_GRANT & B_READY) incr <= 1'b1; // Set increment signal if execute, grant, and ready signals are set
                    else if (M_EXECUTE & B_GRANT & count < 1) incr <= 1'b1; // Set increment signal if execute and grant signals are set and count is less than 1
                    else incr <= 1'b0; // Clear increment signal
                    B_UTIL <= (M_EXECUTE & B_GRANT) ? 1'b1 : 1'b0; // Set bus utilization signal if execute and grant signals are set
                    B_BUS_OUT <= (count == 2 & ~B_READY) ? 1'd0 : REG_ADDRESS[count]; // Set bus output signal based on count and ready signal
                    state <= (count != 15 & B_GRANT) ? ADDRESS : add_state; // Transition to add state if count is not 15 and grant signal is set
                    rst <= (count == 14 | ~B_GRANT) ? 1'b1 : 1'b0; // Set reset signal if count is 14 or grant signal is not set
                    A_ADD <= (count < 2) ? 1'b1 : 1'b0; // Set address add signal if count is less than 2
                    B_DONE <= 1'b0; // Clear bus done signal
                    M_DVALID <= (M_EXECUTE & count > 1) ? 1'b0 : M_DVALID; // Clear data valid signal if execute signal is set and count is greater than 1
                end
                ACKNAR: begin
                    B_UTIL <= (B_ACK & ~M_RW) ? 1'b0 : 1'b1; // Set bus utilization signal based on acknowledge and read/write signals
                    rst <= (count == 2) ? 1'b1 : 1'b0; // Set reset signal if count is 2
                    state <= (count == 3 & B_ACK) ? ackad_state : ACKNAR; // Transition to acknowledge state if count is 3 and acknowledge signal is set
                    B_DONE <= 1'b0; // Clear bus done signal
                end
                WRITE: begin
                    B_UTIL <= 1'b1; // Set bus utilization signal
                    B_BUS_OUT <= REG_DATAIN[count]; // Set bus output signal to input data register value
                    rst <= (count == 6) ? 1'b1 : 1'b0; // Set reset signal if count is 6
                    state <= (count != 7) ? WRITE : ACKNWR; // Transition to write acknowledge state if count is not 7
                    B_DONE <= 1'b0; // Clear bus done signal
                end
                ACKNWR: begin
                    B_UTIL <= 1'b1; // Set bus utilization signal
                    rst <= (count == 1 | B_ACK) ? 1'b1 : 1'b0; // Set reset signal if count is 1 or acknowledge signal is set
                    state <= (count == 2 | B_ACK) ? ackwr_state : ACKNWR; // Transition to write acknowledge state if count is 2 or acknowledge signal is set
                    M_DVALID <= (count == 2 | B_ACK) ? B_ACK : 1'b0; // Set data valid signal if count is 2 or acknowledge signal is set
                    B_DONE <= (B_ACK) ? 1'b1 : 1'b0; // Set bus done signal if acknowledge signal is set
                end
                READ: begin
                    incr1 <= (M_EXECUTE & B_GRANT) ? 1'b1 : 1'b0; // Set increment signal for second counter if execute and grant signals are set
                    B_UTIL <= (B_GRANT & count1 < 5) ? 1'b1 : 1'b0; // Set bus utilization signal if grant signal is set and count1 is less than 5
                    rst1 <= (count1 == 6 | ~B_GRANT) ? 1'b1 : 1'b0; // Set reset signal for second counter if count1 is 6 or grant signal is not set
                    state <= (count1 == 7) ? IDLE : rd_state; // Transition to IDLE state if count1 is 7
                    M_DVALID <= (count1 == 7) ? 1'b1 : 1'b0; // Set data valid signal if count1 is 7
                    REG_DATAOUT[count1] <= B_BUS_IN; // Load bus input data into output data register
                    B_DONE <= (count1 == 7) ? 1'b1 : 1'b0; // Set bus done signal if count1 is 7
                    rst <= 1'b1; // Set reset signal
                end
                HOLD: begin
                    state <= (B_GRANT) ? READ : HOLD; // Transition to READ state if grant signal is set
                    rst1 <= 1'b0; // Clear reset signal for second counter
                end
            endcase
        end
    end

endmodule