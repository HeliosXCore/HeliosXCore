`timescale 1ns / 1ps
`include "../../rtl/consts/Consts.v"

module SrcOprManager_tb;
  reg clk;

  reg arf_busy_i;
  reg [`DATA_LEN-1:0] arf_data_i;
  reg [`RRF_SEL-1:0] arf_rrftag_i;
  reg rrf_valid_i;
  reg [`DATA_LEN-1:0] rrf_data_i;
  reg src_eq_zero_i;
  wire [`DATA_LEN-1:0]src_o;
  wire rdy_o;

  SrcOprManager src_op_manager(
	.arf_busy_i(arf_busy_i),
	.arf_data_i(arf_data_i),
	.arf_rrftag_i(arf_rrftag_i),
	.rrf_valid_i(rrf_valid_i),
	.rrf_data_i(rrf_data_i),
	.src_eq_zero_i(src_eq_zero_i),
	.src_o(src_o),
	.rdy_o(rdy_o)
  );

  initial begin
	clk = 0;
	#20	arf_busy_i = 0;
	arf_data_i = `DATA_LEN'd2;
	arf_rrftag_i = 0;
	rrf_valid_i = 0;
	rrf_data_i = 0;
	src_eq_zero_i = 0;
	#40 arf_busy_i = 1;
	arf_rrftag_i = 1;
	rrf_valid_i = 0;
	#40 arf_busy_i = 1;
	arf_rrftag_i = 1;
	rrf_valid_i = 1;
	rrf_data_i = `DATA_LEN'd2;
	#40 arf_busy_i = 0;
	src_eq_zero_i = 1;
  end

  always
	#20 clk = ~clk;

  initial begin
	#500 $stop;
  end

  initial begin
	forever @(posedge clk) #3 begin
	  $display("arf_busy_i=%h\t, arf_data_i=%h\t,arf_rrftag_i=%h\t, rrf_valid_i=%h\t, rrf_data_i=%h\t, src_eq_zero_i=%h\t, src_o=%h\t ,rdy_o=%h\t",
		arf_busy_i,arf_data_i,arf_rrftag_i,rrf_valid_i,rrf_data_i,src_eq_zero_i,src_o,rdy_o);
	end
  end

endmodule

