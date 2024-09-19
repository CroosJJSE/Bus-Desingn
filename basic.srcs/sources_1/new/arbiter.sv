module arbiter (
    input wire clk,
    input wire reset,
    input wire M1_request,
    input wire M2_request,
    output reg M1_grant,
    output reg M2_grant,
    output reg mux_sel  // Select for master address
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            M1_grant <= 1'b0;
            M2_grant <= 1'b0;
            mux_sel <= 1'b0;
        end else begin
            if (M1_request) begin
                M1_grant <= 1'b1;
                M2_grant <= 1'b0;
                mux_sel <= 1'b0;  // Master 1 selected
            end else if (M2_request) begin
                M1_grant <= 1'b0;
                M2_grant <= 1'b1;
                mux_sel <= 1'b1;  // Master 2 selected
            end
        end
    end
endmodule
