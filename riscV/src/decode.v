module decode (
    input clk,
    input rst,

    input stall,
    input flush,

    input [31:0] i_instr,
    input [31:0] i_pc,
    input [31:0] i_pc4,

    input i_wr_en,
    input [4:0] i_wr_idx,
    input [31:0] i_wr_data,

    //EX
    output reg [31:0] o_pc,
    output reg [31:0] o_pc4,
    output reg [31:0] o_reg1,
    output reg [31:0] o_reg2,
    output reg [31:0] o_imm,
    output reg o_reg1_sel,
    output reg o_reg2_sel,
    output reg [2:0] o_func3,
    output reg o_instr30,
    output reg [1:0] o_alu_op,
    output reg [1:0] o_branch_op,

    //MEM
    output reg o_mem_w_en,

    //WB
    output reg [4:0] o_w_idx,
    output reg [1:0] o_wb_sel,
    output reg o_wb_en,

    //Forwarding Unit
    output reg [4:0] o_rs1,
    output reg [4:0] o_rs2,
    //Harzard detection
    output [4:0] o_wire_rs1,
    output [4:0] o_wire_rs2
);

  wire [6:0] opcode = i_instr[6:0];
  wire [4:0] rd = i_instr[11:7];
  wire [2:0] funct3 = i_instr[14:12];
  wire [4:0] rs1 = i_instr[19:15];
  wire [4:0] rs2 = i_instr[24:20];
  wire instr30 = i_instr[30];


  wire [31:0] reg1_wire;
  wire [31:0] reg2_wire;

  registers regs (
      .clk(clk),
      .rst(rst),
      .wr_en(i_wr_en),
      .rd_idx1(rs1),
      .rd_idx2(rs2),
      .wr_idx(i_wr_idx),
      .wr_data(i_wr_data),
      .reg1(reg1_wire),
      .reg2(reg2_wire)
  );

  wire [31:0] imm_wire;
  imm_gen ig (
      .instr(i_instr),
      .imm  (imm_wire)
  );

  wire [1:0] alu_op;
  wire [1:0] branch_op;
  wire [1:0] wb_sel;
  wire r1_sel, r2_sel, mem_wr_en, wb_en;
  control control_unit (
    .opcode(opcode),
    .r1_sel(r1_sel),
    .r2_sel(r2_sel),
    .alu_op(alu_op),
    .branch_op(branch_op),
    .mem_wr_en(mem_wr_en),
    .wb_sel(wb_sel),
    .wb_en(wb_en)
  );

  assign o_wire_rs1 = rs1;
  assign o_wire_rs2 = rs2;

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      o_pc <= 0;
      o_pc4 <= 0;
      o_reg1 <= 0;
      o_reg2 <= 0;
      o_imm <= 0;
      o_reg1_sel <= 0;
      o_reg2_sel <= 0;
      o_func3 <= 0;
      o_instr30 <= 0;
      o_alu_op <= 0;
      o_branch_op <= 0;
      o_mem_w_en <= 0;
      o_w_idx <= 0;
      o_wb_sel <= 0;
      o_wb_en <= 0;
      o_rs1 <= 0;
      o_rs2 <= 0;
    end else if (!stall) begin
      if (flush) begin
        o_pc <= 0;
        o_pc4 <= 0;
        o_reg1 <= 0;
        o_reg2 <= 0;
        o_imm <= 0;
        o_reg1_sel <= 0;
        o_reg2_sel <= 0;
        o_func3 <= 0;
        o_instr30 <= 0;
        o_alu_op <= 0;
        o_branch_op <= 0;
        o_mem_w_en <= 0;
        o_w_idx <= 0;
        o_wb_sel <= 0;
        o_wb_en <= 0;
        o_rs1 <= 0;
        o_rs2 <= 0;
      end else begin
        o_pc <= i_pc;
        o_pc4 <= i_pc4;
        o_reg1 <= reg1_wire;
        o_reg2 <= reg2_wire;
        o_imm <= imm_wire;
        o_reg1_sel <= r1_sel;
        o_reg2_sel <= r2_sel;
        o_func3 <= funct3;
        o_instr30 <= instr30;
        o_alu_op <= alu_op;
        o_branch_op <= branch_op;
        o_mem_w_en <= mem_wr_en;
        o_w_idx <= rd;
        o_wb_sel <= wb_sel;
        o_wb_en <= wb_en;
        o_rs1 <= rs1;
        o_rs2 <= rs2;
      end
    end
  end

endmodule

