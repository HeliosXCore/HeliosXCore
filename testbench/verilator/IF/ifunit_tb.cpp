#include "fmt/core.h"
#include "verilator_tb.hpp"
#include "VIFUnit.h"
#include "VIFUnit___024root.h"
#include "error_handler.hpp"
#include <iostream>
#include <verilated.h>

vluint64_t sim_time = 0;

template <>
void VerilatorTb<VIFUnit>::initialize_signal() {
    dut->clk_i = 0;
    dut->reset_i = 1;
    dut->idata_i = 0;

    dut->stall_IF = 1;
    dut->kill_IF = 1;
};

class VIFUnitTb : public VerilatorTb<VIFUnit> {
   public:
    VIFUnitTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
        : VerilatorTb<VIFUnit>(clock, start_time, end_time) {}

    void test1_input() {
        if (sim_time == 50) {
            dut->reset_i = 0;
            dut->stall_IF = 0;
            dut->kill_IF = 0;

            /* dut->idata_i = 0x0000000526300100; */
            dut->idata_i = 0x26300100;
        }
    }

    void test1_verify() {
        if (sim_time == 60) {
            // ASSERT(dut->npc_o == 0x000f404c, "npc error");
            ASSERT(dut->inst_o == 0x26300100, "inst error: {:#x}", dut->inst_o);

            fmt::println("IFUnit test1 passed!");
        }
    }

    void test2_input() {
        if (sim_time == 60) {
            // dut->pc_i = 0x000f2620;
            dut->idata_i = 0xc2804365;
        }
    }

    void test2_verify() {
        if (sim_time == 70) {
            // ASSERT(dut->npc_o == 0x000f2624, "npc error");
            ASSERT(dut->inst_o == 0xc2804365, "inst error, {:#x}", dut->inst_o);

            fmt::println("IFUnit test2 passed!");
        }
    }

    void test3_input() {
        if (sim_time == 70) {
            // dut->pc_i = 0x000f0717;
            dut->idata_i = 0x00202423;
        }
    }

    void test3_verify() {
        if (sim_time == 80) {
            // ASSERT(dut->npc_o == 0x000f071b, "npc error");
            ASSERT(dut->inst_o == 0x00202423, "inst error: {:#x}", dut->inst_o);

            fmt::println("IFUnit test3 passed!");
        }
    }

    void input() {
        test1_input();
        test2_input();
        test3_input();
    }

    void verify_dut() {
        test1_verify();
        test2_verify();
        test3_verify();
    }
};

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    std::shared_ptr<VIFUnitTb> tb = std::make_shared<VIFUnitTb>(5, 50, 1000);

    tb->run("ifunit.vcd");
}
