module tb_masked2D_filter;

  parameter N = 3;
  parameter WORD = 32;
  parameter MAX_N = 25;
  parameter INPUT_SIZE = 8;
  parameter N_BITS = $clog2(MAX_N);
  parameter MAX_K = MAX_N >> 1;
  parameter MAX_C = $clog2(MAX_N);
  parameter H = 15;
  parameter W = 10;
  parameter KERNEL_SIZE = MAX_N * MAX_N;
  parameter R_BITS = $clog2(KERNEL_SIZE+1);

  reg clk = 0;
  reg rst = 1;
  reg [WORD-1:0] h = H;
  reg [WORD-1:0] w = W;
  reg [N_BITS-1:0] n = N;
  reg [KERNEL_SIZE-1:0] mask = {{N*N{1'b1}}, {KERNEL_SIZE-N*N{1'b0}}};
  reg [R_BITS-1:0] rank_sel = N*N/2+1;

 masked_2D_filter #(
   .WORD(WORD),
   .MAX_N(MAX_N),
   .INPUT_SIZE(INPUT_SIZE)
) uut (
    .clk(clk),
    .rst(rst),
    .h(h),
    .w(w),
    .n(n),
    .mask(mask),
    .rank_sel(rank_sel)
  );

  reg [7:0] picture[H*W-1 : 0];

  always #10 clk = ~clk;


  always @(posedge clk) $display(address);

  initial begin
    $dumpfile("out/input_selector.vcd");
    $dumpvars(0, tb_input_selector);
    //$monitor(address);
    //$monitor(uut.yc);
    rst = 0;
    #1 rst = 1;

    for (integer i = 0; i < H * W; i = i + 1) begin
      picture[i] = i;
    end

    for (integer i = 0; i < 1040; i = i + 1) begin #20; end $finish; end
endmodule
