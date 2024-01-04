#include <cstdlib>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <stdlib.h>
#include <assert.h>
#include <iostream>

#include "Vimm_gen.h"
#include "decoder.hpp"

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_shared<Vimm_gen>();

    Verilated::traceEverOn(true);
    auto m_trace = std::make_shared<VerilatedVcdC>();
    dut->trace(m_trace.get(), 99);

    m_trace->open("imm_gen.vcd");

    while (sim_time < MAX_SIM_TIME) {
        dut->eval();

        // TODO: for this part,you can directly refer the decoder_tb.cpp
        sim_time++;
    }

    m_trace->dump(sim_time);
}
