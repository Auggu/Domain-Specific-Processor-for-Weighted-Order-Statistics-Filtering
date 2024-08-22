module tb_shift_reg ();

parameter bits = 8;
parameter N = 5;
reg [bits-1 : 0] in = 8'd0;
reg clk = 0;
wire [N*bits-1:0]out;
shift_reg #(bits,N) uut(clk, in, out);

always #10 clk = ~clk;

initial begin
   $dumpfile("shift_reg.vcd");
   $dumpvars(0,tb_shift_reg);
    in = 8'd255;
    #15;
    in = 0;
    #5
    #20;
    in = 8'hAB;
    #25
    in = 0;
    #200
    $finish;
end

endmodule