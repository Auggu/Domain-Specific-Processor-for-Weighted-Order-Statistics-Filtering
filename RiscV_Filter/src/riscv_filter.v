module riscv_filter (
    input clk,
    input rst,
    input start_btn,
    input swt_0,
    output [55:0] seven_segs,
    output led0
);

  parameter MAX_N = 5;
  parameter WORD = 8;
  parameter ROMSIZE = 512;
  parameter MEMSIZE = 1024;


  wire [31:0] parameters;
  wire [31:0] reg_a0;

  top_riscv #(
      .MAX_N  (MAX_N),
      .ROMSIZE(ROMSIZE),
      .MEMSIZE(MEMSIZE)
  ) riscV (
      .clk(clk),
      .rst(rst),
      .start_btn(start_btn),
      .parameters(parameters),
      .reg_a0(reg_a0),
      .led0(led0)
  );

  wire [31:0] ss_in = swt_0 ? parameters : reg_a0;

  genvar i;
  generate for (i = 0; i < 8; i = i + 1) begin : gen_seven_seg
      seven_seg ss (
          .in (ss_in[i*4+:4]),
          .out(seven_segs[i*7+:7])
      );
    end
  endgenerate

endmodule
