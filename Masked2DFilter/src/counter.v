module counter #(
    parameter COUNT_BITS = 16
) (
    input clk,
    input rst,
    input  do_count,
    output reg [COUNT_BITS-1:0] count
);

always @ (posedge clk or negedge rst) begin
  if(!rst) count <= 0;
  else begin
    if(do_count) count <= count + 1;
  end
end

endmodule
