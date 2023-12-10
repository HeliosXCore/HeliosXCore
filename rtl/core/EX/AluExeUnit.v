`include "consts/ALU.vh"
`include "consts/Consts.vh"

module AluExeUnit (
    input wire clk_i,
    input wire reset_i,
    input wire if_write_rrf_i,
    input wire [`ALU_OP_WIDTH-1:0] alu_op_i,
    input wire [`DATA_LEN-1:0] src1_i,
    input wire [`DATA_LEN-1:0] src2_i,
    input wire issue_i,
    output wire [`DATA_LEN-1:0] result_o,
    output wire reorder_buffer_we_o,
    output wire rename_register_we_o
);

    // 当前部件是否有指令在运行
    reg busy;
    assign reorder_buffer_we_o  = busy;
    assign rename_register_we_o = busy & if_write_rrf_i;

    always @(posedge clk_i) begin
        if (reset_i) begin
            busy <= 0;
        end else begin
            busy <= issue_i;
        end
    end

    assign result_o = (alu_op_i == `ALU_OP_ADD) ? (src1_i + src2_i) : 0;

endmodule
