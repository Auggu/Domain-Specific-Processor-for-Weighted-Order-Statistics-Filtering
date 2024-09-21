module masked_rank_order #(
    parameter N = 7,
    parameter data_bits = 8
) (
    input clk,
    input rst,
    input [data_bits-1 : 0] i_new,
    input [N-1 : 0] mask,
    input [rank_bits -1 : 0] rank_sel,
    output [data_bits-1 : 0] out
);

    parameter rank_bits = $clog2(N+1);
    wire [data_bits*N-1:0] s;
    wire [N-2 : 0] gts;
    wire [rank_bits*N-1:0] r;

    shift_reg #(data_bits, N) data_regs(clk, rst, i_new, s);
    new_s_is_gt #(N, data_bits)  get_gts(i_new, s[data_bits*N-1: data_bits], gts);

    masked_ranks #(N)
        rank_logic (clk,
           rst,
           mask,
           gts,
           r);

    rank_selector #(N, data_bits, rank_bits)
        sel(s,r, rank_sel ,out);

endmodule
