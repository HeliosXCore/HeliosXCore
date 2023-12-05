#include "VRSAlu.h"
#include "VRSAlu___024root.h"
#include "verilator_tb.hpp"

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

    void simple_verify_allocate_rs_0() {
        dut->reset_i = 0;
        if (sim_time == 50) {
            // 写入一条指令
            // enable 写使能
            dut->we_1_i = 1;
            // 写入 0 号保留站项
            dut->write_addr_1_i = 0;
            // 写入指令地址
            dut->write_addr_1_i = 0x80000000;
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
            fmt::println("Busy Vector: {}", dut->busy_vector_o);
            assert(dut->busy_vector_o == 0x1);
        }
    }

    void verilfy() override { simple_verify_allocate_rs_0(); }
};

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    // std::shared_ptr<VerilatorTb<VRSAlu>> tb =
    //     std::make_shared<VerilatorTb<VRSAlu>>();
    std::shared_ptr<VRSAluTb> tb = std::make_shared<VRSAluTb>();

    tb->run("rs_alu.vcd");
}