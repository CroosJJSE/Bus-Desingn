module decoder (
    input wire [2:0] selected_addr_decode ,  // 6-bit slave address
    output reg [1:0] sel_mux  // 2-bit select signal for the mux
);
    always @(*) begin
        case (selected_addr_decode)
            3'b000: sel_mux <= 2'b00;  // Select slave 0
            3'b001: sel_mux <= 2'b01;  // Select slave 1
            3'b010: sel_mux <= 2'b10;  // Select slave 2
            default: sel_mux <= 2'b00;  // Default to slave 0
        endcase
    end
endmodule
