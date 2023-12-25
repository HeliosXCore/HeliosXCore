`include "consts/Consts.vh"
`include "consts/ALU.vh"
`include "consts/Opcodes.vh"

module ExUnit (
    (* IO_BUFFER_TYPE = "none" *) input wire clk_i,
    (* IO_BUFFER_TYPE = "none" *) input wire reset_i,

    // ALU 输入
    (* IO_BUFFER_TYPE = "none" *) input wire alu_if_write_rrf_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`RRF_SEL-1:0] alu_rrf_tag_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`ADDR_LEN-1:0] alu_pc_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] alu_imm_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`ALU_OP_WIDTH-1:0] alu_alu_op_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] alu_src1_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`SRC_A_SEL_WIDTH-1:0] alu_src_a_select_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] alu_src2_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`SRC_B_SEL_WIDTH-1:0] alu_src_b_select_i,
    (* IO_BUFFER_TYPE = "none" *) input wire alu_issue_i,
    
    // ALU 输出
    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] alu_result_o,
    (* IO_BUFFER_TYPE = "none" *) output wire [`RRF_SEL-1:0] alu_rrf_tag_o,
    (* IO_BUFFER_TYPE = "none" *) output wire alu_rob_we_o,
    (* IO_BUFFER_TYPE = "none" *) output wire alu_rrf_we_o,

    // Branch 输入
    (* IO_BUFFER_TYPE = "none" *) input wire branch_if_write_rrf_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`RRF_SEL-1:0] branch_rrf_tag_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`ADDR_LEN-1:0] branch_pc_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] branch_imm_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`ALU_OP_WIDTH-1:0] branch_alu_op_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] branch_src1_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`DATA_LEN-1:0] branch_src2_i,
    (* IO_BUFFER_TYPE = "none" *) input wire [`OPCODE_LEN-1:0] branch_opcode_i,
    (* IO_BUFFER_TYPE = "none" *) input wire branch_issue_i,

    // Branch 输出
    (* IO_BUFFER_TYPE = "none" *) output wire [`DATA_LEN-1:0] branch_result_o,
    (* IO_BUFFER_TYPE = "none" *) output wire [`RRF_SEL-1:0] branch_rrf_tag_o,
    (* IO_BUFFER_TYPE = "none" *) output wire branch_rob_we_o,
    (* IO_BUFFER_TYPE = "none" *) output wire branch_rrf_we_o,
    (* IO_BUFFER_TYPE = "none" *) output wire [`ADDR_LEN-1:0] branch_jump_result_o,
    (* IO_BUFFER_TYPE = "none" *) output wire [`ADDR_LEN-1:0] branch_jump_addr_o,
    (* IO_BUFFER_TYPE = "none" *) output wire branch_if_jump_o
);

    //---------------------------------------------------- ALU --------------------------------------------------------

    // ALU 执行结果锁存器
    reg [`DATA_LEN-1:0] alu_result_latch;
    reg [`RRF_SEL-1:0] alu_rrf_tag_latch;
    reg alu_rob_we_latch;
    reg alu_rrf_we_latch;

    // ALU 执行结果 -> 锁存器
    wire [`DATA_LEN-1:0] alu_result;
    wire alu_rob_we;
    wire alu_rrf_we;

    AluUnit alu_unit(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .if_write_rrf_i(alu_if_write_rrf_i),
        .pc_i(alu_pc_i),
        .imm_i(alu_imm_i),
        .alu_op_i(alu_alu_op_i),
        .src1_i(alu_src1_i),
        .src_a_select_i(alu_src_a_select_i),
        .src2_i(alu_src2_i),
        .src_b_select_i(alu_src_b_select_i),
        .issue_i(alu_issue_i),

        .result_o(alu_result),
        .rob_we_o(alu_rob_we),
        .rrf_we_o(alu_rrf_we)
   );

    // 上升沿保存 ALU 执行结果到锁存器中
    always @(posedge clk_i) begin
        if (reset_i) begin
            alu_result_latch <= 0;
            alu_rrf_tag_latch <= 0;
            alu_rob_we_latch <= 0;
            alu_rrf_we_latch <= 0;
        end else begin
            alu_result_latch <= alu_result;
            alu_rrf_tag_latch <= alu_rrf_tag_i;
            alu_rob_we_latch <= alu_rob_we;
            alu_rrf_we_latch <= alu_rrf_we;   
        end
    end

    // 锁存器 -> ALU 输出信号
    assign alu_result_o = alu_result_latch;
    assign alu_rob_we_o = alu_rob_we_latch;
    assign alu_rrf_we_o = alu_rrf_we_latch;
    assign alu_rrf_tag_o = alu_rrf_tag_latch;


    //---------------------------------------------------- Branch --------------------------------------------------------

    // Branch 执行结果锁存器
    reg [`DATA_LEN-1:0] branch_result_latch;
    reg [`RRF_SEL-1:0] branch_rrf_tag_latch;
    reg branch_rob_we_latch;
    reg branch_rrf_we_latch;
    reg [`ADDR_LEN-1:0] branch_jump_result_latch;
    reg [`ADDR_LEN-1:0] branch_jump_addr_latch;
    reg branch_if_jump_latch;

    // Branch 执行结果 -> Branch 锁存器
    wire [`DATA_LEN-1:0] branch_result;
    wire branch_rob_we;
    wire branch_rrf_we;
    wire [`ADDR_LEN-1:0] branch_jump_result;
    wire [`ADDR_LEN-1:0] branch_jump_addr;
    wire branch_if_jump;

    BranchUnit branch_unit (
        .clk_i                   ( clk_i             ),
        .reset_i                 ( reset_i           ),
        .if_write_rrf_i          ( branch_if_write_rrf_i    ),
        .alu_op_i                ( branch_alu_op_i          ),
        .src1_i                  ( branch_src1_i            ),
        .src2_i                  ( branch_src2_i            ),
        .pc_i                    ( branch_pc_i              ),
        .imm_i                   ( branch_imm_i             ),
        .opcode_i                ( branch_opcode_i          ),
        .issue_i                 ( branch_issue_i           ),

        .result_o                ( branch_result          ),
        .rob_we_o                ( branch_rob_we          ),
        .rrf_we_o                ( branch_rrf_we          ),
        .jump_result_o           ( branch_jump_result     ),
        .jump_addr_o             ( branch_jump_addr   ),
        .if_jump_o               ( branch_if_jump          )
    );

    // 上升沿保存 Branch 执行结果到锁存器中
    always @(posedge clk_i) begin
        if (reset_i) begin
            branch_result_latch <= 0;
            branch_rrf_tag_latch <= 0;
            branch_rob_we_latch <= 0;
            branch_rrf_we_latch <= 0;
            branch_jump_result_latch <= 0;
            branch_jump_addr_latch <= 0;
            branch_if_jump_latch <= 0;
            
        end else begin
            branch_result_latch <= branch_result;
            branch_rrf_tag_latch <= branch_rrf_tag_i;
            branch_rob_we_latch <= branch_rob_we;
            branch_rrf_we_latch <= branch_rrf_we;
            branch_jump_result_latch <= branch_jump_result;
            branch_jump_addr_latch <= branch_jump_addr;
            branch_if_jump_latch <=  branch_if_jump;
        end
    end

    // Branch 锁存器 -> Branch 输出信号
    assign branch_result_o = branch_result_latch;
    assign branch_rrf_tag_o = branch_rrf_tag_latch;
    assign branch_rob_we_o = branch_rob_we_latch;
    assign branch_rrf_we_o = branch_rrf_we_latch;
    assign branch_jump_result_o = branch_jump_result_latch;
    assign branch_jump_addr_o = branch_jump_addr_latch;
    assign branch_if_jump_o = branch_if_jump_latch;
   

endmodule