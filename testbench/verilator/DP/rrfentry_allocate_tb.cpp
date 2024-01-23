#include <cstdlib>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <stdlib.h>
#include <assert.h>
#include <iostream>

#include "VRrfEntryAllocate.h"

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

void dut_reset(std::shared_ptr<VRrfEntryAllocate> dut, vluint64_t &sim_time) {
    dut->reset_i = 0;
    if (posedge_cnt >= 0 && posedge_cnt < 2) {
        dut->reset_i = 1;
        dut->com_inst_num_i = 0;
        dut->stall_dp_i = 0;
    }
}

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_shared<VRrfEntryAllocate>();

    Verilated::traceEverOn(true);
    auto m_trace = std::make_shared<VerilatedVcdC>();
    dut->trace(m_trace.get(), 99);

    m_trace->open("rrfentry_allocate.vcd");

    dut->clk_i = 0;

    while (sim_time < MAX_SIM_TIME) {
        dut_reset(dut, sim_time);

        if ((sim_time % 5) == 0) {
            dut->clk_i = !dut->clk_i;
        }
        dut->eval();

        vluint64_t rrftag_rand_1;
        vluint64_t rrftag_rand_2;
        if (dut->clk_i == 1) {
            posedge_cnt++;
            if (posedge_cnt == 2) {
                assert(dut->rrf_allocatable_o == 1);
                assert(dut->freenum_o == 64);
                assert(dut->rrfptr_o == 0);
                assert(dut->nextrrfcyc_o == 0);
                std::cout << "Rrf_alloc Test 1 Pass!" << std::endl;
            } else if (posedge_cnt == 4) {
                assert(dut->freenum_o == 62);
                std::cout << "Rrf_alloc Test 2 Pass!" << std::endl;

                dut->stall_dp_i = 1;
            } else if (posedge_cnt >= 5 && posedge_cnt < 8) {
                assert(dut->freenum_o == 62);
                std::cout << "Rrf_alloc Test 3 Pass!" << std::endl;
            } else if (posedge_cnt == 8) {
                dut->stall_dp_i = 0;
            } else if (posedge_cnt == 9) {
                assert(dut->freenum_o == 61);
                std::cout << "Rrf_alloc Test 4 Pass!" << std::endl;
            } else if (posedge_cnt == 10) {
                assert(dut->freenum_o == 60);
                std::cout << "Rrf_alloc Test 5 Pass!" << std::endl;

                dut->stall_dp_i = 1;
                dut->com_inst_num_i = 3;
            } else if (posedge_cnt == 11) {
                assert(dut->freenum_o == 63);
                std::cout << "Rrf_alloc Test 6 Pass!" << std::endl;

                dut->stall_dp_i = 0;
                dut->com_inst_num_i = 0;
            } else if (posedge_cnt == 12) {
                assert(dut->freenum_o == 62);
                std::cout << "Rrf_alloc Test 7 Pass!" << std::endl;
            }
        }

        m_trace->dump(sim_time);
        sim_time++;
    }
}
