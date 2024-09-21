module tb_tx_uart ();

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
    $dumpfile("out/tx_uart.vcd");
    $dumpvars(0, tb_tx_uart);

    fill_output();
    uut.gen_sim_output.output_mem.mem[0] = 3;
    rst = 0;
    #1 rst = 1;
    send_uart("h");
    send_uart(8'd2);
    send_uart("w");
    send_uart(8'd3);
    send_uart("o");
    #1000000
    print_output;
    $finish;
  end

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

  task automatic fill_output;
    integer i;
    for(i = 0; i < 2*3; i = i+1 ) begin
      uut.gen_sim_output.output_mem.mem[i] = i;
    end
  endtask
task automatic print_output();
    integer i;
    for(i = 0; i < 10*15; i = i+1 ) begin
      $display("%d: %d",i, uut.gen_sim_output.output_mem.mem[i]);
    end
  endtask

endmodule
