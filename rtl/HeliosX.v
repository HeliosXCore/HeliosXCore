`include "consts/Consts.vh"
module HeliosX (
    input wire clk_i,
    input wire reset_i,

    output reg [`ADDR_LEN-1:0] pc_o,

    input wire [4*`INSN_LEN-1:0] idata_i,

    output wire [`DATA_LEN-1:0]  dmem_wdata_o,
    output wire    dmem_we_o,
    output wire [`ADDR_LEN-1:0]  dmem_addr_o,

    input wire [`DATA_LEN-1:0] dmem_data_i
);

    wire [     `REG_SEL-1:0] rs1_decoder_out_arf_in;
    wire [     `REG_SEL-1:0] rs2_decoder_out_arf_in;

    wire                     stall_dp;

    wire                     rrf_allocatable;
    wire [       `RRF_SEL:0] freenum_RrfEntryAllocate_out_rob_in;
    wire [     `RRF_SEL-1:0] rrfptr_RrfEntryAllocate_out_rob_in;
    wire                     nextrrfcyc_RrfEntryAllocate_out_RsAlu_in;

    wire [              1:0] com_inst_num_rob_out_RrfEntryAllocate_in;
    wire [     `REG_SEL-1:0] completed_dstnum_rob_out_arf_in;
    wire                     completed_we_rob_out_arf_in;
    wire [     `RRF_SEL-1:0] completed_dst_rrftag_rob_out_arfANDrrf_in;

    wire [     `REG_SEL-1:0] dstnum_setbusy_decoder_out_arf_in;
    wire                     dst_en_setbusy_decoder_out_arf_in;

    wire                     forward_rrf_we_alu1_out_rrf_in;
    wire [     `RRF_SEL-1:0] forward_rrftag_RsAlu1_out_rrf_in;
    wire [    `DATA_LEN-1:0] forward_rrfdata_alu1_out_rrf_in;

    wire                     forward_rrf_we_alu2_out_rrf_in;
    wire [     `RRF_SEL-1:0] forward_rrftag_RsAlu2_out_rrf_in;
    wire [    `DATA_LEN-1:0] forward_rrfdata_alu2_out_rrf_in;


    wire                     forward_rrf_we_ldst_out_rrf_in;
    wire [     `RRF_SEL-1:0] forward_rrftag_RsLdst_out_rrf_in;
    wire [    `DATA_LEN-1:0] forward_rrfdata_ldst_out_rrf_in;


    wire                     forward_rrf_we_mul_out_rrf_in;
    wire [     `RRF_SEL-1:0] forward_rrftag_RsMul_out_rrf_in;
    wire [    `DATA_LEN-1:0] forward_rrfdata_mul_out_rrf_in;


    wire                     forward_rrf_we_branch_out_rrf_in;
    wire [     `RRF_SEL-1:0] forward_rrftag_RsBranch_out_rrf_in;
    wire [    `DATA_LEN-1:0] forward_rrfdata_branch_out_rrf_in;

    wire                     allocate_rrf_en;

    wire                     src1_eq_zero_decoder_out_srcopmanager_in;
    wire                     src2_eq_zero_decoder_out_srcopmanager_in;

    wire [    `DATA_LEN-1:0] src1_srcopmanager_out_srcmanager_in;
    wire                     rdy1_srcopmanager_out_srcmanager_in;
    wire [    `DATA_LEN-1:0] src2_srcopmanager_out_srcmanager_in;
    wire                     rdy2_srcopmanager_out_srcmanager_in;

    // 请求 ALU 指令的数量
    wire [              1:0] dp_req_alu_num;
    // 请求内存指令的数量
    wire [              1:0] dp_req_mem_num;
    wire [    `ADDR_LEN-1:0] dp_pc_1;
    wire [    `ADDR_LEN-1:0] dp_pc_2;

    wire [    `DATA_LEN-1:0] dp_op_1_1;
    wire [    `DATA_LEN-1:0] dp_op_1_2;
    wire [    `DATA_LEN-1:0] dp_op_2_1;
    wire [    `DATA_LEN-1:0] dp_op_2_2;

    wire                     dp_valid_1_1;
    wire                     dp_valid_1_2;
    wire                     dp_valid_2_1;
    wire                     dp_valid_2_2;

    wire [    `DATA_LEN-1:0] dp_imm_1;
    wire [    `DATA_LEN-1:0] dp_imm_2;

    wire [     `RRF_SEL-1:0] dp_rrf_tag_1;
    wire [     `RRF_SEL-1:0] dp_rrf_tag_2;

    wire                     dp_dst_1;
    wire                     dp_dst_2;

    wire [`ALU_OP_WIDTH-1:0] dp_alu_op_1;
    wire [`ALU_OP_WIDTH-1:0] dp_alu_op_2;

    wire                     stall_dp;
    wire                     kill_dp;

    // 执行前递的信号
    wire [    `DATA_LEN-1:0] exe_result_1;
    wire [    `DATA_LEN-1:0] exe_result_2;
    wire [    `DATA_LEN-1:0] exe_result_3;
    wire [    `DATA_LEN-1:0] exe_result_4;
    wire [    `DATA_LEN-1:0] exe_result_5;
    wire [     `RRF_SEL-1:0] exe_result_1_dst;
    wire [     `RRF_SEL-1:0] exe_result_2_dst;
    wire [     `RRF_SEL-1:0] exe_result_3_dst;
    wire [     `RRF_SEL-1:0] exe_result_4_dst;
    wire [     `RRF_SEL-1:0] exe_result_5_dst;

    wire [    `DATA_LEN-1:0] exe_alu_op_1;
    wire [    `DATA_LEN-1:0] exe_alu_op_2;
    wire [    `ADDR_LEN-1:0] exe_alu_pc;
    wire [    `DATA_LEN-1:0] exe_alu_imm;
    wire [     `RRF_SEL-1:0] exe_alu_rrf_tag;
    wire                     exe_alu_dst_val;
    wire [`ALU_OP_WIDTH-1:0] exe_alu_op;
    wire [ `ALU_ENT_NUM-1:0] exe_alu_ready;
    wire                     exe_alu_issue;

    wire [    `DATA_LEN-1:0] exe_mem_op_1;
    wire [    `DATA_LEN-1:0] exe_mem_op_2;
    wire [    `ADDR_LEN-1:0] exe_mem_pc;
    wire [    `DATA_LEN-1:0] exe_mem_imm;
    wire [     `RRF_SEL-1:0] exe_mem_rrf_tag;
    wire                     exe_mem_dst_val;
    wire [`LDST_ENT_NUM-1:0] exe_mem_ready;
    wire                     exe_mem_issue_o;

endmodule

