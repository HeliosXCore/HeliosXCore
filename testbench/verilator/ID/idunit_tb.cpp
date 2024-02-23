#include "fmt/core.h"
#include "verilator_tb.hpp"
#include "VIDUnit.h"
#include "VIDUnit___024root.h"
#include "error_handler.hpp"
#include <iostream>
#include <verilated.h>
#include "decoder.hpp"

vluint64_t sim_time = 0;

template <>
void VerilatorTb<VIDUnit>::initialize_signal() {
    dut->clk_i = 0;
    dut->reset_i = 1;
    dut->kill_ID = 1;
    dut->stall_DP = 1;

    dut->inst1_i = 0;
};

class VIDUnitTb : public VerilatorTb<VIDUnit> {
   public:
    VIDUnitTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
        : VerilatorTb<VIDUnit>(clock, start_time, end_time) {}

    void test1_input() {
        if (sim_time == 50) {
            dut->reset_i = 0;
            dut->kill_ID = 0;
            dut->stall_DP = 0;
            // type:U
            /* 0x800002b7,  // lui t0,0x80000 */
            dut->inst1_i = 0x800002b7;
        }
    }

    void test1_verify() {
        if (sim_time == 60) {
            ASSERT(dut->imm_type_1_o == IMM_U, "imm_type error");
            ASSERT(dut->rs1_1_o == 0x00, "rs1 error");
            ASSERT(dut->rs2_1_o == 0x00, "rs2 error");
            ASSERT(dut->rd_1_o == 0x05, "rd error");
            ASSERT(dut->src_a_sel_1_o == SRC_A_ZERO, "src_a_sel error");
            ASSERT(dut->src_b_sel_1_o == SRC_B_IMM, "src_b_sel error");
            ASSERT(dut->wr_reg_1_o == 1, "wr_reg error");
            ASSERT(dut->uses_rs1_1_o == 0, "uses_rs1 error");
            ASSERT(dut->uses_rs2_1_o == 0, "uses_rs2 error");
            ASSERT(dut->illegal_instruction_1_o == 0,
                   "illegal instruction error");
            ASSERT(dut->alu_op_1_o == ALU_OP_ADD, "alu_op error");
            ASSERT(dut->rs_ent_1_o == RS_ENT_ALU, "rs_ent error");

            fmt::println("IDUnit test1 passed!");
        }
    }

    void test2_input() {
        if (sim_time == 60) {
            // type: J
            /* 80000024:	374000ef          	jal	ra,80000398
             * <halt> */
            dut->inst1_i = 0x374000ef;
        }
    }

    void test2_verify() {
        if (sim_time == 70) {
            ASSERT(dut->imm_type_1_o == IMM_J, "imm_type error");
            ASSERT(dut->rd_1_o == 0x01, "rs1 error");
            ASSERT(dut->src_a_sel_1_o == SRC_A_PC, "src_a_sel error");
            ASSERT(dut->src_b_sel_1_o == SRC_B_FOUR, "src_b_sel error");
            ASSERT(dut->wr_reg_1_o == 1, "wr_reg error");
            ASSERT(dut->uses_rs1_1_o == 0, "uses_rs1 error");
            ASSERT(dut->uses_rs2_1_o == 0, "uses_rs2 error");
            ASSERT(dut->illegal_instruction_1_o == 0,
                   "illegal instruction error");
            ASSERT(dut->alu_op_1_o == ALU_OP_ADD, "alu_op error");
            ASSERT(dut->rs_ent_1_o == RS_ENT_JAL, "rs_ent error");

            fmt::println("IDUnit test2 passed!");
        }
    }

    void test3_input() {
        if (sim_time == 70) {
            // type:I
            /* 80000034:	00082883          	lw	a7,0(a6) */
            dut->inst1_i = 0x00082883;
        }
    }

    void test3_verify() {
        if (sim_time == 80) {
            ASSERT(dut->imm_type_1_o == IMM_I, "imm_type error");
            ASSERT(dut->rs1_1_o == 0x10, "rs1 error");
            ASSERT(dut->rd_1_o == 0x11, "rd error");
            ASSERT(dut->src_a_sel_1_o == SRC_A_RS1, "src_a_sel error");
            ASSERT(dut->src_b_sel_1_o == SRC_B_IMM, "src_b_sel error");
            ASSERT(dut->wr_reg_1_o == 1, "wr_reg error");
            ASSERT(dut->uses_rs1_1_o == 1, "uses_rs1 error");
            ASSERT(dut->uses_rs2_1_o == 0, "uses_rs2 error");
            ASSERT(dut->illegal_instruction_1_o == 0,
                   "illegal instruction error");
            ASSERT(dut->rs_ent_1_o == RS_ENT_LDST, "rs_ent error");
            ASSERT(dut->alu_op_1_o == ALU_OP_ADD, "alu_op error");
            ASSERT(dut->dmem_size_1_o == 0x2, "dmem_size error");
            ASSERT(dut->dmem_type_1_o == 0x2, "dmem_type error");

            fmt::println("IDUnit test3 passed!");
        }
    }

    void test4_input() {
        if (sim_time == 80) {
            // type:S
            /* 80000074:	00f82023          	sw	a5,0(a6) */
            dut->inst1_i = 0x00f82023;
        }
    }

    void test4_verify() {
        if (sim_time == 90) {
            ASSERT(dut->imm_type_1_o == IMM_S, "imm_type error");
            ASSERT(dut->rs1_1_o == 0x10, "rs1 error");
            ASSERT(dut->rs2_1_o == 0x0f, "rs2 error");
            ASSERT(dut->src_a_sel_1_o == SRC_A_RS1, "src_a_sel error");
            ASSERT(dut->src_b_sel_1_o == SRC_B_IMM, "src_b_sel error");
            ASSERT(dut->wr_reg_1_o == 0, "wr_reg error");
            ASSERT(dut->uses_rs1_1_o == 1, "uses_rs1 error");
            ASSERT(dut->uses_rs2_1_o == 1, "uses_rs2 error");
            ASSERT(dut->illegal_instruction_1_o == 0,
                   "illegal instruction error");
            ASSERT(dut->alu_op_1_o == ALU_OP_ADD, "alu_op error");
            ASSERT(dut->rs_ent_1_o == RS_ENT_LDST, "rs_ent error");
            ASSERT(dut->dmem_size_1_o == 0x2, "dmem_size error");
            ASSERT(dut->dmem_type_1_o == 0x2, "dmem_type error");

            fmt::println("IDUnit test4 passed!");
        }
    }

    void input() {
        test1_input();
        test2_input();
        test3_input();
        test4_input();
    }

    void verify_dut() {
        test1_verify();
        test2_verify();
        test3_verify();
        test4_verify();
    }
};

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VIDUnitTb> tb = std::make_shared<VIDUnitTb>(5, 50, 1000);

    tb->run("idunit.vcd");
}
