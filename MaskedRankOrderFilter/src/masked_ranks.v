module calculate_rank #(
    parameter N = 7
) (
    input [N-1 : 0] in,
    input [N-1 : 0] mask,
    input mask_bit,
    output [$clog2(N+1)-1 : 0] rank
);

  wire [N-1:0] masked = in & mask;
  wire [$clog2(N+1)-1 : 0] sum;
  counter #(N) adder (
      masked,
      sum
  );
  assign rank = sum & {$clog2(N + 1) {mask_bit}};

endmodule

module rank_reg #(
    parameter N = 7,
    parameter REG_NUMBER = 0
) (
    input clk,
    input rst,
    input [N-1 : 0] in,
    output reg [N-1 : 0] out
);

  parameter RANK_BITS = $clog2(N);

  parameter RESET_VAL = 2 ** REG_NUMBER - 1;

  always @(posedge clk or negedge rst) begin
    if (!rst) out <= RESET_VAL;
    else out <= in;
  end

endmodule


module masked_ranks #(
    parameter N = 7
) (
    input clk,
    input rst,
    input [N -1 : 0] mask,
    input [N-2 : 0] gts,
    output [(rank_bits * N)-1 : 0] ranks_out
);

  parameter rank_bits = $clog2(N + 1);

  reg [N-1 : 0] reg_ins[N-1 : 0];
  wire [N-1 : 0] reg_outs[N-1 : 0];

  integer i;
  always @(*) begin
    reg_ins[N-1] = {1'b1, gts};
    for (i = 0; i < N - 1; i = i + 1) begin
      reg_ins[i] = {~gts[i], reg_outs[i+1][N-1 : 1]};
    end
  end

  genvar j;
  generate
    for (j = 0; j < N; j = j + 1) begin : gen_regs
      rank_reg #(N, j + 1) r_reg (
          clk,
          rst,
          reg_ins[j],
          reg_outs[j]
      );
      calculate_rank #(N) cal_rank (
          reg_outs[j],
          mask,
          mask[j],
          ranks_out[j*rank_bits+:rank_bits]
      );
    end
  endgenerate

endmodule

