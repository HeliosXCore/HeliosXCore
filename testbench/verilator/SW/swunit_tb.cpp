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
            // fmt::println("alu_busy_vector: {:#x}",
            //              dut->rootp->SwUnit__DOT__alu_busy_vector);
            // 检查分配 entry 编号
            ASSERT(dut->rootp->SwUnit__DOT__alu_allocate_en_1 == 1,
                   "Wrong allocate enable signal!");
            ASSERT(dut->rootp->SwUnit__DOT__free_alu_entry_1 == 0,
                   "Wrong allocate entry singal {}!",
                   dut->rootp->SwUnit__DOT__free_alu_entry_1);
            // 发射一条指令
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 1, 2,
                     0x80000000, 0, 1, 1);

            ASSERT(dut->dp_valid_1_1_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_1_2_i == 1,
                   "Wrong dispatch write valid signal!");
        } else if (sim_time == 60) {
            // 在第二个周期，将输入信号修改为 0
            dut->dp_req_alu_num_i = 0;
            ASSERT(dut->exe_alu_op_1_o == 1, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 2, "Wrong output alu op signal!");
        }
    }

    void double_inst_issue_test() {
        if (sim_time == 100) {
            dut->reset_i = 0;
            dut->stall_dp_i = 0;
            dut->kill_dp_i = 0;
            disable_next_rrf_cycle();
            // 分配两个 entry
            dut->dp_req_alu_num_i = 2;

            // 输出分配的 entry
            // 检查分配 entry 编号
            ASSERT(dut->rootp->SwUnit__DOT__alu_allocate_en_1 == 1,
                   "Wrong allocate enable signal!");
            ASSERT(dut->rootp->SwUnit__DOT__free_alu_entry_1 == 0,
                   "Wrong allocate entry singal {}!",
                   dut->rootp->SwUnit__DOT__free_alu_entry_1);
            ASSERT(dut->rootp->SwUnit__DOT__alu_allocate_en_2 == 1,
                   "Wrong allocate enable signal!");
            ASSERT(dut->rootp->SwUnit__DOT__free_alu_entry_2 == 1,
                   "Wrong allocate entry singal {}!",
                   dut->rootp->SwUnit__DOT__free_alu_entry_2);
            // 发射两条条指令
            // 第一条指令的 RRF Tag 为 5
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 3, 4,
                     0x80000000, 5, 1, 1);
            // 第二条指令的 RRF Tag 为 6
            dispatch(1, OperandType::VALUE, OperandType::VALUE, 5, 6,
                     0x80000004, 6, 1, 2);

            ASSERT(dut->dp_valid_1_1_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_1_2_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_2_1_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_2_2_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->rootp->SwUnit__DOT__alu_clear_busy == 0,
                   "Wrong alu clear busy signal {}!",
                   dut->rootp->SwUnit__DOT__alu_clear_busy);
            // fmt::println("Busy Vector: {:#x}",
            //              dut->rootp->SwUnit__DOT__alu_busy_vector);
        } else if (sim_time == 110) {
            // 在第二个周期，将输入信号修改为 0
            dut->dp_req_alu_num_i = 0;
            // fmt::println("Busy Vector: {:#x}",
            //              dut->rootp->SwUnit__DOT__alu_busy_vector);
            // fmt::println("ALU entry value: {:#x}",
            //              dut->rootp->SwUnit__DOT__alu_entry_value);
            // fmt::println("ALU issue addr: {}",
            //              dut->rootp->SwUnit__DOT__alu_issue_addr);

            // 第二周期发射第一条指令
            ASSERT(dut->rootp->exe_alu_ready_o == 3, "Wrong alu ready signal!");
            ASSERT(dut->exe_alu_op_1_o == 3, "Wrong output alu op1 signal {}!",
                   dut->exe_alu_op_1_o);
            ASSERT(dut->exe_alu_op_2_o == 4, "Wrong output alu op2 signal {}!",
                   dut->exe_alu_op_2_o);
        } else if (sim_time == 120) {
            // 第三周期发射第二条指令
            ASSERT(dut->exe_alu_op_1_o == 5, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 6, "Wrong output alu op signal!");
        }
    }

    void triple_inst_issue_test() {
        if (sim_time == 200) {
            dut->reset_i = 0;
            dut->stall_dp_i = 0;
            dut->kill_dp_i = 0;
            disable_next_rrf_cycle();
            // 分配两个 entry
            dut->dp_req_alu_num_i = 2;

            // 输出分配的 entry
            // 检查分配 entry 编号
            ASSERT(dut->rootp->SwUnit__DOT__alu_allocate_en_1 == 1,
                   "Wrong allocate enable signal!");
            ASSERT(dut->rootp->SwUnit__DOT__free_alu_entry_1 == 0,
                   "Wrong allocate entry singal {}!",
                   dut->rootp->SwUnit__DOT__free_alu_entry_1);
            ASSERT(dut->rootp->SwUnit__DOT__alu_allocate_en_2 == 1,
                   "Wrong allocate enable signal!");
            ASSERT(dut->rootp->SwUnit__DOT__free_alu_entry_2 == 1,
                   "Wrong allocate entry singal {}!",
                   dut->rootp->SwUnit__DOT__free_alu_entry_2);

            // 发射两条条指令，两条指令的第二个操作数均为 RRFTag = 1
            // 第一条指令的 RRF Tag 为 5
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 7, 1,
                     0x80000008, 5, 1, 1);
            // 第二条指令的 RRF Tag 为 6
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 8, 1,
                     0x8000000C, 6, 1, 2);

            ASSERT(dut->dp_valid_1_1_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_1_2_i == 0,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_2_1_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_2_2_i == 0,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->rootp->SwUnit__DOT__alu_clear_busy == 0,
                   "Wrong alu clear busy signal {}!",
                   dut->rootp->SwUnit__DOT__alu_clear_busy);
        } else if (sim_time == 210) {
            dut->dp_req_alu_num_i = 1;
            // 发射第三条指令
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 9, 10,
                     0x80000008, 7, 1, 1);
        } else if (sim_time == 220) {
            dut->dp_req_alu_num_i = 0;
            ASSERT(dut->exe_alu_ready_o == 4, "Wrong alu ready signal {}!",
                   dut->exe_alu_ready_o);
            ASSERT(dut->exe_alu_op_1_o == 9, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 10, "Wrong output alu op signal!");

            // 执行前递
            dut->exe_result_1_dst_i = 1;
            dut->exe_result_1_i = 11;
        } else if (sim_time == 230) {
            ASSERT(dut->exe_alu_op_1_o == 7, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 11, "Wrong output alu op signal!");
        } else if (sim_time == 240) {
            ASSERT(dut->exe_alu_op_1_o == 8, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 11, "Wrong output alu op signal!");
        } else if (sim_time == 250) {
            dut->exe_result_1_dst_i = 0;
            dut->exe_result_1_i = 0;
        }
    }

    void oldest_inst_issue_test() {
        if (sim_time == 300) {
            dut->reset_i = 0;
            dut->stall_dp_i = 0;
            dut->kill_dp_i = 0;
            disable_next_rrf_cycle();
            // 分配两个 entry
            dut->dp_req_alu_num_i = 2;

            // 输出分配的 entry
            // 检查分配 entry 编号
            ASSERT(dut->rootp->SwUnit__DOT__alu_allocate_en_1 == 1,
                   "Wrong allocate enable signal!");
            ASSERT(dut->rootp->SwUnit__DOT__free_alu_entry_1 == 0,
                   "Wrong allocate entry singal {}!",
                   dut->rootp->SwUnit__DOT__free_alu_entry_1);
            ASSERT(dut->rootp->SwUnit__DOT__alu_allocate_en_2 == 1,
                   "Wrong allocate enable signal!");
            ASSERT(dut->rootp->SwUnit__DOT__free_alu_entry_2 == 1,
                   "Wrong allocate entry singal {}!",
                   dut->rootp->SwUnit__DOT__free_alu_entry_2);

            // 发射两条条指令，两条指令的第二个操作数均为 RRFTag = 1
            // 第一条指令的 RRF Tag 为 5
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 7, 1,
                     0x80000008, 5, 1, 1);
            // 第二条指令的 RRF Tag 为 6
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 8, 1,
                     0x8000000C, 6, 1, 2);

            ASSERT(dut->dp_valid_1_1_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_1_2_i == 0,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_2_1_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_2_2_i == 0,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->rootp->SwUnit__DOT__alu_clear_busy == 0,
                   "Wrong alu clear busy signal {}!",
                   dut->rootp->SwUnit__DOT__alu_clear_busy);
        } else if (sim_time == 310) {
            dut->dp_req_alu_num_i = 1;
            // 发射第三条指令
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 9, 10,
                     0x80000008, 7, 1, 1);

            // 执行前递
            dut->exe_result_1_dst_i = 1;
            dut->exe_result_1_i = 11;
        } else if (sim_time == 320) {
            dut->dp_req_alu_num_i = 0;
            ASSERT(dut->exe_alu_ready_o == 7, "Wrong alu ready signal {}!",
                   dut->exe_alu_ready_o);
            ASSERT(dut->exe_alu_op_1_o == 7, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 11, "Wrong output alu op signal!");
        } else if (sim_time == 330) {
            ASSERT(dut->exe_alu_op_1_o == 8, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 11, "Wrong output alu op signal!");
        } else if (sim_time == 340) {
            ASSERT(dut->exe_alu_op_1_o == 9, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 10, "Wrong output alu op signal!");
        } else if (sim_time == 350) {
            dut->exe_result_1_dst_i = 0;
            dut->exe_result_1_i = 0;
        }
    }

    void full_inst_issue_test() {
        if (sim_time == 400) {
            dut->reset_i = 0;
            dut->stall_dp_i = 0;
            dut->kill_dp_i = 0;
            // 分配两个 entry
            dut->dp_req_alu_num_i = 2;
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 1, 1,
                     0x80000008, 1, 1, 1);
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 2, 2,
                     0x8000000C, 2, 1, 2);
            // fmt::println("Ready vector: {:#x}", dut->exe_alu_ready_o);
            // fmt::println("Busy vector: {:#x}",
            //              dut->rootp->SwUnit__DOT__alu_busy_vector);
            // fmt::println("Allocate entry: {}, {}",
            //              dut->rootp->SwUnit__DOT__free_alu_entry_1,
            //              dut->rootp->SwUnit__DOT__free_alu_entry_2);

        } else if (sim_time == 410) {
            dut->dp_req_alu_num_i = 2;
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 3, 3,
                     0x80000008, 3, 1, 1);
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 4, 4,
                     0x8000000C, 4, 1, 2);
            // fmt::println("Ready vector: {:#x}", dut->exe_alu_ready_o);
            // fmt::println("Busy vector: {:#x}",
            //              dut->rootp->SwUnit__DOT__alu_busy_vector);
            // fmt::println("Allocate entry: {}, {}",
            //              dut->rootp->SwUnit__DOT__free_alu_entry_1,
            //              dut->rootp->SwUnit__DOT__free_alu_entry_2);
        } else if (sim_time == 420) {
            dut->dp_req_alu_num_i = 2;
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 5, 5,
                     0x80000008, 5, 1, 1);
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 6, 6,
                     0x8000000C, 6, 1, 2);
            // fmt::println("Ready vector: {:#x}", dut->exe_alu_ready_o);
            // fmt::println("Busy vector: {:#x}",
            //              dut->rootp->SwUnit__DOT__alu_busy_vector);
            // fmt::println("Allocate entry: {}, {}",
            //              dut->rootp->SwUnit__DOT__free_alu_entry_1,
            //              dut->rootp->SwUnit__DOT__free_alu_entry_2);
        } else if (sim_time == 430) {
            dut->dp_req_alu_num_i = 2;
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 7, 7,
                     0x80000008, 7, 1, 1);
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 8, 8,
                     0x8000000C, 8, 1, 2);
            // fmt::println("Ready vector: {:#x}", dut->exe_alu_ready_o);
            // fmt::println("Busy vector: {:#x}",
            //              dut->rootp->SwUnit__DOT__alu_busy_vector);
            // fmt::println("Allocate entry: {}, {}",
            //              dut->rootp->SwUnit__DOT__free_alu_entry_1,
            //              dut->rootp->SwUnit__DOT__free_alu_entry_2);
        } else if (sim_time == 440) {
            dut->dp_req_alu_num_i = 2;
            ASSERT(dut->rootp->SwUnit__DOT__alu_allocatable == 0,
                   "Wrong allocate entry singal!");
            ASSERT(dut->rootp->SwUnit__DOT__alu_busy_vector == 0xFF,
                   "Wrong busy vector with {:#x}!",
                   dut->rootp->SwUnit__DOT__alu_busy_vector);
            // ASSERT(dut->rootp->SwUnit__DOT__alu_allocate_en_1 == 0,
            //        "Wrong allocate enable signal!");
            // ASSERT(dut->rootp->SwUnit__DOT__alu_allocate_en_2 == 0,
            //        "Wrong allocate enable signal!");
            ASSERT(dut->rootp->SwUnit__DOT__we_1 == 0, "Wrong we signal!");
            ASSERT(dut->rootp->SwUnit__DOT__we_2 == 0, "Wrong we signal!");

            // 发射所有指令
            dut->exe_result_1_dst_i = 1;
            dut->exe_result_1_i = 10;
            dut->exe_result_2_dst_i = 2;
            dut->exe_result_2_i = 20;
            dut->exe_result_3_dst_i = 3;
            dut->exe_result_3_i = 30;
            dut->exe_result_4_dst_i = 4;
            dut->exe_result_4_i = 40;

        } else if (sim_time == 450) {
            // fmt::println("Ready vector: {:#x}", dut->exe_alu_ready_o);
            // fmt::println("History vector: {:#x}",
            //              dut->rootp->SwUnit__DOT__alu_history_vector);
            dut->dp_req_alu_num_i = 0;
            dut->exe_result_1_dst_i = 5;
            dut->exe_result_1_i = 50;
            dut->exe_result_2_dst_i = 6;
            dut->exe_result_2_i = 60;
            dut->exe_result_3_dst_i = 7;
            dut->exe_result_3_i = 70;
            dut->exe_result_4_dst_i = 8;
            dut->exe_result_4_i = 80;

            // 验证发射
            // fmt::println("exe_alu_op_1_o: {}", dut->exe_alu_op_1_o);
            // fmt::println("exe_alu_op_2_o: {}", dut->exe_alu_op_2_o);
            // fmt::println("busy vector: {:#x}",
            //              dut->rootp->SwUnit__DOT__alu_busy_vector);
            ASSERT(dut->exe_alu_op_1_o == 1, "Wrong output alu op signal {} !",
                   dut->exe_alu_op_1_o);
            ASSERT(dut->exe_alu_op_2_o == 10, "Wrong output alu op signal!");
        } else if (sim_time == 460) {
            // fmt::println("exe_alu_op_1_o: {}", dut->exe_alu_op_1_o);
            // fmt::println("exe_alu_op_2_o: {}", dut->exe_alu_op_2_o);
            ASSERT(dut->exe_alu_op_1_o == 2, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 20, "Wrong output alu op signal!");
        } else if (sim_time == 470) {
            // fmt::println("exe_alu_op_1_o: {}", dut->exe_alu_op_1_o);
            // fmt::println("exe_alu_op_2_o: {}", dut->exe_alu_op_2_o);
            ASSERT(dut->exe_alu_op_1_o == 3, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 30, "Wrong output alu op signal!");
        } else if (sim_time == 480) {
            // fmt::println("exe_alu_op_1_o: {}", dut->exe_alu_op_1_o);
            // fmt::println("exe_alu_op_2_o: {}", dut->exe_alu_op_2_o);
            ASSERT(dut->exe_alu_op_1_o == 4, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 40, "Wrong output alu op signal!");
        } else if (sim_time == 490) {
            // fmt::println("exe_alu_op_1_o: {}", dut->exe_alu_op_1_o);
            // fmt::println("exe_alu_op_2_o: {}", dut->exe_alu_op_2_o);
            ASSERT(dut->exe_alu_op_1_o == 5, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 50, "Wrong output alu op signal!");
        } else if (sim_time == 500) {
            // fmt::println("exe_alu_op_1_o: {}", dut->exe_alu_op_1_o);
            // fmt::println("exe_alu_op_2_o: {}", dut->exe_alu_op_2_o);
            ASSERT(dut->exe_alu_op_1_o == 6, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 60, "Wrong output alu op signal!");
        } else if (sim_time == 510) {
            // fmt::println("exe_alu_op_1_o: {}", dut->exe_alu_op_1_o);
            // fmt::println("exe_alu_op_2_o: {}", dut->exe_alu_op_2_o);
            ASSERT(dut->exe_alu_op_1_o == 7, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 70, "Wrong output alu op signal!");
        } else if (sim_time == 520) {
            // fmt::println("exe_alu_op_1_o: {}", dut->exe_alu_op_1_o);
            // fmt::println("exe_alu_op_2_o: {}", dut->exe_alu_op_2_o);
            ASSERT(dut->exe_alu_op_1_o == 8, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 80, "Wrong output alu op signal!");
        }
    }

    void verify_dut() override {
        single_inst_issue_test();
        double_inst_issue_test();
        triple_inst_issue_test();
        oldest_inst_issue_test();
        full_inst_issue_test();
    }
};

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VSwUnitTb> tb = std::make_shared<VSwUnitTb>(5, 50, 1000);

    tb->run("swunit.vcd");
    fmt::print("Dut Correctness passed!\n");
}