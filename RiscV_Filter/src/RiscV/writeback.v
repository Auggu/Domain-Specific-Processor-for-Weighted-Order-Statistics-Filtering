module writeback (
    input [31:0] i_mem,
    input [31:0] i_alu,
    input [31:0] i_pc4,
    input [4:0] i_w_idx,
    input [1:0] i_wb_sel,
    input i_wb_en,

    output [31:0] o_wb_data,
    output [4:0] o_w_idx,
    output o_wb_en
);

  assign o_wb_en = i_wb_en;
  assign o_w_idx = i_w_idx;

  mux3 mux (
      .sel(i_wb_sel),
      .a  (i_alu),
      .b  (i_mem),
      .c  (i_pc4),
      .out(o_wb_data)
  );

endmodule
