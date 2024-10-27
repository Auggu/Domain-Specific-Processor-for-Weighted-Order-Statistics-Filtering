module tb_memory ();

  reg clk = 0;
  reg rst = 1;
  reg [31:0] address = 0;
  reg [31:0] data_in = 0;
  reg [2:0] func3 = 0;
  reg w_en = 0;
  wire [31:0] data_out;

  memory #(
      .SIZE(255)
  ) uut (
      .clk(~clk),
      .rst(rst),
      .address(address),
      .data_in(data_in),
      .func3(func3),
      .w_en(w_en),
      .data_out(data_out)
  );

  always #10 clk = ~clk;

  initial begin
    $monitor("%h", data_out);
    $dumpfile("out/mem.vcd");
    $dumpvars(0, tb_memory);

    rst = 0;
    #1;
    rst = 1;
    #9;
    w_en = 1;
    address = 3;
    data_in = 32'hDEADBEEF;
    func3 = 0;
    #20;
    w_en = 0;
    func3 = 2;
    address = 0;
    #20;
    address = 3;
    #20;
    #20;
    $finish();
  end

endmodule
