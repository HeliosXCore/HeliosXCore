CXX		:= g++


RTLD	?= rtl/core/SW
RTLOBJD	:= build
TESTBENCHD	:= testbench

TEST 	  ?= AllocateUnit
TESTBENCH ?= allocate_unit_tb
VERILATOR := verilator

# CFLAGS	:= -Wall 
VFLAGS 	:= --trace --x-assign unique --x-initial unique -Wno-WIDTHTRUNC -Wno-WIDTHEXPAND
PFLAGS	:= -GREQ_LEN=4 -GGRANT_LEN=2

.PHONY:

sim: 
	mkdir $(RTLOBJD)
	$(VERILATOR) $(CFLAGS) $(VFLAGS) -cc $(RTLD)/$(TEST).v --exe $(TESTBENCHD)/$(TESTBENCH).cpp -Mdir $(RTLOBJD)
	make -C $(RTLOBJD) -f V$(TEST).mk V$(TEST)
	./$(RTLOBJD)/V$(TEST) +verilator+rand+reset+2

wave: sim
	gtkwave waveform.vcd

clean:
	rm -rf build