RTLD	:= rtl/core/DP
TESTBENCHD	:= testbench/verilator/DP
TEST 	  := ReNameUnit
MODULES   := $(RTLD)/Arf.v $(RTLD)/Rrf.v \
						 $(RTLD)/RrfEntryAllocate.v $(RTLD)/SrcOprManager.v \
						 $(RTLD)/SyncRAM.v
TESTBENCH := dpunit_tb
WAVE 	  := dpunit.vcd

IFLGAS		:= -CFLAGS -I../testbench/verilator
LDFLAGS		:=

cc:
	@$(VERILATOR) $(VFLAGS) -cc $(RTLD)/$(TEST).v -Mdir $(RTLOBJD) $(MODULES)
