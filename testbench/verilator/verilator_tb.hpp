#pragma once
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <memory>
#include <fmt/core.h>

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 50

template <class DUT>
class VerilatorTb {
   public:
    vluint64_t sim_time;
    vluint64_t posedge_cnt;
    std::shared_ptr<DUT> dut;
    std::shared_ptr<VerilatedVcdC> m_trace;

    VerilatorTb() {
        sim_time = 0;
        posedge_cnt = 0;
        dut = std::make_shared<DUT>();
    }

    ~VerilatorTb() {}

    virtual void initialize_signal();

    virtual void reset_dut() {
        if (sim_time >= 0 && sim_time < VERIF_START_TIME) {
            initialize_signal();
        }
    }

    virtual void eval() { dut->eval(); }

    virtual void tick();

    virtual void verilfy(){};

    virtual vluint64_t get_clk();

    virtual void close_trace() { m_trace->close(); }

    virtual void open_trace(std::string filename) {
        m_trace->open(filename.c_str());
    }

    virtual void execute() {
        while (sim_time < MAX_SIM_TIME) {
            reset_dut();
            if ((sim_time % 5) == 0) {
                tick();
            }
            eval();

            if (get_clk() == 1) {
                verilfy();
            }

            m_trace->dump(sim_time);
            sim_time++;
        }
    }

    virtual void run(std::string vcd_filename) {
        Verilated::traceEverOn(true);
        m_trace = std::make_shared<VerilatedVcdC>();
        dut->trace(m_trace.get(), 99);

        open_trace(vcd_filename);

        execute();

        close_trace();
    }
};