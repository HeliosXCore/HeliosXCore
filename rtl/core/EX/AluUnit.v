`include "consts/ALU.vh"
`include "consts/Consts.vh"

module AluUnit (
    (* IO_BUFFER_TYPE = "none" *) input wire clk_i,
    (* IO_BUFFER_TYPE = "none" *) input wire reset_i,
    (* IO_BUFFER_TYPE = "none" *) input wire if_write_rrf_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`ADDR_LEN-1:0] pc_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] imm_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`ALU_OP_WIDTH-1:0] alu_op_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] src1_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`SRC_A_SEL_WIDTH-1:0] src_a_select_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] src2_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`SRC_B_SEL_WIDTH-1:0] src_b_select_i,
    (* IO_BUFFER_TYPE = "none" *) input wire issue_i,
    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] result_o,
    (* IO_BUFFER_TYPE = "none" *) output wire rob_we_o,
    (* IO_BUFFER_TYPE = "none" *) output wire rrf_we_o
);

    // 传入的两个源操作数命名为 1、2，经过选择后实际 ALU 计算的操作数命名为 a、b
    wire [`DATA_LEN-1:0] src_a;
    wire [`DATA_LEN-1:0] src_b;

    assign rob_we_o = issue_i;  // 向 ROB 发送完成信号
    assign rrf_we_o = issue_i & if_write_rrf_i;  // 向 RRF 发送写信号


    SrcASelect src_a_select (
        .src_a_sel(src_a_select_i),
        .pc(pc_i),
        .rs1(src1_i),
        .alu_src_a(src_a)
    );

    SrcBSelect src_b_select (
        .src_b_sel(src_b_select_i),
        .imm(imm_i),
        .rs2(src2_i),
        .alu_src_b(src_b)
    );

    Alu alu (
        .op (alu_op_i),
        .in1(src_a),
        .in2(src_b),
        .out(result_o)
    );

endmodule
