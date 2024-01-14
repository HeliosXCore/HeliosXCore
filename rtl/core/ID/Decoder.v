`include "consts/Consts.vh"
`include "consts/RV32Opcodes.vh"
`include "consts/ALU.vh"

`default_nettype none
module Decoder (
    input  wire [               31:0] inst_i,      //指令
    output reg  [`IMM_TYPE_WIDTH-1:0] imm_type_o,  //当前指令的立即数类型
    output wire [       `REG_SEL-1:0] rs1_o,       //当前指令中的第一个源操作数寄存器地址
    output wire [       `REG_SEL-1:0] rs2_o,       //当前指令中的第二个源操作数寄存器地址
    output wire [       `REG_SEL-1:0] rd_o,        //当前指令的目标寄存器地址

    output wire [`SRC_A_SEL_WIDTH-1:0] src_a_sel_o,            //用于选择ALU操作数
    output wire [`SRC_B_SEL_WIDTH-1:0] src_b_sel_o,            //用于选择ALU操作数
    output wire                        wr_reg_o,               //是否将数据写入目标寄存器
    output wire                        uses_rs1_o,             //rs1的有效信号
    output wire                        uses_rs2_o,             //rs2的有效信号
    output wire                        illegal_instruction_o,  //表示该指令未在该处理器中定义
    output wire [   `ALU_OP_WIDTH-1:0] alu_op_o,               //ALU操作类型
    output wire [     `RS_ENT_SEL-1:0] rs_ent_o,               //保留站ID
    //output reg 			  dmem_use,
    //output reg 			  dmem_write,

    output wire [                2:0] dmem_size_o,  //决定Load/Store指令数据的大小
    output wire [`MEM_TYPE_WIDTH-1:0] dmem_type_o,  //决定Load/Store指令数据的大小

    output wire [     `MD_OP_WIDTH-1:0] md_req_op_o,           //运算类型（乘、除、模）
    output wire                         md_req_in_1_signed_o,  //乘法器的第一个源操作数是否有符号
    output wire                         md_req_in_2_signed_o,  //乘法器的第二个源操作数是否有符号
    output wire [`MD_OUT_SEL_WIDTH-1:0] md_req_out_sel_o       //决定乘法器输出的哪一部分为最后的乘法结果:高32位还是低32位
);

    wire [`ALU_OP_WIDTH-1:0] srl_or_sra;
    wire [`ALU_OP_WIDTH-1:0] add_or_sub;
    wire [  `RS_ENT_SEL-1:0] rs_ent_md;

    wire [              6:0] opcode = inst_i[6:0];
    wire [              6:0] funct7 = inst_i[31:25];
    wire [             11:0] funct12 = inst_i[31:20];
    wire [              2:0] funct3 = inst_i[14:12];
    // reg [`MD_OP_WIDTH-1:0]   md_req_op;
    reg  [`ALU_OP_WIDTH-1:0] alu_op_arith;

    assign rd_o = inst_i[11:7];
    assign rs1_o = inst_i[19:15];
    assign rs2_o = inst_i[24:20];

    assign dmem_size_o = {1'b0, funct3[1:0]};
    assign dmem_type_o = funct3;

    assign imm_type_o = (opcode == `RV32_LOAD) ? `IMM_I :
                        (opcode == `RV32_STORE) ? `IMM_S :
                        (opcode == `RV32_JAL) ? `IMM_J :
                        (opcode == `RV32_JALR) ? `IMM_J :
                        (opcode == `RV32_LUI) ? `IMM_U :
                        (opcode == `RV32_AUIPC) ? `IMM_U :
                        (opcode == `RV32_OP) ? `IMM_I :
                        (opcode == `RV32_OP_IMM) ? `IMM_I :
                        `IMM_I;

    assign src_a_sel_o = (opcode == `RV32_LOAD) ? `SRC_A_RS1 :
                         (opcode == `RV32_STORE) ? `SRC_A_RS1 :
                         (opcode == `RV32_JAL) ? `SRC_A_PC :
                         (opcode == `RV32_JALR) ? `SRC_A_PC :
                         (opcode == `RV32_LUI) ? `SRC_A_ZERO :
                         (opcode == `RV32_AUIPC) ? `SRC_A_PC :
                         (opcode == `RV32_OP) ? `SRC_A_RS1 :
                         (opcode == `RV32_OP_IMM) ? `SRC_A_RS1 :
                         `SRC_A_RS1;

    assign src_b_sel_o = (opcode == `RV32_LOAD) ? `SRC_B_IMM :
                         (opcode == `RV32_STORE) ? `SRC_B_IMM :
                         (opcode == `RV32_JAL) ? `SRC_B_FOUR :
                         (opcode == `RV32_JALR) ? `SRC_B_FOUR :
                         (opcode == `RV32_LUI) ? `SRC_B_IMM :
                         (opcode == `RV32_AUIPC) ? `SRC_B_IMM :
                         (opcode == `RV32_OP) ? `SRC_B_RS2 :
                         (opcode == `RV32_OP_IMM) ? `SRC_B_IMM :
                         `SRC_B_IMM;

    assign wr_reg_o = (opcode == `RV32_LOAD) ? 1'b1 :
                      (opcode == `RV32_STORE) ? 1'b0 :
                      (opcode == `RV32_JAL) ? 1'b1 :
                      (opcode == `RV32_JALR) ? 1'b1 :
                      (opcode == `RV32_LUI) ? 1'b1 :
                      (opcode == `RV32_AUIPC) ? 1'b1 :
                      (opcode == `RV32_OP) ? 1'b1 :
                      (opcode == `RV32_OP_IMM) ? 1'b1 :
                      1'b0;

    assign uses_rs1_o = (opcode == `RV32_LOAD) ? 1'b1 :
                        (opcode == `RV32_STORE) ? 1'b1 :
                        (opcode == `RV32_JAL) ? 1'b0 :
                        (opcode == `RV32_JALR) ? 1'b0 :
                        (opcode == `RV32_LUI) ? 1'b0 :
                        (opcode == `RV32_AUIPC) ? 1'b0 :
                        (opcode == `RV32_OP) ? 1'b1 :
                        (opcode == `RV32_OP_IMM) ? 1'b1 :
                        1'b1;

    assign uses_rs2_o = (opcode == `RV32_LOAD) ? 1'b0 :
                        (opcode == `RV32_STORE) ? 1'b1 :
                        (opcode == `RV32_JAL) ? 1'b0 :
                        (opcode == `RV32_JALR) ? 1'b0 :
                        (opcode == `RV32_LUI) ? 1'b0 :
                        (opcode == `RV32_AUIPC) ? 1'b0 :
                        (opcode == `RV32_OP) ? 1'b1 :
                        (opcode == `RV32_OP_IMM) ? 1'b0 :
                        1'b0;

    assign illegal_instruction_o = (opcode == `RV32_LOAD) ? 1'b0 :
                                   (opcode == `RV32_STORE) ? 1'b0 :
                                   (opcode == `RV32_JAL) ? 1'b0 :
                                   (opcode == `RV32_JALR) ? 1'b0 :
                                   (opcode == `RV32_LUI) ? 1'b0 :
                                   (opcode == `RV32_AUIPC) ? 1'b0 :
                                   (opcode == `RV32_OP) ? 1'b0 :
                                   (opcode == `RV32_OP_IMM) ? 1'b0 :
                                   1'b1;

    assign alu_op_o = (opcode == `RV32_LOAD) ? `ALU_OP_ADD :
                      (opcode == `RV32_STORE) ? `ALU_OP_ADD :
                      (opcode == `RV32_JAL) ? `ALU_OP_ADD :
                      (opcode == `RV32_JALR) ? `ALU_OP_ADD :
                      (opcode == `RV32_LUI) ? `ALU_OP_ADD :
                      (opcode == `RV32_AUIPC) ? `ALU_OP_ADD :
                      (opcode == `RV32_OP) ? alu_op_arith :
                      (opcode == `RV32_OP_IMM) ? alu_op_arith :
                      `ALU_OP_ADD;

    assign rs_ent_o = (opcode == `RV32_LOAD) ? `RS_ENT_LDST :
                      (opcode == `RV32_STORE) ? `RS_ENT_LDST :
                      (opcode == `RV32_JAL) ? `RS_ENT_JAL :
                      (opcode == `RV32_JALR) ? `RS_ENT_JALR :
                      (opcode == `RV32_LUI) ? `RS_ENT_ALU :
                      (opcode == `RV32_AUIPC) ? `RS_ENT_ALU :
                      (opcode == `RV32_OP) ? `RS_ENT_ALU :
                      (opcode == `RV32_OP_IMM) ? `RS_ENT_ALU :
                      `RS_ENT_ALU;

    assign add_or_sub = ((opcode == `RV32_OP) && (funct7[5])) ? `ALU_OP_SUB : `ALU_OP_ADD;
    assign srl_or_sra = (funct7[5]) ? `ALU_OP_SRA : `ALU_OP_SRL;

    assign alu_op_arith = (funct3 == `RV32_FUNCT3_ADD_SUB) ? add_or_sub :
                          (funct3 == `RV32_FUNCT3_SLL) ? `ALU_OP_SLL :
                          (funct3 == `RV32_FUNCT3_SLT) ? `ALU_OP_SLT :
                          (funct3 == `RV32_FUNCT3_SLTU) ? `ALU_OP_SLTU :
                          (funct3 == `RV32_FUNCT3_XOR) ? `ALU_OP_XOR :
                          (funct3 == `RV32_FUNCT3_SRA_SRL) ? srl_or_sra :
                          (funct3 == `RV32_FUNCT3_OR) ? `ALU_OP_OR :
                          (funct3 == `RV32_FUNCT3_AND) ? `ALU_OP_AND :
                          `ALU_OP_ADD;


    //assign md_req_valid = uses_md;
    assign rs_ent_md = ((funct3 == `RV32_FUNCT3_MUL) || (funct3 == `RV32_FUNCT3_MULH) || (funct3 == `RV32_FUNCT3_MULHSU) || (funct3 == `RV32_FUNCT3_MULHU)) ? `RS_ENT_MUL : `RS_ENT_DIV;

    assign md_req_op_o = (funct3 == `RV32_FUNCT3_MUL) ? `MD_OP_MUL :
                         (funct3 == `RV32_FUNCT3_MULH) ? `MD_OP_MUL :
                         (funct3 == `RV32_FUNCT3_MULHSU) ? `MD_OP_MUL :
                         (funct3 == `RV32_FUNCT3_MULHU) ? `MD_OP_MUL :
                         (funct3 == `RV32_FUNCT3_DIV) ? `MD_OP_DIV :
                         (funct3 == `RV32_FUNCT3_DIVU) ? `MD_OP_DIV :
                         (funct3 == `RV32_FUNCT3_REM) ? `MD_OP_REM :
                         (funct3 == `RV32_FUNCT3_REMU) ? `MD_OP_REM :
                         `MD_OP_MUL;

    assign md_req_in_1_signed_o = (funct3 == `RV32_FUNCT3_MUL) ? 0 :
                                  (funct3 == `RV32_FUNCT3_MULH) ? 1 :
                                  (funct3 == `RV32_FUNCT3_MULHSU) ? 1 :
                                  (funct3 == `RV32_FUNCT3_MULHU) ? 0 :
                                  (funct3 == `RV32_FUNCT3_DIV) ? 1 :
                                  (funct3 == `RV32_FUNCT3_DIVU) ? 0 :
                                  (funct3 == `RV32_FUNCT3_REM) ? 1 :
                                  (funct3 == `RV32_FUNCT3_REMU) ? 0 :
                                  0;

    assign md_req_in_2_signed_o = (funct3 == `RV32_FUNCT3_MUL) ? 0 :
                                  (funct3 == `RV32_FUNCT3_MULH) ? 1 :
                                  (funct3 == `RV32_FUNCT3_MULHSU) ? 0 :
                                  (funct3 == `RV32_FUNCT3_MULHU) ? 0 :
                                  (funct3 == `RV32_FUNCT3_DIV) ? 1 :
                                  (funct3 == `RV32_FUNCT3_DIVU) ? 0 :
                                  (funct3 == `RV32_FUNCT3_REM) ? 1 :
                                  (funct3 == `RV32_FUNCT3_REMU) ? 0 :
                                  0;

    assign md_req_out_sel_o = (funct3 == `RV32_FUNCT3_MUL) ? `MD_OUT_LO :
                              (funct3 == `RV32_FUNCT3_MULH) ? `MD_OUT_HI :
                              (funct3 == `RV32_FUNCT3_MULHSU) ? `MD_OUT_HI :
                              (funct3 == `RV32_FUNCT3_MULHU) ? `MD_OUT_HI :
                              (funct3 == `RV32_FUNCT3_DIV) ? `MD_OUT_LO :
                              (funct3 == `RV32_FUNCT3_DIVU) ? `MD_OUT_LO :
                              (funct3 == `RV32_FUNCT3_REM) ? `MD_OUT_REM :
                              (funct3 == `RV32_FUNCT3_REMU) ? `MD_OUT_REM :
                              `MD_OUT_LO;

endmodule  // decoder
`default_nettype wire
