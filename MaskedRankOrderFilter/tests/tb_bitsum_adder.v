module tb_bitsum_adder;

  reg  [8:0] in = 9'b0;
  wire [3:0] out;

  bitsum_tree #(
      .N(9)
  ) uut (
      .in (in),
      .out(out)
  );

  initial begin
    $dumpfile("out/bitsum_tree.vcd");
    $dumpvars(0, tb_bitsum_adder);
    $monitor(out);
    #1
    in = 9'b000000000;
    #1
    in = 9'b000000100;
    #1
    in = 9'b111111111;
    #1
    in = 9'b101010101;
    #1
    in = 9'b100000000;
    #1
    $finish;
  end

endmodule
