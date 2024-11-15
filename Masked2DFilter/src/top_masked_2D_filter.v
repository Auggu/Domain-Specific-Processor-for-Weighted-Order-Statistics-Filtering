module top_masked_2D_filter (
    input clk,
    input rst,
    input rx_serial,
    input uart_rts,
    output tx_serial,
    output uart_cts,
    output rts_led,
    output [7:0] leds,
    output [6:0] seven_seg0,
    output [6:0] seven_seg1,
    output [6:0] seven_seg2,
    output [6:0] seven_seg3
);

  parameter SYNTHESIS = 1;
  parameter BYTE = 8;
  parameter INPUT_SIZE = 8;
  parameter MAX_N = 3;


  assign leds = state;
  assign out = output_out;
  assign rts_led = uart_rts;


  //----------KERNEL PARAMETERS-------------------
  wire [INPUT_SIZE-1:0] n;
  wire [INPUT_SIZE-1:0] h;
  wire [INPUT_SIZE-1:0] w;
  wire [INPUT_SIZE-1:0] r;

  wire [INPUT_SIZE-1:0] parameter_in = rx_byte;
  wire [1:0] parameter_sel;
  wire parameter_w_en = w_en_array[2];

  parameters #(
		.INPUT_SIZE(INPUT_SIZE)
  ) parameters (
      .clk(clk),
      .sel(parameter_sel),
      .w_en(parameter_w_en),
      .in(parameter_in),
      .n(n),
      .h(h),
      .w(w),
      .r(r)
  );

  //----------- MASK-------------------
  parameter MASK_BITS = MAX_N * MAX_N;
  parameter MASK_SIZE = (MASK_BITS + INPUT_SIZE - 1) / 8;
  parameter MASK_ADDR_BITS = $clog2(MASK_SIZE);

  wire [MASK_ADDR_BITS-1:0] mask_addr;
  wire mask_w_en = w_en_array[3];
  wire [INPUT_SIZE-1:0] mask_in = rx_byte;
  wire [MASK_BITS-1:0] mask;

  assign mask_addr = uart_count[MASK_ADDR_BITS : 0];
  mask_reg #(
      .MAX_N(MAX_N),
      .INPUT_SIZE(INPUT_SIZE)
  ) mask_reg (
      .clk (clk),
      .addr(mask_addr),
      .w_en(mask_w_en),
      .in  (mask_in),
      .mask(mask)
  );

  //-----------INPUT MEMORY-------------------
  wire [BYTE:0] input_addr;
  wire [INPUT_SIZE-1:0] input_in = rx_byte;
  wire [INPUT_SIZE-1:0] input_out;
  wire input_w_en = w_en_array[1];
  assign input_addr = run_kernel ? kernel_r_addr : uart_count;

  generate
    if (!SYNTHESIS) begin : gen_sim_input
      single_port_ram #(
          .SIZE(2 ** (1+BYTE)),
          .INPUT_SIZE(INPUT_SIZE)
      ) input_mem (
          .clk (~clk),
          .addr(input_addr[8:0]),
          .w_en(input_w_en),
          .in  (input_in),
          .out (input_out)
      );

    end else begin : gen_synth_input
      ram_1_port input_mem (
          .clock(~clk),
          .address(input_addr[8:0]),
          .wren(input_w_en),
          .data(input_in),
          .q(input_out)
      );
    end
  endgenerate
  //-----------OUTPUT MEMORY-------------------
  wire [BYTE:0] output_addr;
  wire [INPUT_SIZE-1:0] output_in = kernel_out;
  wire [INPUT_SIZE-1:0] output_out;
  wire output_w_en = kernel_w_en & run_kernel;

  assign output_addr = run_kernel ? kernel_w_addr : uart_count;

  generate
    if (!SYNTHESIS) begin : gen_sim_output
      single_port_ram #(
          .SIZE(2 ** (BYTE+1)),
          .INPUT_SIZE(INPUT_SIZE)
      ) output_mem (
          .clk (clk),
          .addr(output_addr),
          .w_en(output_w_en),
          .in  (output_in),
          .out (output_out)
      );

    end else begin : gen_synth_output
      IN_OUT_RAM output_mem (
          .clock(clk),
          .address(output_addr),
          .wren(output_w_en),
          .data(output_in),
          .q(output_out)
      );
    end
  endgenerate
  //---------FSM--------------------------
  wire [7:0] fsm_uart;
  wire fsm_counter_rst;
  wire in_addr_sel;
  wire [1:0] uart_sel;
  wire start_run;
  wire start_send;
  wire [7:0] state;
  assign kernel_done = input_len == kernel_w_addr;
  //DELETE
  fsm #(
      .MASK_BYTES(MASK_SIZE)
  ) fsm (
      .clk(clk),
      .rst(rst),
      .uart_in(rx_byte),
      .counter(uart_count),
      .kernel_done(kernel_done),
      .input_len(input_len),
      .counter_rst(fsm_counter_rst),
      .in_addr_sel(in_addr_sel),
      .para_sel(parameter_sel),
      .uart_sel(uart_sel),
      .rx_dv(w_en_array[0]),
      .run_kernel(run_kernel),
      .start_send(start_send),
      .o_state(state)
  );

  //----------COUNTER--------
  assign count_rst = rst & ~fsm_counter_rst;
  assign do_count  = rx_dv | tx_done;
  wire [2*BYTE-1 : 0] uart_count;

  counter #(
      .COUNT_BITS(2 * BYTE)
  ) uart_counter (
      .clk(clk),
      .rst(count_rst),
      .do_count(do_count),
      .count(uart_count)
  );

  //------------UART-RX-------------
  //50000000 / 115200 = 434
  assign uart_cts = 1'b1;
  wire [7:0] rx_byte;
  uart_rx #(
      .CLKS_PER_BIT(434)
  ) uart_rx (
      .i_Clock(clk),
      .i_Rx_Serial(rx_serial),
      .o_Rx_DV(rx_dv),
      .o_Rx_Byte(rx_byte)
  );

  //------------UART-TX-------------
  //50000000 / 115200 = 434
  wire [7:0] tx_byte;
  uart_tx #(
      .CLKS_PER_BIT(434)
  ) uart_tx (
      .i_Clock(clk),
      .i_Tx_DV(start_send),
      .i_Tx_Byte(output_out),
      .o_Tx_Active(tx_active),
      .o_Tx_Serial(tx_serial),
      .o_Tx_Done(tx_done)
  );


  //-------------WIRES--------
  wire [15:0] input_len;
  assign input_len = w * h;

  //--------MUX---------------
  reg [3:0] w_en_array;
  always @(*) begin
    w_en_array = 4'b0000;
    case (uart_sel)
      2'b01:   w_en_array[1] = rx_dv;
      2'b10:   w_en_array[2] = rx_dv;
      2'b11:   w_en_array[3] = rx_dv;
      default: w_en_array[0] = rx_dv;
    endcase
  end

  //--------ADDRESS HANDLER___________________________________
  wire [BYTE:0] kernel_r_addr;
  wire [BYTE:0] kernel_w_addr;
  assign address_handler_rst = rst;// & run_kernel;
  assign kernel_clk = clk;   // run_kernel;
  address_handler2 #(
      .WORD (BYTE),
      .MAX_N(MAX_N)
  ) address_handler (
      .clk(kernel_clk),
      .rst(address_handler_rst),
      .h(h),
      .w(w),
      .n(n),
      .run(run_kernel),
      .r_addr(kernel_r_addr),
      .w_addr(kernel_w_addr),
      .w_en(kernel_w_en),
      .r_en(kernel_r_en),
      .kernel_newline(newline)
  );

  //----------KERNEL---------------------------------------
  parameter RANK_BITS = $clog2(MAX_N * MAX_N + 1);
  wire [BYTE-1:0] kernel_out;
  wire [BYTE-1:0] kernel_in;
  wire [RANK_BITS-1:0] rank_select = r[RANK_BITS-1:0];
  assign kernel_rst = address_handler_rst & ~newline;
  assign kernel_in  = kernel_r_en ? input_out : 8'd0;
  masked_rank_order #(
      .N(MAX_N * MAX_N),
      .DATA_BITS(INPUT_SIZE)
  ) kernel (
      .clk(clk),
      .rst(kernel_rst),
      .i_new(kernel_in),
      .mask(mask),
      .rank_sel(rank_select),
      .out(kernel_out)
  );

  seven_seg h_ss_0 (
      .in (h[3:0]),
      .out(seven_seg0)
  );
  seven_seg h_ss_1 (
      .in (h[7:4]),
      .out(seven_seg1)
  );
  seven_seg w_ss_0 (
      .in (w[3:0]),
      .out(seven_seg2)
  );
  seven_seg w_ss_1 (
      .in (w[7:4]),
      .out(seven_seg3)
  );

endmodule
