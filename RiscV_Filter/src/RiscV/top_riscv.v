module top_riscv #(
    parameter MAX_N   = 5,
    parameter ROMSIZE = 512,
    parameter MEMSIZE = 1024
) (
    input clk,
    input rst,
    input start_btn,
    output [31:0] parameters,
    output [31:0] reg_a0,
    output led0
);

  debounce db (
      .clk(clk),
      .btn_in(~start_btn),
      .btn_out(start_btn_db)
  );

  run_module rm (
      .clk(clk),
      .rst(rst),
      .start_btn(start_btn_db),
      .ebreak(ebreak_d),
      .run(run)
  );

  wire clk_rv = clk & run;
  assign led0 = run;

  wire [31:0] instr_f;
  wire [31:0] pc_f;
  wire [31:0] pc4_f;
  wire [31:0] jmp_addr;
  wire do_branch;

  fetch #(
      .ROM_SIZE(ROMSIZE)
  ) fetch_stage (
      .clk(clk_rv),
      .rst(rst),
      .pc_sel(do_branch),
      .jmp_addr(jmp_addr),
      .stall(ld_hazard | kernel_running),
      .flush(do_branch),
      .o_instruction(instr_f),
      .o_pc(pc_f),
      .o_pc4(pc4_f)
  );

  wire [31:0] pc_d, pc4_d, reg1_d, reg2_d, imm_d;
  wire reg1_sel_d, reg2_sel_d, instr30_d, mem_w_en_d, wb_en_d, run_filter_d;
  wire [2:0] func3_d;
  wire [1:0] alu_op_d, branch_op_d, wb_sel_d;
  wire [4:0] w_idx_d;
  wire [4:0] rs1_d;
  wire [4:0] rs2_d;
  wire [4:0] rs1_wire_d;
  wire [4:0] rs2_wire_d;

  decode decode_stage (
      .clk(clk_rv),
      .rst(rst),

      .stall(kernel_running),
      .flush(do_branch | ld_hazard),

      .i_instr(instr_f),
      .i_pc(pc_f), .i_pc4(pc4_f),

      .i_wr_en  (wb_en_wb),
      .i_wr_idx (w_idx_wb),
      .i_wr_data(wb_data_wb),

      .o_pc(pc_d),
      .o_pc4(pc4_d),
      .o_reg1(reg1_d),
      .o_reg2(reg2_d),
      .o_imm(imm_d),
      .o_reg1_sel(reg1_sel_d),
      .o_reg2_sel(reg2_sel_d),
      .o_func3(func3_d),
      .o_instr30(instr30_d),
      .o_alu_op(alu_op_d),
      .o_branch_op(branch_op_d),
      .o_mem_w_en(mem_w_en_d),
      .o_w_idx(w_idx_d),
      .o_wb_sel(wb_sel_d),
      .o_wb_en(wb_en_d),
      .o_rs1(rs1_d),
      .o_rs2(rs2_d),
      .o_wire_rs1(rs1_wire_d),
      .o_wire_rs2(rs2_wire_d),
      .o_reg_a0(reg_a0),
      .o_ebreak(ebreak_d),
      .o_run_filter(run_filter_d)
  );

  wire [31:0] alu_out_e, rs2_e, pc4_e;
  wire mem_w_en_e, wb_en_e;
  wire [2:0] func3_e;
  wire [4:0] w_idx_e;
  wire [1:0] wb_sel_e;

  execute execute_stage (
      .clk(clk_rv),
      .rst(rst),
      .i_pc(pc_d),
      .i_pc4(pc4_d),
      .i_r1(reg1_d),
      .i_r2(reg2_d),
      .i_imm(imm_d),
      .i_r1_sel(reg1_sel_d),
      .i_r2_sel(reg2_sel_d),
      .i_func3(func3_d),
      .i_instr30(instr30_d),
      .i_alu_op(alu_op_d),
      .i_branch_op(branch_op_d),

      .i_wb_fw_data (wb_data_wb),
      .i_mem_fw_data(fw_data_m),
      .i_r1_fw_sel  (r1_fw_sel_fu),
      .i_r2_fw_sel  (r2_fw_sel_fu),

      .i_mem_w_en(mem_w_en_d),
      .i_w_idx(w_idx_d),
      .i_wb_sel(wb_sel_d),
      .i_wb_en(wb_en_d),
      .o_alu_res(alu_out_e),
      .o_rs2(rs2_e),
      .o_mem_w_en(mem_w_en_e),
      .o_func3(func3_e),
      .o_pc4(pc4_e),
      .o_w_idx(w_idx_e),
      .o_wb_sel(wb_sel_e),
      .o_wb_en(wb_en_e),
      .o_alu_res_wire(jmp_addr),
      .o_do_branch(do_branch)
  );

  wire [1:0] r1_fw_sel_fu;
  wire [1:0] r2_fw_sel_fu;
  forwarding_unit fu (
      .i_rs1_e(rs1_d),
      .i_rs2_e(rs2_d),
      .i_wb_idx_m(w_idx_e),
      .i_w_en_m(wb_en_e),
      .i_wb_idx_w(w_idx_m),
      .i_w_en_w(wb_en_wb),
      .o_rs1_fw_sel(r1_fw_sel_fu),
      .o_rs2_fw_sel(r2_fw_sel_fu)
  );

  wire ld_hazard;
  hazard_detection hd (
      .i_rs1_d(rs1_wire_d),
      .i_rs2_d(rs2_wire_d),
      .i_wb_idx_e(w_idx_d),
      .i_wb_sel_e(wb_sel_d),
      .o_ld_hazard(ld_hazard)
  );

  wire [31:0] mem_out_m;
  wire [31:0] pc4_m;
  wire [31:0] fw_data_m;
  wire [31:0] alu_res_m;
  wire [4:0] w_idx_m;
  wire [1:0] wb_sel_m;
  wire [MAX_N*MAX_N-1:0] mask;
  wire wb_en_m;


  mem_stage #(
      .MEM_SIZE(MEMSIZE),
      .MAX_N(MAX_N)
  ) memory_stage (
      .clk(clk_rv),
      .rst(rst),
      .i_alu_res(alu_out_e),
      .i_rs2(rs2_e),
      .i_func3(func3_e),
      .i_mem_w_en(mem_w_en_e),
      .i_w_idx(w_idx_e),
      .i_wb_sel(wb_sel_e),
      .i_wb_en(wb_en_e),
      .i_pc4(pc4_e),
      .o_mem_out(mem_out_m),
      .o_alu_res(alu_res_m),
      .o_w_idx(w_idx_m),
      .o_wb_sel(wb_sel_m),
      .o_wb_en(wb_en_m),
      .o_pc4(pc4_m),
      .o_mem_fw_data(fw_data_m),

      .i_kernel_address(kernel_address),
      .i_kernel_running(kernel_running),
      .i_kernel_w_en(kernel_w_en),
      .i_kernel_input(kernel_out),
      .o_parameters(parameters),
      .o_mask(mask),
      .o_mem_to_kernel(mem_to_kernel)
  );

  wire [31:0] wb_data_wb;
  wire [4:0] w_idx_wb;
  wire wb_en_wb;
  writeback wb_stage (
      .i_mem(mem_out_m),
      .i_alu(alu_res_m),
      .i_pc4(pc4_m),
      .i_w_idx(w_idx_m),
      .i_wb_sel(wb_sel_m),
      .i_wb_en(wb_en_m),

      .o_wb_data(wb_data_wb),
      .o_w_idx  (w_idx_wb),
      .o_wb_en  (wb_en_wb)
  );


  wire new_line, kernel_running, kernel_clk;
  wire [31:0] kernel_address;
  address_handler #(
      .WORD (8),
      .MAX_N(MAX_N)
  ) ah (
      .clk(clk_rv),
      .rst(rst),
      .i_h(parameters[7:0]),
      .i_w(parameters[15:8]),
      .i_n(parameters[23:16]),
      .run(run_filter_d),
      .address(kernel_address),
      .w_en(kernel_w_en),
      .r_en(kernel_r_en),
      .kernel_newline(newline),
      .kernel_running(kernel_running),
      .kernel_clk(kernel_clk)
  );

  wire [7:0] kernel_out, mem_to_kernel;
  wire kernel_rst = rst & ~newline;
  wire [7:0] kernel_in = kernel_r_en ? mem_to_kernel : 8'd0 ;

  masked_rank_order #(
    .N(MAX_N*MAX_N),
    .DATA_BITS(8)
  ) kernel (
    .clk(kernel_clk),
    .rst(kernel_rst),
    .i_new(kernel_in),
    .i_mask(mask),
    .rank_sel(parameters[31:24]),
    .out(kernel_out)
  );

endmodule
