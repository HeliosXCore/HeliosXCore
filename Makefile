CXX		:= g++
VERILATOR := verilator

RTLOBJD	:= build

STAGE ?= SW 

ifeq ($(STAGE), SW)
	RTLD	:= rtl/core/SW
	RTLOBJD	:= build
	TESTBENCHD	:= testbench/verilator/SW
	TEST 	  := SwUnit
	MODULES   := $(RTLD)/SourceManager.v $(RTLD)/RSAluEntry.v \
				$(RTLD)/RSAlu.v $(RTLD)/OldestFinder.v \
				$(RTLD)/AllocateUnit.v
	TESTBENCH := swunit_tb
	WAVE 	  := swunit.vcd
else ifeq ($(STAGE), ROB)
    RTLD	:= rtl/core/COM
    TESTBENCHD	:= testbench/verilator/ROB
	TEST 	  := SingleInstROB
	MODULES   :=
	TESTBENCH := SingleInstROB_tb
	WAVE 	  := SingleInstROB.vcd
endif


# CFLAGS	:= -Wall 
VIGNOREW 	:= 
VINCULDES	:= -Irtl/
VFLAGS 		:= --trace --x-assign unique --x-initial unique $(VIGNOREW) $(VINCULDES)
PFLAGS		:= -GREQ_LEN=4 -GGRANT_LEN=2
IFLGAS		:= -CFLAGS -I../testbench/verilator -CFLAGS -I../3rd-party/fmt/include
LDFLAGS		:= -LDFLAGS ../3rd-party/fmt/build/libfmt.a
MACRO_FLAGS := -CFLAGS -DFMT_HEADER_ONLY


# Format
VFormater := verible-verilog-format
FormatFlags := --inplace --column_limit=200 --indentation_spaces=4
VSRC 	  := $(shell find rtl -name "*.v")

.PHONY: sim wave clean format

sim: 
	@mkdir -p $(RTLOBJD)
	@$(VERILATOR) $(CFLAGS) $(VFLAGS) -cc $(RTLD)/$(TEST).v $(LDFLAGS) $(MODULES) \
		--public \
		--exe $(TESTBENCHD)/$(TESTBENCH).cpp $(IFLGAS) $(MACRO_FLAGS) -Mdir $(RTLOBJD)
	@make -C $(RTLOBJD) -f V$(TEST).mk V$(TEST)
	@./$(RTLOBJD)/V$(TEST) +verilator+rand+reset+2

wave: sim
	@gtkwave $(WAVE)

format:
	@for file in $(VSRC); do \
		$(VFormater) --inplace $(FormatFlags) $$file; \
	done

clean:
	@rm -rf build
	@rm *.vcd

lint:
	@verilator --lint-only -Irtl rtl/core/SW/SourceManager.v rtl/core/SW/RSAluEntry.v \
			rtl/core/SW/RSAlu.v rtl/core/SW/OldestFinder.v rtl/core/SW/AllocateUnit.v \
			rtl/core/SW/SwUnit.v
	@verilator --lint-only -Irtl rtl/core/EX/AluExeUnit.v

	@verilator --lint-only -Irtl rtl/core/COM/SingleInstROB.v
	@verilator --lint-only -Irtl rtl/core/COM/ROB.v