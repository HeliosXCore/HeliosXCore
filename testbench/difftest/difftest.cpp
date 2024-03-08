#include "VHeliosX.h"
#include "memory.hpp"
#include "soc.hpp"
#include "ffi.hpp"
#include <sstream>  // for std::stringstream
#include <iostream>
#include <iomanip>  // for std::setw and std::setfill
#include <fmt/core.h>
#include <memory.h>
#include <cassert>
#include <cstdint>
#include <cstdio>
#include "VHeliosX.h"
#include "VHeliosX___024root.h"

using namespace heliosxsimulator;

#if 0
#define FILE_PATH "testcase/rv32ui-p-add.txt"
#define ARRAY_SIZE 328
#endif

#if 0
#define FILE_PATH "testcase/rv32ui-p-addi.txt"
#define ARRAY_SIZE 199
#endif

#if 0
#define FILE_PATH "testcase/rv32ui-p-and.txt"
#define ARRAY_SIZE 328
#endif

#if 0
#define FILE_PATH "testcase/rv32ui-p-andi.txt"
#define ARRAY_SIZE 158
#endif

#if 0
#define FILE_PATH "testcase/rv32ui-p-auipc.txt"
#define ARRAY_SIZE 78
#endif

#if 1
#define FILE_PATH "testbench/difftest/testcase/rv32ui-p-add_and_auipc.txt"
#define ARRAY_SIZE 1086
#endif

int read_file_to_array(const char *file_path, uint32_t *arr, int arr_size) {
    FILE *file;
    int count = 0;

    file = fopen(file_path, "r");
    if (!file) {
        perror("Error opening file");
        return -1;
    }

    while (count < arr_size && fscanf(file, "%x", &arr[count]) == 1) {
        count++;
    }

    fclose(file);
    return count;
}

class HeliosXCoreSimulator : public SocSimulator<VHeliosX> {
   public:
    HeliosXCoreSimulator(std::shared_ptr<VHeliosX> cpu_top,
                         std::shared_ptr<EmulatorWrapper> emulator,
                         std::unique_ptr<Memory> imem,
                         std::unique_ptr<Memory> dmem, uint64_t clock,
                         uint64_t start_time)
        : SocSimulator(cpu_top, emulator, std::move(imem), std::move(dmem),
                       clock, start_time) {}

    uint64_t get_rrf_rrfdata(uint64_t rrftag) {
        return cpu_top->rootp
            ->HeliosX__DOT__u_ReNameUnit__DOT__rrf__DOT__rrf_data[rrftag];
    }

    std::string to_hex_string_with_prefix(uint64_t value, int width) {
        std::stringstream stream;
        stream << "0x" << std::setfill(' ') << std::setw(width) << std::hex
               << value;
        return stream.str();
    }

    vluint64_t rob_valid =
        cpu_top->rootp->HeliosX__DOT__u_SingleInstROB__DOT__valid;

    vluint64_t rob_finish =
        cpu_top->rootp->HeliosX__DOT__u_SingleInstROB__DOT__finish;

    vluint64_t rob_dstvalid =
        cpu_top->rootp->HeliosX__DOT__u_SingleInstROB__DOT__dstValid;

    struct VlUnpacked<uint32_t, 64> inst_pc =
        cpu_top->rootp->HeliosX__DOT__u_SingleInstROB__DOT__inst_pc;

    struct VlUnpacked<uint8_t, 64> dstnum =
        cpu_top->rootp->HeliosX__DOT__u_SingleInstROB__DOT__dst;

    void print_rob() {
        // 设置列宽
        const int width_hex = 18;  // 16进制的列宽，增加以适应0x前缀
        const int width_dec = 5;   // 10进制的列宽
        const int width_tag = 8;   // rrftag列宽

        // 打印表头
        std::cout << std::left << std::setfill(' ') << std::setw(width_tag)
                  << "rrftag" << std::setw(width_hex) << "finish"
                  << std::setw(width_hex) << "valid" << std::setw(width_hex)
                  << "dstValid" << std::setw(width_hex) << "inst_pc"
                  << std::setw(width_dec) << "dst" << std::endl;

        // 打印各行数据
        for (int i = 0; i < 64; ++i) {
            std::cout << std::left << std::setfill(' ') << std::dec
                      << std::setw(width_tag) << i << std::setw(width_hex)
                      << to_hex_string_with_prefix((rob_finish >> i) & 1, 1)
                      << std::setw(width_hex)
                      << to_hex_string_with_prefix((rob_valid >> i) & 1, 1)
                      << std::setw(width_hex)
                      << to_hex_string_with_prefix((rob_dstvalid >> i) & 1, 1)
                      << std::setw(width_hex)
                      << to_hex_string_with_prefix(inst_pc[i], 8) << std::dec
                      << std::setw(width_dec)
                      << static_cast<unsigned>(dstnum[i]) << std::endl;
        }
        // 打印表头
        std::cout << std::left << std::setfill(' ') << std::setw(width_tag)
                  << "rrftag" << std::setw(width_hex) << "finish"
                  << std::setw(width_hex) << "valid" << std::setw(width_hex)
                  << "dstValid" << std::setw(width_hex) << "inst_pc"
                  << std::setw(width_dec) << "dst" << std::endl;
    }

    uint64_t get_rrf_rrfvalid(uint64_t rrftag) {
        vluint64_t rrfvalid =
            cpu_top->rootp
                ->HeliosX__DOT__u_ReNameUnit__DOT__rrf__DOT__rrf_valid;
        vluint64_t mask = 0x1l << rrftag;
        return (rrfvalid & mask) >> rrftag;
    }

    const char *regs[32] = {"$0", "ra", "sp",  "gp",  "tp", "t0", "t1", "t2",
                            "s0", "s1", "a0",  "a1",  "a2", "a3", "a4", "a5",
                            "a6", "a7", "s2",  "s3",  "s4", "s5", "s6", "s7",
                            "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"};

    const char *reg_idx2str(const uint32_t idx) { return regs[idx]; }

    uint32_t get_regidx(const char *regname) {
        for (int i = 0; i < 32; i++) {
            if (strcmp(regname, regs[i]) == 0) {
                return i;
            }
        }
        fmt::println("regname is not correct!\n");
        return -1;
    }
};

int main() {
    uint32_t img[ARRAY_SIZE];
    assert(read_file_to_array(FILE_PATH, img, ARRAY_SIZE) != -1);

    std::shared_ptr<VHeliosX> cpu_top = std::make_shared<VHeliosX>();

    std::shared_ptr<EmulatorWrapper> emulator =
        std::make_shared<EmulatorWrapper>();

    emulator->initialize();
    emulator->copy_from_dut(0x80000000, (void *)img, sizeof(img));

    std::unique_ptr<Memory> imem =
        std::make_unique<Memory>(0x80000000, 0x10000);
    imem->load(0x80000000, (const char *)img, sizeof(img));

    std::unique_ptr<Memory> dmem = std::make_unique<Memory>(0, 0x10000);

    std::shared_ptr<HeliosXCoreSimulator> soc_sim =
        std::make_shared<HeliosXCoreSimulator>(
            cpu_top, emulator, std::move(imem), std::move(dmem), 5, 100);

    soc_sim->run("difftest.vcd");
}
