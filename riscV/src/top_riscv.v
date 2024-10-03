module top_riscv (
    input clk,
    input rst,
    input stall,
    input flush
);

  wire [31:0] instr_f;
  wire [31:0] pc_f;
  wire [31:0] pc4_f;

  fetch #(
      .ROM_SIZE(512)
  ) fetch_stage (
      .clk(clk),
      .rst(rst),
      .pc_sel(),
      .jmp_addr(),
      .stall(stall),
      .flush(flush),
      .o_instruction(instr_f),
      .o_pc(pc_f),
      .o_pc4(pc4_f)
  );

  decode decode_stage (
      .clk(clk),
      .rst(rst),
      .stall(),
      .flush(),
      .i_instr(instr_f),
      .i_pc(pc_f),
      .i_pc4(pc4_f),
      .i_wr_en(),
      .i_wr_idx(),
      .i_wr_data(),
      .o_pc(),
      .o_pc4(),
      .o_reg1(),
      .o_reg2(),
      .o_imm(),
      .o_reg1_sel(),
      .o_reg2_sel(),
      .o_func3(),
      .o_instr30(),
      .o_alu_op(),
      .o_branch_op(),
      .o_mem_w_en(),
      .o_w_idx(),
      .o_wb_sel(),
      .o_wb_en()
  );

endmodule
