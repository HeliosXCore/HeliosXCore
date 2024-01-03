#include <cstdlib>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <stdlib.h>
#include <assert.h>
#include <iostream>

#include "build/VRrf.h"

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
        dut->forward_rrf_we_i = 0;
        dut->forward_rrftag_i = 0;
        dut->forward_rrfdata_i = 0;
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
        dut->clk_i = !dut->clk_i;

        dut->eval();

        vluint64_t rrftag_rand_1;
        vluint64_t rrftag_rand_2;
        if (dut->clk_i == 1) {
            posedge_cnt++;
            if (posedge_cnt == 2) {
                assert(dut->rs1_rrfvalid_o == 0);
                assert(dut->rs2_rrfvalid_o == 0);
                std::cout << "Rrf Test 1 Pass!" << std::endl;

                rrftag_rand_1 = rand() % 64;
                dut->allocate_rrf_en_i = 1;
                dut->allocate_rrftag_i = rrftag_rand_1;
                /* dut->rs1_rrftag_i = rrftag_rand_1; */
                /* rrftag_rand_2 = rand() % 64; */
                /* dut->rs2_rrftag_i = rrftag_rand_2; */
            }
            if (posedge_cnt == 3) {
                dut->rs1_rrftag_i = rrftag_rand_1;

                rrftag_rand_2 = rand() % 64;
                dut->allocate_rrf_en_i = 1;
                dut->allocate_rrftag_i = rrftag_rand_2;
            }
            if (posedge_cnt == 4) {
                assert(dut->rs1_rrfvalid_o == 0);
                std::cout << "Rrf Test 2 Pass!" << std::endl;

                dut->rs2_rrftag_i = rrftag_rand_2;
            }
            if (posedge_cnt == 5) {
                assert(dut->rs2_rrfvalid_o == 0);
                std::cout << "Rrf Test 3 Pass!" << std::endl;

                dut->forward_rrf_we_i = 1;
                dut->forward_rrftag_i = rrftag_rand_1;
                dut->forward_rrfdata_i = 11;
            }
            if (posedge_cnt == 6) {
                dut->rs1_rrftag_i = rrftag_rand_1;

                dut->forward_rrf_we_i = 1;
                dut->forward_rrftag_i = rrftag_rand_2;
                dut->forward_rrfdata_i = 12;
            }
            if (posedge_cnt == 7) {
                assert(dut->rs1_rrfdata_o == 11);
                assert(dut->rs1_rrfvalid_o == 1);
                std::cout << "Rrf Test 4 Pass!" << std::endl;

                dut->rs2_rrftag_i = rrftag_rand_2;
            }
            if (posedge_cnt == 8) {
                assert(dut->rs2_rrfdata_o == 12);
                assert(dut->rs2_rrfvalid_o == 1);
                std::cout << "Rrf Test 5 Pass!" << std::endl;

                dut->completed_dst_rrftag_i = rrftag_rand_2;
            }
            if (posedge_cnt == 9) {
                assert(dut->data_to_arfdata_o == 12);
                std::cout << "Rrf Test 6 Pass!" << std::endl;
            }
        }

        m_trace->dump(sim_time);
        sim_time++;
    }
}