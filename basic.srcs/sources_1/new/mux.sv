module mux_1 #(parameter WIDTH = 6) (
    input wire [WIDTH-1:0] in0,
    input wire [WIDTH-1:0] in1,
    input wire sel,
    output wire [WIDTH-1:0] out
);
    assign out = (sel) ? in1 : in0;
endmodule

module mux_2 #(parameter WIDTH = 2) (
    input wire [WIDTH-1:0] in0,
    input wire [WIDTH-1:0] in1,
    input wire sel,
    output wire [WIDTH-1:0] out
);
    assign out = (sel) ? in1 : in0;
endmodule

module mux_3 #(parameter WIDTH = 8) (
    input wire [WIDTH-1:0] in0,
    input wire [WIDTH-1:0] in1,
    input wire [WIDTH-1:0] in2,
    input wire [2:0] sel,  // Select one slave's data based on decoder output
    output reg [WIDTH-1:0] out
);
    always @(*) begin
        case (sel)
            3'b001: out = in0;  // Slave 0
            3'b010: out = in1;  // Slave 1
            3'b100: out = in2;  // Slave 2
            default: out = {WIDTH{1'b0}};
        endcase
    end
endmodule
