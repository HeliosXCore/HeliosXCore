RTLD	:= rtl/core/SW
RTLOBJD	:= build
TESTBENCHD	:= testbench/verilator/SW
TEST 	  := SwUnit
MODULES   := $(RTLD)/SourceManager.v $(RTLD)/RSAluEntry.v \
			$(RTLD)/RSAlu.v $(RTLD)/OldestFinder.v \
			$(RTLD)/AllocateUnit.v $(RTLD)/RSAccessMemEntry.v \
			$(RTLD)/RSAccessMem.v 
TESTBENCH := swunit_tb
WAVE 	  := swunit.vcd