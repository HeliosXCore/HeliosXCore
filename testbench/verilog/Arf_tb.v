`timescale 1ns / 1ps
`include "../../rtl/consts/Consts.v"

module Arf_tb;
  reg clk_i;
  reg reset_i;

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
	.clk_i(clk_i),
	.reset_i(reset_i),

	.rs1_i(rs1_i),
	.rs2_i(rs2_i),
	.rs1_arf_data_o(rs1_arf_data_o),
	.rs2_arf_data_o(rs2_arf_data_o),
	.rs1_arf_busy_o(rs1_arf_busy_o),
	.rs2_arf_busy_o(rs2_arf_busy_o),
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
	rs1_i = 0;
	rs2_i = 0;
	completed_dst_num_i = 0;
	from_rrfdata_i = 0;
	completed_dst_rrftag_i = 0;
	completed_we_i = 0;
	dst_num_setbusy_i = 0;
	dst_rrftag_setbusy_i = 0;
	dst_en_setbusy_i = 0;
	#20 reset_i = 1;
	#40 reset_i = 0;
	dst_num_setbusy_i = `REG_SEL'd1;
	dst_rrftag_setbusy_i = `RRF_SEL'd12;
	dst_en_setbusy_i = 1;
	#40 
	dst_num_setbusy_i = `REG_SEL'd2;
	dst_rrftag_setbusy_i = `RRF_SEL'd13;
	dst_en_setbusy_i = 1;
	#40 
	completed_we_i = 1;
	completed_dst_num_i = `REG_SEL'd1;
	from_rrfdata_i = `DATA_LEN'd14;
	completed_dst_rrftag_i = `RRF_SEL'd12;
	#40 completed_we_i = 1;
	completed_dst_num_i = `REG_SEL'd2;
	from_rrfdata_i = `DATA_LEN'd15;
	completed_dst_rrftag_i = `RRF_SEL'd13;
	#40 completed_we_i = 1;
	completed_dst_num_i = `REG_SEL'd2;
	from_rrfdata_i = `DATA_LEN'd16;
	completed_dst_rrftag_i = `RRF_SEL'd12;
	#40 rs1_i = `REG_SEL'd1;
	rs2_i = `REG_SEL'd2;
  end


  always
	#20 clk_i = ~clk_i;


  initial begin
	#500 $stop;
  end

  initial begin
	forever @(posedge clk_i) #3 begin
	  $display("reset_i = %h\t, rs1_i=%h\t, rs2_i=%h\t, rs1_arf_data_o=%h\t, rs2_arf_data_o=%h\t, rs1_arf_busy_o=%h\t, rs2_arf_busy_o=%h\t, rs1_arf_rrftag_o=%h\t, rs2_arf_rrftag_o=%h\t, completed_dst_num_i=%h\t, from_rrfdata_i=%h\t, completed_dst_rrftag_i=%h\t, completed_we_i=%h\t, dst_num_setbusy_i=%h\t, dst_rrftag_setbusy_i=%h\t, dst_en_setbusy_i\t",
		reset_i,rs1_i, rs2_i,rs1_arf_data_o,rs2_arf_data_o,rs1_arf_busy_o,rs2_arf_busy_o,rs1_arf_rrftag_o,rs2_arf_rrftag_o,completed_dst_num_i,from_rrfdata_i,completed_dst_rrftag_i,completed_we_i,dst_num_setbusy_i,dst_rrftag_setbusy_i,dst_en_setbusy_i);
	end
  end

endmodule

