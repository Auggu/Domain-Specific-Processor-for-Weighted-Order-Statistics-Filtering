module address_handler2 #(
    parameter WORD  = 8,
    parameter MAX_N = 25
) (
    input clk,
    input rst,
    input signed [WORD-1:0] h,
    input signed [WORD-1:0] w,
    input signed [WORD-1:0] n,
    input run,
    output reg [31:0] address,
    output wire w_en,
    output wire r_en,
    output reg kernel_newline,
    output reg kernel_clk,
    output reg kernel_running
);

  localparam IDLE = 3'b000;
  localparam RUN = 3'b001;
  localparam NEWCOL = 3'b010;
  localparam NEWLINE = 3'b100;

  reg [2:0] cur_state;
  reg [2:0] next_state;

  wire signed [WORD-1:0] k = n >> 1;
  wire signed [WORD-1:0] neg_k = -k;
  reg signed [WORD-1:0] yc;

  reg [WORD-1:0] rx;
  wire [WORD-1:0] ry = wy + yc;

  reg [WORD-1:0] wx;
  reg [WORD-1:0] wy;

  always @(posedge clk) begin
    if (!rst) cur_state <= IDLE;
    else cur_state <= next_state;
  end


  always @(*) begin
    next_state = IDLE;
    case (cur_state)
      IDLE: if(run) next_state = RUN;

      RUN: begin
        if(yc == k) next_state = NEWCOL;
        else next_state = RUN;
      end

      NEWCOL: next_state = IDLE;

      NEWLINE: next_state = IDLE;

      default next_state = IDLE;
    endcase
  end

  always @(posedge clk) begin
    wx <= 0;
    wy <= 0;
    rx <= 0;
    yc <= neg_k;
    kernel_running <= 0;
    case (next_state)
      IDLE: begin end
      RUN: yc <= yc + 1;
      NEWCOL: yc <= neg_k;
    endcase
  end

endmodule
