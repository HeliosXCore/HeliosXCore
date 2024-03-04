#include "VHeliosX.h"
#include "memory.hpp"
#include "soc.hpp"
#include "ffi.hpp"
#include <fmt/core.h>
#include <memory.h>
#include <cstdint>

using namespace heliosxsimulator;

#define FILE_PATH \
    "/home/mrgeek/document/dump/isa/txt_file/inst/rv32ui-p-add.txt"
#define ARRAY_SIZE \
    328  // Adjust this based on the actual number of lines in the file
int read_file_to_array(const char *file_path, uint32_t *arr, size_t arr_size) {
    FILE *file = fopen(file_path, "r");
    if (file == NULL) {
        perror("Failed to open file");
        return -1;
    }
    for (size_t i = 0; i < arr_size; i++) {
        if (fscanf(file, "%x", &arr[i]) != 1) {
            fclose(file);
            return -1;  // Error reading the file
        }
    }
    fclose(file);
    return 0;  // Success
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
    read_file_to_array(FILE_PATH, img1, ARRAY_SIZE);

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
