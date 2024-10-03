module tb_imm_gen ();

reg [31:0]instr = 32'b0;
wire signed[31:0] imm;
imm_gen uut(.instr(instr), .imm(imm));

initial begin
$monitor("%h",imm);
instr = 32'h1a400293;#1
instr = 32'he5c00293;#1
instr = 32'h900002b7;#1
instr = 32'hfff28293;#1;
instr = 32'h2dbde0ef;#1;
instr = 32'h2dbde0ef;#1;
instr = 32'hbe502423;#1;

end

endmodule

