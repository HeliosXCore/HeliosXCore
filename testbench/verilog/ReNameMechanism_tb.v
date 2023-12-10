`include "../../rtl/consts/Consts.v"
`include "../../rtl/core/DP/SynRam.v"
`timescale 1ns / 1ps
module ReNameMechanism_tb;
    reg clk_i;
    reg   reset_i;
	
	reg [`REG_SEL-1:0] rs1_decoder_out_arf_in;
	reg [`REG_SEL-1:0] rs2_decoder_out_arf_in;
	wire [`DATA_LEN-1:0] rs1_arfdata_arf_out_srcopmanager_in;
	wire [`DATA_LEN-1:0] rs2_arfdata_arf_out_srcopmanager_in;
	wire rs1_arfbusy_arf_out_srcopmanager_in;
	wire rs2_arfbusy_arf_out_srcopmanager_in;
	wire [`RRF_SEL-1:0] rs1_arf_rrftag_arf_out_srcopmanagerANDrrf_in;
	wire [`RRF_SEL-1:0] rs2_arf_rrftag_arf_out_srcopmanagerANDrrf_in;  

	reg [`REG_SEL-1:0] completed_dstnum_rob_out_arf_in;
	wire [`DATA_LEN-1:0] from_rrfdata_rrf_out_arf_in;
	reg [`RRF_SEL-1:0] completed_dst_rrftag_rob_out_arfANDrrf_in;
	reg completed_we_rob_out_arf_in;

	reg [`REG_SEL-1:0] dstnum_setbusy_decoder_out_arf_in;
	reg dst_en_setbusy_decoder_out_arf_in;
	
	wire [`RRF_SEL-1:0] allocate_rrftag_AllocateRrfEntry_out_rrfANDarf_in;
  Arf arf(
	.clk_i(clk_i),
	.reset_i(reset_i),

	.rs1_i(rs1_decoder_out_arf_in),
	.rs2_i(rs2_decoder_out_arf_in),
	.rs1_arf_data_o(rs1_arfdata_arf_out_srcopmanager_in),
	.rs2_arf_data_o(rs2_arfdata_arf_out_srcopmanager_in),
	.rs1_arf_busy_o(rs1_arfbusy_arf_out_srcopmanager_in),
	.rs2_arf_busy_o(rs2_arfbusy_arf_out_srcopmanager_in),
	.rs1_arf_rrftag_o(rs1_arf_rrftag_arf_out_srcopmanagerANDrrf_in),
	.rs2_arf_rrftag_o(rs2_arf_rrftag_arf_out_srcopmanagerANDrrf_in),

	.completed_dst_num_i(completed_dstnum_rob_out_arf_in),
	.from_rrfdata_i(from_rrfdata_rrf_out_arf_in),
	.completed_dst_rrftag_i(completed_dst_rrftag_rob_out_arfANDrrf_in),
	.completed_we_i(completed_we_rob_out_arf_in),

	.dst_num_setbusy_i(dstnum_setbusy_decoder_out_arf_in),
	.dst_rrftag_setbusy_i(allocate_rrftag_AllocateRrfEntry_out_rrfANDarf_in),
	.dst_en_setbusy_i(dst_en_setbusy_decoder_out_arf_in)
  );

  
  wire [`DATA_LEN-1:0] rs1_rrfdata_rrf_out_srcopmanager_in;
  wire [`DATA_LEN-1:0] rs2_rrfdata_rrf_out_srcopmanager_in;
  wire rs1_rrfvalid_rrf_out_srcopmanager_in;
  wire rs2_rrfvalid_rrf_out_srcopmanager_in;


  reg forward_rrf_we_alu_out_rrf_in;
  reg [`RRF_SEL-1:0] forward_rrftag_RsAlu_out_rrf_in;
  reg [`DATA_LEN-1:0] forward_rrfdata_alu_out_rrf_in;  

  reg allocate_rrf_en_i;
  

  Rrf rrf(
	.clk_i(clk_i),
	.reset_i(reset_i),
	
	.rs1_rrftag_i(rs1_arf_rrftag_arf_out_srcopmanagerANDrrf_in),
	.rs2_rrftag_i(rs2_arf_rrftag_arf_out_srcopmanagerANDrrf_in),
	.rs1_rrfdata_o(rs1_rrfdata_rrf_out_srcopmanager_in),
	.rs2_rrfdata_o(rs2_rrfdata_rrf_out_srcopmanager_in),
	.rs1_rrfvalid_o(rs1_rrfvalid_rrf_out_srcopmanager_in),
	.rs2_rrfvalid_o(rs2_rrfvalid_rrf_out_srcopmanager_in),
	
	.forward_rrf_we_i(forward_rrf_we_alu_out_rrf_in),
	.forward_rrftag_i(forward_rrftag_RsAlu_out_rrf_in),
	.forward_rrfdata_i(forward_rrfdata_alu_out_rrf_in),

	.allocate_rrf_en_i(allocate_rrf_en_i),
	.allocate_rrftag_i(allocate_rrftag_AllocateRrfEntry_out_rrfANDarf_in),

	.completed_dst_rrftag_i(completed_dst_rrftag_rob_out_arfANDrrf_in),
	.data_to_arfdata_o(from_rrfdata_rrf_out_arf_in)
  );


  reg src_eq_zero_decoder_out_srcopmanager_in;
  wire [`DATA_LEN-1:0]src_srcopmanager_out_srcmanager_in;
  wire rdy_srcopmanager_out_srcmanager_in;

  SrcOprManager src_op_manager1(
	.arf_busy_i(rs1_arfbusy_arf_out_srcopmanager_in),
	.arf_data_i(rs1_arfdata_arf_out_srcopmanager_in),
	.arf_rrftag_i(rs1_arf_rrftag_arf_out_srcopmanagerANDrrf_in),
	.rrf_valid_i(rs1_rrfvalid_rrf_out_srcopmanager_in),
	.rrf_data_i(rs1_rrfdata_rrf_out_srcopmanager_in),
	.src_eq_zero_i(src_eq_zero_decoder_out_srcopmanager_in),
	.src_o(src_srcopmanager_out_srcmanager_in),
	.ready_o(rdy_srcopmanager_out_srcmanager_in)
  );


  reg [1:0] com_inst_num_rob_out_RrfEntryAllocate_in;
  reg stall_dp_i;

  wire rrf_allocatable_o;
  wire [`RRF_SEL:0] freenum_RrfEntryAllocate_out_rob_in;
  wire [`RRF_SEL-1:0] rrfptr_RrfEntryAllocate_out_rob_in;
  wire nextrrfcyc_o;
  
  RrfEntryAllocate rrf_alloc(
	.clk_i(clk_i),
	.reset_i(reset_i),
	.com_inst_num_i(com_inst_num_rob_out_RrfEntryAllocate_in),
	.stall_dp_i(stall_dp_i),
	.rrf_allocatable_o(rrf_allocatable_o),
	.freenum_o(freenum_RrfEntryAllocate_out_rob_in),
	.dst_rename_rrftag_o(allocate_rrftag_AllocateRrfEntry_out_rrfANDarf_in),
	.rrfptr_o(rrfptr_RrfEntryAllocate_out_rob_in),
	.nextrrfcyc_o(nextrrfcyc_o)
  );

  assign stall_dp_i = ~rrf_allocatable_o;


  initial begin
	clk_i = 0;
	reset_i = 0;
	rs1_decoder_out_arf_in = 0;
	rs2_decoder_out_arf_in = 0;

	completed_dstnum_rob_out_arf_in = 0;
	completed_dst_rrftag_rob_out_arfANDrrf_in= 0;
	completed_we_rob_out_arf_in  = 0;

	dstnum_setbusy_decoder_out_arf_in = 0;
	dst_en_setbusy_decoder_out_arf_in = 0;
	allocate_rrf_en_i = 0;

	forward_rrf_we_alu_out_rrf_in = 0;
	forward_rrftag_RsAlu_out_rrf_in = 0;
	forward_rrfdata_alu_out_rrf_in = 0;  

	src_eq_zero_decoder_out_srcopmanager_in = 0;
	
	com_inst_num_rob_out_RrfEntryAllocate_in = 0;
	stall_dp_i = 0;

	#20 reset_i = 1;
	#40 reset_i = 0;
	src_eq_zero_decoder_out_srcopmanager_in = 1;
	#40 dstnum_setbusy_decoder_out_arf_in = 1;
	dst_en_setbusy_decoder_out_arf_in = 1;
	allocate_rrf_en_i = 1;

	src_eq_zero_decoder_out_srcopmanager_in = 0;
	#40 forward_rrf_we_alu_out_rrf_in = 1;
	forward_rrftag_RsAlu_out_rrf_in = `RRF_SEL'd12;
	forward_rrfdata_alu_out_rrf_in = `DATA_LEN'd19;

	dstnum_setbusy_decoder_out_arf_in = 0;
	dst_en_setbusy_decoder_out_arf_in = 0;
	allocate_rrf_en_i = 0;
	#40 completed_dstnum_rob_out_arf_in = 1;
	completed_dst_rrftag_rob_out_arfANDrrf_in= `RRF_SEL'd12;
	completed_we_rob_out_arf_in = 1;
	com_inst_num_rob_out_RrfEntryAllocate_in = 1;

	forward_rrf_we_alu_out_rrf_in = 0;
	forward_rrftag_RsAlu_out_rrf_in = `RRF_SEL'd0;
	forward_rrfdata_alu_out_rrf_in = `DATA_LEN'd0;
	#40 rs1_decoder_out_arf_in = 1;
	rs2_decoder_out_arf_in = 2;

	completed_dstnum_rob_out_arf_in = 0;
	completed_dst_rrftag_rob_out_arfANDrrf_in= `RRF_SEL'd0;
	completed_we_rob_out_arf_in = 0;
	com_inst_num_rob_out_RrfEntryAllocate_in = 0;
  end
  
  always
	#20 clk_i = ~clk_i;


  initial begin
	#500 $stop;
  end

  initial begin
	forever @(posedge clk_i) #3 begin
	  $display("rs1_decoder_out_arf_in=%h\t, rs2_decoder_out_arf_in=%h\t, completed_dstnum_rob_out_arf_in=%h\t, completed_dst_rrftag_rob_out_arfANDrrf_in=%h\t, completed_we_rob_out_arf_in=%h\t, dstnum_setbusy_decoder_out_arf_in=%h\t, dst_en_setbusy_decoder_out_arf_in=%h\t, allocate_rrftag_AllocateRrfEntry_out_rrfANDarf_in=%h\t, forward_rrf_we_alu_out_rrf_in=%h\t, forward_rrftag_RsAlu_out_rrf_in=%h\t, forward_rrfdata_alu_out_rrf_in=%h\t, allocate_rrf_en_i=%h\t, src_eq_zero_decoder_out_srcopmanager_in=%h\t, src_srcopmanager_out_srcmanager_in=%h\t, rdy_srcopmanager_out_srcmanager_in=%h\t, com_inst_num_rob_out_RrfEntryAllocate_in=%h\t, stall_dp_i=%h\t, rrf_allocatable_o=%h\t, freenum_RrfEntryAllocate_out_rob_in=%h\t, rrfptr_RrfEntryAllocate_out_rob_in=%h\t, nextrrfcyc_o=%h\t",rs1_decoder_out_arf_in, rs2_decoder_out_arf_in, completed_dstnum_rob_out_arf_in, completed_dst_rrftag_rob_out_arfANDrrf_in, completed_we_rob_out_arf_in, dstnum_setbusy_decoder_out_arf_in, dst_en_setbusy_decoder_out_arf_in, allocate_rrftag_AllocateRrfEntry_out_rrfANDarf_in, forward_rrf_we_alu_out_rrf_in, forward_rrftag_RsAlu_out_rrf_in, forward_rrfdata_alu_out_rrf_in, allocate_rrf_en_i, src_eq_zero_decoder_out_srcopmanager_in, src_srcopmanager_out_srcmanager_in, rdy_srcopmanager_out_srcmanager_in, com_inst_num_rob_out_RrfEntryAllocate_in, stall_dp_i, rrf_allocatable_o, freenum_RrfEntryAllocate_out_rob_in, rrfptr_RrfEntryAllocate_out_rob_in, nextrrfcyc_o);
	end
  end
endmodule
