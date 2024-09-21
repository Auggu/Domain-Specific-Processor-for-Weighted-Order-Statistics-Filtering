module fsm #(
  parameter MASK_BYTES = 11
) (
    input clk,
    input rst,
    input rx_dv,
    input [7:0] uart_in,
    input  [15:0] counter,
    input kernel_done,
    input [15:0] input_len,
    output reg counter_rst,
    output reg in_addr_sel,
    output reg [1:0] para_sel,
    output reg [1:0] uart_sel,
    output reg run_kernel,
    output reg start_send,
    output reg tx_dv,
    output wire [7:0] o_state
);

  parameter IDLE = 8'b00000000;
  parameter RUN = 8'b00000001;
  parameter N = 8'b00000010;
  parameter H = 8'b00000100;
  parameter W = 8'b00001000;
  parameter R = 8'b00010000;
  parameter M = 8'b00100000;
  parameter I = 8'b01000000;
  parameter O = 8'b10000000;

  reg command_rst;

  reg [7:0] state;
  reg [15:0] count_to;
  reg [7:0] r_uart_command;

  assign o_state = state;

  always @ (posedge clk or negedge command_rst) begin
    if(!command_rst) begin
      r_uart_command <= 0;
    end else begin
      if(rx_dv) begin
        r_uart_command <= uart_in;
      end
    end
  end

  always @(state) begin
    run_kernel   = 0;
    in_addr_sel = 0;
    para_sel    = 0;
    uart_sel    = 0;
    start_send  = 0;
    count_to    = 0;
    counter_rst = 0;
    command_rst = 0;
    tx_dv = 0;

    case (state)
      IDLE: begin
        counter_rst = 1;
        command_rst = 1;
      end

      RUN: begin
        in_addr_sel = 1;
        run_kernel  = 1;
      end

      N: begin
        uart_sel = 2;
        para_sel = 0;
        count_to = 1;
      end

      H: begin
        uart_sel = 2;
        para_sel = 1;
        count_to = 1;
      end

      W: begin
        uart_sel = 2;
        para_sel = 2;
        count_to = 1;
      end

      R: begin
        uart_sel = 2;
        para_sel = 3;
        count_to = 1;
      end

      M: begin
        uart_sel = 3;
        count_to = MASK_BYTES;
      end

      I: begin
        uart_sel = 1;
        count_to = input_len;
      end

      O: begin
        start_send = 1;
        count_to = input_len;
      end
    endcase
  end


  always @(posedge clk or negedge rst) begin
    if (!rst) state = IDLE;
    else
      case (state)

        IDLE:
        case (r_uart_command)
          "n": state = N;
          "h": state = H;
          "w": state = W;
          "r": state = R;
          "i": state = I;
          "m": state = M;
          "o": state = O;
          "s": state = RUN;
          default: state = IDLE;
        endcase

        RUN:
        if (kernel_done) state = O;
        else state = RUN;

        default:
        if (counter == count_to) state = IDLE;
        else state = state;

      endcase
  end

endmodule
