module tb_rank_order ();
    
    parameter N = 5;
    parameter rank_bits = $clog2(N);
    parameter data_bits = 8;
    parameter RANK_SEL = N/2;

    parameter no_in = 18;
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
        $readmemh("tests/duplicates.hex", data, 0, no_in-1);
        rst = 0;
        #1
        rst = 1;
        $display("in s4 s3 s2 s1 s0 r4 r3 r2 r1 r0 out");
        for(integer i=0; i< no_in; i = i+1 ) begin
            $write("%0d ", in);
            for(integer j=0; j<N; j = j+1) begin
                $write("%0d ", uut.s[j*8 +: 8]);
            end
             for(integer j=0; j<N; j = j+1) begin
                $write("%0d ", uut.r[j*rank_bits +: rank_bits]);
            end
            $write("%0d", out);
            $display();
            #20;
        end
        $display("");
        
        $finish;
    end
endmodule  