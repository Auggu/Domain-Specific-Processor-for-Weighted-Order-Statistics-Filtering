module tb_rank_order ();
    
    parameter N = 5;
    parameter rank_bits = $clog2(N);
    parameter data_bits = 8;
    parameter RANK_SEL = N/2;

    parameter no_in = 21;
    parameter run_time = (no_in+1) *20;

    reg clk = 0;
    reg rst = 1;
    reg [data_bits-1 : 0] in = 0;
    wire [data_bits-1 : 0] out;

    reg [data_bits:0] data [no_in-1:0];
    reg [$clog2(no_in)-1 : 0] addr = 0;

    always @ (posedge clk) begin
        in <= data[addr];
        addr <= addr + 1;
    end
    rank_order #(N, data_bits, rank_bits, RANK_SEL) uut(clk, rst, in, out);

    always #10 clk = ~clk;
    initial begin
        $dumpfile("rank_order.vcd");
        $dumpvars(0,tb_rank_order);
        $readmemh("tests/input.hex", data, 0, no_in-1);
        $display("%d", RANK_SEL);
        $monitor("%d", out);
        rst = 0;
        #100;
        rst = 1;
        #run_time;
        $finish;
    end
endmodule  