#include "fmt/core.h"
#include "verilator_tb.hpp"
#include "VStoreBuffer.h"
#include "VStoreBuffer___024root.h"
#include "error_handler.hpp"
#include <ios>
#include <iostream>
#include <ostream>
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
void VerilatorTb<VStoreBuffer>::initialize_signal() {
    dut->clk_i = 0;
    dut->reset_i = 1;
    dut->issue_i = 0;
    dut->we_i = 0;
    dut->address_i = 0;
    dut->write_data_i = 0;
    dut->complete_i = 0;
};

class VStoreBufferTb : public VerilatorTb<VStoreBuffer> {
   public:
    VStoreBufferTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
        : VerilatorTb<VStoreBuffer>(clock, start_time, end_time) {}

    void store_test_input() {
        if (sim_time == 50) {
            // 1. store 4 to 0x88000000
            dut->reset_i = 0;
            dut->issue_i = 1;
            dut->we_i = 1;
            dut->address_i = 0x88000000;
            dut->write_data_i = 4;
        } else if (sim_time == 60) {
            // 1 complete
            dut->complete_i = 1;
            // 2. store 8 to 0x88000004
            dut->address_i = 0x88000004;
            dut->write_data_i = 8;
        } else if (sim_time == 70) {
            // 2 complete
            dut->complete_i = 1;
            // 3. store 12 to 0x88000008
            dut->address_i = 0x88000008;
            dut->write_data_i = 12;
        } else if (sim_time == 80) {
            // 3 complete but a load instruction has issued
            dut->complete_i = 1;
            dut->we_i = 0;
        }
    }

    void store_test_verify() {
        if (sim_time == 70) {
            // check 1
            ASSERT(dut->mem_we_o == 1, "StoreBuffer store_test error");
            ASSERT(dut->write_address_o == 0x88000000,
                   "StoreBuffer store_test error");
            ASSERT(dut->write_data_o == 4, "StoreBuffer store_test error");
        } else if (sim_time == 80) {
            // check 2
            ASSERT(dut->mem_we_o == 1, "StoreBuffer store_test error");
            ASSERT(dut->write_address_o == 0x88000004,
                   "StoreBuffer store_test error");
            ASSERT(dut->write_data_o == 8, "StoreBuffer store_test error");
        } else if (sim_time == 90) {
            // check 3
            ASSERT(dut->mem_we_o == 0, "StoreBuffer store_test error");
            ASSERT(dut->write_address_o == 0x88000004,
                   "StoreBuffer store_test error");
            ASSERT(dut->write_data_o == 8, "StoreBuffer store_test error");
            fmt::println("StoreBuffer store_test passed!");
        }
    }

    void load_test_input() {
        if (sim_time == 90) {
            // 1. load 0x88000004 should not hit.
            dut->we_i = 0;
            dut->address_i = 0x88000004;
        } else if (sim_time == 100) {
            // 2. load 0x88000008
            dut->we_i = 0;
            dut->address_i = 0x88000008;
        }
    }

    void load_test_verify() {
        if (sim_time == 100) {
            // check 1
            ASSERT(dut->hit == 0, "StoreBuffer load_test error");
        } else if (sim_time == 110) {
            // check 2
            ASSERT(dut->hit == 1, "StoreBuffer load_test error");
            ASSERT(dut->read_data_o == 12, "StoreBuffer load_test error");
            fmt::println("StoreBuffer load_test passed!");
        }
    }

    void input() {
        store_test_input();
        load_test_input();
    }

    void verify_dut() {
        store_test_verify();
        load_test_verify();
    }
};

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VStoreBufferTb> tb =
        std::make_shared<VStoreBufferTb>(5, 50, 1000);

    tb->run("StoreBuffer.vcd");
}
