module top (
    input wire clk,
    input wire reset
   
);

    // Internal signals
    wire M1_request, M2_request;     // Requests from the two masters
    wire M1_grant, M2_grant;         // Grant signals from arbiter to masters
    wire [2:0] M1_addr, M2_addr;     // Addresses from the masters
    wire [7:0] data_bus;             // Data bus shared between masters and slaves
    wire [7:0] data_out_0, data_out_1, data_out_2;  // Data outputs from slaves
    wire data_valid_out_0, data_valid_out_1, data_valid_out_2;  // Data valid signals from slaves
    wire mux_sel;                    // Select signal for address mux

    wire [2:0] selected_addr;        // Address output from mux
    wire [2:0] selected_addr_decode;        // Address output from mux to decoder
    
    wire [7:0] selected_data_out;    // Data output from selected slave
    wire selected_data_valid;        // Data valid output from selected slave

    // Instantiate master 1
    master master1 (
        .clk(clk),
        .async_reset(reset),
        .M1_grant(M1_grant),        // Grant signal from arbiter
        .data_in(selected_data_out), // Data from selected slave
        .ext_data_valid(selected_data_valid),  // Data valid signal from selected slave
        .M1_request(M1_request),    // Request from master 1
        .M1_addr(M1_addr),          // Address from master 1
        .data_bus(data_bus),        // Shared data bus
        .data_valid_out(data_valid_out_0)  // Data valid signal (currently unused)
    );

    // Instantiate master 2
    master master2 (
        .clk(clk),
        .async_reset(reset),
        .M1_grant(M2_grant),        // Grant signal from arbiter
        .data_in(selected_data_out), // Data from selected slave
        .ext_data_valid(selected_data_valid),  // Data valid signal from selected slave
        .M1_request(M2_request),    // Request from master 2
        .M1_addr(M2_addr),          // Address from master 2
        .data_bus(data_bus),        // Shared data bus
        .data_valid_out(data_valid_out_1)  // Data valid signal (currently unused)
    );

    // Instantiate arbiter
    arbiter arb_inst (
        .clk(clk),
        .reset(reset),
        .M1_request(M1_request),
        .M2_request(M2_request),
        .M1_grant(M1_grant),
        .M2_grant(M2_grant),
        .mux_sel(mux_sel)  // Mux select for address
    );

    // Mux: Select the master's address (based on arbiter)
    mux_1 #(.WIDTH(6)) addr_mux (
        .in0({3'b000, M1_addr}),    // Master 1 address
        .in1({3'b000, M2_addr}),    // Master 2 address
        .sel(mux_sel),              // Select line from arbiter
        .out(selected_addr)         // Selected address for slaves
    );

    // Instantiate slaves
    slave slave0 (
        .clk(clk),
        .reset(reset),
        .slave_address(selected_addr),   // Address from mux
        .data_in_valid(data_valid_out_0),  // Data valid signal
        .data_out(data_out_0),           // Data output from slave 0
        .data_out_valid(data_valid_out_0) // Data valid output from slave 0
    );

    slave slave1 (
        .clk(clk),
        .reset(reset),
        .slave_address(selected_addr),
        .data_in_valid(data_valid_out_1),
        .data_out(data_out_1),
        .data_out_valid(data_valid_out_1)
    );

    slave slave2 (
        .clk(clk),
        .reset(reset),
        .slave_address(selected_addr),
        .data_in_valid(data_valid_out_2),
        .data_out(data_out_2),
        .data_out_valid(data_valid_out_2)
    );

    // Mux: Select data output from one of the three slaves
    mux_3 #(.WIDTH(3)) data_mux (
        .in0(data_out_0),  // Data from Slave 0
        .in1(data_out_1),  // Data from Slave 1
        .in2(data_out_2),  // Data from Slave 2
        .sel(selected_addr_decode),  // Select lines
        .out(selected_data_out)  // Selected data from slaves
    );
    
    mux_1 #(.WIDTH(2)) addr_mux_decoder (
    .in0( M1_addr),    // Master 1 address
    .in1( M2_addr),    // Master 2 address
    .sel(mux_sel),              // Select line from arbiter
    .out(selected_addr_decode)         // Selected address for slaves
    );
    

    assign selected_data_valid = (data_valid_out_0 | data_valid_out_1 | data_valid_out_2);

endmodule
