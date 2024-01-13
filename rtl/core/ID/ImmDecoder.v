`include "consts/Consts.vh"
`default_nettype none
module ImmDecoder (
    input wire [`INSN_LEN-1:0] inst,
    input wire [`IMM_TYPE_WIDTH-1:0] imm_type,
    output wire [`DATA_LEN-1:0] imm
);

assign imm = (imm_type == `IMM_I) ? {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20]} :
             (imm_type == `IMM_S) ? {{21{inst[31]}}, inst[30:25], inst[11:8], inst[7]} :
             (imm_type == `IMM_U) ? {inst[31], inst[30:20], inst[19:12], 12'b0} :
             (imm_type == `IMM_J) ? {{12{inst[31]}}, inst[19:12], inst[20], inst[30:25], inst[24:21], 1'b0} :
             {{21{inst[31]}}, inst[30:25], inst[24:21], inst[20]};

endmodule
`default_nettype wire
