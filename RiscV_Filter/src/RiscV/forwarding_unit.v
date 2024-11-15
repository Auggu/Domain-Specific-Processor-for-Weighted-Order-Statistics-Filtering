module forwarding_unit (
    input [4:0] i_rs1_e,
    input [4:0] i_rs2_e,

    input [4:0] i_wb_idx_m,
    input i_w_en_m,

    input [4:0] i_wb_idx_w,
    input i_w_en_w,

    output [1:0] o_rs1_fw_sel,
    output [1:0] o_rs2_fw_sel
);

  assign o_rs1_fw_sel[0] = (i_rs1_e == i_wb_idx_m) & i_w_en_m;
  assign o_rs2_fw_sel[0] = (i_rs2_e == i_wb_idx_m) & i_w_en_m;

  assign o_rs1_fw_sel[1] = ((i_rs1_e == i_wb_idx_w) & i_w_en_w) & !o_rs1_fw_sel[0];
  assign o_rs2_fw_sel[1] = ((i_rs2_e == i_wb_idx_w) & i_w_en_w) & !o_rs2_fw_sel[0];


endmodule
