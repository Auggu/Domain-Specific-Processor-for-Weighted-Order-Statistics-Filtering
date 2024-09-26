module rank_selector #(
    parameter N = 3,
    parameter data_bits = 8,
    parameter rank_bits = 2,
    parameter RANK_SEL = 1
) (
    input [data_bits*N-1 : 0] s,
    input [rank_bits*N-1 : 0] r,
    output reg [data_bits-1 : 0] s_out
);
    /*
    integer i;
    always @* begin
        s_out = 0;
        for (i = 0; i < N; i = i +1 ) begin
            if(r[rank_bits * i +: rank_bits] == RANK_SEL) begin
                s_out = s[data_bits * i +: data_bits];
            end
        end
    end
    */
	 parameter [rank_bits-1 : 0] RS = RANK_SEL;
    wire equal[N-1:0];    
    wire [data_bits-1:0] and_gates [N-1:0];    
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : and_gen
            assign equal[i] = r[rank_bits * i +: rank_bits] == RS;
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