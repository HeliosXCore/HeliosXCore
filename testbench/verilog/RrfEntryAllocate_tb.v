`timescale 1ns / 1ps
`include "../../rtl/consts/Consts.v"

module RrfEntryAllocate_tb;
  reg clk_i;
  reg reset_i;

  reg [1:0] com_inst_num_i;
  reg stall_dp_i;

  wire rrf_allocatable_o;
  wire [`RRF_SEL:0] freenum_o;
  wire [`RRF_SEL-1:0] dst_rename_rrftag_o;
  wire [`RRF_SEL-1:0] rrfptr_o;
  wire nextrrfcyc_o;
  
  RrfEntryAllocate rrf_alloc(
	.clk_i(clk_i),
	.reset_i(reset_i),
	.com_inst_num_i(com_inst_num_i),
	.stall_dp_i(stall_dp_i),
	.rrf_allocatable_o(rrf_allocatable_o),
	.freenum_o(freenum_o),
	.dst_rename_rrftag_o(dst_rename_rrftag_o),
	.rrfptr_o(rrfptr_o),
	.nextrrfcyc_o(nextrrfcyc_o)
  );

  assign stall_dp_i = ~rrf_allocatable_o;

  initial begin
	clk_i = 0;
	reset_i = 0;
	com_inst_num_i = 0;
	stall_dp_i = 0;
	#20 reset_i = 1;
	#40 reset_i = 0;
	com_inst_num_i = 2'd2;
	#40 com_inst_num_i = 2'd2;
	#40 com_inst_num_i = 1;
	#40 com_inst_num_i = 1;
	#40 com_inst_num_i = 2'd2;
	#40 com_inst_num_i = 1;
	#40 com_inst_num_i = 0;
	#40 com_inst_num_i = 0;
	#40 com_inst_num_i = 0;
	#40 com_inst_num_i = 0;
	#40 com_inst_num_i = 2;
  end

  always
	#20 clk_i = ~clk_i;

  initial begin
	#500 $stop;
  end

  initial begin
	forever @(posedge clk_i) #3 begin
	  $display("com_inst_num_i=%h\t, stall_dp_i=%h\t, rrf_allocatable_o=%h\t, freenum_o=%h\t, dst_rename_rrftag_o=%h\t, rrfptr_o=%h\t, nextrrfcyc_o=%h\t",
		com_inst_num_i,stall_dp_i,rrf_allocatable_o,freenum_o,dst_rename_rrftag_o,rrfptr_o,nextrrfcyc_o);
	end
  end

endmodule

