`include "consts/Consts.vh"
`default_nettype none
module RSRequestGen (
    // 指令对应的保留站类型
    input wire [`RS_ENT_SEL-1:0] inst1_rs_type_i,
    input wire [`RS_ENT_SEL-1:0] inst2_rs_type_i,

    output wire    req1_alu_o,
    output wire    req2_alu_o,
    output wire [1:0]   req_alunum_o,

    output wire    req1_branch_o,
    output wire    req2_branch_o,
    output wire [1:0]   req_branchnum_o,

    output wire    req1_mul_o,
    output wire    req2_mul_o,
    output wire [1:0]   req_mulnum_o,

    output wire    req1_ldst_o,
    output wire    req2_ldst_o,
    output wire [1:0]   req_ldstnum_o
);

  assign req1_alu_o = (inst1_rs_type_i == `RS_ENT_ALU) ? 1'b1 : 1'b0;
  assign req2_alu_o = (inst2_rs_type_i == `RS_ENT_ALU) ? 1'b1 : 1'b0;
  assign req_alunum_o = {1'b0, req1_alu_o} + {1'b0, req2_alu_o};

  assign req1_branch_o = (inst1_rs_type_i == `RS_ENT_BRANCH) ? 1'b1 : 1'b0;
  assign req2_branch_o = (inst2_rs_type_i == `RS_ENT_BRANCH) ? 1'b1 : 1'b0;
  assign req_branchnum_o = {1'b0, req1_branch_o} + {1'b0, req2_branch_o};

  assign req1_mul_o = (inst1_rs_type_i == `RS_ENT_MUL) ? 1'b1 : 1'b0;
  assign req2_mul_o = (inst2_rs_type_i == `RS_ENT_MUL) ? 1'b1 : 1'b0;
  assign req_mulnum_o = {1'b0, req1_mul_o} + {1'b0, req2_mul_o};

  assign req1_ldst_o = (inst1_rs_type_i == `RS_ENT_LDST) ? 1'b1 : 1'b0;
  assign req2_ldst_o = (inst2_rs_type_i == `RS_ENT_LDST) ? 1'b1 : 1'b0;
  assign req_ldstnum_o = {1'b0, req1_ldst_o} + {1'b0, req2_ldst_o};

endmodule  // rs_requestgenerator
`default_nettype wire
