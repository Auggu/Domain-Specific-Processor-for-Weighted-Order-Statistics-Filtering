module memory #(
    parameter SIZE = 512
) (
  input clk,
  input rst,
  input addr
);

  reg [31:0] mem[SIZE:0];


endmodule

