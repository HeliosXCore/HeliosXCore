`timescale 1ns / 1ps
`include "../../rtl/consts/Consts.v"

module Rrf_tb;
  reg clk_i;
  reg reset_i;


  reg [`RRF_SEL-1:0] rs1_rrftag_i;
  reg [`RRF_SEL-1:0] rs2_rrftag_i;
  wire [`DATA_LEN-1:0] rs1_rrfdata_o;
  wire [`DATA_LEN-1:0] rs2_rrfdata_o;
  wire rs1_rrfvalid_o;
  wire rs2_rrfvalid_o;


  reg forward_rrf_we_i;
  reg [`RRF_SEL-1:0] forward_rrftag_i;
  reg [`DATA_LEN-1:0] forward_rrfdata_i;  

  reg allocate_rrf_en_i;
  reg [`RRF_SEL-1:0] allocate_rrftag_i;
  
  reg [`RRF_SEL-1:0] completed_dst_rrftag_i;
  wire [`DATA_LEN-1:0] data_to_arfdata_o;


  Rrf rrf(
	.clk(clk_i),
	.reset(reset_i),
	
	.rs1_rrftag_i(rs1_rrftag_i),
	.rs2_rrftag_i(rs2_rrftag_i),
	.rs1_rrfdata_o(rs1_rrfdata_o),
	.rs2_rrfdata_o(rs2_rrfdata_o),
	.rs1_rrfvalid_o(rs1_rrfvalid_o),
	.rs2_rrfvalid_o(rs2_rrfvalid_o),
	
	.forward_rrf_we_i(forward_rrf_we_i),
	.forward_rrftag_i(forward_rrftag_i),
	.forward_rrfdata_i(forward_rrfdata_i),


	.allocate_rrf_en_i(allocate_rrf_en_i),
	.allocate_rrftag_i(allocate_rrftag_i),

	.completed_dst_rrftag_i(completed_dst_rrftag_i),
	.data_to_arfdata_o(data_to_arfdata_o)

  );

  initial begin
	clk_i = 0;
	// 测试写
	forward_rrf_we_i = 1'b1;
	forward_rrftag_i = `RRF_SEL'b0;
	forward_rrfdata_i = `DATA_LEN'b1;

	allocate_rrf_en_i = 1'b1;
	allocate_rrftag_i = `RRF_SEL'b1;

  end


  always
	#20 clk_i = ~clk_i;


  initial begin
	#500 $stop;
  end

  initial begin
	forever @(posedge clk_i) #3 begin
	  $display("forward_rrf_we_i=%h\t, forward_rrftag_i=%h\t, forward_rrfdata_i=%h\t, allocate_rrf_en_i=%h\t, allocate_rrftag_i=%h\t",
		clk_i,forward_rrf_we_i,forward_rrftag_i,forward_rrfdata_i,allocate_rrf_en_i,allocate_rrftag_i);
	end
  end

endmodule

