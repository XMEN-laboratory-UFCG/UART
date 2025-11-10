TB = ../tb/testbench_funcional.sv
RTL = ../rtl/*.sv
SYSTHESIS = ../synthesis
LOGIC_EQ_CHECKING = ../logic_equivalence_checking
PHYSICAL_DESIGNS = ../physical_design
dir = ./sim/

sims:
	cd ${dir} &&\
	source /usr/local/cadence/cds.sh &&\
	xrun ${TB} ${RTL}
		
sim-gui:
	cd ${dir} &&\
	source /usr/local/cadence/cds.sh &&\
	xrun ${TB} ${RTL} -gui -access +rwc -coverage all

clean:
	cd ${dir} &&\
	rm -rf *
genus_synthesis: #Síntese do RTL usando o PDK
	cd ${dir} &&\
	source /usr/local/cadence/cds.sh &&\
	genus -f ${SYSTHESIS}/genus_script.tcl -log log
lec_conformal:#Equivalencia Lógica
	cd ${dir} &&\
	source /usr/local/cadence/cds.sh &&\
	lec -xl -NOGui -dofile ${LOGIC_EQ_CHECKING}/uart.do -log log
innovus_physical_design:
	cd ${dir} &&\
	source /usr/local/cadence/cds.sh &&\
	innovus -stylus -file ${PHYSICAL_DESIGNS}/innovus_script.tcl
help:
	@echo "Arguments to make:"
	@echo "sim - run testbench"
	@echo "sim-gui - run waves forms"
	@echo "genus_synthesis - run synthesis"
	@echo "genus_synthesis - run logical equivalence checking"
	@echo "innovus_physical_design - run design physical"
	@echo "clean - remove simulation output files"