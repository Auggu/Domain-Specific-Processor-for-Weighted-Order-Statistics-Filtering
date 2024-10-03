module tb_alu ();

  reg [31:0] op1 = 4;
  reg [31:0] op2 = 2;
  reg [2:0] func3 = 0;
  reg instr30 = 0;
  reg [1:0] alu_op = 1;
  wire [31:0] alu_out;

  alu uut (
      .op1(op1),
      .op2(op2),
      .func3(func3),
      .instr30(instr30),
      .alu_op(alu_op),
      .alu_out(alu_out)
  );

  initial begin
    $monitor("%d", alu_out);
    $monitor("%b", alu_out);
    #1;
    op1 = 20;
    op2 = -15;
    #1
    instr30 = 1;
    #2;
    op1 = -256;
    op2 = 1;
    func3 = 3'b101;
    #2
    instr30 = 0;
    #2;
    op1 = -3;
    op2 = 5;
    func3 = 2;
    #1;
    func3 = 3;
    #1;
    alu_op = 2;
    #1;
    alu_op = 0;
    #1;

  end
endmodule
