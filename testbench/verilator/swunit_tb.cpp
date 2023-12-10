#include "verilator_tb.hpp"
#include "VSwUnit.h"
#include "VSwUnit___024root.h"
#include "error_handler.hpp"
#include <iostream>

template <>
void VerilatorTb<VSwUnit>::initialize_signal() {
    dut->reset_i = 1;
    dut->dp_next_rrf_cycle_i = 1;

    dut->dp_req_alu_num_i = 0;
    dut->dp_pc_1_i = 0;
    dut->dp_pc_2_i = 0;

    dut->dp_op_1_1_i = 0;
    dut->dp_op_1_2_i = 0;
    dut->dp_op_2_1_i = 0;
    dut->dp_op_2_2_i = 0;

    dut->dp_valid_1_1_i = 0;
    dut->dp_valid_1_2_i = 0;
    dut->dp_valid_2_1_i = 0;
    dut->dp_valid_2_2_i = 0;

    dut->dp_imm_1_i = 0;
    dut->dp_imm_2_i = 0;

    dut->dp_rrf_tag_1_i = 0;
    dut->dp_rrf_tag_2_i = 0;

    dut->dp_dst_1_i = 0;
    dut->dp_dst_2_i = 0;

    dut->dp_alu_op_1_i = 0;
    dut->dp_alu_op_2_i = 0;

    dut->stall_dp_i = 0;
    dut->kill_dp_i = 0;

    dut->exe_result_1_i = 0;
    dut->exe_result_2_i = 0;
    dut->exe_result_3_i = 0;
    dut->exe_result_4_i = 0;
    dut->exe_result_5_i = 0;
    dut->exe_result_1_dst_i = 0;
    dut->exe_result_2_dst_i = 0;
    dut->exe_result_3_dst_i = 0;
    dut->exe_result_4_dst_i = 0;
    dut->exe_result_5_dst_i = 0;
}

template <>
vluint64_t VerilatorTb<VSwUnit>::get_clk() {
    return dut->clk_i;
}

class VSwUnitTb : public VerilatorTb<VSwUnit> {
   public:
    enum class OperandType { VALUE, RRFTAG };

    VSwUnitTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
        : VerilatorTb<VSwUnit>(clock, start_time, end_time) {}

    void enable_next_rrf_cycle() { dut->dp_next_rrf_cycle_i = 1; }
    void disable_next_rrf_cycle() { dut->dp_next_rrf_cycle_i = 0; }

    // 派发指令通过选择发送给第一个 write_port 或者第二个 write_port
    void dispatch(uint8_t dispatch_port, OperandType op_1_type,
                  OperandType op_2_type, int op_1, int op_2, uint32_t pc,
                  uint8_t write_rrf_tag, bool write_dst, uint8_t alu_op) {
        if (dispatch_port == 0) {
            // 写入第一个写端口
            dut->dp_pc_1_i = pc;
            dut->dp_rrf_tag_1_i = write_rrf_tag;
            dut->dp_dst_1_i = write_dst;
            dut->dp_op_1_1_i = op_1;
            dut->dp_op_1_2_i = op_2;
            dut->dp_alu_op_1_i = alu_op;
            switch (op_1_type) {
                case OperandType::VALUE:
                    dut->dp_valid_1_1_i = 1;
                    break;
                case OperandType::RRFTAG:
                    dut->dp_valid_1_1_i = 0;
                    break;
            }
            switch (op_2_type) {
                case OperandType::VALUE:
                    dut->dp_valid_1_2_i = 1;
                    break;
                case OperandType::RRFTAG:
                    dut->dp_valid_1_2_i = 0;
                    break;
            }
        } else if (dispatch_port == 1) {
            // 写入第二个写端口
            dut->dp_pc_2_i = pc;
            dut->dp_rrf_tag_2_i = write_rrf_tag;
            dut->dp_dst_2_i = write_dst;
            dut->dp_op_2_1_i = op_1;
            dut->dp_op_2_2_i = op_2;
            dut->dp_alu_op_2_i = alu_op;
            switch (op_1_type) {
                case OperandType::VALUE:
                    dut->dp_valid_2_1_i = 1;
                    break;
                case OperandType::RRFTAG:
                    dut->dp_valid_2_1_i = 0;
                    break;
            }

            switch (op_2_type) {
                case OperandType::VALUE:
                    dut->dp_valid_2_2_i = 1;
                    break;
                case OperandType::RRFTAG:
                    dut->dp_valid_2_2_i = 0;
                    break;
            }
        }
    }

    // 单指令发射测试
    void single_inst_issue_test() {
        if (sim_time == 50) {
            dut->reset_i = 0;
            dut->stall_dp_i = 0;
            dut->kill_dp_i = 0;
            disable_next_rrf_cycle();
            // 分配一个 entry
            dut->dp_req_alu_num_i = 1;
            // 发射一条指令
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 1, 2,
                     0x80000000, 0, 1, 1);

            ASSERT(dut->dp_valid_1_1_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_1_2_i == 1,
                   "Wrong dispatch write valid signal!");
        } else if (sim_time == 60) {
            ASSERT(dut->rootp->SwUnit__DOT__exe_alu_ready == 1,
                   "Wrong alu ready signal!");
        } else if (sim_time == 70) {
            ASSERT(dut->exe_alu_op_1_o == 1, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 2, "Wrong output alu op signal!");
        }
    }

    void verify_dut() override { single_inst_issue_test(); }
};

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VSwUnitTb> tb = std::make_shared<VSwUnitTb>(5, 50, 1000);

    tb->run("swunit.vcd");
}