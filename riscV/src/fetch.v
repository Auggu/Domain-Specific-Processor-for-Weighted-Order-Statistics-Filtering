module fetch (
    input clk,
    input rst,
    input branch,
    input [31:0] jmp_addr
);
  reg [31:0] pc_counter;


  always @(posedge clk) begin
    if (!rst) pc_counter <= 32'd0;
    else begin
      if (pc_sel) pc_counter <= jmp_addr;
      else pc_counter <= pc_counter + 4;
    end
  end

endmodule
