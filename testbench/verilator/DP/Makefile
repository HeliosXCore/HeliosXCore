CXX		:= g++


RTLD	?= ../../../rtl/core/DP
RTLOBJD	:= build
TESTBENCHD	:= ../../../testbench/verilator
VERILATOR := verilator

TEST 	  ?=
TESTBENCH ?=
WAVE 	  ?=

STAGE ?= RRF
ifeq ($(STAGE), ARF)
	TEST := Arf
	TESTBENCH := DP/arf_tb
	WAVE := arf.vcd
endif
ifeq ($(STAGE), RRF)
	TEST := Rrf
	TESTBENCH := DP/rrf_tb
	WAVE := rrf.vcd
endif

# CFLAGS	:= -Wall 
VIGNOREW 	:= 
VINCULDES	:= -I../../../rtl/ -I../../../rtl/core/DP/
VFLAGS 		:= --trace --x-assign unique --x-initial unique $(VIGNOREW) $(VINCULDES)
PFLAGS		:= -GREQ_LEN=4 -GGRANT_LEN=2
# IFLGAS		:=  -I../testbench/verilator  -I../3rd-party/fmt/include
IFLGAS		:=  -I../testbench/verilator 
# LDFLAGS		:= -LDFLAGS ../3rd-party/fmt/build/libfmt.a
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
