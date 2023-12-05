`include "../../consts/Consts.v"

// 暂时不考虑分支预测的话，每个时钟周期都会分配一个rrf entry
module RrfEntryAllocate(
  input wire clk,
  input wire reset,

  // COM阶段提交的指令的数量
  input wire [1:0] com_inst_num_i,
	
  // 前一周期的DP是否成功，也即为目的寄存器分配free rrf entry是否成功了
  input wire stall_dp_i,
  
  output wire rrf_allocatable_o,
  output reg [`RRF_SEL:0] freenum_o,
  output wire [`RRF_SEL-1:0] dst_rename_rrftag_o,
  output reg [`RRF_SEL-1:0] rrfptr_o,
  output reg 		      nextrrfcyc_o
);
  
  wire [1:0] reqnum = 1;
  
  wire [`RRF_SEL-1:0] 	      rrfptr_next = (rrfptr_o + reqnum)%`RRF_NUM;

  assign rrf_allocatable_o = (freenum_o + com_inst_num_i) < reqnum ? 1'b0 : 1'b1;

  // TODO:在DP阶段stall以后，这里难道还是可以正常赋值吗？
  assign dst_rename_rrftag_o = rrfptr_o;

  always @(posedge clk)begin
	if(reset)begin
	  freenum_o <= `RRF_NUM;
	  rrfptr_o <= 0;
	  nextrrfcyc_o <= 0;
	end else if(stall_dp_i) begin
	  rrfptr_o <= rrfptr_o;
	  freenum_o <= freenum_o + com_inst_num_i;
	  nextrrfcyc_o <= 0;
	end else begin
	  freenum_o <= freenum_o+com_inst_num_i-reqnum;
	  rrfptr_o <= rrfptr_next ;
	  nextrrfcyc_o <= (rrfptr_o>rrfptr_next) ? 1'b1 : 1'b0;
	end
  end
endmodule
