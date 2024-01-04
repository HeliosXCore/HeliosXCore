CXX		:= g++


RTLD	?= ../../../rtl/core/SW
RTLOBJD	:= ../../../build
TESTBENCHD	:= ../
VERILATOR := verilator

TEST 	  ?=
TESTBENCH ?=
WAVE 	  ?=


MODULE ?= InorderAllocIssueUnit
ifeq ($(MODULE), InorderAllocIssueUnit)
	TEST := InorderAllocIssueUnit
	TESTBENCH := SW/inorder_alloc_issue_unit_tb
	WAVE := inorder_alloc_issue_unit.vcd
endif

# CFLAGS	:= -Wall 
VIGNOREW 	:= 
VINCULDES	:= -I../../../rtl/ -I../../../rtl/core/SW/
VFLAGS 		:= --trace --x-assign unique --x-initial unique $(VIGNOREW) $(VINCULDES)
PFLAGS		:= -GREQ_LEN=4 -GGRANT_LEN=2
IFLGAS		:=  -I../testbench/verilator 
MACRO_FLAGS :=  -DFMT_HEADER_ONLY


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

