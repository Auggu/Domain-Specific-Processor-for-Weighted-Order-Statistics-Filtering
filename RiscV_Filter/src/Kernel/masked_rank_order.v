module masked_rank_order #(
    parameter N = 7,
    parameter DATA_BITS = 8
) (
    input clk,
    input rst,
    input [DATA_BITS-1 : 0] i_new,
    input [N-1 : 0] mask,
    input [RANK_BITS -1 : 0] rank_sel,
    output [DATA_BITS-1 : 0] out
);

    parameter RANK_BITS = $clog2(N+1);

    wire [DATA_BITS*N-1:0] s;
    wire [N-2 : 0] gts;
    wire [RANK_BITS*N-1:0] r;

    shift_reg #(DATA_BITS, N) data_regs(clk, rst, i_new, s);
    new_s_is_gt #(N, DATA_BITS)  get_gts(i_new, s[DATA_BITS*N-1: DATA_BITS], gts);

    masked_ranks #(N)
        rank_logic (clk,
           rst,
           mask,
           gts,
           r);

    rank_selector #(N, DATA_BITS, RANK_BITS)
        sel(s,r, rank_sel ,out);

endmodule
