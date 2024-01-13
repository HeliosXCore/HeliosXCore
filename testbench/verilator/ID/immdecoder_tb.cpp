#include "fmt/core.h"
#include "verilator_tb.hpp"
#include "VImmDecoder.h"
#include "VImmDecoder___024root.h"
#include "error_handler.hpp"
#include <iostream>
#include <verilated.h>
#include "decoder.hpp"

vluint64_t sim_time = 0;

template <>
void VerilatorTb<VDecoder>::initialize_signal() {
    dut->inst = 0;
    dut->imm_type = 0
};

class VImmDecoderTb : public VerilatorTb<VImmDecoder> {
   public:
    VImmDecoderTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
        : VerilatorTb<VImmDecoder>(clock, start_time, end_time) {}

    void test1_input() {
        if (sim_time == 50) {
            // type:U
            /* 0x800002b7,  // lui t0,0x80000 */
            dut->inst = 0x800002b7;
            dut->imm_type = IMM_U;
        }
    }

    void test1_verify() {
        if (sim_time == 55) {
            ASSERT(dut->imm == 0x80000000);           
            fmt::println("ImmDecoder test1 passed!");
        }
    }

    void test2_input() {
        if (sim_time == 60) {
        // type: J
        /* 80000024:	374000ef          	jal	ra,80000398 <halt> */
            dut->inst = 0x374000ef;
            dut->imm_type = IMM_J;
        }
    }

    void test2_verify() {
        if (sim_time == 65) {
            ASSERT(dut->imm == 0x374);
            fmt::println("ImmDecoder test2 passed!");
        }
    }

    void test3_input() {
        if (sim_time == 70) {
        // type:I
        /* 80000034:	00082883          	lw	a7,0(a6) */
            dut->inst = 0x00082883;
            dut->imm_type = IMM_I;
        }
    }

    void test3_verify() {
        if (sim_time == 75) {
            ASSERT(dut->imm == 0x0);
            fmt::println("ImmDecoder test3 passed!");
        }
    }

    void test4_input() {
        if (sim_time == 80) {
        // type:S
        /* 80000074:	00f82023          	sw	a5,0(a6) */
            dut->inst = 0x00f82023;
            dut->imm_type = IMM_S;
        }
    }

    void test4_verify() {
        if (sim_time == 85) {
            ASSERT(dut->imm == 0x0);
            fmt::println("ImmDecoder test4 passed!");
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

    std::shared_ptr<VImmDecoderTb> tb = std::make_shared<VImmDecoderTb>(5, 50, 1000);

    tb->run("ImmDecoder.vcd");
}
