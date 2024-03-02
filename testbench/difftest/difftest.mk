RTLD	:= rtl
RTLOBJD	:= build
TESTBENCHD	:= testbench/difftest
TEST 	  := HeliosX
MODULES   := $(RTLD)/core/IF/*.v $(RTLD)/core/ID/*.v $(RTLD)/core/DP/*.v \
			$(RTLD)/core/SW/*.v $(RTLD)/core/EX/*.v $(RTLD)/core/COM/SingleInstROB.v
TESTBENCH := difftest
WAVE 	  := difftest.vcd

IFLAGS 	  += -CFLAGS -I../HeliosXSimulator/include
LDFLAGS   += -LDFLAGS ../build/libHeliosXSimulator.a