#include <memory>

template <class DUT>
class VerilatorTb {
   public:
    std::size_t sim_time;
    std::size_t posedge_cnt;
    std::shared_ptr<DUT> dut;
    VerilatorTb(std::shared_ptr<DUT> dut) : dut(dut) {
        sim_time = 0;
        posedge_cnt = 0;
    }
    ~VerilatorTb() {}
    virtual void reset_dut();
    virtual void eval() { dut->eval(); }

    virtual void tick() {
        dut->clk_i ^= 1;
        eval();
        sim_time++;
    }
};