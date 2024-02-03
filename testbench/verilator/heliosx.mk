RTLD	:= rtl
RTLOBJD	:= build
TESTBENCHD	:= testbench/verilator
TEST 	  := HeliosX
MODULES   := $(RTLD)/core/IF/*.v $(RTLD)/core/ID/*.v $(RTLD)/core/DP/*.v \
			$(RTLD)/core/SW/*.v $(RTLD)/core/EX/*.v $(RTLD)/core/COM/SingleInstROB.v
TESTBENCH := heliosx_tb
WAVE 	  := heliosx.vcd