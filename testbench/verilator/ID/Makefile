CXX		:= g++
VERILATOR := verilator
RTLD	?= ../../../rtl/core/ID
RTLOBJD	:= build
TESTBENCHD	:= ../../../testbench/verilator/ID

TEST 	  ?=
TESTBENCH ?=
WAVE 	  ?=


MODULE ?= Decoder
ifeq ($(MODULE), Decoder)
	TEST := Decoder
	TESTBENCH := decoder_tb
	MODULES := 
	WAVE := Decoder.vcd
else ifeq ($(MODULE), ImmDecoder)
	TEST := ImmDecoder
	TESTBENCH := immdecoder_tb
	MODULES := 
	WAVE := ImmDecoder.vcd
endif

VIGNOREW 	:= 
VINCULDES	:= -I../../../rtl/ -I../../../rtl/core/ID/
VFLAGS 		:= --trace --x-assign unique --x-initial unique $(VIGNOREW) $(VINCULDES)
PFLAGS		:= -GREQ_LEN=4 -GGRANT_LEN=2
IFLGAS		:= -CFLAGS -I../../../../testbench/verilator -CFLAGS -I../../../../3rd-party/fmt/include
LDFLAGS		:= -LDFLAGS ../../../../3rd-party/fmt/build/libfmt.a
MACRO_FLAGS := -CFLAGS -DFMT_HEADER_ONLY


.PHONY: sim wave clean format

cc:
	@$(VERILATOR) $(VFLAGS) -cc $(RTLD)/$(TEST).v -Mdir $(RTLOBJD)

sim: 
	@mkdir -p $(RTLOBJD)
	@$(VERILATOR) $(VFLAGS) -cc $(RTLD)/$(TEST).v $(LDFLAGS) $(MODULES) \
		--public \
		--exe $(TESTBENCHD)/$(TESTBENCH).cpp $(IFLGAS) $(MACRO_FLAGS) -Mdir $(RTLOBJD)
	@make -C $(RTLOBJD) -f V$(TEST).mk V$(TEST)
	@./$(RTLOBJD)/V$(TEST) +verilator+rand+reset+2

wave: sim
	@gtkwave $(WAVE)

clean:
	@rm -rf build
	@rm *.vcd

