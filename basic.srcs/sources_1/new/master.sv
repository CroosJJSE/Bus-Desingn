module master (
    input  wire        clk,           // Clock signal
    input  wire        async_reset,   // Asynchronous reset
    input  wire        M1_grant,      // Grant signal from arbiter
    input  wire [7:0]  data_in,       // 8-bit data input (for read operation)
    input  wire        ext_data_valid,  // External signal for data validity (for read/write completion)
    output reg         M1_request,    // Request signal to arbiter
    output reg [2:0]   M1_addr,       // Slave address output
    inout  wire [7:0]  data_bus,      // 8-bit bi-directional data bus (read/write data)
    output wire        data_valid_out  // Signal to indicate valid data during write
);

    // Internal signals
    reg [7:0] instruction_memory [4:0];  // Five 8-bit registers for instructions
    reg [2:0] current_instruction;       // Points to the current instruction
    reg [2:0] next_instruction;          // Points to the next instruction
    reg [1:0] state;                     // State (Idle, Read, Write)
    reg [7:0] register_data ;            // Register to store data for write operations
    reg [1:0] write_counter;             // Counter to track clock cycles for write operation 
    reg       data_valid_internal;
           // Internal data_valid signal

    // Instruction Fields
    reg [1:0] operation;    // First 2 bits (State)
    reg [2:0] slave_address; // Next 3 bits (Slave Address)
    reg       reg_sel;       // Next 1 bit (Register selection)
    
    // State definitions
    localparam IDLE  = 2'b00;
    localparam READ  = 2'b01;
    localparam WRITE = 2'b10;

    // Assign output signals
    assign data_bus = (state == WRITE && M1_grant) ? register_data : 8'bz;  // Bus tri-state logic
    assign data_valid_out = data_valid_internal;

    // Asynchronous reset and instruction memory initialization
    always @(posedge clk or posedge async_reset) begin
        if (async_reset) begin // Reset logic
            write_counter <= 2'b00;  // Reset the counter
            current_instruction <= 3'b000;
            M1_request <= 1'b0;
            data_valid_internal <= 1'b0;
            state <= IDLE;
        end
        else begin
             // Load the current instruction manually
            operation      <= instruction_memory[current_instruction][7:6];  // First 2 bits (7 and 6)
            slave_address  <= instruction_memory[current_instruction][5:3];  // Next 3 bits (5, 4, 3)
            reg_sel        <= instruction_memory[current_instruction][2];    // Last 1 bit (2)
            
            // State machine
            case (state)
                IDLE: begin
                    M1_request <= 1'b0;  // Don't request bus while idle
                    data_valid_internal <= 1'b0;  // Data is not valid in IDLE
                    if (!ext_data_valid && M1_grant) begin
                        if (operation == READ || operation == WRITE) begin
                            state <= operation;
                            M1_addr <= slave_address;  // Set the slave address
                        end
                    end
                end

                READ: begin
                    M1_request <= 1'b1;  // Request bus
                    if (ext_data_valid) begin
                        register_data <= data_in;  // Store the data read from the bus
                        current_instruction <= next_instruction;  // Move to the next instruction
                    end
                end

                WRITE: begin
                    M1_request <= 1'b1;  // Request bus
                    if (M1_grant) begin
                        if (write_counter == 2'b00) begin
                            data_valid_internal <= 1'b1;  // Set data valid signal
                        end
                        if (write_counter < 2'b10) begin
                            write_counter <= write_counter + 1;  // Increment counter
                        end
                        else begin
                            data_valid_internal <= 1'b0;  // Clear data valid signal after 2 clock cycles
                            write_counter <= 2'b00;  // Reset the counter
                            current_instruction <= next_instruction;  // Move to the next instruction
                            state <= IDLE;  // Return to IDLE state
                        end
                    end
                end
            endcase
        end
    end
    
    always @(negedge ext_data_valid) begin
        if (M1_grant) begin
            next_instruction <= current_instruction + 1;  // Move to the next instruction
        end
    end

    // Initialize instruction memory (can be customized later)
    initial begin
        instruction_memory[0] = 8'b01_000_0_01;  // Example: WRITE to Slave 1
        instruction_memory[1] = 8'b01_000_0_10;  // Example: IDLE
        instruction_memory[2] = 8'b10000101;  // Example: WRITE to Slave 5
        instruction_memory[3] = 8'b10000001;  // Example: WRITE to Slave 1
        instruction_memory[4] = 8'b10000110;  // Example: WRITE to Slave 6
    end
endmodule
