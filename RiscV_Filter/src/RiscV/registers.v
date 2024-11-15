module registers (
    input clk,
    input rst,
    input wr_en,
    input [4:0] rd_idx1,
    input [4:0] rd_idx2,
    input [4:0] wr_idx,
    input [31:0] wr_data,
    output [31:0] reg1,
    output [31:0] reg2,
    output [31:0] reg_a0
);

  reg [31:0] regs [0:31];
  assign reg_a0 = regs[10];

  assign reg1 = rd_idx1 != 5'b0 ? regs[rd_idx1] : 32'b0;
  assign reg2 = rd_idx2 != 5'b0 ? regs[rd_idx2] : 32'b0;

  integer i;
  always @(negedge clk or negedge rst) begin
    if (!rst) begin
      for (i = 0; i < 32; i = i + 1) begin
        regs[i] <= 0;
      end
    end else begin
      if (wr_en) begin
        regs[wr_idx] <= wr_data;
      end
    end
  end
  
  endmodule
