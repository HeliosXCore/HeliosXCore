#include <cstdlib>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <stdlib.h>
#include <assert.h>
#include <iostream>

#include "obj_dir/Vimm_gen.h"
#include "decoder.hpp"

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_shared<Vimm_gen>();

    Verilated::traceEverOn(true);
    auto m_trace = std::make_shared<VerilatedVcdC>();
    dut->trace(m_trace.get(), 99);

    m_trace->open("imm_gen.vcd");

    while (sim_time < MAX_SIM_TIME) {
        dut->eval();

        if (sim_time == 5) {
            // type:U
            /* 0x800002b7,  // lui t0,0x80000 */
            dut->inst = 0x800002b7;
            dut->imm_type = IMM_U;
        }
        if (sim_time == 6) {
            assert(dut->imm == 0x80000000);
            std::cout << "imm_gen Test 1 Pass!" << std::endl;
        }

        /* 80000024:	374000ef          	jal	ra,80000398 <halt> */
        // type: J
        if (sim_time == 7) {
            dut->inst = 0x374000ef;
            dut->imm_type = IMM_J;
        }
        if (sim_time == 8) {
            assert(dut->imm == 0x374);
            std::cout << "imm_gen Test 2 Pass!" << std::endl;
        }
        /* 80000034:	00082883          	lw	a7,0(a6) */
        // type:I
        if (sim_time == 9) {
            dut->inst = 0x00082883;
            dut->imm_type = IMM_I;
        }
        if (sim_time == 10) {
            assert(dut->imm == 0x0);
            std::cout << "imm_gen Test 3 Pass!" << std::endl;
        }
        /* 80000074:	00f82023          	sw	a5,0(a6) */
        // type:S
        if (sim_time == 11) {
            dut->inst = 0x00f82023;
            dut->imm_type = IMM_S;
        }
        if (sim_time == 12) {
            assert(dut->imm == 0x0);
            std::cout << "imm_gen Test 4 Pass!" << std::endl;
        }
        sim_time++;
    }

    m_trace->dump(sim_time);
}