module control (
    input [6:0] opcode,

    output reg r1_sel,
    output reg r2_sel,
    output reg [1:0] alu_op,
    output reg [1:0] branch_op,
    output reg mem_wr_en,
    output reg [1:0] wb_sel,
    output reg wb_en
);

  parameter [6:0] ARTIH     = 7'b0110011;
  parameter [6:0] IM_ARTIH  = 7'b0010011;
  parameter [6:0] LOAD      = 7'b0000011;
  parameter [6:0] STORE     = 7'b0100011;
  parameter [6:0] BRANCH    = 7'b1100011;
  parameter [6:0] JAL       = 7'b1101111;
  parameter [6:0] JALR      = 7'b1100111;
  parameter [6:0] LUI       = 7'b0110111;
  parameter [6:0] AUIPC     = 7'b0010111;

  always @(*) begin
    case (opcode)
      ARTIH: begin
        r1_sel = 1'b0;  //0: reg1,  1: pc
        r2_sel = 1'b0;  //0: reg2,  1: imm
        alu_op = 2'b01;  //00: add, 01: func3, 10: lui
        mem_wr_en = 1'b0;
        branch_op = 2'b00;  //00: no-branch, 01: func3, 10: jmp
        wb_sel = 2'b00;  //00: alu, 01: memory, 10: pc4
        wb_en = 1'b1;
      end

      IM_ARTIH: begin
        r1_sel = 1'b0;  //0: reg1,  1: pc
        r2_sel = 1'b1;  //0: reg2,  1: imm
        alu_op = 2'b01;  //00: add, 01: func3, 10: lui
        mem_wr_en = 1'b0;
        branch_op = 2'b00;  //00: no-branch, 01: func3, 10: jmp
        wb_sel = 2'b00;  //00: alu, 01: memory, 10: pc4
        wb_en = 1'b1;
      end

      LOAD: begin
        r1_sel = 1'b0;  //0: reg1,  1: pc
        r2_sel = 1'b1;  //0: reg2,  1: imm
        alu_op = 2'b00;  //00: add, 01: func3, 10: lui
        mem_wr_en = 1'b0;
        branch_op = 2'b00;  //00: no-branch, 01: func3, 10: jmp
        wb_sel = 2'b01;  //00: alu, 01: memory, 10: pc4
        wb_en = 1'b1;
      end

      STORE: begin
        r1_sel = 1'b0;  //0: reg1,  1: pc
        r2_sel = 1'b1;  //0: reg2,  1: imm
        alu_op = 2'b00;  //00: add, 01: func3, 10: lui
        mem_wr_en = 1'b1;
        branch_op = 2'b00;  //00: no-branch, 01: func3, 10: jmp
        wb_sel = 2'b00;  //00: alu, 01: memory, 10: pc4
        wb_en = 1'b0;
      end

      BRANCH: begin
        r1_sel = 1'b1;  //0: reg1,  1: pc
        r2_sel = 1'b1;  //0: reg2,  1: imm
        alu_op = 2'b00;  //00: add, 01: func3, 10: lui
        mem_wr_en = 1'b0;
        branch_op = 2'b01;  //00: no-branch, 01: func3, 10: jmp
        wb_sel = 2'b00;  //00: alu, 01: memory, 10: pc4
        wb_en = 1'b0;
      end

      JAL: begin
        r1_sel = 1'b1;  //0: reg1,  1: pc
        r2_sel = 1'b1;  //0: reg2,  1: imm
        alu_op = 2'b00;  //00: add, 01: func3, 10: lui
        mem_wr_en = 1'b0;
        branch_op = 2'b10;  //00: no-branch, 01: func3, 10: jmp
        wb_sel = 2'b10;  //00: alu, 01: memory, 10: pc4
        wb_en = 1'b1;
      end

      JALR: begin
        r1_sel = 1'b0;  //0: reg1,  1: pc
        r2_sel = 1'b1;  //0: reg2,  1: imm
        alu_op = 2'b00;  //00: add, 01: func3, 10: lui
        mem_wr_en = 1'b0;
        branch_op = 2'b10;  //00: no-branch, 01: func3, 10: jmp
        wb_sel = 2'b10;  //00: alu, 01: memory, 10: pc4
        wb_en = 1'b1;
      end

      LUI: begin
        r1_sel = 1'b0;  //0: reg1,  1: pc
        r2_sel = 1'b1;  //0: reg2,  1: imm
        alu_op = 2'b10;  //00: add, 01: func3, 10: lui
        mem_wr_en = 1'b0;
        branch_op = 2'b00;  //00: no-branch, 01: func3, 10: jmp
        wb_sel = 2'b00;  //00: alu, 01: memory, 10: pc4
        wb_en = 1'b1;
      end

      AUIPC: begin
        r1_sel = 1'b1;  //0: reg1,  1: pc
        r2_sel = 1'b1;  //0: reg2,  1: imm
        alu_op = 2'b00;  //00: add, 01: func3, 10: lui
        mem_wr_en = 1'b0;
        branch_op = 2'b00;  //00: no-branch, 01: func3, 10: jmp
        wb_sel = 2'b00;  //00: alu, 01: memory, 10: pc4
        wb_en = 1'b1;
      end

      default: begin
        r1_sel = 1'b0;  //0: reg1,  1: pc
        r2_sel = 1'b0;  //0: reg2,  1: imm
        alu_op = 2'b00;  //00: add, 01: func3, 10: lui
        mem_wr_en = 1'b0;
        branch_op = 2'b00;  //00: no-branch, 01: func3, 10: jmp
        wb_sel = 2'b00;  //00: alu, 01: memory, 10: pc4
        wb_en = 1'b0;
      end

    endcase
  end

endmodule

