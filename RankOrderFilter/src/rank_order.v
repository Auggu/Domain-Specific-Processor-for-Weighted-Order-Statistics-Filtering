module rank_order #(
    parameter N = 3,
    parameter data_bits = 8,
    parameter rank_bits = 2,
    parameter RANK_SEL = 1
) (
    input clk,
    input rst,
    input [data_bits-1 : 0] i_new,
    output [data_bits-1 : 0] out
);
    wire [data_bits*N-1:0] s;
    wire [rank_bits*N-1:0] r;

    shift_reg #(data_bits, N) sample_regs(clk, rst, i_new, s);

    ranks #(data_bits, rank_bits, N) 
        rank_logic (clk, 
           rst,
           s[data_bits * (N-1) -1 : 0],
           i_new,
           r);

    rank_selector #(N,data_bits, rank_bits, RANK_SEL) 
        sel(s,r, out); 

endmodule