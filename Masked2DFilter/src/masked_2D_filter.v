module masked_2D_filter #(
    parameter WORD = 32,
    parameter MAX_N = 9,
    parameter INPUT_SIZE = 8
) (
    input clk,
    input rst,
    input [WORD-1:0] h,
    input [WORD-1:0] w,
    input [N_BITS-1:0] n,
    input [KERNEL_SIZE-1:0] mask,
    input [R_BITS-1:0] rank_sel
);

  parameter N_BITS = $clog2(MAX_N);
  parameter KERNEL_SIZE = MAX_N * MAX_N;
  parameter R_BITS = $clog2(KERNEL_SIZE + 1);

  wire [WORD-1:0] r_addr;
  wire [WORD-1:0] w_addr;
  wire [WORD-1:0] addr_offset;
  wire [INPUT_SIZE-1:0] in;
  wire [INPUT_SIZE-1:0] kernel_out;

  address_handler #(
      .WORD (WORD),
      .MAX_N(MAX_N)
  ) ah (
      .clk(clk),
      .rst(rst),
      .h(h),
      .w(w),
      .n(n),
      .r_addr(r_addr),
      .w_addr(w_addr),
      .w_en(w_en),
      .r_en(r_en)
  );

  masked_rank_order #(
      .N(KERNEL_SIZE),
      .DATA_BITS(INPUT_SIZE)
  ) kernel (
      .clk(clk),
      .rst(rst),
      .i_new(in),
      .rank_sel(rank_sel),
      .out(kernel_out)
  );

  memory #(
      .WORD(WORD),
      .INPUT_SIZE(INPUT_SIZE)
  ) mem (
      .clk(clk),
      .rst(rst),
      .r_addr(r_addr),
      .w_addr(w_addr + addr_offset),
      .r_en(r_en),
      .w_en(w_en),
      .in(kernel_out),
      .out(out)
  );

endmodule
