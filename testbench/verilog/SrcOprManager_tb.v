`timescale 1ns / 1ps
`include "../../rtl/consts/Consts.v"

module SrcOprManager_tb;
  reg arf_busy_i;
  reg [`DATA_LEN-1:0] arf_data_i;
  reg rrf_valid_i;
  reg [`DATA_LEN-1:0] rrf_data_i;
  reg src_eq_zero_i;
  wire [`DATA_LEN-1:0]src_o;
  wire rdy_o;

  SrcOprManager src_op_manager(
	.arf_busy_i(arf_busy_i),
	.arf_data_i(arf_data_i),
	.rrf_valid_i(rrf_valid_i),
	.rrf_data_i(rrf_data_i),
	.src_eq_zero_i(src_eq_zero_i),
	.src_o(src_o),
	.rdy_o(rdy_o)
  );

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

