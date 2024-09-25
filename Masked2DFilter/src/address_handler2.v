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
    output reg [WORD:0] r_addr,
    output reg [WORD:0] w_addr,
    output wire w_en,
    output wire r_en,
    output reg kernel_newline
);

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
  assign w_en = write;


  reg [2:0] state;

  always @(posedge clk or negedge rst) begin
    if (!rst) state <= IDLE;
    else begin
      case (state)
        IDLE: begin
          if (run) state <= RUN;
          else state <= IDLE;
        end
        RUN: begin
          if (!run) state <= IDLE;
          else begin
            if (yc == k-1) state <= NEWCOL;
            else if (xw == w) state <= NEWLINE;
            else state <= RUN;
          end
        end
        NEWCOL: begin
          if (xw == w-1) state <= NEWLINE;
          else state <= RUN;
        end
        NEWLINE: begin
          state <= RUN;
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
      end
      RUN: begin
        if (r_en) r_addr <= r_addr + w;
        else  r_addr <= r_addr;
        if(write) w_addr <= w_addr + 1;
        else w_addr <= w_addr;
        yc = yc + 1;
        yw <= yw;
        xr <= xr;
        kernel_newline <= 1'd0;
        start_address <= start_address;
        write <= 1'd0;
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
        w_addr <= w_addr + 1;
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
