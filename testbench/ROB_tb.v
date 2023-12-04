`include "../rtl/consts/Consts.v"
module ROB_tb();
    reg clk;
    reg reset;
    reg dp1_i;
    reg [`ROB_SEL-1:0] dp1_addr_i;
    reg finish_ex_alu1_i;
    reg [`RRF_SEL-1:0] ex_alu1_addr_i;
    reg [`REG_SEL-1:0] dst_dp1_i;
    reg isValid_dst_dp1_i;

    wire [`ROB_SEL-1:0] commit_ptr_1_o;
    wire arfwe_1_o;
    wire [`REG_SEL-1:0] dst_arf_1_o;

    // 实例化ROB
    ROB dut (
        .clk(clk),
        .reset(reset),
        .dp1_i(dp1_i),
        .dp1_addr_i(dp1_addr_i),
        .finish_ex_alu1_i(finish_ex_alu1_i),
        .ex_alu1_addr_i(ex_alu1_addr_i),
        .dst_dp1_i(dst_dp1_i),
        .isValid_dst_dp1_i(isValid_dst_dp1_i),
        .commit_ptr_1_o(commit_ptr_1_o),
        .arfwe_1_o(arfwe_1_o),
        .dst_arf_1_o(dst_arf_1_o)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
                $dumpfile("ROB_tb.vcd");    //生成的vcd文件名称
                $dumpvars(0, ROB_tb);       //要记录的信号  0代表所有
            end
 
    initial begin
        reset = 1;
        dp1_i = 0;
        dp1_addr_i = 0;
        finish_ex_alu1_i = 0;
        ex_alu1_addr_i = 0;
        dst_dp1_i = 0;
        isValid_dst_dp1_i = 0;

        #10 reset = 0; 


        #20 dp1_i = 1;
        #5 dp1_addr_i = 3;
        #5 finish_ex_alu1_i = 1;
        #5 ex_alu1_addr_i = 3;
        #5 dst_dp1_i = 5;
        #5 isValid_dst_dp1_i = 1;


        #20 dp1_i = 1;
        #5 dp1_addr_i = 4;
        #5 finish_ex_alu1_i = 1;
        #5 ex_alu1_addr_i = 4;
        #5 dst_dp1_i = 6;
        #5 isValid_dst_dp1_i = 1;

 

        #100 $stop;
  end

endmodule
