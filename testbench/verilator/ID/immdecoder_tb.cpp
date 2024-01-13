#include <cstdlib>
#include <memory>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <stdlib.h>
#include <assert.h>
#include <iostream>

#include "VImmDecoder.h"
#include "decoder.hpp"

#define MAX_SIM_TIME 300
#define VERIF_START_TIME 7
vluint64_t sim_time = 0;

int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_shared<VImmDecoder>();

    Verilated::traceEverOn(true);
    auto m_trace = std::make_shared<VerilatedVcdC>();
    dut->trace(m_trace.get(), 99);

    m_trace->open("ImmDecoder.vcd");

    while (sim_time < MAX_SIM_TIME) {
        dut->eval();

        if (sim_time == 5) {
            // type:U
            /* 0x800002b7,  // lui t0,0x80000 */
            dut->inst = 0x800002b7;
            dut->imm_type = IMM_U;
        }
        else if (sim_time == 10) {
            assert(dut->imm == 0x80000000);
            std::cout << "ImmDecoder Test 1 Pass!" << std::endl;
        }

        /* 80000024:	374000ef          	jal	ra,80000398 <halt> */
        // type: J
        else if (sim_time == 15) {
            dut->inst = 0x374000ef;
            dut->imm_type = IMM_J;
        }
        else if (sim_time == 20) {
            assert(dut->imm == 0x374);
            std::cout << "ImmDecoder Test 2 Pass!" << std::endl;
        }
        /* 80000034:	00082883          	lw	a7,0(a6) */
        // type:I
        else if (sim_time == 25) {
            dut->inst = 0x00082883;
            dut->imm_type = IMM_I;
        }
        else if (sim_time == 30) {
            assert(dut->imm == 0x0);
            std::cout << "ImmDecoder Test 3 Pass!" << std::endl;
        }
        /* 80000074:	00f82023          	sw	a5,0(a6) */
        // type:S
        else if (sim_time == 35) {
            dut->inst = 0x00f82023;
            dut->imm_type = IMM_S;
        }
        else if (sim_time == 40) {
            assert(dut->imm == 0x0);
            std::cout << "ImmDecoder Test 4 Pass!" << std::endl;
        }
        sim_time++;
    }

    m_trace->dump(sim_time);
}
