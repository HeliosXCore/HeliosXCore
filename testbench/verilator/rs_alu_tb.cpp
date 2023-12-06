#include "VRSAlu.h"
#include "VRSAlu___024root.h"
#include "verilator_tb.hpp"
#include "error_handler.hpp"
#include <vector>

template <>
void VerilatorTb<VRSAlu>::initialize_signal() {
    dut->reset_i = 1;
    dut->next_rrf_cycle_i = 0;
    dut->clear_busy_i = 0;
    dut->issue_addr_i = 0;
    dut->write_addr_1_i = 0;
    dut->write_addr_2_i = 0;
    dut->we_1_i = 0;
    dut->we_2_i = 0;
    dut->write_valid_1_1_i = 0;
    dut->write_valid_1_2_i = 0;
    dut->write_tag_1_i = 0;
    dut->write_dst_1_i = 0;
    dut->write_alu_op_1_i = 0;

    dut->write_valid_2_1_i = 0;
    dut->write_valid_2_2_i = 0;
    dut->write_tag_2_i = 0;
    dut->write_dst_2_i = 0;
    dut->write_alu_op_2_i = 0;

    dut->exe_result_1_dst_i = 0;
    dut->exe_result_2_dst_i = 0;
    dut->exe_result_3_dst_i = 0;
    dut->exe_result_4_dst_i = 0;
    dut->exe_result_5_dst_i = 0;

    dut->exe_result_1_i = 0;
    dut->exe_result_2_i = 0;
    dut->exe_result_3_i = 0;
    dut->exe_result_4_i = 0;
    dut->exe_result_5_i = 0;

    dut->write_pc_1_i = 0;
    dut->write_op_1_1_i = 0;
    dut->write_op_1_2_i = 0;
    dut->write_imm_1_i = 0;

    dut->write_pc_2_i = 0;
    dut->write_op_2_1_i = 0;
    dut->write_op_2_2_i = 0;
    dut->write_imm_2_i = 0;
}

template <>
vluint64_t VerilatorTb<VRSAlu>::get_clk() {
    return dut->clk_i;
}

class VRSAluTb : public VerilatorTb<VRSAlu> {
   public:
    enum class OperandType { VALUE, RRFTAG };

    VRSAluTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
        : VerilatorTb<VRSAlu>(clock, start_time, end_time) {}

    // 派发指令通过选择发送给第一个 write_port 或者第二个 write_port
    void dispatch(uint8_t dispatch_port, OperandType op_1_type,
                  OperandType op_2_type, int op_1, int op_2, uint32_t pc,
                  uint8_t entry_addr, uint8_t write_rrf_tag, bool write_dst,
                  uint8_t alu_op) {
        if (dispatch_port == 0) {
            // 写入第一个写端口
            dut->we_1_i = 1;
            dut->write_addr_1_i = entry_addr;
            dut->write_pc_1_i = pc;
            dut->write_tag_1_i = write_rrf_tag;
            dut->write_dst_1_i = write_dst;
            dut->write_op_1_1_i = op_1;
            dut->write_op_1_2_i = op_2;
            dut->write_alu_op_1_i = alu_op;
            switch (op_1_type) {
                case OperandType::VALUE:
                    dut->write_valid_1_1_i = 1;
                    break;
                case OperandType::RRFTAG:
                    dut->write_valid_1_1_i = 0;
                    break;
            }
            switch (op_2_type) {
                case OperandType::VALUE:
                    dut->write_valid_1_2_i = 1;
                    break;
                case OperandType::RRFTAG:
                    dut->write_valid_1_2_i = 0;
                    break;
            }
        } else if (dispatch_port == 1) {
            // 写入第二个写端口
            dut->we_2_i = 1;
            dut->write_addr_2_i = entry_addr;
            dut->write_pc_2_i = pc;
            dut->write_tag_2_i = write_rrf_tag;
            dut->write_dst_2_i = write_dst;
            dut->write_op_2_1_i = op_1;
            dut->write_op_2_2_i = op_2;
            dut->write_alu_op_2_i = alu_op;
            switch (op_1_type) {
                case OperandType::VALUE:
                    dut->write_valid_2_1_i = 1;
                    break;
                case OperandType::RRFTAG:
                    dut->write_valid_2_1_i = 0;
                    break;
            }

            switch (op_2_type) {
                case OperandType::VALUE:
                    dut->write_valid_2_2_i = 1;
                    break;
                case OperandType::RRFTAG:
                    dut->write_valid_2_2_i = 0;
                    break;
            }
        }
    }

    void issue_inst(uint8_t issue_addr) {
        dut->issue_addr_i = issue_addr;
        dut->clear_busy_i = 1;
    }

