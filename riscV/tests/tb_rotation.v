module tb_rotation ();

reg [1:0] sel = 0;
reg [31:0] data = 0;

wire [4:0] sx8 = sel << 2'd3;
  wire [31:0] rotated =  (data >> (sx8)) | (data << (6'd32 - sx8));

initial begin
 $monitor("%H", rotated);
  #5;
  data = 32'hdeadbeef;
  #5
  sel = 2'b01;
  #5;
  sel = 2'b10;
  #5;
  sel = 2'b11;
  #5;
  sel = 2'b00;
  #5;
end

endmodule
