module adder_ladder #(
    parameter N = 3,
    parameter rank_bits = 2
) (
    input [N-2: 0] in,
    output reg [rank_bits-1 : 0] out
);
    
    integer i;
    always @* begin
        out = 0;
        for (i = 0; i < N-1; i = i + 1) begin : adder_ladder
            out = out + in[i];
        end
    end

endmodule