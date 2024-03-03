CXX		:= g++
VERILATOR := verilator
RTLD	?= ../../../rtl/core/SW
RTLOBJD	:= build
TESTBENCHD	:= ../../../testbench/verilator/SW

TEST 	  ?=
TESTBENCH ?=
WAVE 	  ?=


MODULE ?= AllocateUnit
ifeq ($(MODULE), AllocateUnit)
	TEST := AllocateUnit
	TESTBENCH := allocate_unit_tb
	MODULES := 
	WAVE := allocate_unit.vcd
else ifeq ($(MODULE), RSAluEntry)
	TEST := RSAluEntry
	TESTBENCH := rs_alu_entry_tb
	MODULES := $(RTLD)/SourceManager.v 
	WAVE := rs_alu_entry.vcd
else ifeq ($(MODULE), RSAlu)
	TEST := RSAlu
	TESTBENCH := rs_alu_tb
	MODULES := $(RTLD)/SourceManager.v $(RTLD)/RSAluEntry.v
	WAVE := rs_alu.vcd
endif

VIGNOREW 	:= 
VINCULDES	:= -I../../../rtl/ -I../../../rtl/core/SW/
VFLAGS 		:= --trace --x-assign unique --x-initial unique $(VIGNOREW) $(VINCULDES)
PFLAGS		:= -GREQ_LEN=4 -GGRANT_LEN=2
IFLAGS		:= -CFLAGS -I../../../../testbench/verilator -CFLAGS -I../../../../3rd-party/fmt/include
LDFLAGS		:= -LDFLAGS ../../../../3rd-party/fmt/build/libfmt.a
MACRO_FLAGS := -CFLAGS -DFMT_HEADER_ONLY


.PHONY: sim wave clean format

cc:
	@$(VERILATOR) $(VFLAGS) -cc $(RTLD)/$(TEST).v -Mdir $(RTLOBJD)

sim: 
	@mkdir -p $(RTLOBJD)
	@$(VERILATOR) $(VFLAGS) -cc $(RTLD)/$(TEST).v $(LDFLAGS) $(MODULES) \
		--public \
		--exe $(TESTBENCHD)/$(TESTBENCH).cpp $(IFLAGS) $(MACRO_FLAGS) -Mdir $(RTLOBJD)
	@make -C $(RTLOBJD) -f V$(TEST).mk V$(TEST)
	@./$(RTLOBJD)/V$(TEST) +verilator+rand+reset+2

wave: sim
	@gtkwave $(WAVE)

clean:
	@rm -rf build
	@rm *.vcd

