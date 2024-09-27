module registers (
    input clk,
    input rst,
    input wr_en,
    input [4:0] rd_idx1,
    input [4:0] rd_idx2,
    input [4:0] wr_idx,
    input [31:0] wr_data,
    output [31:0] reg1,
    output [31:0] reg2
);

  reg [31:0] regs[0:31];

  assign reg1 = regs[rd_idx1];
  assign reg2 = regs[rd_idx2];

  always @(negedge clk) begin
    if (wr_en) regs[wr_idx] <= wr_data;
  end

  integer i;
  always @(negedge rst) begin
    for (i = 0; i < 32; i = i + 1) begin
      regs[0] <= 32'b0;
    end
  end

endmodule
