`include "consts/Consts.vh"
`default_nettype none
module PipelineIF(
	input wire 			  clk_i,
    input wire 			  reset_i,
    input wire [`ADDR_LEN-1:0] 	  pc_i,
    input wire [4*`INSN_LEN-1:0]   idata_i,
	  
    output wire [`ADDR_LEN-1:0] 	  npc_o,
    output wire [`INSN_LEN-1:0] 	  inst1_o
);

	assign npc_o = pc_i + 4;

    Selector selector(
		.sel_i(pc_i[3:2]),
	    .idata_i(idata_i),
	    .inst1_o(inst1_o)
	);
endmodule


module Selector(
	input wire [1:0] 		sel_i,
	input wire [4*`INSN_LEN-1:0] idata_i,
	output wire [`INSN_LEN-1:0] 	inst1_o
);

	assign inst1_o = (sel_i == 2'b00) ? idata_i[31:0] :
					 (sel_i == 2'b01) ? idata_i[63:32] :
				 	 (sel_i == 2'b10) ? idata_i[95:64] :
				 	 (sel_i == 2'b11) ? idata_i[127:96] :
				 	 `INSN_LEN'h0;
   
endmodule
`default_nettype wire
