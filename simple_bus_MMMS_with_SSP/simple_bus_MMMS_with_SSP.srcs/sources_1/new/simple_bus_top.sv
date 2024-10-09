module simple_bus_top #( 
    parameter DATA_WIDTH = 8, 
    parameter ADDR_WIDTH = 4 
)(
    input  logic                        clk,
    input  logic                        reset,
    output logic [DATA_WIDTH-1:0]       master_din,
    input  logic [DATA_WIDTH-1:0]       master1_dout,
    input  logic [ADDR_WIDTH-1:0]       master1_addr,
    input  logic                        wr1,
    input  logic [DATA_WIDTH-1:0]       master2_dout,
    input  logic [ADDR_WIDTH-1:0]       master2_addr,
    input  logic                        wr2,
    output logic [DATA_WIDTH-1:0]       master_dout,
    output logic [ADDR_WIDTH-1:0]       master_addr,
    output logic                        wr,
    output logic                        slave1_sel,
    output logic                        slave2_sel,
    output logic                        slave3_sel,
    output logic [DATA_WIDTH-1:0]       slave1_data_out,
    output logic [DATA_WIDTH-1:0]       slave2_data_out,
    output logic [DATA_WIDTH-1:0]       slave3_data_out,
    input  logic                        slave1_slack,
    input  logic                        slave2_slack,
    input  logic                        slave3_slack,
    input  logic                        grant1,
    input  logic                        grant2,
    input  logic                        master1_slack,
    input  logic                        master2_slack,
    output logic                        split,
    output logic [1:0]                  req_split_master,
    input  logic [1:0]                  active_master1
);

    // Instantiate arbiter module
    ss_arbiter arbiter_inst (
        .clk(clk),
        .reset(reset),
        .slack1(master1_slack),
        .slack2(master2_slack),
        .split(split),
        .req_split_slave(req_split_master),
        .req_master1(wr1),
        .req_master2(wr2), 
        .grant_master1(grant1),
        .grant_master2(grant2),
        .active_master(active_master1)
    );

    // Address-Data Mux
    mux_2to1_addr_data mux_2to1_addr_data_inst (
        .grant1(grant1),
        .grant2(grant2),
        .addr1(master1_addr),
        .data1(master1_dout),
        .addr2(master2_addr),
        .data2(master2_dout),
        .wr1(wr1),
        .wr2(wr2),
        .selected_addr(master_addr),
        .selected_data(master_dout),
        .Selected_wr(wr)
    );

    // Slave Decoder
    decoder decoder_inst (
        .addr(master_addr),
        .grant1(grant1),
        .grant2(grant2),
        .slave1_sel(slave1_sel),
        .slave2_sel(slave2_sel),
        .slave3_sel(slave3_sel)
    );

    // Slack Signal Mux/Demux
    mux_demux mux_demux_inst (
        .select1(slave1_sel),
        .select2(slave2_sel),
        .select3(slave3_sel),
        .grant1(grant1),
        .grant2(grant2),
        .input1(slave1_slack),
        .input2(slave2_slack),
        .input3(slave3_slack),
        .output1(master1_slack),
        .output2(master2_slack)
    );

    // Data Mux for Slaves
    mux_3to1_8bit mux_data_inst (
        .slave1_sel(slave1_sel),
        .slave2_sel(slave2_sel),
        .slave3_sel(slave3_sel),
        .slave1_data(slave1_data_out),
        .slave2_data(slave2_data_out),
        .slave3_data(slave3_data_out),
        .selected_data(master_din)
    );

endmodule
