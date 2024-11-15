module branch (
    input [31:0] r1,
    input [31:0] r2,
    input [ 1:0] branch_op,
    input [ 2:0] func3,
    input instr30,
    output reg do_branch
);

parameter [2:0] BEQ = 3'b000;
parameter [2:0] BNE = 3'b001;
parameter [2:0] BLT = 3'b100;
parameter [2:0] BGE  = 3'b101;
parameter [2:0] BLTU = 3'b110;
parameter [2:0] BGEU = 3'b111;

wire signed [31:0] r1_signed = r1;
wire signed [31:0] r2_signed = r2;

always @ (*) begin
  if(branch_op == 2'b00) do_branch = 1'b0;
  else if(branch_op == 2'b10) do_branch = 1'b1;
  else if(branch_op == 2'b01) begin
    case (func3)
      BEQ: do_branch = (r1_signed == r2_signed);
      BNE: do_branch = (r1_signed != r2_signed);
      BLT: do_branch = (r1_signed < r2_signed);
      BGE: do_branch = (r1_signed >= r2_signed);
      BLTU: do_branch = (r1 < r2);
      BGEU: do_branch = (r1 >= r2);
      default: do_branch = 1'b0;
    endcase
  end
end


endmodule
