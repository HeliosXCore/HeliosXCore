RTLD	:= rtl/core/EX
RTLOBJD	:= build
TESTBENCHD	:= testbench/verilator/EX
TEST 	  := ExUnit
MODULES   := $(shell find rtl/core/EX -name "*.v" -not -name "ExUnit.v")
TESTBENCH := exunit_tb