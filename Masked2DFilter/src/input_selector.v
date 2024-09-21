module input_selector #(
    parameter WORD  = 32,
    parameter MAX_N = 25
) (
    input clk,
    input rst,
    input [WORD-1:0] h,
    input [WORD-1:0] w,
    input [N_BITS-1:0] n,
    output wire [WORD-1:0] address
);
  parameter N_BITS = $clog2(MAX_N);
  parameter K_BITS = $clog2(MAX_N >> 1);
  parameter C_BITS = $clog2(MAX_N);

  reg [WORD-1:0] x;
  reg signed [WORD-1:0] y;
  reg signed [C_BITS-1:0] count;
  wire signed [WORD-1:0] yc;
  wire [K_BITS-1:0] k;
  wire [C_BITS-1:0] count_to;
  wire [WORD-1:0] x_plus_1;

  assign address = x >= 0 & x < w & yc >= 0 & yc < h ? yc * w + x : 0;
  assign newrow = count == count_to;
  assign newline = (x + 1 == (w + k) & newrow);
  assign yc = y + count;
  assign count_to = k;
  assign k = n >> 1;
  assign x_plus_1 = x + 1;

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      y <= 0;
    end else begin
      if (newline) y <= y + 1;
      else y <= y;
    end
  end

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      x <= 0;
    end else begin
      if (newline) x <= 0;
      else if (count == count_to) x <= x + 1;
      else x <= x;
    end
  end

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      count <= -(n >> 1);
    end else begin
      if (newrow) count <= -(n >> 1);
      else count <= count + 1;
    end
  end

endmodule

