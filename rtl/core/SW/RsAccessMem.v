`include "consts/Consts.vh"

module RSAccessMem (
    input wire clk_i,
    input wire reset_i,
    input wire next_rrf_cycle_i,
    input wire clear_busy_i,
    input wire [`LDST_ENT_SEL-1:0] issue_addr_i,
    input wire we_1_i,
    input wire we_2_i,
    // 分配保留站地址
    input wire [`LDST_ENT_SEL-1:0] write_addr_1_i,
    input wire [`LDST_ENT_SEL-1:0] write_addr_2_i,
    // 分配的两条指令的 PC 值
    input wire [`ADDR_LEN-1:0] write_pc_1_i,
    input wire [`ADDR_LEN-1:0] write_pc_2_i,
    // 分配的两条指令的两个操作数
    input wire [`DATA_LEN-1:0] write_src_op_1_1_i,
    input wire [`DATA_LEN-1:0] write_src_op_1_2_i,
    input wire [`DATA_LEN-1:0] write_src_op_2_1_i,
    input wire [`DATA_LEN-1:0] write_src_op_2_2_i,
    // 两个操作数是否有效
    input wire write_valid_1_1_i,
    input wire write_valid_1_2_i,
    input wire write_valid_2_1_i,
    input wire write_valid_2_2_i,
    // 分配的两条指令的立即数的值
    input wire [`DATA_LEN-1:0] write_imm_1_i,
    input wire [`DATA_LEN-1:0] write_imm_2_i,
    // 分配的两条指令的目标寄存器的 RRF tag
    input wire [`RRF_SEL-1:0] write_rrf_tag_1_i,
    input wire [`RRF_SEL-1:0] write_rrf_tag_2_i,
    // 分配的两条指令是否要写回寄存器
    input wire write_dst_val_1_i,
    input wire write_dst_val_2_i,

    // 执行前递信号
    input wire [`DATA_LEN-1:0] exe_result_1_i,
    input wire [`DATA_LEN-1:0] exe_result_2_i,
    input wire [`DATA_LEN-1:0] exe_result_3_i,
    input wire [`DATA_LEN-1:0] exe_result_4_i,
    input wire [`DATA_LEN-1:0] exe_result_5_i,
    input wire [ `RRF_SEL-1:0] exe_result_1_dst_i,
    input wire [ `RRF_SEL-1:0] exe_result_2_dst_i,
    input wire [ `RRF_SEL-1:0] exe_result_3_dst_i,
    input wire [ `RRF_SEL-1:0] exe_result_4_dst_i,
    input wire [ `RRF_SEL-1:0] exe_result_5_dst_i,

    // 输出信号
    output reg  [`LDST_ENT_NUM-1:0] busy_vector_o,
    output wire [`LDST_ENT_NUM-1:0] previous_busy_vector_next_o,

    // 输出的源操作数信号
    output reg [`DATA_LEN-1:0] exe_src_op_1_o,
    output reg [`DATA_LEN-1:0] exe_src_op_2_o,
    // 指令是否准备好
    output reg [`LDST_ENT_NUM-1:0] ready_vector_o,
    // 输出的 PC 值
    output reg [`ADDR_LEN-1:0] exe_pc_o,
    // 输出的立即数
    output reg [`DATA_LEN-1:0] exe_imm_o,
    // 输出的目标寄存器的 RRF tag
    output reg [`RRF_SEL-1:0] exe_rrf_tag_o,
    // 输出的目标寄存器是否有效
    output reg exe_dst_val_o
);

    // 一个保留站中存储 4 个Entry
    wire [`DATA_LEN-1:0] exe_src_op_1      [0:`LDST_ENT_NUM-1];
    wire [`DATA_LEN-1:0] exe_src_op_2      [0:`LDST_ENT_NUM-1];
    wire                 ready             [0:`LDST_ENT_NUM-1];
    wire [`ADDR_LEN-1:0] exe_pc            [0:`LDST_ENT_NUM-1];
    wire [`DATA_LEN-1:0] exe_imm           [0:`LDST_ENT_NUM-1];
    wire [ `RRF_SEL-1:0] exe_rrf_tag       [0:`LDST_ENT_NUM-1];
    wire                 exe_dst_val       [0:`LDST_ENT_NUM-1];

    wire                 select_rs_entry_0;
    wire                 select_rs_entry_1;
    wire                 select_rs_entry_2;
    wire                 select_rs_entry_3;

    assign select_rs_entry_0 = (we_1_i && (write_addr_1_i == 0)) || (we_2_i && (write_addr_2_i == 0));
    assign select_rs_entry_1 = (we_1_i && (write_addr_1_i == 1)) || (we_2_i && (write_addr_2_i == 1));
    assign select_rs_entry_2 = (we_1_i && (write_addr_1_i == 2)) || (we_2_i && (write_addr_2_i == 2));
    assign select_rs_entry_3 = (we_1_i && (write_addr_1_i == 3)) || (we_2_i && (write_addr_2_i == 3));

    wire select_write_signal_0_1;
    wire select_write_signal_0_2;
    wire select_write_signal_1_1;
    wire select_write_signal_1_2;
    wire select_write_signal_2_1;
    wire select_write_signal_2_2;
    wire select_write_signal_3_1;
    wire select_write_signal_3_2;

    assign select_write_signal_0_1 = we_1_i && (write_addr_1_i == 0);
    assign select_write_signal_0_2 = we_2_i && (write_addr_2_i == 0);
    assign select_write_signal_1_1 = we_1_i && (write_addr_1_i == 1);
    assign select_write_signal_1_2 = we_2_i && (write_addr_2_i == 1);
    assign select_write_signal_2_1 = we_1_i && (write_addr_1_i == 2);
    assign select_write_signal_2_2 = we_2_i && (write_addr_2_i == 2);
    assign select_write_signal_3_1 = we_1_i && (write_addr_1_i == 3);
    assign select_write_signal_3_2 = we_2_i && (write_addr_2_i == 3);

    RSAccessMemEntry entry_0 (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .busy_i(busy_vector_o[0]),
        .write_pc_i(select_write_signal_0_1 ? write_pc_1_i : select_write_signal_0_2 ? write_pc_2_i : '0),
        .write_src_op_1_i(select_write_signal_0_1 ? write_src_op_1_1_i : select_write_signal_0_2 ? write_src_op_2_1_i : '0),
        .write_src_op_2_i(select_write_signal_0_1 ? write_src_op_1_2_i : select_write_signal_0_2 ? write_src_op_2_2_i : '0),
        .write_valid_1_i(select_write_signal_0_1 ? write_valid_1_1_i : select_write_signal_0_2 ? write_valid_2_1_i : '0),
        .write_valid_2_i(select_write_signal_0_1 ? write_valid_1_2_i : select_write_signal_0_2 ? write_valid_2_2_i : '0),
        .write_imm_i(select_write_signal_0_1 ? write_imm_1_i : select_write_signal_0_2 ? write_imm_2_i : '0),
        .write_rrf_tag_i(select_write_signal_0_1 ? write_rrf_tag_1_i : select_write_signal_0_2 ? write_rrf_tag_2_i : '0),
        .write_dst_val_i(select_write_signal_0_1 ? write_dst_val_1_i : select_write_signal_0_2 ? write_dst_val_2_i : '0),
        .wen_i(select_rs_entry_0),
        .exe_src_op_1_o(exe_src_op_1[0]),
        .exe_src_op_2_o(exe_src_op_2[0]),
        .ready_o(ready[0]),
        .exe_pc_o(exe_pc[0]),
        .exe_imm_o(exe_imm[0]),
        .exe_rrf_tag_o(exe_rrf_tag[0]),
        .exe_dst_val_o(exe_dst_val[0]),
        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),
        .exe_result_1_dst_i(exe_result_1_dst_i),
        .exe_result_2_dst_i(exe_result_2_dst_i),
        .exe_result_3_dst_i(exe_result_3_dst_i),
        .exe_result_4_dst_i(exe_result_4_dst_i),
        .exe_result_5_dst_i(exe_result_5_dst_i)
    );

    RSAccessMemEntry entry_1 (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .busy_i(busy_vector_o[1]),
        .write_pc_i(select_write_signal_1_1 ? write_pc_1_i : select_write_signal_1_2 ? write_pc_2_i : '0),
        .write_src_op_1_i(select_write_signal_1_1 ? write_src_op_1_1_i : select_write_signal_1_2 ? write_src_op_2_1_i : '0),
        .write_src_op_2_i(select_write_signal_1_1 ? write_src_op_1_2_i : select_write_signal_1_2 ? write_src_op_2_2_i : '0),
        .write_valid_1_i(select_write_signal_1_1 ? write_valid_1_1_i : select_write_signal_1_2 ? write_valid_2_1_i : '0),
        .write_valid_2_i(select_write_signal_1_1 ? write_valid_1_2_i : select_write_signal_1_2 ? write_valid_2_2_i : '0),
        .write_imm_i(select_write_signal_1_1 ? write_imm_1_i : select_write_signal_1_2 ? write_imm_2_i : '0),
        .write_rrf_tag_i(select_write_signal_1_1 ? write_rrf_tag_1_i : select_write_signal_1_2 ? write_rrf_tag_2_i : '0),
        .write_dst_val_i(select_write_signal_1_1 ? write_dst_val_1_i : select_write_signal_1_2 ? write_dst_val_2_i : '0),
        .wen_i(select_rs_entry_1),
        .exe_src_op_1_o(exe_src_op_1[1]),
        .exe_src_op_2_o(exe_src_op_2[1]),
        .ready_o(ready[1]),
        .exe_pc_o(exe_pc[1]),
        .exe_imm_o(exe_imm[1]),
        .exe_rrf_tag_o(exe_rrf_tag[1]),
        .exe_dst_val_o(exe_dst_val[1]),
        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),
        .exe_result_1_dst_i(exe_result_1_dst_i),
        .exe_result_2_dst_i(exe_result_2_dst_i),
        .exe_result_3_dst_i(exe_result_3_dst_i),
        .exe_result_4_dst_i(exe_result_4_dst_i),
        .exe_result_5_dst_i(exe_result_5_dst_i)
    );

    RSAccessMemEntry entry_2 (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .busy_i(busy_vector_o[2]),
        .write_pc_i(select_write_signal_2_1 ? write_pc_1_i : select_write_signal_2_2 ? write_pc_2_i : '0),
        .write_src_op_1_i(select_write_signal_2_1 ? write_src_op_1_1_i : select_write_signal_2_2 ? write_src_op_2_1_i : '0),
        .write_src_op_2_i(select_write_signal_2_1 ? write_src_op_1_2_i : select_write_signal_2_2 ? write_src_op_2_2_i : '0),
        .write_valid_1_i(select_write_signal_2_1 ? write_valid_1_1_i : select_write_signal_2_2 ? write_valid_2_1_i : '0),
        .write_valid_2_i(select_write_signal_2_1 ? write_valid_1_2_i : select_write_signal_2_2 ? write_valid_2_2_i : '0),
        .write_imm_i(select_write_signal_2_1 ? write_imm_1_i : select_write_signal_2_2 ? write_imm_2_i : '0),
        .write_rrf_tag_i(select_write_signal_2_1 ? write_rrf_tag_1_i : select_write_signal_2_2 ? write_rrf_tag_2_i : '0),
        .write_dst_val_i(select_write_signal_2_1 ? write_dst_val_1_i : select_write_signal_2_2 ? write_dst_val_2_i : '0),
        .wen_i(select_rs_entry_2),
        .exe_src_op_1_o(exe_src_op_1[2]),
        .exe_src_op_2_o(exe_src_op_2[2]),
        .ready_o(ready[2]),
        .exe_pc_o(exe_pc[2]),
        .exe_imm_o(exe_imm[2]),
        .exe_rrf_tag_o(exe_rrf_tag[2]),
        .exe_dst_val_o(exe_dst_val[2]),
        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),
        .exe_result_1_dst_i(exe_result_1_dst_i),
        .exe_result_2_dst_i(exe_result_2_dst_i),
        .exe_result_3_dst_i(exe_result_3_dst_i),
        .exe_result_4_dst_i(exe_result_4_dst_i),
        .exe_result_5_dst_i(exe_result_5_dst_i)
    );

    RSAccessMemEntry entry_3 (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .busy_i(busy_vector_o[3]),
        .write_pc_i(select_write_signal_3_1 ? write_pc_1_i : select_write_signal_3_2 ? write_pc_2_i : '0),
        .write_src_op_1_i(select_write_signal_3_1 ? write_src_op_1_1_i : select_write_signal_3_2 ? write_src_op_2_1_i : '0),
        .write_src_op_2_i(select_write_signal_3_1 ? write_src_op_1_2_i : select_write_signal_3_2 ? write_src_op_2_2_i : '0),
        .write_valid_1_i(select_write_signal_3_1 ? write_valid_1_1_i : select_write_signal_3_2 ? write_valid_2_1_i : '0),
        .write_valid_2_i(select_write_signal_3_1 ? write_valid_1_2_i : select_write_signal_3_2 ? write_valid_2_2_i : '0),
        .write_imm_i(select_write_signal_3_1 ? write_imm_1_i : select_write_signal_3_2 ? write_imm_2_i : '0),
        .write_rrf_tag_i(select_write_signal_3_1 ? write_rrf_tag_1_i : select_write_signal_3_2 ? write_rrf_tag_2_i : '0),
        .write_dst_val_i(select_write_signal_3_1 ? write_dst_val_1_i : select_write_signal_3_2 ? write_dst_val_2_i : '0),
        .wen_i(select_rs_entry_3),
        .exe_src_op_1_o(exe_src_op_1[3]),
        .exe_src_op_2_o(exe_src_op_2[3]),
        .ready_o(ready[3]),
        .exe_pc_o(exe_pc[3]),
        .exe_imm_o(exe_imm[3]),
        .exe_rrf_tag_o(exe_rrf_tag[3]),
        .exe_dst_val_o(exe_dst_val[3]),
        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),
        .exe_result_1_dst_i(exe_result_1_dst_i),
        .exe_result_2_dst_i(exe_result_2_dst_i),
        .exe_result_3_dst_i(exe_result_3_dst_i),
        .exe_result_4_dst_i(exe_result_4_dst_i),
        .exe_result_5_dst_i(exe_result_5_dst_i)
    );

    // TODO: Invalid vector
    assign previous_busy_vector_next_o = busy_vector_o;

    // 时序逻辑，用于处理 busy_vector
    always @(posedge clk_i) begin
        if (reset_i) begin
            busy_vector_o <= `LDST_ENT_NUM'b0;
        end else begin
            if (we_1_i) begin
                busy_vector_o[write_addr_1_i] <= 1'b1;
            end
            if (we_2_i) begin
                busy_vector_o[write_addr_2_i] <= 1'b1;
            end
            if (clear_busy_i) begin
                busy_vector_o[issue_addr_i] <= 1'b0;
            end
        end
    end

    assign ready_vector_o = {ready[3], ready[2], ready[1], ready[0]};

    assign exe_src_op_1_o = (issue_addr_i == 0) ? exe_src_op_1[0] : (issue_addr_i == 1) ? exe_src_op_1[1] : (issue_addr_i == 2) ? exe_src_op_1[2] : (issue_addr_i == 3) ? exe_src_op_1[3] : 0;
    assign exe_src_op_2_o = (issue_addr_i == 0) ? exe_src_op_2[0] : (issue_addr_i == 1) ? exe_src_op_2[1] : (issue_addr_i == 2) ? exe_src_op_2[2] : (issue_addr_i == 3) ? exe_src_op_2[3] : 0;
    assign exe_pc_o       = (issue_addr_i == 0) ? exe_pc[0] : (issue_addr_i == 1) ? exe_pc[1] : (issue_addr_i == 2) ? exe_pc[2] : (issue_addr_i == 3) ? exe_pc[3] : 0;
    assign exe_imm_o      = (issue_addr_i == 0) ? exe_imm[0] : (issue_addr_i == 1) ? exe_imm[1] : (issue_addr_i == 2) ? exe_imm[2] : (issue_addr_i == 3) ? exe_imm[3] : 0;
    assign exe_rrf_tag_o  = (issue_addr_i == 0) ? exe_rrf_tag[0] : (issue_addr_i == 1) ? exe_rrf_tag[1] : (issue_addr_i == 2) ? exe_rrf_tag[2] : (issue_addr_i == 3) ? exe_rrf_tag[3] : 0;
    assign exe_dst_val_o  = (issue_addr_i == 0) ? exe_dst_val[0] : (issue_addr_i == 1) ? exe_dst_val[1] : (issue_addr_i == 2) ? exe_dst_val[2] : (issue_addr_i == 3) ? exe_dst_val[3] : 0;

endmodule
