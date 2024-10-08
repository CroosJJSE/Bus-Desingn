module top (
    input wire clk,
    input wire reset,
    
    // Inputs for master 1
    input wire start_M1,
    
    // Inputs for master 2
    input wire start_M2,
    
    output wire [7:0] M1_data_out,  // Output data to master 1
    output wire [7:0] M2_data_out   // Output data to master 2
);

    wire M1_request, M2_request;     // Requests from the two masters
    wire M1_grant, M2_grant;         // Grant signals from arbiter to masters
    wire [5:0] M1_addr, M2_addr;     // Addresses from the masters
    wire [7:0] M1_data_in, M2_data_in;  // Data inputs to slaves from masters
    wire mux_sel;                    // Select signal from arbiter for address mux
    wire [5:0] selected_addr;        // Address output from mux_1
    wire [1:0] slave_select;         // Output of mux_2 (sent to decoder)
    wire [7:0] slave_data_out;       // Data output from the slaves (mux_3 output)

    wire [7:0] data_out_0, data_out_1, data_out_2; // Slave data outputs
    wire valid_out_0, valid_out_1, valid_out_2;    // Slave data valid outputs

    // Instantiate master 1
    master master1 (
        .clk(clk),
        .async_reset(reset),
        .start(start_M1),          // Start signal for master 1
        .M_request(M1_request),    // Request signal from master 1
        .M_grant(M1_grant),        // Grant signal from arbiter to master 1
        .M_addr(M1_addr),          // Address generated by master 1
        .M_data_in(slave_data_out), // Data read from slave
        .M_data_out(M1_data_in)    // Data to be written to slave (currently not used)
    );

    // Instantiate master 2
    master master2 (
        .clk(clk),
        .async_reset(reset),
        .start(start_M2),          // Start signal for master 2
        .M_request(M2_request),    // Request signal from master 2
        .M_grant(M2_grant),        // Grant signal from arbiter to master 2
        .M_addr(M2_addr),          // Address generated by master 2
        .M_data_in(slave_data_out), // Data read from slave
        .M_data_out(M2_data_in)    // Data to be written to slave (currently not used)
    );

    // Instantiate arbiter (decides which master gets access to the bus)
    arbiter arb_inst (
        .clk(clk),
        .reset(reset),
        .M1_request(M1_request),
        .M2_request(M2_request),
        .M1_grant(M1_grant),
        .M2_grant(M2_grant),
        .mux_sel(mux_sel)   // Mux select signal for master address
    );

    // Mux_1: Select the master's address to send to slaves (based on arbiter)
    mux_1 #(.WIDTH(6)) addr_mux (
        .in0(M1_addr),    // Master 1 address
        .in1(M2_addr),    // Master 2 address
        .sel(mux_sel),    // Select line from arbiter
        .out(selected_addr)  // Selected address (sent to slaves)
    );

    // Mux_2: Select the master's target slave address for the decoder
    mux_2 #(.WIDTH(2)) target_mux (
        .in0(M1_addr[3:2]),  // 2-bit address for selecting the slave
        .in1(M2_addr[3:2]),
        .sel(mux_sel),
        .out(slave_select)  // Target slave select for decoder
    );

    // Decoder: Generate slave select signals based on address
    decoder dec_inst (
        .slave_sel(slave_select),  // 2-bit address from mux_2
        .sel_0(valid_out_0),       // Valid signal for Slave 0
        .sel_1(valid_out_1),       // Valid signal for Slave 1
        .sel_2(valid_out_2)        // Valid signal for Slave 2
    );

    // Instantiate slaves
    slave slave0 (
        .clk(clk),
        .reset(reset),
        .slave_address(selected_addr),   // Address selected by mux_1
        .data_in_valid(valid_out_0),     // Valid signal from decoder
        .data_out(data_out_0),           // Data output from slave 0
        .data_out_valid(valid_out_0)     // Data valid signal
    );

    slave slave1 (
        .clk(clk),
        .reset(reset),
        .slave_address(selected_addr),
        .data_in_valid(valid_out_1),
        .data_out(data_out_1),
        .data_out_valid(valid_out_1)
    );

    slave slave2 (
        .clk(clk),
        .reset(reset),
        .slave_address(selected_addr),
        .data_in_valid(valid_out_2),
        .data_out(data_out_2),
        .data_out_valid(valid_out_2)
    );

    // Mux_3: Select data output from one of the three slaves (based on decoder select)
    mux_3 #(.WIDTH(8)) data_mux (
        .in0(data_out_0),  // Data from Slave 0
        .in1(data_out_1),  // Data from Slave 1
        .in2(data_out_2),  // Data from Slave 2
        .sel({valid_out_2, valid_out_1, valid_out_0}),  // Select lines from decoder
        .out(slave_data_out)  // Output the selected slave data
    );

    // Connect data output to both masters
    assign M1_data_out = (M1_grant) ? slave_data_out : 8'bz;  // Master 1 reads data
    assign M2_data_out = (M2_grant) ? slave_data_out : 8'bz;  // Master 2 reads data

endmodule
