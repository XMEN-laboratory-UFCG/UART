
set LEF_PATH $env(HOME)/PDK/gsclib045/lef
set_db init_lib_search_path [list $LEF_PATH]
set_db init_lef_files {gsclib045_tech.lef gsclib045_macro.lef}

set_db init_read_netlist_files ../sim/outputs/uart_netlist.v
set_db init_lef_files {gsclib045_tech.lef gsclib045_macro.lef}

set_db init_power_nets VDD
set_db init_ground_nets VSS
set_db init_mmmc_files Default.view
read_mmmc Default.view
read_physical -lefs {gsclib045_tech.lef gsclib045_macro.lef}
read_netlist ../sim/outputs/uart_netlist.v -top uart_top
init_design