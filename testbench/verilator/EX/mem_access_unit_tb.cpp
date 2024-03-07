#include <sys/types.h>
#include <cstdint>
#include "error_handler.hpp"
#include "fmt/core.h"
#include "verilator_tb.hpp"
#include "mem_sim.hpp"
#include "consts.hpp"
#include "VMemAccessUnit.h"
#include "VMemAccessUnit___024root.h"

#define BASEADDR 0x80000000
#define ADDR(offset) (BASEADDR + offset)

class VMemAccessUnitTb : public VerilatorTb<VMemAccessUnit> {
   public:
    VMemAccessUnitTb(uint64_t clock, uint64_t start_time, uint64_t end_time,
                     std::shared_ptr<Memory> mem)
        : VerilatorTb<VMemAccessUnit>(clock, start_time, end_time), mem(mem) {}

    void initialize_signal() override {
        dut->clk_i = 0;
        dut->reset_i = 1;
        dut->issue_i = 0;
        dut->src1_i = 0;
        dut->src2_i = 0;
        dut->imm_i = 0;
        dut->if_write_rrf_i = 0;
        dut->complete_i = 0;
        dut->load_data_from_data_memory_i = 0;
    }

    void store_input() {
        if (sim_time == 50) {
            // 1 向 0x80000000 写入 1
            dut->reset_i = 0;
            dut->issue_i = 1;
            dut->src1_i = BASEADDR;
            dut->src2_i = 1;
            dut->imm_i = 0;
            dut->if_write_rrf_i = 0;
        } else if (sim_time == 60) {
            // 2 向 0x80000004 写入 2
            dut->src2_i = 2;
            dut->imm_i = 4;
        } else if (sim_time == 70) {
            // 3 向 0x80000008 写入 3
            dut->src2_i = 3;
            dut->imm_i = 8;
            // 同时 1 完成
            dut->complete_i = 1;
        } else if (sim_time == 80) {
            // 2 3 一直未完成
            dut->issue_i = 0;
            dut->complete_i = 0;
        }
    }

    void load_input() {
        if (sim_time == 90) {
            // 读 0x80000000
            dut->issue_i = 1;
            dut->src1_i = BASEADDR;
            dut->imm_i = 0;
            dut->if_write_rrf_i = 1;
        } else if (sim_time == 94) {
            // 模拟内存读取，在95之前内存必须给出值
            dut->load_data_from_data_memory_i = 1;
        } else if (sim_time == 100) {
            // 读 0x80000004
            dut->imm_i = 4;
        } else if (sim_time == 110) {
            // 读 0x80000008
            dut->imm_i = 8;
        } else if (sim_time == 120) {
            dut->issue_i = 0;
        }
    }

    void store_verify() {
        if (sim_time == 50) {
            ASSERT(dut->rrf_we_o == 0, "MemAccessUnit store_test error");
            ASSERT(dut->rob_we_o == 1, "MemAccessUnit store_test error");
            ASSERT(dut->store_buffer_mem_we_o == 0,
                   "MemAccessUnit store_test error");
            ASSERT(dut->store_buffer_write_address_o == 0,
                   "MemAccessUnit store_test error");
            ASSERT(dut->store_buffer_write_data_o == 0,
                   "MemAccessUnit store_test error");
        } else if (sim_time == 60) {
            ASSERT(dut->rrf_we_o == 0, "MemAccessUnit store_test error");
            ASSERT(dut->rob_we_o == 1, "MemAccessUnit store_test error");
            ASSERT(dut->store_buffer_mem_we_o == 0,
                   "MemAccessUnit store_test error");
            ASSERT(dut->store_buffer_write_address_o == 0,
                   "MemAccessUnit store_test error");
            ASSERT(dut->store_buffer_write_data_o == 0,
                   "MemAccessUnit store_test error");
        } else if (sim_time == 70) {
            ASSERT(dut->rrf_we_o == 0, "MemAccessUnit store_test error");
            ASSERT(dut->rob_we_o == 1, "MemAccessUnit store_test error");
            ASSERT(dut->store_buffer_mem_we_o == 0,
                   "MemAccessUnit store_test error");
            ASSERT(dut->store_buffer_write_address_o == 0,
                   "MemAccessUnit store_test error");
            ASSERT(dut->store_buffer_write_data_o == 0,
                   "MemAccessUnit store_test error");
        } else if (sim_time == 80) {
            ASSERT(dut->rrf_we_o == 0, "MemAccessUnit store_test error");
            ASSERT(dut->rob_we_o == 0, "MemAccessUnit store_test error");
            ASSERT(dut->store_buffer_mem_we_o == 1,
                   "MemAccessUnit store_test error");
            ASSERT(dut->store_buffer_write_address_o == ADDR(0),
                   "MemAccessUnit store_test error");
            ASSERT(dut->store_buffer_write_data_o == 1,
                   "MemAccessUnit store_test error");
            // 模拟内存写入
            uint32_t ack, data;
            mem->apply(1, 1, ADDR(0), 1, 0xf, ack, data);
            fmt::println("MemAccessUnit store_test passed!");
        }
    }

