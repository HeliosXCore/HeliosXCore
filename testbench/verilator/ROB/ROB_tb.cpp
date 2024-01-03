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
        void test1(){
            if(sim_time == 50) {
                dut->dp1_i = 1;
                dut->dp1_addr_i = 0;
                dut->pc_dp1_i = 0x1000;
                dut->storebit_dp1_i = 0;
                dut->dstvalid_dp1_i = 0;
                dut->dst_dp1_i = 1;

                dut->dp2_i = 1;
                dut->dp2_addr_i = 1;
                dut->pc_dp2_i = 0x1004;
                dut->storebit_dp2_i = 0;
                dut->dstvalid_dp2_i = 1;
                dut->dst_dp2_i = 2;
            }
            if(sim_time == 60) {
                //dp
                dut->dp1_i = 1;
                dut->dp1_addr_i = 2;
                dut->pc_dp1_i = 0x1008;
                dut->dp2_i = 1;
                dut->dp2_addr_i = 3;
                dut->pc_dp2_i = 0x100c;

                //alu执行完成
                dut->finish_ex_alu1_i = 1;
                dut->finish_ex_alu1_addr_i = 0;
                dut->finish_ex_alu2_i = 1;
                dut->finish_ex_alu2_addr_i = 1;
                ASSERT(dut->commit_ptr_1_o == 2,"ERROR:commit_ptr_1_o occur error!!");
                ASSERT(dut->comnum_o == 2,"ERROR: commit_num occur error!!");
                ASSERT(dut->store_commit_o ==0, "ERROR:store_commit_o occur error!!");
                ASSERT(dut->arfwe_1_o == 0,"arfwe_1_o occur error!!");
                ASSERT(dut->arfwe_2_o == 1,"arfwe_2_o occur error!!");
                ASSERT(dut->dst_1_o == 1,"dst_1_o occur error!!");
                ASSERT(dut->dst_2_o == 2,"dst_2_o occur error!!");

            }
        }
            

        
        // int count = 1;
        void verify_dut() {
           
        }
};




int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VROBTb> tb = std::make_shared<VROBTb>(5, 50, 600);

    tb->run("ROB.vcd");
}


