#include "VSourceManager.h"
#include "VSourceManager___024root.h"

#include <verilated.h>
#include <verilated_vcd_c.h>

#include <stdlib.h>
#include <assert.h>
#include <iostream>
#include <memory>

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

void dut_reset(std::shared_ptr<VSourceManager> dut, vluint64_t &sim_time) {
    if (sim_time >= 0 && sim_time < 50) {
        dut->exe_dst_1_i = 0;
        dut->exe_dst_2_i = 0;
        dut->exe_dst_3_i = 0;
        dut->exe_dst_4_i = 0;
        dut->exe_dst_5_i = 0;

        dut->exe_result_1_i = 0;
        dut->exe_result_2_i = 0;
        dut->exe_result_3_i = 0;
        dut->exe_result_4_i = 0;
        dut->exe_result_5_i = 0;

        dut->src_i = 0;
        dut->src_ready_i = 0;
    }
}

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_shared<VSourceManager>();

    Verilated::traceEverOn(true);
    auto m_trace = std::make_shared<VerilatedVcdC>();
    dut->trace(m_trace.get(), 99);

    m_trace->open("source_manager.vcd");

    while (sim_time < MAX_SIM_TIME) {
        dut_reset(dut, sim_time);
        dut->eval();

        m_trace->dump(sim_time);
        sim_time++;
    }
}