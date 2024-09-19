module top_tb;
    // Declare inputs to the top module as regs and outputs as wires
    reg clk;
    reg reset;
    
    // Master 1 signals
    reg M1_request;
    reg [5:0] M1_addr;
    reg [7:0] M1_data_in;
    wire [7:0] M1_data_out;
    wire M1_grant;
    
    // Master 2 signals
    reg M2_request;
    reg [5:0] M2_addr;
    reg [7:0] M2_data_in;
    wire [7:0] M2_data_out;
    wire M2_grant;

    // Instantiate the top module
    top uut (
        .clk(clk),
        .reset(reset),
        .M1_request(M1_request),
        .M1_addr(M1_addr),
        .M1_data_in(M1_data_in),
        .M1_data_out(M1_data_out),
        .M1_grant(M1_grant),
        .M2_request(M2_request),
        .M2_addr(M2_addr),
        .M2_data_in(M2_data_in),
        .M2_data_out(M2_data_out),
        .M2_grant(M2_grant)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // 10 ns clock period (100 MHz)
    end

    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 1;
        M1_request = 0;
        M1_addr = 6'b000000;
        M1_data_in = 8'b00000000;
        M2_request = 0;
        M2_addr = 6'b000000;
        M2_data_in = 8'b00000000;

        // Apply reset
        #10 reset = 0;
        
        // Test Master 1 accessing Slave 0 (Read)
        #10 M1_request = 1;
        M1_addr = 6'b000000;  // Slave 0, Read operation (first bit = 0)
        
        #20 M1_request = 0;
        
        // Test Master 2 accessing Slave 1 (Read)
        #10 M2_request = 1;
        M2_addr = 6'b001000;  // Slave 1, Read operation (first bit = 0)
        
        #20 M2_request = 0;
        
        // Test Master 1 accessing Slave 2 (Read)
        #10 M1_request = 1;
        M1_addr = 6'b010000;  // Slave 2, Read operation (first bit = 0)
        
        #20 M1_request = 0;
        
        // Test Master 2 accessing Slave 0 (Read)
        #10 M2_request = 1;
        M2_addr = 6'b000000;  // Slave 0, Read operation (first bit = 0)
        
        #20 M2_request = 0;
        
        // Test Master 1 accessing Slave 1 (Read)
        #10 M1_request = 1;
        M1_addr = 6'b001000;  // Slave 1, Read operation (first bit = 0)
        
        #20 M1_request = 0;

        // Test complete
        #100;
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | M1_request=%b | M1_addr=%h | M1_data_out=%h | M1_grant=%b | M2_request=%b | M2_addr=%h | M2_data_out=%h | M2_grant=%b",
            $time, M1_request, M1_addr, M1_data_out, M1_grant, M2_request, M2_addr, M2_data_out, M2_grant);
    end

endmodule
