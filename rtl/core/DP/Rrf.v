`include "consts/Consts.vh"
`default_nettype none

// 重命名寄存器
module Rrf (
    input wire clk_i,
    input wire reset_i,

    // 读rrf
    // 源寄存器对应的rrftag
    input wire [`RRF_SEL-1:0] rs1_rrftag_i,
    input wire [`RRF_SEL-1:0] rs2_rrftag_i,
    //根据源寄存器对应的rrftag读取到的rrf.data域
    output wire [`DATA_LEN-1:0] rs1_rrfdata_o,
    output wire [`DATA_LEN-1:0] rs2_rrfdata_o,
    output wire rs1_rrfvalid_o,
    output wire rs2_rrfvalid_o,


    // 执行部件前递回来的执行结果
    input wire forward_rrf_we_alu1_i,
    input wire [`RRF_SEL-1:0] forward_rrftag_alu1_i,
    input wire [`DATA_LEN-1:0] forward_rrfdata_alu1_i,

    input wire forward_rrf_we_alu2_i,
    input wire [`RRF_SEL-1:0] forward_rrftag_alu2_i,
    input wire [`DATA_LEN-1:0] forward_rrfdata_alu2_i,

    input wire forward_rrf_we_ldst_i,
    input wire [`RRF_SEL-1:0] forward_rrftag_ldst_i,
    input wire [`DATA_LEN-1:0] forward_rrfdata_ldst_i,

    input wire forward_rrf_we_mul_i,
    input wire [`RRF_SEL-1:0] forward_rrftag_mul_i,
    input wire [`DATA_LEN-1:0] forward_rrfdata_mul_i,

    input wire forward_rrf_we_branch_i,
    input wire [`RRF_SEL-1:0] forward_rrftag_branch_i,
    input wire [`DATA_LEN-1:0] forward_rrfdata_branch_i,


    // 为目的寄存器分配的空闲rrf enty
    input wire allocate_rrf_en_i,
    input wire [`RRF_SEL-1:0] allocate_rrftag_i,


    // 指令在COM阶段之后，需要将rrf.data copy到arf.data，所以COM部件就需要把他提
    // 交的指令对应目的寄存器的rrftag传给rrf
    input  wire [ `RRF_SEL-1:0] completed_dst_rrftag_i,
    output wire [`DATA_LEN-1:0] data_to_arfdata_o
);

    reg [`RRF_NUM-1:0] rrf_valid;
    reg [`DATA_LEN-1:0] rrf_data[`RRF_NUM-1:0];


    // 如果在读rrf.data的时候，如果当前rrf.valid为0,且需要的结果刚好前递回来，这时应当选择这个前递回
    // 来的结果，所以这里需要加一个bypass,用来选择一下
    wire forward_accessible_1;
    assign forward_accessible_1 = ( forward_rrf_we_alu1_i | forward_rrf_we_alu2_i | forward_rrf_we_ldst_i | forward_rrf_we_mul_i | forward_rrf_we_branch_i ) ?
    ((rs1_rrftag_i==forward_rrftag_alu1_i)
    |(rs1_rrftag_i==forward_rrftag_alu2_i)
    |(rs1_rrftag_i==forward_rrftag_ldst_i)
    |(rs1_rrftag_i==forward_rrftag_mul_i)
    |(rs1_rrftag_i==forward_rrftag_branch_i))
    :0;
    wire forward_accessible_2;
    assign forward_accessible_2 =( forward_rrf_we_alu1_i | forward_rrf_we_alu2_i | forward_rrf_we_ldst_i | forward_rrf_we_mul_i | forward_rrf_we_branch_i ) ?
    ((rs2_rrftag_i==forward_rrftag_alu1_i)
    |(rs2_rrftag_i==forward_rrftag_alu2_i)
    |(rs2_rrftag_i==forward_rrftag_ldst_i)
    |(rs2_rrftag_i==forward_rrftag_mul_i)
    |(rs2_rrftag_i==forward_rrftag_branch_i))
    :0;

    wire rs1_rrfvalid;
    wire rs2_rrfvalid;
    assign rs1_rrfvalid = rrf_valid[rs1_rrftag_i];
    assign rs2_rrfvalid = rrf_valid[rs2_rrftag_i];

    // 读rrf
    // 读rrf.data
    // 当当前rrf.data可用时，直接读取当前的rrf.data;如果当前rrf.data不可用，需要看看前递结果是否可用，如果前递结果可用，就用前递结果；
    assign rs1_rrfdata_o  = ( ~rs1_rrfvalid & forward_accessible_1 ) ?
    (
      (rs1_rrftag_i==forward_rrftag_alu1_i)?forward_rrfdata_alu1_i:
      (rs1_rrftag_i==forward_rrftag_alu2_i)?forward_rrfdata_alu2_i:
      (rs1_rrftag_i==forward_rrftag_ldst_i)?forward_rrfdata_ldst_i:
      (rs1_rrftag_i==forward_rrftag_mul_i)?forward_rrfdata_mul_i:
      forward_rrfdata_branch_i
    )
    : rrf_data[rs1_rrftag_i];

    assign rs2_rrfdata_o  = ( ~rs2_rrfvalid& forward_accessible_2 ) ?
    (
      (rs2_rrftag_i==forward_rrftag_alu1_i)?forward_rrfdata_alu1_i:
      (rs2_rrftag_i==forward_rrftag_alu2_i)?forward_rrfdata_alu2_i:
      (rs2_rrftag_i==forward_rrftag_ldst_i)?forward_rrfdata_ldst_i:
      (rs2_rrftag_i==forward_rrftag_mul_i)?forward_rrfdata_mul_i:
      forward_rrfdata_branch_i
    )
    : rrf_data[rs2_rrftag_i];

    // 读rrf.valid
    assign rs1_rrfvalid_o = (~rs1_rrfvalid & forward_accessible_1) ? 1 : rrf_valid[rs1_rrftag_i];
    assign rs2_rrfvalid_o = (~rs2_rrfvalid & forward_accessible_2) ? 1 : rrf_valid[rs2_rrftag_i];


    // 写执行部件的前递结果
    always @(posedge clk_i) begin
        if (reset_i) begin
            rrf_valid <= 0;
        end else begin
            if (forward_rrf_we_alu1_i) begin
                rrf_data[forward_rrftag_alu1_i]  <= forward_rrfdata_alu1_i;
                rrf_valid[forward_rrftag_alu1_i] <= 1'b1;
            end
            if (forward_rrf_we_alu2_i) begin
                rrf_data[forward_rrftag_alu2_i]  <= forward_rrfdata_alu2_i;
                rrf_valid[forward_rrftag_alu2_i] <= 1'b1;
            end
        end

    end


    // 当为目的寄存器分配了空闲rrf entry后，需要更新
    always @(posedge clk_i) begin
        if (allocate_rrf_en_i) begin
            rrf_valid[allocate_rrftag_i] <= 1'b0;
        end
    end

    // 读数据给arfdata
    assign data_to_arfdata_o = rrf_data[completed_dst_rrftag_i];
endmodule
`default_nettype wire
