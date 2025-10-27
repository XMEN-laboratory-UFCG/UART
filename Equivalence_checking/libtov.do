set log file lib_v.log -replace
read library $HOME/PDK/gsclib045/timing/fast_vdd1v0_basicCells.lib -liberty
write library fast_vdd1v0_basicCells.v -verilog -replace
