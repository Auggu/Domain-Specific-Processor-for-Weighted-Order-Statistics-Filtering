module tb_riscV_filter();

reg clk = 0;
reg rst = 0;
reg btn = 0;

riscv_filter uut(
    .clk(clk),
    .rst(rst),
    .start_btn(btn),
    .swt_0(),
    .seven_segs(),
    .led0()
);


always #10 clk = ~clk;

integer i;
initial begin
  $dumpfile ("out/riscv_filter.vcd"); // Change filename as appropriate.
  $dumpvars(0, tb_riscV_filter);

  #20 rst = 1;
  #1 btn = 0;
  #100000;

  for (i = 0; i < 300/4; i = i + 1) begin
    $display("%d,%d", i*4,uut.riscV.memory_stage.memory.gen_mems[0].mem.mem[i]);
    $display("%d,%d", i*4+1,uut.riscV.memory_stage.memory.gen_mems[1].mem.mem[i]);
    $display("%d,%d", i*4+2,uut.riscV.memory_stage.memory.gen_mems[2].mem.mem[i]);
    $display("%d,%d", i*4+3,uut.riscV.memory_stage.memory.gen_mems[3].mem.mem[i]);
  end
  $finish();


end

endmodule
