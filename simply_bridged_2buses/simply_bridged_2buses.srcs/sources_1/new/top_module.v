`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2024 04:13:35 PM
// Design Name: 
// Module Name: top_module
// Project Name: 
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


module top_module();

reg clk1,clk2;
reg reset;

wire clk1_SB,clk2_SB;
wire [3:0] addr_SB;
wire r_en_SB,w_en_SB,slack_SB;
wire [7:0] write_data_SB,read_data_SB;

wire clk1_MB,clk2_MB;
wire [3:0] addr_MB;
wire r_en_MB,w_en_MB,slack_MB;
wire [7:0] write_data_MB,read_data_MB;


bus1 bus1(
    .clk1(clk1),                 // Clock input of bus1  
    .reset(reset),                // Reset input
    .clk1_SB(clk1_SB),
    .clk2_SB(clk2_SB),                 
    .addr_SB(addr_SB),
    .r_en_SB(r_en_SB),
    .w_en_SB(w_en_SB),
    .write_data_SB(write_data_SB),
    .read_data_SB(read_data_SB),
    .slack_SB(slack_SB), 
    .clk1_MB(clk1_MB),
    .clk2_MB(clk2_MB),                 
    .addr_MB(addr_MB),
    .r_en_MB(r_en_MB),
    .w_en_MB(w_en_MB),
    .write_data_MB(write_data_MB),
    .read_data_MB(read_data_MB),
    .slack_MB(slack_MB) 
);

bus2 bus2(
    .clk1(clk2),                 // Clock input of bus1  
    .reset(reset),                // Reset input
    .clk1_SB(clk2_MB),
    .clk2_SB(clk1_MB),                 
    .addr_SB(addr_MB),
    .r_en_SB(r_en_MB),
    .w_en_SB(w_en_MB),
    .write_data_SB(write_data_MB),
    .read_data_SB(read_data_MB),
    .slack_SB(slack_MB), 
    .clk1_MB(clk2_SB),
    .clk2_MB(clk1_SB),                 
    .addr_MB(addr_SB),
    .r_en_MB(r_en_SB),
    .w_en_MB(w_en_SB),
    .write_data_MB(write_data_SB),
    .read_data_MB(read_data_SB),
    .slack_MB(slack_SB) 
);


    // Clock generation
    initial begin   
        // Generate clk1 (10ns period)
        forever #5 clk1 = ~clk1; 
    end

    initial begin
        // Generate clk2 (14ns period)
        forever #7 clk2 = ~clk2; 
    end
    
    initial begin
        clk1 = 0;
        clk2 = 0;
        reset = 1; // Start with reset
        #20 reset = 0; // Release reset after 20ns
    end
    

    // Test sequence
    initial begin
        // Test signals setup
        // Example: Writing data
        #50; // Wait for 50ns
        // Add write signal test cases here
        
        // Example: Read data
        #100; // Wait for 100ns
        // Add read signal test cases here

        // Finish simulation
        #200; // Let the simulation run for a bit
        $finish;
    end



endmodule
