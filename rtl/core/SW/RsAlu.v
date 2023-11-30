`include "consts/Consts.v"
`include "consts/ALU.v"

// ALU 保留站 Entry
module RsAluEntry(
    input wire clk,
    input wire reset,
    input wire busy,
    // 分配指令 pc
    input wire [`ADDR_LEN-1: 0] write_pc_i,
    // 分配指令的操作数
    input wire [`DATA_LEN-1: 0] write_op_1_i,
    input wire [`DATA_LEN-1: 0] write_op_2_i,
    // 分配指令操作数是否有效
    input wire write_valid_1_i,
    input wire write_valid_2_i,
    // 写立即数
    input wire [`DATA_LEN-1: 0] write_imm_i,
    // 写回寄存器的 RRF Tag
    input wire [`RRF_SEL-1: 0] write_rrf_tag_i,
    // 是否写回
    input wire is_write_dst_i,
    // 指令 ALU 类型
    input wire [`ADDR_LEN-1: 0] write_alu_op_i,
    input wire we,


);

endmodule

module RsAlu(

)

endmodule;