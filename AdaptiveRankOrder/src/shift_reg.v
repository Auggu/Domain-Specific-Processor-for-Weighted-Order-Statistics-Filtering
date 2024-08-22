module shift_reg #(
    parameter bits = 8,
    parameter N =3
) (
    input clk,
    input rst,
    input [bits-1: 0] in,
    output reg [bits*N-1:0] out= 0
);

	 integer i;
    always @ (posedge clk or negedge rst) begin
        if(!rst) begin
            out = {bits*N{1'b0}};
        end else begin
            out[bits-1 : 0] <= in;
            for(i = 1; i < N; i = i + 1) begin
                out[bits*(i) +: bits] <= out[bits*(i-1) +: bits];
            end
        end
    end

endmodule