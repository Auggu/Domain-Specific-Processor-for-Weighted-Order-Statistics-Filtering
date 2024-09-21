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
            out[N*bits-1 -: bits] <= in;
            for(i = 0; i < N-1; i = i + 1) begin
                out[bits*(i) +: bits] <= out[bits*(i+1) +: bits];
            end
        end
    end

endmodule