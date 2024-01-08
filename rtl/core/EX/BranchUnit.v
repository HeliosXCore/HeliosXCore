`include "consts/ALU.vh"
`include "consts/Consts.vh"
`include "consts/Opcodes.vh"

module BranchUnit (
    (* IO_BUFFER_TYPE = "none" *) input wire clk_i,
    (* IO_BUFFER_TYPE = "none" *) input wire reset_i,
    (* IO_BUFFER_TYPE = "none" *) input wire if_write_rrf_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`ALU_OP_WIDTH-1:0] alu_op_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] src1_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] src2_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`ADDR_LEN-1:0] pc_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] imm_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`OPCODE_LEN-1:0] opcode_i,
    (* IO_BUFFER_TYPE = "none" *) input wire issue_i,

    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] result_o,
    (* IO_BUFFER_TYPE = "none" *) output wire rob_we_o,
    (* IO_BUFFER_TYPE = "none" *) output wire rrf_we_o,
    (* IO_BUFFER_TYPE = "none" *) output wire [`ADDR_LEN-1:0] jump_result_o,
    // 下面两个值传给 ROB 用来分支预测
    (* IO_BUFFER_TYPE = "none" *) output wire [`ADDR_LEN-1:0] jump_addr_o,
    (* IO_BUFFER_TYPE = "none" *) output wire if_jump_o
);

    // 当前部件是否有指令在运行
    reg busy;
    assign rob_we_o = busy;  // 向 ROB 发送完成信号
    assign rrf_we_o = busy & if_write_rrf_i;  // 向 RRF 发送写信号

    wire [`DATA_LEN-1:0] compare_result;

    // 判断是否满足跳转条件，其中 JAL 和 JALR 是无条件跳转，恒为 1
    // 只用最低一位就可以判断条件吗?
    assign if_jump_o = ((opcode_i == `RV32_JAL) || (opcode_i == `RV32_JALR)) ? 1 : compare_result[0];

    // 计算跳转目标地址，其中 JALR 由 src1 给出基址
    assign jump_addr_o = (((opcode_i == `RV32_JALR) ? src1_i : pc_i) + imm_i);

    // 跳转结果，如果跳转则值为 jump_addr_o，否则为 pc + 4 
    assign jump_result_o = if_jump_o ? jump_addr_o : (pc_i + 4);

    // 输出恒为 pc + 4，用于写入 rd
    assign result_o = pc_i + 4;

    always @(posedge clk_i) begin
        if (reset_i) begin
            busy <= 0;
        end else begin
            busy <= issue_i;
        end
    end

    ALU comparator (
        .op (alu_op_i),
        .in1(src1_i),
        .in2(src2_i),
        .out(compare_result)
    );

endmodule
