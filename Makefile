CXX		:= g++
VERILATOR := verilator
STAGE ?= SW

RTLOBJD	:= build
ifeq ($(STAGE), SW)
include testbench/verilator/SW/sw.mk
else ifeq ($(STAGE), ROB)
include testbench/verilator/ROB/rob.mk
else ifeq ($(STAGE), DP)
include testbench/verilator/DP/dp.mk
endif

DEBUG ?= N

VIGNOREW 	:= 
VINCULDES	:= -Irtl/
VFLAGS 		:= --trace --x-assign unique --x-initial unique $(VIGNOREW) $(VINCULDES)
PFLAGS		:= -GREQ_LEN=4 -GGRANT_LEN=2
CFLAGS      := 
IFLGAS		:= -CFLAGS -I../testbench/verilator -CFLAGS -I../3rd-party/fmt/include
LDFLAGS		:= -LDFLAGS ../3rd-party/fmt/build/libfmt.a
MACRO_FLAGS := -CFLAGS -DFMT_HEADER_ONLY

# Format
VFormater := verible-verilog-format
FormatFlags := --inplace --column_limit=200 --indentation_spaces=4
VSRC 	  := $(shell find rtl -name "*.v")

ifeq ($(DEBUG), Y)
	CFLAGS += -CFLAGS -DDEBUG
endif

.PHONY: sim wave clean format

sim: 
	@mkdir -p $(RTLOBJD)
	@$(VERILATOR) $(CFLAGS) $(VFLAGS) -cc $(RTLD)/$(TEST).v $(LDFLAGS) $(MODULES) \
		--public \
		--exe $(TESTBENCHD)/$(TESTBENCH).cpp $(CFLAGS) $(IFLGAS) $(MACRO_FLAGS) -Mdir $(RTLOBJD)
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
	@verilator --lint-only -Irtl rtl/core/EX/*.v
	@verilator --lint-only -Irtl rtl/core/COM/SingleInstROB.v
	@verilator --lint-only -Irtl rtl/core/COM/ROB.v
	@verilator --lint-only -Irtl rtl/core/DP/Arf.v  \
		rtl/core/DP/Rrf.v rtl/core/DP/RrfEntryAllocate.v rtl/core/DP/SrcOprManager.v \
		rtl/core/DP/SyncRAM.v rtl/core/DP/ReNameUnit.v


