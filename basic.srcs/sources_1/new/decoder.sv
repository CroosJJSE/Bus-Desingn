module decoder (
    input wire [1:0] slave_sel,
    output reg sel_0,
    output reg sel_1,
    output reg sel_2
);
    always @(*) begin
        sel_0 = 0;
        sel_1 = 0;
        sel_2 = 0;
        case (slave_sel)
            2'b00: sel_0 = 1;
            2'b01: sel_1 = 1;
            2'b10: sel_2 = 1;
            default: ;
        endcase
    end
endmodule
