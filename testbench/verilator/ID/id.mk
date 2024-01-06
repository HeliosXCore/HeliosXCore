RTLD	:= rtl/core/ID
TESTBENCHD	:= testbench/verilator/ID
TEST 	  := IDUnit
MODULES   := $(RTLD)/Decoder.v $(RTLD)/ImmDecoder.v
TESTBENCH := idunit_tb
WAVE 	  := idunit.vcd

IFLGAS		:= -CFLAGS -I../testbench/verilator
LDFLAGS		:=

cc:
	@$(VERILATOR) $(VFLAGS) -cc $(RTLD)/$(TEST).v -Mdir $(RTLOBJD) $(MODULES)
