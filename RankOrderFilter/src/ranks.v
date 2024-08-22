module rank_logic #(
    parameter data_bits = 8,
    parameter rank_bits = 2
) (
    input [data_bits-1 : 0] i_new,
    input [data_bits-1 : 0] s_n,
    input [rank_bits-1 : 0] r_in,
    input [rank_bits-1 : 0] r_0,
    output[rank_bits-1 : 0] r_out,
    output i_is_ge
);

    wire [rank_bits - 1 : 0] plus_1;

    assign i_is_ge = s_n <= i_new;
    assign plus_1 = r_in + (!i_is_ge);
    assign rn_gt = r_in > r_0;
    assign r_out = plus_1 - rn_gt;

endmodule

module rank_reg #(
    parameter RESET_VAL = 0,
    parameter rank_bits = 2
) (
    input clk,
    input rst,
    input [rank_bits-1 : 0]in,
    output reg [rank_bits-1 : 0] out = RESET_VAL
);

    always @ (posedge clk or negedge rst) begin 
        if(!rst)
            out <= RESET_VAL;
        else 
            out <= in; 
    end 
endmodule


module ranks #(
    parameter data_bits = 8,
    parameter rank_bits = 2,
    parameter N = 3
) (
    input clk,
    input rst,
    input [data_bits * (N-1) - 1 : 0] s,
    input [data_bits-1 : 0] i_new,
    output [(rank_bits * N)-1 : 0] ranks_out
);

    genvar i;

    wire [rank_bits-1 : 0] rank_next [N-1 : 0];
    wire [rank_bits-1 : 0] rank_curr [N-1 : 0];
    wire [N-2 : 0] i_is_ge;
    reg [rank_bits-1 : 0] new_rank = 0;

    adder_ladder #(N, rank_bits) al (i_is_ge[N-2 : 0], rank_next[0]);


    generate 
        for(i = 0; i < N; i = i + 1) begin : reg_gen
            rank_reg #(i, rank_bits) r_reg(clk, rst, rank_next[i], rank_curr[i]);
        end
    endgenerate

    generate
        for(i = 0; i < N-1; i = i +1) begin : logic_gen
            rank_logic #(data_bits, rank_bits) 
                rank_log(i_new, 
                        s[i*data_bits +: data_bits], 
                        rank_curr[i], 
                        rank_curr[N-1], 
                        rank_next[i+1],
                        i_is_ge[i]
                );
        end
    endgenerate

    generate
        for(i = 0; i < N; i = i +1) begin : assign_out
            assign ranks_out[i*rank_bits +: rank_bits] = rank_curr[i];
        end
    endgenerate


endmodule

 