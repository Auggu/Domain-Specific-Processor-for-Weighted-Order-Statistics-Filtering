module debounce #(
    parameter CYCLES = 20
) (
    input clk,
    input btn_in,
    output reg btn_out =0
);

   reg [CYCLES-1:0] shift_reg = 0;
   assign stable = &shift_reg;

   always @ (posedge clk) begin
    shift_reg <= {shift_reg[CYCLES-2:0], btn_in};
    if(stable)
        btn_out <= 1;
    else
        btn_out <= 0;
   end
endmodule

