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



class VROBTb : public VerilatorTb<VROB> {
    public:
        VROBTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
            : VerilatorTb<VROB>(clock, start_time, end_time) {}
        

        //填满ROB，并执行
        void full_test(){
            //ROB的地址
            int dp_addr = 0;

            //从50时间单位开始，开始发射指令，与此同时占据一个ROB的entry，entry从0开始。
            //接下来每隔10个时间单位发射。直到占满ROB所有128个entry。
            for(int i = 50; i <= 1340; i=i+10) {               
                if(sim_time == i) {
                    dut->dp1_i = 1;
                    dut->dp1_addr_i = dp_addr;
                    dp_addr++;
                }
            }
            int finish_addr = 0;

            //从60时间单位开始，执行单元执行完毕后，将指令的地址写入finish_ex_alu1_addr_i，
            for(int i = 60; i <= 650; i=i+10) {
                if(sim_time == i) {
                    dut->finish_ex_alu1_i = 1;
                    dut->finish_ex_alu1_addr_i = finish_addr;
                    ASSERT(dut->commit_ptr_1_o == finish_addr,"ERROR:when sim_time is {},Expected commit_ptr_o == {}",i,finish_addr);
                }
            }

            

        }
        // int count = 1;
        void verify_dut() {
            full_test();
            // fmt::println("count execute:{} times", count);
            // count++;
            // fmt::println("Full Test Pass!");
        }
};




int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VROBTb> tb = std::make_shared<VROBTb>(5, 50, 2000);

    tb->run("ROB.vcd");
}


