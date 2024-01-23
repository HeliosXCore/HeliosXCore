set -e

# Stage 1: Run the unit tests.
# Fetch Stage Modules
make -j -C testbench/verilator/IF sim MODULE=PipelineIF
# Decode Stage Modules
make -j -C testbench/verilator/ID sim MODULE=ImmDecoder
make -j -C testbench/verilator/ID sim MODULE=Decoder
# Dispatch Stage Modules
make -j -C testbench/verilator/DP sim MODULE=SRCOPRMANAGER
make -j -C testbench/verilator/DP sim MODULE=ARF
make -j -C testbench/verilator/DP sim MODULE=RRF
make -j -C testbench/verilator/DP sim MODULE=RRF_ALLO
make -j -C testbench/verilator/DP sim MODULE=RSREQUESTGEN
# Select and Wakeup Stage Modules
make -j -C testbench/verilator/SW sim MODULE=AllocateUnit
make -j -C testbench/verilator/SW sim MODULE=RSAluEntry
make -j -C testbench/verilator/SW sim MODULE=RSAlu
# Execute Stage Modules
make -j -C testbench/verilator/EX sim MODULE=StoreBuffer

# Stage 2: Run the pipeline stage tests.
make -j sim STAGE=IF
make -j sim STAGE=ID
make -j sim STAGE=DP
make -j sim STAGE=SW
make -j sim STAGE=EX
make -j sim STAGE=ROB
