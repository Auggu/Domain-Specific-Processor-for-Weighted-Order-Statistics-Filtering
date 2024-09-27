module fetch #(
    parameter ROM_SIZE = 512
) (
    input clk,
    input rst,
    input pc_sel,
    input [31:0] jmp_addr,
    output reg [31:0] o_instruction,
    output reg [31:0] o_pc
);

  reg [31:0] pc = 0;

  reg [7:0] rom[0:ROM_SIZE-1];
  wire [31:0] rom_out;
  assign rom_out = {rom[pc+3], rom[pc+2], rom[pc+1], rom[pc]};

  always @(posedge clk) begin
    if (!rst) pc <= 32'd0;
    else begin
      if (pc_sel) pc <= jmp_addr;
      else pc <= pc + 4;
    end
  end

  always @(posedge clk) begin
    if(!rst) begin
      o_instruction <= 32'd0;
      o_pc <= 32'd0;
    end else begin
      o_instruction <= rom_out;
      o_pc <= pc;
    end
  end


  initial begin
    $readmemh("program.hex" ,rom);
  end

endmodule
