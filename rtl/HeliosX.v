`include "consts/Consts.vh"
`include "consts/ALU.vh"

module HeliosX (
    input wire clk_i,
    input wire reset_i,

    // output reg [`ADDR_LEN-1:0] pc_o,
    output wire [`ADDR_LEN-1:0] iaddr_o,

    input wire [`INSN_LEN-1:0] idata_i,

    output wire dmem_we_o,
    output wire [`DATA_LEN-1:0] dmem_wdata_o,
    output wire [`ADDR_LEN-1:0] dmem_waddr_o,
    output wire [`ADDR_LEN-1:0] dmem_raddr_o,
    input wire [`DATA_LEN-1:0] dmem_rdata_i

);

    //暂停信号、kill信号
    wire stall_IF;
    wire kill_IF;
    wire stall_ID;
    wire kill_ID;
    wire stall_DP;
    wire kill_DP;

    assign stall_IF = 1'b0;
    assign stall_ID = 1'b0;
    assign stall_DP = 1'b0;
    assign kill_IF  = 1'b0;
    assign kill_ID  = 1'b0;
    assign kill_DP  = 1'b0;


    //因为下面声明的信号连接了不同模块的输入和输出，所以声明的信号后面都去除了后缀 _i以及后缀_o.

    //IF阶段传出的信号
    wire [`ADDR_LEN-1:0] npc;
    wire [`INSN_LEN-1:0] inst;

    //ID阶段传出的信号
    wire [`ADDR_LEN-1:0]pc_dp;
    wire [`IMM_TYPE_WIDTH-1:0] imm_type_1_dp;

    wire [`DATA_LEN-1:0] imm_1_dp;

    wire [`REG_SEL-1:0] rs1_1_dp;
    wire [`REG_SEL-1:0] rs2_1_dp;
    wire [`REG_SEL-1:0] rd_1_dp;
    wire [`SRC_A_SEL_WIDTH-1:0] src_a_sel_1_dp;
    wire [`SRC_B_SEL_WIDTH-1:0] src_b_sel_1_dp;
    wire wr_reg_1_dp;
    wire uses_rs1_1_dp;
    wire uses_rs2_1_dp;
    wire illegal_instruction_1_dp;
    wire [`ALU_OP_WIDTH-1:0] alu_op_1_dp;
    wire [`RS_ENT_SEL-1:0] rs_ent_1_dp;
    wire [2:0] dmem_size_1_dp;
    wire [`MEM_TYPE_WIDTH-1:0] dmem_type_1_dp;
    wire [`MD_OP_WIDTH-1:0] md_req_op_1_dp;
    wire md_req_in_1_signed_1_dp;
    wire md_req_in_2_signed_1_dp;
    wire [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel_1_dp;


    //DP阶段传出的信号

    wire rrf_allocatable;
    wire [`RRF_SEL-1:0] rrfptr_RrfEntryAllocate_out_rob_in;
    /* 因为reenum_RrfEntryAllocate_out_rob_in在COM阶段暂时不需要，所以wulv 在 24.1.23时间注释掉了 */
    //wire [`RRF_SEL:0] freenum_RrfEntryAllocate_out_rob_in
    wire nextrrfcyc;
    wire [`RRF_SEL-1:0] dst_rrftag;
    wire dst_en;
    wire [`DATA_LEN-1:0] src1_srcopmanager_out_srcmanager_in;
    wire rdy1_srcopmanager_out_srcmanager_in;
    wire [`DATA_LEN-1:0] src2_srcopmanager_out_srcmanager_in;
    wire rdy2_srcopmanager_out_srcmanager_in;

    wire req1_alu;
    wire req2_alu;
    wire [1:0] req_alunum_RSRequestGen_out_SWUnit_in;

    wire req1_branch;
    wire req2_branch;
    wire [1:0] req_branchnum_RSRequestGen_out_SWUnit_in;

    wire req1_mul;
    wire req2_mul;
    wire [1:0] req_mulnum_RSRequestGen_out_SWUnit_in;

    wire req1_ldst;
    wire req2_ldst;
    wire [1:0] req_ldstnum_RSRequestGen_out_SWUnit_in;

    // 下面这些信号是dpunit暂存的idunit阶段传来的信号
    //ID阶段传出的信号
    wire [`ADDR_LEN-1:0]pc_sw;
    wire [`IMM_TYPE_WIDTH-1:0] imm_type_1_sw;
    wire [`DATA_LEN-1:0] imm_1_sw;
    wire [`REG_SEL-1:0] rd_1_sw;
    wire [`SRC_A_SEL_WIDTH-1:0] sw_src_a;
    wire [`SRC_B_SEL_WIDTH-1:0] sw_src_b;
    wire wr_reg_1_sw;
    wire uses_rs1_1_sw;
    wire uses_rs2_1_sw;
    wire illegal_instruction_1_sw;
    wire [`ALU_OP_WIDTH-1:0] alu_op_1_sw;
    wire [`RS_ENT_SEL-1:0] rs_ent_1_sw;
    wire [2:0] dmem_size_1_sw;
    wire [`MEM_TYPE_WIDTH-1:0] dmem_type_1_sw;
    wire [`MD_OP_WIDTH-1:0] md_req_op_1_sw;
    wire md_req_in_1_signed_1_sw;
    wire md_req_in_2_signed_1_sw;
    wire [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel_1_sw;
    wire [`REG_SEL-1:0] rs1_sw;
    wire [`REG_SEL-1:0] rs2_sw;

    //SW阶段传出的信号
    wire [`DATA_LEN-1:0] exe_alu_op_1;
    wire [`DATA_LEN-1:0] exe_alu_op_2;
    wire [`ADDR_LEN-1:0] exe_alu_pc;
    wire [`DATA_LEN-1:0] exe_alu_imm;
    wire [`RRF_SEL-1:0] exe_alu_rrf_tag;
    wire exe_alu_dst_val;
    wire [`ALU_OP_WIDTH-1:0] exe_alu_op;
    wire [`ALU_ENT_NUM-1:0] exe_alu_ready;
    wire exe_alu_issue;
    wire [`SRC_A_SEL_WIDTH-1: 0] exe_alu_src_a;
    wire [`SRC_B_SEL_WIDTH-1: 0] exe_alu_src_b;

    wire [`DATA_LEN-1:0] exe_mem_op_1;
    wire [`DATA_LEN-1:0] exe_mem_op_2;
    wire [`ADDR_LEN-1:0] exe_mem_pc;
    wire [`DATA_LEN-1:0] exe_mem_imm;
    wire [`RRF_SEL-1:0] exe_mem_rrf_tag;
    wire exe_mem_dst_val;
    wire [`LDST_ENT_NUM-1:0] exe_mem_ready;
    wire exe_mem_issue;


    //EX阶段传出的信号
    wire [`DATA_LEN-1:0] alu_result;
    wire [`RRF_SEL-1:0] alu_rrf_tag;
    wire alu_rob_we;
    wire alu_rrf_we;

    wire [`DATA_LEN-1:0] branch_result;
    wire [`RRF_SEL-1:0] branch_rrf_tag;
    wire branch_rob_we;
    wire branch_rrf_we;
    wire [`ADDR_LEN-1:0] branch_jump_result;
    wire [`ADDR_LEN-1:0] branch_jump_addr;
    wire branch_if_jump;

    wire mem_access_rrf_we;
    wire mem_access_rob_we;
    wire [`ADDR_LEN-1:0] mem_access_load_address;
    wire mem_access_store_buffer_mem_we;
    wire [`ADDR_LEN-1:0] mem_access_store_buffer_write_address;
    wire [`DATA_LEN-1:0] mem_access_store_buffer_write_data;
    wire [`DATA_LEN-1:0] mem_access_load_data;
    wire [`RRF_SEL-1:0] mem_access_rrf_tag;


    //COM阶段传出的信号
    /* verilator lint_off UNOPTFLAT */
    wire [`ROB_SEL-1:0] commit_ptr_1;
    wire arfwe_1;
    wire [`REG_SEL-1:0] dst_arf_1;
    wire    comnum;

    // always @(posedge clk_i) begin
    //     if(reset_i)begin
    //         pc_o <= `ENTRY_POINT;
    //     end else begin
    //         pc_o <= npc;
    //     end
    // end


    //IF stage
    IFUnit u_IFUnit (
        //input
        .clk_i(clk_i),
        .reset_i(reset_i),
        .idata_i(idata_i),
        .stall_IF(stall_IF),
        .kill_IF(stall_IF),
        .stall_ID(stall_ID),
        .kill_ID(kill_ID),
        .stall_DP(stall_DP),
        .kill_DP(kill_DP),

        //output
        .npc_o  (npc),
        .inst_o (inst),
        .iaddr_o(iaddr_o)
    );


    // iaddr_o表示的是从单周期ram中取指令的地址，但是这里的pc表示的是当前阶段处
    // 理的指令的pc,所以实际上需要延迟两个时钟周期才对
    reg [`ADDR_LEN-1:0] pc_t;
    reg [`ADDR_LEN-1:0] pc_id;
    always @(posedge clk_i) begin
        pc_t  <= iaddr_o;
        pc_id <= pc_t;
    end


    //ID stage
    IDUnit u_IDUnit (
        //input
        .inst1_i(inst),
        .clk_i(clk_i),
        .reset_i(reset_i),
        .pc_i(pc_id),
        .stall_IF(stall_IF),
        .kill_IF(kill_IF),
        .stall_ID(stall_ID),
        .kill_ID(kill_ID),
        .stall_DP(stall_DP),
        .kill_DP(kill_DP),

        //output
        .pc_o(pc_dp),
        .imm_type_1_o(imm_type_1_dp),
        .imm_1_o(imm_1_dp),

        .rs1_1_o(rs1_1_dp),
        .rs2_1_o(rs2_1_dp),
        .rd_1_o(rd_1_dp),
        .src_a_sel_1_o(src_a_sel_1_dp),
        .src_b_sel_1_o(src_b_sel_1_dp),
        .wr_reg_1_o(wr_reg_1_dp),
        .uses_rs1_1_o(uses_rs1_1_dp),
        .uses_rs2_1_o(uses_rs2_1_dp),
        .illegal_instruction_1_o(illegal_instruction_1_dp),
        .alu_op_1_o(alu_op_1_dp),
        .rs_ent_1_o(rs_ent_1_dp),
        .dmem_size_1_o(dmem_size_1_dp),
        .dmem_type_1_o(dmem_type_1_dp),
        .md_req_op_1_o(md_req_op_1_dp),
        .md_req_in_1_signed_1_o(md_req_in_1_signed_1_dp),
        .md_req_in_2_signed_1_o(md_req_in_2_signed_1_dp),
        .md_req_out_sel_1_o(md_req_out_sel_1_dp)
    );


    //DP stage
    ReNameUnit u_ReNameUnit (
        //input
        .clk_i(clk_i),
        .reset_i(reset_i),
        .rs1_decoder_out_arf_in_i(rs1_1_dp),
        .rs2_decoder_out_arf_in_i(rs2_1_dp),
        .rs1_o(rs1_sw),
        .rs2_o(rs2_sw),

        .stall_dp_i(stall_DP),
        .pc_i(pc_dp),

        //output
        .pc_o(pc_sw),
        .rrf_allocatable_o(rrf_allocatable),
        .freenum_RrfEntryAllocate_out_rob_in_o(),
        .rrfptr_RrfEntryAllocate_out_rob_in_o(rrfptr_RrfEntryAllocate_out_rob_in),
        .nextrrfcyc_o(nextrrfcyc),
        .dst_rrftag_o(dst_rrftag),
        .dst_en_o(dst_en),
        //input
        .com_inst_num_rob_out_RrfEntryAllocate_in_i({1'b0, comnum}),
        .completed_dstnum_rob_out_arf_in_i(dst_arf_1),
        .completed_we_rob_out_arf_in_i(arfwe_1),
        .completed_dst_rrftag_rob_out_arfANDrrf_in(commit_ptr_1),

        .dstnum_setbusy_decoder_out_arf_in_i(rd_1_dp),
        .dst_en_setbusy_decoder_out_arf_in_i(wr_reg_1_dp),

        .forward_rrf_we_alu1_out_rrf_in_i  (alu_rrf_we),
        .forward_rrftag_RsAlu1_out_rrf_in_i(alu_rrf_tag),
        .forward_rrfdata_alu1_out_rrf_in_i (alu_result),

        .forward_rrf_we_alu2_out_rrf_in_i  (),
        .forward_rrftag_RsAlu2_out_rrf_in_i(),
        .forward_rrfdata_alu2_out_rrf_in_i (),

        .forward_rrf_we_ldst_out_rrf_in_i  (mem_access_rrf_we),
        .forward_rrftag_RsLdst_out_rrf_in_i(mem_access_rrf_tag),
        .forward_rrfdata_ldst_out_rrf_in_i (mem_access_load_data),

        .forward_rrf_we_mul_out_rrf_in_i  (),
        .forward_rrftag_RsMul_out_rrf_in_i(),
        .forward_rrfdata_mul_out_rrf_in_i (),

        .forward_rrf_we_branch_out_rrf_in_i(),
        .forward_rrftag_RsBranch_out_rrf_in_i(),
        .forward_rrfdata_branch_out_rrf_in_i(),
        .allocate_rrf_en_i(),

        // TODO:
        // uses_rs1_1,uses_rs2_1这两个信号应该是连接到ALU的
        //.src1_eq_zero_decoder_out_srcopmanager_in_i(uses_rs1_1),
        //.src2_eq_zero_decoder_out_srcopmanager_in_i(uses_rs2_1),
        .src1_eq_zero_decoder_out_srcopmanager_in_i((rs1_1_dp == 0) ? 1 : 0),
        .src2_eq_zero_decoder_out_srcopmanager_in_i((rs2_1_dp == 0) ? 1 : 0),

        //output
        .src1_srcopmanager_out_srcmanager_in_o(src1_srcopmanager_out_srcmanager_in),
        .rdy1_srcopmanager_out_srcmanager_in_o(rdy1_srcopmanager_out_srcmanager_in),
        .src2_srcopmanager_out_srcmanager_in_o(src2_srcopmanager_out_srcmanager_in),
        .rdy2_srcopmanager_out_srcmanager_in_o(rdy2_srcopmanager_out_srcmanager_in),

        //RSRequestGen input
        .inst1_RsType_decoder_out_RSRequestGen_in_i(rs_ent_1_dp),
        .inst2_RsType_decoder_out_RSRequestGen_in_i(),

        //RSRequestGen output
        .req1_alu_o(req1_alu),
        .req2_alu_o(req2_alu),
        .req_alunum_RSRequestGen_out_SWUnit_in_o(req_alunum_RSRequestGen_out_SWUnit_in),

        .req1_branch_o(),
        .req2_branch_o(),
        .req_branchnum_RSRequestGen_out_SWUnit_in_o(),

        .req1_mul_o(),
        .req2_mul_o(),
        .req_mulnum_RSRequestGen_out_SWUnit_in_o(),

        .req1_ldst_o(req1_ldst),
        .req2_ldst_o(req2_ldst),
        .req_ldstnum_RSRequestGen_out_SWUnit_in_o(req_ldstnum_RSRequestGen_out_SWUnit_in),


        // 下面这些信号是renameunit暂存的idunit阶段的信号
        .imm_type_1_i(imm_type_1_dp),
        .imm_type_1_o(imm_type_1_sw),

        .imm_1_i(imm_1_dp),
        .imm_1_o(imm_1_sw),

        .rd_1_o(rd_1_sw),

        .src_a_sel_1_i(src_a_sel_1_dp),
        .src_a_sel_1_o(sw_src_a),

        .src_b_sel_1_i(src_b_sel_1_dp),
        .src_b_sel_1_o(sw_src_b),

        .wr_reg_1_o(wr_reg_1_sw),

        .uses_rs1_1_i(uses_rs1_1_dp),
        .uses_rs1_1_o(uses_rs1_1_sw),

        .uses_rs2_1_i(uses_rs2_1_dp),
        .uses_rs2_1_o(uses_rs2_1_sw),

        .illegal_instruction_1_i(illegal_instruction_1_dp),
        .illegal_instruction_1_o(illegal_instruction_1_sw),

        .alu_op_1_i(alu_op_1_dp),
        .alu_op_1_o(alu_op_1_sw),

        .rs_ent_1_o(rs_ent_1_sw),

        .dmem_size_1_i(dmem_size_1_dp),
        .dmem_size_1_o(dmem_size_1_sw),

        .dmem_type_1_i(dmem_type_1_dp),
        .dmem_type_1_o(dmem_type_1_sw),

        .md_req_in_1_signed_1_i(md_req_in_1_signed_1_dp),
        .md_req_in_1_signed_1_o(md_req_in_1_signed_1_sw),

        .md_req_op_1_i(md_req_op_1_dp),
        .md_req_op_1_o(md_req_op_1_sw),

        .md_req_in_2_signed_1_i(md_req_in_2_signed_1_dp),
        .md_req_in_2_signed_1_o(md_req_in_2_signed_1_sw),

        .md_req_out_sel_1_i(md_req_out_sel_1_dp),
        .md_req_out_sel_1_o(md_req_out_sel_1_sw)
    );



    //SW stage
    SwUnit u_SwUint (
        //input
        .clk_i(clk_i),
        .reset_i(reset_i),
        .dp_next_rrf_cycle_i(nextrrfcyc),
        .dp_req_alu_num_i(req_alunum_RSRequestGen_out_SWUnit_in),
        .dp_req_mem_num_i(0),
        .dp_pc_1_i(pc_sw),
        .dp_pc_2_i(0),
        .dp_op_1_1_i(src1_srcopmanager_out_srcmanager_in),
        .dp_op_1_2_i(src2_srcopmanager_out_srcmanager_in),
        .dp_op_2_1_i(0),
        .dp_op_2_2_i(0),
        .dp_valid_1_1_i(rdy1_srcopmanager_out_srcmanager_in),
        .dp_valid_1_2_i(rdy2_srcopmanager_out_srcmanager_in),
        .dp_valid_2_1_i(0),
        .dp_valid_2_2_i(0),
        .dp_src_1_a_i(sw_src_a),
        .dp_src_1_b_i(sw_src_b),
        .dp_src_2_a_i(0),
        .dp_src_2_b_i(0),
        .dp_imm_1_i(imm_1_sw),
        .dp_imm_2_i(0),
        .dp_rrf_tag_1_i(dst_rrftag),
        .dp_rrf_tag_2_i(0),
        .dp_dst_1_i(dst_en),
        .dp_dst_2_i(0),
        .dp_alu_op_1_i(alu_op_1_sw),
        .dp_alu_op_2_i(0),
        .stall_dp_i(stall_DP),
        .kill_dp_i(kill_DP),
        .exe_result_1_i(alu_result),
        .exe_result_2_i(branch_result),
        .exe_result_3_i(0),
        .exe_result_4_i(0),
        .exe_result_5_i(0),
        .exe_result_1_dst_i(alu_rrf_tag),
        .exe_result_2_dst_i(branch_rrf_tag),
        .exe_result_3_dst_i(0),
        .exe_result_4_dst_i(0),
        .exe_result_5_dst_i(0),

        //output
        .exe_alu_op_1_o(exe_alu_op_1),
        .exe_alu_op_2_o(exe_alu_op_2),
        .exe_alu_pc_o(exe_alu_pc),
        .exe_alu_imm_o(exe_alu_imm),
        .exe_alu_rrf_tag_o(exe_alu_rrf_tag),
        .exe_alu_dst_val_o(exe_alu_dst_val),
        .exe_alu_op_o(exe_alu_op),
        .exe_alu_ready_o(),
        .exe_alu_issue_o(exe_alu_issue),
        .exe_alu_src_a_o(exe_alu_src_a),
        .exe_alu_src_b_o(exe_alu_src_b),

        .exe_mem_op_1_o(exe_mem_op_1),
        .exe_mem_op_2_o(exe_mem_op_2),
        .exe_mem_pc_o(),
        .exe_mem_imm_o(exe_mem_imm),
        .exe_mem_rrf_tag_o(exe_mem_rrf_tag),
        .exe_mem_dst_val_o(exe_mem_dst_val),
        .exe_mem_ready_o(),
        .exe_mem_issue_o(exe_mem_issue)

    );

    //EX stage
    ExUnit u_ExUnit (
        // input
        .clk_i  (clk_i),
        .reset_i(reset_i),

        // ALU 输入
        .alu_issue_i(exe_alu_issue),
        .alu_if_write_rrf_i(exe_alu_dst_val),
        .alu_rrf_tag_i(exe_alu_rrf_tag),
        .alu_pc_i(exe_alu_pc),
        .alu_imm_i(exe_alu_imm),
        .alu_alu_op_i(exe_alu_op),
        .alu_src1_i(exe_alu_op_1),
        .alu_src_a_select_i(exe_alu_src_a),
        .alu_src2_i(exe_alu_op_2),
        .alu_src_b_select_i(exe_alu_src_b),
        // ALU输出
        .alu_result_o(alu_result),
        .alu_rrf_tag_o(alu_rrf_tag),
        .alu_rob_we_o(alu_rob_we),
        .alu_rrf_we_o(alu_rrf_we),

        // Branch 输入
        .branch_issue_i(),
        .branch_if_write_rrf_i(),
        .branch_rrf_tag_i(),
        .branch_pc_i(),
        .branch_imm_i(),
        .branch_alu_op_i(),
        .branch_src1_i(),
        .branch_src2_i(),
        .branch_opcode_i(),
        // Branch 输出
        .branch_result_o(branch_result),
        .branch_rrf_tag_o(branch_rrf_tag),
        .branch_rob_we_o(),
        .branch_rrf_we_o(),
        .branch_jump_result_o(),
        .branch_jump_addr_o(),
        .branch_if_jump_o(),

        // MemAccess 输入
        .mem_access_src1_i(exe_mem_op_1),
        .mem_access_src2_i(exe_mem_op_2),
        .mem_access_imm_i(exe_mem_imm),
        .mem_access_if_write_rrf_i(exe_mem_dst_val),
        .mem_access_issue_i(exe_mem_issue),
        .mem_access_complete_i(),
        .mem_access_load_data_from_data_memory_i(dmem_rdata_i),
        .mem_access_rrf_tag_i(exe_mem_rrf_tag),
        // MemAccess 输出
        .mem_access_rrf_we_o(mem_access_rrf_we),
        .mem_access_rob_we_o(),
        .mem_access_load_address_o(dmem_raddr_o),
        .mem_access_store_buffer_mem_we_o(dmem_we_o),
        .mem_access_store_buffer_write_address_o(dmem_waddr_o),
        .mem_access_store_buffer_write_data_o(dmem_wdata_o),
        .mem_access_load_data_o(mem_access_load_data),
        .mem_access_rrf_tag_o(mem_access_rrf_tag)

    );

    //COM stage
    SingleInstROB u_SingleInstROB (
        //input
        .clk_i(clk_i),
        .reset_i(reset_i),
        .dp1_i(rrf_allocatable),
        .dp1_addr_i(dst_rrftag),
        .pc_dp1_i(),
        .dstvalid_dp1_i(dst_en),
        .dst_dp1_i(rd_1_sw),
        .finish_ex_alu1_i(alu_rob_we),
        .finish_ex_alu1_addr_i(alu_rrf_tag),

        //output
        .commit_ptr_1_o(commit_ptr_1),
        .arfwe_1_o(arfwe_1),
        .dst_arf_1_o(dst_arf_1),
        .comnum_o(comnum)
    );



endmodule

