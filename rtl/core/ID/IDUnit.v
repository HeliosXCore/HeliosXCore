`include "consts/Consts.vh"
`include "consts/RV32Opcodes.vh"
`include "consts/ALU.vh"

module IDUnit (
    input  wire [                 31:0] inst1_i,
    output wire [  `IMM_TYPE_WIDTH-1:0] imm_type_1_o,
    output wire [         `REG_SEL-1:0] rs1_1_o,
    output wire [         `REG_SEL-1:0] rs2_1_o,
    output wire [         `REG_SEL-1:0] rd_1_o,
    output wire [ `SRC_A_SEL_WIDTH-1:0] src_a_sel_1_o,
    output wire [ `SRC_B_SEL_WIDTH-1:0] src_b_sel_1_o,
    output wire                         wr_reg_1_o,
    output wire                         uses_rs1_1_o,
    output wire                         uses_rs2_1_o,
    output wire                         illegal_instruction_1_o,
    output wire [    `ALU_OP_WIDTH-1:0] alu_op_1_o,
    output wire [      `RS_ENT_SEL-1:0] rs_ent_1_o,
    output wire [                  2:0] dmem_size_1_o,
    output wire [  `MEM_TYPE_WIDTH-1:0] dmem_type_1_o,
    output wire [     `MD_OP_WIDTH-1:0] md_req_op_1_o,
    output wire                         md_req_in_1_signed_1_o,
    output wire                         md_req_in_2_signed_1_o,
    output wire [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel_1_o
);
  //Decode Info1
  reg [  `IMM_TYPE_WIDTH-1:0] imm_type_1_id;
  reg [         `REG_SEL-1:0] rs1_1_id;
  reg [         `REG_SEL-1:0] rs2_1_id;
  reg [         `REG_SEL-1:0] rd_1_id;
  reg [ `SRC_A_SEL_WIDTH-1:0] src_a_sel_1_id;
  reg [ `SRC_B_SEL_WIDTH-1:0] src_b_sel_1_id;
  reg                         wr_reg_1_id;
  reg                         uses_rs1_1_id;
  reg                         uses_rs2_1_id;
  reg                         illegal_instruction_1_id;
  reg [    `ALU_OP_WIDTH-1:0] alu_op_1_id;
  reg [      `RS_ENT_SEL-1:0] rs_ent_1_id;
  reg [                  2:0] dmem_size_1_id;
  reg [  `MEM_TYPE_WIDTH-1:0] dmem_type_1_id;
  reg [     `MD_OP_WIDTH-1:0] md_req_op_1_id;
  reg                         md_req_in_1_signed_1_id;
  reg                         md_req_in_2_signed_1_id;
  reg [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel_1_id;
  /*
//Decode Info2
    reg [`IMM_TYPE_WIDTH-1:0] 	imm_type_2_id;
    
    reg [`REG_SEL-1:0] 		rs1_2_id;
    reg [`REG_SEL-1:0] 		rs2_2_id;
    reg [`REG_SEL-1:0] 		rd_2_id;
    reg [`SRC_A_SEL_WIDTH-1:0] 	src_a_sel_2_id;
    reg [`SRC_B_SEL_WIDTH-1:0] 	src_b_sel_2_id;
    reg 				wr_reg_2_id;
    reg 				uses_rs1_2_id;
    reg 				uses_rs2_2_id;
    reg 				illegal_instruction_2_id;
    reg [`ALU_OP_WIDTH-1:0] 	alu_op_2_id;
    reg [`RS_ENT_SEL-1:0] 	rs_ent_2_id;
    reg [2:0] 			dmem_size_2_id;
    reg [`MEM_TYPE_WIDTH-1:0] 	dmem_type_2_id;			  
    reg [`MD_OP_WIDTH-1:0] 	md_req_op_2_id;
    reg 				md_req_in_1_signed_2_id;
    reg 				md_req_in_2_signed_2_id;
    reg [`MD_OUT_SEL_WIDTH-1:0] 	md_req_out_sel_2_id;
