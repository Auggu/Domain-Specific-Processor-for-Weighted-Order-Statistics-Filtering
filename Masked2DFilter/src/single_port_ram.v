module single_port_ram #(
    parameter SIZE = 255,
    parameter INPUT_SIZE = 8
) (
    input clk,
    input [ADDR_BITS-1:0] addr,
    input w_en,
    input [INPUT_SIZE-1:0] in,
    output reg  [INPUT_SIZE-1:0] out
);

  parameter ADDR_BITS = $clog2(SIZE) ;

  reg [INPUT_SIZE-1:0] mem [SIZE-1:0];



  always @(posedge clk) begin
    out = mem[addr];
  end


  always @(posedge clk) begin
      if (w_en) mem[addr] <= in;
      else mem[addr] <= mem[addr];
  end

endmodule
