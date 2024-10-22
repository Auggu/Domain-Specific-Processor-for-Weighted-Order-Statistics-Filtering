module mem_stage #(
    parameter MEM_SIZE = 1024
) (
    input clk,
    input rst,
    input [31:0] i_alu_res,
    input [31:0] i_pc4,
    input [31:0] i_rs2,
    input [2:0] i_func3,
    input i_mem_w_en,

    //wb
    input [4:0] i_w_idx,
    input [1:0] i_wb_sel,
    input i_wb_en,

    //wb
    output reg [31:0] o_mem_out,
    output reg [31:0] o_alu_res,
    output reg [31:0] o_pc4,
    output reg [4:0] o_w_idx,
    output reg [1:0] o_wb_sel,
    output reg o_wb_en,

    //forward
    output [31:0] o_mem_fw_data
);

  wire [31:0] mem_out;

  memory #(MEM_SIZE) memory (
    .clk(~clk),
    .rst(rst),
    .address(i_alu_res),
    .data_in(i_rs2),
    .func3(i_func3),
    .w_en(i_mem_w_en),
    .data_out(mem_out)
  );

  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      o_mem_out <= 0;
      o_w_idx <= 0;
      o_wb_sel <= 0;
      o_wb_en <= 0;
      o_alu_res <= 0;
      o_pc4 <= 0;
    end else begin
      o_mem_out <= mem_out;
      o_w_idx <= i_w_idx;
      o_wb_sel <= i_wb_sel;
      o_wb_en <= i_wb_en;
      o_alu_res <= i_alu_res;
      o_pc4 <= i_pc4;
    end
  end

  assign o_mem_fw_data = i_alu_res;

endmodule

module memory #(
    parameter SIZE = 1024
) (
    input clk,
    input rst,
    input [31:0] address,
    input [31:0] data_in,
    input [2:0] func3,
    input w_en,

    output [31:0] data_out
);

  localparam SINGLE_SIZE = SIZE / 4;

  wire [1:0] mem_sel = address[1:0];
  wire [29:0] addr_plus_0 = address[31:2];
  wire [29:0] addr_plus_1 = addr_plus_0 + 1'b1;

  wire [29:0] addrs[0:3];
  wire [3:0] w_ens;
  wire [31:0] mem_out;

  assign addrs[0] = (mem_sel[0] | mem_sel[1]) ? addr_plus_1 : addr_plus_0;
  assign addrs[1] = (mem_sel[1])              ? addr_plus_1 : addr_plus_0;
  assign addrs[2] = (mem_sel[0] & mem_sel[1]) ? addr_plus_1 : addr_plus_0;
  assign addrs[3] = addr_plus_0;

  assign w_ens[0] = w_en;
  assign w_ens[1] = (func3[1] | func3[0]) & w_en;
  assign w_ens[3:2] = {2{w_en & func3[1]}};
  wire [3:0] w_ens_rot =  (w_ens << mem_sel) | (w_ens >> (3'd4 - mem_sel));

  wire [4:0] ms_x_8 = mem_sel << 2'd3;
  wire [31:0] data_in_rot = (data_in << (ms_x_8)) | (data_in >> (6'd32 - ms_x_8));

  wire [31:0] mem_out_rot = (mem_out >> (ms_x_8)) | (mem_out << (6'd32 - ms_x_8));

  wire [7:0] am0 = 8'hFF;
  wire [7:0] am1 = {8{func3[0] | func3[1]}};
  wire [15:0] am2_3 = {16{func3[1]}};
  wire [31:0] and_mask = {am2_3, am1, am0};


  wire [31:0] or_mask = (func3[2] | func3[1]) ? 32'b0 :
      (func3[0] ? {{16{mem_out_rot[15]}}, 16'h0} : {{24{mem_out_rot[7]}}, 8'h0});

  assign data_out = (mem_out_rot & and_mask) | or_mask;

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : gen_mems
      mem_module #(SINGLE_SIZE) mem (
          .clk(clk),
          .rst(rst),
          .address(addrs[i]),
          .data_in(data_in_rot[i*8 +: 8]),
          .w_en(w_ens_rot[i]),
          .data_out(mem_out[i*8 +: 8])
      );
    end
  endgenerate

endmodule

module mem_module #(
    parameter SIZE = 256
) (
    input clk,
    input rst,
    input [29:0] address,
    input [7:0] data_in,
    input w_en,
    output reg [7:0] data_out
);

  reg [7:0] mem[0:SIZE-1];

  integer i = 0;
  always @(posedge clk or negedge rst) begin
    if (~rst) begin
      for (i = 0; i < SIZE; i = i + 1) begin
        mem[i] <= 8'b0;
      end
    end else begin
      if (w_en) mem[address] <= data_in;
    end
  end

  always @(posedge clk) begin
    data_out <= mem[address];
  end

endmodule
