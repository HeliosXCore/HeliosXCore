#pragma once
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <cstdint>
#include <memory>
#include <fmt/core.h>

template <class DUT>
class VerilatorTb {
   public:
    vluint64_t sim_time;
    vluint64_t posedge_cnt;
    vluint64_t cur_cycle;
    vluint64_t next_cycle;
    uint64_t clock;
    uint64_t start_time;
    uint64_t end_time;
    std::shared_ptr<DUT> dut;
    std::shared_ptr<VerilatedVcdC> m_trace;

    VerilatorTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
        : clock(clock),
          start_time(start_time),
          end_time(end_time),
          sim_time(0),
          posedge_cnt(0) {
        dut = std::make_shared<DUT>();
    }

    ~VerilatorTb() {}

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

    // 初始化 DUT 信号
    virtual void initialize_signal(){};
    // 输入信号
    virtual void input(){};
    // 验证 DUT 功能
    virtual void verify_dut(){};

    virtual void reset_dut() {
        if (sim_time >= 0 && sim_time < start_time) {
            initialize_signal();
        }
    }

    virtual void eval() { dut->eval(); }

    virtual void tick() {
        dut->clk_i ^= 1;
        if (dut->clk_i == 1) {
            posedge_cnt++;
        }
    }

    virtual vluint64_t get_clk() { return dut->clk_i; }

    bool posedge() { return (get_clk() == 1); }

    virtual void close_trace() { m_trace->close(); }

    virtual void open_trace(std::string filename) {
        m_trace->open(filename.c_str());
    }

    virtual void execute() {
        while (sim_time < end_time) {
            reset_dut();
            if ((sim_time % clock) == 0) {
                tick();
            }
            eval();
            if (posedge()) {
                input();
            }
            eval();
#ifndef WAVE
            verify_dut();
#endif
            m_trace->dump(sim_time);
            sim_time++;
        }
    }

    virtual void run(std::string vcd_filename) {
        Verilated::traceEverOn(true);
        m_trace = std::make_shared<VerilatedVcdC>();
        dut->trace(m_trace.get(), 1024);
        open_trace(vcd_filename);
        execute();

        close_trace();
    }
};
