#pragma once
#include "verilator_tb.hpp"
#include "error_handler.hpp"
#include "mem_sim.hpp"
#include "uart_sim.hpp"

template <class Dut>
class Soc {
   public:
    // Uart 外设
    std::shared_ptr<UartSim> uart;
    // 指令内存
    std::shared_ptr<MemSim> inst_mem;
    // 数据内存
    std::shared_ptr<MemSim> data_mem;
    // CPU 核心
    std::shared_ptr<VerilatorTb<Dut>> core;

    // 加载指令
    uint64_t load_inst(uint64_t addr);
    // 加载数据
    uint64_t load_data(uint64_t addr);
    // 存储数据
    void store_data(uint64_t addr, uint64_t data);
    // 读 UART
    uint64_t uart_read(uint64_t addr);
    // 写 UART
    void uart_write(uint64_t addr, uint64_t data);

    // 开机从第一条指令开始运行 CPU
    void run();
};