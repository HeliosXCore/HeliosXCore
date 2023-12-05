CXX		:= g++


RTLD	?= rtl/core/SW
RTLOBJD	:= build
TESTBENCHD	:= testbench/verilator

TEST 	  ?= RSAlu
MODULES   ?= $(RTLD)/SourceManager.v $(RTLD)/RSAluEntry.v
TESTBENCH ?= rs_alu_tb
VERILATOR := verilator
WAVE 	  := rs_alu.vcd

# CFLAGS	:= -Wall 
VIGNOREW 	:= -Wno-WIDTHTRUNC -Wno-WIDTHEXPAND
VINCULDES	:= -Irtl/
VFLAGS 		:= --trace --x-assign unique --x-initial unique $(VIGNOREW) $(VINCULDES)
PFLAGS		:= -GREQ_LEN=4 -GGRANT_LEN=2
IFLGAS		:= -CFLAGS -I../testbench/verilator -CFLAGS -I../3rd-party/fmt/include
LDFLAGS		:= -LDFLAGS ../3rd-party/fmt/build/libfmt.a
MACRO_FLAGS := -CFLAGS -DFMT_HEADER_ONLY

.PHONY: sim wave clean

sim: 
	@mkdir -p $(RTLOBJD)
	@$(VERILATOR) $(CFLAGS) $(VFLAGS) -cc $(RTLD)/$(TEST).v $(LDFLAGS) $(MODULES) --exe $(TESTBENCHD)/$(TESTBENCH).cpp --exe $(IFLGAS) --exe $(MACRO_FLAGS) -Mdir $(RTLOBJD)
	@make -C $(RTLOBJD) -f V$(TEST).mk V$(TEST)
	@./$(RTLOBJD)/V$(TEST) +verilator+rand+reset+2

wave: sim
	@gtkwave $(WAVE)

clean:
	@rm -rf build
	@rm *.vcd