module adder_ladder #(
    parameter N = 7,
    parameter rank_bits = $clog2(N+1)
) (
    input [N-2: 0] in,
    input [(N-3)/2-1 : 0] k,
    output reg [rank_bits-1 : 0] out
);
    
    reg [N-2 : 0] filter;

    integer i;
    always @(*) begin
        filter[1:0] = in[1:0];
        for(i = 2; i < N-1; i = i+1) begin
            filter[i] = k[(i-2) / 2] ? in[i] : 1'b0;
        end
    end

    
    always @* begin
        out = 1;
        for (i = 0; i < N-1; i = i + 1) begin : adder_ladder
            out = out + filter[i];
        end
    end

endmodule