#include <cstdlib>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <stdlib.h>
#include <assert.h>
#include <iostream>

#include "obj_dir/Vdecoder.h"
#include "decoder.hpp"

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_shared<Vdecoder>();

    Verilated::traceEverOn(true);
    auto m_trace = std::make_shared<VerilatedVcdC>();
    dut->trace(m_trace.get(), 99);

    m_trace->open("decoder.vcd");

    while (sim_time < MAX_SIM_TIME) {
        dut->eval();

        if (sim_time == 5) {
            // type:U
            /* 0x800002b7,  // lui t0,0x80000 */
            dut->inst_i = 0x800002b7;
        }
        if (sim_time == 6) {
            assert(dut->imm_type_o==IMM_U);
            assert(dut->rd_o==0x05);
            assert(dut->uses_rs1_o==0);
            assert(dut->src_a_sel_o==SRC_A_ZERO);
            assert(dut->wr_reg_o==1);
            std::cout << "decoder Test 1 Pass!" << std::endl;
        }

        /* 80000024:	374000ef          	jal	ra,80000398 <halt> */
        // type: J
        if (sim_time == 7) {
            dut->inst_i = 0x374000ef;
        }
        if (sim_time == 8) {
            assert(dut->imm_type_o==IMM_I);
            assert(dut->rd_o==0x01);
            assert(dut->uses_rs1_o==0);
            assert(dut->src_a_sel_o==SRC_A_PC);
            assert(dut->src_b_sel_o==SRC_B_FOUR);
            assert(dut->wr_reg_o==1);
            assert(dut->rs_ent_o==RS_ENT_JAL);
            std::cout << "decoder Test 2 Pass!" << std::endl;
        }
        /* 80000034:	00082883          	lw	a7,0(a6) */
        // type:I
        if (sim_time == 9) {
            dut->inst_i = 0x00082883;
        }
        if (sim_time == 10) {
            assert(dut->imm_type_o==IMM_I);
            assert(dut->rs1_o==0x10);
            assert(dut->rd_o==0x11);
            assert(dut->src_a_sel_o==SRC_A_RS1);
            assert(dut->src_b_sel_o==SRC_B_IMM);
            assert(dut->wr_reg_o==1);
            assert(dut->uses_rs1_o==1);
            assert(dut->uses_rs2_o==0);
            assert(dut->illegal_instruction_o==0);
            assert(dut->rs_ent_o==RS_ENT_LDST);
            assert(dut->dmem_size_o==0x2);
            assert(dut->dmem_type_o==0x2);
            std::cout << "decoder Test 3 Pass!" << std::endl;
        }
        /* 80000074:	00f82023          	sw	a5,0(a6) */
        // type:S
        if (sim_time == 11) {
            dut->inst_i = 0x00f82023;
        }
        if (sim_time == 12) {
            assert(dut->imm_type_o==IMM_S);
            assert(dut->rs1_o==0x10);
            assert(dut->rs2_o==0x0f);
            assert(dut->src_a_sel_o==SRC_A_RS1);
            assert(dut->src_b_sel_o==SRC_B_IMM);
            assert(dut->wr_reg_o==0);
            assert(dut->uses_rs1_o==1);
            assert(dut->uses_rs2_o==1);
            assert(dut->illegal_instruction_o==0);
            assert(dut->rs_ent_o==RS_ENT_LDST);
            assert(dut->dmem_size_o==0x2);
            assert(dut->dmem_type_o==0x2);
            std::cout << "decoder Test 4 Pass!" << std::endl;
        }
        sim_time++;
    }

    m_trace->dump(sim_time);
}
