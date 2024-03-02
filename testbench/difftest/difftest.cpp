#include "VHeliosX.h"
#include "memory.hpp"
#include "soc.hpp"
#include <fmt/core.h>
#include <memory.h>

using namespace heliosxsimulator;

template <>
void SocSimulator<VHeliosX>::tick() {
    cpu_clk = !cpu_clk;
    cpu_top->clk_i ^= 1;
}

template <>
void SocSimulator<VHeliosX>::initialize_dut() {
    cpu_top->clk_i = 0;
    cpu_top->reset_i = 0;
    cpu_top->idata_i = 0;
    cpu_top->dmem_rdata_i = 0;
}

template <>
void SocSimulator<VHeliosX>::connect_wire() {
    cpu_top->clk_i = cpu_clk;
    cpu_top->reset_i = cpu_reset;
    cpu_top->idata_i = cpu_inst_i;
    cpu_top->dmem_rdata_i = read_dmem_data_i;

    // pc_o = cpu_top->pc_o;
    dmem_we_o = cpu_top->dmem_we_o;
    write_dmem_data_o = cpu_top->dmem_wdata_o;
    dmem_addr_o = cpu_top->dmem_waddr_o;
}

template <>
bool SocSimulator<VHeliosX>::trace_on() {
    return false;
}

template <>
void SocSimulator<VHeliosX>::detect_commit_timeout() {
    // if (debug_wen) {
    //     last_commit = sim_time;
    // } else if (sim_time - last_commit > COMMIT_TIMEOUT) {
    //     std::cout << "Commit timeout at time " << sim_time << std::endl;
    //     running = false;
    // }
}

template <>
void SocSimulator<VHeliosX>::trace() {
    uint32_t ref_pc;
    uint32_t ref_wen;
    uint32_t ref_wreg_num;
    uint32_t ref_wreg_data;

    if (trace_on() && debug_wen && debug_wreg_num) {
        //     while (trace_file >> std::hex >> ref_pc >> ref_wen >>
        //            ref_wreg_num >> ref_wreg_data) {
        //     }
        //     if (ref_pc != pc_o || ref_wen != debug_wen ||
        //         ref_wreg_num != debug_wreg_data ||
        //         ref_wreg_data != debug_wreg_data) {
        //         std::cout << "Trace failed at time " << sim_time <<
        //         std::endl; fmt::println(
        //             "Expected: pc: {:x}, wen: {:x}, wreg_num: {:x}, "
        //             "wreg_data: {:x}",
        //             ref_pc, ref_wen, ref_wreg_num, ref_wreg_data);
        //         fmt::println(
        //             "Actual: pc: {:x}, wen: {:x}, wreg_num: {:x}, "
        //             "wreg_data: {:x}",
        //             pc_o, debug_wen, debug_wreg_num, debug_wreg_data);
        //         running = false;
        //     }
    }
}

template <>
void SocSimulator<VHeliosX>::setup() {
    initialize_dut();
    connect_wire();
    trace();
}

template <>
void SocSimulator<VHeliosX>::run(std::string trace_file) {
    // sim_time = 0;
    // end_time = 1000000;
    // start_time = 0;
    // running = true;

    // while (sim_time < end_time && running) {
    //     setup();
    //     if ((sim_time % clock) == 0) {
    //         tick();
    //     }
    //     eval();
    //     if (posedge()) {
    //         input();
    //     }
    //     eval();
    // }
}

int main() {
    std::shared_ptr<VHeliosX> cpu_top = std::make_shared<VHeliosX>();
    std::shared_ptr<EmulatorWrapper> emulator =
        std::make_shared<EmulatorWrapper>();

    const uint32_t img[] = {
        0x00000413,  // li s0, 0         -> addi s0, x0, 0
        0x74300613,  // li a2, 1859      -> addi a2, x0, 1859
        0x00860433,  // add s0, a2, s0
        0x3a100713,  // li a4, 929       -> addi a4, x0, 929
        0x01600793,  // li a5, 22        -> addi a5, x0, 22
        0x00f70533   // add a0, a4, a5
    };

    std::unique_ptr<Memory> imem = std::make_unique<Memory>(0, 0x10000);
    imem->load(0, (const char *)img, sizeof(img));

    std::unique_ptr<Memory> dmem = std::make_unique<Memory>(0, 0x10000);

    std::shared_ptr<SocSimulator<VHeliosX>> soc_sim =
        std::make_shared<SocSimulator<VHeliosX>>(
            cpu_top, emulator, std::move(imem), std::move(dmem), 5);

    // soc_sim->run("difftest.vcd");
    fmt::println("Success to setup!");
}