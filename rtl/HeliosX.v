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

    wire                     dp_valid_1_1;wire ,
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


    // ------------ EX input -------------
    // alu
    wire ex_alu_issue;
    wire ex_alu_if_write_rrf;
    wire [`RRF_SEL-1:0] ex_alu_rrf_tag;
    wire [`ADDR_LEN-1:0] ex_alu_pc;
    wire [`DATA_LEN-1:0] ex_alu_imm;
    wire [`ALU_OP_WIDTH-1:0] ex_alu_alu_op;
    wire [`DATA_LEN-1:0] ex_alu_src1;
    wire [`SRC_A_SEL_WIDTH-1:0] ex_alu_src_a_select;
    wire [`DATA_LEN-1:0] ex_alu_src2;
    wire [`SRC_B_SEL_WIDTH-1:0] ex_alu_src_b_select;
    // branch
    wire ex_branch_issue;
    wire ex_branch_if_write_rrf;
    wire [`RRF_SEL-1:0] ex_branch_rrf_tag;
    wire [`ADDR_LEN-1:0] ex_branch_pc;
    wire [`DATA_LEN-1:0] ex_branch_imm;
    wire [`ALU_OP_WIDTH-1:0] ex_branch_alu_op;
    wire [`DATA_LEN-1:0] ex_branch_src1;
    wire [`DATA_LEN-1:0] ex_branch_src2;
    wire [`OPCODE_LEN-1:0] ex_branch_opcode;
    // memaccess
    wire ex_mem_access_issue;
    wire [`DATA_LEN-1:0] ex_mem_access_src1;
    wire [`DATA_LEN-1:0] ex_mem_access_src2;
    wire [`DATA_LEN-1:0] ex_mem_access_imm;
    wire ex_mem_access_if_write_rrf;
    wire ex_mem_access_complete;
    wire [`DATA_LEN-1:0] ex_mem_access_load_data_from_data_memory;
    wire [`RRF_SEL-1:0] ex_mem_access_rrf_tag;

    // ------------ EX output ------------
    // alu
    wire [`DATA_LEN-1:0] ex_alu_result;
    wire [`RRF_SEL-1:0] ex_alu_rrf_tag;
    wire ex_alu_rob_we;
    wire alu_rrf_we;
    // branch
    wire [`DATA_LEN-1:0] ex_branch_result;
    wire [`RRF_SEL-1:0] ex_branch_rrf_tag;
    wire ex_branch_rob_we;
    wire ex_branch_rrf_we;
    wire [`ADDR_LEN-1:0] ex_branch_jump_result;
    wire [`ADDR_LEN-1:0] ex_branch_jump_addr;
    wire ex_branch_if_jump;
    // memaccess
    wire ex_mem_access_rrf_we;
    wire ex_mem_access_rob_we;
    wire [`ADDR_LEN-1:0] ex_mem_access_load_address;
    wire ex_mem_access_store_buffer_mem_we;
    wire [`ADDR_LEN-1:0] ex_mem_access_store_buffer_write_address;
    wire [`DATA_LEN-1:0] ex_mem_access_store_buffer_write_data;
    wire [`DATA_LEN-1:0] ex_mem_access_load_data;
    wire [`RRF_SEL-1:0] ex_mem_access_rrf_tag;

    // ------------------------------------------------- EX -------------------------------------------------------
    ExUnit ex_unit (
    .clk_i                                    ( clk_i                                     ),
    .reset_i                                  ( reset_i                                   ),
    .alu_issue_i                              ( ex_alu_issue                               ),
    .alu_if_write_rrf_i                       ( ex_alu_if_write_rrf                        ),
    .alu_rrf_tag_i                            ( ex_alu_rrf_tag                             ),
    .alu_pc_i                                 ( ex_alu_pc                                  ),
    .alu_imm_i                                ( ex_alu_imm                                 ),
    .alu_alu_op_i                             ( ex_alu_alu_op                              ),
    .alu_src1_i                               ( ex_alu_src1                                ),
    .alu_src_a_select_i                       ( ex_alu_src_a_select                        ),
    .alu_src2_i                               ( ex_alu_src2                                ),
    .alu_src_b_select_i                       ( ex_alu_src_b_select                        ),
    .branch_issue_i                           ( ex_branch_issue                            ),
    .branch_if_write_rrf_i                    ( ex_branch_if_write_rrf                     ),
    .branch_rrf_tag_i                         ( ex_branch_rrf_tag                          ),
    .branch_pc_i                              ( ex_branch_pc                               ),
    .branch_imm_i                             ( ex_branch_imm                              ),
    .branch_alu_op_i                          ( ex_branch_alu_op                           ),
    .branch_src1_i                            ( ex_branch_src1                             ),
    .branch_src2_i                            ( ex_branch_src2                             ),
    .branch_opcode_i                          ( ex_branch_opcode                           ),
    .mem_access_src1_i                        ( ex_mem_access_src1                         ),
    .mem_access_src2_i                        ( ex_mem_access_src2                         ),
    .mem_access_imm_i                         ( ex_mem_access_imm                          ),
    .mem_access_if_write_rrf_i                ( ex_mem_access_if_write_rrf                 ),
    .mem_access_issue_i                       ( ex_mem_access_issue                        ),
    .mem_access_complete_i                    ( ex_mem_access_complete                     ),
    .mem_access_load_data_from_data_memory_i  ( ex_mem_access_load_data_from_data_memory   ),
    .mem_access_rrf_tag_i                     ( ex_mem_access_rrf_tag                      ),

    .alu_result_o                             ( ex_alu_result                              ),
    .alu_rrf_tag_o                            ( ex_alu_rrf_tag                             ),
    .alu_rob_we_o                             ( ex_alu_rob_we                              ),
    .alu_rrf_we_o                             ( ex_alu_rrf_we                              ),
    .branch_result_o                          ( ex_branch_result                           ),
    .branch_rrf_tag_o                         ( ex_branch_rrf_tag                          ),
    .branch_rob_we_o                          ( ex_branch_rob_we                           ),
    .branch_rrf_we_o                          ( ex_branch_rrf_we                           ),
    .branch_jump_result_o                     ( ex_branch_jump_result                      ),
    .branch_jump_addr_o                       ( ex_branch_jump_addr                        ),
    .branch_if_jump_o                         ( ex_branch_if_jump                          ),
    .mem_access_rrf_we_o                      ( ex_mem_access_rrf_we                       ),
    .mem_access_rob_we_o                      ( ex_mem_access_rob_we                       ),
    .mem_access_load_address_o                ( ex_mem_access_load_address                 ),
    .mem_access_store_buffer_mem_we_o         ( ex_mem_access_store_buffer_mem_we          ),
    .mem_access_store_buffer_write_address_o  ( ex_mem_access_store_buffer_write_address   ),
    .mem_access_store_buffer_write_data_o     ( ex_mem_access_store_buffer_write_data      ),
    .mem_access_load_data_o                   ( ex_mem_access_load_data                    ),
    .mem_access_rrf_tag_o                     ( ex_mem_access_rrf_tag                      )
);

endmodule

