TB = ../tb/testbench_funcional.sv
RTL = ../rtl/*.sv
SYSTHESIS = ../synthesis
LOGIC_EQ_CHECKING = ../logic_equivalence_checking
dir = ./sim/

sims:
	cd ${dir} &&\
	xrun ${TB} ${RTL}
		
sim-gui:
	cd ${dir} &&\
	xrun ${TB} ${RTL} -gui -access +rwc -coverage all

clean:
	cd ${dir} &&\
	rm -rf *
genus_synthesis: #Síntese do RTL usando o PDK
	cd ${dir} &&\
	genus -f ${SYSTHESIS}/genus_script.tcl -log log
lec_conformal:#Equivalencia Lógica
	cd ${dir} &&\
	lec -xl -NOGui -dofile ${LOGIC_EQ_CHECKING}/uart.do -log log
help:
	@echo "Arguments to make:"
	@echo "sim - run testbench"
	@echo "sim-gui - run testbench"
	@echo "clean - remove simulation output files"