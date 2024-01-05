`include "consts/Consts.vh"
`default_nettype none
module SrcOprManager (
    input  wire                 arf_busy_i,
    input  wire [`DATA_LEN-1:0] arf_data_i,
    input  wire [ `RRF_SEL-1:0] arf_rrftag_i,
    input  wire                 rrf_valid_i,
    input  wire [`DATA_LEN-1:0] rrf_data_i,
    input  wire                 src_eq_zero_i,
    output wire [`DATA_LEN-1:0] src_o,
    output wire                 ready_o
);

    assign src_o   = src_eq_zero_i ? `DATA_LEN'b0 : ~arf_busy_i ? arf_data_i : rrf_valid_i ? rrf_data_i : {26'b0, arf_rrftag_i};
    // 表明src是否已经就绪，即src中已经是data了，而不是rrftag
    assign ready_o = src_eq_zero_i | ~arf_busy_i | rrf_valid_i;
endmodule
`default_nettype wire
