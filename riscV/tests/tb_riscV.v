module tb_riscV();
reg clk = 0;
reg rst = 1;
reg signed [31:0] print;

top_riscv uut(.clk(clk), .rst(rst));

always #10 clk = ~clk;

integer i;
initial begin
$dumpfile("out/riscv.vcd");
$dumpvars(0, tb_riscV);
rst = 0; #20;
rst = 1;
#(46*20);

for (i = 0; i < 32; i = i + 1) begin
   print = uut.decode_stage.regs.regs[i];
   $display("x%0d: %d", i, print);
end
$finish();
end

endmodule
