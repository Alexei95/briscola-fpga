// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
// Date        : Wed Aug 10 19:00:47 2016
// Host        : peppalien running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub {C:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second
//               Semester/Computer
//               Architecture/Assignment/2016/Project_personal/briscola/briscola.runs/clk_wiz_2_synth_1/clk_wiz_2_stub.v}
// Design      : clk_wiz_2
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_2(clk_in1, clk_out1)
/* synthesis syn_black_box black_box_pad_pin="clk_in1,clk_out1" */;
  input clk_in1;
  output clk_out1;
endmodule
