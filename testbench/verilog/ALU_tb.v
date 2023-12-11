`timescale 1ns / 1ps
`include "consts/Consts.vh"
`include "consts/ALU.vh"

module ALU_tb();
    // 输入
    reg clk_i;
    reg reset_i;
    reg if_write_rrf_i;
    reg [`ALU_OP_WIDTH-1:0]   alu_op_i;
    reg [`DATA_LEN-1:0] src1_i;
    reg [`DATA_LEN-1:0] src2_i;
    reg issue_i;

    // 输出
    wire [`DATA_LEN-1:0] result_o;
    wire reorder_buffer_we_o;
    wire rename_register_we_o;

   AluExeUnit alu(
   .clk_i(clk_i),
   .reset_i(reset_i),
   .if_write_rrf_i(if_write_rrf_i),
   .alu_op_i(alu_op_i),
   .src1_i(src1_i),
   .src2_i(src2_i),
   .issue_i(issue_i),
   .result_o(result_o),
   .reorder_buffer_we_o(reorder_buffer_we_o),
   .rename_register_we_o(rename_register_we_o)
   );

    initial begin
        clk_i = 0;
        reset_i = 1;
        if_write_rrf_i = 0;
        alu_op_i = 0;
        src1_i = 0;
        src2_i = 0;
        issue_i = 0; 

        #10;
        reset_i=0;

        #10;
        alu_op_i= `ALU_OP_ADD;
        src1_i = `DATA_LEN'd10;
        src2_i = `DATA_LEN'd12;
        issue_i = 1;
        if_write_rrf_i=1;

        #10;
        reset_i=1;

        #10 $finish();
    end

    always #5 clk_i=~clk_i;


endmodule
