#include "fmt/core.h"
#include "verilator_tb.hpp"
#include "VExUnit.h"
#include "VExUnit___024root.h"
#include "error_handler.hpp"
#include <iostream>
#include <verilated.h>

#define ALU_OP_ADD 0
#define SRC_A_RS1 0
#define SRC_A_PC 1
#define SRC_B_RS2 0
#define SRC_B_FOUR 2

#define RV32_BRANCH 0b1100011
#define RV32_JALR 0b1100111
#define ALU_OP_SEQ 8

vluint64_t sim_time = 0;

template <>
void VerilatorTb<VExUnit>::initialize_signal() {
    dut->clk_i = 0;
    dut->reset_i = 1;

    dut->alu_issue_i = 0;
    dut->alu_if_write_rrf_i = 0;
    dut->alu_rrf_tag_i = 0;
    dut->alu_pc_i = 0;
    dut->alu_imm_i = 0;
    dut->alu_alu_op_i = 0;
    dut->alu_src1_i = 0;
    dut->alu_src_a_select_i = 0;
    dut->alu_src2_i = 0;
    dut->alu_src_b_select_i = 0;

    dut->branch_issue_i = 0;
    dut->branch_if_write_rrf_i = 0;
    dut->branch_rrf_tag_i = 0;
    dut->branch_pc_i = 0;
    dut->branch_imm_i = 0;
    dut->branch_alu_op_i = 0;
    dut->branch_src1_i = 0;
    dut->branch_src2_i = 0;
    dut->branch_opcode_i = 0;

    dut->mem_access_src1_i = 0;
    dut->mem_access_src2_i = 0;
    dut->mem_access_imm_i = 0;
    dut->mem_access_if_write_rrf_i = 0;
    dut->mem_access_issue_i = 0;
    dut->mem_access_complete_i = 0;
    dut->mem_access_load_data_from_data_memory_i = 0;
    dut->mem_access_rrf_tag_i = 0;
};

class VExUnitTb : public VerilatorTb<VExUnit> {
   public:
    VExUnitTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
        : VerilatorTb<VExUnit>(clock, start_time, end_time) {}

    void test1_input() {
        if (sim_time == 50) {
            dut->reset_i = 0;

            dut->alu_issue_i = 1;
            dut->alu_if_write_rrf_i = 1;
            dut->alu_alu_op_i = ALU_OP_ADD;
            dut->alu_src1_i = 1;
            dut->alu_src_a_select_i = SRC_A_RS1;
            dut->alu_src2_i = 2;
            dut->alu_src_b_select_i = SRC_B_RS2;

            dut->branch_issue_i = 1;
            dut->branch_if_write_rrf_i = 1;
            dut->branch_pc_i = 0x80000000;
            dut->branch_imm_i = 0x8000;
            dut->branch_alu_op_i = ALU_OP_SEQ;
            dut->branch_src1_i = 0x88000000;
            dut->branch_src2_i = 10;
            dut->branch_opcode_i = RV32_JALR;

            dut->mem_access_issue_i = 1;
            dut->mem_access_src1_i = 0x80000000;
            dut->mem_access_src2_i = 4;
        }
    }

    void test1_verify() {
        if (sim_time == 55) {
            ASSERT(dut->alu_result_o == 1 + 2, "ALU error");
            ASSERT(dut->branch_jump_result_o == 0x88000000 + 0x8000,
                   "Branch error");
            fmt::println("ExUnit test1 passed!");
        }
    }

    void test2_input() {
        if (sim_time == 60) {
            dut->alu_issue_i = 1;
            dut->alu_if_write_rrf_i = 1;
            dut->alu_alu_op_i = ALU_OP_ADD;
            dut->alu_pc_i = 0x80000000;
            dut->alu_imm_i = 0x8000;
            dut->alu_src1_i = 1;
            dut->alu_src_a_select_i = SRC_A_PC;
            dut->alu_src2_i = 2;
            dut->alu_src_b_select_i = SRC_B_FOUR;

            dut->branch_issue_i = 1;
            dut->branch_if_write_rrf_i = 1;
            dut->branch_pc_i = 0x80000000;
            dut->branch_imm_i = 0x8000;
            dut->branch_alu_op_i = ALU_OP_SEQ;
            dut->branch_src1_i = 10;
            dut->branch_src2_i = 10;
            dut->branch_opcode_i = RV32_BRANCH;

            dut->mem_access_complete_i = 1;
        }
    }

    void test2_verify() {
        if (sim_time == 65) {
            ASSERT(dut->alu_result_o == 0x80000000 + 4, "ALU error");
            ASSERT(dut->branch_jump_result_o == 0x80000000 + 0x8000,
                   "Branch error");
            fmt::println("ExUnit test2 passed!");
        }
    }

    void input() {
        test1_input();
        test2_input();
    }

    void verify_dut() {
        test1_verify();
        test2_verify();
    }
};

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VExUnitTb> tb = std::make_shared<VExUnitTb>(5, 50, 1000);

    tb->run("ExUnit.vcd");
}
