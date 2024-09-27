module rank_logic #(
    parameter data_bits = 8,
    parameter rank_bits = 2
) (
    input [data_bits-1 : 0] i_new,
    input [data_bits-1 : 0] s_n,
    input [rank_bits-1 : 0] r_in,
    input [rank_bits-1 : 0] r_0,
    output [rank_bits-1 : 0] r_out,
    output i_is_ge
);

  wire [rank_bits - 1 : 0] plus_1;

  assign i_is_ge = s_n <= i_new;
  assign plus_1  = r_in + (!i_is_ge);
  assign rn_gt   = r_in > r_0;
  assign r_out   = plus_1 - rn_gt;

endmodule

module rank_reg #(
    parameter RESET_VAL = 0,
    parameter rank_bits = 4
) (
    input clk,
    input rst,
    input clr,
    input [rank_bits-1 : 0] in,
    output reg [rank_bits-1 : 0] out = RESET_VAL
);

  always @(posedge clk or negedge rst or negedge clr) begin
    if (!clr) out <= 0;
    else if (!rst) out <= RESET_VAL;
    else out <= in;
  end
endmodule


module ranks #(
    parameter data_bits = 8,
    parameter rank_bits = $clog2(N),
    parameter N = 7
) (
    input clk,
    input rst,
    input [(N-3)/2 -1 : 0] k,
    input [data_bits * (N-1) - 1 : 0] s,
    input [data_bits-1 : 0] i_new,
    output [(rank_bits * N)-1 : 0] ranks_out
);

  genvar i;

  wire [rank_bits-1 : 0] rank_next[N-1 : 0];
  wire [rank_bits-1 : 0] rank_curr[N-1 : 0];
  wire [N-2 : 0] i_is_ge;

  reg [rank_bits-1 : 0] r_oldest[N-2 : 0];
  reg [N-1:0] clrs;

  adder_ladder #(N, rank_bits) al (
      i_is_ge[N-2 : 0],
      k,
      rank_next[0]
  );

  integer j;
  always @(*) begin
    r_oldest[N-2] = rank_curr[N-1];
    r_oldest[N-3] = rank_curr[N-1];
    for (j = N - 4; j > 0; j = j - 2) begin
      if (k[j/2]) begin
        r_oldest[j]   = r_oldest[j+2];
        r_oldest[j-1] = r_oldest[j+2];
      end else begin
        r_oldest[j]   = rank_curr[j+1];
        r_oldest[j-1] = rank_curr[j+1];
      end
    end
  end


  always @(*) begin
    clrs[2:0] <= 3'b111;
    for (j = 3; j < N; j = j + 1) begin
      clrs[j] = k[(j-3)/2];
    end
  end

  generate
    for (i = 0; i < N; i = i + 1) begin : reg_gen
      rank_reg #(i + 1, rank_bits) r_reg (
          clk,
          rst,
          clrs[i],
          rank_next[i],
          rank_curr[i]
      );
    end
  endgenerate

  generate
    for (i = 0; i < N - 1; i = i + 1) begin : logic_gen
      rank_logic #(data_bits, rank_bits) rank_log (
          i_new,
          s[i*data_bits+:data_bits],
          rank_curr[i],
          r_oldest[i],
          rank_next[i+1],
          i_is_ge[i]
      );
    end
  endgenerate

  generate
    for (i = 0; i < N; i = i + 1) begin : assign_out
      assign ranks_out[i*rank_bits+:rank_bits] = rank_curr[i];
    end
  endgenerate


endmodule


