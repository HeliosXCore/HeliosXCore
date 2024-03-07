set -e

# Stage 1: Run the unit tests.
echo "Running unit tests..."
# Fetch Stage Modules
echo "Running Fetch Stage Modules tests..."
make -j -C testbench/verilator/IF sim MODULE=PipelineIF
# Decode Stage Modules
echo "Running Decode Stage Modules tests..."
make -j -C testbench/verilator/ID sim MODULE=ImmDecoder
make -j -C testbench/verilator/ID sim MODULE=Decoder
# Dispatch Stage Modules
echo "Running Dispatch Stage Modules tests..."
make -j -C testbench/verilator/DP sim MODULE=SRCOPRMANAGER
make -j -C testbench/verilator/DP sim MODULE=ARF
make -j -C testbench/verilator/DP sim MODULE=RRF
make -j -C testbench/verilator/DP sim MODULE=RRF_ALLO
make -j -C testbench/verilator/DP sim MODULE=RSREQUESTGEN
# Select and Wakeup Stage Modules
echo "Running Select and Wakeup Stage Modules tests..."
make -j -C testbench/verilator/SW sim MODULE=AllocateUnit
make -j -C testbench/verilator/SW sim MODULE=RSAluEntry
make -j -C testbench/verilator/SW sim MODULE=RSAlu
# Execute Stage Modules
echo "Running Execute Stage Modules tests..."
make -j -C testbench/verilator/EX sim MODULE=StoreBuffer
make -j -C testbench/verilator/EX sim MODULE=MemAccessUnit


# Stage 2: Run the pipeline stage tests.
echo "Running pipeline stage tests..."
echo "Running IFUnit test..."
make -j sim STAGE=IF
echo "Running IDUnit test..."
make -j sim STAGE=ID
echo "Running DPUnit test..."
make -j sim STAGE=DP
echo "Running SWUnit test..."
make -j sim STAGE=SW
echo "Running EXUnit test..."
make -j sim STAGE=EX
echo "Running ROB test..."
make -j sim STAGE=ROB

# Stage 3: Run the whole pipeline tests.
echo "Running the whole pipeline tests..."
make -j sim STAGE=PIPELINE

# Stage 4: Run difftest
echo "Running difftest..."
make -j difftest
