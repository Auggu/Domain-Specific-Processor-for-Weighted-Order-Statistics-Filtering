module imm_gen (
    input [31:0] instr,
    output reg [31:0] imm
);

  parameter [6:0] IM_ARTIH  = 7'b0010011;
  parameter [6:0] LOAD      = 7'b0000011;
  parameter [6:0] STORE     = 7'b0100011;
  parameter [6:0] BRANCH    = 7'b1100011;
  parameter [6:0] JAL       = 7'b1101111;
  parameter [6:0] JALR      = 7'b1100111;
  parameter [6:0] LUI       = 7'b0110111;
  parameter [6:0] AUIPC     = 7'b0010111;

  //wire [31:0] i = {{20{1'b0}}, instr[11:0]};
  wire [31:0] i = {{20{instr[31]}}, instr[31:20]};
  wire [31:0] s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
  wire [31:0] b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
  wire [31:0] u = {instr[31:12], 12'b0};
  wire [31:0] j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

  always @(*) begin
    case (instr[6:0])
      IM_ARTIH: imm = i;
      LOAD: imm = i;
      STORE: imm = s;
      BRANCH: imm = b;
      JAL: imm = j;
      JALR: imm = i;
      LUI: imm = u;
      AUIPC: imm = u;
      default: imm = 32'b0;
    endcase
  end

endmodule
