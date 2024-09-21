module tb_shift_reg ();

parameter bits = 8;
parameter N = 5;
reg [bits-1 : 0] in = 8'd0;
reg clk = 0;
wire [N*bits-1:0]out;
reg rst = 1;

shift_reg #(bits,N) uut(clk, rst, in, out);

always #10 clk = ~clk;

initial begin
   //$dumpfile("shift_reg.vcd");
   //$dumpvars(0,tb_shift_reg);
   $monitor("%h", out);
    in = 8'd255;
    #15;
    in = 0;
    #20;
    in = 8'hAB;
    #20
    #20
    rst = 0;
    #1
    rst = 1;
    #20
    in = 8'hAA;
    #200
    $finish;
end

endmodule