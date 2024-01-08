#include "verilator_tb.hpp"
#include "VSwUnit.h"
#include "VSwUnit___024root.h"
#include "error_handler.hpp"
#include <iostream>

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

    void single_alu_inst_issue_input() {
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
        } else if (sim_time == 60) {
            // 在第二个周期，将输入信号修改为 0
            dut->dp_req_alu_num_i = 0;
        }
    }

    // 单指令发射测试
    void single_alu_inst_issue_test() {
        if (sim_time == 55) {
            // 检查分配 entry 编号
            ASSERT(dut->rootp->SwUnit__DOT__alu_allocate_en_1 == 1,
                   "Wrong allocate enable signal!");
            ASSERT(dut->rootp->SwUnit__DOT__free_alu_entry_1 == 1,
                   "Wrong allocate entry singal {}!",
                   dut->rootp->SwUnit__DOT__free_alu_entry_1);

            ASSERT(dut->dp_valid_1_1_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_1_2_i == 1,
                   "Wrong dispatch write valid signal!");

            ASSERT(dut->exe_alu_op_1_o == 1, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 2, "Wrong output alu op signal!");
            fmt::println("Single issue test passed!");
        }
    }

    void double_alu_inst_issue_input() {
        if (sim_time == 100) {
            dut->reset_i = 0;
            dut->stall_dp_i = 0;
            dut->kill_dp_i = 0;
            disable_next_rrf_cycle();
            // 分配两个 entry
            dut->dp_req_alu_num_i = 2;

            // 发射两条条指令
            // 第一条指令的 RRF Tag 为 5
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 3, 4,
                     0x80000000, 5, 1, 1);
            // 第二条指令的 RRF Tag 为 6
            dispatch(1, OperandType::VALUE, OperandType::VALUE, 5, 6,
                     0x80000004, 6, 1, 2);
        } else if (sim_time == 110) {
            // 在第二个周期，将输入信号修改为 0
            dut->dp_req_alu_num_i = 0;
        }
    }

    void double_alu_inst_issue_test() {
        if (sim_time == 105) {
            ASSERT(dut->dp_valid_1_1_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_1_2_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_2_1_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_2_2_i == 1,
                   "Wrong dispatch write valid signal!");

            // 第二周期发射第一条指令
            ASSERT(dut->rootp->exe_alu_ready_o == 3, "Wrong alu ready signal!");
            ASSERT(dut->exe_alu_op_1_o == 3, "Wrong output alu op1 signal {}!",
                   dut->exe_alu_op_1_o);
            ASSERT(dut->exe_alu_op_2_o == 4, "Wrong output alu op2 signal {}!",
                   dut->exe_alu_op_2_o);
        } else if (sim_time == 115) {
            ASSERT(dut->exe_alu_op_1_o == 5, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 6, "Wrong output alu op signal!");
            fmt::println("Double issue test passed!");
        }
    }

    void triple_alu_inst_issue_input() {
        if (sim_time == 200) {
            dut->reset_i = 0;
            dut->stall_dp_i = 0;
            dut->kill_dp_i = 0;
            disable_next_rrf_cycle();
            // 分配两个 entry
            dut->dp_req_alu_num_i = 2;

            // 发射两条条指令，两条指令的第二个操作数均为 RRFTag = 1
            // 第一条指令的 RRF Tag 为 5
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 7, 1,
                     0x80000008, 5, 1, 1);
            // 第二条指令的 RRF Tag 为 6
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 8, 1,
                     0x8000000C, 6, 1, 2);
        } else if (sim_time == 210) {
            dut->dp_req_alu_num_i = 1;
            // 发射第三条指令
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 9, 10,
                     0x80000008, 7, 1, 1);
        } else if (sim_time == 220) {
            dut->dp_req_alu_num_i = 0;
            // 执行前递
            dut->exe_result_1_dst_i = 1;
            dut->exe_result_1_i = 11;
        } else if (sim_time == 250) {
            dut->exe_result_1_dst_i = 0;
            dut->exe_result_1_i = 0;
        }
    }

    void triple_alu_inst_issue_test() {
        if (sim_time == 205) {
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
        } else if (sim_time == 215) {
            ASSERT(dut->exe_alu_ready_o == 4, "Wrong alu ready signal {}!",
                   dut->exe_alu_ready_o);
            ASSERT(dut->exe_alu_op_1_o == 9, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 10, "Wrong output alu op signal!");
        } else if (sim_time == 225) {
            ASSERT(dut->exe_alu_op_1_o == 7, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 11, "Wrong output alu op signal!");
        } else if (sim_time == 235) {
            ASSERT(dut->exe_alu_op_1_o == 8, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 11, "Wrong output alu op signal!");
            fmt::println("Triple issue test passed!");
        }
    }

    void oldest_alu_inst_issue_input() {
        if (sim_time == 300) {
            dut->reset_i = 0;
            dut->stall_dp_i = 0;
            dut->kill_dp_i = 0;
            disable_next_rrf_cycle();
            // 分配两个 entry
            dut->dp_req_alu_num_i = 2;

            // 发射两条指令，两条指令的第二个操作数均为 RRFTag = 1
            // 第一条指令的 RRF Tag 为 5
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 7, 1,
                     0x80000008, 5, 1, 1);
            // 第二条指令的 RRF Tag 为 6
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 8, 1,
                     0x8000000C, 6, 1, 2);
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
        } else if (sim_time == 350) {
            dut->exe_result_1_dst_i = 0;
            dut->exe_result_1_i = 0;
        }
    }

    void oldest_alu_inst_issue_test() {
        if (sim_time == 305) {
            // 输出分配的 entry
            // 检查分配 entry 编号
            // ASSERT(dut->rootp->SwUnit__DOT__alu_allocate_en_1 == 1,
            //        "Wrong allocate enable signal!");
            // ASSERT(dut->rootp->SwUnit__DOT__free_alu_entry_1 == 0,
            //        "Wrong allocate entry singal {}!",
            //        dut->rootp->SwUnit__DOT__free_alu_entry_1);
            // ASSERT(dut->rootp->SwUnit__DOT__alu_allocate_en_2 == 1,
            //        "Wrong allocate enable signal!");
            // ASSERT(dut->rootp->SwUnit__DOT__free_alu_entry_2 == 1,
            //        "Wrong allocate entry singal {}!",
            //        dut->rootp->SwUnit__DOT__free_alu_entry_2);
#ifdef DEBUG
            fmt::println("free_alu_entry_1: {:#x}",
                         dut->rootp->SwUnit__DOT__free_alu_entry_1);
            fmt::println("free_alu_entry_2: {:#x}",
                         dut->rootp->SwUnit__DOT__free_alu_entry_2);
#endif

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
        } else if (sim_time == 315) {
            ASSERT(dut->exe_alu_ready_o == 7, "Wrong alu ready signal {}!",
                   dut->exe_alu_ready_o);
            ASSERT(dut->exe_alu_op_1_o == 7, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 11, "Wrong output alu op signal!");
        } else if (sim_time == 325) {
            ASSERT(dut->exe_alu_op_1_o == 8, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 11, "Wrong output alu op signal!");
        } else if (sim_time == 335) {
            ASSERT(dut->exe_alu_op_1_o == 9, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 10, "Wrong output alu op signal!");
            fmt::println("Oldest issue test passed!");
        }
    }

    void full_alu_inst_issue_input() {
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
        } else if (sim_time == 410) {
            dut->dp_req_alu_num_i = 2;
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 3, 3,
                     0x80000008, 3, 1, 1);
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 4, 4,
                     0x8000000C, 4, 1, 2);
        } else if (sim_time == 420) {
            dut->dp_req_alu_num_i = 2;
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 5, 5,
                     0x80000008, 5, 1, 1);
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 6, 6,
                     0x8000000C, 6, 1, 2);
        } else if (sim_time == 430) {
            dut->dp_req_alu_num_i = 2;
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 7, 7,
                     0x80000008, 7, 1, 1);
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 8, 8,
                     0x8000000C, 8, 1, 2);
        } else if (sim_time == 440) {
            dut->dp_req_alu_num_i = 2;
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
            dut->dp_req_alu_num_i = 0;
            dut->exe_result_1_dst_i = 5;
            dut->exe_result_1_i = 50;
            dut->exe_result_2_dst_i = 6;
            dut->exe_result_2_i = 60;
            dut->exe_result_3_dst_i = 7;
            dut->exe_result_3_i = 70;
            dut->exe_result_4_dst_i = 8;
            dut->exe_result_4_i = 80;
        } else if (sim_time == 520) {
            dut->dp_req_alu_num_i = 0;
        }
    }

    void full_alu_inst_issue_test() {
        if (sim_time == 435) {
            ASSERT(dut->rootp->SwUnit__DOT__alu_allocatable == 0,
                   "Wrong allocate entry singal!");
            ASSERT(dut->rootp->SwUnit__DOT__alu_busy_vector == 0xFF,
                   "Wrong busy vector with {:#x}!",
                   dut->rootp->SwUnit__DOT__alu_busy_vector);
            // ASSERT(dut->rootp->SwUnit__DOT__we_1 == 0, "Wrong we signal!");
            // ASSERT(dut->rootp->SwUnit__DOT__we_2 == 0, "Wrong we signal!");
        } else if (sim_time == 445) {
            // 验证发射
            ASSERT(dut->exe_alu_op_1_o == 1, "Wrong output alu op signal {} !",
                   dut->exe_alu_op_1_o);
            ASSERT(dut->exe_alu_op_2_o == 10, "Wrong output alu op signal!");
        } else if (sim_time == 455) {
            ASSERT(dut->exe_alu_op_1_o == 2, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 20, "Wrong output alu op signal!");
        } else if (sim_time == 465) {
            ASSERT(dut->exe_alu_op_1_o == 3, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 30, "Wrong output alu op signal!");
        } else if (sim_time == 475) {
            ASSERT(dut->exe_alu_op_1_o == 4, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 40, "Wrong output alu op signal!");
        } else if (sim_time == 485) {
            ASSERT(dut->exe_alu_op_1_o == 5, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 50, "Wrong output alu op signal!");
        } else if (sim_time == 495) {
            ASSERT(dut->exe_alu_op_1_o == 6, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 60, "Wrong output alu op signal!");
        } else if (sim_time == 505) {
            ASSERT(dut->exe_alu_op_1_o == 7, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 70, "Wrong output alu op signal!");
        } else if (sim_time == 515) {
            ASSERT(dut->exe_alu_op_1_o == 8, "Wrong output alu op signal!");
            ASSERT(dut->exe_alu_op_2_o == 80, "Wrong output alu op signal!");
            fmt::println("Full issue test passed!");
        }
    }

    void single_mem_inst_issue_input() {
        if (sim_time == 600) {
            disable_next_rrf_cycle();
            dut->dp_req_mem_num_i = 1;
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 1, 2,
                     0x80000000, 0, 1, 1);
        } else if (sim_time == 610) {
            dut->dp_req_mem_num_i = 1;
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 3, 4,
                     0x80000004, 0, 1, 2);
        } else if (sim_time == 620) {
            dut->dp_req_mem_num_i = 0;
        }
    }

    void single_mem_inst_issue_test() {
        if (sim_time == 605) {
            ASSERT(dut->dp_valid_1_1_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->dp_valid_1_2_i == 1,
                   "Wrong dispatch write valid signal!");
            ASSERT(dut->rootp->SwUnit__DOT__mem_allocatable == 1,
                   "Wrong allocate enable signal!");
            ASSERT(dut->rootp->SwUnit__DOT__free_mem_entry_1 == 1,
                   "Wrong allocate entry singal {}!",
                   dut->rootp->SwUnit__DOT__free_mem_entry_1);
            ASSERT(dut->exe_mem_op_1_o == 1, "Wrong output mem op signal!");
            ASSERT(dut->exe_mem_op_2_o == 2, "Wrong output mem op signal!");
            ASSERT(dut->exe_mem_pc_o == 0x80000000,
                   "Wrong output mem pc signal!");
        } else if (sim_time == 615) {
            ASSERT(dut->exe_mem_op_1_o == 3, "Wrong output mem op signal!");
            ASSERT(dut->exe_mem_op_2_o == 4, "Wrong output mem op signal!");
            ASSERT(dut->exe_mem_pc_o == 0x80000004,
                   "Wrong output mem pc signal!");
            fmt::println("Single Load/Store issue test passed!");
        }
    }

    void double_mem_inst_issue_input() {
        if (sim_time == 700) {
            disable_next_rrf_cycle();
            dut->dp_req_mem_num_i = 2;
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 5, 6,
                     0x80000000, 0, 1, 1);
            dispatch(1, OperandType::VALUE, OperandType::VALUE, 7, 8,
                     0x80000004, 0, 1, 2);
        } else if (sim_time == 710) {
            // dut->dp_req_mem_num_i = 2;
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 9, 10,
                     0x80000008, 0, 1, 1);
            dispatch(1, OperandType::VALUE, OperandType::VALUE, 11, 12,
                     0x8000000C, 0, 1, 2);
        } else if (sim_time == 720) {
            dut->dp_req_mem_num_i = 0;
        }
    }

    void double_mem_inst_issue_test() {
        if (sim_time == 705) {
#ifdef DEBUG
            fmt::println(
                "[Load/Store::double_mem_inst_issue_test], time: {}, issue "
                "entry: {}",
                sim_time, dut->rootp->SwUnit__DOT__mem_issue_entry);
#endif
            ASSERT(dut->exe_mem_op_1_o == 5, "Wrong output mem op signal!");
            ASSERT(dut->exe_mem_op_2_o == 6, "Wrong output mem op signal!");
        } else if (sim_time == 715) {
#ifdef DEBUG
            fmt::println(
                "[Load/Store::double_mem_inst_issue_test], time: {}, issue "
                "entry: {}",
                sim_time, dut->rootp->SwUnit__DOT__mem_issue_entry);
#endif
            ASSERT(dut->exe_mem_op_1_o == 7, "Wrong output mem op signal!");
            ASSERT(dut->exe_mem_op_2_o == 8, "Wrong output mem op signal!");
        } else if (sim_time == 725) {
#ifdef DEBUG
            fmt::println(
                "[Load/Store::double_mem_inst_issue_test], time: {}, issue "
                "entry: {}",
                sim_time, dut->rootp->SwUnit__DOT__mem_issue_entry);
#endif
            ASSERT(dut->exe_mem_op_1_o == 9, "Wrong output mem op signal!");
            ASSERT(dut->exe_mem_op_2_o == 10, "Wrong output mem op signal!");
        } else if (sim_time == 735) {
#ifdef DEBUG
            fmt::println(
                "[Load/Store::double_mem_inst_issue_test], time: {}, issue "
                "entry: {}",
                sim_time, dut->rootp->SwUnit__DOT__mem_issue_entry);
#endif
            ASSERT(dut->exe_mem_op_1_o == 11, "Wrong output mem op signal!");
            ASSERT(dut->exe_mem_op_2_o == 12, "Wrong output mem op signal!");
            fmt::println("Double Load/Store issue test passed!");
        }
    }

    void single_mem_inst_block_issue_input() {
        if (sim_time == 800) {
            disable_next_rrf_cycle();
            dut->dp_req_mem_num_i = 1;
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 13, 1,
                     0x80000000, 0, 1, 1);
        } else if (sim_time == 810) {
            dut->dp_req_mem_num_i = 1;
            dispatch(0, OperandType::VALUE, OperandType::VALUE, 15, 16,
                     0x80000004, 0, 1, 2);
            dut->exe_result_1_dst_i = 1;
            dut->exe_result_1_i = 14;
        } else if (sim_time == 820) {
            dut->dp_req_mem_num_i = 0;
            dut->exe_result_1_dst_i = 0;
            dut->exe_result_1_i = 0;
        }
    }

    void single_mem_inst_block_issue_test() {
        if (sim_time == 805) {
            ASSERT(dut->exe_mem_issue_o == 0, "Wrong output mem ready signal!");
        } else if (sim_time == 815) {
#ifdef DEBUG
            // Print Issue Entry
            fmt::println(
                "[Load/Store::single_mem_inst_block_issue_test], time: {}, "
                "issue entry: {}",
                sim_time, dut->rootp->SwUnit__DOT__mem_issue_entry);
#endif
            ASSERT(dut->exe_mem_op_1_o == 13,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 13,
                   dut->exe_mem_op_1_o);
            ASSERT(dut->exe_mem_op_2_o == 14,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 14,
                   dut->exe_mem_op_2_o);
        } else if (sim_time == 825) {
#ifdef DEBUG
            // Print Issue Entry
            fmt::println(
                "[Load/Store::single_mem_inst_block_issue_test], time: {}, "
                "issue entry: {}",
                sim_time, dut->rootp->SwUnit__DOT__mem_issue_entry);
#endif
            ASSERT(dut->exe_mem_op_1_o == 15,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 15,
                   dut->exe_mem_op_1_o);
            ASSERT(dut->exe_mem_op_2_o == 16,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 16,
                   dut->exe_mem_op_2_o);
            fmt::println("Single Load/Store Block issue test passed!");
        }
    }

    void double_mem_inst_block_issue_input() {
        if (sim_time == 900) {
            disable_next_rrf_cycle();
            dut->dp_req_mem_num_i = 2;
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 17, 1,
                     0x80000000, 0, 1, 1);
            dispatch(1, OperandType::VALUE, OperandType::VALUE, 19, 20,
                     0x80000004, 0, 1, 2);
        } else if (sim_time == 910) {
            dut->dp_req_mem_num_i = 0;
        } else if (sim_time == 920) {
            dut->exe_result_1_dst_i = 1;
            dut->exe_result_1_i = 18;
        } else if (sim_time == 940) {
            dut->exe_result_1_dst_i = 0;
            dut->exe_result_1_i = 0;
        }
    }

    void double_mem_inst_block_issue_test() {
        if (sim_time == 905) {
            ASSERT(dut->exe_mem_issue_o == 0, "Wrong output mem issue signal!");
        } else if (sim_time == 915) {
            ASSERT(dut->exe_mem_issue_o == 0, "Wrong output mem issue signal!");
        } else if (sim_time == 925) {
#ifdef DEBUG
            // Print Issue Entry
            fmt::println(
                "[Load/Store::double_mem_inst_block_issue_test], time: {}, "
                "issue entry: {}",
                sim_time, dut->rootp->SwUnit__DOT__mem_issue_entry);
#endif
            ASSERT(dut->exe_mem_issue_o == 1, "Wrong output mem issue signal!");
            ASSERT(dut->exe_mem_op_1_o == 17,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 17,
                   dut->exe_mem_op_1_o);
            ASSERT(dut->exe_mem_op_2_o == 18,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 18,
                   dut->exe_mem_op_2_o);
        } else if (sim_time == 935) {
#ifdef DEBUG
            // Print Issue Entry
            fmt::println(
                "[Load/Store::double_mem_inst_block_issue_test], time: {}, "
                "issue entry: {}",
                sim_time, dut->rootp->SwUnit__DOT__mem_issue_entry);
#endif
            ASSERT(dut->exe_mem_issue_o == 1, "Wrong output mem issue signal!");
            ASSERT(dut->exe_mem_op_1_o == 19,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 17,
                   dut->exe_mem_op_1_o);
            ASSERT(dut->exe_mem_op_2_o == 20,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 18,
                   dut->exe_mem_op_2_o);
            fmt::println("Double Load/Store Block issue test passed!");
        }
    }

    void full_mem_inst_issue_input() {
        if (sim_time == 1000) {
            disable_next_rrf_cycle();
#ifdef DEBUG
            // Print begin_0, end_0, begin_1, end_1
            fmt::println(
                "[Load/Store::full_mem_inst_issue_input], time: {}, begin_0: "
                "{:#x}, end_0: {:#x}, begin_1: {:#x}, end_1: {:#x}, not_full: "
                "{}",
                sim_time,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__begin_0,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__end_0,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__begin_1,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__end_1,
                dut->rootp
                    ->SwUnit__DOT__inorder_alloc_issue_unit__DOT__not_full);
            // Print busy vector
            fmt::println(
                "[Load/Store::full_mem_inst_issue_input], time: {}, busy "
                "vector: {:#x}",
                sim_time, dut->rootp->SwUnit__DOT__mem_busy_vector);
#endif
            dut->dp_req_mem_num_i = 2;
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 21, 1,
                     0x80000000, 0, 1, 1);
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 23, 2,
                     0x80000004, 0, 1, 2);
        } else if (sim_time == 1010) {
#ifdef DEBUG
            // Print begin_0, end_0, begin_1, end_1
            fmt::println(
                "[Load/Store::full_mem_inst_issue_input], time: {}, begin_0: "
                "{:#x}, end_0: {:#x}, begin_1: {:#x}, end_1: {:#x}, not_full: "
                "{}",
                sim_time,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__begin_0,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__end_0,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__begin_1,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__end_1,
                dut->rootp
                    ->SwUnit__DOT__inorder_alloc_issue_unit__DOT__not_full);
            // Print busy vector
            fmt::println(
                "[Load/Store::full_mem_inst_issue_input], time: {}, busy "
                "vector: {:#x}",
                sim_time, dut->rootp->SwUnit__DOT__mem_busy_vector);
#endif
            dut->dp_req_mem_num_i = 2;
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 25, 3,
                     0x80000008, 0, 1, 1);
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 27, 4,
                     0x8000000C, 0, 1, 2);
        } else if (sim_time == 1020) {
            dut->dp_req_mem_num_i = 2;
            dispatch(0, OperandType::VALUE, OperandType::RRFTAG, 29, 5,
                     0x80000010, 0, 1, 1);
            dispatch(1, OperandType::VALUE, OperandType::RRFTAG, 31, 6,
                     0x80000014, 0, 1, 2);
        } else if (sim_time == 1030) {
            dut->dp_req_mem_num_i = 0;
            dut->exe_result_1_dst_i = 1;
            dut->exe_result_1_i = 22;
            dut->exe_result_2_dst_i = 2;
            dut->exe_result_2_i = 24;
            dut->exe_result_3_dst_i = 3;
            dut->exe_result_3_i = 26;
            dut->exe_result_4_dst_i = 4;
            dut->exe_result_4_i = 28;
        }
    }

    void full_mem_inst_issue_test() {
        if (sim_time == 1005) {
#ifdef DEBUG
            // Print Allocate Entry
            fmt::println(
                "[Load/Store::full_mem_inst_issue_test], time: {}, allocate "
                "entry_1: {:#x}, allocate entry_2: {:#x}",
                sim_time, dut->rootp->SwUnit__DOT__free_mem_entry_1,
                dut->rootp->SwUnit__DOT__free_mem_entry_2);
            // Print Issue Entry
            fmt::println(
                "[Load/Store::full_mem_inst_issue_test], time: {}, issue "
                "entry: {}",
                sim_time, dut->rootp->SwUnit__DOT__mem_issue_entry);
            // Print begin_0, end_0, begin_1, end_1
            fmt::println(
                "[Load/Store::full_mem_inst_issue_test], time: {}, begin_0: "
                "{:#x}, end_0: {:#x}, begin_1: {:#x}, end_1: {:#x}, not_full: "
                "{}",
                sim_time,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__begin_0,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__end_0,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__begin_1,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__end_1,
                dut->rootp
                    ->SwUnit__DOT__inorder_alloc_issue_unit__DOT__not_full);
            // Print busy vector
            fmt::println(
                "[Load/Store::full_mem_inst_issue_test], time: {}, busy "
                "vector: {:#x}",
                sim_time, dut->rootp->SwUnit__DOT__mem_busy_vector);
#endif
            ASSERT(dut->exe_mem_issue_o == 0, "Wrong output mem issue signal!");
            ASSERT(dut->rootp->SwUnit__DOT__mem_allocatable == 1,
                   "Wrong allocate enable signal!");
        } else if (sim_time == 1015) {
#ifdef DEBUG
            // Print Allocate Entry
            fmt::println(
                "[Load/Store::full_mem_inst_issue_test], time: {}, allocate "
                "entry_1: {:#x}, allocate entry_2: {:#x}",
                sim_time, dut->rootp->SwUnit__DOT__free_mem_entry_1,
                dut->rootp->SwUnit__DOT__free_mem_entry_2);
            // Print Issue Entry
            fmt::println(
                "[Load/Store::full_mem_inst_issue_test], time: {}, issue "
                "entry: {}",
                sim_time, dut->rootp->SwUnit__DOT__mem_issue_entry);
            // Print begin_0, end_0, begin_1, end_1
            fmt::println(
                "[Load/Store::full_mem_inst_issue_test], time: {}, begin_0: "
                "{:#x}, end_0: {:#x}, begin_1: {:#x}, end_1: {:#x}, not_full: "
                "{}",
                sim_time,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__begin_0,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__end_0,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__begin_1,
                dut->rootp->SwUnit__DOT__inorder_alloc_issue_unit__DOT__end_1,
                dut->rootp
                    ->SwUnit__DOT__inorder_alloc_issue_unit__DOT__not_full);
            // Print busy vector
            fmt::println(
                "[Load/Store::full_mem_inst_issue_test], time: {}, busy "
                "vector: {:#x}",
                sim_time, dut->rootp->SwUnit__DOT__mem_busy_vector);
#endif
            ASSERT(dut->exe_mem_issue_o == 0, "Wrong output mem issue signal!");
        } else if (sim_time == 1025) {
            ASSERT(dut->exe_mem_issue_o == 0, "Wrong output mem issue signal!");
            // allocatenable
            ASSERT(dut->rootp->SwUnit__DOT__mem_allocatable == 0,
                   "Wrong allocate enable signal!");
        } else if (sim_time == 1035) {
            ASSERT(dut->exe_mem_issue_o == 1, "Wrong output mem issue signal!");
            ASSERT(dut->exe_mem_op_1_o == 21,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 21,
                   dut->exe_mem_op_1_o);
            ASSERT(dut->exe_mem_op_2_o == 22,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 22,
                   dut->exe_mem_op_2_o);
        } else if (sim_time == 1045) {
            ASSERT(dut->exe_mem_issue_o == 1, "Wrong output mem issue signal!");
            ASSERT(dut->exe_mem_op_1_o == 23,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 23,
                   dut->exe_mem_op_1_o);
            ASSERT(dut->exe_mem_op_2_o == 24,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 24,
                   dut->exe_mem_op_2_o);
        } else if (sim_time == 1055) {
            ASSERT(dut->exe_mem_issue_o == 1, "Wrong output mem issue signal!");
            ASSERT(dut->exe_mem_op_1_o == 25,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 25,
                   dut->exe_mem_op_1_o);
            ASSERT(dut->exe_mem_op_2_o == 26,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 26,
                   dut->exe_mem_op_2_o);
        } else if (sim_time == 1065) {
            ASSERT(dut->exe_mem_issue_o == 1, "Wrong output mem issue signal!");
            ASSERT(dut->exe_mem_op_1_o == 27,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 27,
                   dut->exe_mem_op_1_o);
            ASSERT(dut->exe_mem_op_2_o == 28,
                   "Wrong output mem op signal, Expected: {}, Actual: {}!", 28,
                   dut->exe_mem_op_2_o);
            fmt::println("Full Load/Store issue test passed!");
        }
    }

    void initialize_signal() override {
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

    void input() override {
        single_alu_inst_issue_input();
        double_alu_inst_issue_input();
        triple_alu_inst_issue_input();
        oldest_alu_inst_issue_input();
        full_alu_inst_issue_input();

        // Load/Store
        single_mem_inst_issue_input();
        double_mem_inst_issue_input();
        single_mem_inst_block_issue_input();
        double_mem_inst_block_issue_input();
        full_mem_inst_issue_input();
    }

    void verify_dut() override {
        single_alu_inst_issue_test();
        double_alu_inst_issue_test();
        triple_alu_inst_issue_test();
        oldest_alu_inst_issue_test();
        full_alu_inst_issue_test();

        // Load/Store
        single_mem_inst_issue_test();
        double_mem_inst_issue_test();
        single_mem_inst_block_issue_test();
        double_mem_inst_block_issue_test();
        full_mem_inst_issue_test();
    }
};

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VSwUnitTb> tb = std::make_shared<VSwUnitTb>(5, 50, 1500);

    tb->run("swunit.vcd");
    fmt::print("Dut Correctness passed!\n");
}