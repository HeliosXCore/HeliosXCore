CXX		:= g++


RTLD	?= ../../../rtl/core/ID
RTLOBJD	:= build
TESTBENCHD	:= ../../../testbench/verilator
VERILATOR := verilator

TEST 	  ?=
TESTBENCH ?=
WAVE 	  ?=

STAGE ?=IMM_GEN
ifeq ($(STAGE), IMM_GEN)
	TEST := imm_gen
	TESTBENCH := ID/imm_gen_tb
	WAVE := imm_gen.vcd
else ifeq ($(STAGE), ARF)
	TEST := Arf
	TESTBENCH := ID/arf_tb
	WAVE := arf.vcd
else ifeq ($(STAGE), RRF)
	TEST := Rrf
	TESTBENCH := ID/rrf_tb
	WAVE := rrf.vcd
else ifeq ($(STAGE), RRF_ALLO)
	TEST := RrfEntryAllocate
	TESTBENCH := ID/rrfentry_allocate_tb
	WAVE := rrfentry_allocate.vcd
endif

# CFLAGS	:= -Wall 
VIGNOREW 	:= 
VINCULDES	:= -I../../../rtl/ -I../../../rtl/core/ID/
VFLAGS 		:= --trace --x-assign unique --x-initial unique $(VIGNOREW) $(VINCULDES)
PFLAGS		:= -GREQ_LEN=4 -GGRANT_LEN=2
IFLGAS		:=  -I../testbench/verilator 
MACRO_FLAGS :=  -DFMT_HEADER_ONLY

# Format
VFormater := verible-verilog-format
FormatFlags := --inplace --column_limit=200 --indentation_spaces=4
VSRC 	  := $(shell find ../../../rtl -name "*.v")

.PHONY: sim wave clean format

cc:
	@$(VERILATOR) $(VFLAGS) -cc $(RTLD)/$(TEST).v -Mdir $(RTLOBJD)

sim: 
	@mkdir -p $(RTLOBJD)
	@$(VERILATOR) $(VFLAGS) -cc $(RTLD)/$(TEST).v $(LDFLAGS) \
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
