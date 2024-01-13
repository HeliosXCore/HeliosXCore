#include "fmt/core.h"
#include "verilator_tb.hpp"
#include "VDecoder.h"
#include "VDecoder___024root.h"
#include "error_handler.hpp"
#include <iostream>
#include <verilated.h>
#include "decoder.hpp"

vluint64_t sim_time = 0;

template <>
void VerilatorTb<VDecoder>::initialize_signal() {
    dut->inst1_i = 0;
};

class VDecoderTb : public VerilatorTb<VDecoder> {
   public:
    VDecoderTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
        : VerilatorTb<VDecoder>(clock, start_time, end_time) {}

    void test1_input() {
        if (sim_time == 50) {
            // type:U
            /* 0x800002b7,  // lui t0,0x80000 */
            dut->inst1_i = 0x800002b7;
        }
    }

    void test1_verify() {
        if (sim_time == 55) {
            ASSERT(dut->imm_type_1_o == IMM_U);
            ASSERT(dut->rs1_1_o == inst1_i[19:15]);
            ASSERT(dut->rs2_1_o == inst1_i[24:20]);
            ASSERT(dut->rd_1_o == 0x05);
            ASSERT(dut->src_a_sel_1_o == SRC_A_ZERO);
            ASSERT(dut->src_b_sel_1_o == SRC_B_IMM);
            ASSERT(dut->wr_reg_1_o == 1);
            ASSERT(dut->uses_rs1_1_o == 0);
            ASSERT(dut->uses_rs2_1_o == 0);
            ASSERT(dut->illegal_instruction_1_o == 0);
            ASSERT(dut->alu_op_1_o == ALU_OP_ADD);
            ASSERT(dut->rs_ent_1_o == RS_ENT_ALU);
            
            fmt::println("Decoder test1 passed!");
        }
    }

    void test2_input() {
        if (sim_time == 60) {
        // type: J
        /* 80000024:	374000ef          	jal	ra,80000398 <halt> */
            dut->inst1_i = 0x374000ef;
        }
    }

    void test2_verify() {
        if (sim_time == 65) {
            ASSERT(dut->imm_type_1_o == IMM_J);
            ASSERT(dut->rd_1_o == 0x01);
            ASSERT(dut->src_a_sel_1_o == SRC_A_PC);
            ASSERT(dut->src_b_sel_1_o == SRC_B_FOUR);
            ASSERT(dut->wr_reg_1_o == 1);
            ASSERT(dut->uses_rs1_1_o == 0);
            ASSERT(dut->uses_rs2_1_o == 0);
            ASSERT(dut->illegal_instruction_1_o == 0);
            ASSERT(dut->alu_op_1_o == ALU_OP_ADD);
            ASSERT(dut->rs_ent_1_o == RS_ENT_JAL);

            fmt::println("Decoder test2 passed!");
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
        if (sim_time == 75) {
            ASSERT(dut->imm_type_o == IMM_I);
            ASSERT(dut->rs1_o == 0x10);
            ASSERT(dut->rd_o == 0x11);
            ASSERT(dut->src_a_sel_o == SRC_A_RS1);
            ASSERT(dut->src_b_sel_o == SRC_B_IMM);
            ASSERT(dut->wr_reg_o == 1);
            ASSERT(dut->uses_rs1_o == 1);
            ASSERT(dut->uses_rs2_o == 0);
            ASSERT(dut->illegal_instruction_o == 0);
            ASSERT(dut->rs_ent_o == RS_ENT_LDST);
            ASSERT(dut->alu_op_1_o == ALU_OP_ADD);
            ASSERT(dut->dmem_size_o == 0x2);
            ASSERT(dut->dmem_type_o == 0x2);

            fmt::println("Decoder test3 passed!");
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
        if (sim_time == 85) {
            ASSERT(dut->imm_type_o == IMM_S);
            ASSERT(dut->rs1_o == 0x10);
            ASSERT(dut->rs2_o == 0x0f);
            ASSERT(dut->src_a_sel_o == SRC_A_RS1);
            ASSERT(dut->src_b_sel_o == SRC_B_IMM);
            ASSERT(dut->wr_reg_o == 0);
            ASSERT(dut->uses_rs1_o == 1);
            ASSERT(dut->uses_rs2_o == 1);
            ASSERT(dut->illegal_instruction_o == 0);
            ASSERT(dut->alu_op_1_o == ALU_OP_ADD);
            ASSERT(dut->rs_ent_o == RS_ENT_LDST);
            ASSERT(dut->dmem_size_o == 0x2);
            ASSERT(dut->dmem_type_o == 0x2);

            fmt::println("Decoder test4 passed!");
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

    std::shared_ptr<VDecoderTb> tb = std::make_shared<VDecoderTb>(5, 50, 1000);

    tb->run("Decoder.vcd");
}
