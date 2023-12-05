CXX		:= g++


RTLD	?= rtl/core/SWU
RTLOBJD	:= build
TESTBENCHD	:= testbench/verilator

TEST 	  ?= RSAluEntry
MODULES   ?= $(RTLD)/SourceManager.v
TESTBENCH ?= rs_alu_entry_tb
VERILATOR := verilator

# CFLAGS	:= -Wall 
VIGNOREW 	:= -Wno-WIDTHTRUNC -Wno-WIDTHEXPAND
VINCULDES	:= -Irtl/
VFLAGS 		:= --trace --x-assign unique --x-initial unique $(VIGNOREW) $(VINCULDES)
PFLAGS		:= -GREQ_LEN=4 -GGRANT_LEN=2

.PHONY:

sim: 
	mkdir $(RTLOBJD)
	$(VERILATOR) $(CFLAGS) $(VFLAGS) -cc $(RTLD)/$(TEST).v $(MODULES) --exe $(TESTBENCHD)/$(TESTBENCH).cpp -Mdir $(RTLOBJD)
	make -C $(RTLOBJD) -f V$(TEST).mk V$(TEST)
	./$(RTLOBJD)/V$(TEST) +verilator+rand+reset+2

wave: sim
	gtkwave waveform.vcd

clean:
	rm -rf build