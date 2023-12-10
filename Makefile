CXX		:= g++


RTLD	?= rtl/core/SW
RTLOBJD	:= build
TESTBENCHD	:= testbench/verilator

TEST 	  ?= SwUnit
MODULES   ?= $(RTLD)/SourceManager.v $(RTLD)/RSAluEntry.v \
			$(RTLD)/RSAlu.v $(RTLD)/OldestFinder.v \
			$(RTLD)/AllocateUnit.v
TESTBENCH ?= swunit_tb
VERILATOR := verilator
WAVE 	  := swunit.vcd

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
	@$(VERILATOR) $(CFLAGS) $(VFLAGS) -cc $(RTLD)/$(TEST).v $(LDFLAGS) $(MODULES) \
		--public \
		--exe $(TESTBENCHD)/$(TESTBENCH).cpp $(IFLGAS) $(MACRO_FLAGS) -Mdir $(RTLOBJD)
	@make -C $(RTLOBJD) -f V$(TEST).mk V$(TEST)
	@./$(RTLOBJD)/V$(TEST) +verilator+rand+reset+2

wave: sim
	@gtkwave $(WAVE)

clean:
	@rm -rf build
	@rm *.vcd