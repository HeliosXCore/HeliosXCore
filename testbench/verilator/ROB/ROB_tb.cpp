#include "verilator_tb.hpp"
#include "VROB.h"
#include "VROB___024root.h"
#include "error_handler.hpp"
#include <iostream>
#include <verilated.h>


#define MAX_SIM_TIME 300
vluint64_t sim_time = 0;


template<>
void  VerilatorTb<VROB>::initialize_signal(){

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
    dut->storebit_dp1_i = 0;
    dut->dstvalid_dp2_i = 0;
    dut->dst_dp2_i = 0;
    dut->bhr_dp2_i = 0;
    dut->isbranch_dp2_i = 0;

    dut->finish_ex_alu1_i = 0;
    dut->finish_ex_alu1_addr_i = 0;
    dut->finish_ex_alu2_i = 0;
    dut->finish_ex_alu2_addr_i = 0;
    

};



class VROBTb : public VerilatorTb<VROB> {
    public:
        VROBTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
            : VerilatorTb<VROB>(clock, start_time, end_time) {}
        

        //假设有四条指令：分别都是 
        // add，r1,r2,r3  目的寄存器被重命名为 x0
        // add，r2,r3,r4  目的寄存器被重命名为 x1
        // add，r3,r4,r5  目的寄存器被重命名为 x2
        // add，r4,r5,r6  目的寄存器被重命名为 x3
        //地址分别是 0x1000，0x1004，0x1008，0x100c
        void test4add(){
            if(sim_time == 60) {
                dut->dp1_i = 1;
                dut->dp1_addr_i = 0;
                dut->pc_dp1_i = 0x1000;
                dut->storebit_dp1_i = 0;
                dut->dstvalid_dp1_i = 1;
                dut->dst_dp1_i = 1;

                dut->dp2_i = 1;
                dut->dp2_addr_i = 1;
                dut->pc_dp2_i = 0x1004;
                dut->storebit_dp2_i = 0;
                dut->dstvalid_dp2_i = 1;
                dut->dst_dp2_i = 2;
            }
            if(sim_time == 70) {
                //dp1
                dut->dp1_i = 1;
                dut->dp1_addr_i = 2;
                dut->pc_dp1_i = 0x1008;
                dut->storebit_dp1_i = 0;
                dut->dstvalid_dp1_i = 1;
                dut->dst_dp1_i = 3;

                //dp2
                dut->dp2_i = 1;
                dut->dp2_addr_i = 3;
                dut->pc_dp2_i = 0x100c;
                dut->storebit_dp2_i = 0;
                dut->dstvalid_dp2_i = 1;
                dut->dst_dp2_i = 4;

                //alu执行完成
                dut->finish_ex_alu1_i = 1;
                dut->finish_ex_alu1_addr_i = 0;
                dut->finish_ex_alu2_i = 1;
                dut->finish_ex_alu2_addr_i = 1;
                // ASSERT(dut->commit_ptr_1_o == 2,"when sim_time = {}, ERROR: commit_ptr_1_o should be equal to 2, but now commit_ptr_1_o = {}", sim_time, dut->commit_ptr_1_o);
                // ASSERT(dut->comnum_o == 2,"when sim_time = {}, ERROR: commit_num should be equal to 2", sim_time);
                // ASSERT(dut->store_commit_o ==0, "when sim_time = {},  ERROR: store_commit_o should be equal to 0", sim_time);
                // ASSERT(dut->arfwe_1_o == 1,"when sim_time = {}, ERROR: arfwe_1_o should be equal to 0", sim_time);
                // ASSERT(dut->arfwe_2_o == 1,"when sim_time = {}, ERROR: arfwe_2_o should be equal to 1", sim_time);
                // ASSERT(dut->dst_arf_1_o == 1,"when sim_time = {}, ERROR: dst_arf_1_o should be equal to 1", sim_time);
                // ASSERT(dut->dst_arf_2_o == 2,"when sim_time = {}, ERROR: dst_arf_2_o should be equal to 2", sim_time);

            }
            if(sim_time == 80) {
                dut->finish_ex_alu1_i = 1;
                dut->finish_ex_alu1_addr_i = 2;
                dut->finish_ex_alu2_i = 1;
                dut->finish_ex_alu2_addr_i = 3;

                // ASSERT(dut->commit_ptr_1_o == 4,"when sim_time ={}, ERROR: commit_ptr_1_o should be equal to 4", sim_time);
                // ASSERT(dut->comnum_o == 2,"when sim_time ={}, ERROR: commit_num  should be equal to 2", sim_time);
                // ASSERT(dut->store_commit_o ==0, "when sim_time = {},ERROR: store_commit_o should be equal to 0", sim_time);
                // ASSERT(dut->arfwe_1_o == 1,"when sim_time = {}, ERROR: arfwe_1_o should be equal to 1", sim_time);
                // ASSERT(dut->arfwe_2_o == 1,"when sim_time = {}, ERROR: arfwe_2_o should be equal to 1", sim_time);
                // ASSERT(dut->dst_arf_1_o == 3,"when sim_time = {}, ERROR: dst_arf_1_o should be equal to 3", sim_time);
                // ASSERT(dut->dst_arf_2_o == 4,"when sim_time = {}, ERROR: dst_arf_2_o should be equal to 4", sim_time);
            }
        }
            
        void verify_dut() {
           test4add();
        }
};




int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VROBTb> tb = std::make_shared<VROBTb>(5, 50, 600);

    tb->run("ROB.vcd");
}


