`include "consts/Consts.vh"
`include "consts/ALU.vh"

// Select and Wakeup 阶段的顶层模块，输入 Dispatch 阶段发送的信号，
// 输出到 Execute 阶段。
module SwUnit(
    input wire                      clk_i,
    input wire                      reset_i,
    input wire                      dp_next_rrf_cycle_i,

    // 请求 ALU 指令的数量
    input wire [1: 0]               dp_req_alu_num_i,
    input wire [`ADDR_LEN-1: 0]     dp_pc_1_i,
    input wire [`ADDR_LEN-1: 0]     dp_pc_2_i,

    input wire [`DATA_LEN-1: 0]     dp_op_1_1_i,
    input wire [`DATA_LEN-1: 0]     dp_op_1_2_i,
    input wire [`DATA_LEN-1: 0]     dp_op_2_1_i,
    input wire [`DATA_LEN-1: 0]     dp_op_2_2_i,

    input wire                      dp_valid_1_1_i,
    input wire                      dp_valid_1_2_i, 
    input wire                      dp_valid_2_1_i,
    input wire                      dp_valid_2_2_i,
    
    input wire [`DATA_LEN-1: 0]     dp_imm_1_i, 
    input wire [`DATA_LEN-1: 0]     dp_imm_2_i,

    input wire [`RRF_SEL-1: 0]      dp_rrf_tag_1_i,
    input wire [`RRF_SEL-1: 0]      dp_rrf_tag_2_i,

    input wire                      dp_dst_1_i,
    input wire                      dp_dst_2_i,

    input wire [`ALU_OP_WIDTH-1: 0] dp_alu_op_1_i,
    input wire [`ALU_OP_WIDTH-1: 0] dp_alu_op_2_i,

    input wire                      stall_dp_i,
    input wire                      kill_dp_i,

    // 执行前递的信号
    input wire [`DATA_LEN-1: 0]     exe_result_1_i,
    input wire [`DATA_LEN-1: 0]     exe_result_2_i,
    input wire [`DATA_LEN-1: 0]     exe_result_3_i,
    input wire [`DATA_LEN-1: 0]     exe_result_4_i,
    input wire [`DATA_LEN-1: 0]     exe_result_5_i,
    input wire [`RRF_SEL-1: 0]      exe_result_1_dst_i,
    input wire [`RRF_SEL-1: 0]      exe_result_2_dst_i,
    input wire [`RRF_SEL-1: 0]      exe_result_3_dst_i,
    input wire [`RRF_SEL-1: 0]      exe_result_4_dst_i,
    input wire [`RRF_SEL-1: 0]      exe_result_5_dst_i,

    output reg [`DATA_LEN-1: 0]     exe_alu_op_1_o,
    output reg [`DATA_LEN-1: 0]     exe_alu_op_2_o,
    output reg [`ADDR_LEN-1: 0]     exe_alu_pc_o,   
    output reg [`DATA_LEN-1: 0]     exe_alu_imm_o,
    output reg [`RRF_SEL-1: 0]      exe_alu_rrf_tag_o,
    output reg                      exe_alu_dst_val_o,
    output reg [`ALU_OP_WIDTH-1: 0] exe_alu_op_o
);

    wire [`ALU_ENT_NUM-1: 0] busy_alu_vector; 
    wire alu_allocatable;
    wire alu_allocate_en_1;
    wire alu_allocate_en_2;
    // 传递给 Allocator 的信号
    wire [`ALU_ENT_SEL: 0] free_alu_entry_1;
    wire [`ALU_ENT_SEL: 0] free_alu_entry_2;

    // 提取出前 ALU_ENT_SEL 位的 ALU 指令地址
    wire [`ALU_ENT_SEL-1: 0] alu_allocate_entry_1;
    wire [`ALU_ENT_SEL-1: 0] alu_allocate_entry_2; 

    wire [`ALU_ENT_SEL-1: 0] alu_rs_allocate_entry_1;
    wire [`ALU_ENT_SEL-1: 0] alu_rs_allocate_entry_2;

    wire [`ALU_ENT_SEL-1: 0] alu_issue_addr;
    wire alu_clear_busy;
    wire we_1;
    wire we_2;

    reg [`ALU_ENT_NUM-1: 0] alu_busy_vector;
    wire [`ALU_ENT_NUM*(`RRF_SEL+2)-1: 0] alu_history_vector;

    wire [`DATA_LEN-1: 0] exe_alu_op_1;
    wire [`DATA_LEN-1: 0] exe_alu_op_2;
    wire [`ADDR_LEN-1: 0] exe_alu_pc;   
    wire [`DATA_LEN-1: 0] exe_alu_imm;
    wire [`RRF_SEL-1: 0]  exe_alu_rrf_tag;
    wire                  exe_alu_dst_val;
    wire [`ALU_OP_WIDTH-1: 0] exe_alu_op;
    wire [`ALU_ENT_NUM-1: 0]  exe_alu_ready;

    wire [`ALU_ENT_SEL-1: 0] alu_issue_entry;
    wire [`RRF_SEL+1: 0]     alu_entry_value;
    
    // 分配单元根据 req_num 分配保留站条目
    AllocateUnit #(`ALU_ENT_NUM, `ALU_ENT_SEL+1) AluAllocator(
        .busy_i(busy_alu_vector),
        .en_1_o(alu_allocate_en_1),
        .en_2_o(alu_allocate_en_2),
        .free_entry_1_o(free_alu_entry_1),
        .free_entry_2_o(free_alu_entry_2),
        .req_num_i(dp_req_alu_num_i),
        .allocatable_o(alu_allocatable)
    );

    // 由于最后一位是 mask bit，因此提取前 `ALU_ENT_SEL-1 位 作为分配的 ADDR
    assign alu_allocate_entry_1 = free_alu_entry_1[`ALU_ENT_SEL: 1];
    assign alu_allocate_entry_2 = free_alu_entry_2[`ALU_ENT_SEL: 1];

    // 如果分配成功赋值，否则为 0
    assign alu_rs_allocate_entry_1 = alu_allocate_en_1? alu_allocate_entry_1 : 0;
    assign alu_rs_allocate_entry_2 = alu_allocate_en_2? alu_allocate_entry_2 : 0;

    // 写使能信号，TODO：更多条件
    assign we_1 = ~stall_dp_i & ~kill_dp_i & alu_allocate_en_1;
    assign we_2 = ~stall_dp_i & ~kill_dp_i & alu_allocate_en_2;

    assign alu_issue_addr = alu_issue_entry;
    assign alu_clear_busy = ~alu_entry_value[`RRF_SEL+1];


    RSAlu RSAlu(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .next_rrf_cycle_i(dp_next_rrf_cycle_i),

        .issue_addr_i(alu_issue_addr),
        .clear_busy_i(alu_clear_busy),
        .we_1_i(we_1),
        .we_2_i(we_2),

        .write_pc_1_i(dp_pc_1_i),
        .write_pc_2_i(dp_pc_2_i),

        // 为保留站分配的 entry 地址
        .write_addr_1_i(alu_rs_allocate_entry_1),
        .write_addr_2_i(alu_rs_allocate_entry_2),

        .write_op_1_1_i(dp_op_1_1_i),
        .write_op_1_2_i(dp_op_1_2_i),
        .write_valid_1_1_i(dp_valid_1_1_i),
        .write_valid_1_2_i(dp_valid_1_2_i),

        .write_op_2_1_i(dp_op_2_1_i),
        .write_op_2_2_i(dp_op_2_2_i),
        .write_valid_2_1_i(dp_valid_2_1_i),
        .write_valid_2_2_i(dp_valid_2_2_i),

        .write_imm_1_i(dp_imm_1_i),
        .write_imm_2_i(dp_imm_2_i),

        .write_tag_1_i(dp_rrf_tag_1_i),
        .write_tag_2_i(dp_rrf_tag_2_i),

        .write_dst_1_i(dp_dst_1_i),
        .write_dst_2_i(dp_dst_2_i),

        .write_alu_op_1_i(dp_alu_op_1_i),
        .write_alu_op_2_i(dp_alu_op_2_i),

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

        .exe_op_1_o(exe_alu_op_1),
        .exe_op_2_o(exe_alu_op_2),
        .ready_o(exe_alu_ready),
        .exe_pc_o(exe_alu_pc),
        .exe_imm_o(exe_alu_imm),
        .exe_rrf_tag_o(exe_alu_rrf_tag),
        .exe_alu_op_o(exe_alu_op),
        .exe_dst_val_o(exe_alu_dst_val),

        .busy_vector_o(alu_busy_vector),
        .history_vector_o(alu_history_vector)
    );


    // 从8个Entry中找到最老的进行发射
    OldestFinder AluIssuer(
        .entry_vector_i({`ALU_ENT_SEL'h7, `ALU_ENT_SEL'h6, `ALU_ENT_SEL'h5, `ALU_ENT_SEL'h4,
	       `ALU_ENT_SEL'h3, `ALU_ENT_SEL'h2, `ALU_ENT_SEL'h1, `ALU_ENT_SEL'h0}),
        .value_vector_i(alu_history_vector),
        .oldest_entry_o(alu_issue_entry),
        .oldest_value_o(alu_entry_value)
    );

    always@(posedge clk_i)begin
        if(reset_i)begin
            // 初始化数据
            exe_alu_op_1_o <= 0;
            exe_alu_op_2_o <= 0;
            exe_alu_pc_o <= 0;
            exe_alu_imm_o <= 0;
            exe_alu_rrf_tag_o <= 0;
            exe_alu_dst_val_o <= 0;
            exe_alu_op_o <= 0;
        end else begin
            // 上升沿为输出数据赋值
            exe_alu_op_1_o <= exe_alu_op_1;
            exe_alu_op_2_o <= exe_alu_op_2;
            exe_alu_pc_o <= exe_alu_pc;
            exe_alu_imm_o <= exe_alu_imm;
            exe_alu_rrf_tag_o <= exe_alu_rrf_tag;
            exe_alu_dst_val_o <= exe_alu_dst_val;
            exe_alu_op_o <= exe_alu_op;
        end
    end

endmodule