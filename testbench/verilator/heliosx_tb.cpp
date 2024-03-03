#include <sys/types.h>
#include <cstdint>
#include "error_handler.hpp"
#include "fmt/core.h"
#include "verilator_tb.hpp"
#include "mem_sim.hpp"
#include "consts.hpp"
#include "VHeliosX.h"
#include "VHeliosX___024root.h"

class VHeliosXTb : public VerilatorTb<VHeliosX> {
   public:
    VHeliosXTb(uint64_t clock, uint64_t start_time, uint64_t end_time,
               std::shared_ptr<Memory> mem)
        : VerilatorTb<VHeliosX>(clock, start_time, end_time), mem(mem) {}

    uint64_t gen_arf_rrftag(uint32_t arf_rrftag0, uint32_t arf_rrftag1,
                            uint32_t arf_rrftag2, uint32_t arf_rrftag3,
                            uint32_t arf_rrftag4, uint32_t arf_rrftag5,
                            uint32_t regidx) {
        /* fmt::println("\n\narf_rrftag5: {:#x}", arf_rrftag5); */
        /* fmt::println("arf_rrftag4: {:#x}", arf_rrftag4); */
        /* fmt::println("arf_rrftag3: {:#x}", arf_rrftag3); */
        /* fmt::println("arf_rrftag2: {:#x}", arf_rrftag2); */
        /* fmt::println("arf_rrftag1: {:#x}", arf_rrftag1); */
        /* fmt::println("arf_rrftag0: {:#x}", arf_rrftag0); */
        uint32_t mask = 0x1 << regidx;
        uint32_t rrftag5_mask = (((arf_rrftag5 & mask) >> regidx) << 5);
        uint32_t rrftag4_mask = (((arf_rrftag4 & mask) >> regidx) << 4);
        uint32_t rrftag3_mask = (((arf_rrftag3 & mask) >> regidx) << 3);
        uint32_t rrftag2_mask = (((arf_rrftag2 & mask) >> regidx) << 2);
        uint32_t rrftag1_mask = (((arf_rrftag1 & mask) >> regidx) << 1);
        uint32_t rrftag0_mask = (((arf_rrftag0 & mask) >> regidx) << 0);
        return rrftag5_mask | rrftag4_mask | rrftag3_mask | rrftag2_mask |
               rrftag1_mask | rrftag0_mask;
    }

    uint64_t get_rrf_rrfdata(uint64_t rrftag) {
        return dut->rootp
            ->HeliosX__DOT__u_ReNameUnit__DOT__rrf__DOT__rrf_data[rrftag];
    }

    uint64_t get_rrf_rrfvalid(uint64_t rrftag) {
        vluint64_t rrfvalid =
            dut->rootp->HeliosX__DOT__u_ReNameUnit__DOT__rrf__DOT__rrf_valid;
        vluint64_t mask = 0x1l << rrftag;
        return (rrfvalid & mask) >> rrftag;
    }

    uint64_t get_arf_rrftag(uint32_t regidx) {
        uint64_t rrftag = gen_arf_rrftag(
            dut->rootp
                ->HeliosX__DOT__u_ReNameUnit__DOT__arf__DOT__re_tb__DOT__arf_rrftag0,
            dut->rootp
                ->HeliosX__DOT__u_ReNameUnit__DOT__arf__DOT__re_tb__DOT__arf_rrftag1,
            dut->rootp
                ->HeliosX__DOT__u_ReNameUnit__DOT__arf__DOT__re_tb__DOT__arf_rrftag2,
            dut->rootp
                ->HeliosX__DOT__u_ReNameUnit__DOT__arf__DOT__re_tb__DOT__arf_rrftag3,
            dut->rootp
                ->HeliosX__DOT__u_ReNameUnit__DOT__arf__DOT__re_tb__DOT__arf_rrftag4,
            dut->rootp
                ->HeliosX__DOT__u_ReNameUnit__DOT__arf__DOT__re_tb__DOT__arf_rrftag5,
            regidx);
#ifdef DEBUG
        fmt::println("reg:{} 的regidx:{}\n分配的rrftag是:{}\n\n",
                     reg_idx2str(regidx), regidx, rrftag);
#endif  // DEBUG

        return rrftag;
    }

    // 获取指定寄存器的arf_busy位
    uint32_t get_arf_busy(uint32_t regidx) {
        uint32_t mask = 0x1 << regidx;

        return (dut->rootp
                    ->HeliosX__DOT__u_ReNameUnit__DOT__arf__DOT__re_tb__DOT__arf_busy &
                mask) >>
               regidx;
    }

    // 获取arf_data的内容
    uint32_t get_arf_data(uint32_t regidx) {
        uint32_t data =
            dut->rootp
                ->HeliosX__DOT__u_ReNameUnit__DOT__arf__DOT__ARFData__DOT__mem0__DOT__mem
                    [regidx];
#ifdef DEBUG
        fmt::println("regidx:{}\treg_data:{:#x}\n", regidx, data);
#endif  // DEBUG
        return data;
    }

