module tb_riscV();
reg clk = 0;
reg rst = 1;
reg signed [31:0] print;
reg start = 1;
top_riscv uut(.clk(clk), .rst(rst), .start_btn(start));

always #10 clk = ~clk;

integer i;
initial begin
$dumpfile("out/riscv.vcd");
$dumpvars(0, tb_riscV);
rst = 0; #20;
rst = 1;
start = 0;
#420
start =1;#20
//start = 0; #420
//start = 0;

#(46*20);
#(512*20);
for (i = 0; i < 32; i = i + 1) begin
   print = uut.decode_stage.regs.regs[i];
   $display("x%0d: %x", i, print);
end
$finish();
end

endmodule
