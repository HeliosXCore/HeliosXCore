RTLD	:= rtl/core/IF
TESTBENCHD	:= testbench/verilator/IF
TEST 	  := IFUnit
MODULES   := $(RTLD)/PipelineIF.v
TESTBENCH := ifunit_tb
WAVE 	  := ifunit.vcd

cc:
	@$(VERILATOR) $(VFLAGS) -cc $(RTLD)/$(TEST).v -Mdir $(RTLOBJD) $(MODULES)
