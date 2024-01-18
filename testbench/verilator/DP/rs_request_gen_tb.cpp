#include <cstdio>
#include <cstdlib>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <stdlib.h>
#include <assert.h>
#include <iostream>

#include "VRSRequestGen.h"
#include "RsType.hpp"

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;

void dut_reset(std::shared_ptr<VRSRequestGen> dut, vluint64_t &sim_time) {
    dut->reset_i = 0;
    if (sim_time >= 0 && sim_time < 5) {
        dut->reset_i = 1;
        dut->inst1_rs_type_i = 0;
        dut->inst2_rs_type_i = 0;
    }
}

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_shared<VRSRequestGen>();

    Verilated::traceEverOn(true);
    auto m_trace = std::make_shared<VerilatedVcdC>();
    dut->trace(m_trace.get(), 99);

    m_trace->open("rs_request_gen.vcd");

    while (sim_time < MAX_SIM_TIME) {
        dut->eval();

        dut_reset(dut, sim_time);
        if (sim_time == 5) {
            dut->inst1_rs_type_i = RS_ENT_ALU;
            dut->inst2_rs_type_i = 0;
        } else if (sim_time == 10) {
            assert(dut->req1_alu_o == 1);
            assert(dut->req_alunum_o == 1);
            assert(dut->req1_branch_o == 0);
            assert(dut->req_branchnum_o == 0);
            assert(dut->req1_ldst_o == 0);
            assert(dut->req_ldstnum_o == 0);
            assert(dut->req1_mul_o == 0);
            assert(dut->req_mulnum_o == 0);
            std::cout << "RSRequestGen Test 1 Pass!" << std::endl;
        } else if (sim_time == 15) {
            dut->inst1_rs_type_i = RS_ENT_LDST;
        } else if (sim_time == 20) {
            assert(dut->req1_ldst_o == 1);
            assert(dut->req_ldstnum_o == 1);
            assert(dut->req1_alu_o == 0);
            assert(dut->req_alunum_o == 0);
            assert(dut->req1_branch_o == 0);
            assert(dut->req_branchnum_o == 0);
            assert(dut->req1_mul_o == 0);
            assert(dut->req_mulnum_o == 0);
            std::cout << "RSRequestGen Test 2 Pass!" << std::endl;
        } else if (sim_time == 25) {
            dut->inst1_rs_type_i = RS_ENT_MUL;
        } else if (sim_time == 30) {
            assert(dut->req1_mul_o == 1);
            assert(dut->req_mulnum_o == 1);
            assert(dut->req1_ldst_o == 0);
            assert(dut->req_ldstnum_o == 0);
            assert(dut->req1_alu_o == 0);
            assert(dut->req_alunum_o == 0);
            assert(dut->req1_branch_o == 0);
            assert(dut->req_branchnum_o == 0);
            std::cout << "RSRequestGen Test 3 Pass!" << std::endl;
        } else if (sim_time == 35) {
            dut->inst1_rs_type_i = RS_ENT_BRANCH;
        } else if (sim_time == 40) {
            assert(dut->req1_branch_o == 1);
            assert(dut->req_branchnum_o == 1);
            assert(dut->req1_mul_o == 0);
            assert(dut->req_mulnum_o == 0);
            assert(dut->req1_ldst_o == 0);
            assert(dut->req_ldstnum_o == 0);
            assert(dut->req1_alu_o == 0);
            assert(dut->req_alunum_o == 0);
            std::cout << "RSRequestGen Test 4 Pass!" << std::endl;
        }
        sim_time++;
    }

    m_trace->dump(sim_time);
}
