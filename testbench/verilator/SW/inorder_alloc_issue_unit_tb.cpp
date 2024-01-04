#include "verilator_tb.hpp"
#include "error_handler.hpp"
#include "VInorderAllocIssueUnit.h"
#include "VInorderAllocIssueUnit___024root.h"

class VInorderAllocIssueTB : public VerilatorTb<VInorderAllocIssueUnit> {
   public:
    VInorderAllocIssueTB(uint64_t clock, uint64_t start_time, uint64_t end_time)
        : VerilatorTb<VInorderAllocIssueUnit>(clock, start_time, end_time) {}

    void alloc_test() {
        if (sim_time == 50) {
            dut->reset_i = 0;
            dut->req_num_i = 1;
        } else if (sim_time == 60) {
            dut->busy_vector_i = 0x1;
            dut->req_num_i = 2;
            dut->ready_vector_i = 0x1;
        } else if (sim_time == 70) {
            dut->req_num_i = 0;
            dut->busy_vector_i = 0x7;
        }
    }

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

    void verify_dut() override { alloc_test(); }
};

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    std::shared_ptr<VInorderAllocIssueTB> tb =
        std::make_shared<VInorderAllocIssueTB>(5, 50, 300);
    tb->run("inorder_alloc_issue_unit.vcd");
    fmt::println("Inorder Alloc Issue Unit Test Pass!");
    return 0;
}