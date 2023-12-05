#include "VRSAlu.h"
#include "VRSAlu___024root.h"
#include "verilator_tb.hpp"
#include "error_handler.hpp"

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
void VerilatorTb<VRSAlu>::tick() {
    dut->clk_i ^= 1;
}

template <>
vluint64_t VerilatorTb<VRSAlu>::get_clk() {
    return dut->clk_i;
}

class VRSAluTb : public VerilatorTb<VRSAlu> {
   public:
    VRSAluTb() : VerilatorTb<VRSAlu>() {}

    // 单指令发射测试
    void single_inst_issue_test() {
        dut->reset_i = 0;
        if (sim_time == 50) {
            // 写入一条指令
            // enable 写使能
            dut->we_1_i = 1;
            // 写入 0 号保留站项
            dut->write_addr_1_i = 0;
            // 写入指令地址
            dut->write_pc_1_i = 0x80000000;
            // 写入两条有效的操作数
            dut->write_op_1_1_i = 0x000000FF;
            dut->write_op_1_2_i = 0x000000EF;
            // Enable 有效
            dut->write_valid_1_1_i = 1;
            dut->write_valid_1_2_i = 1;
            // 写入目标重命名寄存器
            dut->write_tag_1_i = 0x1;
            // 第一条指令需写回寄存器
            dut->write_dst_1_i = 0x1;
        } else if (sim_time == 60) {
            // 下一个时钟周期
            assert(dut->busy_vector_o == 0x1);
            assert(dut->ready_o == 0x1);

            // 此时对第一条指令进行发射
            dut->issue_addr_i = 0x0;
            dut->clear_busy_i = 1;
        } else if (sim_time == 70) {
            // 验证是否发射成功
            assert(dut->busy_vector_o == 0x0);
            assert(dut->exe_op_1_o == 0x000000FF);
            assert(dut->exe_op_2_o == 0x000000EF);
        }
    }

    // 两条指令同时发射测试
    void two_inst_issue_test() {
        if (sim_time == 100) {
            // 同时发射两条指令
            dut->we_1_i = 1;
            dut->we_2_i = 1;

            // 存储到 3 号和 7 号保留站里
            dut->write_addr_1_i = 3;
            dut->write_addr_2_i = 7;

            // 写入两条指令的 pc 地址
            dut->write_pc_1_i = 0x80000004;
            dut->write_pc_2_i = 0x80000008;

            // 随机写入两条指令的操作数
            dut->write_op_1_1_i = 0x7;
            dut->write_op_1_2_i = 0x8;
            dut->write_op_2_1_i = 0x9;
            dut->write_op_2_2_i = 0xA;

            // 四个操作数全部有效
            dut->write_valid_1_1_i = 1;
            dut->write_valid_1_2_i = 1;
            dut->write_valid_2_1_i = 1;
            dut->write_valid_2_2_i = 1;

            // 写入重命名寄存器的编号
            dut->write_tag_1_i = 2;
            dut->write_tag_2_i = 3;

            // 两条指令都要写回寄存器
            dut->write_dst_1_i = 1;
            dut->write_dst_2_i = 1;

            // 写入 ALU 类型
            dut->write_alu_op_1_i = 5;
            dut->write_alu_op_2_i = 7;
        } else if (sim_time == 110) {
            // 禁止写入指令
            dut->we_1_i = 0;
            dut->we_2_i = 0;
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
            dut->issue_addr_i = 3;
            dut->clear_busy_i = 1;
        } else if (sim_time == 120) {
            // 验证第一条指令是否发射成功
            ASSERT(dut->busy_vector_o == (1 << 7), "Dut busy_vector_o = {}",
                   dut->busy_vector_o);
            ASSERT(dut->exe_op_1_o = 0x7, "Dut exe_op_1_o = {}",
                   dut->exe_imm_o);
            ASSERT(dut->exe_op_2_o == 0x8, "Dut exe_op_2_o = {}",
                   dut->exe_op_2_o);
            ASSERT(dut->exe_pc_o == 0x80000004, "Dut exe_pc_o = {}",
                   dut->exe_pc_o);
            ASSERT(dut->exe_rrf_tag_o == 2, "Dut exe_rrf_tag_o = {}",
                   dut->exe_rrf_tag_o);
            ASSERT(dut->exe_dst_val_o == 1, "Dut exe_dst_val_o = {}",
                   dut->exe_dst_val_o);
            ASSERT(dut->exe_alu_op_o == 5, "DUr exe_alu_op_o = {}",
                   dut->exe_alu_op_o);

            // 发射第二条指令
            dut->issue_addr_i = 7;
            dut->clear_busy_i = 1;
        } else if (sim_time == 130) {
            // 验证第二条指令发射是否成功
            ASSERT(dut->busy_vector_o == 0, "Dut busy_vector_o = {}",
                   dut->busy_vector_o);
            ASSERT(dut->exe_op_1_o == 0x9, "Dut exe_op_1_o = {}",
                   dut->exe_op_1_o);
            ASSERT(dut->exe_op_2_o == 0xA, "Dut exe_op_2_o = {}",
                   dut->exe_op_2_o);
            ASSERT(dut->exe_pc_o == 0x80000008, "Dut exe_pc_o = {}",
                   dut->exe_pc_o);
            ASSERT(dut->exe_rrf_tag_o == 3, "Dut rrf_tag_o = {}",
                   dut->exe_rrf_tag_o);
            ASSERT(dut->exe_dst_val_o == 1, "Dut exe_dst_val_o = {}",
                   dut->exe_dst_val_o);
            ASSERT(dut->exe_alu_op_o == 7, "Dut exe_alu_op_o = {}",
                   dut->exe_alu_op_o);
        }
    }

    void verilfy() override {
        single_inst_issue_test();
        two_inst_issue_test();
    }
};

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    // std::shared_ptr<VerilatorTb<VRSAlu>> tb =
    //     std::make_shared<VerilatorTb<VRSAlu>>();
    std::shared_ptr<VRSAluTb> tb = std::make_shared<VRSAluTb>();

    tb->run("rs_alu.vcd");
}