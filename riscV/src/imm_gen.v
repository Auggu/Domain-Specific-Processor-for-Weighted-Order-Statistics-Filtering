module imm_gen (
    input  [31:0] instr,
    output [31:0] imm
);

  parameter [6:0] IM_ARTIH  = 7'b0010011;
  parameter [6:0] LOAD      = 7'b0000011;
  parameter [6:0] STORE     = 7'b0100011;
  parameter [6:0] BRANCH    = 7'b1100011;
  parameter [6:0] JAL       = 7'b1101111;
  parameter [6:0] JALR      = 7'b1100111;
  parameter [6:0] LUI       = 7'b0110111;
  parameter [6:0] AUIPC     = 7'b0010111;

  wire [31:0] i = {{20{1'b0}}, instr[11:0]};
  wire [31:0] s = {{20{1'b0}}, instr[11:5], instr[11:7]};
  wire [31:0] b = 

  always @(*) begin
    case (instr[6:0])
      7'b0010011: imm <= {{20{1'b0}}, instr[11:0]};  //I imm-arith
      7'b0000011: imm <= {{20{1'b0}}, instr[11:0]};  //I load
      7'b0100011: imm <= {{20{1'b0}}, instr[11:5], instr[11:7]};  //S store
      7'b0000011: imm <= {{20{1'b0}}, instr[11:5], instr[11:7]};
      default: imm <= 32'b0;
    endcase
  end

endmodule
