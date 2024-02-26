`include "consts/Consts.vh"
`include "consts/ALU.vh"

module RSAluEntry (
    input wire clk_i,
    input wire reset_i,
    // 该 entry 是否忙碌
    input wire busy_i,
    // 写指令的 PC 值
    input wire [`ADDR_LEN-1:0] write_pc_i,
    // Dispatch 指令的两个操作数
    input wire [`DATA_LEN-1:0] write_op_1_i,
    input wire [`DATA_LEN-1:0] write_op_2_i,
    // 是否选择操作数
    input wire [`SRC_A_SEL_WIDTH-1:0] write_src_a_i,
    input wire [`SRC_B_SEL_WIDTH-1:0] write_src_b_i,
    // Dispatch 指令的两个操作数是否有效，无效则为 RRFTag
    input wire write_op_1_valid_i,
    input wire write_op_2_valid_i,
    // Dispatch 指令发射的立即数
    input wire [`DATA_LEN-1:0] write_imm_i,
    // Dispatch 指令写回寄存器的 RRF Tag
    input wire [`RRF_SEL-1:0] write_rrf_tag_i,
    input wire write_dst_val_i,

    // TODO: 操作数和立即数以及 PC 的选择器
    // Dispatch 指令的 ALU 操作码
    input wire [`ALU_OP_WIDTH-1:0] write_alu_op_i,
    // Dispatch 指令是否写入
    input wire we_i,

    // 执行前递的信号
    // 前五条指令执行前递的结果
    input wire [`DATA_LEN-1:0] exe_result_1_i,
    input wire [`DATA_LEN-1:0] exe_result_2_i,
    input wire [`DATA_LEN-1:0] exe_result_3_i,
    input wire [`DATA_LEN-1:0] exe_result_4_i,
    input wire [`DATA_LEN-1:0] exe_result_5_i,
    // 前五条指令执行前递的目标寄存器
    input wire [ `RRF_SEL-1:0] exe_result_1_dst_i,
    input wire [ `RRF_SEL-1:0] exe_result_2_dst_i,
    input wire [ `RRF_SEL-1:0] exe_result_3_dst_i,
    input wire [ `RRF_SEL-1:0] exe_result_4_dst_i,
    input wire [ `RRF_SEL-1:0] exe_result_5_dst_i,
    // TODO: 该指令是否被杀死

    // Issue 阶段输出
    output wire [`DATA_LEN-1:0] exe_op_1_o,
    output wire [`DATA_LEN-1:0] exe_op_2_o,
    // 两个操作数是否已经准备好
    output wire ready_o,
    output reg [`ADDR_LEN-1:0] exe_pc_o,
    output reg [`DATA_LEN-1:0] exe_imm_o,
    output reg [`RRF_SEL-1:0] exe_rrf_tag_o,
    output reg exe_dst_val_o,
    output reg [`ALU_OP_WIDTH-1:0] exe_alu_op_o,

    output reg [`SRC_A_SEL_WIDTH-1:0] exe_src_a_o,
    output reg [`SRC_B_SEL_WIDTH-1:0] exe_src_b_o
);

    reg valid_1;
    reg valid_2;
    reg [`DATA_LEN-1:0] op_1;
    reg [`DATA_LEN-1:0] op_2;

    reg next_valid_1;
    reg next_valid_2;
    reg [`DATA_LEN-1:0] next_op_1;
    reg [`DATA_LEN-1:0] next_op_2;

    // 两个操作数已经准备好且保留站 entry 有数据
    assign ready_o = busy_i & valid_1 & valid_2;
    assign exe_op_1_o = ~valid_1 & next_valid_1 ? next_op_1 : op_1;
    assign exe_op_2_o = ~valid_2 & next_valid_2 ? next_op_2 : op_2;

    always @(posedge clk_i) begin
        if (reset_i) begin
            valid_1 <= 0;
            valid_2 <= 0;
            op_1 <= 0;
            op_2 <= 0;

            exe_pc_o <= 0;
            exe_imm_o <= 0;
            exe_rrf_tag_o <= 0;
            exe_dst_val_o <= 0;
            exe_alu_op_o <= 0;

            exe_src_a_o <= 0;
            exe_src_b_o <= 0;
        end else if (we_i) begin
            exe_pc_o <= write_pc_i;
            exe_imm_o <= write_imm_i;
            exe_rrf_tag_o <= write_rrf_tag_i;
            exe_dst_val_o <= write_dst_val_i;
            exe_alu_op_o <= write_alu_op_i;
            exe_src_a_o <= write_src_a_i;
            exe_src_b_o <= write_src_b_i;

            op_1 <= write_op_1_i;
            op_2 <= write_op_2_i;
            valid_1 <= write_op_1_valid_i;
            valid_2 <= write_op_2_valid_i;
        end else begin
            op_1 <= next_op_1;
            op_2 <= next_op_2;
            valid_1 <= next_valid_1;
            valid_2 <= next_valid_2;
        end
    end

    // 用于维护第一个操作数是否准备好
    SourceManager source_manager_1 (
        .src_i(op_1),
        .src_ready_i(valid_1),

        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),

        .exe_dst_1_i(exe_result_1_dst_i),
        .exe_dst_2_i(exe_result_2_dst_i),
        .exe_dst_3_i(exe_result_3_dst_i),
        .exe_dst_4_i(exe_result_4_dst_i),
        .exe_dst_5_i(exe_result_5_dst_i),

        .src_o(next_op_1),
        .resolved_o(next_valid_1)
    );

    // 用于维护第二个操作数是否准备好
    SourceManager source_manager_2 (
        .src_i(op_2),
        .src_ready_i(valid_2),

        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),

        .exe_dst_1_i(exe_result_1_dst_i),
        .exe_dst_2_i(exe_result_2_dst_i),
        .exe_dst_3_i(exe_result_3_dst_i),
        .exe_dst_4_i(exe_result_4_dst_i),
        .exe_dst_5_i(exe_result_5_dst_i),

        .src_o(next_op_2),
        .resolved_o(next_valid_2)
    );

endmodule

