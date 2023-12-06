`include "consts/Consts.vh"

// Select and Wakeup 阶段的顶层模块，输入 Dispatch 阶段发送的信号，
// 输出到 Execute 阶段。
module SwUnit(
    input wire clk_i,
    input wire reset_i,

    // 请求 ALU 指令的数量
    input wire [1: 0] req_alu_num_i
);

    wire [`ALU_ENT_NUM-1: 0] busy_alu_vector; 
    wire alu_allocatable;
    wire alu_allocate_en_1;
    wire alu_allocate_en_2;
    wire [`ALU_ENT_SEL: 0] free_alu_entry_1;
    wire [`ALU_ENT_SEL: 0] free_alu_entry_2;
    
    AllocateUnit #(`ALU_ENT_NUM, `ALU_ENT_SEL+1) AluAllocator(
        .busy_i(busy_alu_vector),
        .en_1_o(alu_allocate_en_1),
        .en_2_o(alu_allocate_en_2),
        .free_entry_1_o(free_alu_entry_1),
        .free_entry_2_o(free_alu_entry_2),
        .req_num_i(req_alu_num_i),
        .allocatable_o(alu_allocatable)
    );

endmodule