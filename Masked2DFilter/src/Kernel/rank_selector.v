module rank_selector #(
    parameter N = 7,
    parameter data_bits = 8,
    parameter rank_bits = $clog2(N+1)
) (
    input [data_bits*N-1 : 0] s,
    input [rank_bits*N-1 : 0] r,
    input [rank_bits-1 : 0] rank_sel,
    output reg [data_bits-1 : 0] s_out
);

    wire equal[N-1:0];
    wire [data_bits-1:0] and_gates [N-1:0];
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : and_gen
            assign equal[i] = r[rank_bits * i +: rank_bits] == rank_sel;
            assign and_gates[i] = s[data_bits * i +: data_bits] & {data_bits{equal[i]}};
        end
    endgenerate

    integer j;
    always @* begin
        s_out = and_gates[0];
        for (j = 1; j < N; j = j + 1) begin : or_gen
            s_out = s_out | and_gates[j];
        end
    end

endmodule

