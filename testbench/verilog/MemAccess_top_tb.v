`timescale 1ns / 1ps
`include "consts/Consts.vh"

module MemAccessTopTB();

    // Inputs
    reg   clk_i                                = 0 ;
    reg   reset_i                              = 1 ;
    reg   [`DATA_LEN-1:0]  src1_i              = 0 ;
    reg   [`DATA_LEN-1:0]  src2_i              = 0 ;
    reg   [`DATA_LEN-1:0]  imm_i               = 0 ;
    reg   if_write_rrf_i                       = 0 ;
    reg   issue_i                              = 0 ;
    reg   complete_i                           = 0 ;

    // Outputs
    wire  rrf_we_o                             ;
    wire  rob_we_o                             ;
    wire  [`DATA_LEN-1:0]  load_data_o         ;

    MemAccessTop  mem_access_top (
        .clk_i                   ( clk_i                              ),
        .reset_i                 ( reset_i                            ),
        .src1_i                  ( src1_i             [`DATA_LEN-1:0] ),
        .src2_i                  ( src2_i             [`DATA_LEN-1:0] ),
        .imm_i                   ( imm_i              [`DATA_LEN-1:0] ),
        .if_write_rrf_i          ( if_write_rrf_i                     ),
        .issue_i                 ( issue_i                            ),
        .complete_i              ( complete_i                         ),

        .rrf_we_o                ( rrf_we_o                           ),
        .rob_we_o                ( rob_we_o                           ),
        .load_data_o             ( load_data_o        [`DATA_LEN-1:0] )
    );

    initial begin
        #10 reset_i=0;

        // store 1 to 0x80000000
        #10 issue_i=1;src1_i=`DATA_LEN'h80000000;imm_i=`DATA_LEN'h00000000;src2_i=`DATA_LEN'h00000001;

        // store 2 to 0x80000004
        #10 src1_i=`DATA_LEN'h80000000;imm_i=`DATA_LEN'h00000004;src2_i=`DATA_LEN'h00000002;

        // store 3 to 0x80000008
        #10 src1_i=`DATA_LEN'h80000000;imm_i=`DATA_LEN'h00000008;src2_i=`DATA_LEN'h00000003;

        // load 0x80000000 (actually from store buffer)
        #10 if_write_rrf_i=1;src1_i=`DATA_LEN'h80000000;imm_i=`DATA_LEN'h00000000;

        #10 complete_i=1;
        #20 complete_i=0;

        // load 0x80000004 (actually from mem)
        #10 src1_i=`DATA_LEN'h80000000;imm_i=`DATA_LEN'h00000004;

        // load 0x80000008 (actually from store buffer)
        #10 src1_i=`DATA_LEN'h80000000;imm_i=`DATA_LEN'h00000008;

        #10 $display("test finish."); $finish();
    end

    always #5 clk_i=~clk_i;

endmodule