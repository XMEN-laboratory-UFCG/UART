
set LIB_PATH $env(HOME)/PDK/gsclib045/timing
set LEF_PATH $env(HOME)/PDK/gsclib045/lef
set QRC_PATH $env(HOME)/PDK/gsclib045/qrc
set_db init_lib_search_path [list $LIB_PATH $LEF_PATH $QRC_PATH]
set_db init_hdl_search_path ../rtl/

set_db library fast_vdd1v0_basicCells.lib
set_db lef_library {gsclib045_tech.lef gsclib045_macro.lef gsclib045_multibitsDFF.lef}

read_hdl -sv uart_top.sv baud_rate.sv  counter.sv  ref_clock.sv uart_rx.sv  uart_tx.sv


elaborate 
read_sdc ../constraints/constraints_top.sdc

set_db syn_generic_effort low
set_db syn_map_effort low
set_db syn_opt_effort low

syn_generic
syn_map
syn_opt

#reports
report_timing > reports/report_timing.rpt
report_power  > reports/report_power.rpt
report_area   > reports/report_area.rpt
report_qor    > reports/report_qor.rpt



#Outputs
write_hdl > outputs/uart_netlist.v
write_sdc > outputs/uart_sdc.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge  -setuphold split > outputs/delays.sdf
