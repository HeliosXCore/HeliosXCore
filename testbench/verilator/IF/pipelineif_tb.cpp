#include "fmt/core.h"
#include "verilator_tb.hpp"
#include "VPipelinIF.h"
#include "VPipelineIF___024root.h"
#include "error_handler.hpp"
#include <iostream>
#include <verilated.h>

vluint64_t sim_time = 0;

template <>
void VerilatorTb<VPipelineIF>::initialize_signal() {
    dut->clk_i = 0;
    dut->reset_i = 1;
    dut->pc_i = 0;
    dut->idata_i = 0;
};

class VPipelineIFTb : public VerilatorTb<VPipelineIF> {
   public:
    VPipelineIFTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
        : VerilatorTb<VPipelineIF>(clock, start_time, end_time) {}

    void test1_input() {
        if (sim_time == 50) {
            dut->reset_i = 0;

            dut->pc_i = 0x000f4048;
            dut->idata_i = 0x0000000526300100;
        }
    }

    void test1_verify() {
        if (sim_time == 55) {
            ASSERT(dut->npc_o==0x000f404c,"npc error");
            ASSERT(dut->inst1_o==0x26300100,"inst1 error");
            
            fmt::println("PipelineIF test1 passed!");
        }
    }

    void test2_input() {
        if (sim_time == 60) {
            dut->pc_i = 0x000f2620;
            dut->idata_i = 0xfdff06fc2804365;
        }
    }

    void test2_verify() {
        if (sim_time == 65) {
            ASSERT(dut->npc_o==0x000f2624,"npc error");
            ASSERT(dut->inst1_o==0xc2804365,"inst1 error");

            fmt::println("PipelineIF test2 passed!");
        }
    }

    void test3_input() {
        if (sim_time == 70) {
            dut->pc_i = 0x000f0717;
            dut->idata_i = 0xffdff06f00202423;
        }
    }

    void test3_verify() {
        if (sim_time == 75) {
            ASSERT(dut->npc_o==0x000f071b,"npc error");
            ASSERT(dut->inst1_o==0xffdff06f,"inst1 error");

            fmt::println("PipelineIF test3 passed!");
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

    std::shared_ptr<VPipelineIFTb> tb = std::make_shared<VPipelineIFTb>(5, 50, 1000);

    tb->run("PipelineIF.vcd");
}
