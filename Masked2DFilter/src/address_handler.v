module address_handler #(
    parameter WORD  = 16,
    parameter MAX_N = 25
) (
    input clk,
    input rst,
    input [WORD-1:0] h,
    input [WORD-1:0] w,
    input [WORD-1:0] n,
    output wire [WORD:0] r_addr,
    output reg [WORD:0] w_addr,
    output reg w_en,
    output wire r_en,
    output wire kernel_newline
);

  parameter N_BITS = $clog2(MAX_N);
  parameter K_BITS = $clog2((MAX_N >> 1)+1);
  parameter C_BITS = $clog2(MAX_N);

  wire signed [WORD-1:0] x;
  reg signed [WORD-1:0] y;
  reg signed [C_BITS-1:0] count_y;
  reg signed [WORD-1:0] xc;
  reg r_newcol;

  reg [1:0] newline_delay;
  assign kernel_newline = newline_delay[1];
  //assign kernel_newline = newline_delay[0];

  wire signed [WORD-1:0] yc;
  wire [K_BITS-1:0] k;
  wire [C_BITS-1:0] count_to;
  wire [WORD-1:0] x_plus_1;
  wire [WORD:0] w_addr_pre_pre;
  //wire [WORD:0] w_addr_pre;

  assign r_addr = yc * w + xc;
  assign r_en = xc >= 0 & xc < w & yc >= 0 & yc < h;
  assign w_en_pre_pre = x >= 0 & newcol;
  assign w_addr_pre_pre = y * w + x;

  //assign w_en_pre = x >= 0 & newcol;
  //assign w_addr_pre = y * w + x;

  assign x = xc - k;
  assign newcol = count_y == count_to;
  assign newline = (x == w);
  assign yc = y + count_y;
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
      xc <= 0;
    end else begin
      if (newline) xc <= 0;
      else if (count_y == count_to) xc <= xc + 1;
      else xc <= xc;
    end
  end

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      count_y <= -(n >> 1);
    end else begin
      if (newcol | newline) count_y <= -(n >> 1);
      else count_y <= count_y + 1;
    end
  end


  reg [WORD:0] w_addr_pre;
  reg w_en_pre;

  always @(posedge clk) begin
    w_en_pre   <= w_en_pre_pre;
    w_addr_pre <= w_addr_pre_pre;
  end

  always @(negedge clk) begin
    w_en <= w_en_pre;
    w_addr <= w_addr_pre;
    newline_delay <= {newline_delay[0], newline};
  end

  /*
  always @(posedge clk) begin
    w_en <= w_en_pre;
    w_addr <= w_addr_pre;
    newline_delay <= {newline_delay[0], newline};
  end
  */
endmodule

