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
void SocSimulator<VHeliosX>::input() {
    Instruction inst_o;
    uint32_t inst_value_o;

    if (sim_time >= 90) {
        cpu_reset = 0;
    }

    // 应该reset_i=0的时候才能开始取指令，不然时序不对
    if (sim_time >= 90 && sim_time % 10 == 0) {
        imem->fetch(1, cpu_top->iaddr_o, inst_o, inst_value_o);
        cpu_inst_i = inst_o.instructions[0];
#ifdef DEBUG
        fmt::println(
            "sim_time: {}, inst_o: {:#x}, inst_value_o: {}, iaddr_o: {:#x}",
            sim_time, inst_o.instructions[0], inst_value_o, dut->iaddr_o);
#endif
    }
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

    debug_pc_o = cpu_top->debug_pc_o;
    debug_wen = cpu_top->debug_reg_wen_o;
    debug_wreg_data = cpu_top->debug_reg_wdata_o;
    debug_wreg_num = cpu_top->debug_reg_id_o;
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
    Verilated::traceEverOn(true);
    auto m_trace = std::make_unique<VerilatedVcdC>();
    cpu_top->trace(m_trace.get(), 99);
    m_trace->open(trace_file.c_str());

    sim_time = 0;
    running = true;

    while (!Verilated::gotFinish() && sim_time > 0 && running) {
        fmt::println("sim_time: {}", sim_time);
        reset_dut();
        if ((sim_time % clock) == 0) {
            tick();
        }
        cpu_top->eval();

        if ((sim_time % clock) == 0) {
            // 信号连线
            connect_wire();
            // 检查是否很长时间没有进行提交并结束仿真
            detect_commit_timeout();
            // Trace 判断 Dut 运行是否正确
            trace();
        }

        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
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
            cpu_top, emulator, std::move(imem), std::move(dmem), 5, 100);

    soc_sim->run("difftest.vcd");
}