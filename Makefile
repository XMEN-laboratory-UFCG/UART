xrun:
	xrun testbanch_funcional.sv uart_rx.sv uart_tx.sv counter.sv baund_rate.sv
		
wave:
	xrun testbanch_funcional.sv uart_rx.sv uart_tx.sv counter.sv baund_rate.sv -gui -access +rw

cover:
	imc -load cov_work/scope/test

clean:
	rm -rf waves.shm xcelium.d xrun.* *.log .simvision

help:
	@echo "Xcelium and VManager need to be installed and environment needs to be set up to use this Makefile."
	@echo "possible arguments to make:"
	@echo "sim - run simulation"
	@echo "wave - show waveforms and transaction diagrams after simulation"
	@echo "       use & to keep the waveform viewer open and reload database after next simulation"
	@echo "clean - remove simulation output files"