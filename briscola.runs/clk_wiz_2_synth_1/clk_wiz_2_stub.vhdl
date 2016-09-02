-- Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2016.2 (win64) Build 1577090 Thu Jun  2 16:32:40 MDT 2016
-- Date        : Wed Aug 10 19:00:47 2016
-- Host        : peppalien running 64-bit Service Pack 1  (build 7601)
-- Command     : write_vhdl -force -mode synth_stub {C:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second
--               Semester/Computer
--               Architecture/Assignment/2016/Project_personal/briscola/briscola.runs/clk_wiz_2_synth_1/clk_wiz_2_stub.vhdl}
-- Design      : clk_wiz_2
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_wiz_2 is
  Port ( 
    clk_in1 : in STD_LOGIC;
    clk_out1 : out STD_LOGIC
  );

end clk_wiz_2;

architecture stub of clk_wiz_2 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_in1,clk_out1";
begin
end;
