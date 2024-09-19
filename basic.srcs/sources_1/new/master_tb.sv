`timescale 1ns/1ps

module master_tb;

    // Declare testbench signals
    reg clk;
    reg async_reset;
    reg M1_grant;
    reg [7:0] data_in;
    reg ext_data_valid;
    wire M1_request;
    wire [2:0] M1_addr;
    wire [7:0] data_bus;
    wire data_valid_out;

    // Bidirectional `data_bus` signal (for read/write)
    reg [7:0] data_bus_driver;
    assign data_bus = (M1_grant && M1_request) ? data_bus_driver : 8'bz;

    // Instantiate the master module
    master uut (
        .clk(clk),
        .async_reset(async_reset),
        .M1_grant(M1_grant),
        .data_in(data_in),
        .ext_data_valid(ext_data_valid),
        .M1_request(M1_request),
        .M1_addr(M1_addr),
        .data_bus(data_bus),
        .data_valid_out(data_valid_out)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // 100 MHz clock (10ns period)
    end

    // Initial block for simulation
    initial begin
        // Initialize all inputs
        clk = 0;
        async_reset = 1;
        M1_grant = 0;
        data_in = 8'b0;
        ext_data_valid = 0;
        data_bus_driver = 8'b0;

        // Display header for the simulation
        $display("Time\t\tM1_request\tM1_addr\t\tdata_bus\tdata_valid_out");

        // Hold reset for a few clock cycles
        #20;

        // Release reset
        async_reset = 0;

        // Wait for a bit, then let master request the bus
        #30;
        M1_grant = 0; // Initially not granting the bus

        // Simulate the master requesting the bus
        #50;
        M1_grant = 1;  // Grant the bus after master requests

        // Simulate a data read after granting
        #40;
        data_in = 8'hAA;  // Example data from the bus
        ext_data_valid = 1;  // Signal valid data

        // Wait for some time to let the read complete
        #100;
        ext_data_valid = 0;

        // Simulate a write operation after some time
        #200;
        M1_grant = 1;  // Grant the bus again for writing
        data_bus_driver = 8'h55;  // Example data to write on the bus

        // Observe more behavior (keep simulation running for 1000ns)
        #500;

        // End of test
        @(posedge clk);
        $display("Test completed.");
        $finish;
    end

    // Monitor signal changes
    initial begin
        $monitor("%0dns\t%b\t\t%h\t\t%h\t\t%b", $time, M1_request, M1_addr, data_bus, data_valid_out);
    end

endmodule
