module run_module (
    input clk,
    input rst,
    input  start_btn,
    input  ebreak,
    output reg run = 0
);

  reg btn_dly;
  reg [1:0] ebreak_sr = 2'b0;
  wire stop = ebreak_sr[1] | ~rst;

  always @ (posedge clk) begin
    btn_dly <= start_btn;
    ebreak_sr <= {ebreak_sr[0], ebreak};
  end

  wire start = ~btn_dly & start_btn;

  always @(posedge clk) begin
    if (start) run <= 1'b1;
    else if (stop) run <= 1'b0;
  end

endmodule
