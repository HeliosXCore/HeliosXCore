#include "verilator_tb.hpp"
#include "VROB.h"
#include "VROB___024root.h"
#include "error_handler.hpp"
#include <iostream>
#include <verilated.h>


vluint64_t sim_time = 0;


template<>
void  VerilatorTb<VROB>::initialize_signal(){

    dut->clk_i = 0;
    dut->reset_i = 1;
    dut->dp1_i = 0;            
    dut->dp1_addr_i = 0;             
    dut->pc_dp1_i = 0;
    dut->storebit_dp1_i = 0;
    dut->dstvalid_dp1_i = 0;
    dut->dst_dp1_i = 0;
    dut->bhr_dp1_i = 0;
    dut->isbranch_dp1_i = 0;
    dut->dp2_i = 0;
    dut->dp2_addr_i = 0;
    dut->pc_dp2_i = 0;
    dut->storebit_dp2_i = 0;
    dut->dstvalid_dp2_i = 0;
    dut->dst_dp2_i = 0;
    dut->bhr_dp2_i = 0;
    dut->isbranch_dp2_i = 0;
    dut->finish_ex_alu1_i = 0;     
    dut->finish_ex_alu1_addr_i = 0;
    dut->finish_ex_alu2_i = 0;
    dut->finish_ex_alu2_addr_i = 0;
    dut->finish_ex_mul_i = 0;
    dut->finish_ex_mul_addr_i = 0;
    dut->finish_ex_ldst_i = 0;
    dut->finish_ex_ldst_addr_i = 0;
    dut->finish_ex_branch_i = 0;
    dut->finish_ex_branch_addr_i = 0;
    dut->finish_ex_branch_brcond_i = 0;
    dut->finish_ex_branch_jmpaddr_i = 0;
    
};



class VROBTb : public VerilatorTb<VROB> {
    public:
        VROBTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
            : VerilatorTb<VROB>(clock, start_time, end_time) {}


    void test1_input() {
        //假设有四条指令：分别都是
        // add，r1,r2,r3       r1 -> 1
        // add，r2,r3,r4       r2 -> 2 
        //load  r1, 0x1008     
        //store r2, 0x1010    

        if (sim_time == 10) {
            //add，r1,r2,r3
            dut->reset_i = 0;
        }
        else if (sim_time == 30) {
            dut->dp1_i = 1;
            dut->dp1_addr_i = 1;
            dut->storebit_dp1_i = 0;
            dut->dstvalid_dp1_i = 1;
            dut->dst_dp1_i = 1;
            }
        else if (sim_time == 40) {
            dut->dp1_i = 1;
            dut->dp1_addr_i = 2;
            dut->storebit_dp1_i = 0;
            dut->dstvalid_dp1_i = 1;
            dut->dst_dp1_i = 2;
        }
        else if (sim_time == 50) {
            //dp1
            dut->dp1_i = 1;
            dut->dp1_addr_i = 3;
            dut->storebit_dp1_i = 0;
            dut->dstvalid_dp1_i = 0;
            dut->dst_dp1_i = 1;

            //exe
            dut->finish_ex_alu1_i = 1;
            dut->finish_ex_alu1_addr_i = 1;
        }

        else if (sim_time == 60) {   
            //dp1
            dut->dp1_i = 1;
            dut->dp1_addr_i = 4;
            dut->storebit_dp1_i = 1;
            dut->dstvalid_dp1_i = 0;
            dut->dst_dp1_i = 2;

            //exe
            dut->finish_ex_alu1_i = 1;
            dut->finish_ex_alu1_addr_i = 2;
        }
        else if (sim_time == 70) {
            //exe
            dut->finish_ex_ldst_i = 1;
            dut->finish_ex_ldst_addr_i = 3;
        }
        else if (sim_time == 80) {
            //exe
            dut->finish_ex_ldst_i = 1;
            dut->finish_ex_ldst_addr_i = 4;
        }

    }


    void test1_verify() {
        if(sim_time == 60) {
            ASSERT(dut->commit_ptr_1_o == 1,"when sim_time = {}, ERROR: commit_ptr_1_o should be equal to 1, but now commit_ptr_1_o = {}", sim_time, dut->commit_ptr_1_o);
            ASSERT(dut->arfwe_1_o == 1,"when sim_time = {}, ERROR: arfwe_1_o should be equal to 1,now it is {}", sim_time,dut->arfwe_1_o);
            ASSERT(dut->dst_arf_1_o == 1,"when sim_time = {}, ERROR: dst_arf_1_o should be equal to 1,now it is {}", sim_time,dut->dst_arf_1_o);
        }
        if(sim_time == 70) {
            ASSERT(dut->commit_ptr_1_o == 2,"when sim_time = {}, ERROR: commit_ptr_1_o should be equal to 2, but now commit_ptr_1_o = {}", sim_time, dut->commit_ptr_1_o);
            ASSERT(dut->arfwe_1_o == 1,"when sim_time = {}, ERROR: arfwe_1_o should be equal to 1,now it is {}", sim_time,dut->arfwe_1_o);
            ASSERT(dut->dst_arf_1_o == 2,"when sim_time = {}, ERROR: dst_arf_1_o should be equal to 1,now it is {}", sim_time,dut->dst_arf_1_o)
        }
        if(sim_time == 80) {
            ASSERT(dut->commit_ptr_1_o == 3,"when sim_time = {}, ERROR: commit_ptr_1_o should be equal to 3, but now commit_ptr_1_o = {}", sim_time, dut->commit_ptr_1_o);
            ASSERT(dut->arfwe_1_o == 0,"when sim_time = {}, ERROR: arfwe_1_o should be equal to 0,now it is {}", sim_time,dut->arfwe_1_o);
            ASSERT(dut->dst_arf_1_o == 1,"when sim_time = {}, ERROR: dst_arf_1_o should be equal to 1,now it is {}", sim_time,dut->dst_arf_1_o)
        }
        if(sim_time == 90) {
            ASSERT(dut->commit_ptr_1_o == 4,"when sim_time = {}, ERROR: commit_ptr_1_o should be equal to 4, but now commit_ptr_1_o = {}", sim_time, dut->commit_ptr_1_o);
            ASSERT(dut->arfwe_1_o == 0,"when sim_time = {}, ERROR: arfwe_1_o should be equal to 0,now it is {}", sim_time,dut->arfwe_1_o);
            ASSERT(dut->dst_arf_1_o == 2,"when sim_time = {}, ERROR: dst_arf_1_o should be equal to 2,now it is {}", sim_time,dut->dst_arf_1_o)
            ASSERT(dut->store_commit_o == 1,"when sim_time = {}, ERROR: store_commit_o should be equal to 1,now it is {}", sim_time,dut->store_commit_o)
        }
    
    }

        void input() {
            test1_input();
    }
        void verify_dut() {
            test1_verify();          
        }
};




int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VROBTb> tb = std::make_shared<VROBTb>(5, 10, 200);

    tb->run("ROB.vcd");
}


