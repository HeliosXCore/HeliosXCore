CXX		:= g++


RTLD	?= ../../../rtl/core/DP
RTLOBJD	:= build
TESTBENCHD	:= ../../../testbench/verilator
VERILATOR := verilator

TEST 	  ?=
TESTBENCH ?=
WAVE 	  ?=

MODULE ?= RSREQUESTGEN
ifeq ($(MODULE), SRCOPRMANAGER)
	TEST := SrcOprManager
	TESTBENCH := DP/src_opr_manager_tb
	WAVE := src_opr_manager.vcd
else ifeq ($(MODULE), ARF)
	TEST := Arf
	TESTBENCH := DP/arf_tb
	WAVE := arf.vcd
else ifeq ($(MODULE), RRF)
	TEST := Rrf
	TESTBENCH := DP/rrf_tb
	WAVE := rrf.vcd
else ifeq ($(MODULE), RRF_ALLO)
	TEST := RrfEntryAllocate
	TESTBENCH := DP/rrfentry_allocate_tb
	WAVE := rrfentry_allocate.vcd
else ifeq ($(MODULE), RSREQUESTGEN)
	TEST := RSRequestGen
	TESTBENCH := DP/rs_request_gen_tb
	WAVE := rs_request_gen.vcd
endif

CFLAGS      :=
# CFLAGS += -CFLAGS -ggdb

VIGNOREW 	:= 
VINCULDES	:= -I../../../rtl/ -I../../../rtl/core/DP/
VFLAGS 		:= --trace --x-assign unique --x-initial unique $(VIGNOREW) $(VINCULDES)
PFLAGS		:= -GREQ_LEN=4 -GGRANT_LEN=2
IFLGAS		:=  -I../testbench/verilator 
MACRO_FLAGS :=  -DFMT_HEADER_ONLY

# Format
VFormater := verible-verilog-format
FormatFlags := --inplace --column_limit=200 --indentation_spaces=4
VSRC 	  := $(shell find ../../../rtl -name "*.v")

ENABLE_WAVE ?= N
DEBUG ?= N
ifeq ($(ENABLE_WAVE), Y)
	CFLAGS += -CFLAGS -DWAVE
endif
ifeq ($(DEBUG), Y)
	CFLAGS += -CFLAGS -DDEBUG
endif


.PHONY: sim wave clean format

cc:
	@$(VERILATOR) $(CFLAGS) $(VFLAGS) -cc $(RTLD)/$(TEST).v -Mdir $(RTLOBJD)

sim: 
	@mkdir -p $(RTLOBJD)
	@$(VERILATOR) $(CFLAGS) $(VFLAGS) -cc $(RTLD)/$(TEST).v $(LDFLAGS) \
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
