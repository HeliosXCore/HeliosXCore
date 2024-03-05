#include "verilator_tb.hpp"
#include "VSingleInstROB.h"
#include "VSingleInstROB___024root.h"
#include "error_handler.hpp"
#include <iostream>
#include <verilated.h>


#define MAX_SIM_TIME 300
vluint64_t sim_time = 0;


template<>
void  VerilatorTb<VSingleInstROB>::initialize_signal(){
    dut->clk_i = 0;
    dut->reset_i = 1; 
    dut->dp1_i = 0;
    dut->dp1_addr_i = 0;
    dut->pc_dp1_i = 0;
    dut->dstvalid_dp1_i = 0;
    dut->dst_dp1_i = 0;
    dut->finish_ex_alu1_i = 0;
    dut->finish_ex_alu1_addr_i = 0;

};



class VSingleInstROBTb : public VerilatorTb<VSingleInstROB> {
    public:
        VSingleInstROBTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
            : VerilatorTb<VSingleInstROB>(clock, start_time, end_time) {}
        
        void test1_input() {
            if (sim_time == 10) {
                dut->reset_i = 0;
            }
            
            else if (sim_time == 30) {
                //dp阶段
                dut->dp1_i = 1;
                dut->dp1_addr_i = 1;
                dut->dst_dp1_i = 8;
                dut->dstvalid_dp1_i = 1;
                dut->pc_dp1_i = 0x80;

            }
            else if (sim_time == 40) {
                //dp阶段输入
                dut->dp1_i = 1;
                dut->dp1_addr_i = 2;
                dut->dst_dp1_i = 12;
                dut->dstvalid_dp1_i = 1;
                dut->pc_dp1_i = 0x84;
            }
            else if (sim_time == 50) {
                //dp阶段输入
                dut->dp1_i = 1;
                dut->dp1_addr_i = 3;
                dut->dst_dp1_i = 8;
                dut->dstvalid_dp1_i = 1;

                //exe阶段输入
                dut->finish_ex_alu1_i = 1;
                dut->finish_ex_alu1_addr_i = 1;
            }
            else if (sim_time == 60) {
                //dp阶段输入
                dut->dp1_i = 1;
                dut->dp1_addr_i = 4;
                dut->dst_dp1_i = 13;
                dut->dstvalid_dp1_i = 1;

                //exe阶段输入
                dut->finish_ex_alu1_i = 1;
                dut->finish_ex_alu1_addr_i = 2;
                
            }
            else if(sim_time == 70) {
                //dp阶段输入
                dut->dp1_i = 1;
                dut->dp1_addr_i = 5;
                dut->dst_dp1_i = 14;
                dut->dstvalid_dp1_i = 1;

            }
        }


        void test_verify() {
            if(sim_time == 65) {
                ASSERT(dut->arfwe_1_o == 1, "when sim_time = {}, ERROR: arfwe_1_o should be equal to 1,Error value is {}", sim_time,dut->arfwe_1_o);
                ASSERT(dut->commit_ptr_1_o == 1, "when sim_time = {}, ERROR: commit_ptr_1_o should be equal to 2,Error value is {}", sim_time, dut->commit_ptr_1_o);
                ASSERT(dut->comnum_o == 1, "when sim_time = {}, ERROR: comnum_o should be equal to 1,Error value is {}", sim_time, dut->comnum_o);
                ASSERT(dut->dst_arf_1_o == 8,"when sim_time = {}, ERROR: dst_arf_1_o should be equal to 8, Error value is {},Error value is {}", sim_time, dut->dst_arf_1_o);
                ASSERT(dut->pc_com_o == 0x80,"when sim_time = {}, ERROR: pc_com_o should be equal to 0x80, Error vaule is {}",sim_time, dut->pc_com_o);
                fmt::println("SingleInstROB test1 passed!");
            } else if(sim_time == 75) {
                ASSERT(dut->arfwe_1_o == 1, "when sim_time = {}, ERROR: arfwe_1_o should be equal to 1,Error value is {}", sim_time,dut->arfwe_1_o);
                ASSERT(dut->commit_ptr_1_o == 2, "when sim_time = {}, ERROR: commit_ptr_1_o should be equal to 3, Error value is {}", sim_time, dut->commit_ptr_1_o);
                ASSERT(dut->comnum_o == 1, "when sim_time = {}, ERROR: comnum_o should be equal to 2,Error value is {}", sim_time, dut->comnum_o);
                ASSERT(dut->dst_arf_1_o == 12,"when sim_time = {}, ERROR: dst_arf_1_o should be equal to 8,Error value is {}",sim_time, dut->dst_arf_1_o);
                ASSERT(dut->pc_com_o == 0x84,"when sim_time = {}, ERROR: pc_com_o should be equal to 0x84, Error vaule is {}",sim_time, dut->pc_com_o);
                fmt::println("SingleInstROB test2 passed!");
            }

        }
        void input() {
            test1_input();
    }
        void verify_dut() {
            test_verify();          
        }
};


int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VSingleInstROBTb> tb = std::make_shared<VSingleInstROBTb>(5, 10, 100);

    tb->run("SingleInstROB.vcd");
}


