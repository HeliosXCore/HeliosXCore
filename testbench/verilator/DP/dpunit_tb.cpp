#include <cstdint>
#include <cstdio>
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
#include "VReNameUnit___024root.h"

#include "RsType.hpp"

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

uint32_t get_rrf_rrfvalid(std::shared_ptr<VReNameUnit> dut, vluint64_t rrftag) {
    vluint64_t rrfvalid = dut->rootp->ReNameUnit__DOT__rrf__DOT__rrf_valid;
    vluint64_t mask = 0x1l << rrftag;
    return (rrfvalid & mask) >> rrftag;
}

uint32_t get_rrf_rrfdata(std::shared_ptr<VReNameUnit> dut, vluint64_t rrftag) {
    return dut->rootp->ReNameUnit__DOT__rrf__DOT__rrf_data[rrftag];
}

uint8_t get_arf_rrftag(std::shared_ptr<VReNameUnit> dut, uint32_t regidx) {
    uint32_t arf_rrftag0, arf_rrftag1, arf_rrftag2, arf_rrftag3, arf_rrftag4,
        arf_rrftag5;
    arf_rrftag0 =
        dut->rootp->ReNameUnit__DOT__arf__DOT__re_tb__DOT__arf_rrftag0;
    arf_rrftag1 =
        dut->rootp->ReNameUnit__DOT__arf__DOT__re_tb__DOT__arf_rrftag1;
    arf_rrftag2 =
        dut->rootp->ReNameUnit__DOT__arf__DOT__re_tb__DOT__arf_rrftag2;
    arf_rrftag3 =
        dut->rootp->ReNameUnit__DOT__arf__DOT__re_tb__DOT__arf_rrftag3;
    arf_rrftag4 =
        dut->rootp->ReNameUnit__DOT__arf__DOT__re_tb__DOT__arf_rrftag4;
    arf_rrftag5 =
        dut->rootp->ReNameUnit__DOT__arf__DOT__re_tb__DOT__arf_rrftag5;
    uint32_t mask = 0x1 << regidx;
    uint32_t rrftag5_mask = (((arf_rrftag5 & mask) >> regidx) << 5);
    uint32_t rrftag4_mask = (((arf_rrftag4 & mask) >> regidx) << 4);
    uint32_t rrftag3_mask = (((arf_rrftag3 & mask) >> regidx) << 3);
    uint32_t rrftag2_mask = (((arf_rrftag2 & mask) >> regidx) << 2);
    uint32_t rrftag1_mask = (((arf_rrftag1 & mask) >> regidx) << 1);
    uint32_t rrftag0_mask = (((arf_rrftag0 & mask) >> regidx) << 0);
    return rrftag5_mask | rrftag4_mask | rrftag3_mask | rrftag2_mask |
           rrftag1_mask | rrftag0_mask;
}

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

        dut->forward_rrf_we_alu2_out_rrf_in_i = 0;
        dut->forward_rrftag_RsAlu2_out_rrf_in_i = 0;
        dut->forward_rrfdata_alu2_out_rrf_in_i = 0;

        dut->forward_rrf_we_ldst_out_rrf_in_i = 0;
        dut->forward_rrftag_RsLdst_out_rrf_in_i = 0;
        dut->forward_rrfdata_ldst_out_rrf_in_i = 0;

        dut->forward_rrf_we_mul_out_rrf_in_i = 0;
        dut->forward_rrftag_RsMul_out_rrf_in_i = 0;
        dut->forward_rrfdata_mul_out_rrf_in_i = 0;

        dut->forward_rrf_we_branch_out_rrf_in_i = 0;
        dut->forward_rrftag_RsBranch_out_rrf_in_i = 0;
        dut->forward_rrfdata_branch_out_rrf_in_i = 0;

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
            vluint64_t tmp1_allocate_rrftag;
            vluint64_t tmp2_allocate_rrftag;
            if (posedge_cnt == 2 && sim_time == 10) {
#ifndef WAVE
                assert(dut->dst_en_o == 0);

                assert(dut->rrf_allocatable_o == 1);
                assert(dut->freenum_RrfEntryAllocate_out_rob_in_o == 63);
                assert(dut->rrfptr_RrfEntryAllocate_out_rob_in_o == 1);
                assert(dut->nextrrfcyc_o == 0);
                std::cout << "ReNameUnit Test 1 Pass!" << std::endl;
#endif  // !WAVE

                dut->dstnum_setbusy_decoder_out_arf_in_i = 2;
                dut->dst_en_setbusy_decoder_out_arf_in_i = 1;
                dut->allocate_rrf_en_i = 1;

                dut->inst1_RsType_decoder_out_RSRequestGen_in_i = RS_ENT_ALU;
            } else if (posedge_cnt == 3 && sim_time == 20) {
                tmp1_allocate_rrftag =
                    dut->rrfptr_RrfEntryAllocate_out_rob_in_o - 1;

#ifndef WAVE
                assert(get_arf_rrftag(dut, 2) == 1);
                assert(dut->dst_en_o == 1);

                printf("dut->dst_rrftag_o:%u\n", dut->dst_rrftag_o);
                assert(dut->dst_rrftag_o == 1);

                assert(dut->rrfptr_RrfEntryAllocate_out_rob_in_o == 2);
                assert(dut->rrf_allocatable_o == 1);
                assert(dut->freenum_RrfEntryAllocate_out_rob_in_o == 62);

                assert(dut->req1_alu_o == 1);
                assert(dut->req_alunum_RSRequestGen_out_SWUnit_in_o == 1);
                assert(dut->req1_branch_o == 0);
                assert(dut->req_branchnum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_ldst_o == 0);
                assert(dut->req_ldstnum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_mul_o == 0);
                assert(dut->req_mulnum_RSRequestGen_out_SWUnit_in_o == 0);
                std::cout << "ReNameUnit Test 2 Pass!" << std::endl;
#endif

                dut->forward_rrf_we_alu1_out_rrf_in_i = 1;
                // tmp1_allocate_rrftag=1,也就是2号寄存器分配到的rrftag
                dut->forward_rrftag_RsAlu1_out_rrf_in_i = tmp1_allocate_rrftag;
                dut->forward_rrfdata_alu1_out_rrf_in_i = 13;
                dut->rs1_decoder_out_arf_in_i = 2;

                dut->dstnum_setbusy_decoder_out_arf_in_i = 4;
                dut->dst_en_setbusy_decoder_out_arf_in_i = 0;
                dut->allocate_rrf_en_i = 1;

            } else if (posedge_cnt == 4 && sim_time == 30) {
#ifndef WAVE
                assert(dut->src1_srcopmanager_out_srcmanager_in_o == 13);
                assert(dut->rdy1_srcopmanager_out_srcmanager_in_o == 1);
                assert(get_rrf_rrfvalid(dut, tmp1_allocate_rrftag) == 1);
                assert(get_rrf_rrfdata(dut, tmp1_allocate_rrftag) == 13);
                // 这里有个缺陷，在dst_en=0的情况下，dst_rrftag_o实际上还是会先变成+1的情况，但是应该是不影响整体逻辑的。目前还没想到比较好的办法解决
                assert(dut->dst_rrftag_o == 2);
                assert(dut->rrfptr_RrfEntryAllocate_out_rob_in_o == 2);
                std::cout << "ReNameUnit Test 3 Pass!" << std::endl;
#endif  // !WAVE

                dut->inst1_RsType_decoder_out_RSRequestGen_in_i = RS_ENT_LDST;
                dut->rs1_decoder_out_arf_in_i = 2;
                dut->dst_en_setbusy_decoder_out_arf_in_i = 1;
            } else if (posedge_cnt == 5 && sim_time == 40) {
                tmp2_allocate_rrftag =
                    dut->rrfptr_RrfEntryAllocate_out_rob_in_o - 1;
                std::cout << tmp1_allocate_rrftag << std::endl;

#ifndef WAVE
                assert(get_arf_rrftag(dut, 4) == 2);
                assert(dut->dst_en_o == 1);

                printf("dut->dst_rrftag_o:%u\n", dut->dst_rrftag_o);
                assert(dut->dst_rrftag_o == 2);

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
                std::cout << "ReNameUnit Test 4 Pass!" << std::endl;
#endif
                // 前递到4号寄存器
                dut->forward_rrf_we_alu1_out_rrf_in_i = 1;
                dut->forward_rrftag_RsAlu1_out_rrf_in_i = tmp2_allocate_rrftag;
                dut->forward_rrfdata_alu1_out_rrf_in_i = 16;
                dut->rs1_decoder_out_arf_in_i = 4;

<<<<<<< HEAD
#ifndef WAVE
                assert(dut->rdy1_srcopmanager_out_srcmanager_in_o == 1);
                std::cout << "ReNameUnit Test 4 Pass!" << std::endl;
#endif
                =======
>>>>>>> origin/main
            } else if (posedge_cnt == 6 && sim_time == 50) {
#ifndef WAVE
                assert(dut->src1_srcopmanager_out_srcmanager_in_o == 16);
                assert(dut->rdy1_srcopmanager_out_srcmanager_in_o == 1);
                std::cout << "ReNameUnit Test 5 Pass!" << std::endl;
#endif
                dut->rs1_decoder_out_arf_in_i = 2;
                dut->rs2_decoder_out_arf_in_i = 4;
                dut->inst1_RsType_decoder_out_RSRequestGen_in_i = RS_ENT_MUL;
            } else if (posedge_cnt == 7 && sim_time == 60) {
                vluint64_t tmp1 = dut->rdy1_srcopmanager_out_srcmanager_in_o;
                vluint64_t tmp2 = dut->src1_srcopmanager_out_srcmanager_in_o;
#ifndef WAVE
                assert(get_arf_rrftag(dut, dut->rs2_decoder_out_arf_in_i) == 4);
                assert(dut->rdy1_srcopmanager_out_srcmanager_in_o == 1);
                assert(dut->src1_srcopmanager_out_srcmanager_in_o == 13);
                // dst_num这时仍然有值，所以会被继续分配一个新的rrftag：3
                assert(dut->rdy2_srcopmanager_out_srcmanager_in_o == 0);
                assert(dut->src2_srcopmanager_out_srcmanager_in_o == 3);

                assert(dut->req1_alu_o == 0);
                assert(dut->req_alunum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_branch_o == 0);
                assert(dut->req_branchnum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_ldst_o == 0);
                assert(dut->req_ldstnum_RSRequestGen_out_SWUnit_in_o == 0);
                assert(dut->req1_mul_o == 1);
                assert(dut->req_mulnum_RSRequestGen_out_SWUnit_in_o == 1);
                std::cout << "RenameUnit Test 6 Pass!" << std::endl;
#endif

                dut->completed_dstnum_rob_out_arf_in_i = 2;
                dut->completed_we_rob_out_arf_in_i = 1;
                dut->com_inst_num_rob_out_RrfEntryAllocate_in_i = 1;

                dut->src2_eq_zero_decoder_out_srcopmanager_in_i = 1;

                dut->inst1_RsType_decoder_out_RSRequestGen_in_i = RS_ENT_BRANCH;
            } else if (posedge_cnt == 8 && sim_time == 70) {
#ifndef WAVE
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
                std::cout << "RenameUnit Test 7 Pass!" << std::endl;
#endif
            }
        }

        m_trace->dump(sim_time);
        sim_time++;
    }
}
