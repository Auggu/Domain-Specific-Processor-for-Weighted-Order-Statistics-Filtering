module decode (
    input clk,
    input rst,
    input reg_write,
    input [31:0] instr,
    input [31:0] pc,
    input [4:0] wr_idx,
    input [31:0] wr_data
);

  wire [31:0] reg1_wire;
  wire [31:0] reg2_wire;

  registers regs(
      .clk(clk),
      .rst(rst),
      .wr_en(reg_write),
      .rd_idx1(instr[19:15]),
      .rd_idx2(instr[24:20]),
      .wr_idx(wr_idx),
      .wr_data(wr_data),
      .reg1(reg1_wire),
      .reg2(reg2_wire),
  );

  wire [31:0]imm_wire;
  imm_gen ig (.instr(instr), .imm(imm));


endmodule
