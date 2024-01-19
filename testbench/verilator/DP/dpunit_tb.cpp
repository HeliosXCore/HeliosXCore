#include <cstdlib>
#include <memory>
#include <sys/types.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <stdlib.h>
#include <assert.h>
#include <iostream>

#include "VReNameUnit.h"
#include "verilatedos.h"

#include "RsType.hpp"

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

void dut_reset(std::shared_ptr<VReNameUnit> dut, vluint64_t &sim_time) {
    dut->reset_i = 0;
    if (posedge_cnt >= 0 && posedge_cnt < 2) {
        dut->reset_i = 1;
        dut->rs1_decoder_out_arf_in_i = 0;
        dut->rs2_decoder_out_arf_in_i = 0;
        dut->com_inst_num_rob_out_RrfEntryAllocate_in_i = 0;
        dut->stall_dp_i = 0;
        dut->completed_dstnum_rob_out_arf_in_i = 0;
        dut->completed_we_rob_out_arf_in_i = 0;
        dut->dstnum_setbusy_decoder_out_arf_in_i = 0;
        dut->dst_en_setbusy_decoder_out_arf_in_i = 0;
        dut->forward_rrf_we_alu1_out_rrf_in_i = 0;
        dut->forward_rrftag_RsAlu1_out_rrf_in_i = 0;
        dut->forward_rrfdata_alu1_out_rrf_in_i = 0;
        dut->allocate_rrf_en_i = 0;
        dut->src1_eq_zero_decoder_out_srcopmanager_in_i = 0;
        dut->src2_eq_zero_decoder_out_srcopmanager_in_i = 0;
        dut->inst1_RsType_decoder_out_RSRequestGen_in_i = 0;
        dut->inst2_RsType_decoder_out_RSRequestGen_in_i = 0;
    }
}

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_shared<VReNameUnit>();

    Verilated::traceEverOn(true);
    auto m_trace = std::make_shared<VerilatedVcdC>();
    dut->trace(m_trace.get(), 99);

    m_trace->open("dpunit.vcd");

    dut->clk_i = 0;

    while (sim_time < MAX_SIM_TIME) {
        dut_reset(dut, sim_time);
        dut->clk_i = !dut->clk_i;

        dut->eval();

        vluint64_t rrftag_rand_1;
        vluint64_t rrftag_rand_2;
        if (dut->clk_i == 1) {
            posedge_cnt++;
            vluint64_t tmp1_allocate_rrftag;
            vluint64_t tmp2_allocate_rrftag;
            if (posedge_cnt == 2) {
                assert(dut->rrf_allocatable_o == 1);
                assert(dut->freenum_RrfEntryAllocate_out_rob_in_o == 64);
                assert(dut->rrfptr_RrfEntryAllocate_out_rob_in_o == 0);
                assert(dut->nextrrfcyc_o == 0);
                std::cout << "ReNameUnit Test 1 Pass!" << std::endl;

                dut->dstnum_setbusy_decoder_out_arf_in_i = 2;
                dut->dst_en_setbusy_decoder_out_arf_in_i = 1;
                dut->allocate_rrf_en_i = 1;

                dut->inst1_RsType_decoder_out_RSRequestGen_in_i = RS_ENT_ALU;
            } else if (posedge_cnt == 3) {
                tmp1_allocate_rrftag =
                    dut->rrfptr_RrfEntryAllocate_out_rob_in_o - 1;
                std::cout << tmp1_allocate_rrftag << std::endl;

                assert(dut->rrfptr_RrfEntryAllocate_out_rob_in_o == 1);
                assert(dut->rrf_allocatable_o == 1);
                assert(dut->freenum_RrfEntryAllocate_out_rob_in_o == 63);

                assert(dut->req1_alu_o == 1);
                assert(dut->req_alunum_RSRequestGen_out_SWUnit_in_o == 1);
                assert(dut->req1_branch_o == 0);
                assert(dut->req_branchnum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_ldst_o == 0);
                assert(dut->req_ldstnum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_mul_o == 0);
                assert(dut->req_mulnum_RSRequestGen_out_SWUnit_in_o == 0);
                std::cout << "ReNameUnit Test 2 Pass!" << std::endl;

                dut->forward_rrf_we_alu1_out_rrf_in_i = 1;
                dut->forward_rrftag_RsAlu1_out_rrf_in_i = tmp1_allocate_rrftag;
                dut->forward_rrfdata_alu1_out_rrf_in_i = 13;

                dut->dstnum_setbusy_decoder_out_arf_in_i = 4;
                dut->dst_en_setbusy_decoder_out_arf_in_i = 1;
                dut->allocate_rrf_en_i = 1;

            } else if (posedge_cnt == 4) {
                dut->inst1_RsType_decoder_out_RSRequestGen_in_i = RS_ENT_LDST;
                dut->rs1_decoder_out_arf_in_i = 2;
            } else if (posedge_cnt == 5) {
                tmp2_allocate_rrftag =
                    dut->rrfptr_RrfEntryAllocate_out_rob_in_o - 1;
                std::cout << tmp1_allocate_rrftag << std::endl;

                assert(dut->rrfptr_RrfEntryAllocate_out_rob_in_o == 3);
                assert(dut->rrf_allocatable_o == 1);
                assert(dut->freenum_RrfEntryAllocate_out_rob_in_o == 61);

                assert(dut->req1_alu_o == 0);
                assert(dut->req_alunum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_branch_o == 0);
                assert(dut->req_branchnum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_ldst_o == 1);
                assert(dut->req_ldstnum_RSRequestGen_out_SWUnit_in_o == 1);
                assert(dut->req1_mul_o == 0);
                assert(dut->req_mulnum_RSRequestGen_out_SWUnit_in_o == 0);
                std::cout << "ReNameUnit Test 3 Pass!" << std::endl;

                dut->forward_rrf_we_alu1_out_rrf_in_i = 1;
                dut->forward_rrftag_RsAlu1_out_rrf_in_i = tmp2_allocate_rrftag;
                dut->forward_rrfdata_alu1_out_rrf_in_i = 16;

                assert(dut->rdy1_srcopmanager_out_srcmanager_in_o == 1);
                std::cout << "ReNameUnit Test 4 Pass!" << std::endl;
            } else if (posedge_cnt == 6) {
                dut->rs2_decoder_out_arf_in_i = 4;
                dut->inst1_RsType_decoder_out_RSRequestGen_in_i = RS_ENT_MUL;
            } else if (posedge_cnt == 7) {
                vluint64_t tmp1 = dut->rdy1_srcopmanager_out_srcmanager_in_o;
                vluint64_t tmp2 = dut->src1_srcopmanager_out_srcmanager_in_o;
                std::cout << tmp1 << std::endl;
                std::cout << tmp2 << std::endl;
                assert(dut->rdy1_srcopmanager_out_srcmanager_in_o == 1);
                assert(dut->src1_srcopmanager_out_srcmanager_in_o == 13);

                assert(dut->req1_alu_o == 0);
                assert(dut->req_alunum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_branch_o == 0);
                assert(dut->req_branchnum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_ldst_o == 0);
                assert(dut->req_ldstnum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_mul_o == 1);
                assert(dut->req_mulnum_RSRequestGen_out_SWUnit_in_o == 1);
                std::cout << "RenameUnit Test 5 Pass!" << std::endl;

                dut->completed_dstnum_rob_out_arf_in_i = 2;
                dut->completed_we_rob_out_arf_in_i = 1;
                dut->com_inst_num_rob_out_RrfEntryAllocate_in_i = 1;

                dut->src2_eq_zero_decoder_out_srcopmanager_in_i = 1;

                dut->inst1_RsType_decoder_out_RSRequestGen_in_i = RS_ENT_BRANCH;
            } else if (posedge_cnt == 8) {
                assert(dut->src2_srcopmanager_out_srcmanager_in_o == 0);
                assert(dut->rdy2_srcopmanager_out_srcmanager_in_o == 1);
                assert(dut->rrf_allocatable_o == 1);

                assert(dut->req1_alu_o == 0);
                assert(dut->req_alunum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_branch_o == 1);
                assert(dut->req_branchnum_RSRequestGen_out_SWUnit_in_o == 1);
                assert(dut->req1_ldst_o == 0);
                assert(dut->req_ldstnum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_mul_o == 0);
                assert(dut->req_mulnum_RSRequestGen_out_SWUnit_in_o == 0);
                std::cout << "RenameUnit Test 6 Pass!" << std::endl;
            }
        }

        m_trace->dump(sim_time);
        sim_time++;
    }
}
