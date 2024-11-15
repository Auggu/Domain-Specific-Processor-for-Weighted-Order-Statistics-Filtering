module tb_uart_fsm ();


  reg clk = 0;
  reg rst = 1;
  reg rx_serial = 1;

  top_masked_2D_filter uut (
      .clk(clk),
      .rst(rst),
      .rx_serial(rx_serial)
  );

  always #10 clk = ~clk;

  initial begin
    $dumpfile("out/uart_fsm.vcd");
    $dumpvars(0, tb_uart_fsm);

    fill_input();
    rst = 0;
    #1 rst = 1;
    send_uart("h");
    send_uart(8'd22);
    send_uart("w");
    send_uart(8'd22);
    send_uart("n");
    send_uart(8'd3);
    send_uart("r");
    send_uart(8'd3);
    send_uart("m");
    send_mask;
    send_uart("s");
    #50000
    print_output;
    $finish;
  end

  task automatic send_mask;
    integer i;
    begin
      //send_uart(8'b01011101);
      send_uart(8'b10111010);
      send_uart(8'b00000000);
      send_uart(8'b00000000);
      send_uart(8'b00000000);
      //send_uart(8'b11111111);
      //send_uart(8'b11111111);
      //send_uart(8'b11111111);
      //send_uart(8'b00000001);
      //#for (i = 0; i < 7; i = i + 1) begin
        //#send_uart(8'b00000000);
      //end
    end
  endtask

  task automatic send_uart(input [7:0] msg);
    integer i;
    begin
      rx_serial = 0;
      for (i = 0; i < 8; i = i + 1) begin
        #8681 rx_serial = msg[i];
      end
      #8681 rx_serial = 1;
      #8681;
    end
  endtask

  task automatic fill_input;
    integer i;
    integer j;
    for(i = 0; i < 22*22; i = i+1 ) begin
      j = i +1 ;
      j = j > 255? j - 255 : j;
      uut.gen_sim_input.input_mem.mem[i] = j;
    end
  endtask

  task automatic print_output();
    integer i;
    integer j;
    for(i = 0; i < 22*22; i = i+1 ) begin
      $display("%d: %d",i, uut.gen_sim_output.output_mem.mem[i]);
    end
  endtask

endmodule
