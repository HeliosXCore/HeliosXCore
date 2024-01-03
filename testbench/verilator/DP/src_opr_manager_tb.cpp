#include <cstdlib>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <stdlib.h>
#include <assert.h>
#include <iostream>

#include "build/VSrcOprManager.h"

#define MAX_SIM_TIME 30
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_shared<VSrcOprManager>();

    Verilated::traceEverOn(true);
    auto m_trace = std::make_shared<VerilatedVcdC>();
    dut->trace(m_trace.get(), 99);

    m_trace->open("src_opr_manager.vcd");

    while (sim_time < MAX_SIM_TIME) {
        dut->eval();

        if (sim_time == 5) {
            dut->arf_busy_i = 0;
            dut->arf_data_i = 12;
            dut->arf_rrftag_i = 11;
            dut->rrf_valid_i = 0;
            dut->rrf_data_i = 13;
            dut->src_eq_zero_i = 0;
        }
        if (sim_time == 6) {
            assert(dut->src_o == 12);
            assert(dut->ready_o == 1);
            std::cout << "SrcOpeManager Test 1 Pass!" << std::endl;
        }
        if (sim_time == 7) {
            dut->src_eq_zero_i = 1;
            dut->arf_busy_i = 1;
            dut->arf_data_i = 12;
            dut->arf_rrftag_i = 11;
            dut->rrf_valid_i = 0;
            dut->rrf_data_i = 13;
        }
        if (sim_time == 8) {
            assert(dut->src_o == 0);
            assert(dut->ready_o == 1);
            std::cout << "SrcOpeManager Test 2 Pass!" << std::endl;
        }
        if (sim_time == 9) {
            dut->src_eq_zero_i = 0;
            dut->arf_busy_i = 1;
            dut->arf_data_i = 12;
            dut->arf_rrftag_i = 11;
            dut->rrf_valid_i = 0;
            dut->rrf_data_i = 13;
        }
        if (sim_time == 10) {
            assert(dut->ready_o == 0);
            std::cout << "SrcOpeManager Test 3 Pass!" << std::endl;
        }
        if (sim_time == 11) {
            dut->src_eq_zero_i = 0;
            dut->arf_busy_i = 1;
            dut->arf_data_i = 12;
            dut->arf_rrftag_i = 11;
            dut->rrf_valid_i = 1;
            dut->rrf_data_i = 13;
        }
        if (sim_time == 12) {
            assert(dut->src_o == 13);
            assert(dut->ready_o == 1);
            std::cout << "SrcOpeManager Test 4 Pass!" << std::endl;
        }
        sim_time++;
    }

    m_trace->dump(sim_time);
}
