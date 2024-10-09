`timescale 1ns/1ps

module tb_dual_clock_fifo;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 8;

    // Clock and reset signals
    reg wr_clk;
    reg rd_clk;
    reg reset;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] wr_data;
    wire [DATA_WIDTH-1:0] rd_data;
    wire full;
    wire empty;

    // Instantiate the dual clock FIFO
    dual_clock_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .wr_clk(wr_clk),
        .reset(reset),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_clk(rd_clk),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    initial begin
        wr_clk = 0;
        forever #5 wr_clk = ~wr_clk;  // 100 MHz write clock
    end

    initial begin
        rd_clk = 0;
        forever #7 rd_clk = ~rd_clk;  // 71.43 MHz read clock
    end

    integer i;
    
    // Testbench logic
    initial begin
        // Initialize inputs
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        
        reset = 1;
        #10 reset = 0;

        // Wait for both clocks to stabilize
        #20;
        
        
        // Write data into the FIFO
        wr_en = 1;
        for (i = 0; i < 2*DEPTH-1; i = i + 1) begin
            wr_data = i;
            #10;  // Wait for the write clock cycle
        end
        wr_en = 0;

        // Wait some cycles and then start reading
        #50;
        rd_en = 1;
        #300;
        rd_en = 0;
        
        
        //second rd_en
        // Write data into the FIFO
        wr_en = 1;
        for (i = 0; i < 2*DEPTH-1; i = i + 1) begin
            wr_data = i;
            #10;  // Wait for the write clock cycle
        end
        wr_en = 0;

        // Wait some cycles and then start reading
        #50;
        rd_en = 1;
        #300;
        rd_en = 0;

        // End of simulation
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time: %t | wr_en: %b | wr_data: %d | rd_en: %b | rd_data: %d | full: %b | empty: %b", 
                  $time, wr_en, wr_data, rd_en, rd_data, full, empty);
    end

endmodule
