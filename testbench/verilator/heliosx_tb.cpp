#include "error_handler.hpp"
#include "verilator_tb.hpp"
#include "mem_sim.h"
#include "VHeliosX.h"
#include "VHeliosX___024root.h"

class VHeliosXTb : public VerilatorTb<VHeliosX> {
   public:
    VHeliosXTb(uint64_t clock, uint64_t start_time, uint64_t end_time,
               std::shared_ptr<Memory> mem)
        : VerilatorTb<VHeliosX>(clock, start_time, end_time), mem(mem) {}

    void initialize_signal() override {
        dut->reset_i = 1;
        dut->idata_i = 0;
        dut->dmem_data_i = 0;
    }

    void input() override {
        Instruction inst_o;
        uint32_t inst_value_o;

        if (sim_time % 10 == 0) {
            mem->fetch(1, dut->iaddr_o, inst_o, inst_value_o);
        }

        if (sim_time == 100) {
            dut->reset_i = 0;
            fmt::println("sim_time: {}, inst_o: {:#x}, iaddr_o: {:#x}",
                         sim_time, inst_o.instructions[0], dut->iaddr_o);
            dut->idata_i = static_cast<uint64_t>(inst_o.instructions[1]) << 32 |
                           inst_o.instructions[0];
        } else if (sim_time == 110) {
            fmt::println("sim_time: {}, inst_o: {:#x}, iaddr_o: {:#x}",
                         sim_time, inst_o.instructions[0], dut->iaddr_o);
            dut->idata_i = static_cast<uint64_t>(inst_o.instructions[1]) << 32 |
                           inst_o.instructions[0];
        } else if (sim_time == 120) {
            fmt::println("sim_time: {}, inst_o: {:#x}, iaddr_o: {:#x}",
                         sim_time, inst_o.instructions[0], dut->iaddr_o);
            dut->idata_i = static_cast<uint64_t>(inst_o.instructions[1]) << 32 |
                           inst_o.instructions[0];
        }
    }

    void verify_dut() override {
        if (sim_time == 115) {
            // sim_time 110: 00000413
            ASSERT(dut->rootp->HeliosX__DOT__imm_1 == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__imm_1);
        } else if (sim_time == 125) {
            // sim_time 120: 74300613
            ASSERT(dut->rootp->HeliosX__DOT__imm_1 == 1859,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__imm_1);
        }
    }

   protected:
    std::shared_ptr<Memory> mem;
};

int main(int argc, char **argv, char **env) {
    const uint32_t img[] = {
        0x00000413,  // li s0, 0
        0x74300613,  // li a2, 1859
        0x00860433,  // add s0, a2, s0
        0x3a100713,  // li a4, 929
        0x01600793,  // li a5, 22
        0x00f70533,  // add a0, a4, a5
    };

    std::shared_ptr<Memory> mem = std::make_shared<Memory>(0, 0x10000);
    mem->load(0, (const char *)img, sizeof(img) * sizeof(uint32_t));

    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VHeliosXTb> tb =
        std::make_shared<VHeliosXTb>(5, 50, 1500, mem);

    tb->run("HeliosX.vcd");
    fmt::print("HeliosX Dut Correctness passed!\n");
}