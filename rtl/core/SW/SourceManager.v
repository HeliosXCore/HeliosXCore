`include "consts/Consts.vh"

module SourceManager (
    input  wire [`DATA_LEN-1:0] src_i,
    input  wire                 src_ready_i,
    input  wire [`DATA_LEN-1:0] exe_result_1_i,
    input  wire [ `RRF_SEL-1:0] exe_dst_1_i,
    //    input wire 		       kill_spec1,
    input  wire [`DATA_LEN-1:0] exe_result_2_i,
    input  wire [ `RRF_SEL-1:0] exe_dst_2_i,
    //    input wire 		       kill_spec2,
    input  wire [`DATA_LEN-1:0] exe_result_3_i,
    input  wire [ `RRF_SEL-1:0] exe_dst_3_i,
    //    input wire 		       kill_spec3,
    input  wire [`DATA_LEN-1:0] exe_result_4_i,
    input  wire [ `RRF_SEL-1:0] exe_dst_4_i,
    //    input wire 		       kill_spec4,
    input  wire [`DATA_LEN-1:0] exe_result_5_i,
    input  wire [ `RRF_SEL-1:0] exe_dst_5_i,
    //    input wire 		       kill_spec5,
    output wire [`DATA_LEN-1:0] src_o,
    output wire                 resolved_o
);

    assign src_o = src_ready_i ? src_i :
        exe_dst_1_i == src_i[`RRF_SEL-1: 0]? exe_result_1_i :
        exe_dst_2_i == src_i[`RRF_SEL-1: 0]? exe_result_2_i :
        exe_dst_3_i == src_i[`RRF_SEL-1: 0]? exe_result_3_i :
        exe_dst_4_i == src_i[`RRF_SEL-1: 0]? exe_result_4_i :
        exe_dst_5_i == src_i[`RRF_SEL-1: 0]? exe_result_5_i : src_i;

    assign resolved_o = src_ready_i |
        (exe_dst_1_i == src_i[`RRF_SEL-1: 0]) |
        (exe_dst_2_i == src_i[`RRF_SEL-1: 0]) |
        (exe_dst_3_i == src_i[`RRF_SEL-1: 0]) |
        (exe_dst_4_i == src_i[`RRF_SEL-1: 0]) |
        (exe_dst_5_i == src_i[`RRF_SEL-1: 0]);

endmodule  // src_manager


