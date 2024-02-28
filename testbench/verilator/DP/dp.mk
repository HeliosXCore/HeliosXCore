RTLD	:= rtl/core/DP
TESTBENCHD	:= testbench/verilator/DP
TEST 	  := ReNameUnit
MODULES   := $(RTLD)/Arf.v $(RTLD)/Rrf.v \
						 $(RTLD)/RrfEntryAllocate.v $(RTLD)/SrcOprManager.v \
						 $(RTLD)/SyncRAM.v $(RTLD)/RSRequestGen.v
TESTBENCH := dpunit_tb
WAVE 	  := dpunit.vcd

CFLAGS += -CFLAGS -ggdb

cc:
	@$(VERILATOR) $(VFLAGS) -cc $(RTLD)/$(TEST).v -Mdir $(RTLOBJD) $(MODULES)