    void fetch_test() {
        if (sim_time == 115) {
            ASSERT(dut->rootp->HeliosX__DOT__inst == 0x00000413,
                   "sim_time: {} Error inst_1 {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__inst);
        } else if (sim_time == 125) {
            ASSERT(dut->rootp->HeliosX__DOT__inst == 0x74300613,
                   "sim_time: {} Error inst_1 {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__inst);
        } else if (sim_time == 135) {
            ASSERT(dut->rootp->HeliosX__DOT__inst == 0x00860433,
                   "sim_time: {} Error inst_1 {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__inst);
        }
    }

    void decode_test() {
        if (sim_time == 125) {
            // sim_time 110: 00000413
            //// li s0, 0
            /// addi s0,zero,0
            ASSERT(dut->rootp->HeliosX__DOT__imm_1_dp == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__imm_1_dp);

            ASSERT(dut->rootp->HeliosX__DOT__imm_type_1_dp == IMM_I,
                   "sim_time: {} Error Imm Type {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__imm_type_1_dp);

            ASSERT(dut->rootp->HeliosX__DOT__uses_rs1_1_dp == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__uses_rs1_1_dp);

            ASSERT(dut->rootp->HeliosX__DOT__rs1_1_dp == get_regidx("$0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__uses_rs1_1_dp);

            ASSERT(dut->rootp->HeliosX__DOT__uses_rs2_1_dp == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__uses_rs2_1_dp);

        } else if (sim_time == 135) {
            // sim_time 120: 74300613
            // addi a2,zero, 1859
            ASSERT(dut->rootp->HeliosX__DOT__imm_1_dp == 1859,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__imm_1_dp);

            ASSERT(dut->rootp->HeliosX__DOT__imm_type_1_dp == IMM_I,
                   "sim_time: {} Error Imm Type {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__imm_type_1_dp);

            ASSERT(dut->rootp->HeliosX__DOT__uses_rs1_1_dp == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__uses_rs1_1_dp);

            ASSERT(dut->rootp->HeliosX__DOT__rs1_1_dp == get_regidx("$0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rs1_1_dp);

            ASSERT(dut->rootp->HeliosX__DOT__uses_rs2_1_dp == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__uses_rs2_1_dp);

        } else if (sim_time == 145) {
            // sim_time 130: 00860433
            // add s0, a2, s0
            ASSERT(dut->rootp->HeliosX__DOT__alu_op_1_dp == ALU_OP_ADD,
                   "sim_time: {} Error alu_op_1 {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_op_1_dp);

            ASSERT(dut->rootp->HeliosX__DOT__uses_rs1_1_dp == 1,
                   "sim_time: {} Error alu_op_1 {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__uses_rs1_1_dp);

            ASSERT(dut->rootp->HeliosX__DOT__rs1_1_dp == get_regidx("a2"),
                   "sim_time: {} Error alu_op_1 {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rs1_1_dp);

            ASSERT(dut->rootp->HeliosX__DOT__uses_rs2_1_dp == 1,
                   "sim_time: {} Error alu_op_1 {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__uses_rs2_1_dp);

            ASSERT(dut->rootp->HeliosX__DOT__rs2_1_dp == get_regidx("s0"),
                   "sim_time: {} Error alu_op_1 {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rs2_1_dp);
        }
    }

    void dispatch_test() {
        if (sim_time == 135) {
            // sim_time 110: 00000413
            //// li s0, 0
            /// addi s0,zero,0
            ASSERT(dut->rootp->HeliosX__DOT__rs1_sw == get_regidx("$0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rs1_sw);

            ASSERT(dut->rootp->HeliosX__DOT__pc_sw == 0x80000000,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__pc_sw);

            ASSERT(dut->rootp->HeliosX__DOT__rrf_allocatable == 0x1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            // 下面这个信号，应当是要传给ROB的
            ASSERT(
                dut->rootp
                        ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o ==
                    62,
                "sim_time: {} Error Imm Type {:#x}", sim_time,
                dut->rootp
                    ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o);

            ASSERT(
                dut->rootp->HeliosX__DOT__rrfptr_RrfEntryAllocate_out_rob_in ==
                    2,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rrfptr_RrfEntryAllocate_out_rob_in);

            ASSERT(dut->rootp->HeliosX__DOT__nextrrfcyc == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__nextrrfcyc);

            ASSERT(dut->rootp->HeliosX__DOT__dst_rrftag == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_rrftag);

            ASSERT(dut->rootp->HeliosX__DOT__dst_en == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_en);

            ASSERT(dut->rootp->HeliosX__DOT__rd_1_sw == get_regidx("s0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rd_1_sw);

            ASSERT(dut->rootp->HeliosX__DOT__wr_reg_1_sw == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__wr_reg_1_sw);

            ASSERT(
                dut->rootp->HeliosX__DOT__src1_srcopmanager_out_srcmanager_in ==
                    0,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__src1_srcopmanager_out_srcmanager_in);

            ASSERT(
                dut->rootp->HeliosX__DOT__rdy1_srcopmanager_out_srcmanager_in ==
                    1,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rdy1_srcopmanager_out_srcmanager_in);

            ASSERT(
                dut->rootp->HeliosX__DOT__rdy2_srcopmanager_out_srcmanager_in ==
                    1,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rdy2_srcopmanager_out_srcmanager_in);

            ASSERT(get_arf_rrftag(get_regidx("s0")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_rrftag(get_regidx("s0")));

            ASSERT(get_arf_busy(get_regidx("s0")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("s0")));

            ASSERT(dut->rootp->HeliosX__DOT__req1_alu == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__req1_alu);

            ASSERT(
                dut->rootp
                        ->HeliosX__DOT__req_alunum_RSRequestGen_out_SWUnit_in ==
                    1,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp
                    ->HeliosX__DOT__req_alunum_RSRequestGen_out_SWUnit_in);

            ASSERT(dut->rootp->HeliosX__DOT__imm_1_sw == 0,
                   "_dpsim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__imm_1_sw);

        } else if (sim_time == 145) {
            // sim_time 120: 74300613
            // li a2, 1859
            ASSERT(dut->rootp->HeliosX__DOT__rs1_sw == get_regidx("$0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rs1_sw);

            ASSERT(dut->rootp->HeliosX__DOT__pc_sw == 0x80000004,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__pc_sw);

            ASSERT(dut->rootp->HeliosX__DOT__rrf_allocatable == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            // 下面这个信号，应当是要传给ROB的
            ASSERT(
                dut->rootp
                        ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o ==
                    61,
                "sim_time: {} Error Imm Type {:#x}", sim_time,
                dut->rootp
                    ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o);

            ASSERT(
                dut->rootp->HeliosX__DOT__rrfptr_RrfEntryAllocate_out_rob_in ==
                    3,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rrfptr_RrfEntryAllocate_out_rob_in);

            ASSERT(dut->rootp->HeliosX__DOT__nextrrfcyc == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__nextrrfcyc);

            ASSERT(dut->rootp->HeliosX__DOT__dst_rrftag == 2,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_rrftag);

            ASSERT(dut->rootp->HeliosX__DOT__dst_en == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_en);

            ASSERT(dut->rootp->HeliosX__DOT__rd_1_sw == get_regidx("a2"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rd_1_sw);

            ASSERT(dut->rootp->HeliosX__DOT__wr_reg_1_sw == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__wr_reg_1_sw);

            ASSERT(
                dut->rootp->HeliosX__DOT__src1_srcopmanager_out_srcmanager_in ==
                    0,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__src1_srcopmanager_out_srcmanager_in);

            ASSERT(
                dut->rootp->HeliosX__DOT__rdy1_srcopmanager_out_srcmanager_in ==
                    1,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rdy1_srcopmanager_out_srcmanager_in);

            ASSERT(
                dut->rootp->HeliosX__DOT__src2_srcopmanager_out_srcmanager_in ==
                    get_arf_data(dut->rootp->HeliosX__DOT__rs2_sw),
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__src2_srcopmanager_out_srcmanager_in);

            ASSERT(
                dut->rootp->HeliosX__DOT__rdy2_srcopmanager_out_srcmanager_in ==
                    1,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rdy2_srcopmanager_out_srcmanager_in);

            ASSERT(get_arf_rrftag(get_regidx("a2")) == 2,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_rrftag(get_regidx("a2")));

            ASSERT(get_arf_busy(get_regidx("a2")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("a2")));

            ASSERT(dut->rootp->HeliosX__DOT__req1_alu == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__req1_alu);

            ASSERT(
                dut->rootp
                        ->HeliosX__DOT__req_alunum_RSRequestGen_out_SWUnit_in ==
                    1,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp
                    ->HeliosX__DOT__req_alunum_RSRequestGen_out_SWUnit_in);

            ASSERT(dut->rootp->HeliosX__DOT__imm_1_sw == 1859,
                   "_dpsim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__imm_1_sw);

        } else if (sim_time == 155) {
            // 第一条指令在150的时候执行完毕，这时DP模块应该可以收到执行部件前递来的结果
            // 前递结果将在160的时候写入rrf.data中。
            // 由于rrf中设计了旁路，所以在160的时候，就可以获取到第一条指令前递过来的结果了。
            // 验证执行部件的前递结果
            // 这时候前递结果还没写入
            ASSERT(get_rrf_rrfvalid(1) == 0, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(1));

            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_we == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_we);

            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_tag == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);

            ASSERT(dut->rootp->HeliosX__DOT__alu_result == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);

            // sim_time 130: 00860433
            // add s0, a2, s0
            ASSERT(dut->rootp->HeliosX__DOT__rs1_sw == get_regidx("a2"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rs1_sw);

            ASSERT(dut->rootp->HeliosX__DOT__rs2_sw == get_regidx("s0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rs2_sw);

            ASSERT(dut->rootp->HeliosX__DOT__pc_sw == 0x80000008,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__pc_sw);

            ASSERT(dut->rootp->HeliosX__DOT__rrf_allocatable == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            // 150的时候第一条指令不应该提交
            ASSERT(get_arf_busy(get_regidx("s0")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("s0")));

            ASSERT(
                dut->rootp
                        ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o ==
                    60,
                "sim_time: {} Error Imm Type {:#x}", sim_time,
                dut->rootp
                    ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o);

            ASSERT(
                dut->rootp->HeliosX__DOT__rrfptr_RrfEntryAllocate_out_rob_in ==
                    4,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rrfptr_RrfEntryAllocate_out_rob_in);

            ASSERT(dut->rootp->HeliosX__DOT__nextrrfcyc == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__nextrrfcyc);

            ASSERT(dut->rootp->HeliosX__DOT__dst_rrftag == 3,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            ASSERT(dut->rootp->HeliosX__DOT__dst_en == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            ASSERT(dut->rootp->HeliosX__DOT__rd_1_sw == get_regidx("s0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rd_1_sw);

            ASSERT(dut->rootp->HeliosX__DOT__wr_reg_1_sw == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__wr_reg_1_sw);

            // 为a2分配的rrftag,应该是1
            ASSERT(
                dut->rootp->HeliosX__DOT__src1_srcopmanager_out_srcmanager_in ==
                    2,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__src1_srcopmanager_out_srcmanager_in);

            // 此时还没有写回，所以rdy应该是0
            ASSERT(
                dut->rootp->HeliosX__DOT__rdy1_srcopmanager_out_srcmanager_in ==
                    0,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rdy1_srcopmanager_out_srcmanager_in);

            // TODO:
            // 正常情况下，下面这个s0的rrftag确实应该是0,但是如前面提到的，ROB的时序不对，导致此时arf_busy是0,进而导致此时送给srcmanager的是arf_data,而不是arf_rrftag
            // 可以断言一下试试，此刻，src2应该就是arf_data
            // 确实是这样，下面这个断言是对的。
            // 所以src==0这个断言就先注释掉
            //
            // ROB的时序好像又对了。难蹦。下面这个assert先注释掉
            // ASSERT(
            //     dut->rootp->HeliosX__DOT__src2_srcopmanager_out_srcmanager_in
            //     ==
            //         get_arf_data(get_regidx("s0")),
            //     "sim_time: {} Error Imm {:#x}", sim_time,
            //     dut->rootp->HeliosX__DOT__src2_srcopmanager_out_srcmanager_in);

            // 感觉srcopmanager这个模块对于第一条和第三条指令这种
            // 两个目的寄存器重合的情况没有很好的处理
            // 为s0分配的rrftag,应当是0
            ASSERT(
                dut->rootp->HeliosX__DOT__src2_srcopmanager_out_srcmanager_in ==
                    1,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__src2_srcopmanager_out_srcmanager_in);

            // 此时还没有写回，所以rdy应该是0
            ASSERT(
                dut->rootp->HeliosX__DOT__rdy2_srcopmanager_out_srcmanager_in ==
                    0,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rdy2_srcopmanager_out_srcmanager_in);

            ASSERT(dut->rootp->HeliosX__DOT__req1_alu == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__req1_alu);

            ASSERT(
                dut->rootp
                        ->HeliosX__DOT__req_alunum_RSRequestGen_out_SWUnit_in ==
                    1,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp
                    ->HeliosX__DOT__req_alunum_RSRequestGen_out_SWUnit_in);

            ASSERT(get_arf_rrftag(get_regidx("s0")) == 3,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_rrftag(get_regidx("s0")));
        } else if (sim_time == 165) {
            // TODO:验证第一条指令执行阶段前递来的内容是否正确写入
            // rrftag=1时值是否正确
            ASSERT(get_rrf_rrfdata(1) == 0, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfdata(1));

            ASSERT(get_rrf_rrfvalid(1) == 1, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(1));

            // 160的时候第一条指令已经提交完毕了，dp可以收到提交的内容了
            // 这时候提交的指令并没有写回到dp中
            ASSERT(get_arf_busy(get_regidx("s0")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("s0")));

            ASSERT(dut->rootp->HeliosX__DOT__comnum == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__comnum);

            ASSERT(dut->rootp->HeliosX__DOT__dst_arf_1 == get_regidx("s0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_arf_1);

            ASSERT(dut->rootp->HeliosX__DOT__arfwe_1 == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__arfwe_1);

            ASSERT(dut->rootp->HeliosX__DOT__commit_ptr_1 == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__commit_ptr_1);

            // 第一条指令在150的时候执行完毕，这时DP模块应该可以收到执行部件前递来的结果
            // 前递结果将在160的时候写入rrf.data中。
            // 由于rrf中设计了旁路，所以在160的时候，就可以获取到第一条指令前递过来的结果了。
            // 验证执行部件的前递结果
            // 160的时候会收到第二条指令的执行完以后前递过来的结果
            ASSERT(get_rrf_rrfvalid(2) == 0, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(1));

            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_we == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_we);

            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_tag == 2,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);

            ASSERT(dut->rootp->HeliosX__DOT__alu_result == 1859,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);

            ASSERT(dut->rootp->HeliosX__DOT__rs1_sw == get_regidx("$0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rs1_sw);

            ASSERT(dut->rootp->HeliosX__DOT__pc_sw == 0x8000000C,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__pc_sw);

            ASSERT(dut->rootp->HeliosX__DOT__rrf_allocatable == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            ASSERT(
                dut->rootp
                        ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o ==
                    59,
                "sim_time: {} Error Imm Type {:#x}", sim_time,
                dut->rootp
                    ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o);

            ASSERT(
                dut->rootp->HeliosX__DOT__rrfptr_RrfEntryAllocate_out_rob_in ==
                    5,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rrfptr_RrfEntryAllocate_out_rob_in);

            ASSERT(dut->rootp->HeliosX__DOT__nextrrfcyc == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__nextrrfcyc);

            ASSERT(dut->rootp->HeliosX__DOT__dst_rrftag == 4,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            ASSERT(dut->rootp->HeliosX__DOT__dst_en == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            ASSERT(dut->rootp->HeliosX__DOT__rd_1_sw == get_regidx("a4"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rd_1_sw);

            ASSERT(dut->rootp->HeliosX__DOT__wr_reg_1_sw == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__wr_reg_1_sw);

            ASSERT(
                dut->rootp->HeliosX__DOT__src1_srcopmanager_out_srcmanager_in ==
                    0,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__src1_srcopmanager_out_srcmanager_in);

            ASSERT(
                dut->rootp->HeliosX__DOT__rdy1_srcopmanager_out_srcmanager_in ==
                    1,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rdy1_srcopmanager_out_srcmanager_in);

            /* ASSERT( */
            /*     dut->rootp->HeliosX__DOT__src2_srcopmanager_out_srcmanager_in
             * == */
            /*         1, */
            /*     "sim_time: {} Error Imm {:#x}", sim_time, */
            /*     dut->rootp->HeliosX__DOT__src2_srcopmanager_out_srcmanager_in);
             */
            /**/
            /* // 此时还没有写回，所以rdy应该是0 */
            /* ASSERT( */
            /*     dut->rootp->HeliosX__DOT__rdy2_srcopmanager_out_srcmanager_in
             * == */
            /*         0, */
            /*     "sim_time: {} Error Imm {:#x}", sim_time, */
            /*     dut->rootp->HeliosX__DOT__rdy2_srcopmanager_out_srcmanager_in);
             */

            ASSERT(dut->rootp->HeliosX__DOT__req1_alu == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__req1_alu);

            ASSERT(
                dut->rootp
                        ->HeliosX__DOT__req_alunum_RSRequestGen_out_SWUnit_in ==
                    1,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp
                    ->HeliosX__DOT__req_alunum_RSRequestGen_out_SWUnit_in);

            ASSERT(get_arf_rrftag(get_regidx("a4")) == 4,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_rrftag(get_regidx("a4")));

            ASSERT(get_arf_busy(get_regidx("s0")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("s0")));

        } else if (sim_time == 175) {
            // 验证第一条指令的ROB结果是否成功写回
            // 这时候不应该清空arf.busy,因为s0后面又被重命名了
            ASSERT(get_arf_busy(get_regidx("s0")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("s0")));

            ASSERT(get_arf_data(get_regidx("s0")) == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_data(get_regidx("s0")));

            // 验证一下debug相关的输出
            ASSERT(dut->debug_pc_o == 0x80000000,
                   "sim_time: {} Error Imm {:#x}", sim_time, dut->debug_pc_o);

            ASSERT(dut->debug_reg_id_o == get_regidx("s0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->debug_reg_id_o == get_regidx("s0"));

            ASSERT(dut->debug_reg_wdata_o == 0x0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->debug_reg_wdata_o);

            ASSERT(dut->debug_reg_wen_o == 1, "sim_time: {} Error Imm {:#x}",
                   sim_time, dut->debug_reg_wen_o);

            // 验证第二条指令执行阶段前递来的内容是否正确写入
            // rrftag=2时值是否正确
            ASSERT(get_rrf_rrfdata(2) == 1859, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfdata(2));

            ASSERT(get_rrf_rrfvalid(2) == 1, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(2));

            // 170的时候第二条指令已经提交完毕了，dp可以收到提交的内容了
            // 这时候提交的指令并没有写回到dp中
            ASSERT(get_arf_busy(get_regidx("a2")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("a2")));

            ASSERT(dut->rootp->HeliosX__DOT__comnum == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__comnum);

            ASSERT(dut->rootp->HeliosX__DOT__dst_arf_1 == get_regidx("a2"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_arf_1);

            ASSERT(dut->rootp->HeliosX__DOT__arfwe_1 == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__arfwe_1);

            ASSERT(dut->rootp->HeliosX__DOT__commit_ptr_1 == 2,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__commit_ptr_1);

            // 170的时候会收不到第三条指令的执行完以后前递过来的结果
            ASSERT(get_rrf_rrfvalid(3) == 0, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(1));

            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_we == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_we);

            ASSERT(dut->rootp->HeliosX__DOT__rs1_sw == get_regidx("$0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rs1_sw);

            ASSERT(dut->rootp->HeliosX__DOT__pc_sw == 0x80000010,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__pc_sw);

            ASSERT(dut->rootp->HeliosX__DOT__rrf_allocatable == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            ASSERT(
                dut->rootp
                        ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o ==
                    59,
                "sim_time: {} Error Imm Type {:#x}", sim_time,
                dut->rootp
                    ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o);

            ASSERT(
                dut->rootp->HeliosX__DOT__rrfptr_RrfEntryAllocate_out_rob_in ==
                    6,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rrfptr_RrfEntryAllocate_out_rob_in);

            ASSERT(dut->rootp->HeliosX__DOT__nextrrfcyc == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__nextrrfcyc);

            ASSERT(dut->rootp->HeliosX__DOT__dst_rrftag == 5,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            ASSERT(dut->rootp->HeliosX__DOT__dst_en == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            ASSERT(dut->rootp->HeliosX__DOT__rd_1_sw == get_regidx("a5"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rd_1_sw);

            ASSERT(dut->rootp->HeliosX__DOT__wr_reg_1_sw == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__wr_reg_1_sw);

            ASSERT(
                dut->rootp->HeliosX__DOT__src1_srcopmanager_out_srcmanager_in ==
                    0,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__src1_srcopmanager_out_srcmanager_in);

            ASSERT(
                dut->rootp->HeliosX__DOT__rdy1_srcopmanager_out_srcmanager_in ==
                    1,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rdy1_srcopmanager_out_srcmanager_in);

            /* ASSERT( */
            /*     dut->rootp->HeliosX__DOT__src2_srcopmanager_out_srcmanager_in
             * == */
            /*         1, */
            /*     "sim_time: {} Error Imm {:#x}", sim_time, */
            /*     dut->rootp->HeliosX__DOT__src2_srcopmanager_out_srcmanager_in);
             */
            /**/
            /* // 此时还没有写回，所以rdy应该是0 */
            /* ASSERT( */
            /*     dut->rootp->HeliosX__DOT__rdy2_srcopmanager_out_srcmanager_in
             * == */
            /*         0, */
            /*     "sim_time: {} Error Imm {:#x}", sim_time, */
            /*     dut->rootp->HeliosX__DOT__rdy2_srcopmanager_out_srcmanager_in);
             */

            ASSERT(dut->rootp->HeliosX__DOT__req1_alu == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__req1_alu);

            ASSERT(
                dut->rootp
                        ->HeliosX__DOT__req_alunum_RSRequestGen_out_SWUnit_in ==
                    1,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp
                    ->HeliosX__DOT__req_alunum_RSRequestGen_out_SWUnit_in);

            ASSERT(get_arf_rrftag(get_regidx("a5")) == 5,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_rrftag(get_regidx("a5")));

            // 第一条指令提交以后，不应该清空s0的arf.busy,因为s0后面又被重命名了
            ASSERT(get_arf_busy(get_regidx("s0")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("s0")));

        } else if (sim_time == 185) {
            // 验证第二条指令的ROB结果是否成功写回
            ASSERT(get_arf_busy(get_regidx("a2")) == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("a2")));

            ASSERT(get_arf_data(get_regidx("a2")) == 1859,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_data(get_regidx("a2")));

            // 验证一下debug相关的输出
            ASSERT(dut->debug_pc_o == 0x80000004,
                   "sim_time: {} Error Imm {:#x}", sim_time, dut->debug_pc_o);

            ASSERT(dut->debug_reg_id_o == get_regidx("a2"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->debug_reg_id_o == get_regidx("a2"));

            ASSERT(dut->debug_reg_wdata_o == 1859,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->debug_reg_wdata_o);

            ASSERT(dut->debug_reg_wen_o == 1, "sim_time: {} Error Imm {:#x}",
                   sim_time, dut->debug_reg_wen_o);

            // 180的时候会收到第三条指令的执行完以后前递过来的结果
            // 但是前递结果并没有写回,下周期才能写回
            ASSERT(get_rrf_rrfvalid(3) == 0, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(4));

            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_we == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_we);

            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_tag == 3,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);

            ASSERT(dut->rootp->HeliosX__DOT__alu_result == 1859,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);

            ASSERT(dut->rootp->HeliosX__DOT__rs1_sw == get_regidx("a4"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rs1_sw);

            ASSERT(dut->rootp->HeliosX__DOT__rs2_sw == get_regidx("a5"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rs2_sw);

            ASSERT(dut->rootp->HeliosX__DOT__pc_sw == 0x80000014,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__pc_sw);

            ASSERT(dut->rootp->HeliosX__DOT__rrf_allocatable == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            ASSERT(
                dut->rootp
                        ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o ==
                    59,
                "sim_time: {} Error Imm Type {:#x}", sim_time,
                dut->rootp
                    ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o);

            ASSERT(
                dut->rootp->HeliosX__DOT__rrfptr_RrfEntryAllocate_out_rob_in ==
                    7,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rrfptr_RrfEntryAllocate_out_rob_in);

            ASSERT(dut->rootp->HeliosX__DOT__nextrrfcyc == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__nextrrfcyc);

            ASSERT(dut->rootp->HeliosX__DOT__dst_rrftag == 6,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            ASSERT(dut->rootp->HeliosX__DOT__dst_en == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            ASSERT(dut->rootp->HeliosX__DOT__rd_1_sw == get_regidx("a0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rd_1_sw);

            ASSERT(dut->rootp->HeliosX__DOT__wr_reg_1_sw == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__wr_reg_1_sw);

            ASSERT(
                dut->rootp->HeliosX__DOT__src1_srcopmanager_out_srcmanager_in ==
                    4,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__src1_srcopmanager_out_srcmanager_in);

            ASSERT(
                dut->rootp->HeliosX__DOT__rdy1_srcopmanager_out_srcmanager_in ==
                    0,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rdy1_srcopmanager_out_srcmanager_in);

            ASSERT(
                dut->rootp->HeliosX__DOT__src2_srcopmanager_out_srcmanager_in ==
                    5,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__src2_srcopmanager_out_srcmanager_in);

            // 此时还没有写回，所以rdy应该是0
            ASSERT(
                dut->rootp->HeliosX__DOT__rdy2_srcopmanager_out_srcmanager_in ==
                    0,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__rdy2_srcopmanager_out_srcmanager_in);

            ASSERT(dut->rootp->HeliosX__DOT__req1_alu == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__req1_alu);

            ASSERT(
                dut->rootp
                        ->HeliosX__DOT__req_alunum_RSRequestGen_out_SWUnit_in ==
                    1,
                "sim_time: {} Error Imm {:#x}", sim_time,
                dut->rootp
                    ->HeliosX__DOT__req_alunum_RSRequestGen_out_SWUnit_in);

            ASSERT(get_arf_rrftag(get_regidx("a0")) == 6,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_rrftag(get_regidx("a0")));
        } else if (sim_time == 195) {
            // 验证第三条指令执行阶段前递来的内容是否正确写入
            // rrftag=3时值是否正确
            ASSERT(get_rrf_rrfdata(3) == 1859, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfdata(3));

            ASSERT(get_rrf_rrfvalid(3) == 1, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(3));

            // 190的时候第三条指令已经提交完毕了，dp可以收到提交的内容了
            // 这时候提交的指令并没有写回到dp中
            ASSERT(get_arf_busy(get_regidx("s0")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("s0")));

            ASSERT(dut->rootp->HeliosX__DOT__comnum == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__comnum);

            ASSERT(dut->rootp->HeliosX__DOT__dst_arf_1 == get_regidx("s0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_arf_1);

            ASSERT(dut->rootp->HeliosX__DOT__arfwe_1 == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__arfwe_1);

            ASSERT(dut->rootp->HeliosX__DOT__commit_ptr_1 == 3,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__commit_ptr_1);

            // 能收到第四条指令的执行结果，但是不会写入
            ASSERT(get_rrf_rrfvalid(4) == 0, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(4));

            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_we == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_we);

            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_tag == 4,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);

            ASSERT(dut->rootp->HeliosX__DOT__alu_result == 929,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);

            ASSERT(dut->rootp->HeliosX__DOT__rrf_allocatable == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__rrf_allocatable);

            ASSERT(
                dut->rootp
                        ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o ==
                    59,
                "sim_time: {} Error Imm Type {:#x}", sim_time,
                dut->rootp
                    ->HeliosX__DOT__u_ReNameUnit__DOT__freenum_RrfEntryAllocate_out_rob_in_o);

            ASSERT(get_arf_busy(get_regidx("s0")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("s0")));

            ASSERT(get_rrf_rrfvalid(4) == 0, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(4));

        } else if (sim_time == 205) {
            // 验证第三条指令的提交结果是否成功写入
            ASSERT(get_arf_busy(get_regidx("s0")) == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("s0")));

            ASSERT(get_arf_data(get_regidx("s0")) == 1859,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_data(get_regidx("s0")));

            // 验证一下debug相关的输出
            ASSERT(dut->debug_pc_o == 0x80000008,
                   "sim_time: {} Error Imm {:#x}", sim_time, dut->debug_pc_o);

            ASSERT(dut->debug_reg_id_o == get_regidx("s0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->debug_reg_id_o == get_regidx("s0"));

            ASSERT(dut->debug_reg_wdata_o == 1859,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->debug_reg_wdata_o);

            ASSERT(dut->debug_reg_wen_o == 1, "sim_time: {} Error Imm {:#x}",
                   sim_time, dut->debug_reg_wen_o);

            // 验证第四条指令执行阶段前递来的内容是否正确写入
            // rrftag=3时值是否正确
            ASSERT(get_rrf_rrfdata(4) == 929, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfdata(4));

            ASSERT(get_rrf_rrfvalid(4) == 1, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(4));

            // 200的时候第三条指令已经提交完毕了，dp可以收到提交的内容了
            // 这时候提交的指令并没有写回到dp中
            ASSERT(get_arf_busy(get_regidx("a4")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("a4")));

            ASSERT(dut->rootp->HeliosX__DOT__comnum == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__comnum);

            ASSERT(dut->rootp->HeliosX__DOT__dst_arf_1 == get_regidx("a4"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_arf_1);

            ASSERT(dut->rootp->HeliosX__DOT__arfwe_1 == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__arfwe_1);

            ASSERT(dut->rootp->HeliosX__DOT__commit_ptr_1 == 4,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__commit_ptr_1);

            // 能收到第五条指令的执行结果，但是不会写入
            ASSERT(get_rrf_rrfvalid(5) == 0, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(5));

            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_we == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_we);

            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_tag == 5,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);

            ASSERT(dut->rootp->HeliosX__DOT__alu_result == 22,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);

        } else if (sim_time == 215) {
            // 验证第四条指令的提交结果是否成功写入
            ASSERT(get_arf_busy(get_regidx("a4")) == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("a4")));

            ASSERT(get_arf_data(get_regidx("a4")) == 929,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_data(get_regidx("a4")));

            ASSERT(dut->debug_pc_o == 0x8000000C,
                   "sim_time: {} Error Imm {:#x}", sim_time, dut->debug_pc_o);

            ASSERT(dut->debug_reg_id_o == get_regidx("a4"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->debug_reg_id_o == get_regidx("a4"));

            ASSERT(dut->debug_reg_wdata_o == 929,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->debug_reg_wdata_o);

            ASSERT(dut->debug_reg_wen_o == 1, "sim_time: {} Error Imm {:#x}",
                   sim_time, dut->debug_reg_wen_o);
            // 验证第五条指令执行阶段前递来的内容是否正确写入
            // rrftag=5时值是否正确
            ASSERT(get_rrf_rrfdata(5) == 22, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfdata(5));

            ASSERT(get_rrf_rrfvalid(5) == 1, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(5));

            // 210的时候第五条指令已经提交完毕了，dp可以收到提交的内容了
            // 这时候提交的指令并没有写回到dp中
            ASSERT(get_arf_busy(get_regidx("a5")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("a5")));

            ASSERT(dut->rootp->HeliosX__DOT__comnum == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__comnum);

            ASSERT(dut->rootp->HeliosX__DOT__dst_arf_1 == get_regidx("a5"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_arf_1);

            ASSERT(dut->rootp->HeliosX__DOT__arfwe_1 == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__arfwe_1);

            ASSERT(dut->rootp->HeliosX__DOT__commit_ptr_1 == 5,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__commit_ptr_1);

        } else if (sim_time == 225) {
            // 验证第五条指令的提交结果是否成功写入
            ASSERT(get_arf_busy(get_regidx("a5")) == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("a5")));

            ASSERT(get_arf_data(get_regidx("a5")) == 22,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_data(get_regidx("a5")));

            ASSERT(dut->debug_pc_o == 0x80000010,
                   "sim_time: {} Error Imm {:#x}", sim_time, dut->debug_pc_o);

            ASSERT(dut->debug_reg_id_o == get_regidx("a5"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->debug_reg_id_o == get_regidx("a5"));

            ASSERT(dut->debug_reg_wdata_o == 22, "sim_time: {} Error Imm {:#x}",
                   sim_time, dut->debug_reg_wdata_o);

            ASSERT(dut->debug_reg_wen_o == 1, "sim_time: {} Error Imm {:#x}",
                   sim_time, dut->debug_reg_wen_o);
            // 验证第六条指令的执行前递结果是否正确
            // 但此时执行的前递结果还没有写回
            ASSERT(get_rrf_rrfvalid(6) == 0, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(6));

            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_we == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_we);

            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_tag == 6,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);

            ASSERT(dut->rootp->HeliosX__DOT__alu_result == 951,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);

        } else if (sim_time == 235) {
            // 验证第六条指令执行阶段前递来的内容是否正确写入
            // rrftag=6时值是否正确
            ASSERT(get_rrf_rrfdata(6) == 951, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfdata(6));

            ASSERT(get_rrf_rrfvalid(6) == 1, "sim_time: {} Error Imm {:#x}",
                   sim_time, get_rrf_rrfvalid(6));

            // 第六条指令已经提交完毕了，dp可以收到提交的内容了
            // 这时候提交的指令并没有写回到dp中
            ASSERT(get_arf_busy(get_regidx("a0")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("a0")));

            ASSERT(dut->rootp->HeliosX__DOT__comnum == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__comnum);

            ASSERT(dut->rootp->HeliosX__DOT__dst_arf_1 == get_regidx("a0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_arf_1);

            ASSERT(dut->rootp->HeliosX__DOT__arfwe_1 == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__arfwe_1);

            ASSERT(dut->rootp->HeliosX__DOT__commit_ptr_1 == 6,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__commit_ptr_1);

            ASSERT(get_arf_busy(get_regidx("a0")) == 1,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("a0")));

        } else if (sim_time == 245) {
            // 验证第六条指令提交结果是否写入成功
            ASSERT(get_arf_busy(get_regidx("a0")) == 0,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_busy(get_regidx("a0")));

            ASSERT(get_arf_data(get_regidx("a0")) == 951,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   get_arf_data(get_regidx("a0")));

            ASSERT(dut->debug_pc_o == 0x80000014,
                   "sim_time: {} Error Imm {:#x}", sim_time, dut->debug_pc_o);

            ASSERT(dut->debug_reg_id_o == get_regidx("a0"),
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->debug_reg_id_o == get_regidx("a0"));

            ASSERT(dut->debug_reg_wdata_o == 951,
                   "sim_time: {} Error Imm {:#x}", sim_time,
                   dut->debug_reg_wdata_o);

            ASSERT(dut->debug_reg_wen_o == 1, "sim_time: {} Error Imm {:#x}",
                   sim_time, dut->debug_reg_wen_o);
        }
    }

    void wakeup_test() {
        if (sim_time == 135) {
            ASSERT(dut->rootp->HeliosX__DOT__req1_alu == 1,
                   "sim_time: {} Error Alu req num: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__req1_alu);
        } else if (sim_time == 145) {
            // li s0, 0
            ASSERT(dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_pc_o ==
                       0x80000000,
                   "sim_time: {} Error Alu pc: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__exe_alu_pc);
            ASSERT(dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_op_1_o == 0,
                   "sim_time: {} Error OP 1: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_op_1_o);
            ASSERT(dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_op_2_o == 0,
                   "sim_time: {} Error OP 2: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_op_2_o);
            ASSERT(dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_imm_o == 0,
                   "sim_time: {} Error ALU IMM: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_imm_o);
        } else if (sim_time == 155) {
            // li a2, 1859
            ASSERT(dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_pc_o ==
                       0x80000004,
                   "sim_time: {} Error Alu pc: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__exe_alu_pc);
            ASSERT(
                dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_imm_o == 1859,
                "sim_time: {} Error ALU IMM: {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_imm_o);

        } else if (sim_time == 165) {
            // Pending
#ifdef DEBUG
            fmt::println("[RS] sim_time: {}, exe_alu_pc_o: {:#x}", sim_time,
                         dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_pc_o);
#endif

        } else if (sim_time == 175) {
            // li a4, 929
            // add s0, a2, s0
            ASSERT(dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_pc_o ==
                       0x80000008,
                   "sim_time: {} Error Alu pc: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__exe_alu_pc);

            ASSERT(
                dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_op_1_o == 1859,
                "sim_time: {} Error exe_op_1_o: {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_op_1_o);
            ASSERT(dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_op_2_o == 0,
                   "sim_time: {} Error exe_op_2_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_op_2_o);

        } else if (sim_time == 185) {
            // li a5, 22
            ASSERT(dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_pc_o ==
                       0x8000000C,
                   "sim_time: {} Error Alu pc: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__exe_alu_pc);
            ASSERT(
                dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_imm_o == 929,
                "sim_time: {} Error exe_alu_imm_o: {:#x}", sim_time,
                dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_imm_o);
        } else if (sim_time == 195) {
            // add a0, a4, a5
            // Pending
            ASSERT(dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_pc_o ==
                       0x80000010,
                   "sim_time: {} Error exe_alu_pc_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__exe_alu_pc);
            ASSERT(dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_imm_o == 22,
                   "sim_time: {} Error exe_alu_imm_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_imm_o);
        } else if (sim_time == 205) {
            // Pending
#ifdef DEBUG
            fmt::println("[RS] sim_time: {}, exe_alu_pc_o: {:#x}", sim_time,
                         dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_pc_o);
#endif
        } else if (sim_time == 215) {
            ASSERT(dut->rootp->HeliosX__DOT__u_SwUint__DOT__exe_alu_pc_o ==
                       0x80000014,
                   "sim_time: {} Error exe_alu_pc_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__exe_alu_pc);
        }
    }

    void execute_test() {
        if (sim_time == 155) {
            // li s0, 0         -> addi s0, x0, 0
            ASSERT(dut->rootp->HeliosX__DOT__alu_result == 0,
                   "sim_time: {} Error Alu result: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_result);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_tag == 1,
                   "sim_time: {} Error Alu rrf_tag: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rob_we == 1,
                   "sim_time: {} Error Alu rob_we: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rob_we);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_we == 1,
                   "sim_time: {} Error Alu rrf_we: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_we);
        } else if (sim_time == 165) {
            // li a2, 1859      -> addi a2, x0, 1859
            ASSERT(dut->rootp->HeliosX__DOT__alu_result == 1859,
                   "sim_time: {} Error Alu result: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_result);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_tag == 2,
                   "sim_time: {} Error Alu rrf_tag: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rob_we == 1,
                   "sim_time: {} Error Alu rob_we: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rob_we);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_we == 1,
                   "sim_time: {} Error Alu rrf_we: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_we);
        } else if (sim_time == 175) {
            // pending

        } else if (sim_time == 185) {
            // add s0, a2, s0
            ASSERT(dut->rootp->HeliosX__DOT__alu_result == 0 + 1859,
                   "sim_time: {} Error Alu result: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_result);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_tag == 3,
                   "sim_time: {} Error Alu rrf_tag: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rob_we == 1,
                   "sim_time: {} Error Alu rob_we: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rob_we);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_we == 1,
                   "sim_time: {} Error Alu rrf_we: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_we);
        } else if (sim_time == 195) {
            // li a4, 929       -> addi a4, x0, 929
            ASSERT(dut->rootp->HeliosX__DOT__alu_result == 929,
                   "sim_time: {} Error Alu result: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_result);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_tag == 4,
                   "sim_time: {} Error Alu rrf_tag: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rob_we == 1,
                   "sim_time: {} Error Alu rob_we: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rob_we);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_we == 1,
                   "sim_time: {} Error Alu rrf_we: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_we);
        } else if (sim_time == 205) {
            // li a5, 22        -> addi a5, x0, 22
            ASSERT(dut->rootp->HeliosX__DOT__alu_result == 22,
                   "sim_time: {} Error Alu result: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_result);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_tag == 5,
                   "sim_time: {} Error Alu rrf_tag: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rob_we == 1,
                   "sim_time: {} Error Alu rob_we: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rob_we);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_we == 1,
                   "sim_time: {} Error Alu rrf_we: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_we);
        } else if (sim_time == 215) {
            // pending

        } else if (sim_time == 225) {
            // add a0, a4, a5
            ASSERT(dut->rootp->HeliosX__DOT__alu_result == 929 + 22,
                   "sim_time: {} Error Alu result: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_result);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_tag == 6,
                   "sim_time: {} Error Alu rrf_tag: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_tag);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rob_we == 1,
                   "sim_time: {} Error Alu rob_we: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rob_we);
            ASSERT(dut->rootp->HeliosX__DOT__alu_rrf_we == 1,
                   "sim_time: {} Error Alu rrf_we: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__alu_rrf_we);
        }
    }

    void commit_test() {
        if (sim_time == 165) {
            // li s0,0
            //  fmt::println("sim_time: {}, dst: {}", sim_time,
            //  dut->rootp->HeliosX__DOT__ )
            ASSERT(dut->rootp->HeliosX__DOT__commit_ptr_1 == 1,
                   "sim_time: {} Error commit_ptr_1_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__commit_ptr_1);
            ASSERT(dut->rootp->HeliosX__DOT__dst_arf_1 == get_regidx("s0"),
                   "sim_time: {} Error dst_arf_1_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_arf_1);

        } else if (sim_time == 175) {
            // li a2,1859
            ASSERT(dut->rootp->HeliosX__DOT__commit_ptr_1 == 2,
                   "sim_time: {} Error commit_ptr_1_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__commit_ptr_1);
            ASSERT(dut->rootp->HeliosX__DOT__dst_arf_1 == get_regidx("a2"),
                   "sim_time: {} Error dst_arf_1_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_arf_1);
        } else if (sim_time == 185) {
            // Pending
        } else if (sim_time == 195) {
            // add s0,a2,s0
            ASSERT(dut->rootp->HeliosX__DOT__commit_ptr_1 == 3,
                   "sim_time: {} Error commit_ptr_1_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__commit_ptr_1);
            ASSERT(dut->rootp->HeliosX__DOT__dst_arf_1 == get_regidx("s0"), ,
                   "sim_time: {} Error dst_arf_1_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_arf_1);
        } else if (sim_time == 205) {
            // li a4,929
            ASSERT(dut->rootp->HeliosX__DOT__commit_ptr_1 == 4,
                   "sim_time: {} Error commit_ptr_1_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__commit_ptr_1);
            ASSERT(dut->rootp->HeliosX__DOT__dst_arf_1 == get_regidx("a4"),
                   "sim_time: {} Error dst_arf_1_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_arf_1);
        } else if (sim_time == 215) {
            // li a5,22
            ASSERT(dut->rootp->HeliosX__DOT__commit_ptr_1 == 5,
                   "sim_time: {} Error commit_ptr_1_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__commit_ptr_1);
            ASSERT(dut->rootp->HeliosX__DOT__dst_arf_1 == get_regidx("a5"), ,
                   "sim_time: {} Error dst_arf_1_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_arf_1);
        } else if (sim_time == 225) {
            // Pending
        } else if (sim_time == 235) {
            // add a0,a4,a5
            ASSERT(dut->rootp->HeliosX__DOT__commit_ptr_1 == 6,
                   "sim_time: {} Error commit_ptr_1_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__commit_ptr_1);
            ASSERT(dut->rootp->HeliosX__DOT__dst_arf_1 == get_regidx("a0"), ,
                   "sim_time: {} Error dst_arf_1_o: {:#x}", sim_time,
                   dut->rootp->HeliosX__DOT__dst_arf_1);
        }
    }

    void initialize_signal() override {
        dut->reset_i = 1;
        dut->idata_i = 0;
        dut->dmem_rdata_i = 0;
    }

    void input() override {
        Instruction inst_o;
        uint32_t inst_value_o;

        if (sim_time == 90) {
            dut->reset_i = 0;
        }

        // 应该reset_i=0的时候才能开始取指令，不然时序不对
        if (sim_time >= 90 && sim_time % 10 == 0) {
            mem->fetch(1, dut->iaddr_o, inst_o, inst_value_o);
            dut->idata_i = inst_o.instructions[0];
#ifdef DEBUG
            fmt::println(
                "sim_time: {}, inst_o: {:#x}, inst_value_o: {}, iaddr_o: {:#x}",
                sim_time, inst_o.instructions[0], inst_value_o, dut->iaddr_o);
#endif
        }
    }

    void verify_dut() override {
        fetch_test();
        decode_test();
        dispatch_test();
        wakeup_test();
        execute_test();
        commit_test();
    }

   protected:
    std::shared_ptr<Memory> mem;
};

int main(int argc, char **argv, char **env) {
    const uint32_t img[] = {
        0x00000413,  // li s0, 0         -> addi s0, x0, 0
        0x74300613,  // li a2, 1859      -> addi a2, x0, 1859
        0x00860433,  // add s0, a2, s0
        0x3a100713,  // li a4, 929       -> addi a4, x0, 929
        0x01600793,  // li a5, 22        -> addi a5, x0, 22
        0x00f70533   // add a0, a4, a5
    };

    std::shared_ptr<Memory> mem = std::make_shared<Memory>(0x80000000, 0x10000);
    mem->load(0x80000000, (const char *)img, sizeof(img));
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VHeliosXTb> tb =
        std::make_shared<VHeliosXTb>(5, 50, 1500, mem);

    tb->run("heliosx.vcd");
    fmt::println("==========================");
    fmt::print("HeliosX Dut Correctness passed!\n");
    fmt::println("==========================");
}
