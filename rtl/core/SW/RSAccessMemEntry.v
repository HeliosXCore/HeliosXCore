`include "consts/Consts.vh"

module RSAccessMemEntry (
    input wire clk_i,
    input wire reset_i,
    input wire busy_i,
    input wire [`ADDR_LEN-1:0] write_pc_i,
    input wire [`DATA_LEN-1:0] write_src_op_1_i,
    input wire [`DATA_LEN-1:0] write_src_op_2_i,
    input wire write_valid_1_i,
    input wire write_valid_2_i,
    input wire [`DATA_LEN-1:0] write_imm_i,
    input wire [`RRF_SEL-1:0] write_rrf_tag_i,
    input wire write_dst_val_i,
    input wire wen_i,

    output wire [`DATA_LEN-1:0] exe_src_op_1_o,
    output wire [`DATA_LEN-1:0] exe_src_op_2_o,
    output wire ready_o,
    output reg [`ADDR_LEN-1:0] exe_pc_o,
    output reg [`DATA_LEN-1:0] exe_imm_o,
    output reg [`RRF_SEL-1:0] exe_rrf_tag_o,
    output reg exe_dst_val_o,


    input wire [`DATA_LEN-1:0] exe_result_1_i,
    input wire [`DATA_LEN-1:0] exe_result_2_i,
    input wire [`DATA_LEN-1:0] exe_result_3_i,
    input wire [`DATA_LEN-1:0] exe_result_4_i,
    input wire [`DATA_LEN-1:0] exe_result_5_i,

    input wire [`RRF_SEL-1:0] exe_result_1_dst_i,
    input wire [`RRF_SEL-1:0] exe_result_2_dst_i,
    input wire [`RRF_SEL-1:0] exe_result_3_dst_i,
    input wire [`RRF_SEL-1:0] exe_result_4_dst_i,
    input wire [`RRF_SEL-1:0] exe_result_5_dst_i
);

    reg valid_1;
    reg valid_2;
    reg [`DATA_LEN-1:0] op_1;
    reg [`DATA_LEN-1:0] op_2;

    reg next_valid_1;
    reg next_valid_2;
    reg [`DATA_LEN-1:0] next_op_1;
    reg [`DATA_LEN-1:0] next_op_2;

    wire [`DATA_LEN-1:0] write_op_1;
    wire [`DATA_LEN-1:0] write_op_2;
    wire write_valid_1;
    wire write_valid_2;

    wire write_op_update_1;
    wire write_op_update_2;

    assign write_op_update_1 = (wen_i & ~write_valid_1_i) ? 
                     (exe_result_1_dst_i == write_src_op_1_i[`RRF_SEL-1:0]) |
                     (exe_result_2_dst_i == write_src_op_1_i[`RRF_SEL-1:0]) |
                     (exe_result_3_dst_i == write_src_op_1_i[`RRF_SEL-1:0]) |
                     (exe_result_4_dst_i == write_src_op_1_i[`RRF_SEL-1:0]) |
                     (exe_result_5_dst_i == write_src_op_1_i[`RRF_SEL-1:0]) : 0;

    assign write_op_update_2 = (wen_i & ~write_valid_2_i) ? 
                     (exe_result_1_dst_i == write_src_op_2_i[`RRF_SEL-1:0]) |
                     (exe_result_2_dst_i == write_src_op_2_i[`RRF_SEL-1:0]) |
                     (exe_result_3_dst_i == write_src_op_2_i[`RRF_SEL-1:0]) |
                     (exe_result_4_dst_i == write_src_op_2_i[`RRF_SEL-1:0]) |
                     (exe_result_5_dst_i == write_src_op_2_i[`RRF_SEL-1:0]) : 0;

    assign write_op_1 = (~write_op_update_1) ? write_src_op_1_i:
        (exe_result_1_dst_i == write_src_op_1_i[`RRF_SEL-1:0]) ? exe_result_1_i :
        (exe_result_2_dst_i == write_src_op_1_i[`RRF_SEL-1:0]) ? exe_result_2_i :
        (exe_result_3_dst_i == write_src_op_1_i[`RRF_SEL-1:0]) ? exe_result_3_i :
        (exe_result_4_dst_i == write_src_op_1_i[`RRF_SEL-1:0]) ? exe_result_4_i :
        (exe_result_5_dst_i == write_src_op_1_i[`RRF_SEL-1:0]) ? exe_result_5_i : write_src_op_1_i;

    assign write_op_2 = (~write_op_update_2) ? write_src_op_2_i:
        (exe_result_1_dst_i == write_src_op_2_i[`RRF_SEL-1:0]) ? exe_result_1_i :
        (exe_result_2_dst_i == write_src_op_2_i[`RRF_SEL-1:0]) ? exe_result_2_i :
        (exe_result_3_dst_i == write_src_op_2_i[`RRF_SEL-1:0]) ? exe_result_3_i :
        (exe_result_4_dst_i == write_src_op_2_i[`RRF_SEL-1:0]) ? exe_result_4_i :
        (exe_result_5_dst_i == write_src_op_2_i[`RRF_SEL-1:0]) ? exe_result_5_i : write_src_op_2_i;

    assign write_valid_1 = write_valid_1_i | write_op_update_1;
    assign write_valid_2 = write_valid_2_i | write_op_update_2;

    // 两个操作数已经准备好且保留站 entry 有数据
    assign ready_o = busy_i & valid_1 & valid_2;
    assign exe_src_op_1_o = ~valid_1 & next_valid_1 ? next_op_1 : op_1;
    assign exe_src_op_2_o = ~valid_2 & next_valid_2 ? next_op_2 : op_2;

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
        end else if (wen_i) begin
            exe_pc_o <= write_pc_i;
            exe_imm_o <= write_imm_i;
            exe_rrf_tag_o <= write_rrf_tag_i;
            exe_dst_val_o <= write_dst_val_i;

            // op_1 <= write_src_op_1_i;
            // op_2 <= write_src_op_2_i;
            // valid_1 <= write_valid_1_i;
            // valid_2 <= write_valid_2_i;

            op_1 <= write_op_1;
            op_2 <= write_op_2;
            valid_1 <= write_valid_1;
            valid_2 <= write_valid_2;
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