//Additional Info
    reg 				rs1_2_eq_dst1_id;
    reg  				rs2_2_eq_dst1_id;
    reg [`SPECTAG_LEN-1:0] 	sptag1_id;
    reg [`SPECTAG_LEN-1:0] 	sptag2_id;
    reg [`SPECTAG_LEN-1:0] 	tagreg_id;
    reg 				spec1_id;
    reg 				spec2_id;
    reg [`INSN_LEN-1:0] 		inst1_id;
    reg [`INSN_LEN-1:0] 		inst2_id;
    reg 				prcond1_id;
    reg 				prcond2_id;
    reg 				inv1_id;
    reg 				inv2_id;
    reg [`ADDR_LEN-1:0] 		praddr1_id;
    reg [`ADDR_LEN-1:0] 		praddr2_id;
    reg [`ADDR_LEN-1:0] 		pc_id;
    reg [`GSH_BHR_LEN-1:0] 	bhr_id;
    reg 				isbranch1_id;
    reg 				isbranch2_id;
*/

  decoder dec1 (
      .inst_i(inst1_i),
      .imm_type_o(imm_type_1_o),
      .rs1_o(rs1_1_o),
      .rs2_o(rs2_1_o),
      .rd_o(rd_1_o),
      .src_a_sel_o(src_a_sel_1_o),
      .src_b_sel_o(src_b_sel_1_o),
      .wr_reg_o(wr_reg_1_o),
      .uses_rs1_o(uses_rs1_1_o),
      .uses_rs2_o(uses_rs2_1_o),
      .illegal_instruction_o(illegal_instruction_1_o),
      .alu_op_o(alu_op_1_o),
      .rs_ent_o(rs_ent_1_o),
      .dmem_size_o(dmem_size_1_o),
      .dmem_type_o(dmem_type_1_o),
      .md_req_op_o(md_req_op_1_o),
      .md_req_in_1_signed_o(md_req_in_1_signed_1_o),
      .md_req_in_2_signed_o(md_req_in_2_signed_1_o),
      .md_req_out_sel_o(md_req_out_sel_1_o)
  );

  always @(posedge clk_i) begin
    if (reset_i | kill_ID) begin
      imm_type_1_id <= 0;
      rs1_1_id <= 0;
      rs2_1_id <= 0;
      rd_1_id <= 0;
      src_a_sel_1_id <= 0;
      src_b_sel_1_id <= 0;
      wr_reg_1_id <= 0;
      uses_rs1_1_id <= 0;
      uses_rs2_1_id <= 0;
      illegal_instruction_1_id <= 0;
      alu_op_1_id <= 0;
      rs_ent_1_id <= 0;
      dmem_size_1_id <= 0;
      dmem_type_1_id <= 0;
      md_req_op_1_id <= 0;
      md_req_in_1_signed_1_id <= 0;
      md_req_in_2_signed_1_id <= 0;
      md_req_out_sel_1_id <= 0;
    end else if (~stall_DP) begin
      imm_type_1_id <= imm_type_1_o;
      rs1_1_id <= rs1_1_o;
      rs2_1_id <= rs2_1_o;
      rd_1_id <= rd_1_o;
      src_a_sel_1_id <= src_a_sel_1_o;
      src_b_sel_1_id <= src_b_sel_1_o;
      wr_reg_1_id <= wr_reg_1_o;
      uses_rs1_1_id <= uses_rs1_1_o;
      uses_rs2_1_id <= uses_rs2_1_o;
      illegal_instruction_1_id <= illegal_instruction_1_o;
      alu_op_1_id <= alu_op_1_o;
      rs_ent_1_id <= inv1_if ? 0 : rs_ent_1_o;
      dmem_size_1_id <= dmem_size_1_o;
      dmem_type_1_id <= dmem_type_1_o;
      md_req_op_1_id <= md_req_op_1_o;
      md_req_in_1_signed_1_id <= md_req_in_1_signed_1_o;
      md_req_in_2_signed_1_id <= md_req_in_2_signed_1_o;
      md_req_out_sel_1_id <= md_req_out_sel_1_o;
    end
  end

endmodule
