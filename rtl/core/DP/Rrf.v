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
    input wire forward_rrf_we_i,
    input wire [`RRF_SEL-1:0] forward_rrftag_i,
    input wire [`DATA_LEN-1:0] forward_rrfdata_i,


    // 为目的寄存器分配的空闲rrf enty
    input wire allocate_rrf_en_i,
    input wire [`RRF_SEL-1:0] allocate_rrftag_i,


    // 指令在COM阶段之后，需要将rrf.data copy到arf.data，所以COM部件就需要把他提
    // 交的指令对应目的寄存器的rrftag传给rrf
    input  wire [ `RRF_SEL-1:0] completed_dst_rrftag_i,
    output wire [`DATA_LEN-1:0] data_to_arfdata_o
);

    reg [ `RRF_NUM-1:0] rrf_valid;
    reg [`DATA_LEN-1:0] rrf_data  [`RRF_NUM-1:0];

    // 读rrf
    // 读rrf.data
    assign rs1_rrfdata_o  = rrf_data[rs1_rrftag_i];
    assign rs2_rrfdata_o  = rrf_data[rs2_rrftag_i];
    // 读rrf.valid
    assign rs1_rrfvalid_o = rrf_valid[rs1_rrftag_i];
    assign rs2_rrfvalid_o = rrf_valid[rs2_rrftag_i];


    // 写执行部件的前递结果
    always @(posedge clk_i) begin
        if (reset_i) begin
            rrf_valid <= 0;
        end else if (forward_rrf_we_i) begin
            rrf_data[forward_rrftag_i]  <= forward_rrfdata_i;
            rrf_valid[forward_rrftag_i] <= 1'b1;
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
