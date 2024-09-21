module parameters #(
    parameter INPUT_SIZE = 8
) (
    input clk,
    input [1:0] sel,
    input  w_en,
    input [INPUT_SIZE-1: 0] in,
    output reg [INPUT_SIZE-1: 0] n,
    output reg [INPUT_SIZE-1: 0] h,
    output reg [INPUT_SIZE-1: 0] w,
    output reg [INPUT_SIZE-1: 0] r
);

  always @(posedge clk) begin
   if (w_en) begin
     case (sel)
       2'b00: n <= in;
       2'b01: h <= in;
       2'b10: w <= in;
       2'b11: r <= in;
       default: n <= in;
     endcase
   end
  end

endmodule
