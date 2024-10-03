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

  reg [31:0] regs[1:31];

  assign reg1 = rd_idx1 == 5'b0 ? 32'b0 : regs[rd_idx1];
  assign reg2 = rd_idx2 == 5'b0 ? 32'b0 : regs[rd_idx2];

  always @(negedge clk or negedge rst) begin
    if (!rst) begin
      integer i;
      for (i = 1; i < 32; i = i + 1) begin
        regs[i] <= 0;
      end
    end else if (wr_en && wr_idx != 5'b0) begin
      regs[wr_idx] <= wr_data;
    end
  end

  endmodule
