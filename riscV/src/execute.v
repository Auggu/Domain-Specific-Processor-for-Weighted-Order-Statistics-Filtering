module execute (
    ////// INPUTS ///////////////
    input clk,
    input rst,

    input [31:0] i_pc,
    input [31:0] i_pc4,
    input [31:0] i_r1,
    input [31:0] i_r2,
    input [31:0] i_imm,
    input i_r1_sel,
    input i_r2_sel,
    input [2:0] i_func3,
    input i_instr30,
    input [1:0] i_alu_op,
    input [1:0] i_branch_op,

    input [31:0] i_wb_fw_data,
    input [31:0] i_mem_fw_data,
    input [ 1:0] i_r1_fw_sel,
    input [ 1:0] i_r2_fw_sel,
    input i_mem_w_en,

    //WB
    input [4:0] i_w_idx,
    input [1:0] i_wb_sel,
    input i_wb_en,
    /////// OUTPUTS ///////////////
    //
    //mem
    output reg [31:0] o_alu_res,
    output reg [31:0] o_rs2,
    output reg o_mem_w_en,
    output reg [2:0] o_func3,

    //WB
    output reg [31:0] o_pc4,
    output reg [4:0] o_w_idx,
    output reg [1:0] o_wb_sel,
    output reg o_wb_en,

    //Fetch
    output [31:0] o_alu_res_wire,
    output o_do_branch
);

  wire [31:0] r1;
  wire [31:0] r2;
  mux3 r1_mux3 (
      .sel(i_r1_fw_sel),
      .a  (i_r1),
      .b  (i_mem_fw_data),
      .c  (i_wb_fw_data),
      .out(r1)
  );
  mux3 r2_mux3 (
      .sel(i_r2_fw_sel),
      .a  (i_r2),
      .b  (i_mem_fw_data),
      .c  (i_wb_fw_data),
      .out(r2)
  );

  wire [31:0] op1 = i_r1_sel ? i_pc : r1;
  wire [31:0] op2 = i_r2_sel ? i_imm : r2;

  wire [31:0] alu_out;
  assign o_alu_res_wire = alu_out;

  alu alu (
      .op1(op1),
      .op2(op2),
      .func3(i_func3),
      .instr30(i_instr30),
      .op2_sel(i_r2_sel),
      .alu_op(i_alu_op),
      .alu_out(alu_out)
  );

  branch branch_unit (
      .r1(r1),
      .r2(r2),
      .branch_op(i_branch_op),
      .func3(i_func3),
      .instr30(i_instr30),
      .do_branch(o_do_branch)
  );

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      o_alu_res <= 0;
      o_rs2 <= 0;
      o_mem_w_en <= 0;
      o_func3 <= 0;
      o_pc4 <= 0;
      o_w_idx <= 0;
      o_wb_sel <= 0;
      o_wb_en <= 0;
    end else begin
      o_alu_res <= alu_out;
      o_rs2 <= r2; o_mem_w_en <= i_mem_w_en;
      o_func3 <= i_func3;
      o_pc4 <= i_pc4;
      o_w_idx <= i_w_idx;
      o_wb_sel <= i_wb_sel;
      o_wb_en <= i_wb_en;
    end
  end


endmodule

