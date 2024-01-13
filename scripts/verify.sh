# Stage 1: Run the unit tests.
make -j -C testbench/verilator/DP sim MODULE=SRCOPRMANAGER
make -j -C testbench/verilator/DP sim MODULE=ARF
make -j -C testbench/verilator/DP sim MODULE=RRF
make -j -C testbench/verilator/DP sim MODULE=RRF_ALLO

make -j -C testbench/verilator/SW sim MODULE=AllocateUnit
make -j -C testbench/verilator/SW sim MODULE=RSAluEntry
make -j -C testbench/verilator/SW sim MODULE=RSAlu

make -j -C testbench/verilator/EX sim MODULE=StoreBuffer

# Stage 2: Run the pipeline stage tests.
make -j sim STAGE=SW
make -j sim STAGE=ROB
make -j sim STAGE=DP
