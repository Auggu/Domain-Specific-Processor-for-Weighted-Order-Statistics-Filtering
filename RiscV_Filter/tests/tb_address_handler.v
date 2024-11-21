module tb_address_handler ();

  reg clk = 0;
  reg rst = 0;
  reg run = 0;
  reg [7:0] h = 10;
  reg [7:0] w = 10;
  reg [7:0] r = 3;
  reg [7:0] n = 3;

  address_handler #(
      .WORD (8),
      .MAX_N(3)
  ) uut (
      .clk(clk),
      .rst(rst),
      .h(h),
      .w(w),
      .n(n),
      .run(run),
      .address(),
      .w_en(),
      .r_en(),
      .kernel_newline(),
      .kernel_clk(),
      .kernel_running()
  );

  always #10 clk = ~clk;

  initial begin
  $dumpfile ("out/address_handler.vcd"); // Change filename as appropriate.
  $dumpvars(0, tb_address_handler);
    #5 rst = 1;
    #3;
    run = 1;
    #3
    run = 0;
    #10000;
    $finish();
  end

endmodule
