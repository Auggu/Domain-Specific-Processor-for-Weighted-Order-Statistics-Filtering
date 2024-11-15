module alu (
    input [31:0] op1,
    input [31:0] op2,
    input [2:0] func3,
    input instr30,
    input [1:0] alu_op,
    input op2_sel, //0:r2 | 1:imm
    output reg [31:0] alu_out
);

parameter [3:0] ADD = 4'b0000;
parameter [3:0] SUB = 4'b1000;
parameter [3:0] XOR = 4'b0100;
parameter [3:0] OR  = 4'b0110;
parameter [3:0] AND = 4'b0111;
parameter [3:0] SLL = 4'b0001;
parameter [3:0] SRL = 4'b0101;
parameter [3:0] SRA = 4'b1101;
parameter [3:0] SLT = 4'b0010;
parameter [3:0] SLTU = 4'b0011;

wire signed [31:0] op1_signed = op1;
wire signed [31:0] op2_signed = op2;
wire func7 = (func3 == 3'd5) | ~op2_sel ? instr30 : 1'b0;


always @ (*) begin
  if(alu_op == 2'b00) alu_out = op1_signed + op2_signed;
  else if(alu_op == 2'b10) alu_out = op2;
  else if(alu_op == 2'b01) begin
    case ({func7 ,func3})
      ADD: alu_out = op1_signed + op2_signed;
      SUB: alu_out = op1_signed - op2_signed;
      XOR: alu_out = op1 ^ op2;
      OR: alu_out = op1 | op2;
      AND: alu_out = op1 & op2;
      SLL: alu_out = op1 << (op2_sel ? op2[4:0] : op2);
      SRL: alu_out = op1 >> (op2_sel ? op2[4:0] : op2);
      SRA: alu_out = op1_signed >>> (op2_sel ? op2[4:0] : op2);
      SLT: alu_out = op1_signed < op2_signed;
      SLTU: alu_out = op1 < op2;
      default: alu_out = op1_signed + op2_signed;
    endcase
  end
end

endmodule


