`include "consts/Consts.vh"
`include "consts/RV32Opcodes.vh"
`include "consts/ALU.vh"

module IDUnit (
    input wire [31:0] inst1_i,
    input wire        clk_i,
    input wire        reset_i,
    input wire        stall_IF,
    input wire        kill_IF,
    input wire        stall_ID,
    input wire        kill_ID,
    input wire        stall_DP,
    input wire        kill_DP,

    output reg [`IMM_TYPE_WIDTH-1:0] imm_type_1_o,

    output reg [`DATA_LEN-1:0] imm_1_o,

    output reg [         `REG_SEL-1:0] rs1_1_o,
    output reg [         `REG_SEL-1:0] rs2_1_o,
    output reg [         `REG_SEL-1:0] rd_1_o,
    output reg [ `SRC_A_SEL_WIDTH-1:0] src_a_sel_1_o,
    output reg [ `SRC_B_SEL_WIDTH-1:0] src_b_sel_1_o,
    output reg                         wr_reg_1_o,
    output reg                         uses_rs1_1_o,
    output reg                         uses_rs2_1_o,
    output reg                         illegal_instruction_1_o,
    output reg [    `ALU_OP_WIDTH-1:0] alu_op_1_o,
    output reg [      `RS_ENT_SEL-1:0] rs_ent_1_o,
    output reg [                  2:0] dmem_size_1_o,
    output reg [  `MEM_TYPE_WIDTH-1:0] dmem_type_1_o,
    output reg [     `MD_OP_WIDTH-1:0] md_req_op_1_o,
    output reg                         md_req_in_1_signed_1_o,
    output reg                         md_req_in_2_signed_1_o,
    output reg [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel_1_o
);
    //译码结果寄存器
    // reg [  `IMM_TYPE_WIDTH-1:0] imm_type_1_id;

    // reg [        `DATA_LEN-1:0] imm_1_id;

    // reg [         `REG_SEL-1:0] rs1_1_id;
    // reg [         `REG_SEL-1:0] rs2_1_id;
    // reg [         `REG_SEL-1:0] rd_1_id;
    // reg [ `SRC_A_SEL_WIDTH-1:0] src_a_sel_1_id;
    // reg [ `SRC_B_SEL_WIDTH-1:0] src_b_sel_1_id;
    // reg                         wr_reg_1_id;
    // reg                         uses_rs1_1_id;
    // reg                         uses_rs2_1_id;
    // reg                         illegal_instruction_1_id;
    // reg [    `ALU_OP_WIDTH-1:0] alu_op_1_id;
    // reg [      `RS_ENT_SEL-1:0] rs_ent_1_id;
    // reg [                  2:0] dmem_size_1_id;
    // reg [  `MEM_TYPE_WIDTH-1:0] dmem_type_1_id;
    // reg [     `MD_OP_WIDTH-1:0] md_req_op_1_id;
    // reg                         md_req_in_1_signed_1_id;
    // reg                         md_req_in_2_signed_1_id;
    // reg [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel_1_id;

    wire [  `IMM_TYPE_WIDTH-1:0] imm_type_1;

    wire [        `DATA_LEN-1:0] imm_1;

    wire [         `REG_SEL-1:0] rs1_1;
    wire [         `REG_SEL-1:0] rs2_1;
    wire [         `REG_SEL-1:0] rd_1;
    wire [ `SRC_A_SEL_WIDTH-1:0] src_a_sel_1;
    wire [ `SRC_B_SEL_WIDTH-1:0] src_b_sel_1;
    wire                         wr_reg_1;
    wire                         uses_rs1_1;
    wire                         uses_rs2_1;
    wire                         illegal_instruction_1;
    wire [    `ALU_OP_WIDTH-1:0] alu_op_1;
    wire [      `RS_ENT_SEL-1:0] rs_ent_1;
    wire [                  2:0] dmem_size_1;
    wire [  `MEM_TYPE_WIDTH-1:0] dmem_type_1;
    wire [     `MD_OP_WIDTH-1:0] md_req_op_1;
    wire                         md_req_in_1_signed_1;
    wire                         md_req_in_2_signed_1;
    wire [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel_1;

    Decoder dec1 (
        .inst_i(inst1_i),
        .imm_type_o(imm_type_1),
        .rs1_o(rs1_1),
        .rs2_o(rs2_1),
        .rd_o(rd_1),
        .src_a_sel_o(src_a_sel_1),
        .src_b_sel_o(src_b_sel_1),
        .wr_reg_o(wr_reg_1),
        .uses_rs1_o(uses_rs1_1),
        .uses_rs2_o(uses_rs2_1),
        .illegal_instruction_o(illegal_instruction_1),
        .alu_op_o(alu_op_1),
        .rs_ent_o(rs_ent_1),
        .dmem_size_o(dmem_size_1),
        .dmem_type_o(dmem_type_1),
        .md_req_op_o(md_req_op_1),
        .md_req_in_1_signed_o(md_req_in_1_signed_1),
        .md_req_in_2_signed_o(md_req_in_2_signed_1),
        .md_req_out_sel_o(md_req_out_sel_1)
    );

    ImmDecoder immdec1 (
        .inst(inst1_i),
        .imm_type(imm_type_1),
        .imm(imm_1)
    );

    always @(posedge clk_i) begin
        if (reset_i | kill_ID) begin
            imm_type_1_o <= 0;
            imm_1_o <= 0;
            rs1_1_o <= 0;
            rs2_1_o <= 0;
            rd_1_o <= 0;
            src_a_sel_1_o <= 0;
            src_b_sel_1_o <= 0;
            wr_reg_1_o <= 0;
            uses_rs1_1_o <= 0;
            uses_rs2_1_o <= 0;
            illegal_instruction_1_o <= 0;
            alu_op_1_o <= 0;
            rs_ent_1_o <= 0;
            dmem_size_1_o <= 0;
            dmem_type_1_o <= 0;
            md_req_op_1_o <= 0;
            md_req_in_1_signed_1_o <= 0;
            md_req_in_2_signed_1_o <= 0;
            md_req_out_sel_1_o <= 0;
        end else if (~stall_DP) begin
            imm_type_1_o <= imm_type_1;
            imm_1_o <= imm_1;
            rs1_1_o <= rs1_1;
            rs2_1_o <= rs2_1;
            rd_1_o <= rd_1;
            src_a_sel_1_o <= src_a_sel_1;
            src_b_sel_1_o <= src_b_sel_1;
            wr_reg_1_o <= wr_reg_1;
            uses_rs1_1_o <= uses_rs1_1;
            uses_rs2_1_o <= uses_rs2_1;
            illegal_instruction_1_o <= illegal_instruction_1;
            alu_op_1_o <= alu_op_1;
            rs_ent_1_o <= rs_ent_1;
            dmem_size_1_o <= dmem_size_1;
            dmem_type_1_o <= dmem_type_1;
            md_req_op_1_o <= md_req_op_1;
            md_req_in_1_signed_1_o <= md_req_in_1_signed_1;
            md_req_in_2_signed_1_o <= md_req_in_2_signed_1;
            md_req_out_sel_1_o <= md_req_out_sel_1;
        end
    end



endmodule
