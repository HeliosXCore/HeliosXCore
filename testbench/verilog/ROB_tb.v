`timescale 1ns / 1ps
`include "consts/Consts.v"
module ROB_tb();
    reg clk_i;
    reg reset_i;
    reg 			  dp1_i;                                     //是否发射
    reg [`RRF_SEL-1:0] 	  dp1_addr_i;                        //第一条发射的指令在ROB的地址
    reg [`INSN_LEN-1:0] 	  pc_dp1_i;
    reg 			  storebit_dp1_i;
    reg 			  dstvalid_dp1_i;
    reg [`REG_SEL-1:0] 	  dst_dp1_i;
    reg [`GSH_BHR_LEN-1:0]  bhr_dp1_i;
    reg 			  isbranch_dp1_i;
    reg 			  dp2_i;
    reg [`RRF_SEL-1:0] 	  dp2_addr_i;
    reg [`INSN_LEN-1:0] 	  pc_dp2_i;
    reg 			  storebit_dp2_i;
    reg 			  dstvalid_dp2_i;
    reg [`REG_SEL-1:0] 	  dst_dp2_i;
    reg [`GSH_BHR_LEN-1:0]  bhr_dp2_i;
    reg 			  isbranch_dp2_i;
    reg               finish_ex_alu1_i;                                    //alu1单元是否执行完成
    reg [`RRF_SEL-1:0] finish_ex_alu1_addr_i;                              //alu1执行完成的指令在ROB的地址
    reg 			  finish_ex_alu2_i;
    reg [`RRF_SEL-1:0] 	  finish_ex_alu2_addr_i;
    reg 			  finish_ex_mul_i;
    reg [`RRF_SEL-1:0] 	  finish_ex_mul_addr_i;
    reg 			  finish_ex_ldst_i;
    reg [`RRF_SEL-1:0] 	  finish_ex_ldst_addr_i;
    reg 			  finish_ex_branch_i;
    reg [`RRF_SEL-1:0] 	  finish_ex_branch_addr_i;
    reg 			  finish_ex_branch_brcond_i;
    reg [`ADDR_LEN-1:0]   finish_ex_branch_jmpaddr_i;
    reg [`RRF_SEL-1:0] dispatch_ptr_i;
    reg [`RRF_SEL-1:0] rrf_freenum_i;
    // reg prmiss_i;

    wire [`ROB_SEL-1:0] commit_ptr_1_o;
    wire [`ROB_SEL-1:0] commit_ptr_2_o;
    wire [1:0] comnum_o;
    wire store_commit_o;
    wire arfwe_1_o;
    wire arfwe_2_o;
    wire [`REG_SEL-1:0] dst_arf_1_o;
    wire [`REG_SEL-1:0] dst_arf_2_o;
    wire [`ADDR_LEN-1:0] pc_combranch_o;
    wire [`GSH_BHR_LEN-1:0] bhr_combranch_o;
    wire [`ADDR_LEN-1:0] jmpaddr_combranch_o;
    wire brcond_combranch_o;
    wire combranch_o;

    // 实例化ROB
    ROB dut (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .dp1_i(dp1_i),
        .dp1_addr_i(dp1_addr_i),
        .pc_dp1_i(pc_dp1_i),
        .storebit_dp1_i(storebit_dp1_i),
        .dstvalid_dp1_i(dstvalid_dp1_i),
        .dst_dp1_i(dst_dp1_i),
        .bhr_dp1_i(bhr_dp1_i),
        .isbranch_dp1_i(isbranch_dp1_i),
        .dp2_i(dp2_i),
        .dp2_addr_i(dp2_addr_i),
        .pc_dp2_i(pc_dp2_i),
        .storebit_dp2_i(storebit_dp2_i),
        .dstvalid_dp2_i(dstvalid_dp2_i),
        .dst_dp2_i(dst_dp2_i),
        .bhr_dp2_i(bhr_dp2_i),
        .isbranch_dp2_i(isbranch_dp2_i),
        .finish_ex_alu1_i(finish_ex_alu1_i),
        .finish_ex_alu1_addr_i(finish_ex_alu1_addr_i),
        .finish_ex_alu2_i(finish_ex_alu2_i),
        .finish_ex_alu2_addr_i(finish_ex_alu2_addr_i),
        .finish_ex_mul_i(finish_ex_mul_i),
        .finish_ex_mul_addr_i(finish_ex_mul_addr_i),
        .finish_ex_ldst_i(finish_ex_ldst_i),
        .finish_ex_ldst_addr_i(finish_ex_ldst_addr_i),
        .finish_ex_branch_i(finish_ex_branch_i),
        .finish_ex_branch_addr_i(finish_ex_branch_addr_i),
        .finish_ex_branch_brcond_i(finish_ex_branch_brcond_i),
        .finish_ex_branch_jmpaddr_i(finish_ex_branch_jmpaddr_i),
        .dispatch_ptr_i(dispatch_ptr_i),
        .rrf_freenum_i(rrf_freenum_i),
        // .prmiss_i(prmiss_i),

        .commit_ptr_1_o(commit_ptr_1_o),
        .commit_ptr_2_o(commit_ptr_2_o),
        .comnum_o(comnum_o),
        .store_commit_o(store_commit_o),
        .arfwe_1_o(arfwe_1_o),
        .arfwe_2_o(arfwe_2_o),
        .dst_arf_1_o(dst_arf_1_o),
        .dst_arf_2_o(dst_arf_2_o),
        .pc_combranch_o(pc_combranch_o),
        .bhr_combranch_o(bhr_combranch_o),
        .jmpaddr_combranch_o(jmpaddr_combranch_o),
        .brcond_combranch_o(brcond_combranch_o),
        .combranch_o(combranch_o)
    );

    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end

    initial begin
                $dumpfile("ROB_tb.vcd");    //生成的vcd文件名称
                $dumpvars(0, ROB_tb);       //要记录的信号  0代表所有
            end
 
    initial begin
        reset_i = 1;
        dp1_i = 0;
        dp1_addr_i = 0;
        pc_dp1_i = 0;
        storebit_dp1_i = 0;
        dstvalid_dp1_i = 0;
        dst_dp1_i = 0;
        bhr_dp1_i = 0;
        isbranch_dp1_i = 0;

        dp2_i = 0;
        dp2_addr_i = 0;
        pc_dp2_i = 0;
        storebit_dp1_i = 0;
        dstvalid_dp2_i = 0;
        dst_dp2_i = 0;
        bhr_dp2_i = 0;
        isbranch_dp2_i = 0;


        #10 reset_i = 0; 


        #20 dp1_i = 1;
            dp1_addr_i = 0;
            dst_dp1_i[dp1_addr_i] = 1;                

        #5 finish_ex_alu1_i = 1;
            finish_ex_alu1_addr_i = dp1_addr_i;


        #100 $stop;
        $finish();
    end

endmodule