    void load_verify() {
        if (sim_time == 90) {
            ASSERT(dut->rrf_we_o == 1, "MemAccessUnit load_test error");
            ASSERT(dut->rob_we_o == 1, "MemAccessUnit load_test error");
            ASSERT(dut->load_address_o == ADDR(0),
                   "MemAccessUnit load_test error");
            ASSERT(dut->rootp->MemAccessUnit__DOT__hit_store_buffer == 0,
                   "MemAccessUnit load_test error");
        } else if (sim_time == 100) {
            ASSERT(dut->rrf_we_o == 1, "MemAccessUnit load_test error");
            ASSERT(dut->rob_we_o == 1, "MemAccessUnit load_test error");
            ASSERT(dut->load_address_o == ADDR(4),
                   "MemAccessUnit load_test error");
            ASSERT(dut->load_data_o == 1, "MemAccessUnit load_test error");
            ASSERT(dut->rootp->MemAccessUnit__DOT__hit_store_buffer == 0,
                   "MemAccessUnit load_test error");
        } else if (sim_time == 110) {
            ASSERT(dut->rrf_we_o == 1, "MemAccessUnit load_test error");
            ASSERT(dut->rob_we_o == 1, "MemAccessUnit load_test error");
            ASSERT(dut->load_address_o == ADDR(8),
                   "MemAccessUnit load_test error");
            ASSERT(dut->load_data_o == 2, "MemAccessUnit load_test error");
            ASSERT(dut->rootp->MemAccessUnit__DOT__hit_store_buffer == 1,
                   "MemAccessUnit load_test error");
        } else if (sim_time == 120) {
            ASSERT(dut->rrf_we_o == 0, "MemAccessUnit load_test error");
            ASSERT(dut->rob_we_o == 0, "MemAccessUnit load_test error");
            ASSERT(dut->load_address_o == ADDR(8),
                   "MemAccessUnit load_test error");
            ASSERT(dut->load_data_o == 3, "MemAccessUnit load_test error");
            ASSERT(dut->rootp->MemAccessUnit__DOT__hit_store_buffer == 1,
                   "MemAccessUnit load_test error");
            fmt::println("MemAccessUnit load_test passed!");
        }
    }

    void input() override {
        store_input();
        load_input();
    }

    void verify_dut() override {
        store_verify();
        load_verify();
    }

   protected:
    std::shared_ptr<Memory> mem;
};

int main(int argc, char **argv, char **env) {
    const uint32_t zero_data[0x10000] = {0};

    std::shared_ptr<Memory> mem = std::make_shared<Memory>(0x80000000, 0x40000);
    mem->load(0x80000000, (const char *)zero_data, sizeof(zero_data));
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VMemAccessUnitTb> tb =
        std::make_shared<VMemAccessUnitTb>(5, 50, 1500, mem);

    tb->run("MemAccessUnit.vcd");
}
