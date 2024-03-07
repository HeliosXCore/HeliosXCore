#include "VHeliosX.h"
#include "memory.hpp"
#include "soc.hpp"
#include "ffi.hpp"
#include <fmt/core.h>
#include <memory.h>
#include <cassert>
#include <cstdint>
#include <cstdio>

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
#define FILE_PATH "testcase/rv32ui-p-add_addi.txt"
#define ARRAY_SIZE 524
#endif

#if 0
#define FILE_PATH "testcase/rv32ui-p-and.txt"
#define ARRAY_SIZE 328
#endif

#if 0
#define FILE_PATH "testcase/rv32ui-p-andi.txt"
#define ARRAY_SIZE 158
#endif

#if 1
#define FILE_PATH "testcase/rv32ui-p-auipc.txt"
#define ARRAY_SIZE 78
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

int main() {
    const uint32_t img[] = {
        0x00000413,  // li s0, 0         -> addi s0, x0, 0
        0x74300613,  // li a2, 1859      -> addi a2, x0, 1859
        0x00860433,  // add s0, a2, s0
        0x3a100713,  // li a4, 929       -> addi a4, x0, 929
        0x01600793,  // li a5, 22        -> addi a5, x0, 22
        0x00f70533   // add a0, a4, a5
    };

    uint32_t img1[ARRAY_SIZE];
    assert(read_file_to_array(FILE_PATH, img1, ARRAY_SIZE) != -1);

    std::shared_ptr<VHeliosX> cpu_top = std::make_shared<VHeliosX>();

    std::shared_ptr<EmulatorWrapper> emulator =
        std::make_shared<EmulatorWrapper>();

    emulator->initialize();
    /* emulator->copy_from_dut(0x80000000, (void *)img, sizeof(img)); */
    emulator->copy_from_dut(0x80000000, (void *)img1, sizeof(img1));

    std::unique_ptr<Memory> imem =
        std::make_unique<Memory>(0x80000000, 0x10000);
    /* imem->load(0x80000000, (const char *)img, sizeof(img)); */
    imem->load(0x80000000, (const char *)img1, sizeof(img1));

    std::unique_ptr<Memory> dmem = std::make_unique<Memory>(0, 0x10000);

    std::shared_ptr<SocSimulator<VHeliosX>> soc_sim =
        std::make_shared<SocSimulator<VHeliosX>>(
            cpu_top, emulator, std::move(imem), std::move(dmem), 5, 100);

    soc_sim->run("difftest.vcd");
}
