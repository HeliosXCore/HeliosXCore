# Stage 1: Run the pipeline stage tests.
make sim STAGE=SW
make sim STAGE=ROB
make sim STAGE=DP

# Stage 2: Run the unit tests.
make -C testbench/verilator/DP sim MODULE=SRCOPRMANAGER
make -C testbench/verilator/DP sim MODULE=ARF
make -C testbench/verilator/DP sim MODULE=RRF
make -C testbench/verilator/DP sim MODULE=RRF_ALLO

