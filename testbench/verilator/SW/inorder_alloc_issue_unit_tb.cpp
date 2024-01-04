#include "verilator_tb.hpp"
#include "error_handler.hpp"
#include "VInorderAllocIssueUnit.h"
#include "VInorderAllocIssueUnit___024root.h"

class VInorderAllocIssueTB : public VerilatorTb<VInorderAllocIssueUnit> {
   public:
    VInorderAllocIssueTB(uint64_t clock, uint64_t start_time, uint64_t end_time)
        : VerilatorTb<VInorderAllocIssueUnit>(clock, start_time, end_time) {}

    void initialize_signal() override {
        dut->clk_i = 0;
        dut->reset_i = 1;
        dut->req_num_i = 0;
        dut->busy_vector_i = 0;
        dut->previsous_busy_vector_next_i = 0;
        dut->ready_vector_i = 0;
        dut->dp_kill_i = 0;
        dut->dp_stall_i = 0;
    }

    void verify_dut() override {}
};