    void verify_issue_inst(int op_1, int op_2, uint32_t pc, uint8_t entry_addr,
                           uint8_t write_rrf_tag, bool write_dst,
                           uint8_t alu_op) {
        // 验证发射的指令是否正确
        ASSERT(dut->exe_op_1_o == op_1, "Error exe_op_1_o = {} in {}",
               dut->exe_op_1_o, sim_time);
        ASSERT(dut->exe_op_2_o == op_2, "Error exe_op_2_o = {} in {}",
               dut->exe_op_2_o, sim_time);
        ASSERT(dut->exe_pc_o == pc, "Error exe_pc_o = {} in {}", dut->exe_pc_o,
               sim_time);
        ASSERT(dut->exe_rrf_tag_o == write_rrf_tag,
               "Error exe_rrf_tag_o = {} in {}", dut->exe_rrf_tag_o, sim_time);
        ASSERT(dut->exe_dst_val_o == write_dst,
               "Error exe_dst_val_o = {} in {}", dut->exe_dst_val_o, sim_time);
        ASSERT(dut->exe_alu_op_o == alu_op, "Dut exe_alu_op_o = {} in {}",
               dut->exe_alu_op_o, sim_time);
    }

    void disable_write_port(uint8_t write_port) {
        switch (write_port) {
            case 0:
                dut->we_1_i = 0;
                break;
            case 1:
                dut->we_2_i = 0;
                break;
            default:
                break;
        }
    }

    // 单指令发射测试
    void single_inst_issue_test() {
        dut->reset_i = 0;
        if (sim_time == 50) {
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 0x000000FF,
                     0x000000EF, 0x80000000, 0x0, 0x1, 0x1, 1);
        } else if (sim_time == 60) {
            // 下一个时钟周期
            disable_write_port(0);
            ASSERT(dut->busy_vector_o == 0x1, "Dut busy_vector_o = {}",
                   dut->busy_vector_o);
            ASSERT(dut->ready_o == 0x1, "Dut ready_o = {}", dut->ready_o);

            // 此时对第一条指令进行发射
            issue_inst(0);
        } else if (sim_time == 70) {
            // 验证是否发射成功
            ASSERT(dut->busy_vector_o == 0x0, "Dut busy_vector_o = {}",
                   dut->busy_vector_o);
            verify_issue_inst(0x000000FF, 0x000000EF, 0x80000000, 0x0, 0x1, 1,
                              1);
            initialize_signal();
        }
    }

    // 两条指令同时发射测试
    void two_inst_issue_test() {
        if (sim_time == 100) {
            // 同时发射两条指令
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 0x7, 0x8,
                     0x80000004, 3, 2, 1, 5);
            dispatch(1, OperandType::VALUE, OperandType::VALUE, 0x9, 0xA,
                     0x80000008, 7, 3, 1, 7);

        } else if (sim_time == 110) {
            // 禁止写入指令
            disable_write_port(0);
            disable_write_port(1);
            ASSERT(dut->rootp->RSAlu__DOT__select_rs_entry_3 == 1,
                   "select_rs_entry_3 = {}",
                   dut->rootp->RSAlu__DOT__select_rs_entry_3);
            ASSERT(dut->rootp->RSAlu__DOT__select_rs_entry_7 == 1,
                   "select_rs_entry_7 = {}",
                   dut->rootp->RSAlu__DOT__select_rs_entry_7);
            ASSERT(dut->busy_vector_o == ((1 << 3) | (1 << 7)),
                   "dut->busy_vector_o = {}", dut->busy_vector_o);
            ASSERT(dut->ready_o == ((1 << 3) | (1 << 7)), "dut->ready_o = {}",
                   dut->ready_o);
            // 对第一条指令进行发射
            issue_inst(3);
        } else if (sim_time == 120) {
            // 验证第一条指令是否发射成功
            verify_issue_inst(0x7, 0x8, 0x80000004, 3, 2, 1, 5);
            // 发射第二条指令
            issue_inst(7);
        } else if (sim_time == 130) {
            // 验证第二条指令发射是否成功
            verify_issue_inst(0x9, 0xA, 0x80000008, 7, 3, 1, 7);
            initialize_signal();
        }
    }

    // 发射许多指令
    void issue_many_inst() {}

    // 发射一条带 RRF TAG 的指令
    void issue_inst_with_rrf_tag_test() {
        if (sim_time == 200) {
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 7, 8,
                     0x80000010, 5, 2, 1, 5);
        } else if (sim_time == 210) {
            // 此时指令应该没有准备好
            ASSERT(dut->busy_vector_o == (1 << 5),
                   "Error busy_vector_o = {} in {}", dut->busy_vector_o,
                   sim_time);
            ASSERT(dut->ready_o == 0, "Error ready_o = {} in {}", dut->ready_o,
                   sim_time);
            // 屏蔽写使能
            disable_write_port(0);
            // 执行前递
            dut->exe_result_1_dst_i = 8;
            dut->exe_result_1_i = 0xC;
        } else if (sim_time == 220) {
            // 发射指令
            issue_inst(5);
        } else if (sim_time == 230) {
            // 验证指令是否发射成功
            verify_issue_inst(0x7, 0xC, 0x80000010, 5, 2, 1, 5);
            initialize_signal();
        }
    }

    void verify_dut() override {
        // 单指令发射测试
        single_inst_issue_test();
        // 两条指令同时发射测试
        two_inst_issue_test();
        // 发射一条带 RRF TAG 的指令
        issue_inst_with_rrf_tag_test();
    }
};

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VRSAluTb> tb = std::make_shared<VRSAluTb>(5, 50, 1000);

    tb->run("rs_alu.vcd");
}