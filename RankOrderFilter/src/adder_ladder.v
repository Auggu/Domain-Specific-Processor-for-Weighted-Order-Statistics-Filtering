module adder_ladder #(
    parameter N = 3,
    parameter rank_bits = 2
) (
    input [N-2:0] in,
    output [rank_bits-1 : 0] out
);
/*
  integer i;
  always @* begin
    out = 0;
    for (i = 0; i < N - 1; i = i + 1) begin : adder_ladder
      out = out + in[i];
    end
  end
*/
  adder_tree #(
      .INPUTS(N - 1),
      .OUT_W (rank_bits)
  ) tree (
      .in (in),
      .out(out)
  );
endmodule

module adder_tree #(
    parameter INPUTS = 2,
    parameter OUT_W  = 2
) (
    input  [INPUTS-1:0] in,
    output [ OUT_W-1:0] out
);

  generate
    if (INPUTS == 2) begin : gen_base_case
      assign out = in[1] + in[0];
    end else begin : gen_tree_recursive

      localparam RIGHT_INPUTS = 2 ** ($clog2(INPUTS) - 1);
      localparam LEFT_INPUTS = INPUTS - RIGHT_INPUTS;
      localparam RIGHT_W = $clog2(RIGHT_INPUTS+1);
      localparam LEFT_W = $clog2(LEFT_INPUTS+1);
      wire [LEFT_W-1:0] left_out;
      wire [RIGHT_W-1:0] right_out;

      adder_tree #(
          .INPUTS(RIGHT_INPUTS),
          .OUT_W (RIGHT_W)
      ) right_tree (
          .in (in[0+:RIGHT_INPUTS]),
          .out(right_out)
      );

      adder_tree #(
          .INPUTS(LEFT_INPUTS),
          .OUT_W (LEFT_W)
      ) left_tree (
          .in (in[RIGHT_INPUTS+:LEFT_INPUTS]),
          .out(left_out)
      );

      assign out = left_out + right_out;
    end
  endgenerate

endmodule

