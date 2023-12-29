`include "consts/Consts.v"
`default_nettype none
module PipelineIF
  (
   input wire 			  clk_i,
   input wire 			  reset_i,
   input wire [`ADDR_LEN-1:0] 	  pc_i,
   input wire [4*`INSN_LEN-1:0]   idata_i,
	  
   output wire [`ADDR_LEN-1:0] 	  npc_o,
   output wire [`INSN_LEN-1:0] 	  inst1_o
   );

   assign npc_o = pc_i + 4;

   select_logic sellog(
	   .sel_i(pc_i[3:2]),
	   .idata_i(idata_i),
	   .inst1_o(inst1_o)
   );
endmodule


module select_logic
  (
	  input wire [1:0] 		sel_i,
	  input wire [4*`INSN_LEN-1:0] idata_i,
	  output reg [`INSN_LEN-1:0] 	inst1_o
   );

   always @ (*) begin
      inst1_o = `INSN_LEN'h0;
//      inst2_o = `INSN_LEN'h0;
      
	   case(sel_i)
	2'b00 : begin
	   inst1_o = idata_i[31:0];
//	   inst2_o = idata_i[63:32];
	end
	2'b01 : begin
	   inst1_o = idata_i[63:32];
//	   inst2_o = idata_i[95:64];
	end
	2'b10 : begin
	   inst1_o = idata_i[95:64];
//	   inst2_o = idata_i[127:96];
	end
	2'b11 : begin
	   inst1_o = idata_i[127:96];
//	   inst2_o = idata_i[31:0];
	end
      endcase // case (sel)
   end
   
endmodule // select_logic

`default_nettype wire
