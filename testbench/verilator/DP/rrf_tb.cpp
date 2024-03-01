#include <cstdlib>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <stdlib.h>
#include <assert.h>
#include <iostream>

#include "VRrf.h"

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

void dut_reset(std::shared_ptr<VRrf> dut, vluint64_t &sim_time) {
    dut->reset_i = 0;
    if (posedge_cnt >= 0 && posedge_cnt < 2) {
        dut->reset_i = 1;
        dut->rs1_rrftag_i = 0;
        dut->rs2_rrftag_i = 0;
        dut->forward_rrf_we_alu1_i = 0;
        dut->forward_rrftag_alu1_i = 0;
        dut->forward_rrfdata_alu1_i = 0;

        dut->forward_rrf_we_alu2_i = 0;
        dut->forward_rrftag_alu2_i = 0;
        dut->forward_rrfdata_alu2_i = 0;

        dut->forward_rrf_we_ldst_i = 0;
        dut->forward_rrftag_ldst_i = 0;
        dut->forward_rrfdata_ldst_i = 0;

        dut->forward_rrf_we_mul_i = 0;
        dut->forward_rrftag_mul_i = 0;
        dut->forward_rrfdata_mul_i = 0;

        dut->forward_rrf_we_branch_i = 0;
        dut->forward_rrftag_branch_i = 0;
        dut->forward_rrfdata_branch_i = 0;

        dut->allocate_rrf_en_i = 0;
        dut->allocate_rrftag_i = 0;
        dut->completed_dst_rrftag_i = 0;
    }
}

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_shared<VRrf>();

    Verilated::traceEverOn(true);
    auto m_trace = std::make_shared<VerilatedVcdC>();
    dut->trace(m_trace.get(), 99);

    m_trace->open("rrf.vcd");

    dut->clk_i = 0;

    while (sim_time < MAX_SIM_TIME) {
        dut_reset(dut, sim_time);
        if ((sim_time % 5) == 0) {
            dut->clk_i = !dut->clk_i;
            if (dut->clk_i == 1) {
                posedge_cnt++;
            }
        }

        dut->eval();

        vluint64_t rrftag_rand_1;
        vluint64_t rrftag_rand_2;
        if (dut->clk_i == 1) {
            if (posedge_cnt == 2 && sim_time == 10) {
#ifndef WAVE
                assert(dut->rs1_rrfvalid_o == 0);
                assert(dut->rs2_rrfvalid_o == 0);
                std::cout << "Rrf Test 1 Pass!" << std::endl;
#endif  // !WAVE

                rrftag_rand_1 = rand() % 64;
                dut->allocate_rrf_en_i = 1;
                dut->allocate_rrftag_i = rrftag_rand_1;
                /* dut->rs1_rrftag_i = rrftag_rand_1; */
                /* rrftag_rand_2 = rand() % 64; */
                /* dut->rs2_rrftag_i = rrftag_rand_2; */
            } else if (posedge_cnt == 3 && sim_time == 20) {
                dut->rs1_rrftag_i = rrftag_rand_1;

                rrftag_rand_2 = rand() % 64;
                dut->allocate_rrf_en_i = 1;
                dut->allocate_rrftag_i = rrftag_rand_2;
            } else if (posedge_cnt == 4 && sim_time == 30) {
#ifndef WAVE
                assert(dut->rs1_rrfvalid_o == 0);
                std::cout << "Rrf Test 2 Pass!" << std::endl;
#endif

                dut->rs2_rrftag_i = rrftag_rand_2;
            } else if (posedge_cnt == 5 && sim_time == 40) {
#ifndef WAVE
                assert(dut->rs2_rrfvalid_o == 0);
                std::cout << "Rrf Test 3 Pass!" << std::endl;
#endif

                dut->forward_rrf_we_alu1_i = 1;
                dut->forward_rrftag_alu1_i = rrftag_rand_1;
                dut->forward_rrfdata_alu1_i = 11;
            } else if (posedge_cnt == 6 && sim_time == 50) {
                dut->rs1_rrftag_i = rrftag_rand_1;

                dut->forward_rrf_we_alu1_i = 1;
                dut->forward_rrftag_alu1_i = rrftag_rand_2;
                dut->forward_rrfdata_alu1_i = 12;
            } else if (posedge_cnt == 7 && sim_time == 60) {
#ifndef WAVE
                assert(dut->rs1_rrfdata_o == 11);
                assert(dut->rs1_rrfvalid_o == 1);
                std::cout << "Rrf Test 4 Pass!" << std::endl;
#endif

                dut->rs2_rrftag_i = rrftag_rand_2;
            } else if (posedge_cnt == 8 && sim_time == 70) {
#ifndef WAVE
                assert(dut->rs2_rrfdata_o == 12);
                assert(dut->rs2_rrfvalid_o == 1);
                std::cout << "Rrf Test 5 Pass!" << std::endl;
#endif

                dut->completed_dst_rrftag_i = rrftag_rand_2;
            } else if (posedge_cnt == 9 && sim_time == 80) {
#ifndef WAVE
                assert(dut->data_to_arfdata_o == 12);
                std::cout << "Rrf Test 6 Pass!" << std::endl;
#endif
            }
        }

        m_trace->dump(sim_time);
        sim_time++;
    }
}
