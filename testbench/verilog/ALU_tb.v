`timescale 1ns / 1ps
`include "consts/Consts.vh"
`include "consts/ALU.vh"

module ALU_tb();
    // AluExeUnit Inputs
    reg   clk_i                                = 0 ;
    reg   reset_i                              = 0 ;
    reg   if_write_rrf_i                       = 0 ;
    reg   [`ADDR_LEN-1:0]  pc_i                = 0 ;
    reg   [`DATA_LEN-1:0]  imm_i               = 0 ;
    reg   [`ALU_OP_WIDTH-1:0]  alu_op_i        = 0 ;
    reg   [`DATA_LEN-1:0]  src1_i              = 0 ;
    reg   [`SRC_A_SEL_WIDTH-1:0]  src_a_select_i = 0 ;
    reg   [`DATA_LEN-1:0]  src2_i              = 0 ;
    reg   [`SRC_B_SEL_WIDTH-1:0]  src_b_select_i = 0 ;
    reg   issue_i                              = 0 ;

    // AluExeUnit Outputs
    wire  [`DATA_LEN-1:0]  result_o            ;
    wire  rob_we_o                             ;
    wire  rrf_we_o                             ;

    AluUnit  u_AluUnit (
    .clk_i                   ( clk_i                                  ),
    .reset_i                 ( reset_i                                ),
    .if_write_rrf_i          ( if_write_rrf_i                         ),
    .pc_i                    ( pc_i            [`ADDR_LEN-1:0]        ),
    .imm_i                   ( imm_i           [`DATA_LEN-1:0]        ),
    .alu_op_i                ( alu_op_i        [`ALU_OP_WIDTH-1:0]    ),
    .src1_i                  ( src1_i          [`DATA_LEN-1:0]        ),
    .src_a_select_i           ( src_a_select_i   [`SRC_A_SEL_WIDTH-1:0] ),
    .src2_i                  ( src2_i          [`DATA_LEN-1:0]        ),
    .src_b_select_i           ( src_b_select_i   [`SRC_B_SEL_WIDTH-1:0] ),
    .issue_i                 ( issue_i                                ),

    .result_o                ( result_o        [`DATA_LEN-1:0]        ),
    .rob_we_o                ( rob_we_o                               ),
    .rrf_we_o                ( rrf_we_o                               )
);
    
    initial begin
        clk_i = 0;
        reset_i = 1;
        if_write_rrf_i = 0;
        alu_op_i = 0;
        src1_i = 0;
        src2_i = 0;
        issue_i = 0; 
        pc_i = 0;
        imm_i = 0;
        src_a_select_i = 0;
        src_b_select_i = 0;

        #10; $display("test start.");
        reset_i=0;
        

        #10;
        issue_i = 1; 
        if_write_rrf_i=1; 
        alu_op_i= `ALU_OP_ADD; 
        src1_i = `DATA_LEN'd10; 
        src2_i = `DATA_LEN'd12; 
        src_a_select_i= `SRC_A_RS1; 
        src_b_select_i = `SRC_B_RS2;
        #1; if (result_o != 'd22) $display("add failed. result_o=%0d, src1_i=%0d, src2_i=%0d", result_o, src1_i, src2_i);

        #10;
        reset_i=1;

        #10 $display("test finish."); $finish();
    end

    always #5 clk_i=~clk_i;


endmodule
