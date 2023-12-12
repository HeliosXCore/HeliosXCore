`include "consts/Consts.vh"
`include "consts/ALU.vh"

module ExUnit (
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

    // latch
    reg [`DATA_LEN-1:0] result_latch;
    reg reorder_buffer_we_latch;
    reg rename_register_we_latch;

    // save alu result to latch
    wire [`DATA_LEN-1:0] result;
    wire reorder_buffer_we;
    wire rename_register_we;

    // latch to next stage
    assign result_o = result_latch;
    assign reorder_buffer_we_o = reorder_buffer_we_latch;
    assign rename_register_we_o = rename_register_we_latch;

    AluExeUnit alu(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .if_write_rrf_i(if_write_rrf_i),
        .alu_op_i(alu_op_i),
        .src1_i(src1_i),
        .src2_i(src2_i),
        .issue_i(issue_i),
        .result_o(result),
        .reorder_buffer_we_o(reorder_buffer_we),
        .rename_register_we_o(rename_register_we)
   );

    always @(posedge clk_i) begin
        if (reset_i) begin
            result_latch <= 0;
            reorder_buffer_we_latch <= 0;
            rename_register_we_latch <= 0;
        end else begin
            result_latch <= result;
            reorder_buffer_we_latch <= reorder_buffer_we;
            rename_register_we_latch <= rename_register_we;
        end
    end

endmodule