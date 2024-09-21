module counter #(
    parameter N = 7
) (
    input [N-1:0] in,
    output reg [rank_bits-1 : 0] out
);

  parameter rank_bits = $clog2(N + 1);
  integer i;
  always @(*) begin
    out = 0;
    for (i = 0; i < N; i = i + 1) begin
      out = out + in[i];
    end
  end

endmodule

