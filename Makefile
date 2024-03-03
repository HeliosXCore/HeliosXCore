CXX		:= g++
VERILATOR := verilator
STAGE ?= SW

RTLOBJD	:= build
BUILD_DIR := build

DEBUG ?= N
WAVE  ?= N

VIGNOREW 	:= 
VINCULDES	:= -Irtl/
VFLAGS 		:= --trace --x-assign unique --x-initial unique $(VIGNOREW) $(VINCULDES)
PFLAGS		:= -GREQ_LEN=4 -GGRANT_LEN=2
CFLAGS      := 
IFLAGS		:= -CFLAGS -I../testbench/verilator -CFLAGS -I../3rd-party/fmt/include
LDFLAGS		:= -LDFLAGS ../3rd-party/fmt/build/libfmt.a
MACRO_FLAGS := -CFLAGS -DFMT_HEADER_ONLY

# Format
VFormater := verible-verilog-format
FormatFlags := --inplace --column_limit=200 --indentation_spaces=4
VSRC 	  := $(shell find rtl -name "*.v" -not -name "Alu.v")

ifeq ($(STAGE), IF)
include testbench/verilator/IF/if.mk
else ifeq ($(STAGE), ID)
include testbench/verilator/ID/id.mk
else ifeq ($(STAGE), DP)
include testbench/verilator/DP/dp.mk
else ifeq ($(STAGE), SW)
include testbench/verilator/SW/sw.mk
else ifeq ($(STAGE), EX)
include testbench/verilator/EX/ex.mk
else ifeq ($(STAGE), ROB)
include testbench/verilator/ROB/rob.mk
else ifeq ($(STAGE), PIPELINE)
include testbench/verilator/heliosx.mk
else ifrq($(STAGE), DIFFTEST)
include testbench/difftest/difftest.mk
endif


ifeq ($(DEBUG), Y)
	CFLAGS += -CFLAGS -DDEBUG
endif

ifeq ($(ENABLE_WAVE), Y)
	CFLAGS += -CFLAGS -DWAVE
endif

.PHONY: sim wave clean format

sim: 
	@mkdir -p $(RTLOBJD)
	@$(VERILATOR) $(CFLAGS) $(VFLAGS) -cc $(RTLD)/$(TEST).v $(LDFLAGS) $(MODULES) \
		--public \
		--exe $(TESTBENCHD)/$(TESTBENCH).cpp $(CFLAGS) $(IFLAGS) $(MACRO_FLAGS) -Mdir $(RTLOBJD)
	@make -C $(RTLOBJD) -f V$(TEST).mk V$(TEST)
	@./$(RTLOBJD)/V$(TEST) +verilator+rand+reset+2

difftest:
	@make -C HeliosXSimulator static
	@make -C HeliosXEmulator static
	@cp HeliosXSimulator/build/libHeliosXSimulator.a $(BUILD_DIR)/libHeliosXSimulator.a
	@cp HeliosXEmulator/build/libHeliosXEmulator.a $(BUILD_DIR)/libHeliosXEmulator.a
	@make sim STAGE=DIFFTEST

wave: sim
	@gtkwave $(WAVE)

format:
	@for file in $(VSRC); do \
		$(VFormater) --inplace $(FormatFlags) $$file; \
	done

clean:
	@rm -rf build
	@rm *.vcd
	@make -C HeliosXSimulator clean

lint:
	@verilator --lint-only -Irtl rtl/core/IF/*.v rtl/core/ID/*.v rtl/core/DP/*.v \
	rtl/core/SW/*.v rtl/core/EX/*.v rtl/core/COM/SingleInstROB.v rtl/HeliosX.v

