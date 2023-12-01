#include "VAllocateUnit.h"
#include "VAllocateUnit___024root.h"

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

void dut_reset(std::shared_ptr<VAllocateUnit> dut, vluint64_t &sim_time) {
    if (sim_time >= 0 && sim_time < 50) {
        dut->busy_i = 15;
        dut->req_num_i = 0;
    }
}

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_shared<VAllocateUnit>();

    Verilated::traceEverOn(true);
    auto m_trace = std::make_shared<VerilatedVcdC>();
    dut->trace(m_trace.get(), 99);

    m_trace->open("allocate_unit.vcd");

    while (sim_time < MAX_SIM_TIME) {
        dut_reset(dut, sim_time);
        dut->eval();

        if (sim_time == 50) {
            dut->busy_i = 0;
            dut->req_num_i = 2;
        } else if (sim_time == 55) {
            assert(dut->en_1_o == 1);
            assert(dut->en_2_o == 1);
            assert(dut->free_entry_1_o == 0);
            assert(dut->free_entry_2_o == 1);
            assert(dut->allocatable_o == 1);
            std::cout << "Allocate Test 1 Pass!" << std::endl;
        } else if (sim_time == 70) {
            dut->busy_i = 7;
            dut->req_num_i = 1;
        } else if (sim_time == 75) {
            assert(dut->en_1_o == 1);
            assert(dut->en_2_o == 0);
            assert(dut->free_entry_1_o == 3);
            assert(dut->free_entry_2_o == 0);
            assert(dut->allocatable_o == 1);
            std::cout << "Allocate Test 2 Pass!" << std::endl;
        }

        m_trace->dump(sim_time);
        sim_time++;
    }
}