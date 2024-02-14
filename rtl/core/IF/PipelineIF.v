`include "consts/Consts.vh"
`default_nettype none
module PipelineIF (
    input wire                 clk_i,
    input wire                 reset_i,
    input wire [`ADDR_LEN-1:0] pc_i,
    input wire [`INSN_LEN-1:0] idata_i,

    output wire [`ADDR_LEN-1:0] npc_o,
    output wire [`INSN_LEN-1:0] inst_o
);

    // assign inst_o = idata_i;
    assign inst_o = reset_i ? 0 : idata_i;
    // assign npc_o  = pc_i + 4;
    assign npc_o  = reset_i ? 0 : pc_i + 4;

    // Selector selector (
    //     .sel_i  (pc_i[2:2]),
    //     .idata_i(idata_i),
    //     .inst1_o(inst1_o)
    // );
endmodule


// module Selector (
//     input wire [0:0] sel_i,
//     input wire [2*`INSN_LEN-1:0] idata_i,
//     output wire [`INSN_LEN-1:0] inst1_o
// );

//     assign inst1_o = (sel_i == 1'b0) ? idata_i[31:0] : (sel_i == 1'b1) ? idata_i[63:32] : `INSN_LEN'h0;

// endmodule
// `default_nettype wire
