#include "VRSAluEntry.h"
#include "VRSAluEntry___024root.h"

#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>
#include <memory>
#include <assert.h>

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7

void dut_reset(std::shared_ptr<VRSAluEntry> dut, vluint64_t &sim_time) {
    if (sim_time >= 0 && sim_time < 50) {
        dut->busy_i = 0;

        dut->write_pc_i = 0;
        dut->write_op_1_i = 0;
        dut->write_op_2_i = 0;
        dut->write_op_1_valid_i = 0;
        dut->write_op_2_valid_i = 0;
        dut->write_imm_i = 0;
        dut->write_rrf_tag_i = 0;
        dut->write_dst_val_i = 0;

        dut->write_alu_op_i = 0;
        dut->we_i = 0;

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
}

void op_valid_test(std::shared_ptr<VRSAluEntry> dut, vluint64_t &sim_time) {
    if (sim_time == 50) {
        dut->busy_i = 1;
        dut->write_pc_i = 0x80000000;
        dut->write_op_1_i = 0x00000001;
        dut->write_op_2_i = 0x00000002;
        dut->write_alu_op_i = 1;
        dut->write_op_1_valid_i = 1;
        dut->write_op_2_valid_i = 1;

        dut->we_i = 1;
    } else if (sim_time == 60) {
        dut->write_pc_i = 0;
        dut->write_op_1_i = 0;
        dut->write_op_2_i = 0;
        dut->write_op_1_valid_i = 0;
        dut->write_op_2_valid_i = 0;
        dut->we_i = 0;

        assert(dut->exe_pc_o == 0x80000000);
        assert(dut->exe_op_1_o == 0x00000001);
        assert(dut->exe_op_2_o == 0x00000002);
        assert(dut->exe_alu_op_o == 1);
        assert(dut->ready_o == 1);

        std::cout << "RS ALU Entry OP Valid Test Pass!" << std::endl;
    }
}

void op_invalid_test(std::shared_ptr<VRSAluEntry> dut, vluint64_t &sim_time) {
    if (sim_time == 70) {
        dut->busy_i = 1;
        dut->write_pc_i = 0x80000000;
        // RRFTag 1
        dut->write_op_1_i = 1;
        // RRFTag 2
        dut->write_op_2_i = 2;
        dut->write_alu_op_i = 1;
        // Operator Invalid
        dut->write_op_1_valid_i = 0;
        dut->write_op_2_valid_i = 0;

        dut->we_i = 1;
    } else if (sim_time == 80) {
        dut->write_pc_i = 0;
        dut->write_op_1_i = 0;
        dut->write_op_2_i = 0;
        dut->write_op_1_valid_i = 0;
        dut->write_op_2_valid_i = 0;
        dut->we_i = 0;

        assert(dut->exe_pc_o == 0x80000000);
        assert(dut->exe_op_1_o == 1);
        assert(dut->exe_op_2_o == 2);
        assert(dut->exe_alu_op_o == 1);
        assert(dut->ready_o == 0);

        dut->exe_result_1_dst_i = 1;
        dut->exe_result_1_i = 0xFF;
        dut->exe_result_2_dst_i = 2;
        dut->exe_result_2_i = 0xFFFF;
    } else if (sim_time == 90) {
        assert(dut->ready_o == 1);
        assert(dut->exe_op_1_o == 0xFF);
        assert(dut->exe_op_2_o == 0xFFFF);
        std::cout << "RS ALU Entry OP Invalid Test Pass!" << std::endl;
    }
}

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_shared<VRSAluEntry>();

    Verilated::traceEverOn(true);
    auto m_trace = std::make_shared<VerilatedVcdC>();
    dut->trace(m_trace.get(), 99);

    vluint64_t sim_time = 0;
    vluint64_t posedge_cnt = 0;

    m_trace->open("rs_alu_entry.vcd");

    while (sim_time < MAX_SIM_TIME) {
        dut_reset(dut, sim_time);
        if ((sim_time % 5) == 0) {
            dut->clk_i ^= 1;
        }
        dut->eval();

        if (dut->clk_i == 1) {
            op_valid_test(dut, sim_time);
            op_invalid_test(dut, sim_time);
        }

        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
}