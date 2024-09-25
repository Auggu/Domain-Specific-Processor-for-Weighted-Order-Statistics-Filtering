module tb_adaptive_rank_order ();

    parameter N = 9;
    parameter run_time = 420;
    parameter data_bits = 8;
    parameter rank_bits = $clog2(N+1);


    reg clk = 0;
    reg rst = 1;
    reg [data_bits-1 : 0] i_new = 0;
    reg [(N-3)/2 - 1 : 0] k = 2'b11;
    reg [rank_bits - 1 : 0] rank_sel;
    wire [data_bits-1 : 0] out;

    adaptive_rank_order #(N, 8, $clog2(N+1))
    uut(
        clk,
        rst,
        i_new,
        k,
        rank_sel,
        out
    );

    reg [data_bits : 0] data [17:0];

    always #10 clk = ~clk;

    reg [$clog2(18)-1 : 0 ]addr =0 ;
    always @ (posedge clk) begin
        if(addr > 17)
            i_new <= 0;
        else begin
            i_new <= data[addr];
            addr <= addr + 1;
        end
    end

    initial begin
        $dumpfile("out/adaptive_rank_order.vcd");
        $dumpvars(0,tb_adaptive_rank_order);
        $readmemh("tests/test.hex", data, 0, 17);
        //$monitor("%d", out);
        k = 2'b00;
        rank_sel = 2;
        rst = 0;
        #3;
        rst = 1;
        for(integer i =0; i < 25; i = i+1) begin
            $display("%d",out);
            #20;
        end
        $finish;
    end


endmodule
