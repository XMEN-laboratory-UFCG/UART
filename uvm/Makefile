BUILD_DIR  = ./work/
FILES      = -f ../rtl.lst
TOP_MODULE = uart_top

# **************************************
.PHONY: build build-sim sim clean

build:
	cd $(BUILD_DIR) &&\
	xrun \
	-uvm \
	-access +r \
	-64bit -elaborate -top $(TOP_MODULE) \
	-timescale 1ns/1ns \
	-sv -v93 \
	$(FILES) 

sim:
	cd $(BUILD_DIR) &&\
	xrun \
	-uvm \
	-access +rw	-gui \
	-64bit -top $(TOP_MODULE) \
	+uvm_set_config_int=*,recording_detail,1 \
	-timescale 1ns/1ns \
	-sv -v93 \
	-covdut uart_top \
	-covworkdir cov_work \
	-coverage all \
	-covoverwrite \
	+UVM_TESTNAME="uart_test" \
	+UVM_VERBOSITY=UVM_MEDIUM $(FILES)

clean:
	rm -rf work/xcelium.d
	xrun -clean
