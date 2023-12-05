`include "consts/Consts.v"
`include "consts/ALU.v"

module RSAlu(
    input wire clk_i,
    input wire reset_i,
    // 重命名寄存器的下一次循环，需要清空历史向量
    input wire next_rrf_cycle_i,

    // 需要清除 busy 向量标志
    input wire clear_busy_i,
    // 发射的指令 Entry 地址
    input wire [`ALU_ENT_SEL-1: 0] issue_addr_i,
    // 最多一次写入两条指令，这是两条指令的写使能标志
    input wire we_1_i,
    input wire we_2_i,
    // 两条写指令的写分配地址，由 AllocateUnit 分配地址
    input wire [`ALU_ENT_SEL-1: 0] write_addr_1_i,
    input wire [`ALU_ENT_SEL-1: 0] write_addr_2_i,

    // 第一条写入指令的真实 PC 地址
    input wire [`ADDR_LEN-1: 0] write_pc_1_i,
    // 第一条指令写入的两个操作数，无效的话则为 RRFTag
    input wire [`DATA_LEN-1: 0] write_op_1_1_i,
    input wire [`DATA_LEN-1: 0] write_op_1_2_i,
    // 两个操作数是否有效
    input wire write_valid_1_1_i,
    input wire write_valid_1_2_i,
    // 写入第一条指令的立即数值
    input wire [`DATA_LEN-1: 0] write_imm_1_i,
    // 写入第一条指令目标寄存器的 RRFTag
    input wire [`RRF_SEL-1: 0] write_tag_1_i,
    // 第一条指令是否要写回目标寄存器
    input wire write_dst_1_i,
    // 第一条指令的 ALU 操作码
    input wire [`ALU_OP_WIDTH-1: 0] write_alu_op_1_i,

    // 第二条写入指令的真实 PC 地址
    input wire [`ADDR_LEN-1: 0] write_pc_2_i,
    // 第二条指令写入的两个操作数，无效的话则为 RRFTag
    input wire [`DATA_LEN-1: 0] write_op_2_1_i,
    input wire [`DATA_LEN-1: 0] write_op_2_2_i,
    // 两个操作数是否有效
    input wire write_valid_2_1_i,
    input wire write_valid_2_2_i,
    // 写入第二条指令的立即数值
    input wire [`DATA_LEN-1: 0] write_imm_2_i,
    // 写入第二条指令目标寄存器的 RRFTag
    input wire [`RRF_SEL-1: 0] write_tag_2_i,
    // 第二条指令是否要写回目标寄存器
    input wire write_dst_2_i,
    // 第二条指令的 ALU 操作码
    input wire [`ALU_OP_WIDTH-1: 0] write_alu_op_2_i,

    // 执行单元前递的信号
    input wire [`DATA_LEN-1: 0] exe_result_1_i,
    input wire [`DATA_LEN-1: 0] exe_result_2_i,
    input wire [`DATA_LEN-1: 0] exe_result_3_i,
    input wire [`DATA_LEN-1: 0] exe_result_4_i,
    input wire [`DATA_LEN-1: 0] exe_result_5_i,
    input wire [`RRF_SEL-1: 0] exe_result_1_dst_i,
    input wire [`RRF_SEL-1: 0] exe_result_2_dst_i,
    input wire [`RRF_SEL-1: 0] exe_result_3_dst_i,
    input wire [`RRF_SEL-1: 0] exe_result_4_dst_i,
    input wire [`RRF_SEL-1: 0] exe_result_5_dst_i,

    // 用于输出保留站 Entry 的使用情况
    output reg [`ALU_ENT_NUM-1: 0] busy_vector_o,
    output wire [`ALU_ENT_NUM*(`RRF_SEL+2)-1: 0] history_vector_o,

    // 输出给执行单元的信号
    output wire [`DATA_LEN-1: 0] exe_op_1_o,
    output wire [`DATA_LEN-1: 0] exe_op_2_o,
    // 指令操作数是否准备好
    output wire [`ALU_ENT_NUM-1: 0] ready_o,
    output wire [`ADDR_LEN-1: 0] exe_pc_o,
    output wire [`DATA_LEN-1: 0] exe_imm_o,
    output wire [`RRF_SEL-1: 0] exe_rrf_tag_o,
    output wire exe_dst_val_o,
    output wire [`ALU_OP_WIDTH-1: 0] exe_alu_op_o
);

    // 一个保留站中存储8个Entry
    wire [`DATA_LEN-1: 0] exe_op_1 [0: `ALU_ENT_NUM-1];
    wire [`DATA_LEN-1: 0] exe_op_2 [0: `ALU_ENT_NUM-1];
    wire ready [0: `ALU_ENT_NUM-1];
    wire [`ADDR_LEN-1: 0] exe_pc [0: `ALU_ENT_NUM-1];
    wire [`DATA_LEN-1: 0] exe_imm [0: `ALU_ENT_NUM-1];
    wire [`RRF_SEL-1: 0] exe_rrf_tag [0: `ALU_ENT_NUM-1];
    wire exe_dst_val [0: `ALU_ENT_NUM-1];
    wire [`ALU_OP_WIDTH-1: 0] exe_alu_op [0: `ALU_ENT_NUM-1];

    // 用于做保留站指令的排序
    reg [`ALU_ENT_NUM-1:0] 	      sort_bit;

    wire select_rs_entry_0;
    wire select_rs_entry_1;
    wire select_rs_entry_2;
    wire select_rs_entry_3;
    wire select_rs_entry_4;
    wire select_rs_entry_5;
    wire select_rs_entry_6;
    wire select_rs_entry_7;

    assign select_rs_entry_0 = (we_1_i && (write_addr_1_i == 0)) || (we_2_i && (write_addr_2_i == 0));
    assign select_rs_entry_1 = (we_1_i && (write_addr_1_i == 1)) || (we_2_i && (write_addr_2_i == 1));
    assign select_rs_entry_2 = (we_1_i && (write_addr_1_i == 2)) || (we_2_i && (write_addr_2_i == 2));
    assign select_rs_entry_3 = (we_1_i && (write_addr_1_i == 3)) || (we_2_i && (write_addr_2_i == 3));
    assign select_rs_entry_4 = (we_1_i && (write_addr_1_i == 4)) || (we_2_i && (write_addr_2_i == 4));
    assign select_rs_entry_5 = (we_1_i && (write_addr_1_i == 5)) || (we_2_i && (write_addr_2_i == 5));
    assign select_rs_entry_6 = (we_1_i && (write_addr_1_i == 6)) || (we_2_i && (write_addr_2_i == 6));
    assign select_rs_entry_7 = (we_1_i && (write_addr_1_i == 7)) || (we_2_i && (write_addr_2_i == 7));

    wire select_write_signal_0_1;
    wire select_write_signal_0_2;
    wire select_write_signal_1_1;
    wire select_write_signal_1_2;
    wire select_write_signal_2_1;
    wire select_write_signal_2_2;
    wire select_write_signal_3_1;
    wire select_write_signal_3_2;
    wire select_write_signal_4_1;
    wire select_write_signal_4_2;
    wire select_write_signal_5_1;
    wire select_write_signal_5_2;
    wire select_write_signal_6_1;
    wire select_write_signal_6_2;
    wire select_write_signal_7_1;
    wire select_write_signal_7_2;

    assign select_write_signal_0_1 = we_1_i && (write_addr_1_i == 0);
    assign select_write_signal_0_2 = we_2_i && (write_addr_2_i == 0);
    assign select_write_signal_1_1 = we_1_i && (write_addr_1_i == 1);
    assign select_write_signal_1_2 = we_2_i && (write_addr_2_i == 1);
    assign select_write_signal_2_1 = we_1_i && (write_addr_1_i == 2);
    assign select_write_signal_2_2 = we_2_i && (write_addr_2_i == 2);
    assign select_write_signal_3_1 = we_1_i && (write_addr_1_i == 3);
    assign select_write_signal_3_2 = we_2_i && (write_addr_2_i == 3);
    assign select_write_signal_4_1 = we_1_i && (write_addr_1_i == 4);
    assign select_write_signal_4_2 = we_2_i && (write_addr_2_i == 4);
    assign select_write_signal_5_1 = we_1_i && (write_addr_1_i == 5);
    assign select_write_signal_5_2 = we_2_i && (write_addr_2_i == 5);
    assign select_write_signal_6_1 = we_1_i && (write_addr_1_i == 6);
    assign select_write_signal_6_2 = we_2_i && (write_addr_2_i == 6);
    assign select_write_signal_7_1 = we_1_i && (write_addr_1_i == 7);
    assign select_write_signal_7_2 = we_2_i && (write_addr_2_i == 7);

    // 8 个保留站 Entry
    RSAluEntry entry_0(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .busy_i(busy_vector_o[0]),
        .write_pc_i(select_write_signal_0_1 ? write_pc_1_i: select_write_signal_0_2? write_pc_2_i: '0),
        .write_op_1_i(select_write_signal_0_1 ? write_op_1_1_i: select_write_signal_0_2? write_op_2_1_i: '0),
        .write_op_2_i(select_write_signal_0_1 ? write_op_1_2_i: select_write_signal_0_2? write_op_2_2_i: '0),
        .write_op_1_valid_i(select_write_signal_0_1 ? write_valid_1_1_i: select_write_signal_0_2? write_valid_2_1_i: 0),
        .write_op_2_valid_i(select_write_signal_0_1 ? write_valid_1_2_i: select_write_signal_0_2? write_valid_2_2_i: 0),
        .write_imm_i(select_write_signal_0_1 ? write_imm_1_i: select_write_signal_0_2? write_imm_2_i: '0),
        .write_rrf_tag_i(select_write_signal_0_1 ? write_tag_1_i: select_write_signal_0_2? write_tag_2_i: '0),
        .write_dst_val_i(select_write_signal_0_1 ? write_dst_1_i: select_write_signal_0_2? write_dst_2_i: 0),
        .write_alu_op_i(select_write_signal_0_1 ? write_alu_op_1_i: select_write_signal_0_2? write_alu_op_2_i: '0),

        .we_i(select_rs_entry_0),

        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),
        .exe_result_1_dst_i(exe_result_1_dst_i),
        .exe_result_2_dst_i(exe_result_2_dst_i),
        .exe_result_3_dst_i(exe_result_3_dst_i),
        .exe_result_4_dst_i(exe_result_4_dst_i),
        .exe_result_5_dst_i(exe_result_5_dst_i),

        .exe_op_1_o(exe_op_1[0]),
        .exe_op_2_o(exe_op_2[0]),
        .ready_o(ready[0]),
        .exe_pc_o(exe_pc[0]),
        .exe_imm_o(exe_imm[0]),
        .exe_rrf_tag_o(exe_rrf_tag[0]),
        .exe_dst_val_o(exe_dst_val[0]),
        .exe_alu_op_o(exe_alu_op[0])

    );

    RSAluEntry entry_1(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .busy_i(busy_vector_o[1]),
        .write_pc_i(select_write_signal_1_1 ? write_pc_1_i: select_write_signal_1_2? write_pc_2_i: '0),
        .write_op_1_i(select_write_signal_1_1 ? write_op_1_1_i: select_write_signal_1_2? write_op_2_1_i: '0),
        .write_op_2_i(select_write_signal_1_1 ? write_op_1_2_i: select_write_signal_1_2? write_op_2_2_i: '0),
        .write_op_1_valid_i(select_write_signal_1_1 ? write_valid_1_1_i: select_write_signal_1_2? write_valid_2_1_i: 0),
        .write_op_2_valid_i(select_write_signal_1_1 ? write_valid_1_2_i: select_write_signal_1_2? write_valid_2_2_i: 0),
        .write_imm_i(select_write_signal_1_1 ? write_imm_1_i: select_write_signal_1_2? write_imm_2_i: '0),
        .write_rrf_tag_i(select_write_signal_1_1 ? write_tag_1_i: select_write_signal_1_2? write_tag_2_i: '0),
        .write_dst_val_i(select_write_signal_1_1 ? write_dst_1_i: select_write_signal_1_2? write_dst_2_i: 0),
        .write_alu_op_i(select_write_signal_1_1 ? write_alu_op_1_i: select_write_signal_1_2? write_alu_op_2_i: '0),

        .we_i(select_rs_entry_1),

        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),
        .exe_result_1_dst_i(exe_result_1_dst_i),
        .exe_result_2_dst_i(exe_result_2_dst_i),
        .exe_result_3_dst_i(exe_result_3_dst_i),
        .exe_result_4_dst_i(exe_result_4_dst_i),
        .exe_result_5_dst_i(exe_result_5_dst_i),

        .exe_op_1_o(exe_op_1[1]),
        .exe_op_2_o(exe_op_2[1]),
        .ready_o(ready[1]),
        .exe_pc_o(exe_pc[1]),
        .exe_imm_o(exe_imm[1]),
        .exe_rrf_tag_o(exe_rrf_tag[1]),
        .exe_dst_val_o(exe_dst_val[1]),
        .exe_alu_op_o(exe_alu_op[1])
    );

    RSAluEntry entry_2(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .busy_i(busy_vector_o[2]),
        .write_pc_i(select_write_signal_2_1 ? write_pc_1_i: select_write_signal_2_2? write_pc_2_i: '0),
        .write_op_1_i(select_write_signal_2_1 ? write_op_1_1_i: select_write_signal_2_2? write_op_2_1_i: '0),
        .write_op_2_i(select_write_signal_2_1 ? write_op_1_2_i: select_write_signal_2_2? write_op_2_2_i: '0),
        .write_op_1_valid_i(select_write_signal_2_1 ? write_valid_1_1_i: select_write_signal_2_2? write_valid_2_1_i: 0),
        .write_op_2_valid_i(select_write_signal_2_1 ? write_valid_1_2_i: select_write_signal_2_2? write_valid_2_2_i: 0),
        .write_imm_i(select_write_signal_2_1 ? write_imm_1_i: select_write_signal_2_2? write_imm_2_i: '0),
        .write_rrf_tag_i(select_write_signal_2_1 ? write_tag_1_i: select_write_signal_2_2? write_tag_2_i: '0),
        .write_dst_val_i(select_write_signal_2_1 ? write_dst_1_i: select_write_signal_2_2? write_dst_2_i: 0),
        .write_alu_op_i(select_write_signal_2_1 ? write_alu_op_1_i: select_write_signal_2_2? write_alu_op_2_i: '0),

        .we_i(select_rs_entry_2),

        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),
        .exe_result_1_dst_i(exe_result_1_dst_i),
        .exe_result_2_dst_i(exe_result_2_dst_i),
        .exe_result_3_dst_i(exe_result_3_dst_i),
        .exe_result_4_dst_i(exe_result_4_dst_i),
        .exe_result_5_dst_i(exe_result_5_dst_i),

        .exe_op_1_o(exe_op_1[2]),
        .exe_op_2_o(exe_op_2[2]),
        .ready_o(ready[2]),
        .exe_pc_o(exe_pc[2]),
        .exe_imm_o(exe_imm[2]),
        .exe_rrf_tag_o(exe_rrf_tag[2]),
        .exe_dst_val_o(exe_dst_val[2]),
        .exe_alu_op_o(exe_alu_op[2])
    );

    RSAluEntry entry_3(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .busy_i(busy_vector_o[3]),
        .write_pc_i(select_write_signal_3_1 ? write_pc_1_i: select_write_signal_3_2? write_pc_2_i: '0),
        .write_op_1_i(select_write_signal_3_1 ? write_op_1_1_i: select_write_signal_3_2? write_op_2_1_i: '0),
        .write_op_2_i(select_write_signal_3_1 ? write_op_1_2_i: select_write_signal_3_2? write_op_2_2_i: '0),
        .write_op_1_valid_i(select_write_signal_3_1 ? write_valid_1_1_i: select_write_signal_3_2? write_valid_2_1_i: 0),
        .write_op_2_valid_i(select_write_signal_3_1 ? write_valid_1_2_i: select_write_signal_3_2? write_valid_2_2_i: 0),
        .write_imm_i(select_write_signal_3_1 ? write_imm_1_i: select_write_signal_3_2? write_imm_2_i: '0),
        .write_rrf_tag_i(select_write_signal_3_1 ? write_tag_1_i: select_write_signal_3_2? write_tag_2_i: '0),
        .write_dst_val_i(select_write_signal_3_1 ? write_dst_1_i: select_write_signal_3_2? write_dst_2_i: 0),
        .write_alu_op_i(select_write_signal_3_1 ? write_alu_op_1_i: select_write_signal_3_2? write_alu_op_2_i: '0),

        .we_i(select_rs_entry_3),

        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),
        .exe_result_1_dst_i(exe_result_1_dst_i),
        .exe_result_2_dst_i(exe_result_2_dst_i),
        .exe_result_3_dst_i(exe_result_3_dst_i),
        .exe_result_4_dst_i(exe_result_4_dst_i),
        .exe_result_5_dst_i(exe_result_5_dst_i),

        .exe_op_1_o(exe_op_1[3]),
        .exe_op_2_o(exe_op_2[3]),
        .ready_o(ready[3]),
        .exe_pc_o(exe_pc[3]),
        .exe_imm_o(exe_imm[3]),
        .exe_rrf_tag_o(exe_rrf_tag[3]),
        .exe_dst_val_o(exe_dst_val[3]),
        .exe_alu_op_o(exe_alu_op[3])
    );

    RSAluEntry entry_4(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .busy_i(busy_vector_o[4]),
        .write_pc_i(select_write_signal_4_1 ? write_pc_1_i: select_write_signal_4_2? write_pc_2_i: '0),
        .write_op_1_i(select_write_signal_4_1 ? write_op_1_1_i: select_write_signal_4_2? write_op_2_1_i: '0),
        .write_op_2_i(select_write_signal_4_1 ? write_op_1_2_i: select_write_signal_4_2? write_op_2_2_i: '0),
        .write_op_1_valid_i(select_write_signal_4_1 ? write_valid_1_1_i: select_write_signal_4_2? write_valid_2_1_i: 0),
        .write_op_2_valid_i(select_write_signal_4_1 ? write_valid_1_2_i: select_write_signal_4_2? write_valid_2_2_i: 0),
        .write_imm_i(select_write_signal_4_1 ? write_imm_1_i: select_write_signal_4_2? write_imm_2_i: '0),
        .write_rrf_tag_i(select_write_signal_4_1 ? write_tag_1_i: select_write_signal_4_2? write_tag_2_i: '0),
        .write_dst_val_i(select_write_signal_4_1 ? write_dst_1_i: select_write_signal_4_2? write_dst_2_i: 0),
        .write_alu_op_i(select_write_signal_4_1 ? write_alu_op_1_i: select_write_signal_4_2? write_alu_op_2_i: '0),

        .we_i(select_rs_entry_4),

        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),
        .exe_result_1_dst_i(exe_result_1_dst_i),
        .exe_result_2_dst_i(exe_result_2_dst_i),
        .exe_result_3_dst_i(exe_result_3_dst_i),
        .exe_result_4_dst_i(exe_result_4_dst_i),
        .exe_result_5_dst_i(exe_result_5_dst_i),

        .exe_op_1_o(exe_op_1[4]),
        .exe_op_2_o(exe_op_2[4]),
        .ready_o(ready[4]),
        .exe_pc_o(exe_pc[4]),
        .exe_imm_o(exe_imm[4]),
        .exe_rrf_tag_o(exe_rrf_tag[4]),
        .exe_dst_val_o(exe_dst_val[4]),
        .exe_alu_op_o(exe_alu_op[4])
    );

    RSAluEntry entry_5(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .busy_i(busy_vector_o[5]),
        .write_pc_i(select_write_signal_5_1 ? write_pc_1_i: select_write_signal_5_2? write_pc_2_i: '0),
        .write_op_1_i(select_write_signal_5_1 ? write_op_1_1_i: select_write_signal_5_2? write_op_2_1_i: '0),
        .write_op_2_i(select_write_signal_5_1 ? write_op_1_2_i: select_write_signal_5_2? write_op_2_2_i: '0),
        .write_op_1_valid_i(select_write_signal_5_1 ? write_valid_1_1_i: select_write_signal_5_2? write_valid_2_1_i: 0),
        .write_op_2_valid_i(select_write_signal_5_1 ? write_valid_1_2_i: select_write_signal_5_2? write_valid_2_2_i: 0),
        .write_imm_i(select_write_signal_5_1 ? write_imm_1_i: select_write_signal_5_2? write_imm_2_i: '0),
        .write_rrf_tag_i(select_write_signal_5_1 ? write_tag_1_i: select_write_signal_5_2? write_tag_2_i: '0),
        .write_dst_val_i(select_write_signal_5_1 ? write_dst_1_i: select_write_signal_5_2? write_dst_2_i: 0),
        .write_alu_op_i(select_write_signal_5_1 ? write_alu_op_1_i: select_write_signal_5_2? write_alu_op_2_i: '0),

        .we_i(select_rs_entry_5),

        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),
        .exe_result_1_dst_i(exe_result_1_dst_i),
        .exe_result_2_dst_i(exe_result_2_dst_i),
        .exe_result_3_dst_i(exe_result_3_dst_i),
        .exe_result_4_dst_i(exe_result_4_dst_i),
        .exe_result_5_dst_i(exe_result_5_dst_i),

        .exe_op_1_o(exe_op_1[5]),
        .exe_op_2_o(exe_op_2[5]),
        .ready_o(ready[5]),
        .exe_pc_o(exe_pc[5]),
        .exe_imm_o(exe_imm[5]),
        .exe_rrf_tag_o(exe_rrf_tag[5]),
        .exe_dst_val_o(exe_dst_val[5]),
        .exe_alu_op_o(exe_alu_op[5])
    );

    RSAluEntry entry_6(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .busy_i(busy_vector_o[6]),
        .write_pc_i(select_write_signal_6_1 ? write_pc_1_i: select_write_signal_6_2? write_pc_2_i: '0),
        .write_op_1_i(select_write_signal_6_1 ? write_op_1_1_i: select_write_signal_6_2? write_op_2_1_i: '0),
        .write_op_2_i(select_write_signal_6_1 ? write_op_1_2_i: select_write_signal_6_2? write_op_2_2_i: '0),
        .write_op_1_valid_i(select_write_signal_6_1 ? write_valid_1_1_i: select_write_signal_6_2? write_valid_2_1_i: 0),
        .write_op_2_valid_i(select_write_signal_6_1 ? write_valid_1_2_i: select_write_signal_6_2? write_valid_2_2_i: 0),
        .write_imm_i(select_write_signal_6_1 ? write_imm_1_i: select_write_signal_6_2? write_imm_2_i: '0),
        .write_rrf_tag_i(select_write_signal_6_1 ? write_tag_1_i: select_write_signal_6_2? write_tag_2_i: '0),
        .write_dst_val_i(select_write_signal_6_1 ? write_dst_1_i: select_write_signal_6_2? write_dst_2_i: 0),
        .write_alu_op_i(select_write_signal_6_1 ? write_alu_op_1_i: select_write_signal_6_2? write_alu_op_2_i: '0),

        .we_i(select_rs_entry_6),

        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),
        .exe_result_1_dst_i(exe_result_1_dst_i),
        .exe_result_2_dst_i(exe_result_2_dst_i),
        .exe_result_3_dst_i(exe_result_3_dst_i),
        .exe_result_4_dst_i(exe_result_4_dst_i),
        .exe_result_5_dst_i(exe_result_5_dst_i),

        .exe_op_1_o(exe_op_1[6]),
        .exe_op_2_o(exe_op_2[6]),
        .ready_o(ready[6]),
        .exe_pc_o(exe_pc[6]),
        .exe_imm_o(exe_imm[6]),
        .exe_rrf_tag_o(exe_rrf_tag[6]),
        .exe_dst_val_o(exe_dst_val[6]),
        .exe_alu_op_o(exe_alu_op[6])
    );

    RSAluEntry entry_7(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .busy_i(busy_vector_o[7]),
        .write_pc_i(select_write_signal_7_1 ? write_pc_1_i: select_write_signal_7_2? write_pc_2_i: '0),
        .write_op_1_i(select_write_signal_7_1 ? write_op_1_1_i: select_write_signal_7_2? write_op_2_1_i: '0),
        .write_op_2_i(select_write_signal_7_1 ? write_op_1_2_i: select_write_signal_7_2? write_op_2_2_i: '0),
        .write_op_1_valid_i(select_write_signal_7_1 ? write_valid_1_1_i: select_write_signal_7_2? write_valid_2_1_i: 0),
        .write_op_2_valid_i(select_write_signal_7_1 ? write_valid_1_2_i: select_write_signal_7_2? write_valid_2_2_i: 0),
        .write_imm_i(select_write_signal_7_1 ? write_imm_1_i: select_write_signal_7_2? write_imm_2_i: '0),
        .write_rrf_tag_i(select_write_signal_7_1 ? write_tag_1_i: select_write_signal_7_2? write_tag_2_i: '0),
        .write_dst_val_i(select_write_signal_7_1 ? write_dst_1_i: select_write_signal_7_2? write_dst_2_i: 0),
        .write_alu_op_i(select_write_signal_7_1 ? write_alu_op_1_i: select_write_signal_7_2? write_alu_op_2_i: '0),

        .we_i(select_rs_entry_7),

        .exe_result_1_i(exe_result_1_i),
        .exe_result_2_i(exe_result_2_i),
        .exe_result_3_i(exe_result_3_i),
        .exe_result_4_i(exe_result_4_i),
        .exe_result_5_i(exe_result_5_i),
        .exe_result_1_dst_i(exe_result_1_dst_i),
        .exe_result_2_dst_i(exe_result_2_dst_i),
        .exe_result_3_dst_i(exe_result_3_dst_i),
        .exe_result_4_dst_i(exe_result_4_dst_i),
        .exe_result_5_dst_i(exe_result_5_dst_i),

        .exe_op_1_o(exe_op_1[7]),
        .exe_op_2_o(exe_op_2[7]),
        .ready_o(ready[7]),
        .exe_pc_o(exe_pc[7]),
        .exe_imm_o(exe_imm[7]),
        .exe_rrf_tag_o(exe_rrf_tag[7]),
        .exe_dst_val_o(exe_dst_val[7]),
        .exe_alu_op_o(exe_alu_op[7])
    );

    // 组合逻辑
    // 历史数据输出
    assign history_vector_o = {
        {~ready[7], sort_bit[7], exe_rrf_tag[7]},
        {~ready[6], sort_bit[6], exe_rrf_tag[6]},
        {~ready[5], sort_bit[5], exe_rrf_tag[5]},
        {~ready[4], sort_bit[4], exe_rrf_tag[4]},
        {~ready[3], sort_bit[3], exe_rrf_tag[3]},
        {~ready[2], sort_bit[2], exe_rrf_tag[2]},
        {~ready[1], sort_bit[1], exe_rrf_tag[1]},
        {~ready[0], sort_bit[0], exe_rrf_tag[0]}
    };

    // 时序逻辑，计算 sort_bit
    always@(posedge clk_i)begin
        if(reset_i)begin
            sort_bit <= `ALU_ENT_NUM'b1;
        end else if(next_rrf_cycle_i)
        begin
            // next_rrf_cycle 表示下个重命名寄存器开启新一轮从 0 开始的循环
            sort_bit <= (we_1_i ? (`ALU_ENT_NUM'b1 << write_addr_1_i): `ALU_ENT_NUM'b0) | (we_2_i ? (`ALU_ENT_NUM'b1 << write_addr_2_i): `ALU_ENT_NUM'b0);
        end else begin
            if(we_1_i)begin 
                sort_bit[write_addr_1_i] <= 1'b1;
            end
            if(we_2_i)begin 
                sort_bit[write_addr_2_i] <= 1'b1;
            end
        end
    end

    // 时序逻辑，用于处理 busy_vector
    always@(posedge clk_i)begin
        if(reset_i)begin
            busy_vector_o <= `ALU_ENT_NUM'b0;
        end else begin
            if(we_1_i)begin
                busy_vector_o[write_addr_1_i] <= 1'b1;
            end
            if(we_2_i)begin
                busy_vector_o[write_addr_2_i] <= 1'b1;
            end
            if(clear_busy_i)begin 
                busy_vector_o[issue_addr_i] <= 1'b0;
            end
        end
    end

    // 根据发射地址选择输出的数据
    assign ready_o = {ready[7], ready[6], ready[5], ready[4], ready[3], ready[2], ready[1], ready[0]};

    assign exe_op_1_o = (issue_addr_i == 0)? exe_op_1[0]:
                        (issue_addr_i == 1)? exe_op_1[1]:
                        (issue_addr_i == 2)? exe_op_1[2]:
                        (issue_addr_i == 3)? exe_op_1[3]:
                        (issue_addr_i == 4)? exe_op_1[4]:
                        (issue_addr_i == 5)? exe_op_1[5]:
                        (issue_addr_i == 6)? exe_op_1[6]:
                        (issue_addr_i == 7)? exe_op_1[7]: '0;
    assign exe_op_2_o = (issue_addr_i == 0)? exe_op_2[0]:
                        (issue_addr_i == 1)? exe_op_2[1]:
                        (issue_addr_i == 2)? exe_op_2[2]:
                        (issue_addr_i == 3)? exe_op_2[3]:
                        (issue_addr_i == 4)? exe_op_2[4]:
                        (issue_addr_i == 5)? exe_op_2[5]:
                        (issue_addr_i == 6)? exe_op_2[6]:
                        (issue_addr_i == 7)? exe_op_2[7]: '0;
    assign exe_pc_o = (issue_addr_i == 0)? exe_pc[0]:
                        (issue_addr_i == 1)? exe_pc[1]:
                        (issue_addr_i == 2)? exe_pc[2]:
                        (issue_addr_i == 3)? exe_pc[3]:
                        (issue_addr_i == 4)? exe_pc[4]:
                        (issue_addr_i == 5)? exe_pc[5]:
                        (issue_addr_i == 6)? exe_pc[6]:
                        (issue_addr_i == 7)? exe_pc[7]: '0;
    assign exe_imm_o = (issue_addr_i == 0)? exe_imm[0]:
                        (issue_addr_i == 1)? exe_imm[1]:
                        (issue_addr_i == 2)? exe_imm[2]:
                        (issue_addr_i == 3)? exe_imm[3]:
                        (issue_addr_i == 4)? exe_imm[4]:
                        (issue_addr_i == 5)? exe_imm[5]:
                        (issue_addr_i == 6)? exe_imm[6]:
                        (issue_addr_i == 7)? exe_imm[7]: '0;
    assign exe_rrf_tag_o = (issue_addr_i == 0)? exe_rrf_tag[0]:
                        (issue_addr_i == 1)? exe_rrf_tag[1]:
                        (issue_addr_i == 2)? exe_rrf_tag[2]:
                        (issue_addr_i == 3)? exe_rrf_tag[3]:
                        (issue_addr_i == 4)? exe_rrf_tag[4]:
                        (issue_addr_i == 5)? exe_rrf_tag[5]:
                        (issue_addr_i == 6)? exe_rrf_tag[6]:
                        (issue_addr_i == 7)? exe_rrf_tag[7]: '0;
    assign exe_dst_val_o = (issue_addr_i == 0)? exe_dst_val[0]:
                        (issue_addr_i == 1)? exe_dst_val[1]:
                        (issue_addr_i == 2)? exe_dst_val[2]:
                        (issue_addr_i == 3)? exe_dst_val[3]:
                        (issue_addr_i == 4)? exe_dst_val[4]:
                        (issue_addr_i == 5)? exe_dst_val[5]:
                        (issue_addr_i == 6)? exe_dst_val[6]:
                        (issue_addr_i == 7)? exe_dst_val[7]: 0;
    assign exe_alu_op_o = (issue_addr_i == 0)? exe_alu_op[0]:
                        (issue_addr_i == 1)? exe_alu_op[1]:
                        (issue_addr_i == 2)? exe_alu_op[2]:
                        (issue_addr_i == 3)? exe_alu_op[3]:
                        (issue_addr_i == 4)? exe_alu_op[4]:
                        (issue_addr_i == 5)? exe_alu_op[5]:
                        (issue_addr_i == 6)? exe_alu_op[6]:
                        (issue_addr_i == 7)? exe_alu_op[7]: '0;
    


endmodule