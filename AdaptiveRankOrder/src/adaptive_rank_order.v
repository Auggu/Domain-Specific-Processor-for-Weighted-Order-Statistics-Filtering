module adaptive_rank_order #(
    parameter N = 7,
    parameter data_bits = 8,
    parameter rank_bits = $clog2(N+1)
) (
    input clk,
    input rst,
    input [data_bits-1 : 0] i_new,
    input [win_sel - 1 : 0] k,
    input [rank_bits -1 : 0] rank_sel,
    output [data_bits-1 : 0] out
);
    parameter win_sel = (N-3) / 2;
    wire [data_bits*N-1:0] s;
    wire [rank_bits*N-1:0] r;

    shift_reg #(data_bits, N) data_regs(clk, rst, i_new, s);

    ranks #(data_bits, rank_bits, N) 
        rank_logic (clk, 
           rst,
           k,
           s[data_bits * (N-1) -1 : 0],
           i_new,
           r);

    rank_selector #(N,data_bits, rank_bits) 
        sel(s,r, rank_sel ,out); 

endmodule