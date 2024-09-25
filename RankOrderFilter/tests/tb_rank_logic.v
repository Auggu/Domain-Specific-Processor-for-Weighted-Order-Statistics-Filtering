module tb_rank_logic ();
    parameter data_bits = 8;
    parameter rank_bits = 2;
    reg [data_bits-1 : 0] i_new =0;
    reg [data_bits-1 : 0] s_n = 0;
    reg [rank_bits-1 : 0] r_n = 1;
    reg [rank_bits-1 : 0] r_0 = 2;
    wire [rank_bits-1 : 0] new_r;
    wire i_is_ge;

    rank_logic uut(i_new, s_n, r_n, r_0, new_r, i_is_ge);
    
    initial begin
    $dumpfile("rank_logic.vcd");
    $dumpvars(0,tb_rank_logic);
    #10;
    i_new = 0;
    s_n = 0;
    r_n = 1;
    r_0 = 2;
    #10;
    i_new = 3;
    s_n = 0;
    r_n = 1;
    r_0 = 0;
    #10;   
    i_new = 0;
    s_n = 5;
    r_n = 1;
    r_0 = 2;
    #30;
    #20;
    $finish;
    end

endmodule
