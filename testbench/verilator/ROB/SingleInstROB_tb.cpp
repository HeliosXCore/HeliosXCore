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
        

        //填满ROB，并执行
        void full_test(){
            //ROB的地址
            int dp_addr = 0;
            for(int i = 50; i <= 640; i=i+5){               
                if(sim_time == i){
                    dut->dp1_i = 1;
                    dut->dp1_addr_i = dp_addr;
                    dp_addr++;
                }
            }
            int finish_addr = 0;  
            for(int i = 60; i <= 650; i=i+5){
                if(sim_time == i){
                    dut->finish_ex_alu1_i = 1;
                    dut->finish_ex_alu1_addr_i = finish_addr;
                    ASSERT(dut->commit_ptr_1_o == finish_addr,"ERROR:when sim_time is {},Expected commit_ptr_o == {}",i,finish_addr);
                    i++;
                }
            }

            

        }
        int count = 1;
        void verify_dut() {
            full_test();
            fmt::println("count execute:{} times", count);
            count++;
            fmt::println("Full Test Pass!");
        }
};




int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VSingleInstROBTb> tb = std::make_shared<VSingleInstROBTb>(5, 50, 1000);

    tb->run("SingleInstROB.vcd");
}


