module address_handler_sm #(
    parameter WORD  = 9,
    parameter MAX_N = 25
) (
    input clk,
    input rst,
    input /*signed*/ [WORD-1:0] h,
    input /*signed*/ [WORD-1:0] w,
    input /*signed*/ [WORD-1:0] n,
    input run,
    output reg [WORD:0] r_addr,
    output reg [WORD:0] w_addr,
    output reg w_en,
    output reg r_en,
    output reg kernel_newline
);

  parameter N_BITS = $clog2(MAX_N);
  parameter K_BITS = $clog2((MAX_N >> 1) + 1);
  parameter C_BITS = $clog2(MAX_N);

  parameter IDLE = 2'b00;
  parameter RUN = 2'b01;
  parameter NEW_LINE = 2'b10;


  reg [1:0] state;

  wire /*signed*/ [WORD-1:0] x;
  reg /*signed*/ [WORD-1:0] y;
  reg /*signed*/ [WORD-1:0] count_y;
  reg /*signed*/ [WORD-1:0] xc;

  //reg [1:0] newline_delay;
  //assign kernel_newline = newline_delay[1];
  //assign kernel_newline = newline_delay[0];

  //assign kernel_newline = newline;
  wire /*signed*/ [WORD-1:0] yc;
  wire /*signed*/ [WORD-1:0] k;
  wire /*signed*/ [WORD-1:0] count_to;
  //
  //wire [WORD:0] w_addr_pre_pre;
  //wire [WORD:0] w_addr_pre;

  wire [WORD:0] r_addr_wire;
  assign r_addr_wire = yc * w + xc;
  //assign r_en_wire = xc >= 8'sd0 & xc < w & yc >= 8'sd0 & yc < h;
  assign r_en_wire   = (~xc[7]) & xc < w & (~yc[7]) & yc < h;
  //assign w_en_wire = x >= 0 & newcol;
  wire [WORD:0] w_addr_wire;
  assign w_addr_wire = y * w + x;
  //assign w_en_pre_pre = x >= 0 & newcol;
  //assign w_addr_pre_pre = y * w + x;

  //assign w_en_pre = x >= 0 & newcol;
  //assign w_addr_pre = y * w + x;

  assign x = xc - k;
  assign newcol = count_y == count_to;
  assign newline = (x == w);
  assign yc = y + count_y;
  assign count_to = k;
  assign k = n >> 1;

  always @(negedge clk) begin
    r_en   <= r_en_wire;
    r_addr <= r_addr_wire;
  end

  always @(posedge clk or negedge rst) begin
    if (!rst) state = IDLE;
    else
      case (state)
        IDLE: begin
          if (run) state = RUN;
          else state = IDLE;
        end
        RUN: begin
          if (!run) begin
            state = IDLE;
          end else begin
            if (x == w) state = NEW_LINE;
            else state = RUN;
          end
        end
        NEW_LINE: state = RUN;
        default:  state = IDLE;
      endcase
  end

  always @(posedge clk) begin
    w_en   = 1'd0;
    w_addr = w_addr_wire;
    case (state)
      IDLE: begin
        y = 8'd0;
        count_y = -k;
        xc = 8'd0;
        kernel_newline = 1'd0;
      end
      RUN: begin
        if (newcol) begin
          count_y = -k;
          xc = xc + 8'd1;
          y = y;
          if (x > 0) w_en = 1'b1;
        end else if (kernel_newline) begin
          kernel_newline = 1'd0;
          count_y = -k;
          xc = 8'd0;
          y = y + 8'd1;
        end else begin
          count_y = count_y + 8'd1;
          xc = xc;
          y = y;
        end
      end
      NEW_LINE: begin
        kernel_newline = 1'd1;
        w_en = 1'd0;
      end
    endcase
  end

endmodule

