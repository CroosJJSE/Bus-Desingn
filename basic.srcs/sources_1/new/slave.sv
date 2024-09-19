module slave (
    input wire clk,
    input wire reset,
    input wire [5:0] slave_address,  // 6-bit slave address
    input wire data_in_valid,        // Input valid signal
    output reg [7:0] data_out,       // 8-bit data output
    output reg data_out_valid        // Data output valid signal
);

    // Memory block (initialized with a value)
    reg [7:0] memory;

    // Target slave address decoding (for this slave)
    localparam TARGET_SLAVE = 2'b01;  // Change this for each slave instance

    // Extract bits for operation and slave selection
    wire operation = slave_address[5];          // 1st bit is operation: 1 -> write, 0 -> read
    wire [1:0] slave_select = slave_address[3:2];  // 2nd and 3rd bits indicate the target slave

    initial begin
        memory = 8'hA5;  // Initialize memory with some value (0xA5)
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 8'b0;
            data_out_valid <= 1'b0;
        end
        else begin
            // Check if the target slave is being addressed
            if (slave_select == TARGET_SLAVE) begin
                if (data_in_valid && operation == 1'b0) begin  // Read operation
                    data_out <= memory;  // Output the stored data
                    data_out_valid <= 1'b1;  // Set data valid signal high
                end
                else begin
                    data_out_valid <= 1'b0;  // Set data valid signal low if not reading
                end
            end
            else begin
                // If not the target slave, do nothing
                data_out <= 8'b0;
                data_out_valid <= 1'b0;
            end
        end
    end
endmodule
