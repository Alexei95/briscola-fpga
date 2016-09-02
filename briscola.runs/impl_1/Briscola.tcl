proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir {C:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.cache/wt} [current_project]
  set_property parent.project_path {C:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.xpr} [current_project]
  set_property ip_repo_paths {{c:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.cache/ip}} [current_project]
  set_property ip_output_repo {{c:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.cache/ip}} [current_project]
  set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
  add_files -quiet {{C:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.runs/synth_1/Briscola.dcp}}
  add_files -quiet {{C:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.dcp}}
  set_property netlist_only true [get_files {{C:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0.dcp}}]
  add_files -quiet {{C:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.srcs/sources_1/ip/clk_wiz_2/clk_wiz_2.dcp}}
  set_property netlist_only true [get_files {{C:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.srcs/sources_1/ip/clk_wiz_2/clk_wiz_2.dcp}}]
  read_xdc -mode out_of_context -ref blk_mem_gen_0 -cells U0 {{c:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_ooc.xdc}}
  set_property processing_order EARLY [get_files {{c:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.srcs/sources_1/ip/blk_mem_gen_0/blk_mem_gen_0_ooc.xdc}}]
  read_xdc -mode out_of_context -ref clk_wiz_2 -cells inst {{c:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.srcs/sources_1/ip/clk_wiz_2/clk_wiz_2_ooc.xdc}}
  set_property processing_order EARLY [get_files {{c:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.srcs/sources_1/ip/clk_wiz_2/clk_wiz_2_ooc.xdc}}]
  read_xdc -prop_thru_buffers -ref clk_wiz_2 -cells inst {{c:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.srcs/sources_1/ip/clk_wiz_2/clk_wiz_2_board.xdc}}
  set_property processing_order EARLY [get_files {{c:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.srcs/sources_1/ip/clk_wiz_2/clk_wiz_2_board.xdc}}]
  read_xdc -ref clk_wiz_2 -cells inst {{c:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.srcs/sources_1/ip/clk_wiz_2/clk_wiz_2.xdc}}
  set_property processing_order EARLY [get_files {{c:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.srcs/sources_1/ip/clk_wiz_2/clk_wiz_2.xdc}}]
  read_xdc {{C:/Users/colucci/Google Drive/Uni/Second Year - 2015_2016/Second Semester/Computer Architecture/Assignment/2016/Project_personal/briscola/briscola.srcs/constrs_1/imports/constraints_xdc_vivado/Nexys4_Master.xdc}}
  link_design -top Briscola -part xc7a100tcsg324-1
  write_hwdef -file Briscola.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design -verbose
  write_checkpoint -force Briscola_opt.dcp
  report_drc -file Briscola_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force Briscola_placed.dcp
  report_io -file Briscola_io_placed.rpt
  report_utilization -file Briscola_utilization_placed.rpt -pb Briscola_utilization_placed.pb
  report_control_sets -verbose -file Briscola_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force Briscola_routed.dcp
  report_drc -file Briscola_drc_routed.rpt -pb Briscola_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file Briscola_timing_summary_routed.rpt -rpx Briscola_timing_summary_routed.rpx
  report_power -file Briscola_power_routed.rpt -pb Briscola_power_summary_routed.pb -rpx Briscola_power_routed.rpx
  report_route_status -file Briscola_route_status.rpt -pb Briscola_route_status.pb
  report_clock_utilization -file Briscola_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force Briscola.mmi }
  write_bitstream -force Briscola.bit -bin_file -verbose
  catch { write_sysdef -hwdef Briscola.hwdef -bitfile Briscola.bit -meminfo Briscola.mmi -file Briscola.sysdef }
  catch {write_debug_probes -quiet -force debug_nets}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

