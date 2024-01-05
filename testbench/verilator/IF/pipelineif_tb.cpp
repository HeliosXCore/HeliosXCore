#include "verilator_tb.hpp"
#include "VPipelineIF.h"
#include "VPipelineIF___024root.h"
#include "error_handler.hpp"
#include <iostream>
#include <verilated.h>


#define MAX_SIM_TIME 300
vluint64_t sim_time = 0;


template<>
void  VerilatorTb<VPipelineIF>::initialize_signal(){
    dut->clk_i = 0;
    dut->reset_i = 1; 
    dut->pc_i = 0;
    dut->idata_i = 0;
};



class VPipelineIFTb : public VerilatorTb<VPipelineIF> {
    public:
        VPipelineIFTb(uint64_t clock, uint64_t start_time, uint64_t end_time)
            : VerilatorTb<VSingleInstROB>(clock, start_time, end_time) {}
        
        void if_test(){
            //int pc = 0x000f4048;
            while(sim_time < MAX_SIM_TIME){
                dut->eval();

                if(sim_time == 5){
                    dut->pc_i = 0x000f4048;
                    dut->idata_i = 0x0000000526300100ffdff06f00202423;
                }
                if(sim_time == 6){
                    assert(dut->npc_o==0x000f404c);
                    assert(dut->inst1_o==0x26300100);
                    std::cout << "PipelineIF Test 1 Pass!" << std::endl;
                }

                if(sim_time == 7){
                    dut->pc_i = 0x000f2620;
                    dut->idata_i = 0x0000000526300100ffdff06fc2804365;
                }
                if(sim_time == 8){
                    assert(dut->npc_o==0x000f2624);
                    assert(dut->inst1_o==0xc2804365);
                    std::cout << "PipelineIF Test 2 Pass!" << std::endl;
                }

                if(sim_time == 9){
                    dut->pc_i = 0x000f0717;
                    dut->idata_i = 0x0000000526300100ffdff06f00202423;
                }
                if(sim_time == 10){
                    assert(dut->npc_o==0x000f071b);
                    assert(dut->inst1_o==0xffdff06f);
                    std::cout << "PipelineIF Test 3 Pass!" << std::endl;
                }
                sim_time++;

            }

        }
        // int count = 1;
        void verify_dut() {
            if_test();
            // fmt::println("count execute:{} times", count);
            // count++;
            // fmt::println("Full Test Pass!");
        }
};




int main(int argc, char **argv, char **env) {
    srand(time(NULL));
    Verilated::commandArgs(argc, argv);

    std::shared_ptr<VPipelineIFTb> tb = std::make_shared<VPipelineIFTb>(1, 0, 200);

    tb->run("PipelineIF.vcd");
}
