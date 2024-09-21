module tb_masked_rank_order ();

  parameter N = 11;
  parameter rank_bits = $clog2(N);
  parameter data_bits = 8;

  parameter no_in = 18;
  parameter run_time = (no_in + 1) * 20;

  reg clk = 0;
  reg rst = 1;
  reg [N-1 : 0] mask = 11'b11100000000;
  reg [data_bits-1 : 0] in = 0;
  reg [$clog2(N+1)-1 : 0] rank_sel = 2;
  wire [data_bits-1 : 0] out;

  reg [data_bits:0] data[no_in-1:0];
  reg [$clog2(no_in)-1 : 0] addr = 0;

  always @(posedge clk) begin
    in   <= data[addr];
    addr <= addr + 1;
  end
  masked_rank_order #(N, data_bits) uut (
      clk,
      rst,
      in,
      mask,
      rank_sel,
      out
  );

  always #10 clk = ~clk;
  initial begin
    $dumpfile("out/masked_rank_order.vcd");
    $dumpvars(0, tb_masked_rank_order);
    $readmemh("tests/test.hex", data, 0, no_in - 1);
    rst = 0;
    #1 rst = 1;
    $display("in s4 s3 s2 s1 s0 r4 r3 r2 r1 r0 out");
    for (integer i = 0; i < no_in; i = i + 1) begin
      $write("%0d ", in);
      for (integer j = N - 1; j >= 0; j = j - 1) begin
        $write("%0d ", uut.s[j*8+:8]);
      end
      for (integer j = N - 1; j >= 0; j = j - 1) begin
        $write("%0d ", uut.r[j*rank_bits+:rank_bits]);
      end
      $write("%0d", out);
      $display();
      #20;
    end
    $display("");

    $finish;
  end

endmodule

