`include "consts/Consts.vh"
`default_nettype wire
module ReNameUnit (
    input wire clk_i,
    input wire reset_i,

    input wire [`REG_SEL-1:0] rs1_decoder_out_arf_in_i,
    input wire [`REG_SEL-1:0] rs2_decoder_out_arf_in_i,

    input wire stall_dp_i,

    output wire rrf_allocatable_o,
    output wire [`RRF_SEL:0] freenum_RrfEntryAllocate_out_rob_in_o,
    output wire [`RRF_SEL-1:0] rrfptr_RrfEntryAllocate_out_rob_in_o,
    output wire nextrrfcyc_o,
    // 为dst分配的重命名寄存器的rrftag
    output wire [`RRF_SEL-1:0] dst_rrftag_o,
    output wire dst_en_o,

    input wire [1:0] com_inst_num_rob_out_RrfEntryAllocate_in_i,
    input wire [`REG_SEL-1:0] completed_dstnum_rob_out_arf_in_i,
    input wire completed_we_rob_out_arf_in_i,
    input wire [`RRF_SEL-1:0] completed_dst_rrftag_rob_out_arfANDrrf_in,

    input wire [`REG_SEL-1:0] dstnum_setbusy_decoder_out_arf_in_i,
    input wire dst_en_setbusy_decoder_out_arf_in_i,

    input wire forward_rrf_we_alu1_out_rrf_in_i,
    input wire [`RRF_SEL-1:0] forward_rrftag_RsAlu1_out_rrf_in_i,
    input wire [`DATA_LEN-1:0] forward_rrfdata_alu1_out_rrf_in_i,

    input wire forward_rrf_we_alu2_out_rrf_in_i,
    input wire [`RRF_SEL-1:0] forward_rrftag_RsAlu2_out_rrf_in_i,
    input wire [`DATA_LEN-1:0] forward_rrfdata_alu2_out_rrf_in_i,


    input wire forward_rrf_we_ldst_out_rrf_in_i,
    input wire [`RRF_SEL-1:0] forward_rrftag_RsLdst_out_rrf_in_i,
    input wire [`DATA_LEN-1:0] forward_rrfdata_ldst_out_rrf_in_i,


    input wire forward_rrf_we_mul_out_rrf_in_i,
    input wire [`RRF_SEL-1:0] forward_rrftag_RsMul_out_rrf_in_i,
    input wire [`DATA_LEN-1:0] forward_rrfdata_mul_out_rrf_in_i,


    input wire forward_rrf_we_branch_out_rrf_in_i,
    input wire [`RRF_SEL-1:0] forward_rrftag_RsBranch_out_rrf_in_i,
    input wire [`DATA_LEN-1:0] forward_rrfdata_branch_out_rrf_in_i,

    input wire allocate_rrf_en_i,

    input wire src1_eq_zero_decoder_out_srcopmanager_in_i,
    input wire src2_eq_zero_decoder_out_srcopmanager_in_i,

    output wire [`DATA_LEN-1:0] src1_srcopmanager_out_srcmanager_in_o,
    output wire rdy1_srcopmanager_out_srcmanager_in_o,
    output wire [`DATA_LEN-1:0] src2_srcopmanager_out_srcmanager_in_o,
    output wire rdy2_srcopmanager_out_srcmanager_in_o,


    // RSRequestGen 模块代码
    input wire [`RS_ENT_SEL-1:0] inst1_RsType_decoder_out_RSRequestGen_in_i,
    input wire [`RS_ENT_SEL-1:0] inst2_RsType_decoder_out_RSRequestGen_in_i,

    output wire    req1_alu_o,
    output wire    req2_alu_o,
    output wire [1:0]   req_alunum_RSRequestGen_out_SWUnit_in_o,

    output wire    req1_branch_o,
    output wire    req2_branch_o,
    output wire [1:0]   req_branchnum_RSRequestGen_out_SWUnit_in_o,

    output wire    req1_mul_o,
    output wire    req2_mul_o,
    output wire [1:0]   req_mulnum_RSRequestGen_out_SWUnit_in_o,

    output wire    req1_ldst_o,
    output wire    req2_ldst_o,
    output wire [1:0]   req_ldstnum_RSRequestGen_out_SWUnit_in_o
);

    reg  rrf_allocatable_reg;
    wire rrf_allocatable_wire;
    assign rrf_allocatable_o = rrf_allocatable_reg;

    reg  [`RRF_SEL-1:0] dst_rrftag_reg;
    wire [`RRF_SEL-1:0] allocate_rrftag_AllocateRrfEntry_out_rrfANDarf_in;
    assign dst_rrftag_o = dst_rrftag_reg;

    reg  dst_en_reg;
    wire dst_en_wire;
    assign dst_en_o = dst_en_reg;

    reg  [`DATA_LEN-1:0] src1_srcopmanager_out_srcmanager_in_reg;
    wire [`DATA_LEN-1:0] src1_srcopmanager_out_srcmanager_in_wire;
    assign src1_srcopmanager_out_srcmanager_in_o = src1_srcopmanager_out_srcmanager_in_reg;

    reg  [`DATA_LEN-1:0] src2_srcopmanager_out_srcmanager_in_reg;
    wire [`DATA_LEN-1:0] src2_srcopmanager_out_srcmanager_in_wire;
    assign src2_srcopmanager_out_srcmanager_in_o = src2_srcopmanager_out_srcmanager_in_reg;

    reg  rdy1_srcopmanager_out_srcmanager_in_reg;
    wire rdy1_srcopmanager_out_srcmanager_in_wire;
    assign rdy1_srcopmanager_out_srcmanager_in_o = rdy1_srcopmanager_out_srcmanager_in_reg;

    reg  rdy2_srcopmanager_out_srcmanager_in_reg;
    wire rdy2_srcopmanager_out_srcmanager_in_wire;
    assign rdy2_srcopmanager_out_srcmanager_in_o = rdy2_srcopmanager_out_srcmanager_in_reg;

    reg  req1_alu_reg;
    wire req1_alu_wire;
    assign req1_alu_o = req1_alu_reg;

    reg  req2_alu_reg;
    wire req2_alu_wire;
    assign req2_alu_o = req2_alu_reg;

    reg  [1:0] req_alunum_RSRequestGen_out_SWUnit_in_reg;
    wire [1:0] req_alunum_RSRequestGen_out_SWUnit_in_wire;
    assign req_alunum_RSRequestGen_out_SWUnit_in_o = req_alunum_RSRequestGen_out_SWUnit_in_reg;

    reg  req1_branch_reg;
    wire req1_branch_wire;
    assign req1_branch_o = req1_branch_reg;

    reg  req2_branch_reg;
    wire req2_branch_wire;
    assign req2_branch_o = req2_branch_reg;

    reg  [1:0] req_branchnum_RSRequestGen_out_SWUnit_in_reg;
    wire [1:0] req_branchnum_RSRequestGen_out_SWUnit_in_wire;
    assign req_branchnum_RSRequestGen_out_SWUnit_in_o = req_branchnum_RSRequestGen_out_SWUnit_in_reg;

    reg  req1_mul_reg;
    wire req1_mul_wire;
    assign req1_mul_o = req1_mul_reg;

    reg  req2_mul_reg;
    wire req2_mul_wire;
    assign req2_mul_o = req2_mul_reg;

    reg  [1:0] req_mulnum_RSRequestGen_out_SWUnit_in_reg;
    wire [1:0] req_mulnum_RSRequestGen_out_SWUnit_in_wire;
    assign req_mulnum_RSRequestGen_out_SWUnit_in_o = req_mulnum_RSRequestGen_out_SWUnit_in_reg;

    reg  req1_ldst_reg;
    wire req1_ldst_wire;
    assign req1_ldst_o = req1_ldst_reg;

    reg  req2_ldst_reg;
    wire req2_ldst_wire;
    assign req2_ldst_o = req2_ldst_reg;

    reg  [1:0] req_ldstnum_RSRequestGen_out_SWUnit_in_reg;
    wire [1:0] req_ldstnum_RSRequestGen_out_SWUnit_in_wire;
    assign req_ldstnum_RSRequestGen_out_SWUnit_in_o = req_ldstnum_RSRequestGen_out_SWUnit_in_reg;

    always @(posedge clk_i) begin
        rrf_allocatable_reg <= rrf_allocatable_wire;

        dst_rrftag_reg <= allocate_rrftag_AllocateRrfEntry_out_rrfANDarf_in;
        dst_en_reg <= dst_en_wire;

        src1_srcopmanager_out_srcmanager_in_reg <= src1_srcopmanager_out_srcmanager_in_wire;
        src2_srcopmanager_out_srcmanager_in_reg <= src2_srcopmanager_out_srcmanager_in_wire;
        rdy1_srcopmanager_out_srcmanager_in_reg <= rdy1_srcopmanager_out_srcmanager_in_wire;
        rdy2_srcopmanager_out_srcmanager_in_reg <= rdy2_srcopmanager_out_srcmanager_in_wire;

        req1_alu_reg <= req1_alu_wire;
        req2_alu_reg <= req2_alu_wire;
        req_alunum_RSRequestGen_out_SWUnit_in_reg <= req_alunum_RSRequestGen_out_SWUnit_in_wire;

        req1_mul_reg <= req1_mul_wire;
        req2_mul_reg <= req2_mul_wire;
        req_mulnum_RSRequestGen_out_SWUnit_in_reg <= req_mulnum_RSRequestGen_out_SWUnit_in_wire;

        req1_ldst_reg <= req1_ldst_wire;
        req2_ldst_reg <= req2_ldst_wire;
        req_ldstnum_RSRequestGen_out_SWUnit_in_reg <= req_ldstnum_RSRequestGen_out_SWUnit_in_wire;
    end



    // decoder传递来的dst使能信号，表示是否需要写回dst
    assign dst_en_wire = dst_en_setbusy_decoder_out_arf_in_i;

    wire [`DATA_LEN-1:0] rs1_arfdata_arf_out_srcopmanager_in;
    wire [`DATA_LEN-1:0] rs2_arfdata_arf_out_srcopmanager_in;
    wire rs1_arfbusy_arf_out_srcopmanager_in;
    wire rs2_arfbusy_arf_out_srcopmanager_in;
    wire [`RRF_SEL-1:0] rs1_arf_rrftag_arf_out_srcopmanagerANDrrf_in;
    wire [`RRF_SEL-1:0] rs2_arf_rrftag_arf_out_srcopmanagerANDrrf_in;

    wire [`DATA_LEN-1:0] from_rrfdata_rrf_out_arf_in;



    Arf arf (
        .clk_i  (clk_i),
        .reset_i(reset_i),

        .rs1_i(rs1_decoder_out_arf_in_i),
        .rs2_i(rs2_decoder_out_arf_in_i),
        .rs1_arf_data_o(rs1_arfdata_arf_out_srcopmanager_in),
        .rs2_arf_data_o(rs2_arfdata_arf_out_srcopmanager_in),
        .rs1_arf_busy_o(rs1_arfbusy_arf_out_srcopmanager_in),
        .rs2_arf_busy_o(rs2_arfbusy_arf_out_srcopmanager_in),
        .rs1_arf_rrftag_o(rs1_arf_rrftag_arf_out_srcopmanagerANDrrf_in),
        .rs2_arf_rrftag_o(rs2_arf_rrftag_arf_out_srcopmanagerANDrrf_in),

        .completed_dst_num_i(completed_dstnum_rob_out_arf_in_i),
        .from_rrfdata_i(from_rrfdata_rrf_out_arf_in),
        .completed_dst_rrftag_i(completed_dst_rrftag_rob_out_arfANDrrf_in),
        .completed_we_i(completed_we_rob_out_arf_in_i),

        .dst_num_setbusy_i(dstnum_setbusy_decoder_out_arf_in_i),
        .dst_rrftag_setbusy_i(allocate_rrftag_AllocateRrfEntry_out_rrfANDarf_in),
        .dst_en_setbusy_i(dst_en_setbusy_decoder_out_arf_in_i)
    );

    wire [`DATA_LEN-1:0] rs1_rrfdata_rrf_out_srcopmanager_in;
    wire [`DATA_LEN-1:0] rs2_rrfdata_rrf_out_srcopmanager_in;
    wire rs1_rrfvalid_rrf_out_srcopmanager_in;
    wire rs2_rrfvalid_rrf_out_srcopmanager_in;

    Rrf rrf (
        .clk_i  (clk_i),
        .reset_i(reset_i),

        .rs1_rrftag_i  (rs1_arf_rrftag_arf_out_srcopmanagerANDrrf_in),
        .rs2_rrftag_i  (rs2_arf_rrftag_arf_out_srcopmanagerANDrrf_in),
        .rs1_rrfdata_o (rs1_rrfdata_rrf_out_srcopmanager_in),
        .rs2_rrfdata_o (rs2_rrfdata_rrf_out_srcopmanager_in),
        .rs1_rrfvalid_o(rs1_rrfvalid_rrf_out_srcopmanager_in),
        .rs2_rrfvalid_o(rs2_rrfvalid_rrf_out_srcopmanager_in),


        .forward_rrf_we_alu1_i (forward_rrf_we_alu1_out_rrf_in_i),
        .forward_rrftag_alu1_i (forward_rrftag_RsAlu1_out_rrf_in_i),
        .forward_rrfdata_alu1_i(forward_rrfdata_alu1_out_rrf_in_i),

        .forward_rrf_we_alu2_i (forward_rrf_we_alu2_out_rrf_in_i),
        .forward_rrftag_alu2_i (forward_rrftag_RsAlu2_out_rrf_in_i),
        .forward_rrfdata_alu2_i(forward_rrfdata_alu2_out_rrf_in_i),

        .forward_rrf_we_ldst_i (forward_rrf_we_ldst_out_rrf_in_i),
        .forward_rrftag_ldst_i (forward_rrftag_RsLdst_out_rrf_in_i),
        .forward_rrfdata_ldst_i(forward_rrfdata_ldst_out_rrf_in_i),

        .forward_rrf_we_mul_i (forward_rrf_we_mul_out_rrf_in_i),
        .forward_rrftag_mul_i (forward_rrftag_RsMul_out_rrf_in_i),
        .forward_rrfdata_mul_i(forward_rrfdata_mul_out_rrf_in_i),

        .forward_rrf_we_branch_i (forward_rrf_we_branch_out_rrf_in_i),
        .forward_rrftag_branch_i (forward_rrftag_RsBranch_out_rrf_in_i),
        .forward_rrfdata_branch_i(forward_rrfdata_branch_out_rrf_in_i),

        .allocate_rrf_en_i(allocate_rrf_en_i),
        .allocate_rrftag_i(allocate_rrftag_AllocateRrfEntry_out_rrfANDarf_in),

        .completed_dst_rrftag_i(completed_dst_rrftag_rob_out_arfANDrrf_in),
        .data_to_arfdata_o(from_rrfdata_rrf_out_arf_in)
    );

    SrcOprManager src_op_manager1 (
        .arf_busy_i(rs1_arfbusy_arf_out_srcopmanager_in),
        .arf_data_i(rs1_arfdata_arf_out_srcopmanager_in),
        .arf_rrftag_i(rs1_arf_rrftag_arf_out_srcopmanagerANDrrf_in),
        .rrf_valid_i(rs1_rrfvalid_rrf_out_srcopmanager_in),
        .rrf_data_i(rs1_rrfdata_rrf_out_srcopmanager_in),
        .src_eq_zero_i(src1_eq_zero_decoder_out_srcopmanager_in_i),
        .src_o(src1_srcopmanager_out_srcmanager_in_wire),
        .ready_o(rdy1_srcopmanager_out_srcmanager_in_wire)
    );

    SrcOprManager src_op_manager2 (
        .arf_busy_i(rs2_arfbusy_arf_out_srcopmanager_in),
        .arf_data_i(rs2_arfdata_arf_out_srcopmanager_in),
        .arf_rrftag_i(rs2_arf_rrftag_arf_out_srcopmanagerANDrrf_in),
        .rrf_valid_i(rs2_rrfvalid_rrf_out_srcopmanager_in),
        .rrf_data_i(rs2_rrfdata_rrf_out_srcopmanager_in),
        .src_eq_zero_i(src2_eq_zero_decoder_out_srcopmanager_in_i),
        .src_o(src2_srcopmanager_out_srcmanager_in_wire),
        .ready_o(rdy2_srcopmanager_out_srcmanager_in_wire)
    );

    RrfEntryAllocate rrf_alloc (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .com_inst_num_i(com_inst_num_rob_out_RrfEntryAllocate_in_i),
        .stall_dp_i(stall_dp_i),
        .req_en_i(dst_en_setbusy_decoder_out_arf_in_i),
        .rrf_allocatable_o(rrf_allocatable_wire),
        .freenum_o(freenum_RrfEntryAllocate_out_rob_in_o),
        .dst_rename_rrftag_o(allocate_rrftag_AllocateRrfEntry_out_rrfANDarf_in),
        .rrfptr_o(rrfptr_RrfEntryAllocate_out_rob_in_o),
        .nextrrfcyc_o(nextrrfcyc_o)
    );

    RSRequestGen rs_request_gen (
        .inst1_rs_type_i(inst1_RsType_decoder_out_RSRequestGen_in_i),
        .inst2_rs_type_i(inst2_RsType_decoder_out_RSRequestGen_in_i),

        .req1_alu_o  (req1_alu_wire),
        .req2_alu_o  (req2_alu_wire),
        .req_alunum_o(req_alunum_RSRequestGen_out_SWUnit_in_wire),

        .req1_branch_o  (req1_branch_wire),
        .req2_branch_o  (req2_branch_wire),
        .req_branchnum_o(req_branchnum_RSRequestGen_out_SWUnit_in_wire),

        .req1_mul_o  (req1_mul_wire),
        .req2_mul_o  (req2_mul_wire),
        .req_mulnum_o(req_mulnum_RSRequestGen_out_SWUnit_in_wire),

        .req1_ldst_o  (req1_ldst_wire),
        .req2_ldst_o  (req2_ldst_wire),
        .req_ldstnum_o(req_ldstnum_RSRequestGen_out_SWUnit_in_wire)
    );
endmodule
`default_nettype none
