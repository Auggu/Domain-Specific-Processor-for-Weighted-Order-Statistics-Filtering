module fetch #(
    parameter ROM_SIZE = 512
) (
    input clk,
    input rst,
    input pc_sel,
    input [31:0] jmp_addr,
    input stall,
    input flush,
    output reg [31:0] o_instruction,
    output reg [31:0] o_pc,
    output reg [31:0] o_pc4
);

  reg [31:0] pc;
  wire [31:0] pc4 = pc + 4;

  reg [31:0] rom[0:ROM_SIZE-1];
  wire [31:0] rom_out;
  assign rom_out = rom[pc[31:2]];

  always @(posedge clk or negedge rst) begin
    if (!rst) pc <= 0;
    else if (!stall) begin
      if (pc_sel) pc <= jmp_addr;
      else pc <= pc4;
    end
  end

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      o_instruction <= 0;
      o_pc <= 0;
      o_pc4 <= 0;
    end else if (!stall) begin
      if (flush) begin
        o_instruction <= 0;
        o_pc <= 0;
        o_pc4 <= 0;
      end else begin
        o_instruction <= rom_out;
        o_pc <= pc;
        o_pc4 <= pc4;
      end
    end
  end

  initial begin
    $readmemh("program.hex", rom);
  end

endmodule
