# Stage 1: Run the unit tests.
make -C testbench/verilator/DP sim MODULE=SRCOPRMANAGER
make -C testbench/verilator/DP sim MODULE=ARF
make -C testbench/verilator/DP sim MODULE=RRF
make -C testbench/verilator/DP sim MODULE=RRF_ALLO

make -C testbench/verilator/SW sim MODULE=AllocateUnit
make -C testbench/verilator/SW sim MODULE=RSAluEntry
make -C testbench/verilator/SW sim MODULE=RSAlu

# Stage 2: Run the pipeline stage tests.
make sim STAGE=SW
make sim STAGE=ROB
make sim STAGE=DP

