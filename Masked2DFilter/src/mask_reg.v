module mask_reg #(
    parameter MAX_N = 9,
    parameter INPUT_SIZE = 8
) (
    input clk,
    input [ADDR_BITS-1:0] addr,
    input w_en,
    input [INPUT_SIZE-1:0] in,
    output [MASK_BITS-1:0] mask
);

  parameter MASK_BITS = MAX_N * MAX_N;
  parameter MEM_SIZE = (MASK_BITS + INPUT_SIZE - 1) / 8;
  parameter ADDR_BITS = $clog2(MEM_SIZE);

  reg [INPUT_SIZE-1:0] register[MEM_SIZE-1:0];
  reg [MEM_SIZE * INPUT_SIZE-1:0] reg_out;
  reg [MEM_SIZE * INPUT_SIZE-1:0] reg_out_flipped;

  assign mask = reg_out_flipped[MEM_SIZE * INPUT_SIZE-1-:MASK_BITS];

  integer i;
  always @(*) begin
    for (i = 0; i < MEM_SIZE; i = i + 1) begin
      reg_out[i*INPUT_SIZE+:INPUT_SIZE] = register[i];
    end
  end

  always @(*) begin
    for (i = 0; i < MEM_SIZE * INPUT_SIZE; i = i + 1) begin
      reg_out_flipped[i] = reg_out[MEM_SIZE * INPUT_SIZE-i-1];
    end
  end

  always @(posedge clk) begin
    if (w_en) register[addr] <= in;
  end

endmodule
