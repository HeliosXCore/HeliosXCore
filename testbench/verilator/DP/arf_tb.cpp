#include <cstdlib>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <stdlib.h>
#include <assert.h>
#include <iostream>

#include "VArf.h"

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

void dut_reset(std::shared_ptr<VArf> dut, vluint64_t &sim_time) {
    dut->reset_i = 0;
    if (posedge_cnt >= 0 && posedge_cnt < 2) {
        dut->reset_i = 1;
        dut->rs1_i = 0;
        dut->rs2_i = 0;
        dut->completed_we_i = 0;
        dut->from_rrfdata_i = 0;
        dut->dst_rrftag_setbusy_i = 0;
        dut->dst_en_setbusy_i = 0;
        dut->dst_num_setbusy_i = 0;
        dut->completed_dst_num_i = 0;
        dut->completed_dst_rrftag_i = 0;
    }
}

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_shared<VArf>();

    Verilated::traceEverOn(true);
    auto m_trace = std::make_shared<VerilatedVcdC>();
    dut->trace(m_trace.get(), 99);

    m_trace->open("arf.vcd");

    dut->clk_i = 0;

    while (sim_time < MAX_SIM_TIME) {
        dut_reset(dut, sim_time);
        dut->clk_i = !dut->clk_i;

        dut->eval();

        vluint64_t dst_rand;
        vluint64_t rrftag_rand;
        if (dut->clk_i == 1) {
            posedge_cnt++;
            if (posedge_cnt == 2) {
                assert(dut->rs1_arf_busy_o == 0);
                assert(dut->rs2_arf_busy_o == 0);
                assert(dut->rs1_arf_rrftag_o == 0);
                assert(dut->rs2_arf_rrftag_o == 0);
                std::cout << "Arf Test 1 Pass!" << std::endl;

                dst_rand = rand() % 32;
                dut->dst_num_setbusy_i = dst_rand;
                rrftag_rand = rand() % 64;
                dut->dst_rrftag_setbusy_i = rrftag_rand;
                dut->dst_en_setbusy_i = 1;
            } else if (posedge_cnt == 3) {
                dut->rs1_i = dst_rand;
            } else if (posedge_cnt == 4) {
                assert(dut->rs1_arf_rrftag_o == rrftag_rand);
                assert(dut->rs1_arf_busy_o == 1);
                std::cout << "Arf Test 2 Pass!" << std::endl;

                dut->completed_dst_num_i = dst_rand;
                dut->from_rrfdata_i = 13;
                dut->completed_dst_rrftag_i = rrftag_rand;
                dut->completed_we_i = 1;
            } else if (posedge_cnt == 5) {
                dut->rs1_i = dst_rand;
            } else if (posedge_cnt == 6) {
                assert(dut->rs1_arf_data_o == 13);
                std::cout << "Arf Test 3 Pass!" << std::endl;
            }
        }

        m_trace->dump(sim_time);
        sim_time++;
    }
}
