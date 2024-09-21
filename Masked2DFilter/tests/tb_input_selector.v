module tb_input_selector;

  parameter N = 5;

  parameter WORD = 32;
  parameter INPUT_SIZE = 8;
  parameter MAX_N = 25;
  parameter N_BITS = $clog2(MAX_N);
  parameter MAX_K = MAX_N >> 1;
  parameter MAX_C = $clog2(MAX_N);
  parameter H = 15;
  parameter W = 10;


  reg clk = 0;
  reg rst = 1;
  reg [WORD-1:0] h = H;
  reg [WORD-1:0] w = W;
  reg [N_BITS-1:0] n = N;
  wire [WORD-1:0] r_addr;
  wire [WORD-1:0] w_addr;
  wire [INPUT_SIZE-1:0] in;
  wire [INPUT_SIZE-1:0] out;

  address_handler #(
      .WORD (WORD),
      .MAX_N(MAX_N)
  ) uut (
      .clk(clk),
      .rst(rst),
      .h(h),
      .w(w),
      .n(n),
      .r_addr(r_addr),
      .w_addr(w_addr)
  );

  wire [WORD-1:0] w_addr_offset;
  assign w_addr_offset = w_addr + w*h;

  memory #(
      .WORD(WORD),
      .INPUT_SIZE(INPUT_SIZE)
  ) mem (
      .clk(clk),
      .rst(rst),
      .r_addr(r_addr),
      .w_addr(w_addr_offset),
      .r_en(r_en),
      .w_en(w_en),
      .in(in),
      .out(out)
  );


  always #10 clk = ~clk;

  integer clk_count = 0;

  always @(posedge clk) begin
    $display("clk=%0d", clk_count);
    clk_count = clk_count + 1;
    if (uut.r_en) $display("r_addr=%0d", r_addr);
    else $display("r_addr=%0d", 0);
  end

  always @(posedge clk) begin
    if (uut.w_en) $display("w_addr=%0d", uut.w_addr);
  end

  initial begin
    $dumpfile("out/input_selector.vcd");
    $dumpvars(0, tb_input_selector);
    //$monitor(r_addr);
    //$monitor(uut.yc);
    rst = 0;
    #1 rst = 1;

    for (integer i = 0; i < H * W; i = i + 1) begin
      mem.memory[i] = i;
    end

    for (integer i = 0; i < 1040; i = i + 1) begin
      #20;
    end

    $finish;
  end

endmodule
