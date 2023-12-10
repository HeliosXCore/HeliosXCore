`timescale 1ns / 1ps
`include "consts/Consts.v"
module tb_ROB;

  // 输入信号
  reg clk;
  reg reset;
  reg dp1_i;
  reg [RRF_SEL-1:0] dp1_addr_i;
  reg [INSN_LEN-1:0] pc_dp1_i;
  reg dstvalid_dp1_i;
  reg [REG_SEL-1:0] dst_dp1_i;
  reg finish_ex_alu1_i;
  reg [RRF_SEL-1:0] finish_ex_alu1_addr_i;

  // 输出信号
  wire [ROB_SEL-1:0] commit_ptr_1_o;
  wire arfwe_1_o;
  wire [REG_SEL-1:0] dst_arf_1_o;

  // 实例化被测模块
  ROB uut (
    .clk(clk),
    .reset(reset),
    .dp1_i(dp1_i),
    .dp1_addr_i(dp1_addr_i),
    .pc_dp1_i(pc_dp1_i),
    .dstvalid_dp1_i(dstvalid_dp1_i),
    .dst_dp1_i(dst_dp1_i),
    .finish_ex_alu1_i(finish_ex_alu1_i),
    .finish_ex_alu1_addr_i(finish_ex_alu1_addr_i),
    .commit_ptr_1_o(commit_ptr_1_o),
    .arfwe_1_o(arfwe_1_o),
    .dst_arf_1_o(dst_arf_1_o)
  );

  // 初始化测试环境
  initial begin
    // 添加时钟脉冲
    clk = 0;
    forever #5 clk = ~clk;

    // 初始化输入信号
    reset = 1;
    dp1_i = 0;
    dp1_addr_i = 0;
    pc_dp1_i = 0;
    dstvalid_dp1_i = 0;
    dst_dp1_i = 0;
    finish_ex_alu1_i = 0;
    finish_ex_alu1_addr_i = 0;

      initial begin
                $dumpfile("ROB_tb.vcd");    //生成的vcd文件名称
                $dumpvars(0, ROB_tb);       //要记录的信号  0代表所有
            end




    // 激活时钟
    #10 reset = 0;
    #5  dp1_i = 1;
        dp1_addr_i = 0;
        dst_dp1_i[dp1_addr_i] = 1;
    #5  finish_ex_alu1_i = 1;
        finish_ex_alu1_addr_i = dp1_addr_i;
    
    #100 $finish;
  end

endmodule
