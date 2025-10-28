set log file uart_lec.log -replace
read library $HOME/PDK/gsclib045/verilog/fast_vdd1v0_basicCells.v -verilog -both
read design ../rtl/*.sv -sv -golden
read design ../sim/outputs/uart_netlist.v -verilog -revised
add pin constraints 0 SE  -revised
add ignored inputs scan_in -revised
add ignored outputs scan_out -revised
set system mode lec
add compared point -all
compare 
set gui


