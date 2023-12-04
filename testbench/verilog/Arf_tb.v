`timescale 1ns / 1ps
`include "../../rtl/consts/Consts.v"

module Arf_tb;
  reg clk;
  reg reset;

  reg [`REG_SEL-1:0] rs1_i;
  reg [`REG_SEL-1:0] rs2_i;
  wire [`DATA_LEN-1:0] rs1_arf_data_o;
  wire [`DATA_LEN-1:0] rs2_arf_data_o;
  wire     rs1_arf_busy_o;
  wire     rs2_arf_busy_o;
  wire [`RRF_SEL-1:0] rs1_arf_rrftag_o;
  wire [`RRF_SEL-1:0] rs2_arf_rrftag_o;  


  reg [`REG_SEL-1:0] completed_dst_num_i;
  reg [`DATA_LEN-1:0] from_rrfdata_i;
  reg [`RRF_SEL-1:0] completed_dst_rrftag_i;
  reg completed_we_i;

  reg [`REG_SEL-1:0] dst_num_setbusy_i;
  reg [`RRF_SEL-1:0] dst_rrftag_setbusy_i;
  reg dst_en_setbusy_i;

  Arf arf(
	.clk(clk),
	.reset(reset),

	.rs1_i(rs1_i),
	.rs2_i(rs2_i),
	.rs1_arf_data_o(rs1_arf_data_o),
	.rs2_arf_data_o(rs2_arf_data_o),
	.rs1_arf_busy_o(rs1_arf_busy_o),
	.rs1_arf_rrftag_o(rs1_arf_rrftag_o),
	.rs2_arf_rrftag_o(rs2_arf_rrftag_o),

	.completed_dst_num_i(completed_dst_num_i),
	.from_rrfdata_i(from_rrfdata_i),
	.completed_dst_rrftag_i(completed_dst_rrftag_i),
	.completed_we_i(completed_we_i),

	.dst_num_setbusy_i(dst_num_setbusy_i),
	.dst_rrftag_setbusy_i(dst_rrftag_setbusy_i),
	.dst_en_setbusy_i(dst_en_setbusy_i)
  );

  initial begin
	clk_i = 0;

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

