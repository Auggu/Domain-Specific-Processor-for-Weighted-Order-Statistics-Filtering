module address_handler #(
    parameter WORD  = 8,
    parameter MAX_N = 25
) (
    input clk,
    input rst,
    input signed [WORD-1:0] i_h,
    input signed [WORD-1:0] i_w,
    input signed [WORD-1:0] i_n,
    input run,
    output [31:0] address,
    output wire w_en,
    output wire r_en,
    output reg kernel_newline,
    output kernel_clk,
    output reg kernel_running
);

  reg [31:0] r_addr;
  reg [31:0] w_addr;
  reg signed [WORD-1:0] h;
  reg signed [WORD-1:0] w;
  reg signed [WORD-1:0] n;

  always @(posedge run) begin
    h <= i_h;
    w <= i_w;
    n <= i_n;
  end

  assign address = write_dly ? w_addr + end_address : r_addr;

  //states
  parameter IDLE = 3'b000;
  parameter RUN = 3'b001;
  parameter NEWLINE = 3'b010;
  parameter NEWCOL = 3'b100;

  reg  [WORD : 0] start_address;

  wire [WORD-1:0] k;
  wire [WORD-1:0] neg_k;
  assign k = n >> 1;
  assign neg_k = -k;

  reg  [WORD-1:0] xr;
  wire [WORD-1:0] xw;
  assign xw = xr + neg_k;

  reg  [WORD-1:0] yw;
  reg  [WORD-1:0] yc;
  wire [WORD-1:0] yr;
  assign yr   = yw + yc;

  assign r_en = ~yr[7] & yr < h & xr < w;
  reg write;
  reg write_dly;
  assign w_en = write_dly;

  wire [31:0] end_address = h*w;

  reg [2:0] state;

  assign kernel_clk = ~hold_kernel & clk & kernel_running;

  reg hold_kernel;
  always @(negedge clk) begin
    hold_kernel <= write_dly ;
  end

  always @(posedge clk) begin
    write_dly <= write;
  end

  always @(posedge clk or negedge rst) begin
    if (!rst) state <= IDLE;
    else begin
      case (state)
        IDLE: begin
          if (run) state <= RUN;
          else state <= IDLE;
        end
        RUN: begin
            if (yc == k-1) state <= NEWCOL;
            else if (xw == w) state <= NEWLINE;
            else state <= RUN;
        end
        NEWCOL: begin
          if (xw == w-1) state <= NEWLINE;
          else state <= RUN;
        end
        NEWLINE: begin
          if (w_addr == end_address-1) state = IDLE;
          else state <= RUN;
        end
      endcase
    end
  end

  always @(posedge clk) begin
    case (state)
      IDLE: begin
        r_addr <= 8'd0;
        w_addr <= 8'd0;
        yc <= neg_k;
        yw <= 8'd0;
        xr <= 8'd0;
        kernel_newline <= 1'd0;
        start_address <= 9'd0;
        write <= 1'd0;
        kernel_running <= run ? 1'd1 :  1'd0;
        kernel_newline <= 1'd1;
      end
      RUN: begin
        if (r_en & ~write_dly) r_addr <= r_addr + w;
        else  r_addr <= r_addr;
        if(write_dly) w_addr <= w_addr + 1;
        else w_addr <= w_addr;
        yc = write_dly ? yc : yc + 1;
        yw <= yw;
        xr <= xr;
        kernel_newline <= 1'd0;
        start_address <= start_address;
        write <= 1'd0;
        kernel_running <= 1'd1;
      end
      NEWCOL: begin
        r_addr <= start_address + xr + 9'd1;
        w_addr <= w_addr;
        yc <= neg_k;
        yw <= yw;
        xr <= xr + 1;
        if (xw == w-1) kernel_newline <= 1'd1;
        else kernel_newline <= 1'd0;
        start_address <= start_address;
        write <= ~xw[7];
      end
      NEWLINE: begin
        if (yr[7]) r_addr <= 0;
        else r_addr <= start_address + w;
        w_addr <= w_addr ;
        yc <= neg_k;
        yw <= yw+1;
        xr <= 8'd0;
        kernel_newline <= 1'd0;
        if (yr[7]) start_address <= 0;
        else start_address <= start_address + w;
        write <= 1'd0;
      end
    endcase
  end

endmodule
