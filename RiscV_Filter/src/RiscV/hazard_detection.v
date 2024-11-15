module hazard_detection (
  input [4:0] i_rs1_d,
  input [4:0] i_rs2_d,

  input [4:0] i_wb_idx_e,
  input [1:0] i_wb_sel_e,

  output o_ld_hazard
);

  assign o_ld_hazard = (i_wb_sel_e == 2'b01) & (i_wb_idx_e == i_rs1_d | i_wb_idx_e == i_rs2_d);

endmodule
